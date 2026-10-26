<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

Class DatosAlumnoUNL {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $esAlumno;
    public $mensajePr = '';

}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION DETERMINA SI UNA PERSONA SE PUEDE INSCRIBIR A UNA CARRERA

 * ENTRADA: $ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento
 * PROCEDIMIENTO INVOCADO: web_serv_esta_inscripto ($carrera, $pais_documento, $tipo_documento, $nro_documento)
 * SALIDA: 2 valores - propiedad [esAlumno] => 0, -1, -2 ; [mensajePr] => La persona se puede inscribir a la carrera,
 * Alumno con legajo generado en la carrera, Aspirante a carrera en el período de Inscripción; Respectivamente.
  ------------------------------------------------------------------------------------------------------------------- */

Class EsAlumnoUNL {

    function verificar($ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento,$credenciales) {

        $alumno = new DatosAlumnoUNL();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'siguv');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        //$aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $alumno->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $alumno->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $alumno;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $pais_documento == "" || $tipo_documento == "" || $nro_documento == "") {
            $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
            $alumno->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $alumno;
        }

        if ($tipotitulo == 0) {
            $titulos = Generales::recuperarTipoTituloConCemed($ua);
            //$titulos = array_reverse($titulos);
        } else {
            $titulos = array($tipotitulo);
        }

        foreach ($titulos as $titulo) {


            // PASO 3: Conexion a informix
            $tipotitulo = 1; // HARDCODE POR ERROR - SE VA A MODIFICAR A LA BREVEDAD
            $db = Generales::recuperarDB($ua, $titulo);
            $objCC = Generales::conectar($db);

            if ($objCC == '3') {

                $alumno->codigoWS = CODIGO_ERROR_CONEXION;
                $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $alumno;
            }

            // PASO 4: Desarrollo la funcion que necesito
            if (($titulo != '7') && (!Generales::verificaUAPS($ua, $titulo))) {
                $strSQL = 'EXECUTE PROCEDURE web_serv_esta_inscripto("' . $carrera . '", "' . $pais_documento . '","' .
                        $tipo_documento . '", "' . $nro_documento . '");';

                $res = $objCC->Execute($strSQL);

                if ($res->fields[0] != "") {
                    $datos = $res->getRows();
                    $alumno->codigoWS = CODIGO_OK;
                    $alumno->mensajeWS =  MENSAJE_OK;
                    $alumno->esAlumno = $datos[0][0] == 0 ? false : true;
                    $alumno->mensajePr = utf8_encode($datos[0][1]);
                    return $alumno;
                } else {
                    $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                }
            } else {
                /**
                 *  Realizo la consulta en Postgres
                 */
               
                $rep = new RepositorioWS();
                $resultado = $rep->estaInscripto($carrera, $pais_documento, $tipo_documento, $nro_documento, $objCC);
              
                if (!empty($resultado)) {
                    $alumno->codigoWS = CODIGO_OK;
                    $alumno->mensajeWS =  MENSAJE_OK;
                    $alumno->esAlumno = $resultado[0][0] == 0 ? false : true;
                    $alumno->mensajePr = $resultado[0][1];
                    return $alumno;
                } else {
                    $datos->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                    $datos->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                }
            }
        }
        return $alumno;
    }

}

function estaInscripto($ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento) {
    $servicio = new EsAlumnoUNL();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=>$ua, 'tipotitulo'=>$tipotitulo,'carrera'=>$carrera,'pais_documento'=>$pais_documento, 'tipo_documento'=>$tipo_documento, 'nro_documento'=>$nro_documento );
    Generales::logLlamada('estaInscripto', $parametros, false);
    
    $resultado = $servicio->verificar(strtoupper(trim($ua)), $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento,$credenciales);
    return json_encode($resultado);
}
