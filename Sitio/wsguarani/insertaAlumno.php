<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

Class DatosinsertaAlumnoWS {

    // Variables Generales
    var $codigoWS;
    var $mensajeWS;

    // Variables Locales del procedimiento
}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN ALUMNO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR SIGUV PARA EL SERVICIO A ATILRA
  ------------------------------------------------------------------------------------------------------------------- */

Class AtilraInsertaAlumnoWS {

    function insertar($ua,$tipoTitulo,$anio_acad, $carrera, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $sexo, $usuario_ag) {

        $alumno = new DatosinsertaAlumnoWS();

        // PASO 1: Autentico el usuario y password de webservices
        $aut = Generales::autenticar();
        if ($aut ==CODIGO_ERROR_AUTENTICACION) {
            $alumno->codigoWS =CODIGO_ERROR_AUTENTICACION;
            $alumno->mensajeWS = "Error de autenticacion - Credenciales invalidas.";
            return $alumno;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($anio_acad == "" || $carrera == "" || $fecha_insc == "" || $apellido == "" || $nombres == "" ||
                $tipo_doc == "" || $nro_doc == "" || $sexo == "" || $usuario_ag == ""|| $ua=="" || $tipoTitulo=="") {
            $alumno->mensajeWS =MENSAJE_ERROR_PARAMETROS;
            $alumno->codigoWS =CODIGO_ERROR_PARAMETROS;
            return $alumno;
        }

        // PASO 3: Conexion a informix - Siempre se conecta a semipre_fbcb
        /*$host = 'guarani.intranet';
        $server = 'rectorado_csm';
        $db = Generales::obtenerDB("SFBCB");

        //$co = ('informix:host=' . $host . '; service=9086;database=' . $db . '; server=' . $server . '; protocol=olsoctcp; EnableScrollableCursors=1;');
        $co = ('informix:host=' . HOST . '; service=9086;database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
        $objCC = Genereles::conectar(true, $co);*/
        $db = Generales::recuperarDB($ua, $tipoTitulo);
        $objCC = Generales::conectar($db);
       
        if ($objCC == '3') {
            $alumno->codigoWS = CODIGO_ERROR_CONEXION;
            $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $alumno;
        }

        // PASO 4: Desarrollo la funcion que necesito
        $strSQL = "EXECUTE PROCEDURE sp820_insc_carr('FBCB', '" . $anio_acad . "', '" . $carrera . "', '" . $fecha_insc . "', '" . $apellido . "', '" . $nombres . "','" . $tipo_doc . "','" . $nro_doc . "','" . $sexo . "');";
        $res = $objCC->Execute($strSQL);

        if ($res->fields[0] == "-1") {
            $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
            $alumno->mensajeWS = "Error en el procedimiento de insercion y creacion del alumno.";
            return $alumno;
        }

        $strSQL = "EXECUTE PROCEDURE sp820_cambiar_usuarioag('" . $tipo_doc . "', '" . $nro_doc . "', '" . $usuario_ag . "');";
        $res = $objCC->Execute($strSQL);

        if ($res->fields[0] == 0) {
            $alumno->codigoWS = "0";
            $alumno->mensajeWS = "La funcion se ejecuto correctamente.";
            return $alumno;
        } else {
            $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
            $alumno->mensajeWS = "Error en el procedimiento de actualizacion del usuario de autogestion.";
            return $alumno;
        }
    }

}

function insertaAlumno($ua,$tipoTitulo,$anio_acad, $carrera, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $sexo, $usuario_ag) {
    $servicio = new AtilraInsertaAlumnoWS();
    $resultado = $servicio->insertar($ua,$tipoTitulo,$anio_acad, $carrera, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $sexo, $usuario_ag);
    return json_encode($resultado);
}

?>
