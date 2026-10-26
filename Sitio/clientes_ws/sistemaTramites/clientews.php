<?php

// Includes necesarios para el funcionamiento
/* include(dirname(__DIR__) . '/conf/credenciales.php');
  include(dirname(__DIR__) . '/conf/hostsws.php'); */

class ClienteSistemaTramites {

    public $configEntorno;
    public $configApp;

    function __construct() {
        $this->configEntorno = parse_ini_file("/etc/guarani292/configEntorno.ini", true);
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
    }

    function altaTramite($expediente, $nombreAlumno, $tipoDocumento, $nroDocumento, $carrera, $ua, $archivoB64, $certificacionMinisterial, $tipoCertificado, $fechaSolicitud) {
        // Seteo parametros de conexion
        $url = $this->configEntorno["wsTramites"]["urlWS"] . '/certificados';

        $datosWS = new stdClass();
        $datosWS->numeroExpediente = $expediente;
        $datosWS->nombreApellido = $nombreAlumno;
        $datosWS->tipoDocumento = $tipoDocumento;
        $datosWS->documento = $nroDocumento;
        $datosWS->carrera = $carrera;
        $datosWS->unidadAcademica = $ua;
        $datosWS->fechaSolicitud = date_format(date_create($fechaSolicitud), 'd/m/Y');
        $datosWS->sistemaCliente = $this->configEntorno["wsExpedientes"]["usuario"];
        $datosWS->contenidoArchivo = $archivoB64;
        $datosWS->obleaMinisterio = $certificacionMinisterial;
        $datosWS->tipoCertificado = $tipoCertificado;

        $respuesta = $this->invocarWS($url, $datosWS);
        return $respuesta;
        /* $curl = curl_init($url);
        $curl_post_data = json_encode($datosWS);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $usuario = $this->configEntorno["wsTramites"]["usuario"];
        $password = $this->configEntorno["wsTramites"]["password"];
        curl_setopt($curl, CURLOPT_USERPWD, $usuario.":".$password);
        $curl_response = curl_exec($curl);
        curl_close($curl);

        return json_decode($curl_response);*/
    }

    function altaTramiteDiploma($expediente, $nombreAlumno, $nroDocumento, $sexo, 
        $tipoDocumento, $tipoDocumentoDescripcion, $carrera, $tipoCarrera, $ua, 
        $fechaEgreso, $fechaNacimiento, $paisNacimiento, $provinciaNacimiento, 
        $localidadNacimiento, $resMinisterial, $tituloObtenido, $urlFoto, $codPaisDNI, 
        $nombreTesina, $diplomaImpreso, $autorizanteRetiro, $archivoCA, $archivoTT,
	$esTituloIntermedio, $esExtranjero, $tituloAnterior, $esColSecExtranjero, $tipoTramite, $carpetaLegajoPublicacion, $fechaSolicitud) {

        $url = $this->configEntorno["wsTramites"]["urlWS"] . '/titulo';
		
		switch ($tipoTramite) {
			case 'E': $tipoTramite = 'ESPECIAL';	break;
			case 'A': $tipoTramite = 'ABREVIADO';	break;
			case 'N': $tipoTramite = 'NORMAL';		break;
		}
        
        $datosWS = new stdClass();
        $datosWS->numeroExpediente = $expediente;
        $datosWS->nombreApellido = $nombreAlumno;
        $datosWS->documento = $nroDocumento;
        $datosWS->sexo = $sexo;
        $datosWS->tipoDocumento = $tipoDocumentoDescripcion;
        $datosWS->carrera = $carrera;
        $datosWS->tipoCarrera = $tipoCarrera;
        $datosWS->unidadAcademica = $ua;
        $datosWS->fechaSolicitud = date_format(date_create($fechaSolicitud), 'd/m/Y');
        $datosWS->fechaEgreso = $fechaEgreso;
        $datosWS->fechaNacimiento = $fechaNacimiento;
        $datosWS->paisNacimiento = $paisNacimiento;
        $datosWS->provinciaNacimiento = $provinciaNacimiento;
        $datosWS->localidadNacimiento = $localidadNacimiento;
        $datosWS->resMinisterial = $resMinisterial;
        $datosWS->tituloObtenido = $tituloObtenido;
        $datosWS->urlFoto = $urlFoto;
        $datosWS->carpetaLegajoPublicacion = $carpetaLegajoPublicacion;
        $datosWS->nombreTesina = $nombreTesina;
        $datosWS->diplomaImpreso = $diplomaImpreso;
        $datosWS->autorizanteRetiro = $autorizanteRetiro;
        $datosWS->contenidoArchivoCA = $archivoCA;
        $datosWS->contenidoArchivoTT = $archivoTT;
        $datosWS->esTituloIntermedio = $esTituloIntermedio;
        $datosWS->esExtranjero = $esExtranjero;
        $datosWS->tituloAnterior = $tituloAnterior;
        $datosWS->esColSecExtranjero = $esColSecExtranjero;
        $datosWS->tramiteTipo = $tipoTramite;
        $respuesta = $this->invocarWS($url, $datosWS);

        return $respuesta;
    }

    function invocarWS($url, $datosWS){
        $curl = curl_init($url);
        $curl_post_data = json_encode($datosWS);
        curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($curl, CURLOPT_POSTFIELDS, $curl_post_data);
        $usuario = $this->configEntorno["wsTramites"]["usuario"];
        $password = $this->configEntorno["wsTramites"]["password"];
        curl_setopt($curl, CURLOPT_USERPWD, $usuario.":".$password);
        $curl_response = curl_exec($curl);
	syslog(LOG_ERR, "[info] " . $curl_response);

        curl_close($curl);

        return json_decode($curl_response);
    }
}
