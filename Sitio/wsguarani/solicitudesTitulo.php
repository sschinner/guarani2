<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

class DatosSolicitudes {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $solicitudes = array();

}

class SolicitudesTitulo {

    function verificar($ua, $pais_documento, $tipo_documento, $nro_documento, $credenciales) {

        $alumno = new DatosSolicitudes();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $alumno->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $alumno->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $alumno;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $pais_documento == "" || $tipo_documento == "" || $nro_documento == "") {
            $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
            $alumno->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $alumno;
        }

        $bases = Generales::basesPorUnidadAcademica($ua);
        $arreglo = array();

        foreach ($bases as $db) {

            $objCC = Generales::conectar($db);
            if ($objCC == '3') {

                $alumno->codigoWS = CODIGO_ERROR_CONEXION;
                $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $alumno;
            }

            // PASO 4: Ejecuto funciones
            if (explode('_', $db)[0] != 'guarani3') {
                
                /**
                ************** INFORMIX **************
                */

                $strSQL = 'EXECUTE PROCEDURE ws_solicitudes_titulo("' . $pais_documento . '","' .
                        $tipo_documento . '", "' . $nro_documento . '");';

                $res = $objCC->Execute($strSQL);
                $resultado = $res->getRows();
                $instancia = 'g2';

                if ($resultado[0][0] == -4) {
                    $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $alumno;
                }
            } else {

                /**
                ************** POSTGRES **************
                */
                
                $rep = new RepositorioWS();
                $resultado = $rep->solicitudesTitulo($pais_documento, $tipo_documento, $nro_documento, $objCC);
                $instancia = '';
                
                if ($resultado[0]['solicitud'] == -4) {
                    $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $alumno;
                }
            }

            if (!empty($resultado)) {

                foreach ($resultado as $resu) {

                    $arreglo['solicitud'] = $resu[0];
                    $arreglo['nombreTitulo'] = (string) Generales::decodificador($resu[1], $instancia);
                    $alumno->solicitudes[] = $arreglo;
                }
            }
            $alumno->codigoWS = CODIGO_OK;
            $alumno->mensajeWS = MENSAJE_OK;
        }
        
        return $alumno;
    }

}

function solicitudesTitulo($ua, $pais_documento, $tipo_documento, $nro_documento) {
    $servicio = new SolicitudesTitulo();
    $credenciales = new Credenciales();
    $resultado = $servicio->verificar(strtoupper(trim($ua)), $pais_documento, $tipo_documento, $nro_documento, $credenciales);
    return json_encode($resultado);
}
