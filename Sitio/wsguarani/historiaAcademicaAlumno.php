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

Class DatosRetornoHistoria {

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $historia = array();

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

    function setHistoria($datos) {
        $this->historia[] = $datos;
    }

}

/* ---------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------- */

Class HistoriaAcademica {

    function datos($carrera, $tipo, $documento, $pais, $unidadAcademica, $tipoTitulo, $credenciales) {
        $instancia = '';
        $historiaAcademica = new DatosRetornoHistoria();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('gea', 'wsingreso', 'hefesto');

        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $historiaAcademica->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $historiaAcademica->setMensajeWS(utf8_encode(MENSAJE_ERROR_AUTENTICACION));
            $retorno = $historiaAcademica;
            unset($historiaAcademica);
            return $retorno;
        } else {
            if ($tipo == "" || $documento == "" || $pais == "" ||
                    $unidadAcademica == "" || $tipoTitulo == "") {
                $historiaAcademica->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                $historiaAcademica->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $historiaAcademica;
                unset($historiaAcademica);
                return $retorno;
            }

            if (Generales::verificaUnidadAcademica($unidadAcademica)) {
                if ($tipoTitulo == 0) {
                    $titulos = Generales::recuperarTipoTituloConCemed($unidadAcademica);
                } else {
                    $titulos = array($tipoTitulo);
                }
            } else {
                $historiaAcademica->setMensajeWS(utf8_encode("Error de parametros - Unidad Acad�mica " . $unidadAcademica . " inexistente - Verifique"));
                $historiaAcademica->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $retorno = $historiaAcademica;
                unset($historiaAcademica);
                return $retorno;
            }

            $historiaAcademica->setMensajeRetorno('No hay datos para Tipo ' . $tipo . '  Documento ' . $documento . ', Pais ' . $pais . ' y Carrera ' . $carrera );
            $historiaAcademica->setCodigoRetorno(-1);

            foreach ($titulos as $titulo) {
                $resultado = '';
                $db = Generales::recuperarDB($unidadAcademica, $titulo);
                $objCC = Generales::conectar($db);

                if ($objCC == 3) {
                    $historiaAcademica->setCodigoWS(CODIGO_ERROR_CONEXION);
                    $historiaAcademica->setMensajeWS(MENSAJE_ERROR_CONEXION);
                    $retorno = $historiaAcademica;
                    unset($historiaAcademica);
                    return $retorno;
                } else if (($titulo != '7') && (!Generales::verificaUAPS($unidadAcademica, $titulo))) {

                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $instancia = 'g2';
                    $strSQL = "execute procedure 'dba'.web_service_historia_academica_alumno('" . $carrera . "','" . $tipo . "','" . $documento . "','" . $pais . "');";
                    $res = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($res && ($res->RecordCount() > 0)) {
                        $resultado = $res->getRows();
                        if ($resultado) {
                            $historiaAcademica->setCodigoWS(CODIGO_OK);
                            $historiaAcademica->setMensajeWS(MENSAJE_OK);
                        }
                    }
                } else {
                    $instancia = '';
                    $historiaAcademica->setCodigoWS(CODIGO_OK);
                    $historiaAcademica->setMensajeWS(MENSAJE_OK);
                    $rep = new RepositorioWS();
                    $resultado = $rep->obtenerHistoriaAcademicaAlumno($carrera, $tipo, $documento, $pais,$unidadAcademica, $objCC);
                }

                if ($resultado) {

                    $arreglo = array();
                    
                    foreach ($resultado as $resu) {

                        // Si el codigo de retorno es distinto a error
                        if ((string)$resu[10] != '-1') { 
                            $historiaAcademica->setMensajeRetorno(Generales::decodificador($resu[12], $instancia));
                            $historiaAcademica->setCodigoRetorno($resu[11]);
                        }
                                                
                        if (trim($resu[1]) !== '') {
                            $arreglo['materia'] = (string) $resu[0];
                            $arreglo['nombreMateria'] = (string) Generales::decodificador($resu[1], $instancia);
                            $arreglo['fecha'] = (string) $resu[2];
                            $arreglo['nota'] = (string) $resu[3];
                            if ($resu[4] === 'A') {
                                $resultadoNota = 'Aprobado';
                            } else if ($resu[4] === 'R') {
                                $resultadoNota = 'Reprobado';
                            } else {
                                $resultadoNota = 'Ausente';
                            }
                            $arreglo['resultado'] = (string) $resultadoNota;
                            $arreglo['acta'] = (string) $resu[5];
                            $arreglo['tipoActa'] = (string) ($resu[6] === 'N') ? 'Normal' : 'Rectificada';
                            $arreglo['tipoExamen'] = (string) Generales::decodificador($resu[7], $instancia);
                            ;
                            $arreglo['nroResolucion'] = (string) $resu[8];
                            $arreglo['tipoMateria'] = (string) Generales::decodificador($resu[9], $instancia);
                            $arreglo['entidadSubtipo'] = Generales::code_tipo_de_actividad_G2aG3($resu[10], $instancia);
                            ;
                            $historiaAcademica->setHistoria($arreglo);
                        }
                    }
                }
            }
        }
        if ($historiaAcademica->getCodigoWS() !== 0) {
            $historiaAcademica->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
            $historiaAcademica->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);

            $retorno = $historiaAcademica;
            unset($historiaAcademica);
            return $retorno;
        }

        $retorno = $historiaAcademica;
        unset($historiaAcademica);
        return $retorno;
    }

}

function historiaAcademicaAlumno($carrera, $tipo, $documento, $pais, $unidadAcademica, $tipoTitulo = 0) {
    $servicio = new HistoriaAcademica();
    $credenciales = new Credenciales();
    $parametros = array('carrera'=>$carrera, 'tipo_documento'=>$tipo, 'nro_documento'=>$documento,'pais_documento'=>$pais,'unidadAcademica'=>$unidadAcademica, 'tipotitulo'=>$tipoTitulo );
    Generales::logLlamada('historiaAcademicaAlumno', $parametros, false);
    
    $resultado = $servicio->datos($carrera, $tipo, $documento, $pais, strtoupper(trim($unidadAcademica)), $tipoTitulo, $credenciales);
    return json_encode($resultado);
}

?>
