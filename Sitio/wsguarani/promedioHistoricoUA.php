<?php

require_once ('Repositorio/RepositorioWS.php');
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contraseña invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class KunturHistoricoUA {

    public $codigoWS;
    public $mensajeWS;
    public $carreras = array();

}

/* ---------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE EL PROMEDIO HISTORICO POR CARRERA DE UNA UNIDAD ACADEMICA - ES INVOCADA POR EL SISTEMA KUNTUR
  ---------------------------------------------------------------------------------------------------------------- */

Class PromedioHistorico {

    function promedios($unidadAcademica, $tipoTitulo,$credenciales) {
        $kuntur = new KunturHistoricoUA();

        $ua = $unidadAcademica;
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('gea');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
       
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $kuntur->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $kuntur->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $kuntur;
        } else {
            if ($ua == "" || $tipoTitulo == "") {
                $kuntur->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $kuntur->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $kuntur;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                // $titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {

                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);  
                
                if ($objCC == '3') {
                    $kuntur->codigoWS = CODIGO_ERROR_CONEXION;
                    $kuntur->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $kuntur;
                } else if (($titulo != '7') && (!Generales::verificaUAPS($ua,$titulo))) {

                    //realizo la consulta para ver si es alumno de la $UA

                    $strSQL = "execute procedure web_serv_promedio_hist_5 ();";

                    $res = $objCC->Execute($strSQL);

                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $kuntur->codigoWS = CODIGO_OK;
                        $kuntur->mensajeWS = MENSAJE_OK;

                        $arreglo = array();
                        foreach ($resultado as $resu) {
                            $arreglo['tipoTitulo'] = $titulo;
                            $arreglo['codigoCarrera'] = $resu[0];
                            $arreglo['nombreCarrera'] = (string) utf8_encode($resu[1]);
                            $arreglo['promedioAplazos'] = $resu[2];
                            $arreglo['promedioSinAplazos'] = $resu[3];
                            $kuntur->carreras[] = $arreglo;
                        }
                    } else if($kuntur->codigoWS != CODIGO_OK) {
                        $kuntur->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $kuntur->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                        return $kuntur;
                    }
                } else {

                    $rep = new RepositorioWS();
                    $resul = $rep->obtenerPromedioPorCarrera($objCC);
//                    $sth = $objCC->prepare("Select * from vw_unl_promCarrera5Anios ;");
//                    $sth->execute();
//                    $resul = $sth->fetchAll();
                    if (!empty($resul)) {
                        $kuntur->codigoWS = CODIGO_OK;
                        $kuntur->mensajeWS = MENSAJE_OK;
                        $arreglo = array();
                        foreach ($resul as $resu) {
                            $arreglo['tipoTitulo'] = (int)$titulo;
                            $arreglo['codigoCarrera'] = $resu[0];
                            $arreglo['nombreCarrera'] = ($resu[1]);
                            $arreglo['promedioAplazos'] = $resu[2];
                            $arreglo['promedioSinAplazos'] = $resu[3];
                            $kuntur->carreras[] = $arreglo;
                        }
                    } else if($kuntur->codigoWS != CODIGO_OK) {
                        $kuntur->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                        $kuntur->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                        return $kuntur;
                    }
                }
            }
            return $kuntur;
        }
    }

}

function promedioHistoricoUA($unidadAcademica, $tipoTitulo = 0) {
    $servicio = new PromedioHistorico();
    //$tipoTitulo = Generales::conversionUATT($unidadAcademica, $tipoTitulo);
    $credenciales = new Credenciales();
    $parametros = array('ua' =>$unidadAcademica, 'tipoTitulo' =>$tipoTitulo);
    Generales::logLlamada('promedioHistoricoUA', $parametros, false);
    
    $resultado = $servicio->promedios(strtoupper($unidadAcademica), $tipoTitulo,$credenciales);
    return json_encode($resultado);
}

?>
