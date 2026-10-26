<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada.
  ------------------------------------------------------------------------------------------ */

/* ------------------------------------------
  CLASE QUE CONTIENE LAS VARIABLES A RETORNAR
  ---------------------------------------- */
require_once ('bcrypt.php');
require_once ('Repositorio/RepositorioWS.php');

Class DatosAtilraCambiaClaveWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;

    // Variables Locales del procedimiento
}

/* ----------------------------------------------------------------------------------
  FUNCION QUE CAMBIA LA CLAVE DE AUTOGESTION DE UN ALUMNO - ES INVOCADA POR EL SISTEMA SIGUV
  ----------------------------------------------------------------------------------- */

Class AtilraCambiaClaveWS {

    function cambiarclaveAG($ua, $tipotitulo, $usuario, $claveNueva, $credenciales) {

        $clave = new DatosAtilraCambiaClaveWS();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('siguv', 'wsatilra');
        // PASO 1: Autentico el usuario y password de webservices
        // $aut = Generales::autenticar();
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $clave->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $clave->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $clave;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $usuario == "" || $claveNueva == "") {
            $clave->codigoWS = CODIGO_ERROR_PARAMETROS;
            $clave->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $clave;
        }

        if ($tipotitulo == 0) {
            $titulos = Generales::recuperarTipoTituloConCemed($ua);
        } else {
            $titulos = array($tipotitulo);
        }

        $enc = new bcrypt(10);
        $claveNueva2 = $enc->hash(($claveNueva));
        $datos = array();
        foreach ($titulos as $titulo) {

            $db = Generales::recuperarDB($ua, $titulo);
            $objCC = Generales::conectar($db);

            if ($objCC == '3') {
                $clave->codigoWS = CODIGO_ERROR_CONEXION;
                $clave->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $clave;
            } else if (($titulo != '7') && (!Generales::verificaUAPS(ucwords($ua), $titulo))) {


                $strSQL = "execute procedure sp820_cambiarClaveAG('" . $ua . "','" . $usuario . "','" . $claveNueva2 . "', '3');";
                $salida = $objCC->Execute($strSQL);

                if ($salida->fields[0] != "") {
                    $datos = $salida->getRows();
                }
            } else {
                $rep = new RepositorioWS();
                $unidadAcademica = ($unidadAcademica == 'EUAA') ? 'CU-G' : $unidadAcademica;
                $datos = array(); //$rep->getUsuarioAutogestion($tipo_doc, $nro_doc, $pais_doc, $objCC);
            }
            if (!empty($datos)) {
                $clave->mensajeWS = $datos[0][1];
                $clave->codigoWS =   (int)$datos[0][0];
                return $clave;
            } else {
                $clave->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $clave->mensajeWS = "Error de procedimiento - Algo salio mal dentro de la funcion.";
                return $clave;
            }
        }
        return $clave;
    }

}

function cambiarClaveAutogestion($unidadAcademica, $tipotitulo, $usuario, $claveNueva) {
    $servicio = new AtilraCambiaClaveWS();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=>$unidadAcademica, 'tipotitulo'=>$tipotitulo, 'usuario'=>$usuario, 'claveNueva'=>$claveNueva);
    Generales::logLlamada('cambiarClaveAutogestion', $parametros, false);
    
    $resultado = $servicio->cambiarclaveAG($unidadAcademica, $tipotitulo, $usuario, $claveNueva, $credenciales);
    return json_encode($resultado);
}

?>
