<?php

namespace personalizacionUNL\operaciones\capic;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

class pagelet_reporte3 extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {

    protected $datos_consulta;
    protected $inscripcion;

    public function get_nombre() {
        return 'reporte';
    }

    function configurar() {
        $this->set_rpp(15);
        $this->set_columnas_reporte($this->get_columnas());
    }

    public function get_columnas() {
        $titulos = array();

        return $titulos;
    }

    /**
     * Recupera los datos
     * @param entero $pagina
     * Numero de p�gina que se desea recuperar
     * @param buleano $todo
     * Recuperar todos los datos
     * @return array
     */
    public function get_data_reporte($pagina = 0, $todo = false) {
        $i = 0;
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();

        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
        $operacion = kernel::ruteador()->get_id_operacion();

        $this->inscripcion['datosComision'] = $this->getDatosInscripcio();
        //$this->inscripcion['cantRegistros'] = count($this->inscripcion['datosIns']);
        $this->inscripcion['nombreTitulo'] = utf8_decode('Comisiones habilitadas');
        $this->inscripcion['url'] = kernel::vinculador()->crear($operacion, 'inscribir');
        return $this->inscripcion;
    }

    public function getDatosInscripcio() {

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
                    print_r("NO se pudo inscribir correctamente la persona en la base de datos de Capic");
//                    $url = ArmaLink("../notificarse_capic.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("NO se pudo inscribir correctamente la persona en la base de datos de Capic") . "&operacion=" . urlencode($parametros["operacion"]));
//                    header("Location: $url");
                    exit;
                }
            }

            //insertar alumno
            $strSQL = "select * from sp_insercion_alumno_capic('" . $parametros["_ua"] . "', '" . $parametros["carrera"] . "', '" . $parametros["legajo"] . "', '" . $datosAluCapic[0][0] . "', '" . $parametros["nro_inscripcion"] . "', '" . $datosAluCapic[0][3] . "')";
           
            $rsInserta = pg_Exec($objCon, $strSQL);
            // evaluo el resultado de la operacion
            $strStatus = pg_result($rsInserta, 0);

            if ($strStatus != 0) {
                pg_query($objCon, "rollback;");
                print_r("NO se pudo inscribir correctamente la persona en la base de datos de Capic");
//                $url = ArmaLink("../notificarse_capic.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("NO se pudo inscribir correctamente al alumno en la base de datos de Capic") . "&operacion=" . urlencode($parametros["operacion"]));
//                header("Location: $url");
                exit;
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
                print_r("NO se pudo actualizar el plan correspondiente al alumno en la base de datos de Capic");
//                $url = ArmaLink("../notificarse_capic.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("NO se pudo actualizar el plan correspondiente al alumno en la base de datos de Capic") . "&operacion=" . urlencode($parametros["operacion"]));
//                header("Location: $url");
                exit;
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
            $url = ArmaLink("../notificarse_capic.php?fStatus=" . urlencode(-1) . "&fMsg=" . urlencode("El plan del alumno NO existe") . "&operacion=" . urlencode($parametros["operacion"]));
            header("Location: $url");
            exit;
        }
        
        //PA me devuelve el promedio del alumno, en caso de no tener promedio cargo NULL
        $datosPA = catalogo::consultar('alumno', 'promedio_Alumno', $parametros);
        if ($datosPA[0][0] == -5) {
            $datosPA[0][0] = "NULL";
        }

        //GA me devuelve el a�o de cursada y el a�o de ingreso
        $datosEAC = catalogo::consultar('alumno', 'cursada_Ingreso_Capic', $parametros);
        
        if ($datosEAC[0][2] == -4) {
            $datosEAC[0][2] = "NULL";
        }
        $strEstadoEjCtrs = "A"; //VER ESTA VARIABLE!!!!!!!!!!*******************##########@@@@@######@@#
        // Inscripci�n en la comisi�n
        $strSQL = "select * from sp_i_inscCursadas('" . $parametros["_ua"] . "', '" . $parametros["carrera"] . "', '" . $datosAluCapic[0][0] . "', '" . $parametros["legajo"] . "', '" . $parametros["comision"] . "', '" . $strEstadoEjCtrs . "', '" . $datosGA[0][0] . "', '" . $datosGA[0][1] . "', '" . $datosPA[0][0] . "', '" . $datosEAC[0][2] . "', '" . $datosAluCapic[0][3] . "', '" . $parametros["materia"] . "')";
        
        $rsInscCur = pg_Exec($objCon, $strSQL);

        // evaluo el resultado de la operacion
        $strStatus = pg_result($rsInscCur, 0);
        
        $strMsg = pg_result($rsInscCur, 1);
        //$strStatus = 1;
        //$strMsg    = "Esto es una prueba";
        if ($strStatus != 0) {
            // limpio la variable de session del ultimo punto de control (que incluye a otros)
            pg_query($objCon, "rollback;");
            return "error";
//            $url = ArmaLink("../notificarse_capic.php?fStatus=" . urlencode($strStatus) . "&fMsg=" . urlencode($strMsg) . "&operacion=" . urlencode($parametros["operacion"]));
//            header("Location: $url");
            exit;
        }

        // hago el COMMIT
        pg_query($objCon, "commit;");
        return true;
        // print_r("se inscribio bien");
        //return $arrConvertido;
    }

    protected function convertUtf8($original, $indices) {
        $arrConvertido = array();
        foreach ($original as $key => $value) {
            $arrConvertido[$key][$indices[0]] = $value[$indices[0]];
            $arrConvertido[$key][$indices[1]] = utf8_decode($value[$indices[1]]);
            $arrConvertido[$key][$indices[2]] = utf8_decode($value[$indices[2]]);
            $arrConvertido[$key][$indices[3]] = utf8_decode($value[$indices[3]]);
            $arrConvertido[$key][$indices[4]] = utf8_decode($value[$indices[4]]);
            $arrConvertido[$key][$indices[5]] = utf8_decode($value[$indices[5]]);
            $arrConvertido[$key][$indices[6]] = utf8_decode($value[$indices[6]]);
        }
        return $arrConvertido;
    }

    /**
     * Retorna la cantidad de datos
     * @return entero
     */
    protected function get_total_registros() {
        return count($this->get_data_reporte(0, true));
    }

}
