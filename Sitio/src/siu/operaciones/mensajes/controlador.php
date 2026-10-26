<?php

namespace siu\operaciones\mensajes;

use kernel\kernel;
use kernel\util\MailJob;
use kernel\util\validador;
use siu\guarani;
use siu\errores\error_guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\util;
use \siu\modelo\datos\catalogo;
use kernel\util\mail;

class controlador extends controlador_g3w2
{
	function get_clase_vista()
	{
		if ($this->accion == 'enviar_mensaje') { 
			return 'vista_envio_mensaje';
		} else {
			return 'vista_lista_mensajes';
		}
	}

	function modelo()
	{
		return guarani::mensajes();
	}

	function accion__index()
	{
		$lista_mensajes = $this->vista()->pagelet('lista_mensajes');
		$lista_mensajes->set_estado_info(pagelet_lista_mensajes::E_RECIBIDOS);
	}

	function accion__enviados()
	{
		$lista_mensajes = $this->vista()->pagelet('lista_mensajes');
		$lista_mensajes->set_estado_info(pagelet_lista_mensajes::E_ENVIADOS);
	}

	function accion__leer_mensaje()
	{
		$anuncio = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		$msg = $this->modelo()->evt__leer_mensaje($anuncio);
		$this->render_ajax_html($msg['mensaje']);
	}

	function accion__leer_mensaje_enviado()
	{
		$id_anuncio = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		$msg = $this->modelo()->evt__leer_mensaje_enviado($id_anuncio);
		$this->render_ajax_html($msg['mensaje']);
	}

    function accion__enviar_mensaje()
    {
        if (! kernel::persona()->perfil()->es('DOC')) {
            throw new error_guarani('error');
        }
        $this->add_var('mensaje_guardado', false);
        if (kernel::request()->isPost()) {

            try
            {
                $tipo_anuncio = $this->validate_param('tipo', 'post', validador::TIPO_ALPHA);
                $tipo_a = $this->validate_param('tipo', 'post', validador::TIPO_ALPHA);
                $titulo = kernel::request()->getPost('titulo');
                $mensaje = kernel::request()->getPost('mensaje');
				$todos_algunos = $this->validate_param('todos_algunos', 'post', validador::TIPO_ALPHA);
				$envia_mail = $this->validate_param('envia_mail', 'post', validador::TIPO_ALPHA, array('allowempty' => true));
				$enviar_a = array();
				if( $todos_algunos == 'AA')
				{
					$enviar_a = $this->validate_param('alumno', 'post', validador::TIPO_ARRAY_TEXTO);
				}
				
				if( $todos_algunos == 'AD')
				{
					$enviar_a = $this->validate_param('docente', 'post', validador::TIPO_ARRAY_TEXTO);
				}

				if($tipo_anuncio == 'com')
				{
					switch($todos_algunos)
					{
						case 'AA': //algunos alumnos
							$tipo_anuncio = 'O';
							$todos_algunos = 'A';
							break;
						case 'AD': //algunos docentes
							$tipo_anuncio = 'B';
							$todos_algunos = 'A';
							break;
						case 'T': //todos
							$tipo_anuncio = 'X';
							break;
							
					}
				}
				
				if($tipo_anuncio == 'mesa')
				{
					switch($todos_algunos)
					{
						case 'AA': //algunos alumnos
							$tipo_anuncio = 'M';
							$todos_algunos = 'A';
							break;
						case 'AD': //algunos docentes
							$tipo_anuncio = 'T';
							$todos_algunos = 'A';
							break;
						case 'T': //todos
							$tipo_anuncio = 'Y';
							break;							
					}
				}

                //$nombre_archivos = $this->guardar_archivos_subidos('archivos', $this->get_path_attachment());

                $mesa = "";
                $comision = "";
                if($tipo_anuncio  == 'M'|| $tipo_anuncio  == 'T'|| $tipo_anuncio  == 'Y') {
                    $mesa = $this->validate_param('mesa', 'post', validador::TIPO_ALPHANUM);
                    $curso = $this->modelo()->get_curso_mesa($mesa);
                } elseif($tipo_anuncio == 'O' || $tipo_anuncio == 'B' || $tipo_anuncio == 'X') {
                    $comision = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM);
                    $curso = $this->modelo()->get_curso_comision($comision);
                }

                if (empty($tipo_anuncio))
                    throw new error_guarani('No ha elegido el tipo de destinatario.');
                if (empty($titulo))
                    throw new error_guarani('Ingrese un título para el mensaje.');
                if (strlen($titulo) > 60)
                    throw new error_guarani('El título no puede tener mas de 60 caracteres.');
                if (empty($mensaje))
                    throw new error_guarani('Ingrese un mensaje.');

                $formato_fecha = '!d/m/Y';
                $fecha_desde = $this->validate_param('fecha_desde', 'post', validador::TIPO_DATE, array('format' => $formato_fecha));
                $fecha_hasta = $this->validate_param('fecha_hasta', 'post', validador::TIPO_DATE, array('format' => $formato_fecha));

                $f_desde = \DateTime::createFromFormat($formato_fecha, $fecha_desde);
                $f_hasta = \DateTime::createFromFormat($formato_fecha, $fecha_hasta);
                $f_actual = $datetime_fecha_actual = new \DateTime('today');

                if ($f_desde < $f_actual) {
                    throw new error_guarani("La fecha desde '$fecha_desde' no puede ser menor a la fecha actual");
                }

                if ($f_desde >= $f_hasta) {
                    throw new error_guarani("La fecha desde '$fecha_desde' no puede ser mayor a fecha hasta '$fecha_hasta'");
                }

                $archivos = array();
                if (isset($_FILES['archivos']))
                {
                    foreach($_FILES['archivos'] as $key => $file)
                    {
                        foreach($file as $id => $data)
                        {
                            if ($_FILES['archivos']['error'][$id] != 4)
                            {
                                switch($key)
                                {
                                    case 'error':
                                        if ($data == 1)
                                        {
                                            $max = ini_get('upload_max_filesize');
                                            if (is_numeric($max))
                                                $max = ($max/1048576).'MB';
                                            throw new error_guarani("Se ha superado el límite máximo de tamaño de archivo ($max).");
                                        }
                                        elseif ($data != 0)
                                            throw new error_guarani('Ha ocurrido un error inesperado subiendo el\los archivo(s). Por favor, intente de nuevo.');
                                        break;
                                    case 'name':
                                        $info = pathinfo($data);
                                        $archivos[$id]['nombre'] = $info['filename'];
                                        $archivos[$id]['extension'] = $info['extension'];
                                        break;
                                    case 'size':
                                        $archivos[$id]['tamanio'] = (int)($data/1024);
                                        break;
                                    case 'tmp_name':
                                        $archivos[$id]['tmp_name'] = $data;
                                        break;
                                    default:
                                        $archivos[$id]['path'] = $this->get_path_attachment();
                                        break;
                                }
                            }
                        }
                    }
                }

                //guardo los archivos en el disco
                $archivos_nuevos = array();
                $nombre_archivos = array();
                if(!empty($archivos)){

                    foreach($archivos as $archivo){
                        $path_carpeta = kernel::proyecto()->get_dir_temp().'/adjuntos_mensajes/'.uniqid();
                        if (!file_exists($path_carpeta)) {
                            //Se crea una carpeta única para el archivo a subir
                            mkdir($path_carpeta, 0777, true);
                        }
                        $archivo['path'] = $path_carpeta.'/'.$archivo['nombre'].'.'.$archivo['extension'];
                        // Se mueven los archivos subidos al servidor del directorio temporal PHP al recientemente creado
                        move_uploaded_file($archivo['tmp_name'], $archivo['path']);
                        $archivos_nuevos[] = $archivo;

                        $nombre_archivos[] = array(
                            'nombre_fs' => $archivo['path'],
                            'nombre_original' => $archivo['nombre']
                        );
                    }

                }

                $enviar_por_mail = "N";
				if ($envia_mail === 'S')
				{
					$enviar_por_mail = $envia_mail;
				}
				
                $enviar_por_sms = "N";

				//remplazo los saltos de lineas de texto plano por saltos de linea en html (<br>)
				$msj_html = str_replace(array("\r\n", "\r", "\n"), "<br>", $mensaje);
				
                $id_mensaje = $this->modelo()->evt__guardar_mensaje(
                    $tipo_anuncio,
                    $curso,
                    $fecha_desde,
                    $fecha_hasta,
                    $titulo,
                    $enviar_por_mail,
                    $enviar_por_sms,
                    $msj_html,
                    $nombre_archivos,
					$todos_algunos,
					$enviar_a	
                );

                $destinatarios = catalogo::consultar('mensajes', 'get_mails_destinatarios_anuncio', array('anuncio' => $id_mensaje));

				if(!empty($destinatarios) and $enviar_por_mail== 'S'){//Si hay destinatarios y el parámetro envía por mail está tildado

                    $mailjob = new MailJob('', "G3W2 -$titulo- ", kernel::load_template('envio_mensajes/mail_envio_mensaje.twig')->render(array(
                            'titulo' => $titulo,
                            'mensaje' => $msj_html,
                            'link' => kernel::vinculador()->crear('mensajes')
                        )),
                        null, '', 'utf-8', $f_desde->format('Y-m-d')
                    );

                    foreach($archivos_nuevos as $archivo){
                        $mailjob->agregar_adjunto($archivo['nombre'].'.'.$archivo['extension'], $archivo['path']);
                    }

                    //Me quedo solo con la columna 'EMAIL' de los destinatarios
                    $func = function($value) {
                        return $value['EMAIL'];
                    };
                    $destinatarios = array_map($func, $destinatarios);

                    $cant_max_destinatarios_por_email = kernel::proyecto()->get_cant_max_destinatarios_por_email();

                    $bloques_destinatarios = array();
                    if($cant_max_destinatarios_por_email == 0){//Se envia un solo email con todos los destinatarios
                        $bloques_destinatarios[0] = $destinatarios;
                    }
                    else{//Se envian varios emails paginados por el valor de $cant_max_destinatarios_por_email
                        $bloques_destinatarios = array_chunk($destinatarios, $cant_max_destinatarios_por_email);
                    }

                    klog2("Bloques de Destinatarios", $bloques_destinatarios);

                    foreach($bloques_destinatarios as $bloque_destinatarios){
                        $mailjob->set_hacia($bloque_destinatarios);
                        $mailjob->set_html(true);
                        //Encolo los emails para enviar luego
                        $mailjob->sendLater();
                    }

                }

                $this->add_var('mensaje_guardado', true);

            }
            catch(\Exception $e)
            {
                kernel::log()->add_debug('ERROR',
                    'Se produjo la siguiente excepción en la transacción mensajes:evt__guardar_mensaje().'.PHP_EOL
                    .'MENSAJE: '.$e->getMessage().PHP_EOL
                    .'TRACE: '.$e->getTraceAsString());

                if(get_class($e) == 'siu\errores\error_guarani'){//Si es error de validación
                    $mensaje_error = $e->getMessage();
                }
                else{
                    $mensaje_error = kernel::traductor()->trans('mensajes_enviar_error');
                }

                $this->vista()->pagelet('envio_mensajes')->set_resultado($mensaje_error);
                $this->vista()->pagelet('envio_mensajes')->data['titulo'] = $titulo;
                $this->vista()->pagelet('envio_mensajes')->data['contenido'] = $mensaje;
                $this->vista()->pagelet('envio_mensajes')->data['tipo_anuncio'] = $tipo_anuncio;
                $this->vista()->pagelet('envio_mensajes')->data['mesa'] = $mesa;
                $this->vista()->pagelet('envio_mensajes')->data['comision'] = $comision;
                $this->vista()->pagelet('envio_mensajes')->data['todos_algunos'] = $todos_algunos;
                $this->vista()->pagelet('envio_mensajes')->data['enviar_a'] = $enviar_a;
                $this->vista()->pagelet('envio_mensajes')->data['envia_mail'] =  $enviar_por_mail;
				$this->vista()->pagelet('envio_mensajes')->add_var_js('hubo_error', true);
				$this->vista()->pagelet('envio_mensajes')->add_var_js('tipo_anuncio', $tipo_a);
				$this->vista()->pagelet('envio_mensajes')->add_var_js('mesa', $mesa);
				$this->vista()->pagelet('envio_mensajes')->add_var_js('comision', $comision);
				$this->vista()->pagelet('envio_mensajes')->add_var_js('todos_algunos', $todos_algunos);
				$this->vista()->pagelet('envio_mensajes')->add_var_js('enviar_a', $enviar_a);
            }

        } else {
            $comision = $this->validate_param('comision', 'get', validador::TIPO_ALPHANUM, array(
                'allowempty' => true
            ));
            if (!empty($comision)) {
                $this->add_var('comision', $comision);
            }
        }
    }

	protected function enviar_mail()
	{

	}

	protected function get_path_attachment()
	{
		return kernel::proyecto()->get_dir_attachment();
	}

	function accion__descargar()
	{
		$mensaje = $this->validate_param('m', 'get', validador::TIPO_ALPHANUM);
		$archivo = $this->validate_param('a', 'get', validador::TIPO_ALPHANUM);
		$adjunto = $this->modelo()->get_datos_adjunto($mensaje, $archivo);
		$path = $adjunto['NOMBRE_FS'];

		$nombre_descarga = pathinfo($path, PATHINFO_BASENAME);
		$this->descargar_archivo($path, $nombre_descarga);
	}

	/**
		*
		* @param string $fecha d/m/Y
		*/
	protected function strtotime($fecha)
	{
		$date = date_create_from_format('d/m/Y', $fecha);
		return strtotime(date_format($date, 'Y-m-d'));
	}
}
?>