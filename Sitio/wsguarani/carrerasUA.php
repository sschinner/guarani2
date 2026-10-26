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

Class DatosCarrera {

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $carreras = array();
  

}

/* ---------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE EL PROMEDIO HISTORICO POR CARRERA DE UNA UNIDAD ACADEMICA - ES INVOCADA POR EL SISTEMA KUNTUR
  ---------------------------------------------------------------------------------------------------------------- */

Class Carreras {

    function CarrerasVigentes($unidadAcademica, $tipoTitulo,$credenciales) {
        $carreras = new DatosCarrera();
       
        $ua = $unidadAcademica;
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('fhuc','extencionFich','hefesto','electivas','comedor', 'wsingreso','siguv', 'bedeliamovil');
        
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
       
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $carreras->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $carreras->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $carreras;
        } else {
            if ($ua == "" || $tipoTitulo == "") {
                $carreras->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                $carreras->codigoWS = CODIGO_ERROR_PARAMETROS;
                return $carreras;
            }
            
            $unidadAcademicaPermitida = Generales::getUnidadAcademicaUsuario($_SERVER['PHP_AUTH_USER']);

            if (strtoupper($unidadAcademicaPermitida) != $ua && $unidadAcademicaPermitida != 'todas') {
                $carreras->mensajeWS = MENSAJE_OK;
                $carreras->codigoWS = CODIGO_OK;
                $carreras->mensajeRetorno = utf8_encode('No posee permisos para consultar datos de la unidad acad�mica ' . $ua);
                $carreras->codigoRetorno = 'false';
                return $carreras;
            }
            
            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
            } else {
                $titulos = array($tipoTitulo);
            }

            foreach ($titulos as $titulo) {
                
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);
                $instancia='';
                if ($objCC == '3') {
                    $carreras->codigoWS = CODIGO_ERROR_CONEXION;
                    $carreras->mensajeWS = MENSAJE_ERROR_CONEXION;
                    return $carreras;
                } else if (($titulo != '7') && (!Generales::verificaUAPS(ucwords($ua),$titulo))) {
                    $instancia='g2';
                    $strSQL = "execute procedure web_serv_carreras_ua();";
                    
                    $res = $objCC->Execute($strSQL);
                    $carreras->codigoWS = CODIGO_OK;
                    $carreras->mensajeWS = MENSAJE_OK;
                  
                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();                       
                        $carreras->codigoRetorno = true;
                        $carreras->mensajeRetorno = 'OK - Datos Carreras UA';
                    } else {                      
                        $carreras->codigoRetorno = false;
                        $carreras->mensajeRetorno = 'No existe datos de carreras para la unidad acádemica solicitada';
                       
                    }
                    
                } else {
                    $instancia='g3';
                    $rep = new RepositorioWS();
                    $unidadAcademica = ($unidadAcademica == 'EUAA')?'CU-G':$unidadAcademica;
                    $resultado = $rep->getDatosPropuestasUA($unidadAcademica,$objCC);
                    $carreras->codigoWS = CODIGO_OK;
                    $carreras->mensajeWS = MENSAJE_OK;
                        
                    if(!empty($resultado)){
                        $carreras->codigoRetorno = true;
                        $carreras->mensajeRetorno = 'OK - Datos Carreras UA';
                    } else {                      
                        $carreras->codigoRetorno = false;
                        $carreras->mensajeRetorno = 'No existe datos de carreras para la unidad acádemica solicitada'; 
                    }
                }
                if ($carreras->codigoRetorno) {
                    $arreglo = array();
                    
                    foreach ($resultado as $resu) {                        
                        $arreglo['codigoCarrera'] = $resu[0];
                        $arreglo['nombreCarrera'] = (string)Generales::decodificador($resu[1],$instancia);
                        $arreglo['planCarrera'] = $resu[2];
                        $arreglo['nombrePlan'] = $instancia != 'g3' ? $resu[2] : $resu[8];
                        $arreglo['versionPlan'] = $resu[3];
                        $arreglo['estado']  = $resu[4];
                        $arreglo['tipoTitulo'] = ($instancia!= 'g3' )?(int) $titulo:(int)$resu[6];
                        $arreglo['tipoCarrera']  = (string)Generales::decodificador($resu[5],$instancia);
                        // los SP de G2 y G3 devuelven distinta cantidad de elementos (resu[6] y resu[7])
                        $arreglo['alcanceTitulo'] = $instancia != 'g3' ? (string)Generales::decodificador($resu[6],$instancia) : $resu[7]; 
                        $carreras->carreras[] = $arreglo;
                    }
                } else {
                    $carreras->codigoRetorno = false;
                    $carreras->mensajeRetorno = ('No existe datos de carreras para la unidad acádemica solicitada'); 
                }
            }
              return $carreras;
        }
    }

}

function carrerasUA($unidadAcademica,$tipoTitulo = 0) {
    $servicio = new Carreras();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=> $unidadAcademica,'tipoTitulo'=> $tipoTitulo);
    Generales::logLlamada('carrerasUA', $parametros, false);
    
    $resultado = $servicio->CarrerasVigentes(strtoupper($unidadAcademica), $tipoTitulo,$credenciales);
    return json_encode($resultado);
}

?>
