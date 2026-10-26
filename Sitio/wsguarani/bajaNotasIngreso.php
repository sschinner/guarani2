<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

Class DatosBajaNotasIngreso {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;	

    // Variables Locales del procedimiento
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE MIGRA LAS NOTAS DE UN ALUMNO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  Se debe calcular la clave por default a setear y pasar como parámetro.
  ------------------------------------------------------------------------------------------------------------------- */

Class NotasIngresobaja {

    function migrar($ua, $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia,$credenciales) {

        $reinscripto = new DatosBajaNotasIngreso();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        // PASO 1: Autentico el usuario y password de webservices
        
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $reinscripto->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $reinscripto->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $reinscripto;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $tipo_doc == "" || $nro_doc == "" || $materia == "" || $pais_documento == "") {
            $reinscripto->codigoWS = CODIGO_ERROR_PARAMETROS;
            $reinscripto->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $reinscripto;
        }

        // PASO 3: Conexion a informix

        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        // return $objCC;
        if ($objCC == '3') {

            $reinscripto->codigoWS = CODIGO_ERROR_CONEXION;
            $reinscripto->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $reinscripto;
        }

        // PASO 4: Desarrollo la funcion que necesito
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua,$tipotitulo))) {
            $strSQL = 'EXECUTE PROCEDURE web_ser_baj_curso_ingreso("' . $ua . '", "' . $carrera . '", "' . $pais_documento . '","' .
                    $tipo_doc . '", "' . $nro_doc . '", "' . $materia . '");';

            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $reinscripto->codigoWS = CODIGO_OK;
                $reinscripto->mensajeWS = MENSAJE_OK;				
                $reinscripto->codigoRetorno = $datosproc[0][0];
                $reinscripto->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $reinscripto;
            } else {
                $reinscripto->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $reinscripto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $reinscripto;
            }
        } else {
            $rep = new RepositorioWS();
            $resul = $rep->dropNotasIngreso($ua, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $objCC);
            if (!empty($resul)) {
                $reinscripto->codigoWS = CODIGO_OK;
                $reinscripto->mensajeWS = MENSAJE_OK;					
                $reinscripto->codigoRetorno = (string)$resul[0][0];
                $reinscripto->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $resul[0][1]);
                return $reinscripto;
            } else {
                $reinscripto->codigoWS = (string)CODIGO_ERROR_PROCEDIMIENTO;
                $reinscripto->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $reinscripto;
            }
        }
    }

}

function bajaNotasIngreso($ua, $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia) {
    $servicio = new NotasIngresobaja();
    $credenciales = new Credenciales();
    
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera,'pais_documento'=>$pais_documento, 'tipo_documento'=>$tipo_doc, 'nro_documento'=>$nro_doc, 'materia'=>$materia);
    Generales::logLlamada('bajaNotasIngreso', $parametros,false);
   
    $resultado = $servicio->migrar(strtoupper(trim($ua)), $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia,$credenciales);
    return json_encode($resultado);
}
