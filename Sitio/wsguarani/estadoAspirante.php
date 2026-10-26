<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio o erroneo.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class EstadoAspirante {

    public $codigoWS;
    public $mensajeWS;
    /* public $codigoRetorno;
    public $mensajeRetorno; */
    public $requisitos = array();
    public $cursosIngreso = array();

}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE EL ESTADO EN QUE SE ENCUENTRA EN ASPIRANTE/ALUMNO Y SUS REQUISITOS PRESENTADOS
  ---------------------------------------------------------------------------------------------- */

Class DatosEstadoAspirante {

    function datos($unidadAcademica, $tipoTitulo, $carrera, $tipo, $documento,$credenciales) {

        $datosAspirante = new EstadoAspirante();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        //$aut = Generales::autenticar();

        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosAspirante->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datosAspirante->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $datosAspirante;
        } 

        if ($tipo == "" || $documento == "" || $unidadAcademica == "" || $tipoTitulo == "" || $carrera == "") {
            $datosAspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            $datosAspirante->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosAspirante;        }
            
        if (!Generales::verificaUnidadAcademica($unidadAcademica)) {
            $datosAspirante->mensajeWS = utf8_encode("Error de parametros - Unidad Académica " . $unidadAcademica . " inexistente - Verifique");
            $datosAspirante->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosAspirante;
        }

        if ($tipoTitulo == 0) {
            $titulos = Generales::recuperarTipoTituloConCemed($unidadAcademica);
        } else {
            $titulos = array($tipoTitulo);
        }
            
        foreach ($titulos as $titulo) {

            $db = Generales::recuperarDB($unidadAcademica, $titulo);
            $objCC = Generales::conectar($db);
            
            if ($objCC == '3') {
                $datosAspirante->codigoWS = CODIGO_ERROR_CONEXION;
                $datosAspirante->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $datosAspirante;
            } 

            if (($titulo != '7') && (!Generales::verificaUAPS($unidadAcademica, $titulo))) {
                /**
                *  Realizo la consulta en Informix
                */
                $datosAspirante->codigoWS = CODIGO_OK;
                $datosAspirante->mensajeWS = MENSAJE_OK;

                $strSQL2 = "execute procedure web_service_requisitos_ingreso('" . $tipo . "','" . $documento . "','" . $carrera . "');";
                $resultado2 = $objCC->Execute($strSQL2);
                                              
                if ($resultado2) {

                    $arreglo = array();
                    $resultado = $resultado2->getRows();
                            
                    foreach ($resultado as $resu) {
                        $arreglo['requisito'] = $resu[0];
                        $arreglo['nombre'] = iconv("ISO-8859-1", "utf-8", $resu[1]);
                        $arreglo['fecha'] = $resu[2];
                        $arreglo['exceptuado'] = $resu[3];
                        $datosAspirante->requisitos[] = $arreglo;
                    }
                }
                        
                $strSQL3 = "execute procedure web_service_cursos_ingreso('" . $tipo . "','" . $documento . "','" . $carrera . "');";
                $resultado3 = $objCC->Execute($strSQL3);
                
                if ($resultado3) {

                    $arreglo = array();
                    $resultado = $resultado3->getRows();
                                                        
                    foreach ($resultado as $resu) {
                        $arreglo['curso'] = $resu[0];
                        $arreglo['nombre'] = iconv("ISO-8859-1", "utf-8", $resu[1]);
                        $arreglo['fecha'] = $resu[2];
                        $arreglo['nota'] = $resu[3];
                        $arreglo['forma_aprobacion'] = $resu[4];
                        $arreglo['id_curso_bienestar'] = null;
                        $datosAspirante->cursosIngreso[] = $arreglo;
                    }
                } 
            } else {
                /**
                *  Realizo la consulta en Postgres 
                */
                $rep = new RepositorioWS();
                    
                $datosAspirante->codigoWS = CODIGO_OK;
                $datosAspirante->mensajeWS = MENSAJE_OK;
                        
                $resultado2 = $rep->obtenerRequisitosAspirante($tipo, $documento, $carrera, $objCC);

                if (!empty($resultado2)) {
                    $arreglo = array();
                            
                    foreach ($resultado2 as $resu) {
                        $arreglo['requisito'] = (string)$resu[0];
                        $arreglo['nombre'] = $resu[1];
                        $arreglo['fecha'] = $resu[2];
                        $arreglo['exceptuado'] = $resu[3];
                        $datosAspirante->requisitos[] = $arreglo;
                    }
                } 
                        
                $resultado3 = $rep->obtenerCursosIngreso($tipo, $documento, $carrera, $objCC);
                
                if (!empty($resultado3)) {
                    $arreglo = array();
                            
                    foreach ($resultado3 as $resu) {
                        $arreglo['curso'] = $resu[0];
                        $arreglo['nombre'] = $resu[1];
                        $arreglo['fecha'] = $resu[2];
                        $arreglo['nota'] = $resu[3];
                        $arreglo['forma_aprobacion'] = $resu[4];
                        $arreglo['id_curso_bienestar'] = null;
                        $datosAspirante->cursosIngreso[] = $arreglo;
                    }
                }
            }
        }
        
        return $datosAspirante;
        
    }

}

function estadoAspirante($unidad_academica, $tipoTitulo, $carrera, $tipo_documento, $nro_documento) {
    $servicio = new DatosEstadoAspirante();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=>$unidad_academica, 'tipotitulo'=>$tipoTitulo,'carrera'=>$carrera, 'tipo_documento'=>$tipo_documento, 'nro_documento'=>$nro_documento );
    Generales::logLlamada('estadoAspirante', $parametros, false);
    
    $resultado = $servicio->datos(strtoupper(trim($unidad_academica)), $tipoTitulo, $carrera, $tipo_documento, $nro_documento,$credenciales);
    return json_encode($resultado);
}

?>
