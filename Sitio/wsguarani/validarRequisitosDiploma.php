<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada o en el llamado a la función.
  ------------------------------------------------------------------------------------------ */

Class DatosValidarRequisitosDiplomaWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE VALIDA LOS REQUISITOS DE DIPLOMA Y ALMACENA LA URL DE LA FOTO
  ------------------------------------------------------------------------------------------------------------------- */

Class ValidarRequisitosDiplomaWS {

    function validar($ua, $tipo_doc, $nro_doc, $pais_documento, $solicitud, $requisitos_validados, $credenciales) {

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');
        
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $validacion->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $validacion->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $validacion;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $pais_documento == "" || $tipo_doc == "" || $nro_doc == "" || $solicitud == "" || $requisitos_validados == "") {
            $validacion->codigoWS = CODIGO_ERROR_PARAMETROS;
            $validacion->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $validacion;
        }
        
        $bases = Generales::basesPorUnidadAcademica($ua);
        $validacion->codigoWS = CODIGO_OK;
        $validacion->mensajeWS = MENSAJE_OK;
        
        $validado = false;
        foreach ($bases as $db) {
            
            $objCC = Generales::conectar($db);
            if ($objCC == '3') {
                $validacion->codigoWS = CODIGO_ERROR_CONEXION;
                $validacion->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $validacion;
            }

            // PASO 4: Desarrollo la funcion que necesito
            if (explode('_', $db)[0] != 'guarani3') {

//                $instancia = 'g2';
                $strSQL = "EXECUTE PROCEDURE ws_validar_req_diploma('" . $ua . "', '" . $pais_documento . "','" .
                        $tipo_doc . "','" . $nro_doc . "','" . $solicitud . "','" . $requisitos_validados . "');";

                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != "") {
                    $resul = $res->getRows();              
                    if ($resul[0][0] == 0) {                       
                        $validado = true;
                    }
                } else {                
                    $validacion->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $validacion->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $validacion;
                }
            } else {
                $rep = new RepositorioWS();
//                $instancia = 'g3';
                $resul = $rep->validarRequisitosDiploma($pais_documento, $tipo_doc, $nro_doc, $solicitud, $requisitos_validados, $objCC);
                
                if (empty($resul)) {
                    $validacion->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $validacion->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;          
                    return $validacion;
                }
                else {
                    if ($resul[0][0] == 0) {                 
                        $validado = true;
                    }
                }
            }
            
        }
        if ($validado) {
            $validacion->codigoRetorno = 0;
//            $validacion->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $resul[0][1]);
            $validacion->mensajeRetorno = 'OK - Se ha modificado el estado de validacion.';
        }
        else {
            $validacion->codigoRetorno = 1;
            $validacion->mensajeRetorno = 'No se ha modificado el estado de validacion.';
        }
        
        
        return $validacion;
    }

}

function validarRequisitosDiploma($ua, $tipo_doc, $nro_doc, $pais_documento, $solicitud, $requisitos_validados) {
    $servicio = new ValidarRequisitosDiplomaWS();
    $credenciales = new Credenciales(); 
    $resultado = $servicio->validar(strtoupper(trim($ua)), $tipo_doc, $nro_doc, $pais_documento, $solicitud, $requisitos_validados, $credenciales);
    
    return json_encode($resultado);
}

?>
