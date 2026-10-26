<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */
require_once ('Repositorio/RepositorioWS.php');
Class DatosNotasIngreso {

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

Class NotasIngreso {

    function migrar($ua, $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota,$credenciales) {

        $reinscripto = new DatosNotasIngreso();

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
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $tipo_doc == "" || $nro_doc == "" || $materia == "" || $tipo_examen == "" || $fecha_examen == "" || $pais_documento == "") {
            $reinscripto->codigoWS = CODIGO_ERROR_PARAMETROS;
            $reinscripto->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $reinscripto;
        }else if ($tipo_examen == "1" && $nota == ""){
            $reinscripto->codigoWS = CODIGO_ERROR_PARAMETROS;
            $reinscripto->mensajeWS = 'Error de parametros - Si el tipo de examen es 1 la nota no puede ser nula o vacia - Verifique';
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
            $strSQL = 'EXECUTE PROCEDURE web_ser_ins_curso_ingreso("' . $ua . '", "' . $carrera . '", "' . $pais_documento . '","' .
                    $tipo_doc . '", "' . $nro_doc . '", "' . $materia . '", "' . $tipo_examen . '", "' .
                    $fecha_examen . '", "' . $nota . '");';

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
            $resul = $rep->setNotasIngreso($carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota, $objCC);
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

function altaNotasIngreso($ua, $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota) {
    $servicio = new NotasIngreso();
    $credenciales = new Credenciales();
    
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera,'pais_documento'=>$pais_documento, 'tipo_documento'=>$tipo_doc, 'nro_documento'=>$nro_doc, 'materia'=>$materia,'tipo_examen'=>$tipo_examen, 'fecha_examen'=> $fecha_examen, 'nota'=> $nota);
    Generales::logLlamada('altaNotasIngreso', $parametros,false);
   
    $resultado = $servicio->migrar(strtoupper(trim($ua)), $tipotitulo, $carrera, $pais_documento, $tipo_doc, $nro_doc, $materia, $tipo_examen, $fecha_examen, $nota,$credenciales);
    
    $repositorio = new RepositorioWS();
    $repositorio->registrarAuditoria($parametros, $resultado, 'altaNotasIngreso', $_SERVER['PHP_AUTH_USER']);
    
    return json_encode($resultado);
}
