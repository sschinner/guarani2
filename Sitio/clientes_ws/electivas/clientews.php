<?php

class ClienteElectivas {

    public $configEntorno;
    public $configApp;

    function __construct() {
     //   $this->configEntorno = parse_ini_file(dirname(__DIR__) . "../../configEntorno.ini", true);
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        
    }

    function getToken($datos) {
        $url = $this->configEntorno["wsElectivas"]["urlWS"].'/auth';
        $usuario = $this->configEntorno["wsElectivas"]["userLogin"];
        $clave = $this->configEntorno["wsElectivas"]["passLogin"];
       
        $curl_post_data = json_encode($datos);
       
        $curl = curl_init();

        curl_setopt($curl, CURLOPT_URL, $url);

        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($curl, CURLOPT_POST, 1);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_USERPWD, $usuario . ':' . $clave);
        curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
        curl_setopt($curl, CURLOPT_HTTPHEADER, array(
            'Accept: application/json',
            'Content-Type: application/json')
        );
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $curl_response = curl_exec($curl);
       
//        if (curl_exec($curl) === false) {
//            echo 'Curl error: ' . curl_error($curl);
//        }
        curl_close($curl);

        $respuesta = json_decode($curl_response);
        
        return $respuesta->session;
    }
    
    public function getUrlConsulta(){
       
        return $this->configEntorno["wsElectivas"]["urlWS"].'/inscripcion/electivas?electivasSession=';
    }
    
    public function getUrlConsultaInscripto(){
       
        return $this->configEntorno["wsElectivas"]["urlWS"].'/inscripcion/alumno?electivasSession=';
    }
    
    public function getUrlInscripcion(){
       
        return $this->configEntorno["wsElectivas"]["urlWS"].'/inscripcion/inicio?electivasSession=';
    }
    

}
