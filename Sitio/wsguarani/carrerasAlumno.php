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

Class DatosRetornoCarreras {
    /* --------- variables datosAcademicosCompletos---------- */

    public $codigoWS = '';
    public $mensajeWS = '';
    public $codigoRetorno;
    public $mensajeRetorno;
    public $carreras = array();

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

    function setCarreras($carreras) {
        $this->carreras[] = $carreras;
    }

}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS ACADEMICOS DE UN ALUMNO - ES INVOCADA POR EL SISTEMA HEFESTO y KUNTUR
  ---------------------------------------------------------------------------------------------- */

Class DatosCarreras {

    function datos($nroDocumento, $tipoDocumento, $paisDocumento, $credenciales, $unidadAcademica) {
        $instancia = '';
        $datosCarreras = new DatosRetornoCarreras();


        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('gea');

        //$aut = Generales::autenticar();
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosCarreras->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $datosCarreras->setMensajeWS(MENSAJE_ERROR_AUTENTICACION);
            $retorno = $datosCarreras;
            unset($datosCarreras);
            return $retorno;
        }

        if ($tipoDocumento == "" || $nroDocumento == "" || $paisDocumento == "") {
            $datosCarreras->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
            $datosCarreras->setCodigoWS(CODIGO_ERROR_PARAMETROS);
            $retorno = $datosCarreras;
            unset($datosCarreras);
            return $retorno;
        }

        if ($unidadAcademica === '') {
            $ua = Generales::obtenerTodasUA();
        } else if (Generales::verificaUnidadAcademica($unidadAcademica)) {
            $ua = Generales::basesPorUnidadAcademica($unidadAcademica);
        } else {
            // Si no verifica unidad academica valida
            $datosCarreras->setMensajeWS(utf8_encode("Error de parametros - Unidad Acad�mica " . $unidadAcademica . " inexistente - Verifique"));
            $datosCarreras->setCodigoWS(CODIGO_ERROR_PARAMETROS);
            $retorno = $datosCarreras;
            unset($datosCarreras);
            return $retorno;
        }

        // Por defecto, mensaje de no encontrado
        $titulo = '';
        $datosCarreras->setMensajeRetorno('No hay datos - Tipo ' . $tipoDocumento . '  Documento ' . $nroDocumento . ' y Pais ' . $paisDocumento . ' inexistente');
        $datosCarreras->setCodigoRetorno(-1);

        // Recorro las bases. G2 y G3
        for ($j = 0; $j < count($ua); $j++) {
            $arreglo['unidadAcademica'] = $arreglo['carrera'] = $arreglo['nombreCarrera'] = $arreglo['calidadAlu'] = $arreglo['tipoIngreso'] = $arreglo['descrcipcionTipoIngreso'] = $arreglo['tipoCarrera'] = $arreglo['descripcionTipoCarrera'] = $arreglo['tipoTitulo'] = '';
            $resultado = '';
            $esCemed = explode('_', $ua[$j]);

            if ($esCemed[0] == 'guarani3' || $unidadAcademica === 'CU-RA') {
                $titulo = '7';

                $objCC = Generales::conectar($ua[$j]);
            } else {

                $objCC = Generales::conectar($ua[$j]);

                switch ($esCemed[0]) {
                    case "alumnado": $titulo = 1;
                        break;
                    case "posgrado": $titulo = 2;
                        break;
                    case "semipre": $titulo = 3;
                        break;
                    case "cemed": $titulo = 6;
                        break;
                    case "convenios": $titulo = 4;
                        break;
                    case "escula": $titulo = 5;
                        break;
                    default: $titulo = '0';
                }
            }

            if ($objCC == 3) {
                $datosCarreras->setCodigoWS(CODIGO_ERROR_CONEXION);
                $datosCarreras->setMensajeWS(MENSAJE_ERROR_CONEXION);
                $arreglo['unidadAcademica'] = (string) $ua[$j] . " Problemas para conectar - Consulte con el administrador";
                $datosCarreras->setCarreras($arreglo);
            }
            
            // Guarani 2
            elseif ($titulo != '7') {
                //realizo la consulta para ver si es alumno de la $UA
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $instancia = 'g2';
                $strSQL = "execute procedure 'dba'.web_serv_carreras_alumno('" . $nroDocumento . "','" . $tipoDocumento . "','" . $paisDocumento . "');";

                $res = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($res && ($res->RecordCount() > 0)) {
                    $resultado = $res->getRows();

                    if ($resultado) {
                        $datosCarreras->setCodigoWS(CODIGO_OK);
                        $datosCarreras->setMensajeWS(MENSAJE_OK);
                    }
                }
            }

            // Guarani 3
            else {
                $datosCarreras->setCodigoWS(CODIGO_OK);
                $datosCarreras->setMensajeWS(MENSAJE_OK);
                if ($unidadAcademica == 'FADU') {// Identificamos y devolvemos el verdadero tipoTitulo (GRADO, POSGRADO, SEMI), hoy son estas dos que G3
                    $titulo = '2';
                } else {
                    $titulo = '1';
                }
                $instancia = '';
                $rep = new RepositorioWS();
                $resultado = $rep->obtenerCarrerasAlumno($nroDocumento, $tipoDocumento, $paisDocumento, $objCC);
            }

            if ($resultado) {

                $arreglo = array();

                foreach ($resultado as $resu) {
                    if (trim($resu[0]) !== '') {
                        $datosCarreras->setMensajeRetorno(utf8_encode('OK - Datos Carreras Alumno'));
                        $datosCarreras->setCodigoRetorno(0);
                        $arreglo['unidadAcademica'] = (string) ($resu[1] == 'CU-G') ? 'EUAA' : $resu[0];
                        $arreglo['carrera'] = (string) $resu[1];
                        $arreglo['nombreCarrera'] = (string) Generales::decodificador($resu[2], $instancia);
                        $arreglo['calidadAlu'] = (string) $resu[3];
                        $arreglo['tipoIngreso'] = $resu[4];
                        $arreglo['descrcipcionTipoIngreso'] = $resu[5];
                        $arreglo['tipoTitulo'] = ($esCemed[0] != 'guarani3' ) ? (int) $titulo : $resu[8];
                        $datosCarreras->setCarreras($arreglo);
                    }
                }
            }
        }

        if ($datosCarreras->getCodigoWS() === '') {
            $datosCarreras->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
            $datosCarreras->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);

            $retorno = $datosCarreras;
            unset($datosCarreras);
            return $retorno;
        }

        $retorno = $datosCarreras;
        unset($datosCarreras);
        return $retorno;
    }

}

function carrerasAlumno($nroDocumento, $tipoDocumento, $paisDocumento, $unidadAcademica = '') {
    $servicio = new DatosCarreras();
    $credenciales = new Credenciales();
    $parametros = array('nroDocumento'=> $nroDocumento,'tipoDocumento'=> $tipoDocumento,'paisDocumento'=> $paisDocumento,'unidadAcademica'=> $unidadAcademica);
    Generales::logLlamada('carrerasAlumno', $parametros, false);
    
    $resultado = $servicio->datos($nroDocumento,$tipoDocumento, $paisDocumento, $credenciales,strtoupper(trim($unidadAcademica)));
    return json_encode($resultado);
}

?>
