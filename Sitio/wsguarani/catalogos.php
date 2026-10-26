<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase?a invalidas.
  '2': Error de parametros - Algun campo es vacio o erroneo.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class DatosRetornoCatalogo {
    /* --------- variables datosAcademicosCompletos---------- */

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $catalogo = array();

    function getCodigoWS() {
        return $this->codigoWS;
    }

    function setCodigoWS($codigoWS) {
        $this->codigoWS = (int) $codigoWS;
    }

    function setMensajeWS($mensajeWS) {
        $this->mensajeWS = (string) $mensajeWS;
    }

    function setCodigoRetorno($codigoRetorno) {
        $this->codigoRetorno = (int) $codigoRetorno;
    }

    function setMensajeRetorno($mensajeRetorno) {
        $this->mensajeRetorno = (string) $mensajeRetorno;
    }

    function setCatalogo($catalogo) {
        // $catalogo =  new SplFixedArray(1000000);
        $this->catalogo[] = $catalogo;
    }

}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS ACADEMICOS DE UN ALUMNO - ES INVOCADA POR EL SISTEMA HEFESTO y KUNTUR
  ---------------------------------------------------------------------------------------------- */

Class DatosCatalogo {

    private $servidor = 'guarani2';

    function datos($filtro, $credenciales) {

        $catalogo = new DatosRetornoCatalogo();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'hefesto', 'extencionFich', 'siguv', 'gea');

        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $catalogo->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $catalogo->setMensajeWS(MENSAJE_ERROR_AUTENTICACION);
            $retorno = $catalogo;
            unset($catalogo);
            return $retorno;
        } else {
            if ($filtro == "") {
                $catalogo->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                $catalogo->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $catalogo;
                unset($catalogo);
                return $retorno;
            }

            $catalogo->setCodigoRetorno(-1);

            $conexion = ($this->servidor == 'guarani3') ? Generales::conectar('guarani3_') : Generales::conectar('cemed_fadu');
//            $ifxConnection = Generales::conectar('alumnado_fich');
//            $pgConnection = Generales::conectar('guarani3_');


            if ($conexion == '3') {
                $catalogo->setCodigoWS(CODIGO_ERROR_CONEXION);
                $catalogo->setMensajeWS(MENSAJE_ERROR_CONEXION);
                $retorno = $catalogo;
                unset($catalogo);
                return $retorno;
            } else {

                $data = new DatosTablas();
                switch ($filtro) {
                    case "colegiosSecundarios":
                        $datosColegios = $data->colegios_secundarios($conexion, $this->servidor);
                        return $datosColegios;
                    case "localidades":
                        $datosLocalidades = $data->localidades($conexion, $this->servidor);
                        return $datosLocalidades;
                    case "dpto_partidos":
                        $datosDptos = $data->dpto_partido($conexion, $this->servidor);
                        return $datosDptos;
                    case "provincias":
                        $datosProvincias = $data->provincias($conexion, $this->servidor);
                        return $datosProvincias;
                    case "paises":
                        $datosPaises = $data->paises($conexion, $this->servidor);
                        return $datosPaises;
                    default :
                        $catalogo->setMensajeWS(MENSAJE_OK);
                        $catalogo->setCodigoWS(CODIGO_OK);
                        $catalogo->setCodigoRetorno(-1);
                        $catalogo->setMensajeRetorno('No se encontro el filtro solicitado - Filtros disponibles: "colegiosSecundarios","localidades","dpto_partidos","provincias","paises" ');
                        return $catalogo;
                }
            }
        }
    }

}

function catalogos($filtro) {

    $servicio = new DatosCatalogo();
    $credenciales = new Credenciales();
    $resultado = $servicio->datos($filtro, $credenciales);
    $json = json_encode($resultado);
    // $base64 =  base64_encode($json);
    return $json;
}

Class DatosTablas {

    public function colegios_secundarios($conexion, $servidor) {

        $catalogo = new DatosRetornoCatalogo();

        if ($servidor != 'guarani3') {

            $sql = " SELECT colegio, nombre, localidad FROM sga_coleg_sec ; ";
            $prep = $conexion->execute($sql);

            if ($prep && ($prep->RecordCount() > 0)) {
                $resultadoG2 = $prep->getRows();
                if ($resultadoG2) {
                    $arreglo = array();
                    foreach ($resultadoG2 as $resu) {
                        $arreglo['codigo'] = (string) $resu[0];
                        $arreglo['nombre'] = (string) utf8_encode($resu[1]);
                        $arreglo['localidad'] = (string) $resu[2];
                        $catalogo->setCatalogo($arreglo);
                    }
                    $catalogo->setMensajeWS(MENSAJE_OK);
                    $catalogo->setCodigoWS(CODIGO_OK);
                }
            }
        } else {

            $sth = $conexion->prepare("SELECT  colegio, nombre, localidad FROM sga_colegios_secundarios ; ");
            $sth->execute();
            $resultadoG3 = $sth->fetchAll();


            if ($resultadoG3) {
                $arreglo = array();
                foreach ($resultadoG3 as $resu) {
                    $arreglo['codigo'] = (string) $resu[0];
                    $arreglo['nombre'] = (string) $resu[1];
                    $arreglo['localidad'] = (string) $resu[2];
                    $catalogo->setCatalogo($arreglo);
                }

                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
            }
        }

        if ($catalogo->getCodigoWS() == CODIGO_OK) {
            $catalogo->setCodigoRetorno(0);
            $catalogo->setMensajeRetorno('OK - Catalogo Colegios Secundarios');
            return $catalogo;
        }


        $catalogo->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $catalogo->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
        return $catalogo;
    }

    public function localidades($conexion, $servidor) {

        $catalogo = new DatosRetornoCatalogo();

        if ($servidor != 'guarani3') {

            $sql = " SELECT localidad, nombre, dpto_partido  FROM mug_localidades ; ";
            $prep = $conexion->execute($sql);

            if ($prep && ($prep->RecordCount() > 0)) {
                $resultadoG2 = $prep->getRows();

                if ($resultadoG2) {
                    $arreglo = array();
                    foreach ($resultadoG2 as $resu) {
                        $arreglo['localidad'] = (string) $resu[0];
                        $arreglo['nombre'] = (string) utf8_encode($resu[1]);
                        $arreglo['dpto_partido'] = (string) $resu[2];
                        $catalogo->setCatalogo($arreglo);
                    }
                    $catalogo->setMensajeWS(MENSAJE_OK);
                    $catalogo->setCodigoWS(CODIGO_OK);
                    $catalogo->setCodigoRetorno(0);
                    $catalogo->setMensajeRetorno('OK - Catalogo Localidades');
                    return $catalogo;
                }
            }
        } else {
            $sth = $conexion->prepare("SELECT  localidad, nombre, dpto_partido FROM mug_localidades  ;");

            $sth->execute(array());
            $resultadoG3 = $sth->fetchAll();


            if ($resultadoG3) {
                $arreglo = array();
                foreach ($resultadoG3 as $resu) {
                    $arreglo['localidad'] = (string) $resu[0];
                    $arreglo['nombre'] = (string) $resu[1];
                    $arreglo['dpto_partido'] = (string) $resu[2];
                    $catalogo->setCatalogo($arreglo);
                }

                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Localidades');
                return $catalogo;
            }
        }

        $catalogo->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $catalogo->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
        return $catalogo;
    }

    public function dpto_partido($conexion, $servidor) {

        if ($servidor != 'guarani3') {
            $catalogo = new DatosRetornoCatalogo();

            $sql = " SELECT dpto_partido, nombre, provincia  FROM mug_dptos_partidos ; ";
            $prep = $conexion->execute($sql);

            if ($prep && ($prep->RecordCount() > 0)) {
                $resultadoG2 = $prep->getRows();
                if ($resultadoG2) {
                    $arreglo = array();
                    foreach ($resultadoG2 as $resu) {
                        $arreglo['dpto_partido'] = (string) $resu[0];
                        $arreglo['nombre'] = (string)utf8_encode($resu[1]);
                        $arreglo['provincia'] = (string) $resu[2];
                        $catalogo->setCatalogo($arreglo);
                    }
                }
                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Dpto Partidos');
                return $catalogo;
            }
        } else {

            $sth = $conexion->prepare("SELECT  dpto_partido, nombre, provincia FROM dpto_partido ;");

            $sth->execute(array());
            $resultadoG3 = $sth->fetchAll();


            if ($resultadoG3) {
                $arreglo = array();
                foreach ($resultadoG3 as $resu) {
                    $arreglo['dpto_partido'] = (string) $resu[0];
                    $arreglo['nombre'] = (string) $resu[1];
                    $arreglo['provincia'] = (string) $resu[2];
                    $catalogo->setCatalogo($arreglo);
                }
            }
            $catalogo->setMensajeWS(MENSAJE_OK);
            $catalogo->setCodigoWS(CODIGO_OK);
            $catalogo->setCodigoRetorno(0);
            $catalogo->setMensajeRetorno('OK - Catalogo Dpto Partidos');
            return $catalogo;
        }

        $catalogo->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $catalogo->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
        return $catalogo;
    }

    public function provincias($conexion, $servidor) {

        $catalogo = new DatosRetornoCatalogo();
        if ($servidor != 'guarani3') {
            $sql = " SELECT provincia, nombre, pais  FROM mug_provincias ; ";
            $prep = $conexion->execute($sql);

            if ($prep && ($prep->RecordCount() > 0)) {
                $resultadoG2 = $prep->getRows();
                if ($resultadoG2) {
                    $arreglo = array();
                    foreach ($resultadoG2 as $resu) {
                        $arreglo['provincia'] = (string) $resu[0];
                        $arreglo['nombre'] = (string) utf8_encode($resu[1]);
                        $arreglo['pais'] = (string) $resu[2];
                        $catalogo->setCatalogo($arreglo);
                    }
                }
                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Provincias');
                return $catalogo;
            }
        } else {

            $sth = $conexion->prepare("SELECT  provincia, nombre, pais FROM mug_provincias ;");

            $sth->execute(array());
            $resultadoG3 = $sth->fetchAll();
            if ($resultadoG3) {
                $arreglo = array();
                foreach ($resultadoG3 as $resu) {
                    $arreglo['provincia'] = (string) $resu[0];
                    $arreglo['nombre'] = (string) $resu[1];
                    $arreglo['pais'] = (string) $resu[2];
                    $catalogo->setCatalogo($arreglo);
                }
                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Provincias');
                return $catalogo;
            }
        }
        $catalogo->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $catalogo->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
        return $catalogo;
    }

    public function paises($conexion, $servidor) {

        $catalogo = new DatosRetornoCatalogo();
        if ($servidor != 'guarani3') {
            $sql = " SELECT pais, nombre  FROM mug_paises ; ";
            $prep = $conexion->execute($sql);

            if ($prep && ($prep->RecordCount() > 0)) {
                $resultadoG2 = $prep->getRows();
                if ($resultadoG2) {
                    $arreglo = array();
                    foreach ($resultadoG2 as $resu) {
                        $arreglo['pais'] = (string) $resu[0];
                        $arreglo['nombre'] = (string) utf8_encode($resu[1]);
                        $catalogo->setCatalogo($arreglo);
                    }
                }
                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Paises');
                return $catalogo;
            }
        } else {

            $sth = $conexion->prepare("SELECT  pais, nombre FROM mug_paises ;");

            $sth->execute(array());
            $resultadoG3 = $sth->fetchAll();


            if ($resultadoG3) {
                $arreglo = array();
                foreach ($resultadoG3 as $resu) {
                    $arreglo['pais'] = (string) $resu[0];
                    $arreglo['nombre'] = (string) $resu[1];
                    $catalogo->setCatalogo($arreglo);
                }

                $catalogo->setMensajeWS(MENSAJE_OK);
                $catalogo->setCodigoWS(CODIGO_OK);
                $catalogo->setCodigoRetorno(0);
                $catalogo->setMensajeRetorno('OK - Catalogo Paises');
                return $catalogo;
            }
        }

        $catalogo->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $catalogo->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
        return $catalogo;
    }

}
