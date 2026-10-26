<?php

namespace personalizacionUA\operaciones\capic;

use Exception;
use kernel\kernel;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\db\db;
use kernel\util\u;
use kernel\util\validador;
use siu\errores\error_procesar_datos_censales;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;
use siu\modelo\guarani_notificacion;

set_include_path('.:' . substr_replace(dirname(__FILE__), '/', -45));
require("conexionCapic/funciones.php");

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador {

    function accion__index() {

        $pagelet = $this->vista()->pagelet('formulario');

        $pagelet->ver_pagina(1);
    }

    function accion__ver_pagina() {
        $pagina = kernel::url()->get_param('pagina', 'get');
        $columna = kernel::url()->get_param('col', 'get');
        $orden = kernel::url()->get_param('ord', 'get');

        $pagelet = $this->vista()->pagelet('formulario');
        $pagelet->ver_pagina($pagina, $columna, $orden);

        kernel::renderer()->add($pagelet);
    }

    function accion__guardar() {

        if (kernel::request()->isPost()) {

            $materia = kernel::request()->getPost('cod_materia');
            $pagelet = $this->vista()->mostar();
            $this->add_var('formulario', $pagelet);
            kernel::renderer()->add($this->vista()->pagelet('formulario'));
        }
    }

    function accion__inscribir() {

        if (kernel::request()->isPost()) {


            $parametros["materia"] = kernel::request()->getPost('id_materia');
            $parametros["comision"] = kernel::request()->getPost('comision');
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $legajo = kernel::persona()->get_id_legajo_activo();
            $plan = kernel::persona()->get_id_plan_activo();
            $carrera = kernel::persona()->get_id_carrera_activa();

            $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
            $parametros['plan'] = kernel::persona()->get_id_plan_activo();
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $parametros['_ua'] = $uA;

            $datosAluCapic = catalogo::consultar('alumno', 'datos_Alumno_Capic', $parametros);

            $datosAluGuarani = catalogo::consultar('alumno', 'datos_principales', $parametros);
           
            $objCon = conectar_postgre();
            // ACA EMPIEZA UNA TRANSACCION, ya que grabo la inscripcion y los mensajes (si los hay)
            pg_query($objCon, "begin;");
            // ----------------------------------------------------
            // Se realiza la secci�n de validaciones para ver si el alumno se encuentra inscripto en Capic
            $strSQL = "select * from sp_alumno_capic('" . $parametros["_ua"] . "', '" . $parametros["nro_inscripcion"] . "', '" . $parametros["carrera"] . "', '" . $datosAluCapic[0][0] . "')";

            $rsAlumno = pg_Exec($objCon, $strSQL);



            // evaluo el resultado de la operacion
            $strStatus = pg_result($rsAlumno, 0);

            
            $strMsg = pg_result($rsAlumno, 1);
            
            if (($strStatus == -1) || ($strStatus == -3)) {
                if ($strStatus == -3) {
                    //insertar la persona

                    $parametros["Nombres"] = iconv("ISO-8859-1", "utf-8", $datosAluGuarani[0][1]);
                    $parametros["Apellido"] = iconv("ISO-8859-1", "utf-8", $datosAluGuarani[0][0]);

                    $strSQL = "select * from sp_insercion_persona_capic('" . $parametros["_ua"] . "', '" . $parametros["nro_inscripcion"] . "', '" . $datosAluCapic[0][4] . "', '" . $parametros["Apellido"] . "', '" . $parametros["Nombres"] . "', '" . $datosAluCapic[0][1] . "', '" . $datosAluCapic[0][5] . "', '" . $datosAluCapic[0][2] . "')";

                    $rsInsertaP = pg_Exec($objCon, $strSQL);

                    // evaluo el resultado de la operacion
                    $strStatus = pg_result($rsInsertaP, 0);

                    if ($strStatus != 0) {
                        pg_query($objCon, "rollback;");
                        $texto = utf8_decode('NO se pudo inscribir correctamente la persona en la base de datos de Capic');
                        $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                        $this->add_var('mensajes', $mensajes);
                        kernel::renderer()->add($this->vista()->pagelet('formulario2'));
                        //exit;
                    }
                }

                //insertar alumno

                $strSQL = "select * from sp_insercion_alumno_capic('" . $parametros["_ua"] . "', '" . $parametros["carrera"] . "', '" . $parametros["legajo"] . "', '" . $datosAluCapic[0][0] . "', '" . $parametros["nro_inscripcion"] . "', '" . $datosAluCapic[0][3] . "')";

                $rsInserta = pg_Exec($objCon, $strSQL);

                // evaluo el resultado de la operacion
                $strStatus = pg_result($rsInserta, 0);

                if ($strStatus != 0) {
                    pg_query($objCon, "rollback;");
                    $texto = utf8_decode('NO se pudo inscribir correctamente la persona en la base de datos de Capic');
                    $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                    $this->add_var('mensajes', $mensajes);
                    kernel::renderer()->add($this->vista()->pagelet('formulario2'));
                    //exit;
                }
                pg_query($objCon, "commit;");
            } elseif ($strStatus == -2) {
                //actualizar plan de alumno

                $strSQL = "select * from sp_modificar_plan_alumno_capic('" . $parametros["_ua"] . "', '" . $parametros["carrera"] . "', '" . $parametros["legajo"] . "', '" . $datosAluCapic[0][0] . "')";
                //    echo "    Plan de Alumno:    ".$strSQL;
                $rsActualiza = pg_Exec($objCon, $strSQL);
                // evaluo el resultado de la operacion
                $strStatus = pg_result($rsActualiza, 0);
                if ($strStatus != 0) {
                    pg_query($objCon, "rollback;");
                    // print_r("NO se pudo actualizar el plan correspondiente al alumno en la base de datos de Capic");
                    $texto = utf8_decode('NO se pudo actualizar el plan correspondiente al alumno en la base de datos de Capic');
                    $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                    $this->add_var('mensajes', $mensajes);
                    kernel::renderer()->add($this->vista()->pagelet('formulario2'));
                    // exit;
                }
                pg_query($objCon, "commit;");
            }

            $objCon = conectar_postgre();
            // ACA EMPIEZA UNA TRANSACCION, ya que grabo la inscripcion y los mensajes (si los hay)
            pg_query($objCon, "begin;");


            //Llamo a los procedimientos que me devuelven los datos que necesito para el ranking de cursadas
            // GA me devuelve la cantidad de materias aprobadas y la cantidad de materias del plan

            $datosGA = catalogo::consultar('alumno', 'ranking_Cursadas_Capic', $parametros);
             
            if ($datosGA[0][1] == -3) {
                pg_query($objCon, "rollback;");

                $texto = utf8_decode('El plan del alumno NO existe');
                $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                $this->add_var('mensajes', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario2'));
                //exit;
            }
            if ($datosGA[0][0] == ''){
                        $datosGA[0][0]=0;
            }
    
            //PA me devuelve el promedio del alumno, en caso de no tener promedio cargo NULL
            $datosPA = catalogo::consultar('alumno', 'promedio_Alumno', $parametros);
            
            if ($datosPA[0][0] == -5) {
                $datosPA[0][0] = NULL;
            }
            
            //GA me devuelve el a�o de cursada y el a�o de ingreso
            $datosEAC = catalogo::consultar('alumno', 'cursada_Ingreso_Capic', $parametros);
            
            if ($datosEAC[0][2] == -4) {
                $datosEAC[0][2] = 0;
            }
           //var_dump($datosEAC);die;
            
            $strEstadoEjCtrs = "A"; //VER ESTA VARIABLE!!!!!!!!!!*******************##########@@@@@######@@#
            // Inscripci�n en la comisi�n

            $strSQL = "select * from sp_i_inscCursadas('" . $parametros["_ua"] . "',"
                    . " '" . $parametros["carrera"] . "', '" . $datosAluCapic[0][0] . "', "
                    . "'" . $parametros["legajo"] . "', '" . $parametros["comision"] . "',"
                    . " '" . $strEstadoEjCtrs . "', '" . $datosGA[0][0] . "', '" . $datosGA[0][1] . "',"
                    . " '" . $datosPA[0][0] . "', '" . $datosEAC[0][2] . "', '" . $datosAluCapic[0][3] . "',"
                    . " '" . $parametros["materia"] . "')";
            
            $rsInscCur = pg_Exec($objCon, $strSQL);

            // evaluo el resultado de la operacion
            $strStatus = pg_result($rsInscCur, 0);

            $strMsg = pg_result($rsInscCur, 1);

            //$strStatus = 1;
            //$strMsg    = "Esto es una prueba";
            if ($strStatus != 0) {
                // limpio la variable de session del ultimo punto de control (que incluye a otros)
                pg_query($objCon, "rollback;");
                $texto = utf8_decode($strMsg . " " . $parametros["comision"] . " para la materia " . $parametros["materia"]);
                $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                $this->add_var('mensajes', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario2'));
            } else {
                pg_query($objCon, "commit;");
                $texto = utf8_decode($strMsg);
                $mensajes[] = new guarani_notificacion(guarani_notificacion::info, $texto);
                $this->add_var('mensajes2', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario2'));
            }
        }
    }

    function accion__darBaja() {

        if (kernel::request()->isPost()) {
            $parametros["comision"] = kernel::request()->getPost('comision');
            $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $parametros['_ua'] = $uA;

            $objCon = conectar_postgre();
            // ACA EMPIEZA UNA TRANSACCION, ya que grabo la inscripcion y los mensajes (si los hay)
            pg_query($objCon, "begin;");

            $strSQL = "select * from sp_d_insccursadas('" . $parametros["_ua"] . "', '" . $parametros["carrera"] . "', '" . $parametros["legajo"] . "', '" . $parametros["comision"] . "')";
            //echo($strSQL);
            $rsDesinscCurs = pg_Exec($objCon, $strSQL);
            // evaluo el resultado de la operacion
            $strStatus = pg_result($rsDesinscCurs, 0);
            $strMsg = pg_result($rsDesinscCurs, 1);
            //echo($strMsg);
            if ($strStatus != 0) {
                //$objCon->RollbackTrans();
                pg_query($objCon, "rollback;");
                $texto = utf8_decode($strMsg /* . " " . $parametros["comision"] . " para la materia " . $parametros["materia"] */);
                $mensajes[] = new guarani_notificacion(guarani_notificacion::error, $texto);
                $this->add_var('mensajes', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario2'));
            } else {
                pg_query($objCon, "commit;");
            }
        }
    }

}

?>
