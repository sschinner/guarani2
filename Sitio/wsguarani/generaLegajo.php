<?php

//TODO: usar procedimiento sp_crear_alumno, posiblemente se cree un procedimiento, que llame a este, para la obtencion del nro_inscripcion
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

Class DatosLegajo {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno = '';

    // Variables Locales del procedimiento
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION que genera el legajo para un aspirante

 * ENTRADA: $ua, $tipotitulo,$anio_acad, $carrera, $pais_documento, $tipo_documento, $nro_documento
 * PROCEDIMIENTO INVOCADO: web_serv_genera_legajo ($ua, $anio_acad, $carrera, $pais_documento, $tipo_documento, $nro_documento)
 * SALIDA: 2 valores - propiedad [codigo] => 0, -1, -2;
 *         [mensajeRetorno] => Generado, No se pudo generar (mensaje personalizado), No es aspirante; Respectivamente.
  ------------------------------------------------------------------------------------------------------------------- */

Class Legajo {

    function generar($ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento, $validado,$credenciales) {

        $alumno = new DatosLegajo();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        // PASO 1: Autentico el usuario y password de webservices
        //$aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $alumno->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $alumno->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $alumno;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $pais_documento == "" || $tipo_documento == "" || $nro_documento == "") {
            $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
            $alumno->mensajeWS = MENSAJE_ERROR_PARAMETROS;            
            return $alumno;
        }

        // PASO 3: Conexion a informix
        
        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        
        if ($objCC == '3') {

            $alumno->codigoWS = CODIGO_ERROR_CONEXION;
            $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $alumno;
        } else if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {

            // PASO 4: Desarrollo la funcion que necesito

//            $strSQL = 'EXECUTE PROCEDURE web_serv_genera_legajo("' . $ua . '","' . $anio_acad . '","' . $carrera . '", "' . $pais_documento . '","' .
//                    $tipo_documento . '", "' . $nro_documento . '", "' . $validado . '");';
            
            $strSQL = 'EXECUTE PROCEDURE web_serv_genera_legajo("' . $ua . '","' . $carrera . '", "' . $pais_documento . '","' .
                    $tipo_documento . '", "' . $nro_documento . '", "' . $validado . '");';
            
            $res = $objCC->Execute($strSQL);

            if ($res->fields[1] != "" || $res->fields[0] != "") {
                $datos = $res->getRows();
                $alumno->codigoWS = CODIGO_OK;
                $alumno->mensajeWS = MENSAJE_OK;

                if ($datos[0][1] == '0') {
                    $alumno->mensajeRetorno = $datos[0][3] . " - " . utf8_decode($datos[0][0]);
                    $alumno->codigoRetorno = $datos[0][1];
                } else if ($datos[0][1] == '-1') {
                    $alumno->mensajeRetorno = $datos[0][3];
                    $alumno->codigoRetorno = $datos[0][1];
                } else if ($datos[0][1] == '-2') {
                    $alumno->mensajeRetorno = $datos[0][3];
                    $alumno->codigoRetorno = $datos[0][1];
                } else {
                    $alumno->mensajeRetorno = $datos[0][3];
                    $alumno->codigoRetorno = '4';
                }


                return $alumno;
            } else {
                $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $alumno;
            }
        } else {
            
            if ($validado === 'N') {
                $alumno->codigoWS = CODIGO_OK;
                $alumno->mensajeWS = MENSAJE_OK;
                $alumno->mensajeRetorno = "OK - Alumno " . $nro_documento . " en condiciones de cursar";
                $alumno->codigoRetorno = '0';
                return $alumno;
            } else if ($validado === 'S') {
                
                $rep = new RepositorioWS();
                $resultado = $rep->generaLegajoPostgres($carrera, $pais_documento, $tipo_documento, $nro_documento, $objCC);
                if (!empty($resultado)) {
                    $alumno->codigoWS = CODIGO_OK;
                    $alumno->mensajeWS = MENSAJE_OK;
                    if ($resultado[0][1] == '0') {
                        $alumno->mensajeRetorno = $resultado[0][2] . " - " . utf8_decode($resultado[0][0]);
                        $alumno->codigoRetorno = $resultado[0][1];
                    } else if ($resultado[0][1] == '-1') {
                       $alumno->mensajeRetorno = $resultado[0][2];
                        $alumno->codigoRetorno = $resultado[0][1];
                    } else if ($resultado[0][1] == '-2') {
                        $alumno->mensajeRetorno = $resultado[0][2];
                        $alumno->codigoRetorno = $resultado[0][1];
                    } else {
                        $alumno->mensajeRetorno = utf8_decode($resultado[0][2]);
                        $alumno->codigoRetorno = '4';
                    }
                    return $alumno;
                } else {
                    $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $alumno;
                }
            }
        }
    }

}

function generaLegajo($ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento, $validado,$credenciales) {
    $servicio = new Legajo();
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera,'pais_documento'=>$pais_documento, 'tipo_documento'=>$tipo_documento, 'nro_documento'=>$nro_documento, 'validado'=>$validado);
    Generales::logLlamada('generaLegajo', $parametros,true);
    $resultado = $servicio->generar(strtoupper(trim($ua)), $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento, $validado,$credenciales);
    return json_encode($resultado);
}
