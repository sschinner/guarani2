<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizÃ³ la operaciÃ³n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condiciÃ³n de error del lenguaje, que no es gestionada o en el llamado a la funciÃ³n.
  ------------------------------------------------------------------------------------------ */
require_once ('Repositorio/RepositorioWS.php');
Class DatosBajaRequisitoWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;

    // Variables Locales del procedimiento
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN REQUISITO DE INGRESO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  ------------------------------------------------------------------------------------------------------------------- */

Class IngresoBajaRequisitoWS {

    function insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito, $credenciales) {

        $requisito = new DatosBajaRequisitoWS();
                
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso','siguv');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        // PASO 1: Autentico el usuario y password de webservices
        
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $requisito->codigoWS = (string) CODIGO_ERROR_AUTENTICACION;
            $requisito->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $requisito;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $tipo_doc == "" || $nro_doc == "" || $cod_requisito == "" || !is_numeric($cod_requisito)) {
            $requisito->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
            $requisito->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $requisito;
        }


        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $requisito->codigoWS = (string) CODIGO_ERROR_CONEXION;
            $requisito->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $requisito;
        }

        // PASO 4: Desarrollo la funcion que necesito
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {
            
            // Codifico de G3 a G2
            $cod_requisito = Generales::recodeG3aG2($cod_requisito);
            
            $strSQL = "EXECUTE PROCEDURE web_ser_baja_req('{$ua}', '{$carrera}', '{$pais_documento}','{$tipo_doc}','{$nro_doc}','{$nro_inscripcion}','{$cod_requisito}');";

            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $requisito->codigoWS = $datosproc[0][0];
                $requisito->mensajeWS = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $requisito;
            } else {
                $requisito->codigoWS = (string) CODIGO_ERROR_PROCEDIMIENTO;
                $requisito->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $requisito;
            }
        } else {
            $rep = new RepositorioWS();
            $resul = $rep->eliminarRequisito($carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito,$objCC);
        
            if (!empty($resul)) {
                $requisito->codigoWS = CODIGO_OK;
                $requisito->mensajeWS = MENSAJE_OK;
                $requisito->codigoRetorno = (string) $resul[0][0];
                $requisito->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $resul[0][1]);
                return $requisito;
            } else {
                $requisito->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $requisito->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $requisito;
            }
        }
    }

}

function bajaRequisito($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito) {
    $servicio = new IngresoBajaRequisitoWS();
    $credenciales = new Credenciales();
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera, 'tipo_doc'=>$tipo_doc, 'nro_doc'=>$nro_doc, 'pais_documento'=>$pais_documento, 'nro_inscripcion'=>$nro_inscripcion, 'cod_requisito'=>$cod_requisito);
    Generales::logLlamada('bajaRequisito', $parametros, false);
    $resultado = $servicio->insertar(strtoupper(trim($ua)), $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito, $credenciales);
    
    $repositorio = new RepositorioWS();
    $repositorio->registrarAuditoria($parametros, $resultado, 'bajaRequisito', $_SERVER['PHP_AUTH_USER']);
    
    return json_encode($resultado);
}

?>
