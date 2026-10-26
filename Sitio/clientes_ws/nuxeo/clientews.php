<?php

class ClienteNuxeo {

    public $configEntorno;
    public $configApp;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
    }

    function obtenerArchivo($path) {       
        $datosWS = new stdClass();
        $datosWS->nombreDocumento = $path;
        $datosWS->usuarioRepo = $this->configEntorno["wsNuxeo"]["usuario"];
        $datosWS->passRepo = $this->configEntorno["wsNuxeo"]["password"];
        $curl_post_data = json_encode($datosWS);
        
        $ch = curl_init($this->configEntorno["wsNuxeo"]["urlWS"]."/recuperar");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $curl_post_data);
        $result_json = curl_exec($ch);
        curl_close($ch);
        
        $result = json_decode($result_json);        
        $pdf = base64_decode($result->archivo);       
        $file = '/tmp/archivo.pdf';
        file_put_contents($file, $pdf);

        if (file_exists($file)) {
            header('Content-Description: File Transfer');
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename="'.basename($file).'"');
            header('Expires: 0');
            header('Cache-Control: must-revalidate');
            header('Pragma: public');
            header('Content-Length: ' . filesize($file));
            readfile($file);
            exit;
        }
    }
}