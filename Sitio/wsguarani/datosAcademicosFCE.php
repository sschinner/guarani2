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

Class DatosAcademicos {
    /* --------- variables datosAcademicosCompletos---------- */
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $carreras = array();
    
}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS ACADEMICOS DE UN ALUMNO - ES INVOCADA POR FCE
  ---------------------------------------------------------------------------------------------- */

Class DatosCompletos {

    function datos($tipo, $documento,$unidadAcademica,$tipoTitulo) {

        $datosAcademicos = new DatosAcademicos();

        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $datosAcademicos->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $datosAcademicos->mensajeWS =MENSAJE_ERROR_AUTENTICACION;
            return $datosAcademicos;
        } else {
            if ($tipo == "" || $documento == "" || $unidadAcademica == "" || $tipoTitulo == "") {
                $datosAcademicos->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $datosAcademicos->codigoWS =CODIGO_ERROR_PARAMETROS;
                return $datosAcademicos;
            }

            
            $hayRegistro=false;
            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTitulo($unidadAcademica);
                $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }
            
            foreach ($titulos as $titulo) {
                
               /* $db = Generales::recuperarDB($unidadAcademica, $titulo);
                $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
                //$co = ('informix:host=guarani.intranet; service=9086;database=' . $db . '; server=rectorado_csm; protocol=olsoctcp; EnableScrollableCursors=1;');
                $objCC = Generales::conectar(true, $co);*/
                $db = Generales::recuperarDB($unidadAcademica, $titulo);
                $objCC = Generales::conectar($db);
                
                if ($objCC == 3) {
                    $datosAcademicos->codigoWS = CODIGO_ERROR_CONEXION;
                    $datosAcademicos->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $datosAcademicos;
                } else {
                    //realizo la consulta para ver si es alumno de la $UA
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;

                    $strSQL = "execute procedure web_serv_dat_acad_fce('" . $tipo . "','" . $documento . "');";
                    $res = $objCC->Execute($strSQL);
                           
                    
                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                       
                        $datosAcademicos->codigoWS = CODIGO_OK;
                        $datosAcademicos->mensajeWS = MENSAJE_OK;
                        $arreglo = array();
                        if ($resultado[0][0] == 0){
			     if(!$hayRegistro){
				$datosAcademicos->codigoRetorno = false; //$resu[0];
			     }
                            }else{
				  $hayRegistro=true;
				  $datosAcademicos->codigoRetorno = true;
				  foreach ($res as $resu) {
				      $arreglo['unidadAcademica'] = $resu[1];
				      $arreglo['carrera'] = $resu[2];
				      $arreglo['cantMatAprob'] = $resu[3];
				      $arreglo['cantMatReprob'] = $resu[4];
				      $arreglo['promedioAplazo'] = $resu[5];
				      $arreglo['promedioSinAplazo'] = $resu[6];
                                      $arreglo['calidadCarrera'] = $resu[7];
				      $datosAcademicos->carreras[] = $arreglo; 
				      
				  }
                        }
                    }
                } 
            }
             if ($datosAcademicos->codigoWS != "0") {
                $datosAcademicos->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $datosAcademicos->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $datosAcademicos;
            }
            return $datosAcademicos;
        }
    }

}

function datosAcademicosFCE($tipo, $documento,$unidadAcademica,$tipoTitulo) {
    $servicio = new DatosCompletos();
   
    $resultado = $servicio->datos($tipo, $documento,strtoupper($unidadAcademica),$tipoTitulo);
    return json_encode($resultado);
}

?>
