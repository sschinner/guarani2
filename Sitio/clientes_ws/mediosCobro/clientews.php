<?php

// Includes necesarios para el funcionamiento
include_once(dirname(__DIR__) . '../../libraries/adodb/adodb.inc.php');
include_once(dirname(__DIR__) . '../../libraries/nusoap/lib/nusoap.php');

// Auditoria
include_once (dirname(__DIR__) . '../../wsguarani/Repositorio/RepositorioWS.php');

class ClienteMediosCobro {

    public $configEntorno;
    public $configApp;
    public $repositorio;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
        $this->repositorio = new RepositorioWS();                    
    }

    function obtenerMediosCobro() {
        // Seteo parametros de conexion
        $wsdl = $this->configEntorno["wsMediosDeCobro"]["urlWS"] . '/ws/deuda?wsdl';
        $client = new nusoap_client($wsdl, 'wsdl');
        $param = array("usuario" => $this->configEntorno["wsMediosDeCobro"]["usuario"],
            "clave" => $this->configEntorno["wsMediosDeCobro"]["password"]);
        $client->soap_defencoding = 'UTF-8';
        $client->decode_utf8 = true;
        $resultado = $client->call('listadoMediosDePago', $param);
        return $resultado;
    }

    function obtenerEntidades() {
        // Seteo parametros de conexion
        $wsdl = $this->configEntorno["wsMediosDeCobro"]["urlWS"] . '/ws/deuda?wsdl';
        $client = new nusoap_client($wsdl, 'wsdl');
        $param = array("usuario" => $this->configEntorno["wsMediosDeCobro"]["usuario"],
            "clave" => $this->configEntorno["wsMediosDeCobro"]["password"]);
        $client->soap_defencoding = 'UTF-8';
        $client->decode_utf8 = true;
        $resultado = $client->call('listadoEntidades', $param);
        return $resultado;
    }

    function notificarNuevoCobro($datos) {
        // Seteo parametros de conexion
        $wsdl = $this->configEntorno["wsMediosDeCobro"]["urlWS"] . '/ws/deuda?wsdl';
        $client = new nusoap_client($wsdl, 'wsdl');
        $param = array("usuario" => $this->configEntorno["wsMediosDeCobro"]["usuario"],
            "clave" => $this->configEntorno["wsMediosDeCobro"]["password"],
            "docTipo" => utf8_encode($datos->tipoDoc), 
            "docNumero" => utf8_encode($datos->nroDoc),
            // "docPais" => $datos->paisDoc,
            "apellido" => utf8_encode($datos->apellido), 
            "nombre" => utf8_encode($datos->nombre),
            "email" => utf8_encode($datos->email),
            "monto" => $datos->monto, "cuota" => $datos->cuotas,
            "periodo" => $datos->periodo,
            "vigencia" => $datos->vigencia, "idEntidad" => $datos->entidad, 
            "idServicio" => $datos->idServicio,
            "identificadorDeuda" => $datos->identificadorDeuda,
            "detalle" => utf8_encode($datos->detalle),
            "urlNotificacion" => $datos->url, "cMediosDePago" => $datos->medioPago);
        $client->soap_defencoding = 'UTF-8';
        $client->decode_utf8 = true;
       
        $resultado = $client->call('nuevaDeuda', $param);
        
        unset($param["clave"]);
        $this->repositorio->registrarAuditoria($param, $resultado, 'nuevaDeuda', $param["usuario"]);
        return $resultado;
    }

    function consultarEstadoCobro($idCobro) {
        // Seteo parametros de conexion
        $wsdl = $this->configEntorno["wsMediosDeCobro"]["urlWS"] . '/ws/deuda?wsdl';
        $client = new nusoap_client($wsdl, 'wsdl');
        $param = array("usuario" => $this->configEntorno["wsMediosDeCobro"]["usuario"],
            "clave" => $this->configEntorno["wsMediosDeCobro"]["password"],
            "codigo" => $idCobro);
        $client->soap_defencoding = 'UTF-8';
        $client->decode_utf8 = true;
        $resultado = $client->call('datosDeudaPorCodigo', $param);
        
        unset($param["clave"]);
        $this->repositorio->registrarAuditoria($param, $resultado, 'datosDeudaPorCodigo', $param["usuario"]);
        return $resultado;
    }
    
        function consultarIdentificadorCobro($idDeuda) {
        // Seteo parametros de conexion
        $wsdl = $this->configEntorno["wsMediosDeCobro"]["urlWS"] . '/ws/deuda?wsdl';
        $client = new nusoap_client($wsdl, 'wsdl');
        $param = array("usuario" => $this->configEntorno["wsMediosDeCobro"]["usuario"],
            "clave" => $this->configEntorno["wsMediosDeCobro"]["password"],
            "identificadorDeuda" => $idDeuda);
        $client->soap_defencoding = 'UTF-8';
        $client->decode_utf8 = true;
       
        $resultado = $client->call('deudasPorFiltros', $param);
        
        unset($param["clave"]);
        $this->repositorio->registrarAuditoria($param, $resultado, 'deudasPorFiltros', $param["usuario"]);
        return $resultado;
    }

}
