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

//define(URL_DNIPAISTIPO_SIGUV_REST, 'https://www.unlvirtual.edu.ar/test/campusvirtual/ws/validarUsuarioHefesto?');

Class AtributosCensalesAlumno {

    public $codigoWS;
    public $mensajeWS;
    //public $tipoTitulo;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $datos = array();

    function getCodigoWS() {
        return $this->codigoWS;
    }

    function getCodigoRetorno() {
        return $this->codigoRetorno;
    }

    function setCodigoRetorno($codigoRetorno) {
        $this->codigoRetorno = (int) $codigoRetorno;
    }

    function setCodigoWS($codigoWS) {
        $this->codigoWS = (int) $codigoWS;
    }

    function setMensajeWS($mensajeWS) {
        $this->mensajeWS = (string) $mensajeWS;
    }

    function setMensajeRetorno($mensajeRetorno) {
        $this->mensajeRetorno = (string) $mensajeRetorno;
    }

    function setDatos($datos) {
        $this->datos[] = $datos;
    }

}

/* ---------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE DATOS CENSALES DE UN ALUMNO
  ---------------------------------------------------------------------------------- */

Class DatosCensalesAlumno {

    function datos($unidadAcademica, $tipoTitulo, $filtro, $valor1, $valor2, $valor3, $credenciales) {
        $instancia = '';
        $datos = new AtributosCensalesAlumno();
        $resultado = '';
        $ua = $unidadAcademica;

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('siguv', 'hefesto','extencionFich', 'wsingreso','gea','telematica','moodlefich','electivas', 'sistemasfce');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        //$aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datos->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $datos->setMensajeWS(utf8_encode(MENSAJE_ERROR_AUTENTICACION));
            return $datos;
        } else {
            if ($ua == "" || $tipoTitulo == "" || $filtro === '' ||
                    $valor1 === '' || ($filtro === 'documento' && ($valor1 === '' || $valor2 === '' || $valor3 === '') )) {
                $datos->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                $datos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                return $datos;
            }
            
            $unidadAcademicaPermitida = Generales::getUnidadAcademicaUsuario($_SERVER['PHP_AUTH_USER']);

            if (strtoupper($unidadAcademicaPermitida) != $unidadAcademica && $unidadAcademicaPermitida != 'todas') {
                $datos->mensajeWS = MENSAJE_OK;
                $datos->codigoWS = CODIGO_OK;
                $datos->mensajeRetorno = utf8_encode('No posee permisos para consultar datos de la unidad acad�mica ' . $unidadAcademica);
                $datos->codigoRetorno = '-5';
                return $datos;
            }

            if ($tipoTitulo == 0) {
                $titulos = Generales::recuperarTipoTituloConCemed($ua);
                //$titulos = array_reverse($titulos);
            } else {
                $titulos = array($tipoTitulo);
            }
            $datos->setCodigoRetorno(-1);
            $datos->setMensajeRetorno('No hay datos - ' . ucfirst($filtro) . ' ' . $valor1 . ' inexistente');
            
            foreach ($titulos as $titulo) {
               
                $db = Generales::recuperarDB($ua, $titulo);
                $objCC = Generales::conectar($db);

                if ($objCC == '3') {
                    $datos->setCodigoWS(CODIGO_ERROR_CONEXION);
                    $datos->setMensajeWS(MENSAJE_ERROR_CONEXION);
                    return $datos;
                } else if (($titulo === '6' && $filtro === 'usuario')) {
                   
                    $respuesta = json_decode(self::tipoDniPaisSiguv($valor1));
                    if ($respuesta->codigoWS === 0 && $respuesta->mensajeWS->nroDocumento !== '') {
                        $valorSig1 = $respuesta->mensajeWS->nroDocumento;
                        $valorSig2 = ($respuesta->mensajeWS->tipoDocumento === 'DNI') ? 0 : 90;
                        $valorSig3 = $respuesta->mensajeWS->paisDocumento;
                        $filtroSig = 'documento';

                        if ($ua == "" || $tipoTitulo == "" || $filtroSig === '' ||
                                $valorSig1 === '' || ($filtroSig === 'documento' && ($valorSig1 === '' || $valorSig2 === '' || $valorSig3 === '') )) {
                            $datos->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                            $datos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                            return $datos;
                        }
                        $instancia = 'g2';
                        $strSQL = "execute procedure web_serv_dat_cen_alu('" . $filtroSig . "','" . $valorSig1 . "','" . $valorSig2 . "','" . $valorSig3 . "');";
                        $res = $objCC->Execute($strSQL);
                        $objCC->Close();
                        if ($res->fields[0] != "") {
                            $resultado = $res->getRows();
                            $datos->setCodigoWS(CODIGO_OK);
                            $datos->setMensajeWS(MENSAJE_OK);
                        }
                    }
                } else if (($titulo != '7') && (!Generales::verificaUAPS($ua, $titulo))) {
                    /**
                     *  Realizo la consulta en Informix para obtener los datos censales 
                     */
                    $instancia = 'g2';
                    $strSQL = "execute procedure web_serv_dat_cen_alu('" . $filtro . "','" . $valor1 . "','" . $valor2 . "','" . $valor3 . "');";
                    $res = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($res->fields[0] != "") {
                        $resultado = $res->getRows();
                        $datos->setCodigoWS(CODIGO_OK);
                        $datos->setMensajeWS(MENSAJE_OK);
                    }
                } else {
                    /**
                     *  Realizo la consulta en Postgres para obtener los datos censales 
                     */
                   // return $filtro .'---'. $valor1.'---'. $valor2.'---'. $valor3;
                    $rep = new RepositorioWS();
                    $ua = ($ua==='EUAA')?'CU-G':$ua;
                    $resultado = $rep->obtenerDatosCensalesAlumno($filtro, $valor1, $valor2, $valor3,$ua, $objCC);
                    $instancia = '';
                    if($unidadAcademica == 'FADU'){// Identificamos y devolvemos el verdadero tipoTitulo (GRADO, POSGRADO, SEMI), hoy son dos en G3
                        $titulo = '2';
                    }else{
                        $titulo = '1';
                    }
                    
                    if (!empty($resultado)) {
                        
                        $datos->setCodigoWS(CODIGO_OK);
                        $datos->setMensajeWS(MENSAJE_OK);
                    }
                }
                if ($datos->getCodigoWS() == (int) CODIGO_OK) {
                    /**
                     *  Mapeo de valores obtenidos 
                     */
                    $censales = array();


                    
                    if ( (int)$resultado[0][0] === 0) {
                       
                        $datos->setCodigoRetorno($resultado[0][0]);
                        $datos->setMensajeRetorno($resultado[0][28]);
                        foreach ($resultado as $resu) {
                            //return $resu;
                            $censales['tipoDocumento'] = (int) $resu[1];
                            $censales['nroDocumento'] = (string) $resu[2];
                            $censales['fechaNacimiento'] = ($resu[3]==NULL)?'':$resu[3];
                            setlocale(LC_ALL, 'en_US');
                            $censales['apellido'] = (string)Generales::decodificador($resu[4],$instancia);
                            $censales['nombre'] = (string) Generales::decodificador($resu[5],$instancia);
                            if ($resu[6] == 'F' || $resu[6] == '2') {
                                $censales['sexo'] = 2;
                            } else if ($resu[6] == 'M' || $resu[6] == '1') {
                                $censales['sexo'] = 1;
                            } else {
                                $censales['sexo'] = (int) $resu[6];
                            }
                            $censales['localidadProc'] = (string) Generales::decodificador($resu[7],$instancia);
                            $censales['cpProc'] = (int) $resu[8];
                            $censales['localidadRes'] = (string) Generales::decodificador($resu[9],$instancia);
                            $censales['cpRes'] = (int) $resu[10];
                            $censales['direccionRes'] = (string) Generales::decodificador($resu[11],$instancia);
                            $censales['nroRes'] = (int) $resu[12];
                            $censales['pisoRes'] = (int) $resu[13];
                            $censales['deptoRes'] = (string) $resu[14];
                            $censales['unidad'] = (string) $resu[15];
                            $censales['telefono'] = (string) $resu[16];
                            $censales['email'] = (string) $resu[17];
                            $censales['nroCelular'] = (string) $resu[18];
                            $censales['compCelular'] = (string) $resu[19];
                            $censales['paisDocumento'] = (string) $resu[20];
                            $censales['provincia_lectivo'] = (string) $resu[21];
                            $censales['pais_lectivo'] = (string) $resu[22];
                            $censales['provincia_proc'] = (string) $resu[23];
                            $censales['pais_proc'] = (string) $resu[24];
                            $censales['telefono_familiar'] = (string) $resu[25];
                            $censales['procedencia_calle'] = (string) $resu[26];
                            $censales['procedencia_numero'] = (string) $resu[27];
                           
                            $censales['tipoTitulo'] = $titulo;
                            $datos->setDatos($censales);
                            
                        }
                        if ($filtro === 'usuario' || $filtroSig === 'usuario' || $filtro === 'documento' || $filtroSig === 'documento') {
                            break;
                        }
                    }
                } else {
                    $datos->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
                    $datos->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
                }
            }
            return $datos;
        }
    }

    private function tipoDniPaisSiguv($usuario) {

        $username = 'hefesto';
        $password = 'h3f3st4';

        $url = URL_DNIPAISTIPO_SIGUV_REST . "usuario=" . $usuario;
        
        $digest = hash('sha256', "$username:$password");
        $headers = array('Content-Type:application/json', 'Authorization: Digest ' .$digest);
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_DIGEST);

        $result = curl_exec($ch);
        curl_close($ch);

        return $result;
    }

}

function datosCensalesAlumno($unidadAcademica, $tipoTitulo = 0, $filtro, $valor1, $valor2 = '', $valor3 = '') {

    $servicio = new DatosCensalesAlumno();
    $credenciales = new Credenciales();
    //$tipoTitulo = Generales::conversionUATT($unidadAcademica, $tipoTitulo);
    $parametros = array('unidadAcademica'=>$unidadAcademica, 'tipotitulo'=>$tipoTitulo,'filtro'=>$filtro, 'valor1'=>$valor1,'valor2'=> $valor2,'valor3'=> $valor3 );
    Generales::logLlamada('datosCensalesAlumno', $parametros, false);
    
    $resultado = $servicio->datos(strtoupper(trim($unidadAcademica)), $tipoTitulo, strtolower(trim($filtro)), $valor1, $valor2, $valor3, $credenciales);
    return json_encode($resultado);
}

?>
