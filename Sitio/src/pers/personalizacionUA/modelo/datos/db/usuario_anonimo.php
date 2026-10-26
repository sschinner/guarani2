<?php

namespace personalizacionUA\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;
use siu\operaciones\_comun\util\caracteres_especiales;
use \siu\modelo\entidades;

class usuario_anonimo extends \siu\modelo\datos\db\usuario_anonimo {
    
     /**
     * parametros: _ua, anio_academico, periodo_lectivo, materia, turno, sede, dia, carrera, anio_cursada
     * cache: no
     * filas: n
     */
    function horarios_cursadas($parametros)
    {
        // Lista las comisiones de un per�odo lectivo, mostrando el aula, horario de cursada, tipo de clase, etc

        // Filtros
        $filtro_sede = '';
        if ($parametros['sede'] != "''"){
            $filtro_sede = " AND sga_comisiones.sede = {$parametros['sede']} ";
        }

        $filtro_carrera = '';
        if ($parametros['carrera'] != "''"){
            $filtro_carrera = " AND sga_comisiones.materia IN (SELECT DISTINCT materia FROM sga_atrib_mat_plan WHERE unidad_academica = {$parametros['_ua']} AND carrera = {$parametros['carrera']}) ";
        }

        $filtro_materia = '';
        if ($parametros['materia'] != "''"){
            $filtro_materia = " AND sga_comisiones.materia = {$parametros['materia']} ";
        }
        $filtro_periodo_lectivo = '';
        if ($parametros['periodo_lectivo'] != "''"){
            $filtro_periodo_lectivo = " AND sga_periodos_lect.periodo_lectivo = {$parametros['periodo_lectivo']} ";
        }

        $filtro_anio_de_cursada = '';
        if ($parametros['anio_cursada'] != "''"){
            $filtro_anio_de_cursada = " AND sga_comisiones.materia IN (SELECT DISTINCT materia FROM sga_atrib_mat_plan WHERE anio_de_cursada = {$parametros['anio_cursada']}) ";
        }

        $filtro_turno = '';
        if ($parametros['turno'] != "''"){
            $filtro_turno = " AND sga_comisiones.turno = {$parametros['turno']} ";
        }
         $filtro_dia_semana = '';
         if ($parametros['dia'] != "''"){
            $filtro_dia_semana = " AND sga_asignaciones.dia_semana = {$parametros['dia']} ";
         }

        
        // Consulta de comisiones 
        // Ordenado por: nombre_sede + fecha inicio periodo_lectivo + periodo lectivo + nombre_materia + nombre comision + dia semana + hora inicio clase
        $sql = "SELECT 
                     sga_comisiones.comision as comision, 
                     sga_comisiones.nombre as comision_nombre, 
                     sga_comisiones.periodo_lectivo as periodo_lectivo, 
                     sga_comisiones.materia as materia, 
                     sga_materias.nombre as materia_nombre,
                     sga_materias.nombre_reducido as materia_nombre_red,
                     sga_comisiones.turno as turno, 
                     DECODE(sga_comisiones.turno,'M', 'Ma�ana','T','Tarde','N','Noche',' ') as turno_desc,
                     sga_comisiones.sede as sede,
                     sga_sedes.nombre as sede_nombre,
                     sga_comisiones.capacidad as cupo,
                     sga_comisiones.grupo_carrera as grupo_carrera,
                     sga_comisiones.carrera as carrera,
                     sga_comisiones.plan as plan,
                     
                     -- datos de la asignacion
                     sga_edificios.nombre as edificio,
                     sga_asignaciones.aula as aula,
                     sga_aulas.nombre_aula as aula_nombre,
                     sga_asignaciones.dia_semana as dia_semana,
                     DECODE (sga_asignaciones.dia_semana, 1, 'Domingo', 2, 'Lunes', 3, 'Martes', 4, 'Mi�rcoles', 5, 'Jueves', 6, 'Viernes', 7, 'S�bado') as dia_semana_desc,
                     to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M') as hs_comienzo_clase,
                     to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M') as hs_finaliz_clase,
                     NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'), '     ') || ' - ' || NVL(to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'     ') as inicio_fin_clase,
                     sga_tipo_clase.descripcion as tipo_clase_desc,
                     sga_periodos_lect.fecha_inicio as pl_fecha_inicio,
					 sga_comisiones.capacidad as cupo

                  FROM sga_periodos_lect,
                       sga_comisiones,
                       sga_materias,
                       sga_asign_clases, 
                       sga_asignaciones,
					   sga_sedes,
                                           sga_edificios,
                       OUTER sga_tipo_clase,
                       OUTER sga_aulas
                 WHERE sga_periodos_lect.anio_academico  = {$parametros['anio_academico']}
                   AND sga_comisiones.anio_academico  = sga_periodos_lect.anio_academico
                   AND sga_comisiones.periodo_lectivo = sga_periodos_lect.periodo_lectivo
                   AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                   AND sga_materias.materia = sga_comisiones.materia
                   AND sga_asign_clases.comision   = sga_comisiones.comision
				   AND sga_sedes.sede = sga_comisiones.sede 
                   AND sga_asignaciones.asignacion = sga_asign_clases.asignacion
                   AND sga_tipo_clase.tipo_clase = sga_asign_clases.tipo_clase
                   AND sga_aulas.edificio = sga_asignaciones.edificio
                   AND sga_asignaciones.edificio = sga_edificios.edificio
                   AND sga_aulas.aula     = sga_asignaciones.aula
                   AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
                   AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
                   AND sga_periodos_lect.fecha_public_com <= TODAY
                   $filtro_sede
                   $filtro_carrera
                   $filtro_periodo_lectivo
                   $filtro_materia
                   $filtro_turno
				   $filtro_dia_semana
                   $filtro_anio_de_cursada
               ORDER BY 10, 24, 3, 5, 2, 18, 20
               ";
        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$aux = array();


		foreach($datos as $dato){			
			$aux[$dato['SEDE']]['SEDE']			= $dato['SEDE']; 
			$aux[$dato['SEDE']]['SEDE_NOMBRE']	= $dato['SEDE_NOMBRE']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['PERIODO_LECTIVO']= $dato['PERIODO_LECTIVO']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['MATERIA']= $dato['MATERIA']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['MATERIA_NOMBRE']= $dato['MATERIA_NOMBRE']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['HORARIOS'][]= array(
					'COMISION'				=> $dato['COMISION'],	
					'COMISION_NOMBRE'		=> $dato['COMISION_NOMBRE'],	
					'TURNO'					=> $dato['TURNO'],	
					'TURNO_DESC'			=> $dato['TURNO_DESC'],
					'EDIFICIO'				=> $dato['EDIFICIO'],	
					'AULA'					=> $dato['AULA'],	
					'AULA_NOMBRE'			=> $dato['AULA_NOMBRE'],	
					'DIA_SEMANA'			=> $dato['DIA_SEMANA'],	
					'DIA_SEMANA_DESC'		=> $dato['DIA_SEMANA_DESC'],	
					'HS_COMIENZO_CLASE'		=> $dato['HS_COMIENZO_CLASE'],	
					'HS_COMIENZO_CLASE'		=> $dato['HS_COMIENZO_CLASE'],	
					'HS_FINALIZ_CLASE'		=> $dato['HS_FINALIZ_CLASE'],	
					'INICIO_FIN_CLASE'		=> $dato['INICIO_FIN_CLASE'],	
					'TIPO_CLASE_DESC'		=> $dato['TIPO_CLASE_DESC'],
					'PL_FECHA_INICIO'		=> $dato['PL_FECHA_INICIO'],
					'CUPO'					=> $dato['CUPO'],
			); 

		}
				
        return $aux;
    }
}
