<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;

class comisiones
{
	/**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function get_datos_comision($parametros)
	{
		$sql = "SELECT 
				  c.comision,
				  c.nombre, 
				  c.sede, 
				  c.anio_academico, 
				  c.periodo_lectivo, 
				  c.catedra,
				  DECODE(c.turno,'M','Mañana','T','Tarde','N','Noche','') as turno_desc,
				  c.capacidad as cupo,
				  c.materia as materia,
				   m.nombre_reducido as materia_nombre,
				  DECODE(m.promovible , 'N', 'R', ( DECODE( (SELECT COUNT(*) FROM  sga_det_escala as d  WHERE d.resultado = 'P' AND d.escala_notas = c.escala_notas), 0 , 'R', 'P'))) as calidad_insc
			 FROM sga_comisiones as c
				  sga_materias as m 
			 WHERE c.unidad_academica = m.unidad_academica 
			   AND c.materia = m.materia
			   AND c.comision = {$parametros['comision']} ";

		$datos = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
		return $datos;
	}
 
 	/**
	 * parametros: comision
	 * cache: memoria
	 * filas: n
	 */
	function get_docentes_comision($parametros)
	{
		// Recupera la lista de docentes asignados a una comision
		$sql = "SELECT 
				sga_personas.unidad_academica as unidad_academica,
				sga_personas.nro_inscripcion as nro_inscripcion,
				sga_personas.apellido as apellido,
				sga_personas.nombres as nombres,
				sga_docentes.legajo as legajo,
				sga_docentes_com.responsabilidad as responsabilidad,
				sga_responsab_doc.descripcion as responsab_desc 
			FROM
				sga_docentes_com,
				sga_docentes,
				sga_personas,
				OUTER sga_responsab_doc
			WHERE sga_docentes_com.comision = {$parametros['comision']} 
			  AND sga_docentes.legajo = sga_docentes_com.legajo
			  AND sga_personas.unidad_academica = sga_docentes.unidad_academica
			  AND sga_personas.nro_inscripcion  = sga_docentes.nro_inscripcion
			  AND sga_responsab_doc.responsabilidad = sga_docentes_com.responsabilidad
			ORDER BY  3, 4";

		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}

	/**
	 * parametros: comision, visible_al_alumno
	 * param_null: visible_al_alumno
	 * cache: memoria
	 * filas: n
	 */
	function get_parciales($parametros)
	{
		// Recupera los datos de las evaluaciones parciales de la comision. No los resultados de las notas de los alumnos.
		
	    // visible_al_alumno = S-Las evaluaciones visibles al alumno / N - Las evaluaciones que no son visibles al alumno
	    
	    $filtro_visible_al_alumno = "";
	    if($parametros['visible_al_alumno'] != "''"){
	       $filtro_visible_al_alumno = " AND sga_tipo_eval_parc.visible_al_alumno = 'S' ";
		}

	    // Recupera evaluaciones parciales y las notas de los alumnos...
		$sql = "SELECT	sga_atr_eval_parc.comision as comision,
						sga_atr_eval_parc.evaluacion as evaluacion,
						sga_eval_parc.descripcion as evaluacion_desc,
						sga_tipo_eval_parc.descripcion as tipo_evaluacion,
						sga_cron_eval_parc.fecha_hora as fecha_hora_parcial,
						to_char(sga_cron_eval_parc.fecha_hora, '%d/%m/%Y') as sfecha_parcial,
						to_char(sga_cron_eval_parc.fecha_hora, '%Y%m%d%H%M%S')||'_'||sga_atr_eval_parc.evaluacion as fecha_idevaluacion
				FROM 	sga_atr_eval_parc,
						sga_eval_parc,
						sga_cron_eval_parc,
						sga_tipo_eval_parc
				WHERE	sga_atr_eval_parc.comision    = {$parametros['comision']}
				AND     sga_eval_parc.evaluacion      = sga_atr_eval_parc.evaluacion						
				AND		sga_cron_eval_parc.comision   = sga_atr_eval_parc.comision
				AND		sga_cron_eval_parc.evaluacion = sga_atr_eval_parc.evaluacion
				AND		sga_tipo_eval_parc.tipo_evaluac_parc = sga_eval_parc.tipo_evaluac_parc
				$filtro_visible_al_alumno
				ORDER BY 5, 2
				";
			RETURN kernel::db()->consultar($sql);
	}

	/**
	 * parametros: comision, visible_al_alumno
	 * param_null: visible_al_alumno
	 * cache: memoria
	 * filas: n
	 */
	function get_parciales_alumnos($parametros)
	{
	    // visible_al_alumno = S-Las evaluaciones visibles al alumno / N - Las evaluaciones que no son visibles al alumno
	    $filtro_visible_al_alumno = "";
	    if($parametros['visible_al_alumno'] != "''"){
	       $filtro_visible_al_alumno = " AND sga_tipo_eval_parc.visible_al_alumno = 'S' ";
		}

	    // Recupera evaluaciones parciales y las notas de los alumnos...
		$sql = "SELECT	sga_atr_eval_parc.comision as comision,
						sga_atr_eval_parc.evaluacion as evaluacion,
						sga_eval_parc_alum.fecha_hora as fecha_hora_parcial,
						to_char(sga_eval_parc_alum.fecha_hora, '%d/%m/%Y') as sfecha,
                        to_char(sga_cron_eval_parc.fecha_hora, '%Y%m%d%H%M%S')||'_'||sga_atr_eval_parc.evaluacion as fecha_idevaluacion,
						sga_personas.apellido as alumno_apellido,
						sga_personas.nombres as alumno_nombres,
						sga_eval_parc_alum.unidad_academica as unidad_academica,
						sga_eval_parc_alum.carrera as carrera,
						sga_eval_parc_alum.legajo as legajo,
						sga_eval_parc_alum.nota as nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						sga_eval_parc_alum.resultado as resultado,
						DECODE( sga_eval_parc_alum.resultado, 'A', 'Aprobado' , 'R', 'Reprobado' , 'U', 'Ausente' , 'P', 'Promocionado' ) as resultado_desc,
						sga_eval_parc_alum.observaciones as observaciones,
						sga_eval_parc_alum.corregido_por as corregido_por
				FROM 	sga_eval_parc,
						sga_atr_eval_parc,
						sga_cron_eval_parc,
						sga_tipo_eval_parc,
						sga_eval_parc_alum,
						sga_alumnos, 
						sga_personas,
						OUTER sga_det_escala 
				WHERE	sga_atr_eval_parc.comision	  = {$parametros['comision']}
				AND     sga_atr_eval_parc.evaluacion  = sga_eval_parc.evaluacion
				AND		sga_cron_eval_parc.comision   = sga_atr_eval_parc.comision
				AND		sga_cron_eval_parc.evaluacion = sga_atr_eval_parc.evaluacion
                AND		sga_tipo_eval_parc.tipo_evaluac_parc = sga_eval_parc.tipo_evaluac_parc
				$filtro_visible_al_alumno
				AND		sga_eval_parc_alum.comision          = sga_atr_eval_parc.comision
				AND		sga_eval_parc_alum.evaluacion        = sga_atr_eval_parc.evaluacion
				AND		sga_det_escala.escala_notas          = sga_atr_eval_parc.escala_notas
				AND		sga_det_escala.nota                  = sga_eval_parc_alum.nota
				AND		sga_alumnos.unidad_academica = sga_eval_parc_alum.unidad_academica
				AND		sga_alumnos.carrera          = sga_eval_parc_alum.carrera
				AND		sga_alumnos.legajo           = sga_eval_parc_alum.legajo
				AND		sga_personas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
				ORDER BY 5, 6, 7
				";

			return kernel::db()->consultar($sql); 
	}

/**
	 * parametros: comision
	 * cache: memoria
	 * filas: n
	 */
	function get_alumnos_de_parciales_insc_acta($parametros)
	{
	    // Recupera los alumnos de evaluaciones parciales, inscripciones y acta de cursada
	    // Usa el UNION simple (sin el ALL) para que no traiga registros duplicados.
		$sql = "
				-- Alumnos de las evaluaciones parciales de la comsion
				SELECT	sga_personas.apellido as alumno_apellido,
						sga_personas.nombres as alumno_nombres,
						sga_eval_parc_alum.unidad_academica as unidad_academica,
						sga_eval_parc_alum.carrera as carrera,
						sga_eval_parc_alum.legajo as legajo
				FROM 	sga_atr_eval_parc,
						sga_eval_parc_alum,
						sga_alumnos, 
						sga_personas
				WHERE	sga_atr_eval_parc.comision = {$parametros['comision']}
				AND		sga_eval_parc_alum.comision   = sga_atr_eval_parc.comision
				AND		sga_eval_parc_alum.evaluacion = sga_atr_eval_parc.evaluacion
				AND		sga_alumnos.unidad_academica = sga_eval_parc_alum.unidad_academica
				AND		sga_alumnos.carrera          = sga_eval_parc_alum.carrera
				AND		sga_alumnos.legajo           = sga_eval_parc_alum.legajo
				AND		sga_personas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
				UNION
				-- Inscripciones a cursadas
				SELECT	sga_personas.apellido as alumno_apellido,
						sga_personas.nombres as alumno_nombres,
						sga_alumnos.unidad_academica as unidad_academica,
						sga_alumnos.carrera as carrera,
						sga_alumnos.legajo as legajo
				FROM 	sga_insc_cursadas,
						sga_alumnos, 
						sga_personas
				WHERE	sga_insc_cursadas.comision			 = {$parametros['comision']}
				AND		sga_alumnos.unidad_academica = sga_insc_cursadas.unidad_academica
				AND		sga_alumnos.carrera          = sga_insc_cursadas.carrera
				AND		sga_alumnos.legajo           = sga_insc_cursadas.legajo
				AND		sga_personas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion				
				UNION
				-- Alumnos del acta de cursadas abierta
				SELECT	sga_personas.apellido as alumno_apellido,
						sga_personas.nombres as alumno_nombres,
						sga_alumnos.unidad_academica as unidad_academica,
						sga_alumnos.carrera as carrera,
						sga_alumnos.legajo as legajo
				FROM 	sga_curs_pendiente, 
						sga_alumnos, 
						sga_personas
				WHERE	sga_curs_pendiente.comision	 = {$parametros['comision']}
				AND		sga_alumnos.unidad_academica = sga_curs_pendiente.unidad_academica
				AND		sga_alumnos.carrera          = sga_curs_pendiente.carrera
				AND		sga_alumnos.legajo           = sga_curs_pendiente.legajo
				AND		sga_personas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion				
				UNION
				-- Alumnos del acta de cursadas cerrada
				SELECT	sga_personas.apellido as alumno_apellido,
						sga_personas.nombres as alumno_nombres,
						sga_alumnos.unidad_academica as unidad_academica,
						sga_alumnos.carrera as carrera,
						sga_alumnos.legajo as legajo
				FROM 	sga_actas_cursado,
						sga_det_acta_curs, 
						sga_alumnos, 
						sga_personas
				WHERE	sga_actas_cursado.comision			 = {$parametros['comision']}
				AND		sga_actas_cursado.estado = 'C'
				AND		sga_det_acta_curs.unidad_academica = sga_actas_cursado.unidad_academica		
				AND		sga_det_acta_curs.acta             = sga_actas_cursado.acta
				AND		sga_alumnos.unidad_academica = sga_det_acta_curs.unidad_academica
				AND		sga_alumnos.carrera          = sga_det_acta_curs.carrera
				AND		sga_alumnos.legajo           = sga_det_acta_curs.legajo
				AND		sga_personas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion				
				GROUP BY 1, 2, 3, 4, 5
				ORDER BY 1, 2
				";

			return kernel::db()->consultar($sql); 
	}
    
    
    /**
	 * parametros: _ua, comision	 
	 * cache: no
	 * filas: n
	 */
	function get_resultados_acta_cursada($parametros)
	{
		// Recupero si existe acta de cursada.
		$sql = "SELECT acta, estado
		          FROM sga_actas_cursado 
				 WHERE comision = {$parametros['comision']}
				   AND estado IN ('A','C')";
		$acta_cursado = kernel::db()->consultar_fila($sql);
		
        
        if (!empty($acta_cursado)){
            $sql_detalle = "execute procedure sp_detalle_acta_cu(" . $parametros["_ua"] . ", " . $acta_cursado['ACTA'] .")";        
            $datos_detalle = kernel::db()->consultar($sql_detalle, db::FETCH_NUM);
            
            if (!empty($datos_detalle)){
                $salida = array();
                foreach($datos_detalle as $key => $detalle){
                    $salida['FILAS'][$key]['LEGAJO'] = $detalle[22];
                    $salida['FILAS'][$key]['COND_REG'] = $detalle[25];
                    $salida['FILAS'][$key]['RESULTADO'] = kernel::traductor()->trans('actas.resultado.'.$detalle[27]);
                    $salida['FILAS'][$key]['NOTA'] = $detalle[28];
                }
                $salida['ESTADO'] = $acta_cursado['ESTADO'];
                $salida['ACTA'] = $acta_cursado['ACTA'];
                return $salida;
            }
        }
        return false;
	}
    
    /**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function get_resultados_acta_promocion($parametros)
	{
		// Recuperar Acta de Promocion (acta normal)
		$sql = "SELECT acta, estado
		          FROM sga_actas_promo 
				 WHERE comision = {$parametros['comision']}
				   AND estado IN ('A','C')
				   AND tipo = 'N'";
		$acta_promo = kernel::db()->consultar($sql);
		return $acta_promo;
		// Si existe el acta y esta cerrada se traen los datos del acta de promocion
		// Si existe el acta y esta abierta o no existe el acta, se traen los datos de sga_curs_pendiente.
	}
        
    /**
     * parametros: _ua, nro_inscripcion, anio_academico, periodo
     * param_null: periodo
	 * cache: no
	 * filas: n
	 */
	function lista_comisiones_docente ($parametros)
	{
        $filtro_periodo = "";
	    if($parametros['periodo'] != "''"){
	       $filtro_periodo = " AND sga_periodos_lect.periodo_lectivo = {$parametros["periodo"]} ";
		}
        
		$sql = "SELECT
		              sga_comisiones.comision as comision,
                      sga_comisiones.nombre as comision_nombre,
                      sga_comisiones.materia as materia,
                      sga_materias.nombre as materia_nombre,
                      sga_materias.nombre_reducido as materia_nombre_red,
                      sga_comisiones.anio_academico  as anio_academico,
                      sga_comisiones.periodo_lectivo as periodo_lectivo,
                      sga_comisiones.catedra as catedra,
                      sga_comisiones.turno as turno,
                      DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', '') as turno_desc
                 FROM sga_docentes,
                      sga_docentes_com,
                      sga_comisiones,
                      sga_periodos_lect,
                      sga_materias
                WHERE sga_docentes.unidad_academica = {$parametros["_ua"]}
                  AND sga_docentes.nro_inscripcion  = {$parametros["nro_inscripcion"]}
                  AND sga_docentes_com.legajo = sga_docentes.legajo
                  AND sga_comisiones.comision = sga_docentes_com.comision
                  AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                  AND sga_materias.materia          = sga_comisiones.materia
                  AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
                  AND sga_periodos_lect.anio_academico = {$parametros["anio_academico"]}
                  AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo 
                  ".$filtro_periodo."
                ORDER BY sga_comisiones.materia, sga_comisiones.nombre
              ";

        $datos = kernel::db()->consultar($sql);
        
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$id = catalogo::generar_id($dato['COMISION']);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['COMISION'] = $dato['COMISION'];
			$nuevo[$id]['COMISION_NOMBRE'] = $dato['COMISION_NOMBRE'];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato['PERIODO_LECTIVO'];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato['ANIO_ACADEMICO'];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato['MATERIA_NOMBRE']." (".$dato['MATERIA'].")";
		}
        
		return $nuevo;
	}
}
?>