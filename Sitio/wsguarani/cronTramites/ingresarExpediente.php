<?php

require_once '../../src/siu/lib/kernel/util/vista_jasperreports_ws.php';
use kernel\util\vista_jasperreports_ws;

include_once('../../clientes_ws/mesaEntrada/clientews.php');
include_once('tramites.php');
include_once('logTramiteAnalitico.php');

class Expedientes {

    public $configApp;
    public $configEntorno;

    function __construct() {
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
    }

    function ingresarExpediente() {
        $timer = $this->configApp["cronTramites"]["timer"]; // Segundos
        $intentos = $this->configApp["cronTramites"]["intentos"];
        $tramites = new Tramites();
        $clienteWS = new ClienteMesaEntrada();
        // Obtener los tramites pagos sin expedientes cargados
        $sinExpedientes = $tramites->obtenerTramitesSinExpediente();
        $totalExpedientes = sizeof($sinExpedientes);
        $cont = 1;
        syslog(LOG_ERR,"[info] Cantidad de tramites: " . $totalExpedientes);
        foreach ($sinExpedientes as $exp) {
            $j = 1;
            do {
                if ($j <> 1) {
                    sleep($timer);
                }
                syslog(LOG_ERR,"[info] Tramite " . $cont . " de " . $totalExpedientes);
                $registro = false;
                $idMDE = $tramites->obtenerUAMesaEntradas($exp["ua"]);
                $descripcion = $exp["apellido"] . " " . $exp["nombres"] . 
                    " solicita su " . $this->configApp["wsMesaEntrada"]["descripcion".$exp["tipoCertificado"]] . 
                    " correspondiente a la carrera " . $exp["carrera"];
                
                if ($exp['certificacionMinisterial'] == 'S') {
                    $validacion = utf8_encode(" con Certificaci? Ministerial.");
                }
                elseif ($exp['certificacionMinisterial'] == 'N') {
                    $validacion = utf8_encode(" sin Certificaci? Ministerial.");
                }                
                if ($exp['certificacionMinisterial'] != NULL) $descripcion .= $validacion;
                
                $palabrasClaves = array(array("palabra_clave" => $exp["apellido"]),
                    array("palabra_clave" => $this->configApp["wsMesaEntrada"]["descripcion".$exp["tipoCertificado"]]),
                    array("palabra_clave" => $exp["tipoDocumento"] . $exp["nroDocumento"]));
                $palabrasClavesAuto = array(array("palabra_clave_auto" => $this->configApp["wsMesaEntrada"]["conceptoNombre"]),
                    array("palabra_clave_auto" => $idMDE->nombreMesaEntrada));

                    switch ($exp["tipoCertificado"]) {
                        case '102':
                            $descripcionArchivo = 'Inicio Trámite Diploma Digital';
                            $datosReporte = $tramites->obtenerDatosTramiteDiplomaDigital($exp["db"], $exp["ua"], $exp["id"]);
                            $exp["fecha_egreso"] = $datosReporte[0]["fecha_egreso"];
                            $exp["nombre_titulo"] = $datosReporte[0]["nombre_titulo"];
                            break;
                        case '100':
                            $descripcionArchivo = 'Inicio Trámite CA';
                            $datosReporte = $tramites->obtenerMateriasCertificado100($exp["db"], $exp["ua"], $exp["nroInscripcion"], $exp["titulo"], $exp["id"]);
                            $exp["fecha_egreso"] = $datosReporte[0]["fechaEgresoString"];
                            $exp["nombre_titulo"] = utf8_encode($datosReporte[0]["nombreTitulo"]);
                            break;                            
                        case '5':
                            $descripcionArchivo = 'Inicio Trámite CMA';
                            break;                            
                        case '9':
                            $descripcionArchivo = 'Inicio Trámite CHA';
                            break;                            
                    }
                    
                    $b64Doc = $this->generar_reporte('inicioExpediente.jasper', 'inicioEXP', $this->getFechaReporte(), $exp);
                    
                    $expediente = $clienteWS->altaExpedienteElectronico($idMDE->mesaEntrada, $descripcion, $palabrasClaves, $palabrasClavesAuto, $idMDE->origenes, $b64Doc, $descripcionArchivo);
                
                if ($expediente && $expediente->codRespuesta == 0) {
                    if ($idMDE->mesaEntrada != $idMDE->alumnado) {
                        $paseExp = $clienteWS->paseExpediente($expediente->expediente->numero, $idMDE->mesaEntrada, $idMDE->alumnado, $this->configApp["wsMesaEntrada"]["descripcionPase".$exp["tipoCertificado"]]);
                    } else {
                        $paseExp = new stdClass();
                        $paseExp->codRespuesta = 0;
                    }
                }
                if ($expediente && $expediente->codRespuesta == 0 &&
                        $paseExp && $paseExp->codRespuesta == 0) {
                    $registro = $tramites->registrarExpediente($exp["id"], $exp["db"], $expediente->expediente->numero);
                    if ($exp["tipoCertificado"] == '102'){
                        $titulo = 'Solicitud de diploma';
                    } else {
                        $titulo = 'Solicitud de certificado';
                    }
                    $url = $this->configEntorno["wsExpedientes"]["urlConsulta"] . '/expediente/' . $expediente->expediente->numero;
                    $mensaje = 'Su trámite tiene asignado el Expediente Nro. ' . $expediente->expediente->numero . '. ' . 
                                'Ud. puede consultar online el seguimiento del trámite iniciado, '
                            . 'por medio del sistema Mesa de Entradas - Seguimiento de Expedientes.';
                    $campoBusqueda = 'id_certif_pedido';
                    $datoBusqueda = $exp["id"];
                    $mail = $tramites->enviarMail($titulo, $mensaje, $campoBusqueda, $datoBusqueda, $exp["db"]);
                    if (!$registro) {
                        syslog(LOG_ERR, "[error] Fallo actualizacion en Guarani del expediente: " . $exp["id"] . " - " . $exp["db"] . " - " . $expediente->expediente->numero);
                        $j++;
                    }
                } else {
                    syslog(LOG_ERR, "[error] Fallo el registro en Mesa de Entradas: " . $exp["id"] . " - " . $exp["db"]);
                    $j++;
                }
                if ($expediente && $registro) {
                    syslog(LOG_ERR, "[info] Actualizacion exitosa del expediente: " . $exp["id"] . " - " . $exp["db"] . " - " . $expediente->expediente->numero);
                }
                if ($j == $intentos) {
                    $mensaje = "Fallo la comunicacion con el sistema de Mesa de Entradas.\n";
                    $mensaje .= "Referencia de tramite:\n";
                    $mensaje .= "ID Certificado = " . $exp["id"] . "\n";
                    $mensaje .= "Base de datos = " . $exp["db"] . "\n";
                    syslog(LOG_ERR, $mensaje);
                    // $mensaje .= "Expediente = " . $expediente->expediente->numero;
                    // $mail = new mailTramiteAnalitico();
                    // $mail->errorMail($mensaje);
                }
            } while ((!$registro || !$expediente) && ($intentos > $j));
            $cont++;
        }
    }
    
        function generar_reporte($nombreJasper, $nombreReporte, $fechaReporte, $datos){
        $report = new vista_jasperreports_ws();
        // PATH del reporte
        $path = dirname(__FILE__) . "/jasper/" . $nombreJasper;
        $report->set_path_reporte($path);
        // PARAMETROS del reporte
        $report->set_parametro("fecha_reporte", "S", $fechaReporte);
        
        $nombre = sys_get_temp_dir() . '/datos' . $nombreReporte . $datos["id"] . '.xml';
        $aXMLear = array('datos' => array($datos));
        $xmlData = $this->generar_xml($aXMLear, $nombre); 
        $report->set_xml($xmlData);
        // GENERACION del reporte
        $report->generar_salida();
        $b64Doc = base64_encode(file_get_contents($report->get_nombre_archivo_generado()));
        return $b64Doc;
    }

    function generar_xml($data, $filename) {
        // creating object of SimpleXMLElement
        $xml_data = new SimpleXMLElement('<InicioExpediente></InicioExpediente>');

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
//                $value = utf8_encode($value);
                $xml_data->addChild("$key", htmlspecialchars("$value"));
            }
        }
    }
    
    function getFechaReporte() {
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
