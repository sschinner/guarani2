<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
//require_once("adodb/adodb.inc.php");

Class ListadoPorFecha {

    public $codigoWS=CODIGO_ERROR_PROCEDIMIENTO;
    public $mensajeWS=MENSAJE_ERROR_PROCEDIMIENTO;
    public $dato=array();
   // public $tipoTitulo=array();
    
}

/* ---------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS CENSALES DE UN ALUMNO - ES INVOCADA POR EL SISTEMA PEGASO
  ---------------------------------------------------------------------------------- */

class ListadoAlumnosFecha {

    function datos($ua,$fecha, $tipoTitulo) {

        $listado = new ListadoPorFecha();

        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $listado->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $listado->mensajeWS =MENSAJE_ERROR_AUTENTICACION;
            return $listado;
        } else {
            if ($fecha == "" || $ua == "" || $tipoTitulo == "") {
                $listado->mensajeWS =MENSAJE_ERROR_PARAMETROS;
                $listado->codigoWS =CODIGO_ERROR_PARAMETROS;
                return $listado;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTitulo($ua);
                $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {
             
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
               
                if ($objCC == '3') {
                    $listado->codigoWS = CODIGO_ERROR_CONEXION;
                    $listado->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $listado;
                } else {
                    //realizo la consulta para ver si es alumno de la $UA
                    $strSQL = "execute procedure web_serv_listado_alu_fecha('" . $fecha . "');";
                    $res = $objCC->Execute($strSQL);
                   
                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $listado->codigoWS = CODIGO_OK;
                        $listado->mensajeWS = MENSAJE_OK;
                        
                        $data = array();
                        foreach ($resultado as $resu) {
                           
                            $hayDatos = true;
                            $data['apellido'] = iconv("ISO-8859-1", "utf-8",$resu[0]);
                            $data['nombre'] = iconv("ISO-8859-1", "utf-8",$resu[1]);
                            $data['tipoDocumento'] = $resu[2];
                            $data['carrera'] = $resu[3];
                            $data['fecha'] = $resu[4];
                            $listado->dato[]=$data;
                           
                        }
                      
                    }else{
                        $listado->codigoWS = CODIGO_OK;
                        $listado->mensajeWS = MENSAJE_OK;
                    }
                }
            }
            if ($listado->codigoWS == '0') {
                return $listado;
            } else if ($listado->codigoWS != "0" ) {
                $listado->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $listado->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $listado;
            }
        }
    }

}

function listadoAlumnos($ua,$fecha,$tipoTitulo = 0) {
    $servicio = new ListadoAlumnosFecha();
    $resultado = $servicio->datos($ua,$fecha,$tipoTitulo);
    return json_encode($resultado);
}

?>
