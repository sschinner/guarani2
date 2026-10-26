<?php

namespace personalizacionPOSGRADODIPLOMA\operaciones\gestionar_diploma;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\manejador_archivos;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\guarani;

define('DIPLOMA', 102);

require_once '../../../clientes_ws/nuxeo/clientews.php';
require_once '../../../clientes_ws/mediosCobro/clientews.php';
require_once '../../../clientes_ws/digitalizador/clientews.php';

use ClienteDigitalizador;
use ClienteMediosCobro;
use ClienteNuxeo;

class controlador extends controlador_g3w2 {

    public $inicioSolicitud = false;
    public $errorAlSolicitar = false;
    public $idCertificado;
    public $nroCertificado;
    public $titulo;
    public $encuestaComplta;
	public $tramiteEspecial = false;

	const TRAMITE_ESPECIAL = 'X';
	
    function modelo() {
        return null;
    }

    function get_clase_vista() {
        switch ($this->accion) {
            case 'nueva_solicitud':
                return 'vista_nueva_solicitud';
            case 'visualizar':
                return 'vista_visualizar';
            default:
                return 'vista';
        }
    }

    function accion__index() {
        $this->nroCertificado = DIPLOMA;
    }

    function accion__invocar_pdf_diploma() {
        ob_clean();

        $path = trim($_GET['url']); 
        //$path = '/default-domain/sections/Tramites-CA/CA_FICH-1002580-19';
        $nuxeo = new ClienteNuxeo();
        $nuxeo->obtenerArchivo($path);
    }

    function accion__invocar_pdf_tramite() {
        ob_clean();

        $path = trim($_GET['url']); 
        //$path = '/default-domain/sections/Tramites-CA/CA_FICH-1002580-19';
        $nuxeo = new ClienteNuxeo();
        $nuxeo->obtenerArchivo($path);
    }

    function accion__invocar_pdf_certificado() {
        ob_clean();

        $path = trim($_GET['url']); 
        //$path = '/default-domain/sections/Tramites-CA/CA_FICH-1002580-19';
        $nuxeo = new ClienteNuxeo();
        $nuxeo->obtenerArchivo($path);
    }

    function accion__nueva_solicitud() {

        $certificado = $this->nroCertificado = DIPLOMA;
        $operacion = kernel::ruteador()->get_id_operacion();
        $this->errorAlSolicitar = false;

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();        
        $parametros['ua'] = guarani::ua()->get_id();
        $parametros['nro_certificado'] = $certificado;
        $parametros['carrera'] = guarani::persona()->get_id_carrera_activa();
        
        $encuestaCompleta = catalogo::consultar('alumno', 'control_encuesta_completa', $parametros);
        $this->encuestaComplta = $encuestaCompleta[0];

        $pagelet_nueva_solicitud = $this->vista()->pagelet('pagelet');

        // Hizo clck en Solicitar =>  guardo
        if (kernel::request()->isPost()) {
            
            $email = $this->validate_param('email', 'post', validador::TIPO_TEXTO);
                $telefono = $this->validate_param('telefono', 'post', validador::TIPO_TEXTO);
                $parametros['titulo'] = $titulo = $this->validate_param('titulo', 'post', validador::TIPO_TEXTO); 
                $tipoDiploma = $this->validate_param('diploma', 'post', validador::TIPO_TEXTO);              
            $autorizadoNombre = $this->validate_param('autorizaNombre', 'post', validador::TIPO_TEXTO, array('default' => null));
            $autorizadoApellido = $this->validate_param('autorizaApellido', 'post', validador::TIPO_TEXTO, array('default' => null));
            $autorizadoDNI = $this->validate_param('autorizaDNI', 'post', validador::TIPO_TEXTO, array('default' => null));
            
            $diplomaSolicitado = catalogo::consultar('certificados', 'buscar_el_diploma', $parametros);          
            
            // Si no tiene iniciado el tramite
            if (empty($diplomaSolicitado['ID_CERTIF_PEDIDO'])) {
                
                try {
                    /* guarda los datos censales ingresados */
                    $this->actualizarDatosCensales($email, $telefono);

                    /* realiza el proceso de guardado en las distintas tablas */
                    $inicioOk = $this->guardarSolicitud($certificado, $titulo, $tipoDiploma, $autorizadoNombre, $autorizadoApellido, $autorizadoDNI);
                } 
                catch (\Exception $e) {
                    // Si es una redirección la relanzo
                    if ($e instanceof NuevoRequest) {
                        throw $e;
                    }
                    kernel::log()->add_error($e);

                    $this->vista()->set_error($hubo_error);
                    kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
                }	
            }
            
            // Si lo tiene iniciado, pero sin identificador_cobro
            elseif (!empty($diplomaSolicitado['ID_CERTIF_PEDIDO']) && is_null($diplomaSolicitado['IDENTIFICADOR_COBRO'])) {
//                ($hash, $tipoDiploma, $titulo, $identificadorDeuda, $certificado);
                $inicioOk = $this->asignar_identificador_cobro($diplomaSolicitado);
                
            }

            if ($inicioOk) {
                        $this->inicioSolicitud = true;
			}
			else {
                        $this->errorAlSolicitar = true;
            }
        }
    }

    function accion__visualizar() {

        $certificado = $this->nroCertificado = DIPLOMA;
        $operacion = kernel::ruteador()->get_id_operacion();
        $this->errorAlSolicitar = false;

        if (kernel::request()->isGet()) {

            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $parametros['ua'] = guarani::ua()->get_id();
            $encuestaCompleta = catalogo::consultar('alumno', 'control_encuesta_completa', $parametros);
            $this->encuestaComplta = $encuestaCompleta[0];

            $this->titulo = $this->validate_param('titulo', 'get', validador::TIPO_TEXTO);
            if (!empty($this->titulo)) {
                $parametro['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
                $parametro['nro_certificado'] = DIPLOMA;
                $parametro['carrera'] = guarani::persona()->get_id_carrera_activa();
                $parametro['titulo'] = $this->titulo;
                $diplomaSolicitado = catalogo::consultar('certificados', 'buscar_el_diploma', $parametro);
                $this->idCertificado = $diplomaSolicitado['ID_CERTIF_PEDIDO'];
                
                $this->inicioSolicitud = true;
                
				/*
				 * DETERMINAR SI ES UN TRAMITE ESPECIAL
				 */
				$parametro['alumno'] = $parametro['nro_inscripcion'];
				$estado = catalogo::consultar('alumno', 'estado_titulo_alumno', $parametro);

				if ($estado == self::TRAMITE_ESPECIAL) {
					$this->set_tramite_especial();
				}				
                
                if ($diplomaSolicitado['ESTADO_PAGO'] == "V") {            
                    // Genero nuevo IDENTIFICADOR_DEUDA, hash y fecha de vencimiento.
                    $uA = guarani::ua()->get_id();
                    $diplomaSolicitado['HASH_PAGO'] = md5(guarani::persona()->get_nro_documento() . date("Y-m-d H:i:s") . $uA);
                    $diplomaSolicitado['IDENTIFICADOR_DEUDA'] = $uA . guarani::persona()->get_id_carrera_activa() . date("YmdHis");
                    
                    // Extiendo la fecha de vencimiento del pago segun vigencia definida
                    $mdC = new ClienteMediosCobro();
                    $vigencia = $mdC->configApp['wsMediosDeCobro']['diasVence' . $parametro['nro_certificado']];
                    $fecha = date_create();
                    date_add($fecha, date_interval_create_from_date_string($vigencia . ' days'));
                    $diplomaSolicitado['FECHA_VENCIMIENTO_PAGO'] = date_format($fecha, 'd-m-Y');
                    
                    // Persisto valores en la base
                    $ok =  catalogo::consultar('certificados', 'actualiza_deuda', array(
                        'id_certif_pedido'          => $diplomaSolicitado['ID_CERTIF_PEDIDO'],
                        'estado_pago'               => 'N',
                        'identificador_deuda'       => $diplomaSolicitado['IDENTIFICADOR_DEUDA'],
                        'hash_pago'                 => $diplomaSolicitado['HASH_PAGO'],
                        'fecha_vencimiento_pago'    => $diplomaSolicitado['FECHA_VENCIMIENTO_PAGO']
                    )); 
                }
                
                if (is_null($diplomaSolicitado['IDENTIFICADOR_COBRO']) || $diplomaSolicitado['ESTADO_PAGO'] == "V") {   
                
                    /* Solicito a MdC el alta de nueva deuda o que me devuelva el identificador_cobro asociado a un identificador_deuda
                     * ya existente, segun sea el caso.
                     */
                    $datosWS = $this->cargarDatosWSCobros(
                                                        $diplomaSolicitado['HASH_PAGO'], 
                                                        $diplomaSolicitado['IMPRENTA'], 
                                                        $this->titulo, 
                                                        $diplomaSolicitado['IDENTIFICADOR_DEUDA'], 
                                                        $certificado);
                                                
                    $this->errorAlSolicitar = $this->asignar_identificador_cobro($diplomaSolicitado, $datosWS); 
                    
                    if (!$this->errorAlSolicitar) {
                        $this->actualizarTituloOtorg($this->titulo);
                    }
                }
                
            } else {
                $this->errorAlSolicitar = true;
            }
        }
    }

    public function actualizarDatosCensales($email, $telefono) {

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros['email'] = $email;
        $parametros['telefono'] = $telefono;

        $ok = catalogo::consultar('alumno', 'actualizar_datos_censales', $parametros);
    }

    public function guardarSolicitud($certificado, $titulo, $tipoDiploma, $autorizadoNombre, $autorizadoApellido, $autorizadoDNI) {

        $uA = guarani::ua()->get_id();
        $hash = md5(guarani::persona()->get_nro_documento() . date("Y-m-d H:i:s") . $uA);
        $identificadorDeuda = $uA . guarani::persona()->get_id_carrera_activa() . date("YmdHis");

		/*
		 * DETERMINAR SI ES UN TRAMITE ESPECIAL
		 */
		$parametros['alumno'] = guarani::persona()->get_nro_inscripcion();
		$parametros['titulo'] = $titulo;
		$estado = catalogo::consultar('alumno', 'estado_titulo_alumno', $parametros);

		if ($estado == self::TRAMITE_ESPECIAL) {
			$this->set_tramite_especial();
		}
        
        /*  Carga valores para la llamada al ws MC */
        $datosWS = $this->cargarDatosWSCobros($hash, $tipoDiploma, $titulo, $identificadorDeuda, $certificado);
        
        try {
            /* Se abre transaccion  */
            kernel::db()->abrir_transaccion();

            /* Comienza el guardado en las distintas tablas  */
            $parametros = array();

            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $parametros['_ua'] = guarani::ua()->get_id();

            /*    Inserta en sga_certif_pedidos    */
            $parametros['certificado'] = DIPLOMA;
            $parametros['fecha_de_pedido'] = date('d-m-Y H:i:s');
            $parametros['copias_pedidas'] = '1';
            $parametros['interfaz'] = '3';
            $parametros['copias_impresas'] = '0';
            $nro_transaccion = catalogo::consultar('certificados', 'guardar_certificado_solicitado', $parametros);

            /*    Obtiene el id_certif del certificado insertado    */
            $parametros = array();
            $parametros['ua'] = guarani::ua()->get_id();
            $parametros['nro_certificado'] = DIPLOMA;
            $parametros['nro_solicitud'] = $nro_transaccion;
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $idCertificado = catalogo::consultar('certificados', 'obtiene_idCertif', $parametros);
            
            $fecha = date_create();
            date_add($fecha, date_interval_create_from_date_string($datosWS->vigencia . ' days'));
            $fecha_vence = date_format($fecha, 'd-m-Y');
            $this->fechaVencimiento = $fecha_vence;

            $mensaje = kernel::traductor()->trans('solicitud_certificado.mensaje_exito');
            $mensaje = str_replace("%nro_trans%", $nro_transaccion, $mensaje);

            /*             * * Insertar u820_pedidos_certif ** */
            $parametros = array();
            $parametros['ID_CERTIF_PEDIDO'] = $this->idCertificado = $idCertificado[0]['ID'];
            $parametros['fecha_vencimiento_pago'] = $fecha_vence;
            $parametros['hash_pago'] = $hash; // el que genere en la url
            $parametros['IDENTIFICADOR_DEUDA'] = $identificadorDeuda;
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            
            /*
             * Consulta si existe un path nuxeo para la persona
             */
            $path = catalogo::consultar('certificados', 'get_path_nuxeo', ['nro_inscripcion' => kernel::persona()->get_nro_inscripcion()]);
            $path = $path[0]['PATH_NUXEO'];
            
            /*
             * Si no existe, lo genero
             */
            if (empty($path)) {
            $p = catalogo::consultar('certificados', 'get_pais_tipo_nro_doc', $parametros);
                $path = "{$p[0]['PAIS_DOCUMENTO']}_{$p[0]['TIPO_DOCUMENTO']}_{$p[0]['NRO_DOCUMENTO']}";
            }
            
            $parametros['path_nuxeo'] = $path;
            
            catalogo::consultar('certificados', 'guardar_certificado_arancelado', $parametros);
            
            /*             * * Insertar u820_pedidos_certif_diploma ** */
            $parametros['carrera'] = guarani::persona()->get_id_carrera_activa();
            $parametros['titulo'] = $titulo;
            $parametros['imprenta'] = $tipoDiploma;
            $parametros['autorizado_apellido'] = $autorizadoApellido;
            $parametros['autorizado_nombre'] = $autorizadoNombre;
            $parametros['autorizado_documento'] = $autorizadoDNI;
			$parametros['tipo_tramite'] = $this->tramiteEspecial ? 'E' : 'N';
            catalogo::consultar('certificados', 'guardar_diploma', $parametros);

            /*  Genero hash Digitalizador y guardo en db */
            $this->guardaHashDigital($this->idCertificado);
            
            /* Cambio el estado a 'M' (no le permite volver a solicitar) */
            $this->actualizarTituloOtorg($titulo);
            
            /* Todo ok commit de la transaccion */
            kernel::db()->cerrar_transaccion();
            
            $error = $this->asignar_identificador_cobro($parametros, $datosWS); 
            
            return !$error;
            
        } catch (\Exception $e) {
                // print_r($e);
            kernel::db()->abortar_transaccion();
            return false;
        }      
    }

    public function actualizarTituloOtorg($titulo) {

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros['carrera'] = guarani::persona()->get_id_carrera_activa();
        $parametros['titulo'] = $titulo;

        $ok = catalogo::consultar('alumno', 'actualizar_titulos_otorg', $parametros);
    }

    public function guardaHashDigital($idCertificado) {

        try {
            $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $parametros['tipo_carrera'] = catalogo::consultar('alumno', 'tipo_de_carrera', $parametros)['TIPO_DE_CARRERA'];
			$parametros['tipo_tramite'] = $this->tramiteEspecial ? 'E' : 'N';
            
            $requisitosDiploma = catalogo::consultar('alumno', 'obtener_requisitos_diploma', $parametros);

            foreach ($requisitosDiploma as $fila) {

                $parametros = array();
                /*  Se genera el hash para cada requisito */
                $hashDigitalizador = md5(guarani::persona()->get_nro_documento() . date("Y-m-d H:i:s") . $fila['REQUISITO']);

                /*  Se guarda el hash y el id_certificado  */
                $parametros['id_certif_pedido'] = $idCertificado;
                $parametros['requisito'] = $fila['REQUISITO'];
                $parametros['hash'] = $hashDigitalizador;
                $parametros['fecha'] = date("d-m-Y H:i:s");
                catalogo::consultar('certificados', 'guardar_hash_digital', $parametros);
            }
            return true;
        } catch (\Exception $e) {

            return false;
        }
    }	

    public function cargarDatosWSCobros($hash, $tipoDiploma, $titulo, $identificadorDeuda, $certificado) {

        $mdC = new ClienteMediosCobro();

        $url = $mdC->configEntorno['wsMediosDeCobro']['urlNotificacion'] . $hash;
        $urlTramite = $url;

        $datosWs = new \StdClass();
        $datosWs->apellido = guarani::persona()->get_solo_apellido();
        $datosWs->nombre = guarani::persona()->get_solo_nombre();
        $datosWs->nroDoc = guarani::persona()->get_nro_documento();
        $datosWs->url = $urlTramite; 
        $datosWs->tipoDoc = 1;
        $datosWs->paisDoc = 54;
        $datosWs->email = guarani::persona()->get_mail();
        $datosWs->vigencia = $mdC->configApp['wsMediosDeCobro']['diasVence' . $certificado];
        $datosWs->identificadorDeuda = $identificadorDeuda;

        if (isset($tipoDiploma) && $tipoDiploma === 'S') {

            $this->ministerial = 'S';
            $this->montoCetificado = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado] + $mdC->configApp['wsMediosDeCobro']['montoConCarton' . $certificado];
            $datosWs->monto = $this->tramiteEspecial ? 
					$mdC->configApp['wsMediosDeCobro']['montoEspecial' . $certificado] + $mdC->configApp['wsMediosDeCobro']['montoConCartonEspecial' . $certificado]
					:
					$mdC->configApp['wsMediosDeCobro']['monto' . $certificado] + $mdC->configApp['wsMediosDeCobro']['montoConCarton' . $certificado];
            $datosWs->entidad = $mdC->configApp['wsMediosDeCobro']['entidadMinisterio'];
            $datosWs->idServicio = $mdC->configApp['wsMediosDeCobro']['idServicioMinisterio' . $certificado];
        } else {
            $this->ministerial = 'N';
            $this->montoCetificado = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado];
            $datosWs->monto = $this->tramiteEspecial ? 
					$mdC->configApp['wsMediosDeCobro']['montoEspecial' . $certificado]
					:
					$mdC->configApp['wsMediosDeCobro']['monto' . $certificado];
            $datosWs->entidad = $mdC->configApp['wsMediosDeCobro']['entidad'];
            $datosWs->idServicio = $mdC->configApp['wsMediosDeCobro']['idServicio' . $certificado];
        }
        $datosWs->cuotas = $mdC->configApp['wsMediosDeCobro']['cuotas'];
        $periodo = (string) date("m/Y");
        $datosWs->periodo = $periodo;
        $carrera = guarani::persona()->get_info_carrera_activa();
        $nroInscripcion = guarani::persona()->get_nro_inscripcion(); 
        $datosWs->detalle = $mdC->configApp['wsMediosDeCobro']['detalle' . $certificado] . " - " . $nroInscripcion . " - " . $carrera["nombre"];
        $medioPago = explode(',', $mdC->configApp['wsMediosDeCobro']['medioPago']);
        $datosWs->medioPago = ($medioPago[0] == "") ? array() : $medioPago;

        return $datosWs;
    }

    public function get_inicioSolicitud() {
        return $this->inicioSolicitud;
    }

    public function get_nroCertificado() {
        return $this->nroCertificado;
    }

    public function get_fechaVencimiento() {
        return $this->fechaVencimiento;
    }

    public function get_identificadorCobro() {
        return $this->identificadorCobro;
    }

    public function get_errorAlSolicitar() {
        return $this->errorAlSolicitar;
    }

    public function get_idCertificado() {
        return $this->idCertificado;
    }

    public function get_titulo() {
        return $this->titulo;
    }

    public function get_encuestaCompleta() {
        return $this->encuestaComplta;
    }
    
	public function set_tramite_especial() {
		$this->tramiteEspecial = true;
	}

    function asignar_identificador_cobro($diplomaSolicitado, $datosWS) {
        
        $error = false;
        
        $claseMdC = new ClienteMediosCobro();     
        $resp1 = $claseMdC->consultarIdentificadorCobro($diplomaSolicitado['IDENTIFICADOR_DEUDA']);    
        
        // Comunicacion exitosa SIN resultado (string vacio). No existe deuda.
        if (!isset($resp1['faultcode']) && (empty($resp1)) && ($resp1 !== false)) {           
            $resp2 = $claseMdC->notificarNuevoCobro($datosWS);
            
            if (!isset($resp2['faultcode']) && (!empty($resp2)) && ( $resp2 !== false)) {
                $identificadorCobro = $resp2["return"]["codigo"];
            }
            
            // Falla WS [notificarNuevoCobro]
            elseif (isset($resp2['faultcode']) || ( $resp2 === false)) {
                $error = true;
            }
        }
        
        // Comunicacion exitosa CON resultado. Ya existe deuda.
        elseif (!isset($resp1['faultcode']) && (!empty($resp1)) && ($resp1 !== false)) {           
            $identificadorCobro = $resp1["return"]["codigo"];
        }
                  
        // Falla WS [consultarIdentificadorCobro]
        elseif (isset($resp1['faultcode']) || ( $resp1 === false)) {
            $error = true;
        }
        
        if (!$error) {
            catalogo::consultar('certificados', 'guardar_identificador_cobro', array(
                'id_certif_pedido'             => $diplomaSolicitado['ID_CERTIF_PEDIDO'],
                'identificador_cobro'   => $identificadorCobro
                )); 
        }
        
        return $error;
                    
    }
}
