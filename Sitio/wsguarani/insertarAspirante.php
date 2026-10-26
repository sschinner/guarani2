<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada o en el llamado a la función.
  ------------------------------------------------------------------------------------------ */
require_once ('bcrypt.php');
require_once ('Repositorio/RepositorioWS.php');
Class DatosInsertarAspiranteWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN ALUMNO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  Se debe calcular la clave por default a setear y pasar como parámetro.
  ------------------------------------------------------------------------------------------------------------------- */

Class IngresoInsertarAspiranteWS {

    function insertar($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $email, $credenciales) {

        $aspirante = new DatosInsertarAspiranteWS();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();     
        $permitidos = array('wsingreso','siguv');
        
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $aspirante->codigoWS = (string) CODIGO_ERROR_AUTENTICACION;
            $aspirante->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $aspirante;
        }

        // PASO 2: Verifico integridad de los datos pasados
        
        // Quito caracteres invalidos 
        $email = filter_var($email, FILTER_SANITIZE_EMAIL);

        if ($ua == "" || $tipotitulo == "" || $anio_acad == ""  || $carrera == "" 
            || $tipo_ingreso == ""  || $fecha_insc == ""        || $apellido == "" 
            || $nombres == ""       || $tipo_doc == ""          || $nro_doc == "" || $sexo == "" 
            || $pais_documento == ""    || $fecha_nacimiento == ""
            // Valido nacionalidad catalogada
            || !in_array($nacionalidad, array(1, 2, 3, 4))                   
            || ($nacionalidad == 1 && $pais_origen != 54) 
            || ($nacionalidad != 1 && $pais_origen == 54)
            // Valido formato email        
            || !filter_var($email, FILTER_VALIDATE_EMAIL)
            ) 
        {   
            $aspirante->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
            $aspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $aspirante;
        }

        // PASO 3: Conexion a DB

        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);

        if ($objCC == '3') {
            $aspirante->codigoWS = (string) CODIGO_ERROR_CONEXION;
            $aspirante->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $aspirante;
        }
        
        // PASO 4: Desarrollo la funcion que necesito
        // Realiza la recodificación de datos de Ingreso UNL
        // Obtengo la clave por defecto y la codifico
        $enc = new bcrypt(10);
        $claveNueva = $enc->hash(md5(substr($nro_doc, 0, 5)));
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {

            // Determinar si se pide el dato CUIL
            $sql = "EXECUTE PROCEDURE ws_propuesta_requiere_cuil('{$carrera}')"; 
            $resultado = $objCC->Execute($sql);           
            $carrera_pide_cuil = empty($resultado->getRows()[0][0]);

            if ($carrera_pide_cuil && $nacionalidad == 1 && $numero_cuil == null ) {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
                $aspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS . ' Dato CUIL es obligatorio para la carrera.';
                return $aspirante;
            }
            
            //Sexo - conversion solo para G2
            if ($sexo == "M") {
                $sexo = "1";
            } else {
                $sexo = "2";
            }

            $sql = "EXECUTE PROCEDURE ws_insertar_aspirante(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $bindVars = array($ua, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $claveNueva, $nacionalidad, $pais_origen, $email);
            $res = $objCC->execute($sql, $bindVars);
                        
            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $aspirante->codigoWS = (string) CODIGO_OK;
                $aspirante->mensajeWS = MENSAJE_OK;
                $aspirante->codigoRetorno = $datosproc[0][0];
                $aspirante->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $aspirante;
            } else {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PROCEDIMIENTO;
                $aspirante->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $aspirante;
            }
        } else {
            /**
             *  Realizo la insercion en Postgres 
             */
            $rep = new RepositorioWS();
            
            // Determinar si se pide el dato CUIL
            $propuesta_requiere_cuil = $rep->propuesta_requiere_cuil($carrera, $objCC)[0][0];

            if ($propuesta_requiere_cuil && $nacionalidad == 1 && $numero_cuil == null ) {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
                $aspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS . ' Dato CUIL es obligatorio para la carrera.';
                return $aspirante;
            }
            if ($numero_cuil == "") $numero_cuil = null;

            $resul = $rep->insertarAspiranteNuevo(
                    $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, mb_convert_encoding($apellido, 'UTF-8'), mb_convert_encoding($nombres, 'UTF-8'), $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $email, $objCC);

            if (!empty($resul) && $resul[0]['istatus'] != 4) {
                $aspirante->codigoWS = (string) CODIGO_OK;
                $aspirante->mensajeWS = MENSAJE_OK;
                $aspirante->codigoRetorno = (string) $resul[0][0];
                $aspirante->mensajeRetorno = $resul[0][1];
                return $aspirante;
            } else {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PROCEDIMIENTO;
                $aspirante->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                $aspirante->mensajeRetorno = (string) $resul[0]['vcmsg'];
                return $aspirante;
            }
        }
    }
}

function insertarAspirante($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $email) {
    $servicio = new IngresoInsertarAspiranteWS();
    $credenciales = new Credenciales();
    $parametros = array('ua' =>$ua, 'tipotitulo' =>$tipotitulo,'anio_acad' =>$anio_acad,'carrera' =>$carrera,'sede' =>$sede,'tipo_ingreso' =>$tipo_ingreso,'fecha_insc' =>$fecha_insc,'apellido' =>$apellido,'nombres' =>$nombres, 'pais_documento' =>$pais_documento,'tipo_doc' =>$tipo_doc, 'nro_doc' =>$nro_doc,'numero_cuil' =>$numero_cuil,'fecha_nacimiento' =>$fecha_nacimiento,'sexo' =>$sexo,'nacionalidad' =>$nacionalidad,'pais_origen' =>$pais_origen, 'email'=> $email );
    Generales::logLlamada('insertarAspirante', $parametros, false);
    
    $resultado = $servicio->insertar($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $pais_documento, $tipo_doc, $nro_doc, $numero_cuil, $fecha_nacimiento, $sexo, $nacionalidad, $pais_origen, $email, $credenciales);
    
    $repositorio = new RepositorioWS();
    $repositorio->registrarAuditoria($parametros, $resultado, 'insertarAspirante', $_SERVER['PHP_AUTH_USER']);
    
    return json_encode($resultado);
}

?>
