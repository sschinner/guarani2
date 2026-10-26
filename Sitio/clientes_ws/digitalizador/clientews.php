<?php

class ClienteDigitalizador {

    public $configEntorno;
    public $configApp;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
    } 

    function obtenerUrlDigitalizador($datos) {
        // Seteo parametros de conexion
        $url = $this->configEntorno["wsDigitalizador"]["urlWS"] . '/login';
        $usuario = $this->configEntorno["wsDigitalizador"]["userLogin"];
        $clave = $this->configEntorno["wsDigitalizador"]["passLogin"];
        // Obtengo token de autorizacion
        $curl = curl_init($url);
        curl_setopt($curl, CURLOPT_POST, TRUE);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_POSTFIELDS, "usuario=".$usuario."&clave=".$clave);
        $curl_response = curl_exec($curl);
        curl_close($curl);
        
        $respuesta = json_decode($curl_response);
        if (!$respuesta) return false;
        if ($respuesta->codigoWS != 0) {
            syslog(LOG_ERR, '[error][Digitalizador] Fallo en el login. ' . $respuesta->mensajeWS);            
            return false;
        }
        $token = $respuesta->data->Token;

        // Invoco a formulario
        $url = $this->configEntorno["wsDigitalizador"]["urlWS"] . '/formulario';
        $curl = curl_init($url);
        $curl_post_data = json_encode($datos);

        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Authorization: Bearer ' . $token));
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $curl_response = curl_exec($curl);
        curl_close($curl);

        $respuesta = json_decode($curl_response);
        if (!$respuesta) return false;
        if ($respuesta->codigoWS != 0) {
            syslog(LOG_ERR, '[error][Digitalizador] Fallo en la obtencion de formulario. ' . $respuesta->mensajeWS);
            return false;
        }

        return $respuesta->data->formularios;
    }

}

/*$configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
$configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
// Ejemplo de $datos
$paisDNI = "54";
$tipoDNI = "DNI";
$nroDNI = "30171912";
$cuil = "20301719125";
$hashGenerado = "1asdasdasdasq34323";
$apellido = "Schinner";
$nombres = "Sebastian Luis";
$paisNombre = "Argentina";
$requisitoDesc = "Fotocopia de DNI";
// u820 de requisitos diploma
$tipoDocumentoNuxeo = "Documento de Identidad";
$subTipoDocumentoNuxeo = "Completo";
$cantidadMaxima = 2;

$nombreDocumentoNuxeo = $paisDNI . "_" . $tipoDNI . "_" . $nroDNI;

$datos = array();
$datos[0]["identificador"] = $hashGenerado;
$datos[0]["urlRespuesta"] = $configEntorno["wsDigitalizador"]["urlRespuesta"];
$datos[0]["cantidadMaxima"] = $cantidadMaxima;
$datos[0]["propsPublicador"] = array();
$datos[0]["propsPublicador"]["pubspaceRepo"] = $configApp["wsDigitalizador"]["pubspaceRepo"];
$datos[0]["propsPublicador"]["workspaceRepo"] = $configApp["wsDigitalizador"]["workspaceRepo"];
$datos[0]["propsPublicador"]["nombreDocumento"] = $nombreDocumentoNuxeo . "_" . $requisitoDesc;
$datos[0]["propsPublicador"]["tipoDocumento"] = $configApp["wsDigitalizador"]["tipoDocumento"];
$datos[0]["propsPublicador"]["sePublica"] = $configApp["wsDigitalizador"]["sePublica"];
$datos[0]["propsPublicador"]["encarpetar"] = $configApp["wsDigitalizador"]["encarpetar"];
$datos[0]["propsPublicador"]["nombreCarpeta"] = $nombreDocumentoNuxeo;
$datos[0]["propsPublicador"]["propsDocumento"] = array();
$datos[0]["propsPublicador"]["propsDocumento"]["dc:title"] = $nombreDocumentoNuxeo . "_" . $requisitoDesc;
$datos[0]["propsPublicador"]["propsDocumento"]["canalitico:ApeNombre"] = $apellido . ' ' . $nombres;
$datos[0]["propsPublicador"]["propsDocumento"]["canalitico:TipoDocumento"] = $tipoDNI;
$datos[0]["propsPublicador"]["propsDocumento"]["canalitico:NroDocumento"] = $nroDNI;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:codigoPais"] = $paisDNI;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:cuil"] = $cuil;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:descPais"] = $paisNombre;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:descRequisito"] = $requisitoDesc;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:tipoDocu"] = $tipoDocumentoNuxeo;
$datos[0]["propsPublicador"]["propsDocumento"]["comunLegajo:subtipoDocu"] = $subTipoDocumentoNuxeo;

$prueba = new ClienteDigitalizador();
$salida = $prueba->obtenerUrlDigitalizador($datos);
var_dump($salida);*/