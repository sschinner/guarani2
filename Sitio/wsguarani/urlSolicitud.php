<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

class DatosURLs {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $urls = array();

}

class UrlSolicitud {

    function verificar($ua, $pais_documento, $tipo_documento, $nro_documento, $solicitud, $credenciales) {

        $urls = new DatosURLs();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $urls->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $urls->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $urls;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $pais_documento == "" || $tipo_documento == "" || $nro_documento == "" || $solicitud == "") {
            $urls->codigoWS = CODIGO_ERROR_PARAMETROS;
            $urls->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $urls;
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
                 * ************* INFORMIX **************
                 */
                $strSQL = 'EXECUTE PROCEDURE ws_url_solicitud("' . $pais_documento . '","' .
                        $tipo_documento . '", "' . $nro_documento . '", "' . $solicitud . '");';

                $res = $objCC->Execute($strSQL);
                $resultado = $res->getRows();
                $instancia = 'g2';

                if ($resultado[0][0] === -4) {

                    $urls->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $urls->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $urls;
                }
            } else {

                /**
                 * ************* POSTGRES **************
                 */
                $rep = new RepositorioWS();
                $resultado = $rep->urlSolicitud($pais_documento, $tipo_documento, $nro_documento, $solicitud, $objCC);
                $instancia = '';
                
                if ($resultado[0]['url'] == -4) {
                    $urls->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $urls->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                    return $urls;
                }
            }

            if (!empty($resultado)) {

                foreach ($resultado as $resu) {

                    $arreglo['url'] = $resu[0];
                    $arreglo['nombreRequisito'] = (string) Generales::decodificador($resu[1], $instancia);
                    $arreglo['codigoRequisito'] = $resu[3];
                    $arreglo['uidNuxeo'] = $resu[4];
                    $urls->urls[] = $arreglo;
                }
            }
            
            if (!is_null($resultado[0][2])) {
                $urls->requisitosValidados = $resultado[0][2];
            }
                
            $urls->codigoWS = CODIGO_OK;
            $urls->mensajeWS = MENSAJE_OK;       
        }
        return $urls;
    }

}

function urlSolicitud($ua, $pais_documento, $tipo_documento, $nro_documento, $solicitud) {
    $servicio = new UrlSolicitud();
    $credenciales = new Credenciales();
    $resultado = $servicio->verificar(strtoupper(trim($ua)), $pais_documento, $tipo_documento, $nro_documento, $solicitud, $credenciales);
    return json_encode($resultado);
}
