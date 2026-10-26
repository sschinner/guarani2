<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada o en el llamado a la función.
  ------------------------------------------------------------------------------------------ */
require_once ('Repositorio/RepositorioWS.php');
Class DatosInsertarRequisitoWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN REQUISITO DE INGRESO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  ------------------------------------------------------------------------------------------------------------------- */

Class IngresoInsertarRequisitoWS {

    function insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $fecha_presentacion, $credenciales) {

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso','siguv');
        
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $requisito->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $requisito->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $requisito;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $pais_documento == "" || $tipo_doc == "" || $nro_doc == "" || $cod_requisito == "" || !is_numeric($cod_requisito)) {
            $requisito->codigoWS = CODIGO_ERROR_PARAMETROS;
            $requisito->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $requisito;
        }

        // PASO 3: Conexion a la base
        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $requisito->codigoWS = CODIGO_ERROR_CONEXION;
            $requisito->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $requisito;
        }
        
        // PASO 4: Desarrollo la funcion que necesito
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {

            // Codifico de G3 a G2
            $cod_requisito = Generales::recodeG3aG2($cod_requisito);
            
            $strSQL = "EXECUTE PROCEDURE ws_insertar_requisito('{$ua}','{$carrera}','{$pais_documento}','{$tipo_doc}','{$nro_doc}','{$cod_requisito}','{$fecha_presentacion}');";

            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $requisito->codigoWS = CODIGO_OK;
                $requisito->mensajeWS = MENSAJE_OK;
                $requisito->codigoRetorno = (string) $datosproc[0][0];
                $requisito->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $requisito;
            } else {
                $requisito->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $requisito->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $requisito;
            }
        } else {
            
           
            $rep = new RepositorioWS();
            $resul = $rep->insertarRequisitoNuevo($carrera, $pais_documento, $tipo_doc, $nro_doc, $cod_requisito, $fecha_presentacion, $objCC);

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

function insertarRequisito($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $fecha_presentacion) {
    $servicio = new IngresoInsertarRequisitoWS();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=>$ua, 'tipotitulo'=>$tipotitulo,'carrera'=>$carrera, 'tipo_documento'=>$tipo_doc, 'nro_documento'=>$nro_doc,'pais_documento'=>$pais_documento, 'cod_requisito'=>$cod_requisito, 'fecha_presentacion'=>$fecha_presentacion);
    Generales::logLlamada('insertarRequisito', $parametros, false);
    
    $resultado = $servicio->insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $cod_requisito, $fecha_presentacion, $credenciales);
    
    $repositorio = new RepositorioWS();
    $repositorio->registrarAuditoria($parametros, $resultado, 'insertarRequisito', $_SERVER['PHP_AUTH_USER']);

    return json_encode($resultado);
}

?>
