<?php
//putenv("CLIENT_LOCALE=en_US.819");
//putenv("DB_LOCALE=en_US.819");
//putenv("INFORMIXDIR=/opt/informix");
//putenv("INFORMIXSERVER=guarani_test");
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

class Generales {
    /* -----------------------------------------------------------
      FUNCION QUE CONECTA CON LA BASE DE DATOS DE GUARANI SEGUN ODBC
      ------------------------------------------------------------ */

    function conectar($db) {
        $sTipoCon = "pdo";
        $objCC = & NewADOConnection($sTipoCon);

        $servidor = explode('_', $db);

        if ($servidor[0] == 'guarani3') {
            try {
                $dbConnect = new PDO("pgsql:host=" . HOSTPOSGRES . ";port=" . PUERTOPOSGRES . ";dbname=" . DBPOSGRES, USUARIOCONEXIONPOSGRES, PASSWORDCONEXIONPOSGRES);
                $dbConnect->exec('SET search_path TO negocio');
                return $dbConnect;
            } catch (PDOException $e) {
                return CODIGO_ERROR_CONEXION;
            }
        } else {

            $conexion = ('informix:host=' . HOST . '; service=' . PUERTO . ';database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
            $usuario = USUARIOCONEXION;
            $password = PASSWORDCONEXION;

            if (!$objCC->Connect($conexion, $usuario, $password)) {
                return CODIGO_ERROR_CONEXION;
            } else {
                $strSQL = "SET ROLE guarani";
                $objCC->Execute($strSQL);
                return $objCC;
            }
        }
    }

    /* -----------------------------------------------------------
      FUNCION QUE AUTENTICA LOS SERVICIOS DE WEB SERVICES DE GUARANI
      ------------------------------------------------------------ */

    // TODO: Eliminar funcion de autenticar para utilizar la de autorizacion
    // Buscar las funciones que invocan este metodo
    function autenticar() {
        if (isset($_SERVER['PHP_AUTH_USER']) and isset($_SERVER['PHP_AUTH_PW'])) {
            if ($_SERVER['PHP_AUTH_USER'] == $_SESSION['ws_user'] and $_SERVER['PHP_AUTH_PW'] == $_SESSION['ws_password'])
                return $resp = CODIGO_OK;
            else {
                return $resp = CODIGO_ERROR_AUTENTICACION;  // '1': Error de autenticacion - Usuario y contrase�a invalidas.
            }
        } else {
            return $resp = CODIGO_ERROR_AUTENTICACION;  // '2': Error de autenticacion - Usuario y contrase�a invalidas.
        }
    }

    // TODO (con mucho tiempo): tratar de llevar esto al autenticarConIni
    function autenticarAutorizar($usuario, $password, $permiso) {        
        if (isset($_SERVER['PHP_AUTH_USER']) and isset($_SERVER['PHP_AUTH_PW'])) {
            if (in_array($_SERVER['PHP_AUTH_USER'], $usuario) && in_array($_SERVER['PHP_AUTH_PW'], $password) && in_array($_SERVER['PHP_AUTH_USER'], $permiso))
                return $resp = CODIGO_OK;
            else {
                return $resp = CODIGO_ERROR_AUTENTICACION;  // '1': Error de autenticacion - Usuario y contrase�a invalidas.
            }
        } else {
            return $resp = CODIGO_ERROR_AUTENTICACION;  // '2': Error de autenticacion - Usuario y contrase�a invalidas.
        }
    }

    // Lo usa cron tramites
    function autenticarConIni($datosAutorizacion) {
        if (isset($_SERVER['PHP_AUTH_USER']) and isset($_SERVER['PHP_AUTH_PW'])) {
            if ($_SERVER['PHP_AUTH_USER'] == $datosAutorizacion->usuario and $_SERVER['PHP_AUTH_PW'] == $datosAutorizacion->password)
                return $resp = CODIGO_OK;
            else {
                return $resp = CODIGO_ERROR_AUTENTICACION;  // '1': Error de autenticacion - Usuario y contrase�a invalidas.
            }
        } else {
            return $resp = CODIGO_ERROR_AUTENTICACION;  // '2': Error de autenticacion - Usuario y contrase�a invalidas.
        }
    }

    /* ------------------------------------------------------------------
      FUNCION QUE RETORNA LA BASE DE DATOS SEGUN LA UNIDAD ACADEMICA PASADA
      ------------------------------------------------------------------- */

    public function recuperarDB($ua, $tipotitulo) {

        // Conversiones que sirven para CEMED (Distancia)
        if (($tipotitulo == '6') && (strtoupper($ua) == 'FCM')) {
            $ua = 'ecm';
        }
        if (($tipotitulo == '6') && (strtoupper($ua) == 'CI')) {
            $ua = 'idiomas';
        }
        if (($tipotitulo == '6') && (strtoupper($ua) == 'SG')) {
            $ua = 'secgral';
        }
        if (($tipotitulo == '6') && (strtoupper($ua) == 'EXT')) {
            $ua = 'extension';
        }

        // Conversiones que sirven para Guarani3
        // MODIFICAR A MEDIDA QUE SE VAYA MIGRANDO
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FCA')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FCV')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FIQ')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'CU-RA')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'CU-RS')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'EUAA')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'FADU')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '2') && (strtoupper($ua) == 'FADU')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FHUC')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FBCB')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'ESS')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FICH')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FCJS')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'FCM')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '2') && (strtoupper($ua) == 'FCM')) {
            $tipotitulo = '7';
        }
        if (in_array($tipotitulo, ['1', '2']) && (strtoupper($ua) == 'FCE')) {
            $tipotitulo = '7';
        }
        if (($tipotitulo == '1') && (strtoupper($ua) == 'ISM')) {
            $tipotitulo = '7';
        }

        switch ($tipotitulo) {
            case "1": $db = "alumnado_";
                break;
            case "2": $db = "posgrado_";
                break;
            case "3": $db = "semipre_";
                break;
            case "4": $db = "convenios_";
                break;
            case "5": $db = "escuela_";
                break;
            case "6": $db = "cemed_";
                break;
            case "7": $db = "guarani3_";
                break;
        }

        $db .= strtolower($ua);

        return $db;
    }

    // TODO: Eliminar este para que quede el con Cemed
    function recuperarTipoTitulo($ua) {

        switch ($ua) {
            case "EIS": $titulos = array('1');
                break;
            case "ESS": $titulos = array('1', '3');
                break;
            case "CU-RA": $titulos = array('7');
                break;
            case "CU-RS": $titulos = array('7');
                break;
            case "EUAA": $titulos = array('7');
                break;
            case "FADU": $titulos = array('1', '7');
                break;
            case "FBCB": $titulos = array('1', '2', '3');
                break;
            case "FCA": $titulos = array('1', '2');
                break;
            case "FCE": $titulos = array('1', '2');
                break;
            case "FCJS": $titulos = array('1', '2', '4', '5');
                break;
            case "FCM": $titulos = array('1');
                break;
            case "FCV": $titulos = array('1', '2');
                break;
            case "FHUC": $titulos = array('1', '2', '3');
                break;
            case "FICH": $titulos = array('1', '2');
                break;
            case "FIQ": $titulos = array('1', '2');
                break;
            case "CI": $titulos = array('6');
                break;
            case "ISM": $titulos = array('1');
                break;
            case "LM": $titulos = array('1');
                break;
        }

        return $titulos;
    }

    function recuperarTipoTituloConCemed($ua) {
        switch ($ua) {
            case "EIS": $titulos = array('1');
                break;
            case "ESS": $titulos = array('1', '3');
                break;
            case "CU-RA": $titulos = array('1');
                break;
            case "CU-RS": $titulos = array('1');
                break;
            case "EUAA": $titulos = array('6', '1');
                break;
            case "FADU": $titulos = array('1', '6',);
                break;
            case "FBCB": $titulos = array('1', '2', '3', '6');
                break;
            case "FCA": $titulos = array('1', '2', '6');
                break;
            case "FCE": $titulos = array('1', '2', '6');
                break;
            case "FCJS": $titulos = array('1', '2', '4', '5', '6');
                break;
            case "FCM": $titulos = array('1', '6');
                break;
            case "FCV": $titulos = array('1', '2', '6');
                break;
            case "FHUC": $titulos = array('1', '2', '3', '6');
                break;
            case "FICH": $titulos = array('1', '2', '6');
                break;
            case "FIQ": $titulos = array('1', '2');
                break;
            case "CI": $titulos = array('6');
                break;
            case "ISM": $titulos = array('1', '6');
                break;
            case "LM": $titulos = array('1');
                break;
        }

        return $titulos;
    }

    function obtenerTodasUA($tipotitulo = 0) {

        switch ($tipotitulo) {
            case 0:
                // MODIFICAR A MEDIDA QUE SE VAYA MIGRANDO
                $ua = array(
					"convenios_fcjs",
                    "escuela_fcjs", "semipre_ess", "semipre_fbcb", "semipre_fhuc",
                    "cemed_fadu", "cemed_fbcb", "cemed_fca", "cemed_fce",
                    "cemed_fcjs", "cemed_ecm", "cemed_fcv", "cemed_fhuc",
                    "cemed_euaa", "cemed_fich", "cemed_ism", "cemed_idiomas", "guarani3_");
                /* "posgrado_fiq", "posgrado_fadu","alumnado_euaa","alumnado_fiq","alumnado_fca", "alumnado_fcv"
		, "alumnado_fhuc","alumnado_fbcb","alumnado_ess","alumnado_fich", "alumnado_fadu", "alumnado_fcm",
		, "alumnado_fcjs","alumnado_fce", "alumnado_ism", "posgrado_fich", "posgrado_fbcb", "posgrado_fhuc"  =>MIGRADO A GUARANI3*/
                break;

            case 1:
                $ua = array(
                    "guarani3_"
                );
                break;

            case 2:
                $ua = array(
                    "posgrado_fiq", "posgrado_fich", "posgrado_fcjs",
                    "posgrado_fbcb", "posgrado_fhuc", "guarani3_"
                );
                break;

            case 3:
                $ua = array(
                    "semipre_ess", "semipre_fbcb", "semipre_fhuc", "guarani3_"
                );
                break;

            case 4:
                $ua = array(
                    "convenios_fcjs", "guarani3_"
                );
                break;

            case 5:
                $ua = array(
                    "escuela_fcjs", "guarani3_"
                );
                break;

            case 6:
                $ua = array(
                    "cemed_fadu", "cemed_fbcb", "cemed_fca", "cemed_fce",
                    "cemed_fcjs", "cemed_ecm", "cemed_fcv", "cemed_fhuc",
                    "cemed_euaa", "cemed_fich", "cemed_ism", "cemed_idiomas", "guarani3_"
                );
                break;
        }

        return $ua;
    }

    public function verificaUnidadAcademica($unidadAcademica) {

        $unidadesAcademicas = array('EIS', 'ESS', 'FBCB', 'FADU', 'EUAA', 'CU-RA', 'CU-RS', 'FCA', 'FCE', 'FCJS', 'FCM', 'FCV', 'FHUC', 'FICH', 'FIQ', 'CI', 'ISM');

        if (in_array($unidadAcademica, $unidadesAcademicas)) {
            return true;
        } else {
            return false;
        }
    }

    public function pasarANull($parametro) {

        if (trim($parametro) === '') {
            return NULL;
        } else {
            return $parametro;
        }
    }

    public function verificaUAPS($ua, $titulo) {
        $ua = strtoupper($ua);
        // MODIFICAR A MEDIDA QUE SE VAYA MIGRANDO
        if (($ua === 'CU-RA') || ($ua === 'CU-RS') ||
                ($ua === 'FADU' && $titulo === '2') ||
                ($ua === 'EUAA' && $titulo === '1') ||
                ($ua === 'FIQ' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FCA' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FCV' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FHUC' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'ESS' && $titulo === '1') ||
                ($ua === 'FICH' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FBCB' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FADU' && $titulo === '1') ||
                ($ua === 'FCJS' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'FCM' && $titulo === '1') ||
                ($ua === 'FCM' && $titulo === '2') ||
                ($ua === 'FCE' && in_array($titulo, ['1', '2'])) ||
                ($ua === 'ISM' && $titulo === '1')){
            // || ($ua === 'ESS') || ($ua === 'FCBC')) {
            return true;
        } else {
            return false;
        }
    }

    function validar_formato_fecha($fecha) {
        $valores = explode('/', $fecha);
        if (count($valores) != 3) {
            $valores = explode('-', $fecha);
            if (count($valores) == 3 && checkdate($valores[0], $valores[1], $valores[2])) {
                return true;
            }
        }
        if (count($valores) == 3 && checkdate($valores[0], $valores[1], $valores[2])) {
            return true;
        }
        return false;
    }

    function formato_fecha_g2($fecha) {

        $valores = explode('/', $fecha);
        $fechaG3 = $valores[1] . '/' . $valores[0] . '/' . $valores[2];
        return $fechaG3;
    }

    function formato_fecha_g3($fecha) {

        $valores = explode('/', $fecha);
        $fechaG3 = $valores[2] . '-' . $valores[0] . '-' . $valores[1];
        return $fechaG3;
    }

    public function basesPorUnidadAcademica($unidadAcademica, $tipoTitulo = 0) {

        if ($tipoTitulo == 0) {
            $tiposTitulos = self::recuperarTipoTituloConCemed($unidadAcademica);
        } else {
            $tiposTitulos = array($tipoTitulo);
        }

        $bases = array();

        for ($i = 0; $i < count($tiposTitulos); $i++) {
            $bases[] = self::recuperarDB($unidadAcademica, $tiposTitulos[$i]);
        }
        return array_values(array_unique($bases));
    }

    public function decodificador($valor, $instancia) {
        if ($instancia === 'g2') {
            return utf8_encode($valor);
        } else {
            return $valor;
        }
    }

    public function getUnidadAcademicaUsuario($usuario) {

        switch ($usuario) {
            case "extencionFich": $unidadAcademica = 'fich';
                break;
            case "siguv": $unidadAcademica = 'todas';
                break;
            case "bedeliamovil": $unidadAcademica = 'todas';
                break;
            case "hefesto": $unidadAcademica = 'todas';
                break;
            case "wsingreso": $unidadAcademica = 'todas';
                break;
            case "gea": $unidadAcademica = 'todas';
                break;
            case "telematica": $unidadAcademica = 'todas';
                break;
            case "moodlefich": $unidadAcademica = 'fich';
                break;
            case "fhuc": $unidadAcademica = 'fhuc';
                break;
            case "fce": $unidadAcademica = 'fce';
                break;
            case "sistemasfce": $unidadAcademica = 'fce';
                break;
            case "wswifi": $unidadAcademica = 'todas';
                break;
            case "electivas": $unidadAcademica = 'todas';
                break;
            case "comedor": $unidadAcademica = 'todas';
                break;
        }
        return $unidadAcademica;
    }

    public function obtenerTipoTitulo($db) {

        switch ($db) {
            case "alumnado": $tipoTitulo = "1";
                break;
            case "posgrado": $tipoTitulo = "2";
                break;
            case "semipre": $tipoTitulo = "3";
                break;
            case "convenios": $tipoTitulo = "4";
                break;
            case "escuela": $tipoTitulo = "5";
                break;
            case "cemed": $tipoTitulo = "6";
                break;
        }
        return $tipoTitulo;
    }

    public function logLlamada($nombre, $parametros, $loguear = false) {

        if ($loguear) {
            $cadena = "Parametros del servicio: ";
            $cantidad = count($parametros);
            $i = 1;
            foreach ($parametros as $key => $value) {
                if ($cantidad > $i)
                    $cadena .= $key . '= ' . $value . ', ';
                else
                    $cadena .= $key . '= ' . $value . ' ## ';
                $i++;
            }

            syslog(LOG_INFO, "## SERVICIO-WEB :   " . ($nombre) . " -- " . $cadena);
        }
    }
    
    function recodeG3aG2($requisito) {
        
        switch ($requisito) {
            case 912: $requisito = 'UNL01'; break;
            case 913: $requisito = 'UNL02'; break;
            case 916: $requisito = 'UNL04'; break;
            case 917: $requisito = 'UNL05'; break;
            case 918: $requisito = 'UNL06'; break;
            case 919: $requisito = 'UNL07'; break;
            case 920: $requisito = 'UNL14'; break;
            case 921: $requisito = 'UNL03'; break;
            case 923: $requisito = 'UNL08'; break;
            case 924: $requisito = 'UNL09'; break;
            case 925: $requisito = 'UNL10'; break;
            case 926: $requisito = 'UNL11'; break;
            case 927: $requisito = 'UNL12'; break;
            case 928: $requisito = 'UNL13'; break;
            case 929: $requisito = 'UNL15'; break;
            case 930: $requisito = 'UNL16'; break;
            case 931: $requisito = 'UNL17'; break;
            case 932: $requisito = 'UNL18'; break;
            case 933: $requisito = 'UNL19'; break;
            case 934: $requisito = 'POS01'; break;
            case 935: $requisito = 'POS02'; break;
            case 936: $requisito = 'POS03'; break;
            case 937: $requisito = 'POS04'; break;
            case 938: $requisito = 'POS05'; break;
            case 939: $requisito = 'POS08'; break;
            case 1019: $requisito = 'UNL20'; break;
            case 1020: $requisito = 'UNL21'; break;
            case 1021: $requisito = 'UNL22'; break;
        }
        return $requisito;
    }
    
    function code_tipo_de_actividad_G2aG3($tipo, $instancia)
    {
        if ($instancia !== 'g2') {
            return (string)$tipo;
        }
            
        switch ($tipo) {
            case 'C': $tipo = 'Materia';
                break;
            case 'U': $tipo = 'Curso';
                break;
            default: $tipo = null;
                break;
        }
        return $tipo;
    }
	
	function obtener_bases_g2_sin_distancia()
	{
		$bases = self::obtenerTodasUA();
		return(array_filter($bases, 'self::sinCEMED'));
	}
	
	function sinCEMED($base) {
		return (strncmp($base, "cemed_", 6) != 0 && strncmp($base, "guarani3_", 6) != 0 );
	}

}
?>
