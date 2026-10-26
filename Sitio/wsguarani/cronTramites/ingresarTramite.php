<?php

require_once '../../src/siu/lib/kernel/util/vista_jasperreports_ws.php';
require_once '../../src/siu/lib/kernel/kernel.php';
require_once '../../src/siu/lib/kernel/util/manejador_archivos.php';
require_once '../../src/siu/lib/kernel/util/encoding.php';

use kernel\util\vista_jasperreports_ws;
use kernel\kernel;
use kernel\nucleo;
use kernel\util\manejador_archivos;
use kernel\util\encoding;

include_once('../../clientes_ws/sistemaTramites/clientews.php');
include_once('tramites.php');
include_once('logTramiteAnalitico.php');

class SistemaTramites {

    public $configApp;

    function __construct() {
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
    }

    function ingresarTramite() {
        $timer = $this->configApp["cronTramites"]["timer"]; // Segundos
        $intentos = $this->configApp["cronTramites"]["intentos"];
        $tramites = new Tramites();
        $clienteWS = new ClienteSistemaTramites();
        // Obtener los tramites validados sin fecha de impresion
        $sinTramites = $tramites->obtenerCertificadosValidados();
        $totalTramites = sizeof($sinTramites);
        $cont = 1;
        syslog(LOG_ERR,"[info] Cantidad de tramites: " . $totalTramites);
        foreach ($sinTramites as $tra) {
            $j = 1;
            $registro = false;
            do {
                if ($j <> 1) {
                    sleep($timer);
                }
                syslog(LOG_ERR,"[info] Tramite " . $cont . " de " . $totalTramites);
                if (!is_null($tra["expediente"])){
                    // PASO 1: OBTENGO LOS ARGUMENTOS Y GENERO LOS CERTIFICADOS
                    $argumentos = $tramites->obtenerArgumentosCertificado($tra["db"], $tra["id"]);
                    $certificacionMinisterial = "N";
                    foreach ($argumentos as $arg) {
                        if (($arg["nombre"] == "certificado_me") or ($arg["nombre"] == "unl_ministerial")){
                            $certificacionMinisterial = $arg["argumento"];
                        }
                    }
                    $solicitud = $tra["id"];
                    switch ($tra["tipoCertificado"]) {
                    case 5: // Certificado de Materias Aprobadas
                        $carrera = ($argumentos[0]["version"] == "G2") ? $argumentos[1]["argumento"] : null;
                        $legajo = ($argumentos[0]["version"] == "G2") ? $argumentos[2]["argumento"] : null;
                        $observaciones = ($argumentos[0]["version"] == "G2") ? $argumentos[3]["argumento"] : null;
                        $corresponda = ($argumentos[0]["version"] == "G2") ? $argumentos[4]["argumento"] : null;
                        $exterior = ($argumentos[0]["version"] == "G2") ? $argumentos[5]["argumento"] : null;
                        // $solicitud = ($argumentos[0]["version"] == "G3") ? $tra["id"] : null;
                        $materias = $tramites->obtenerMateriasCertificado5($tra["db"], $tra["ua"], $carrera, $legajo, $observaciones, $corresponda, $exterior, $solicitud);
                        $jasper = "materiasAprobadas.jasper";
                        $tipoCertificado = 'MA';
                        $fechaCertificado = $this->getFechaCertificado();
                        $b64Doc = $this->generar_certificado($jasper, $tipoCertificado, $fechaCertificado, $tra["id"], $materias);
                        break;
                    case 9: // Certificado de Historia Académica
                        $carrera = ($argumentos[0]["version"] == "G2") ? $argumentos[1]["argumento"] : null;
                        $legajo = ($argumentos[0]["version"] == "G2") ? $argumentos[2]["argumento"] : null;
                        $corresponda = ($argumentos[0]["version"] == "G2") ? $argumentos[3]["argumento"] : null;
                        // $solicitud = ($argumentos[0]["version"] == "G3") ? $tra["id"] : null;
                        $materias = $tramites->obtenerMateriasCertificado9($tra["db"], $tra["ua"], $carrera, $legajo, $corresponda, $solicitud);
                        $jasper = "historiaAcademica.jasper";
                        $tipoCertificado = 'HA';
                        $fechaCertificado = $this->getFechaCertificado();
                        $b64Doc = $this->generar_certificado($jasper, $tipoCertificado, $fechaCertificado, $tra["id"], $materias);
                        break;
                    case 100: // Certificado Analítico
                        if (array_key_exists('nroInscripcion', $tra)){
                            $nroInscripcion = $tra["nroInscripcion"];
                        } else{
                            $nroInscripcion = null;
                        }
                        $titCertif = ($argumentos[0]["version"] == "G2") ? $argumentos[2]["argumento"] : null;
                        $materias = $tramites->obtenerMateriasCertificado100($tra["db"], $tra["ua"], $nroInscripcion, $titCertif, $solicitud);
						if ($argumentos["version"] == "G3") {
							$datosSuplemento = $tramites->obtenerDatosSuplemento($tra['alumno'], $materias[0]['fechaEgreso']);
							$materias = [$materias, $datosSuplemento];
						}
                        $jasper = "certificadoAnalitico.jasper";
                        $tipoCertificado = 'CA';
                        $fechaCertificado = $this->getFechaCertificado();
                        $b64Doc = $this->generar_certificado($jasper, $tipoCertificado, $fechaCertificado, $tra["id"], $materias, $argumentos['version']);
                        break;
                    case 102: // Diploma
                        // Obtengo datos especificos del tramite de diplomas
                        $datosDiploma = $tramites->obtenerDatosTramiteDiplomaDigital($tra["db"], $tra["ua"], $solicitud);
                        if (array_key_exists('nroInscripcion', $tra)){
                            $nroInscripcion = $tra["nroInscripcion"];
                        } else{
                            $nroInscripcion = null;
                        }
                        $titCertif = $datosDiploma[0]["codigo_titulo"];
                        $materias = $tramites->obtenerMateriasCertificado100($tra["db"], $tra["ua"], $nroInscripcion, $titCertif, $solicitud);
						if ($argumentos["version"] == "G3") {
							$datosSuplemento = $tramites->obtenerDatosSuplemento($tra['alumno'], $materias[0]['fechaEgreso']);
							$materias = [$materias, $datosSuplemento];
						}
                        $jasper = "certificadoAnalitico.jasper";
                        $tipoCertificado = 'CA';
                        $fechaCertificado = $this->getFechaCertificado();
                        $b64Doc = $this->generar_certificado($jasper, $tipoCertificado, $fechaCertificado, $tra["id"], $materias, $argumentos['version']);
                        $jasper = "certificadoTituloEnTramite.jasper";
                        $tipoCertificado = 'TT';
                        $datosCertificadoTT = $tramites->obtenerDatosCertificadoTT($tra["db"], $tra["ua"], $datosDiploma[0]["nro_solicitud_egreso"]);
                        $b64DocTT = $this->generar_certificado($jasper, $tipoCertificado, $fechaCertificado, $tra["id"], $datosCertificadoTT);
                        break;
                    }
			
                    // PASO 2: INVOCO AL SISTEMA DE TRAMITES PARA ENVIAR LA SOLICITUD
                    $unidadAcademica = $tramites->obtenerUAMesaEntradas($tra["ua"]);
                    if (!empty($materias)){

						// Reacomodo arreglo de materias
						if ($tipoCertificado == 'CA' && $argumentos["version"] == "G3") {
							$materias = $materias[0];
						}						
                        if ($tra["tipoCertificado"] == 102){
                            // Llamo al WS de diploma
                            $respWS = $clienteWS->altaTramiteDiploma($datosDiploma[0]["expediente"],
                                 $datosDiploma[0]["nombres"] . " " . $datosDiploma[0]["apellido"],
                                $datosDiploma[0]["nro_documento"],
                                $datosDiploma[0]["sexo"],
                                $datosDiploma[0]["tipo_doc"],
                                $datosDiploma[0]["tipo_doc_descripcion"],
                                $datosDiploma[0]["nombre_carrera"],
                                $datosDiploma[0]["tipo_de_carrera"],
                                $unidadAcademica->nombreMesaEntrada,
                                $datosDiploma[0]["fecha_egreso"],
                                $datosDiploma[0]["fecha_nacimiento"],
                                $datosDiploma[0]["pais_nacimiento"],
                                $datosDiploma[0]["provincia_nacimiento"],
                                $datosDiploma[0]["localidad_nacimiento"],
                                $datosDiploma[0]["resolucion_ministerial"],
                                $datosDiploma[0]["nombre_titulo"],
                                $datosDiploma[0]["url_foto"],
                                $datosDiploma[0]["cod_pais_dni"],
                                $datosDiploma[0]["nombre_tesina"],
                                $datosDiploma[0]["diploma_impreso"],
                                $datosDiploma[0]["autorizante_retiro"],
                                $b64Doc, $b64DocTT,
								$datosDiploma[0]["es_titulo_intermedio"],
								$datosDiploma[0]["es_extranjero"],
								$datosDiploma[0]["titulo_anterior"],
								$datosDiploma[0]["es_col_sec_extranjero"],
								$datosDiploma[0]["tipo_tramite"],
                                $datosDiploma[0]["path_nuxeo"],
                                $tra['fechaSolicitud']);
                        } else {
                            $respWS = $clienteWS->altaTramite($tra["expediente"], $tra["apellido"] . " " . $tra["nombres"], $materias[0]["tipoDocDescripcion"], $materias[0]["nroDocumento"], utf8_encode($materias[0]["nombreCarrera"]), $unidadAcademica->nombreMesaEntrada, $b64Doc, $certificacionMinisterial, $tipoCertificado, $tra['fechaSolicitud']);
                        }
                    } else {
                        $respWS = new stdClass();
                        $respWS->codRespuesta = -1;
                        syslog(LOG_ERR,"[error] Fallo la recuperacion de materias para el tramite: " . $tra["id"] . " - " . $tra["db"]);
                    }
                    $registro = false;
                    // PASO 3: ACTUALIZO EL CAMPO fecha_de_emision DE LA TABLA DE sga_certif_pedidos
                    if ($respWS && $respWS->codRespuesta == 0) {
                        $registro = $tramites->registrarImpresion($tra["id"], $tra["db"]);
                        if (!$registro) {
                            syslog(LOG_ERR,"[error] Fallo actualizacion en Guarani del registro de impresion: " . $tra["id"] . " - " . $tra["db"]);
                            $j++;
                        }
                    } else {
                        $mensajeWS = '';
                        if ($respWS){
                            $mensajeWS = json_encode($respWS);
                        }
                        syslog(LOG_ERR,"[error] Fallo conexion al Sistema de Tramites: " . $tra["expediente"] . " - " . $tra["ua"] . " - MensajeWS: " . $mensajeWS);
                        $j++;
                    }
                    if ($respWS && $registro) {
                        syslog(LOG_ERR,"[info] Actualizacion exitosa de la impresion del certificado: " . $tra["id"] . " - " . $tra["db"]);
                    }
                    if ($j == $intentos) {
                        $mensaje = "Fallo la comunicacion con el Sistema de Tramites.\n";
                        $mensaje .= "Referencia de tramite:\n";
                        $mensaje .= "ID Certificado = " . $tra["id"] . "\n";
                        $mensaje .= "Base de datos = " . $tra["db"] . "\n";
                        $mensaje .= "Expediente = " . $tra["expediente"];
                        syslog(LOG_ERR, $mensaje);
                        // $mail = new mailTramiteAnalitico();
                        // $mail->errorMail($mensaje);
                    }
                } else {
                    $j++;
                    if ($j == $intentos){
                        syslog(LOG_ERR,"[error] El tramite: " . $tra["id"] . " - " . $tra["db"] . ", no tiene expediente y no se ingresara para firmar");
                    }   
                }
            } while ((!$registro || !$respWS) && ($intentos > $j));
            $cont++;
        }
    }

    function generar_certificado($nombreJasper, $tipoCertificado, $fechaCertificado, $idTramite, $datos, $version = null){
        $report = new vista_jasperreports_ws();
        // PATH del reporte
        $path = dirname(__FILE__) . "/jasper/" . $nombreJasper;
        $report->set_path_reporte($path);
        // PARAMETROS del reporte
        // Obtener este dato en cada bloque de tipo
        // $fechaCertificado = $this->getFechaCertificado(); 
        $report->set_parametro("fecha_reporte", "S", $fechaCertificado);
        $nombre = sys_get_temp_dir() . '/datos' . $tipoCertificado . $idTramite . '.xml';
		
		// En el caso de CA, la estructura es distinta. Se agrego un arbol aparte para la info de suplemento al titulo.
        $aXMLear = ($tipoCertificado === 'CA' && $version === 'G3') ? ['datos' => $datos[0], 'tabla' => $datos[1]] : ['datos' => $datos];
        $xmlData = $this->generar_xml($aXMLear, $nombre);
        $report->set_xml($xmlData);
        // GENERACION del reporte
        $report->generar_salida();
        $b64Doc = base64_encode(file_get_contents($report->get_nombre_archivo_generado()));
        return $b64Doc;
    }

    function generar_xml($data, $filename) {
        // creating object of SimpleXMLElement
        $xml_data = new SimpleXMLElement('<HistoriaAcademica></HistoriaAcademica>');

        // function call to convert array to xml
        $this->array_to_xml($data, $xml_data);
        //saving generated xml file; 
        $result = $xml_data->asXML($filename);
        return $xml_data->asXML();
    }

    function array_to_xml($data, &$xml_data) {
        foreach ($data as $key => $value) {
            if (is_numeric($key)) {
                $key = 'item'; //dealing with <0/>..<n/> issues
            }
            if (is_array($value)) {
                $subnode = $xml_data->addChild($key);
                $this->array_to_xml($value, $subnode);
            } else {
                $value = utf8_encode($value);
                $xml_data->addChild("$key", htmlspecialchars("$value"));
            }
        }
    }

    function getFechaCertificado() {
        $nMes = date("n");
        switch ($nMes) {
            case 1: $mes = "ENERO";
                break;
            case 2: $mes = "FEBRERO";
                break;
            case 3: $mes = "MARZO";
                break;
            case 4: $mes = "ABRIL";
                break;
            case 5: $mes = "MAYO";
                break;
            case 6: $mes = "JUNIO";
                break;
            case 7: $mes = "JULIO";
                break;
            case 8: $mes = "AGOSTO";
                break;
            case 9: $mes = "SEPTIEMBRE";
                break;
            case 10: $mes = "OCTUBRE";
                break;
            case 11: $mes = "NOVIEMBRE";
                break;
            case 12: $mes = "DICIEMBRE";
                break;
        }
        return date("j") . " DE " . $mes . " DE " . date("Y");
    }

	}
