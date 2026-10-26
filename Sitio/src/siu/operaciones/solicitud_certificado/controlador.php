<?php
namespace siu\operaciones\solicitud_certificado;

use kernel\error_kernel;
use kernel\kernel;
use kernel\util\manejador_archivos;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\extension_kernel\controlador_errores_control;
use siu\modelo\datos\catalogo;
use kernel\util\u;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use kernel\util\mail;

include_once(\siu\guarani::dir().'/lib/phpqrcode/qrlib.php');

class controlador extends controlador_errores_control
{

    protected $pdf_hoja = "A5";
    protected $pdf_encabezado = array("", "");
    protected $pdf_encabezado_img = array("img" => "", "width" => "");
    protected $pdf_fuente = "Courier.afm";
    protected $pdf_fuente_texto = 10;
    protected $pdf_fuente_titulo = 10;
    protected $pdf_fuente_subtitulo = 10;

	protected $id_certificado;
	
	function modelo()
	{
		return guarani::solicitud_certificados();
	}
	
	function accion__index()
	{
		$hubo_error = $this->exec_fn_modelo('control__inicial');
		$mensajes = $this->get_var('mensajes');
		if (! empty($mensajes)) {
           $this->vista()->set_hay_mensajes(true);		
        }
		$this->vista()->set_error($hubo_error);

		$pagelet = $this->vista()->pagelet('formulario');
		kernel::renderer()->add($pagelet);
	}
	
	
	function accion__elegir_certificado()
	{
		$certificado = $this->id_certificado = $this->validate_param(0, 'get',
						validador::TIPO_INT, array('allowempty' => true, 'default' => false));
    /*
        switch ($certificado) {
            //Si elige certificado de evaluación...
            case "100":

                $alcance_exa = $this->validate_param('examenes_historicos', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                $alcance_cur = $this->validate_param('cursadas_historicas', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                $this->add_var('alcance_examenes', $alcance_exa);
                $this->add_var('alcance_cursadas', $alcance_cur);
                $pagelet = $this->vista()->pagelet('certificado_evaluacion');
                $this->vista()->set_pagelet_segunda_columna('certificado_evaluacion');
                kernel::renderer()->add($pagelet);

                break;
            //Si elige otro tipo de certificado...
            default:
    */
                if($certificado == 1){
                    $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = false;
                }

                $this->elegir_certificado($certificado);
                $pagelet = $this->vista()->pagelet('formulario');
                $this->vista()->set_pagelet_segunda_columna('formulario');
                kernel::renderer()->add($pagelet);
    /*            
        }
    */


	}

	
	function elegir_certificado($certificado)
	{
        $hubo_error = $this->exec_fn_modelo('control__seleccion_certificado', $certificado);
		
		$mensajes = $this->get_var('mensajes');
		if (! empty($mensajes)) {
           $this->vista()->set_hay_mensajes(true);		
        }
		$this->vista()->set_error($hubo_error);     
	}
	
	function accion__solicitar()
	{
		if (kernel::request()->isPost()) {
				$certificado = $this->id_certificado = $this->validate_param('nro_certificado', 'post', validador::TIPO_INT);
				$cantidad_copias = $this->validate_param('cantidad', 'post', validador::TIPO_INT);
                $argumentos = $this->validate_param('args', 'post', validador::TIPO_ARRAY_TEXTO);

				$hubo_error = $this->exec_fn_modelo('validar_solicitud', array($certificado, $cantidad_copias));
				if(!$hubo_error){
					$hubo_error = $this->exec_fn_modelo('control__solicitud_certificado', array($certificado));
					if(!$hubo_error){
						$hubo_error = $this->exec_fn_modelo('evt__solicitar', array($certificado, $cantidad_copias, $argumentos));
					}
				}
				$mensajes = $this->get_var('mensajes');
				
				if (! empty($mensajes)) {
					$this->vista()->set_hay_mensajes(true);		
				}
				$this->vista()->set_error($hubo_error);
				
				kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
				if (!$hubo_error) {
					$params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
					$params['certificado'] = $certificado;
					$nro_solicitud_certificado = catalogo::consultar('certificados', 'nro_solicitud_certificado', $params);
					$mensaje = kernel::traductor()->trans('solicitud_certificado.mensaje_exito');
					$mensaje = str_replace("%nro_trans%", $nro_solicitud_certificado, $mensaje);
					kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
				}
								
		}
		
	}
	
	function get_id_certificado()
	{		
		return $this->id_certificado;
	}
	
	function get_argumentos_certificado($id_certificado)
	{		
		return $this->modelo()->argumentos_certificado($id_certificado);
	}

    /* Exportación */
    protected function crear_ezpdf(){
        $instancia = new \Cezpdf($this->pdf_hoja, 'portrait');
        return $instancia;
    }

    function accion__exportar_pdf_parcial()
    {
        // Parámetros
        $materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO, array('default' => ''));
        $catedra = $this->validate_param('catedra', 'get', validador::TIPO_TEXTO, array('default' => ''));

        $pdf = new generador_pdf($this->crear_ezpdf());
        $pdf->set_font($this->pdf_fuente);
        $pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5));
        $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
        $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
        $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
        $pdf->set_nombre_archivo('CertificadoParcial');

        $alumno = guarani::persona()->get_nombre();
        $legajo = guarani::persona()->get_id_legajo_activo();

        $datos_carrera = guarani::persona()->get_info_carrera_activa();
        $nombre_carrera = "";
        if (isset($datos_carrera)){
            $nombre_carrera = $datos_carrera['nombre'];
        }

        $logo = kernel::localizador()->encontrar_img('www/img','logo.png');

//        $this->pdf_encabezado = array(
//            strtoupper(kernel::traductor()->trans('certificado_evaluacion.certificado_parcial')),
//            kernel::traductor()->trans('certificado_evaluacion.alumno', array('%alumno%' => $alumno)),
//            112
//        );
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
        $this->pdf_encabezado = array(
            $universidad,
			"",
            110
        );
		$this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

        $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
        $pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);

        $pdf->set_pdf_fuente_texto(12);
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5, 'justification' => 'center'));
        $texto = "<u><b>".kernel::traductor()->trans('certificado_evaluacion.certificado_parcial')."</b></u>";
        $pdf->agregar_texto($texto);

        $pdf->dejar_espacio(-20);

        $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5));
        $anio= date('Y',time());
        $texto = kernel::traductor()->trans('certificado_evaluacion.certificado_parcial_parrafo_uno', array(
            '%alumno%' => $alumno,
            '%legajo%' => $legajo,
            '%materia%' => $materia
        ));
        $pdf->agregar_texto($texto);
        $texto = kernel::traductor()->trans('certificado_evaluacion.certificado_parrafo_dos', array(
            '%anio%' => $anio
        ));
        $pdf->agregar_texto($texto);
        $pdf->dejar_espacio(-80);

        $pdf->set_pdf_fuente_texto(9);
        $texto = kernel::traductor()->trans('certificado_evaluacion.firmas');
        $pdf->agregar_texto($texto);

        $pdf->generar();
    }

    function accion__exportar_pdf_examen()
    {
        // Parámetros
        $materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO, array('default' => ''));
        $mesa = $this->validate_param('mesa', 'get', validador::TIPO_TEXTO, array('default' => ''));

        $pdf = new generador_pdf($this->crear_ezpdf());
        $pdf->set_font($this->pdf_fuente);
        $pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5));
        $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
        $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
        $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
        $pdf->set_nombre_archivo('CertificadoExamen');

        $alumno = guarani::persona()->get_nombre();
        $legajo = guarani::persona()->get_id_legajo_activo();

        $datos_carrera = guarani::persona()->get_info_carrera_activa();
        $nombre_carrera = "";
        if (isset($datos_carrera)){
            $nombre_carrera = $datos_carrera['nombre'];
        }

        $logo = kernel::localizador()->encontrar_img('www/img','logo.png');

//        $this->pdf_encabezado = array(
//            strtoupper(kernel::traductor()->trans('certificado_evaluacion.certificado_examen')),
//            kernel::traductor()->trans('certificado_evaluacion.alumno', array('%alumno%' => $alumno)),
//            112
//        );
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
        $this->pdf_encabezado = array(
            $universidad,
			"",
            110
        );
        $this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

        $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
        $pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);

        $pdf->set_pdf_fuente_texto(12);
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5, 'justification' => 'center'));
        $texto = "<u><b>".kernel::traductor()->trans('certificado_evaluacion.certificado_examen')."</b></u>";
        $pdf->agregar_texto($texto);

        $pdf->dejar_espacio(-20);

        $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5));
        $anio= date('Y',time());
        $texto = kernel::traductor()->trans('certificado_evaluacion.certificado_examen_parrafo_uno', array(
            '%alumno%' => $alumno,
            '%legajo%' => $legajo,
            '%materia%' => $materia,
            '%mesa%' => $mesa
        ));
        $pdf->agregar_texto($texto);
        $texto = kernel::traductor()->trans('certificado_evaluacion.certificado_parrafo_dos', array(
            '%anio%' => $anio
        ));
        $pdf->agregar_texto($texto);
        $pdf->dejar_espacio(-80);

        $pdf->set_pdf_fuente_texto(9);
        $texto = kernel::traductor()->trans('certificado_evaluacion.firmas');
        $pdf->agregar_texto($texto);

        $pdf->generar();
    }

    function get_cat_dias_vigencia_cert_alumno_reg(){
		$argumentos = $this->get_argumentos_certificado(1);
        return $argumentos['vigencia'];
    }

    function get_vigencia_cert_($nro_cert){
		$argumentos = $this->get_argumentos_certificado($nro_cert);
        return $argumentos['vigencia'];
    }

    function enviar_mail_cert($path_archivo, $nombre_archivo){
		$params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
		$dir_mail = catalogo::consultar('persona', 'get_dir_mail', $params);
		if (!empty($dir_mail))
		{
		$asunto = kernel::traductor()->trans('asunto_mail_cert');
		$cuerpo = kernel::traductor()->trans('cuerpo_mail_cert');
		$mail = new mail($dir_mail, $asunto, $cuerpo);
		$mail->agregar_adjunto($nombre_archivo, $path_archivo,null);
		$mail->enviar();			
		}

    }

    function accion__generar_cert_alumno_reg(){

        //Ejecuto puntos de control 2 y 3...
        $hubo_error = $this->exec_fn_modelo('control__inicial');
        if($hubo_error){//Si fallaron los puntos de control...
            $mensajes = $this->get_var('mensajes');
            if (! empty($mensajes)) {
                $this->vista()->set_hay_mensajes(true);
            }
            $this->vista()->set_error($hubo_error);
            $pagelet = $this->vista()->pagelet('formulario');
            kernel::renderer()->add($pagelet);
            return false;
        }

        //Ejecuto puntos de control 26...
        $hubo_error = $this->exec_fn_modelo('control__solicitud_certificado', array(1));
        if($hubo_error){//Si fallaron los puntos de control...
            $mensajes = $this->get_var('mensajes');
            if (! empty($mensajes)) {
                $this->vista()->set_hay_mensajes(true);
            }
            $this->vista()->set_error($hubo_error);
            $pagelet = $this->vista()->pagelet('formulario');
            kernel::renderer()->add($pagelet);
            return false;
        }

        $parametros = array();
        $parametros['carrera'] = guarani::persona()->get_id_carrera_activa();
        $parametros['legajo'] =  guarani::persona()->get_id_legajo_activo();

        $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = false;
        $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = false;

        //Controlo si el alumno es regular a la carrera...
        $ctr_alu_reg_carrera = catalogo::consultar('certificados', 'ctr_alumno_regular_carrera', $parametros);
        $es_regular_a_carrera = ($ctr_alu_reg_carrera["estado"] == 1)? true : false;
		
		//Controlo si el alumno es activo en la carrera
        $ctr_alu_act_carrera = catalogo::consultar('certificados', 'ctr_alumno_activo_carrera', $parametros);
        $es_activo_en_carrera = ($ctr_alu_act_carrera["estado"] == 1)? true : false;

        if($es_regular_a_carrera and $es_activo_en_carrera){//Si es regular y activo...

            $path_temp_car = kernel::proyecto()->get_dir_temp()."/cert_alum_reg";
            manejador_archivos::crear_arbol_directorios($path_temp_car);

            $pdf = new generador_pdf($this->crear_ezpdf());
            $pdf->set_font($this->pdf_fuente);
            $pdf->set_options(array(
                'showHeadings' => 1,
                'protectRows' => 1,
                'maxWidth' => 500,
                'width' => 800,
                'fontSize' => $this->pdf_fuente_texto,
                'shadeCol' => array(0.8, 0.8, 0.8),
                'cols' => array()
                )
            );
            $pdf->set_text_options(array(
                'left' => 5,
                'top' => 20,
                'maxWidth' => 800,
                'width' => 500,
                'spacing' => 1.5
                )
            );
            $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
            $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
            $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
            $pdf->set_nombre_archivo('certificado_alumno_regular');

            $logo = kernel::localizador()->encontrar_img('www/img', 'logo.png');

            $sexo = guarani::persona()->get_sexo();
            $parametros['parametros']['nom_ape_alumno'] = guarani::persona()->get_nombre();

            if($sexo == 1){//Masculino
                $parametros['parametros']['articulo'] = kernel::traductor()->trans('form.cert_alu_regular.el');
                $parametros['parametros']['genero'] = kernel::traductor()->trans('form.cert_alu_regular.alumno');
            }
            else{//Femenino
                $parametros['parametros']['articulo'] = kernel::traductor()->trans('form.cert_alu_regular.la');
                $parametros['parametros']['genero'] = kernel::traductor()->trans('form.cert_alu_regular.alumna');
            }

            $universidad_facultad = "<b>".guarani::ua()->get_nombre_institucion()."</b>\n\n".guarani::ua()->get_nombre();
            $this->pdf_encabezado = array($universidad_facultad, "", 112);
            $this->pdf_encabezado_img = array('img' => $logo['path'], 'width' => '100');

            $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
            $pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);

            $pdf->set_pdf_fuente_texto(12);
            $pdf->set_text_options(array(
                'left' => 5,
                'top' => 0,
                'maxWidth' => 800,
                'width' => 500,
                'spacing' => 1.5,
                'justification' => 'center'
                )
            );
            $texto = "<u><b>".kernel::traductor()->trans('form.cert_alu_regular.certificado_alumno_regular')."</b></u>";
            $pdf->agregar_texto($texto);

            $pdf->dejar_espacio(-20);

            $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
            $pdf->set_text_options(array(
                'left' => 5,
                'top' => 20,
                'maxWidth' => 800,
                'width' => 500,
                'spacing' => 1.5,
                'justification' => 'full'
                )
            );

            $fecha = new \DateTime();
            $dia = $fecha->format('j');
            $mes = $fecha->format('n');
            $anio = $fecha->format('Y');

            $parametros['parametros']['nombre_facultad'] = guarani::ua()->get_nombre();
            $parametros['parametros']['legajo'] = guarani::persona()->get_id_legajo_activo();
            $parametros['parametros']['desc_tipo_docum'] = guarani::persona()->get_tipo_documento_desc_abreviada();
            $parametros['parametros']['nro_documento'] = guarani::persona()->get_nro_documento();
            $parametros['parametros']['nacionalidad'] = guarani::persona()->get_nacionalidad_descripcion();
            $carrera_activa = guarani::persona()->get_info_carrera_activa();
            $parametros['parametros']['carrera_nombre'] = $carrera_activa['nombre'];
            $parametros['parametros']['plan'] = guarani::persona()->get_id_plan_activo();
            $parametros['parametros']['anio_ingreso'] = guarani::persona()->get_anio_ingreso_carrera_activa();
            $parametros['parametros']['fecha'] = $fecha->format('Y-m-d');

            //Armo el texto
            $texto = kernel::traductor()->trans('form.cert_alu_regular.primera_parte', array(
                '%facultad%' => $parametros['parametros']['nombre_facultad'],
                '%genero%' => "{$parametros['parametros']['articulo']} {$parametros['parametros']['genero']}",
                '%alumno%' => $parametros['parametros']['nom_ape_alumno'],
                '%legajo%' => $parametros['parametros']['legajo'],
                '%tipo_doc%' => $parametros['parametros']['desc_tipo_docum'],
                '%nro_doc%' => $parametros['parametros']['nro_documento'],
                '%origen%' => $parametros['parametros']['nacionalidad'],
                '%carrera%' => $parametros['parametros']['carrera_nombre'],
                '%plan%' => $parametros['parametros']['plan'],
                '%anio_ingreso%' => $parametros['parametros']['anio_ingreso']
            ));

            $pdf->agregar_texto($texto);
            $pdf->dejar_espacio(-10);

            $parametros['parametros']['localidad'] = guarani::ua()->get_localidad_institucion();
            $texto = kernel::traductor()->trans('form.cert_alu_regular.segunda_parte', array(
                '%ciudad%' => $parametros['parametros']['localidad'],
                '%dia%' => $dia,
                '%mes%' => kernel::traductor()->trans('mes.'.$mes),
                '%anio%' => $anio
            ));

            $pdf->agregar_texto($texto);
            $pdf->dejar_espacio(-10);
            $pdf->set_pdf_fuente_texto(11);

            //El codigo validador esta formado por la fecha actual (ymdHis) mas un numero random de 2 digitos.
            $parametros['codigo_validador'] = $fecha->format('ymdHis').str_pad(rand(0, 99), 2, '0', STR_PAD_LEFT);
            $texto = kernel::traductor()->trans('form.cert_alu_regular.codigo_validacion');
            $posY = $pdf->agregar_texto($texto);
            //Genero el codigo de barras.
            $barcodeOptions = array('text' => $parametros['codigo_validador']);
            $rendererOptions = array('imageType' => 'png');
            $imageResource = \Zend_Barcode::draw(
                'code39', 'image', $barcodeOptions, $rendererOptions
            );

            $path_img = $path_temp_car."/barcode_car.png";
            $aux_barcode = imagepng($imageResource, $path_img, 3);
            $pdf->agregar_img_png_desde_archivo($path_img, 130 , $posY - 80 , 150, 60);
            imagedestroy($imageResource);
            unlink($path_img);

            $pdf->set_pdf_fuente_texto(10);
            $pdf->set_text_options(array(
                'spacing' => 1,
                'justification' => 'full',
                'left' => 80
                )
            );

            $texto = kernel::traductor()->trans('form.cert_alu_regular.leyenda_qr', array(
                '%url_qr%' => kernel::vinculador()->crear('validador_certificados', 'index')
            ));

            $pdf->dejar_espacio(-100);
            $pdf->agregar_texto($texto);
            $parametros['parametros']['cat_dias_vigencia'] = $this->get_cat_dias_vigencia_cert_alumno_reg();
            $fecha_expiracion = $fecha->add(new \DateInterval('P'.$parametros['parametros']['cat_dias_vigencia'].'D'));
            $parametros['fecha_expiracion'] = $fecha_expiracion->format('Y-m-d');
            $cat_dias_vigencia_text = ($parametros['parametros']['cat_dias_vigencia'] == 1)? "{$parametros['parametros']['cat_dias_vigencia']} día" : "{$parametros['parametros']['cat_dias_vigencia']} días";
            $texto = kernel::traductor()->trans('form.cert_alu_regular.qr_vigencia', array(
                '%vigencia%' => $cat_dias_vigencia_text,
            ));
            $pdf->dejar_espacio(-10);
            $posY = $pdf->agregar_texto($texto);


            $url_validador = kernel::vinculador()->crear('validador_certificados', 'index', $parametros['codigo_validador']);

            //Genero el codigo QR.
            $path_qr = $path_temp_car."/qrcode_car.png";
            \QRcode::png($url_validador, $path_qr);
            $pdf->agregar_img_png_desde_archivo($path_qr, 35, $posY + 28, 80);
            unlink($path_qr);

            $parametros['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
            $parametros['certificado'] = 1;
            //Guardo el certificado en la DB.
            $ok = catalogo::consultar('certificados', 'guardar_certificado_web', $parametros);

            if($ok){
                //$pdf->generar();
                $pdf_aux = $pdf->genera_output();
                $path_nombre = $path_temp_car."/CAR_{$parametros['codigo_validador']}.pdf";
                file_put_contents($path_nombre, $pdf_aux);
                try{
					$this->enviar_mail_cert($path_nombre, 'certificado_alumno_regular.pdf');
                    $this->descargar_archivo($path_nombre, 'certificado_alumno_regular.pdf');
					
                }
                catch(error_kernel $e){
                    $this->id_certificado = 1;
                    $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = true;
                }

            }
            else{
                $this->id_certificado = 1;
                $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = true;
            }

        }
        else{

            $this->id_certificado = 1;
            $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = true;

        }
					
    }

	/**************************************************************************/
	// FUNCIONES DE ACCESO AL MODELO
	/**************************************************************************/
		
	protected function modelo__control__inicial()
	{
		$mensajes = $this->modelo()->control__inicial();
		$this->acum_mensajes($mensajes);
	}
	
	
	protected function modelo__control__seleccion_certificado($certificado)
	{
		$mensajes = $this->modelo()->control__seleccion_certificado($certificado);
		$this->acum_mensajes($mensajes);
	}
	
	
	protected function modelo__evt__solicitar($certificado, $cantidad_copias, $argumentos)
	{
		return $this->modelo()->evt__solicitar($certificado, $cantidad_copias, $argumentos);
		//$this->add_var('transaccion', $transaccion);
		//$this->acum_mensajes($mensajes);
	}
	
	protected function modelo__control__solicitud_certificado($certificado)
	{
		$mensajes = $this->modelo()->control__solicitud_certificado($certificado);
		$this->acum_mensajes($mensajes);		
	}
	
	protected function modelo__validar_solicitud($certificado, $cantidad_copias)
	{
		$mensajes = $this->modelo()->validar_solicitud($certificado, $cantidad_copias);
		$this->acum_mensajes($mensajes);		
	}
	
}