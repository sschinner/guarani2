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

Class DatosRetorno {
    /* --------- variables datosAcademicosCompletos---------- */

    public $codigoWS;
    public $mensajeWS;
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

Class DatosRendimiento {

    function datos($tipo, $documento, $pais, $unidadAcademica, $credenciales) {
        $instancia = '';
        $datosAcademicos = new DatosRetorno();


        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'hefesto', 'extencionFich', 'siguv','gea', 'sistemasfce');

        //$aut = Generales::autenticar();
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosAcademicos->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $datosAcademicos->setMensajeWS(MENSAJE_ERROR_AUTENTICACION);
            $retorno = $datosAcademicos;
            unset($datosAcademicos);
            return $retorno;
        } else {
            if ($tipo == "" || $documento == "" || $pais == "") {
                $datosAcademicos->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                $datosAcademicos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $datosAcademicos;
                unset($datosAcademicos);
                return $retorno;
            }
            
            $unidadAcademicaPermitida = Generales::getUnidadAcademicaUsuario($_SERVER['PHP_AUTH_USER']);

            if (strtoupper($unidadAcademicaPermitida) != $unidadAcademica && $unidadAcademicaPermitida != 'todas') {
                $datosAcademicos->mensajeWS = MENSAJE_OK;
                $datosAcademicos->codigoWS = CODIGO_OK;
                $datosAcademicoscarreras->mensajeRetorno = utf8_encode('No posee permisos para consultar datos de la unidad académica ' . $unidadAcademica);
                $datosAcademicos->codigoRetorno = '-5';
                return $datosAcademicos;
            }

            if ($unidadAcademica === '') {
                $ua = Generales::obtenerTodasUA();
            } else if (Generales::verificaUnidadAcademica($unidadAcademica)) {
                $ua = Generales::basesPorUnidadAcademica($unidadAcademica);
            } else {
                $datosAcademicos->setMensajeWS(utf8_encode("Error de parametros - Unidad Acad�mica " . $unidadAcademica . " inexistente - Verifique"));
                $datosAcademicos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $datosAcademicos;
                unset($datosAcademicos);
                return $retorno;
            }
           
            $titulo = '';
            $datosAcademicos->setMensajeRetorno('No hay datos - Tipo ' . $tipo . '  Documento ' . $documento . ' y Pais ' . $pais . ' inexistente');
            $datosAcademicos->setCodigoRetorno(-1);

            for ($j = 0; $j < count($ua); $j++) {
                $resultado = '';
                $esCemed = explode('_', $ua[$j]);

                if ($esCemed[0] == 'guarani3' || $unidadAcademica === 'CU-RA') {
                    $titulo = '7';
                   
                    $objCC = Generales::conectar($ua[$j]);
                    
                } else {
                    $titulo = '0';
                   
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
                    }
                }

                if ($objCC == '3') {
                    $datosAcademicos->setCodigoWS(CODIGO_ERROR_CONEXION);
                    $datosAcademicos->setMensajeWS(MENSAJE_ERROR_CONEXION);
                    $arreglo['unidadAcademica'] = (string) $ua[$j] ." Problemas para conectar - Consulte con el administrador";
                    $datosAcademicos->setCarreras($arreglo);
                   
                } else if ($titulo != '7') {
                    //realizo la consulta para ver si es alumno de la $UA
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $instancia = 'g2';
                    $strSQL = "execute procedure 'dba'.web_service_rendimiento_acad('" . $tipo . "','" . $documento . "','" . $pais . "');";
                    $res = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($res && ($res->RecordCount() > 0)) {
                        $resultado = $res->getRows();

                        if ($resultado) {
                            $datosAcademicos->setCodigoWS(CODIGO_OK);
                            $datosAcademicos->setMensajeWS(MENSAJE_OK);
                        }
                    }
                } else {
                    $datosAcademicos->setCodigoWS(CODIGO_OK);
                    $datosAcademicos->setMensajeWS(MENSAJE_OK);
                    if($unidadAcademica == 'FADU'){// Identificamos y devolvemos el verdadero tipoTitulo (GRADO, POSGRADO, SEMI), hoy son estas dos que G3
                        $titulo = '2';
                    }else{
                        $titulo = '1';
                    }
                    $instancia = '';
                    $rep = new RepositorioWS();
                    $resultado = $rep->obtenerRendimientoAcademico($tipo, $documento, $pais, $objCC);
                }

                if ($resultado) {

                    $arreglo = array();

                    foreach ($resultado as $resu) {
                        if (trim($resu[2]) !== '') {
                            $datosAcademicos->setMensajeRetorno(utf8_encode('OK - Datos Rendimiento Académico'));
                            $datosAcademicos->setCodigoRetorno(0);
                            $arreglo['unidadAcademica'] = (string) (($resu[1] == 'CU-G')?'EUAA':(($resu[1] == 'ECM')?'FCM':$resu[1]));
                            $arreglo['carrera'] = (string) $resu[2];
                            $arreglo['calidadAlu'] = (string) $resu[3];
                            $arreglo['fechaIngreso'] = $resu[4];
                            $arreglo['fechaEgreso'] = $resu[5];
                            $arreglo['cantMatAprob'] = (int) $resu[6];
                            $arreglo['cantMatReprob'] = (int) $resu[10];
                            $arreglo['cantMatPlan'] = (int) $resu[7];
                            $arreglo['promedioAplazo'] = (float) $resu[8];
                            $arreglo['promedioSinAplazo'] = (float) $resu[9];
                            $arreglo['nombreCarrera'] = (string) Generales::decodificador($resu[11],$instancia);
                            $arreglo['regular'] = (string) $resu[13];
                            $arreglo['descripcionCalidad'] = (string) Generales::decodificador($resu[12],$instancia);
                            $arreglo['nombreTitulo'] = (string) Generales::decodificador($resu[14],$instancia);
                            $arreglo['egresado'] = ((int) $resu[15] === 1) ? TRUE : FALSE;
                            $arreglo['tipoTitulo'] = ($esCemed[0] != 'guarani3' )?(int) $titulo:$resu[16];
                            $datosAcademicos->setCarreras($arreglo);

//                            $datosAcademicos->setMensajeRetorno($resu[14]);
//                            $datosAcademicos->setCodigoRetorno($resu[0]);
                        }
                    }
                }
            }
        }
        if ($datosAcademicos->getCodigoWS() !== 0) {
            $datosAcademicos->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
            $datosAcademicos->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);

            $retorno = $datosAcademicos;
            unset($datosAcademicos);
            return $retorno;
        }

        $retorno = $datosAcademicos;
        unset($datosAcademicos);
        return $retorno;
    }

}

function rendimientoAcademico($tipo, $documento, $pais, $unidad_academica = '') {
    $servicio = new DatosRendimiento();
    $credenciales = new Credenciales();
    $parametros = array('tipo' =>$tipo, 'documento' =>$documento,'pais' =>$pais, 'unidad_academica' =>$unidad_academica);
    Generales::logLlamada('rendimientoAcademico', $parametros, false);
                        
    $resultado = $servicio->datos($tipo, $documento, $pais, strtoupper(trim($unidad_academica)), $credenciales);
    return json_encode($resultado);
}

?>
