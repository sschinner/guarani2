
<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realiz� la operaci�n deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condici�n de error del lenguaje, que no es gestionada o en el llamado a la funci�n.
  ------------------------------------------------------------------------------------------ */

Class DatosBecas {

    // Variables Generales
    public $codigoWS = '';
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $cantMaterias;
    public $anioIngreso;
    
    public $listaMaterias = array();

}

/* ------------------------------------------------------------------------------------------------------------------
  DEVUELVE CANTIDAD Y LISTADO DE MATERIAS APROBADAS ENTRE FECHAS. SOLO CONSIDERA APROBACION POR EXAMEN.

 * ENTRADA: $ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento
 * PROCEDIMIENTO INVOCADO: web_serv_esta_inscripto ($carrera, $pais_documento, $tipo_documento, $nro_documento)
 * SALIDA: 2 valores - propiedad [esAlumno] => 0, -1, -2 ; [mensajePr] => La persona se puede inscribir a la carrera,
 * Alumno con legajo generado en la carrera, Aspirante a carrera en el período de Inscripción; Respectivamente.
  ------------------------------------------------------------------------------------------------------------------- */

Class becaAlumnoUNL {

    function verificar($ua, $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento, $fechaInicio, $fechaFin, $credenciales) {

        $alumno = new DatosBecas();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        // PASO 1: Autentico el usuario y password de webservices

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

        $fechaActual = date('m/d/Y');
        $fechaInicio1 = (trim($fechaInicio) == "") ? '01/01/1970' : $fechaInicio;
        $fechaFin1 = (trim($fechaFin) == "") ? $fechaActual : $fechaFin;

        if (!Generales::validar_formato_fecha($fechaInicio1)) {
            $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
            $alumno->mensajeWS = "Error de parametros - Campo fecha inicial incorrecto - Verifique (MM/dd/YYYY) ";
            return $alumno;
        } else if (!Generales::validar_formato_fecha($fechaFin1)) {
            $alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
            $alumno->mensajeWS = "Error de parametros - Campo fecha fin incorrecto - Verifique (MM/dd/YYYY) ";
            return $alumno;
        }


        if ($tipotitulo == 0) {
            $titulos = Generales::recuperarTipoTituloConCemed($ua);
            // $titulos = array_reverse($titulos);
        } else {
            $titulos = array($tipotitulo);
        }

        // PASO 3: Conexion a informix
        foreach ($titulos as $titulo) {
            $db = Generales::recuperarDB($ua, $titulo);
            $objCC = Generales::conectar($db);

            if ($objCC == '3') {

                $alumno->codigoWS = CODIGO_ERROR_CONEXION;
                $alumno->mensajeWS = MENSAJE_ERROR_CONEXION;
                return $alumno;
            }

            // PASO 4: Desarrollo la funcion que necesito
            if (($titulo != '7') && (!Generales::verificaUAPS($ua, $titulo))) {
                
                $instancia = 'g2';
                
                $strSQL = 'EXECUTE PROCEDURE web_serv_beca_alumno("' . $ua . '","' . $carrera . '", "' . $pais_documento . '","' .
                        $tipo_documento . '", "' . $nro_documento . '", "' . $fechaInicio1 . '", "' . $fechaFin1 . '");';

                $res = $objCC->Execute($strSQL);

                $datos = $res->getRows();

                if ($datos[0][0] != "4") {
                    $alumno->codigoWS = CODIGO_OK;
                    $alumno->mensajeWS = MENSAJE_OK;
                } else {
                    $alumno->codigoWS = '';
                }
            } else {
                $instancia = '';
                $fechaIniG3 = Generales::formato_fecha_g3($fechaInicio1);
                $fechaFinG3 = Generales::formato_fecha_g3($fechaFin1);
                $rep = new RepositorioWS();
                $datos = $rep->becaAlumno($carrera, $pais_documento, $tipo_documento, $nro_documento, $fechaIniG3, $fechaFinG3, $objCC);

                $alumno->codigoWS = CODIGO_OK;
                $alumno->mensajeWS = MENSAJE_OK;
            }

            if ($alumno->codigoWS == CODIGO_OK) {

                $arreglo = array();
                $optativa = 0;
                $tipo = array('E', 'O', 'Optativa');

                foreach ($datos as $resu) {
                    if (!empty($resu[0])) {
                        if (in_array($resu[2], $tipo) && $optativa < 4) {     //Contar 4 Electivas u Optativas como maximo.
                            $arreglo['codigoMateria'] = $resu[0];
                            $arreglo['nombreMateria'] = (string) Generales::decodificador($resu[1], $instancia);
                            if ($resu[2] != 'E') {
                                $arreglo['tipoMateria'] = 'Optativa';
                            } else {
                                $arreglo['tipoMateria'] = 'Electiva';
                            }
                            $arreglo['fechaExamen'] = $resu[3];
                            $arreglo['formaAprobacion'] = $resu[4];
                            $alumno->listaMaterias[] = $arreglo;
                            $optativa++;
                        } else if (!in_array($resu[2], $tipo)) {

                            $arreglo['codigoMateria'] = $resu[0];
                            $arreglo['nombreMateria'] = (string) Generales::decodificador($resu[1], $instancia);
                            $arreglo['tipoMateria'] = 'Comun';
                            $arreglo['fechaExamen'] = $resu[3];
                            $arreglo['formaAprobacion'] = $resu[4];
                            $alumno->listaMaterias[] = $arreglo;
                        }
                    }
                    
                    $anio = (string) $resu[7];
                    $alumno->codigoRetorno = (int)$resu[8];
                    $alumno->mensajeRetorno = $resu[9];
                }

                $alumno->cantMaterias = (int)count($alumno->listaMaterias);
                $alumno->anioIngreso = $anio;
                return $alumno;
            } else {
                $alumno->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $alumno->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $alumno;
            }
        }
    }

}

function becaAlumno($ua, $tipotitulo, $carrera, $tipo_documento, $nro_documento, $pais_documento, $fecha_inicio, $fecha_fin) {
    $servicio = new becaAlumnoUNL();
    $credenciales = new Credenciales();
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera, 'tipo_doc'=>$tipo_documento, 'nro_doc'=>$nro_documento, 'pais_documento'=>$pais_documento,'fecha_inicio'=> $fecha_inicio, 'fecha_fin'=> $fecha_fin);
    Generales::logLlamada('becaAlumno', $parametros, false);
    
    $resultado = $servicio->verificar(strtoupper(trim($ua)), $tipotitulo, $carrera, $pais_documento, $tipo_documento, $nro_documento, $fecha_inicio, $fecha_fin, $credenciales);
    return json_encode($resultado);
}
