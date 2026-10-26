<?php
require_once ('Repositorio/RepositorioWS.php');
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of consultarUsuarioAutogestion
 *
 * @author leandro
 */
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
Class DatosAutogestion {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $usuario;

    // Variables Locales del procedimiento
}

/* --------------------------------------------------------------------------------------------------------------------
  FUNCION QUE MODIFICA EL USUARIO DE AUTOGESTION POR EL PARAMETRO PASADO. ES INVOCADA POR SIGUV PARA EL SERVICIO A ATILRA
  --------------------------------------------------------------------------------------------------------------------- */

Class UsuarioAutogestion {

    function consultarUsuario($ua, $tipoTitulo, $tipo_doc, $nro_doc, $pais_doc, $credenciales) {

        $usuario = new DatosAutogestion();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('siguv');
        // PASO 1: Autentico el usuario y password de webservices
        // $aut = Generales::autenticar();
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $usuario->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $usuario->mensajeWS = "Error de autenticacion - Credenciales invalidas.";
            return $usuario;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($tipo_doc == "" || $nro_doc == "" || $pais_doc == "" || $ua == "" || $tipoTitulo == "") {
            $usuario->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            $usuario->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $usuario;
        }
        if ($tipoTitulo == 0) {
            $titulos = Generales::recuperarTipoTituloConCemed($ua);
        } else {
            $titulos = array($tipoTitulo);
        }
        $datos = array();
        foreach ($titulos as $titulo) {
            $db = Generales::recuperarDB($ua, $titulo);

            $objCC = Generales::conectar($db);

            if ($objCC == '3') {
                $usuario->codigoWS = CODIGO_ERROR_CONEXION;
                $usuario->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $usuario;
            } else if (($titulo != '7') && (!Generales::verificaUAPS(ucwords($ua), $titulo))) {

                // PASO 4: Desarrollo la funcion que necesito
                $strSQL = "EXECUTE PROCEDURE sp820_consultar_usuarioag('" . $tipo_doc . "', '" . $nro_doc . "', '" . $pais_doc . "');";
                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != '') {
                    $datos = $res->getRows();
                    $usuario->codigoWS = CODIGO_OK;
                    $usuario->mensajeWS = MENSAJE_OK;
                }
            } else {
                $rep = new RepositorioWS();
                $unidadAcademica = ($unidadAcademica == 'EUAA') ? 'CU-G' : $unidadAcademica;
                $datos = array();//$rep->getUsuarioAutogestion($tipo_doc, $nro_doc, $pais_doc, $objCC);
                $usuario->codigoWS = CODIGO_OK;
                $usuario->mensajeWS = MENSAJE_OK;
            }
            if (!empty($datos)) {
                $usuario->mensajeRetorno = $datos[0][1];
                $usuario->codigoRetorno = $datos[0][0];
                $usuario->usuario = $datos[0][2];
                return $usuario;
            } else {

                $usuario->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $usuario->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $usuario;
            }
        }
    }

}

function consultarUsuarioAutogestion($ua, $tipoTitulo, $tipo_doc, $nro_doc, $pais_doc) {
    $servicio = new UsuarioAutogestion();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=>$ua, 'tipotitulo'=>$tipoTitulo,'tipo_doc'=>$tipo_doc, 'nro_doc'=>$nro_doc, 'pais_documento'=>$pais_doc);
    Generales::logLlamada('cambiarUsuarioAutogestion', $parametros, false);
    
    $resultado = $servicio->consultarUsuario($ua, $tipoTitulo, $tipo_doc, $nro_doc, $pais_doc, $credenciales);
    return json_encode($resultado);
}

?>
