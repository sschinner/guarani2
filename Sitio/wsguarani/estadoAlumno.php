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

Class AtributosEstadoAlumno {

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
  FUNCION QUE DEVUELVE EL ESTADO DEL ALUMNO EN CADA CARRERA QUE SE ENCUENTRA
  ---------------------------------------------------------------------------------- */

Class EstadoAlumno {

    function datos($unidadAcademica, $tipoTitulo, $filtro, $valor1, $valor2, $valor3, $credenciales) {
        $instancia = '';
        $datos = new AtributosEstadoAlumno();
        $resultado = '';
        $ua = $unidadAcademica;

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('telematica', 'moodlefich', 'comedor', 'siguv', 'wsingreso', 'hefesto', 'gea', 'credicoop', 'solicitudes');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        //$aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datos->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $datos->setMensajeWS(utf8_encode(MENSAJE_ERROR_AUTENTICACION));
            return $datos;
        }
        if ($filtro === '' ||
                $valor1 === '' || ($filtro === 'documento' && ($valor1 === '' || $valor2 === '' || $valor3 === '') )) {
            $datos->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
            $datos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
            return $datos;
        }
		
		$tipoTitulo = ($tipoTitulo === '' ? 0 : $tipoTitulo);

        if ($unidadAcademica === '') {
            $ua = Generales::obtenerTodasUA($tipoTitulo);
        } else if (Generales::verificaUnidadAcademica($unidadAcademica)) {
            $ua = Generales::basesPorUnidadAcademica($unidadAcademica, $tipoTitulo);
        } else {
            $datos->setMensajeWS(utf8_encode("Error de parametros - Unidad Acad�mica " . $unidadAcademica . " inexistente - Verifique"));
            $datos->setCodigoWS(CODIGO_ERROR_PARAMETROS);
            return $datos;
            ;
        }
        $datos->setCodigoWS(CODIGO_OK);
        $datos->setMensajeWS(MENSAJE_OK);
        $datos->setCodigoRetorno(-1);
        $datos->setMensajeRetorno('No hay datos - ' . ucfirst($filtro) . ' ' . $valor1 . ' inexistente');

        foreach ($ua as $base_de_datos) {
            $resultado = '';
            $b = explode('_', $base_de_datos);
            $objCC = Generales::conectar($base_de_datos);
            $titulo = Generales::obtenerTipoTitulo($b[0]);
            if ($objCC == '3') {
                $datos->setCodigoWS(CODIGO_ERROR_CONEXION);
                $datos->setMensajeWS(MENSAJE_ERROR_CONEXION);
                return $datos;
            }

            if ($b[0] != 'guarani3') {
                /**
                 *  Realizo la consulta en Informix para obtener los datos censales 
                 */
                $instancia = 'g2';
                $strSQL = "execute procedure web_serv_estado_alumno ('" . $filtro . "','" . $valor1 . "','" . $valor2 . "','" . $valor3 . "');";

                $res = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($res->fields[0] != "") {
                    $resultado = $res->getRows();
                }
            } else {
                /**
                 *  Realizo la consulta en Postgres para obtener los datos censales 
                 */
                // return $filtro .'---'. $valor1.'---'. $valor2.'---'. $valor3;
                $rep = new RepositorioWS();
                $unidadAcademica = ($unidadAcademica === 'EUAA') ? 'CU-G' : $unidadAcademica;

                $resu = $rep->obtenerEstadoAlumno($filtro, $valor1, $valor2, $valor3, $unidadAcademica, $objCC);
                $instancia = '';

                if ($unidadAcademica == 'FADU') {
                    // Identificamos y devolvemos el verdadero tipoTitulo (GRADO, POSGRADO, SEMI), hoy son dos en G3
                    $titulo = '2';
                } else {
                    $titulo = '1';
                }

                if (!empty($resu) && $resu[0]['istatus'] == 0) {
                    $resultado = $resu;
                    $datos->setCodigoWS(CODIGO_OK);
                    $datos->setMensajeWS(MENSAJE_OK);
                }
            }
            if ($resultado !== '') {
                /**
                 *  Mapeo de valores obtenidos 
                 */
                $estado = array();

                if ((int) $resultado[0][11] === 0) {

                    $datos->setCodigoRetorno($resultado[0][11]);
                    $datos->setMensajeRetorno($resultado[0][12]);
                    foreach ($resultado as $resu) {

                        $estado['carrera'] = (string) $resu[0];
                        $estado['nombreCarrera'] = (string) Generales::decodificador($resu[1], $instancia);
                        $estado['tipoDocumento'] = (int) $resu[2];
                        $estado['nroDocumento'] = (string) $resu[3];
                        $estado['fechaIngreso'] = (string) $resu[4];
                        if ($resu[5] == 'A') {
                            $estado['calidad'] = (string) 'Activo';
                        } else if ($resu[5] == 'P') {
                            $estado['calidad'] = (string) 'Pasivo';
                        } else if ($resu[5] == 'E') {
                            $estado['calidad'] = (string) 'Egresado';
                        } else {
                            $estado['calidad'] = (string) 'Abandono';
                        }
                        $estado['situacionAlumno'] = (string) Generales::decodificador($resu[6],$instancia);
                        $estado['sancionesActuales'] = (boolean) ($resu[7] == 0) ? false : true;
                        $estado['alumnoRegular'] = (boolean) ($resu[8] != 1) ? false : true;
                        $estado['egresado'] = (boolean) ($resu[9] != 1) ? false : true;
                        $estado['ua'] = (string) $resu[10];
                        $estado['tipoTitulo'] = $titulo;
                        $estado['planCarrera'] = (string) $resu[13];
                        $estado['nombrePlan'] = $b[0] == 'guarani3' ? (string) $resu[14] : $resu[13]; // en G2 plan y nombrePlan es el mismo dato
                        $datos->setDatos($estado);
                    }
                }
            }
        }
        if ($datos->getCodigoWS() == (int) CODIGO_OK) {
            return $datos;
        }
        $datos->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
        $datos->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);
    }

    private function tipoDniPaisSiguv($usuario) {

        $username = 'hefesto';
        $password = 'h3f3st4';

        $url = URL_DNIPAISTIPO_SIGUV_REST . "usuario=" . $usuario;

        $digest = hash('sha256', "$username:$password");
        $headers = array('Content-Type:application/json', 'Authorization: Digest ' . $digest);

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

function estadoAlumno($unidadAcademica, $tipoTitulo = 0, $filtro, $valor1, $valor2 = '', $valor3 = '') {

    $servicio = new EstadoAlumno();
    $credenciales = new Credenciales();
    //$tipoTitulo = Generales::conversionUATT($unidadAcademica, $tipoTitulo);
    $parametros = array('unidadAcademica'=>$unidadAcademica, 'tipotitulo'=>$tipoTitulo,'filtro'=>$filtro, 'valor1'=>$valor1,'valor2'=> $valor2,'valor3'=> $valor3 );
    Generales::logLlamada('estadoAlumno', $parametros, false);
    
    $resultado = $servicio->datos(strtoupper(trim($unidadAcademica)), $tipoTitulo, strtolower(trim($filtro)), $valor1, $valor2, $valor3, $credenciales);
    return json_encode($resultado);
}

?>
