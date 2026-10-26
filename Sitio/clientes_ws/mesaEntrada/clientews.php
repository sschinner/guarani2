<?php

// Auditoria
include_once (dirname(__DIR__) . '../../wsguarani/Repositorio/RepositorioWS.php');

class ClienteMesaEntrada {

    public $configEntorno;
    public $configApp;
    public $repositorio;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
        $this->repositorio = new RepositorioWS();
    }
    
    function altaExpediente($uaMDE, $descripcion, $palabrasClaves, $palabrasClavesAuto, $origenes) {
        // Seteo parametros de conexion
        $url = $this->configEntorno["wsExpedientes"]["urlWS"] . '/expediente';

        $datosWS = new stdClass();
        $datosWS->sistemaCliente = $this->configEntorno["wsExpedientes"]["usuario"];
        $datosWS->mesaDeEntradas = $uaMDE;
        $datosWS->expediente = new stdClass();
        $datosWS->expediente->origenes = array(array("id" => $origenes));
        $datosWS->expediente->conceptoId = $this->configApp["wsMesaEntrada"]["concepto"];
        $datosWS->expediente->descripcion = $descripcion;
        $datosWS->expediente->palabrasClaves = $palabrasClaves;
        $datosWS->expediente->palabrasClavesAuto = $palabrasClavesAuto;
        $datosWS->expediente->dependenciaOrigenId = $uaMDE;
        $datosWS->expediente->digital = true;
        
        $curl = curl_init($url);
        $curl_post_data = json_encode($datosWS);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $curl_response = curl_exec($curl);

        $this->repositorio->registrarAuditoria(json_decode($curl_post_data, true), json_decode($curl_response, true), 'expediente', $datosWS->sistemaCliente);
        curl_close($curl);

        return json_decode($curl_response);
    }

    function paseExpediente($expediente, $idOrigen, $idDestino, $descripcion) {
        // Seteo parametros de conexion
        $url = $this->configEntorno["wsExpedientes"]["urlWS"] . '/pase';

        $datosWS = new stdClass();
        $datosWS->sistemaCliente = $this->configEntorno["wsExpedientes"]["usuario"];
        $datosWS->paseRecibido = true;
        $datosWS->pase = new stdClass();
        $datosWS->pase->numeroExpediente = $expediente;
        $time = time();
        $datosWS->pase->fechaEnvio = date("d/m/Y H:i:s", $time) . '.000';
        $datosWS->pase->idDependenciaOrigen = $idOrigen;
        $datosWS->pase->idDependenciaDestino = $idDestino;
        $datosWS->pase->descripcion = $descripcion;
        
        $curl = curl_init($url);
        $curl_post_data = json_encode($datosWS);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $curl_response = curl_exec($curl);
        
        $this->repositorio->registrarAuditoria(json_decode($curl_post_data, true), json_decode($curl_response, true), 'pase', $datosWS->sistemaCliente);
        curl_close($curl);

        return json_decode($curl_response);
    }
    
    function altaExpedienteElectronico($uaMDE, $descripcion, $palabrasClaves, $palabrasClavesAuto, $origenes, $contenidoArchivo, $descripcionArchivo) {
        // Seteo parametros de conexion
        $url = $this->configEntorno["wsExpedientes"]["urlWS"] . '/expedienteElectronico';
        $username = $this->configEntorno['wsExpedientes']['username'];
        $password = $this->configEntorno['wsExpedientes']['password'];

        $datosWS = new stdClass();
        $datosWS->sistemaCliente = $this->configEntorno["wsExpedientes"]["usuario"];
        $datosWS->mesaDeEntradas = $uaMDE;
        $datosWS->contenidoArchivo = $contenidoArchivo;
        $datosWS->descripcionArchivo = $descripcionArchivo;
        $datosWS->expediente = new stdClass();
        $datosWS->expediente->origenes = [["id" => $origenes]];
        $datosWS->expediente->conceptoId = $this->configApp["wsMesaEntrada"]["concepto"];
        $datosWS->expediente->descripcion = $descripcion;
        $datosWS->expediente->palabrasClaves = $palabrasClaves;
        $datosWS->expediente->palabrasClavesAuto = $palabrasClavesAuto;
        $datosWS->expediente->dependenciaOrigenId = $uaMDE;
        $datosWS->expediente->digital = true;
        
        $curl = curl_init($url);
        $curl_post_data = json_encode($datosWS);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($curl, CURLOPT_USERPWD, $username . ":" . $password);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data); 
        $curl_response = curl_exec($curl);
        
        $datosWS->contenidoArchivo = 'archivo_base64';
        $this->repositorio->registrarAuditoria(json_decode(json_encode($datosWS), true), json_decode($curl_response, true), 'expedienteElectronico', $datosWS->sistemaCliente);
        curl_close($curl);

        return json_decode($curl_response);
    }

}
