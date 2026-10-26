<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class DatosMateriaCarrera {
    /* --------- variables datosAcademicosCompletos---------- */

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $materias = array();

}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS ACADEMICOS DE UN ALUMNO - ES INVOCADA POR EL SISTEMA HEFESTO y KUNTUR
  ---------------------------------------------------------------------------------------------- */

Class DatosMateriaPlan {

    function datos($ua, $tipoTitulo, $carrera, $plan, $version, $credenciales) {

        $datosCarreraMateria = new DatosMateriaCarrera();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('fhuc', 'hefesto', 'extencionFich', 'electivas', 'bedeliamovil');

        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosCarreraMateria->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datosCarreraMateria->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            $retorno = $datosCarreraMateria;
            unset($datosCarreraMateria);
            return $retorno;
        } else {
            if ($ua == "" || $tipoTitulo == "" || $carrera == "" || $plan == "" || $version == "") {
                $datosCarreraMateria->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $datosCarreraMateria->codigoWS = CODIGO_ERROR_PARAMETROS;
                $retorno = $datosCarreraMateria;
                unset($datosCarreraMateria);
                return $retorno;
            }

            $unidadAcademicaPermitida = Generales::getUnidadAcademicaUsuario($_SERVER['PHP_AUTH_USER']);

            if (strtoupper($unidadAcademicaPermitida) != $ua && $unidadAcademicaPermitida != 'todas') {
                $datosCarreraMateria->mensajeWS = MENSAJE_OK;
                $datosCarreraMateria->codigoWS = CODIGO_OK;
                $datosCarreraMateria->mensajeRetorno = utf8_encode('No posee permisos para consultar datos de la unidad académica ' . $ua);
                $datosCarreraMateria->codigoRetorno = false;
                return $datosCarreraMateria;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                // $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $datosCarreraMateria->codigoWS = CODIGO_ERROR_CONEXION;
                    $datosCarreraMateria->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $datosCarreraMateria;
                } else if (($titulo != '7') && (!Generales::verificaUAPS(ucwords($ua), $titulo))) {
                    /**
                     *  Realizo la consulta en Informix para obtener los datos censales 
                     */
                    $strSQL = "execute procedure web_serv_materias_carrera ('" . $carrera . "', '" . $plan . "', '" . $version . "');";
                    $instancia = 'g2';
                    $res = $objCC->Execute($strSQL);
                    $datosCarreraMateria->codigoWS = CODIGO_OK;
                    $datosCarreraMateria->mensajeWS = MENSAJE_OK;
                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $datosCarreraMateria->codigoRetorno = true;
                    } else {
                        $datosCarreraMateria->codigoRetorno = false;
                    }
                } else {
                    /**
                     *  Realizo la consulta en Postgres para obtener los datos censales 
                     */
                    $rep = new RepositorioWS();
                    $resultado = $rep->obtenerDatosMateriaCarreraPlan($carrera, $plan, $version, $objCC);
                    $instancia = 'g3';
                    $datosCarreraMateria->codigoWS = CODIGO_OK;
                    $datosCarreraMateria->mensajeWS = MENSAJE_OK;
                    if (!empty($resultado)) {
                        $datosCarreraMateria->codigoRetorno = true;
                    } else {
                        $datosCarreraMateria->codigoRetorno = false;
                    }
                }
                if ($datosCarreraMateria->codigoRetorno) {
                    $arreglo = array();

                    foreach ($resultado as $resu) {
                        $arreglo['codigoMateria'] = $resu[0];
                        $arreglo['nombreMateria'] = (string) Generales::decodificador($resu[1], $instancia);
                        $arreglo['tipoMateria'] = $resu[2];
                        $arreglo['horasSemanales'] = $resu[3];
                        $arreglo['cargaHoraria'] = $resu[4];
                        $arreglo['valorMateria'] = $resu[5];
                        $arreglo['promediable'] = $resu[6];
                        $arreglo['obligatoria'] = $resu[7];
                        $arreglo['anioCursada'] = $resu[8];
                        $arreglo['periodoCursada'] = $resu[9];
                        $arreglo['tipoCursada'] = $resu[10];
                        $datosCarreraMateria->materias[] = $arreglo;
                    }
                }
            }
            if (!empty($datosCarreraMateria->materias)) {
                $datosCarreraMateria->codigoRetorno = true;
                $datosCarreraMateria->mensajeRetorno = 'OK - Datos Materias-Carrera-Plan';
            } else {
                $datosCarreraMateria->codigoRetorno = false;
                $datosCarreraMateria->mensajeRetorno = 'No existe datos para la carrera-plan-versión solicitado';
            }
            return $datosCarreraMateria;
        }
    }

}

function materiasCarreraPlan($ua, $tipoTitulo, $carrera, $plan, $version) {
    $servicio = new DatosMateriaPlan();
    $credenciales = new Credenciales();
    $parametros = array('ua' => $ua, 'tipoTitulo' => $tipoTitulo, 'carrera' => $carrera, 'plan' => $plan, 'version' => $version);
    Generales::logLlamada('materiasCarreraPlan', $parametros, false);

    $resultado = $servicio->datos($ua, $tipoTitulo, $carrera, $plan, $version, $credenciales);
    return json_encode($resultado);
}

?>
