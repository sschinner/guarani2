<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use kernel\util\db\db;
use siu\guarani;

class inscripcion_cursada
{
	/**
	 * parametros: _ua, carrera
	 * cache: memoria
	 * filas: n
	 */
	function cantidad_periodos_inscripcion_vigentes($parametros)
	{
		$sql = "
			SELECT count(*)
			FROM sga_insc_x_carrera
			WHERE unidad_academica = {$parametros['_ua']}
			  AND carrera = {$parametros['carrera']}
			  AND CURRENT YEAR TO SECOND BETWEEN fecha_desde AND fecha_hasta";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		
		return $datos[0];
	}
	
	
	/**
	 * parametros: _ua, carrera, legajo, nro_inscripcion, plan, version, recursar
	 * cache: memoria
	 * filas: n
	 */
	function lista_materias($parametros) 
	{
                $sql = "execute procedure sp_matInscCurAlu({$parametros['_ua']}, ".
                                                            "{$parametros['carrera']},".
                                                            "{$parametros['legajo']},".
                                                            "{$parametros['nro_inscripcion']},".
                                                            "{$parametros['plan']},".
                                                            "{$parametros['version']},".
                                                            "{$parametros['recursar']},".
                                                            "{$parametros['comisiones_actuales']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$nuevo[$dato[1]][catalogo::id] = catalogo::generar_id($dato[1]);
			$nuevo[$dato[1]]['CARRERA'] = $parametros['carrera'];
			$nuevo[$dato[1]]['MATERIA'] = $dato[1];
			$nuevo[$dato[1]]['MATERIA_NOMBRE'] = $dato[2];
			$nuevo[$dato[1]]['MATERIA_NOMBRE_REDUCIDO'] = $dato[5];
			$nuevo[$dato[1]]['CREDITOS'] = $dato[3];
			$nuevo[$dato[1]]['REGULARIZADA'] = $dato[6];
			$nuevo[$dato[1]]['TIPO'] = $dato[6];
			$nuevo[$dato[1]]['NIVEL'] = $dato[7];
		}
		return $nuevo;
	}
        
        /**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function lista_materias_inscripcion_alumno($parametros) 
	{
                // trae todas las cursadas de todas carreras en las cuales el alumno se puede inscribir
                $sql = "execute procedure sp_matInscCursa_ft({$parametros['_ua']}, ".
                                                            "{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
                
		foreach($datos as $dato) {
			$nuevo[$dato[3]][catalogo::id] = catalogo::generar_id($dato[3]);
			$nuevo[$dato[3]]['CARRERA'] = $dato[1];
			$nuevo[$dato[3]]['MATERIA'] = $dato[3];
			$nuevo[$dato[3]]['MATERIA_NOMBRE'] = $dato[4];
			$nuevo[$dato[3]]['MATERIA_NOMBRE_REDUCIDO'] = $dato[5];
			$nuevo[$dato[3]]['CREDITOS'] = $dato[6];
		}
		return $nuevo;
	}

	//---------------------------------------------------------------
	// Comisiones
	//---------------------------------------------------------------

	/**
	 * parametros: _ua, carrera, legajo, materia
	 * cache: no
	 * filas: n
	 */
	function lista_comisiones($parametros)
	{
		$comisiones = self::lista_parcial_comisiones($parametros);
		$subcomisiones = self::lista_parcial_subcomisiones($parametros);
        
		foreach($subcomisiones as $subcom){
			if(isset($comisiones[$subcom['COMISION']])) {
                if (!isset($comisiones[$subcom['COMISION']]['SUBCOMISIONES'][$subcom['TIPO_CLASE']])) {
                    $comisiones[$subcom['COMISION']]['SUBCOMISIONES'][$subcom['TIPO_CLASE']] = array();
                }
				$comisiones[$subcom['COMISION']]['SUBCOMISIONES'][$subcom['TIPO_CLASE']][] = $subcom;
			}
		}
		return $comisiones;
	}

	private function lista_parcial_comisiones($parametros) 
	{
		$sql = "execute procedure sp_comisionesMat({$parametros['_ua']}, ".
													"{$parametros['carrera']},".
													"{$parametros['legajo']},".
													"{$parametros['materia']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        
                $where_horarios = "";
        
		$nuevo = array();        
		foreach($datos as $dato) {
			$nuevo[$dato[3]][catalogo::id] = catalogo::generar_id($dato[3]);
			$nuevo[$dato[3]]['COMISION'] = $dato[3];
			$nuevo[$dato[3]]['COMISION_NOMBRE'] = $dato[4];	
			$nuevo[$dato[3]]['PERIODO_LECTIVO'] = $dato[1];
			$nuevo[$dato[3]]['TURNO'] = $dato[5];
			$nuevo[$dato[3]]['TURNO_NOMBRE'] = $dato[9];
			$nuevo[$dato[3]]['DOCENTE'] = $dato[6];
			$nuevo[$dato[3]]['SEDE'] = $dato[7];
			$nuevo[$dato[3]]['SEDE_NOMBRE'] = $dato[8];
            
                $where_horarios .= "'".$dato[3]."',";
            
			$nuevo[$dato[3]]['CATEDRA'] = $dato[2];
			$nuevo[$dato[3]]['ANIO_ACADEMICO'] = $dato[0];
			$nuevo[$dato[3]]['TIENE_CUPO'] = $dato[11];
			$nuevo[$dato[3]]['COMISION_CUPO'] = $dato[12];
			$nuevo[$dato[3]]['COMISION_INSCRIPTOS'] = $dato[13];
		}
        
        if (!empty($where_horarios)){
            $where_horarios = substr($where_horarios, 0, -1);
            $sql_horarios = "SELECT 
                       DECODE(a.dia_semana, 1, 'Domingo', 2, 'Lunes', 3, 'Martes',4, 'Miércoles', 5, 'Jueves', 6, 'Viernes', 7, 'Sabado', '') as dia,
                       NVL(tc.descripcion, '') as tipo_clase,
                       to_char(a.hs_comienzo_clase, '%H:%M') || ' a ' || NVL(to_char(a.hs_finaliz_clase, '%H:%M'), '-') as hora_desde_hasta,
                       sga_aulas.nombre_aula as nombre_aula,
                       a.dia_semana, 
                       a.hs_comienzo_clase,
                       c.comision
                  FROM sga_asignaciones as a, 
                       sga_asign_clases as c,
                       OUTER sga_tipo_clase as tc,
                       OUTER sga_aulas
                  WHERE a.asignacion  = c.asignacion
                    AND tc.tipo_clase = c.tipo_clase
                    AND c.comision in (".$where_horarios.")
                    AND sga_aulas.edificio = a.edificio
                    AND sga_aulas.aula     = a.aula
                  ORDER BY a.dia_semana, a.hs_comienzo_clase";

            $datos_horarios = kernel::db()->consultar($sql_horarios, db::FETCH_ASSOC);
            
            if (!empty($datos_horarios)){
                foreach ($datos_horarios as $hkey => $hvalue){
                    $nuevo[$hvalue['COMISION']]['HORARIO'][] = $hvalue;
                }
            }
        }
		return $nuevo;
	}

	private function lista_parcial_subcomisiones($parametros) 
	{
		$sql = "execute procedure sp_subcom_materia({$parametros['_ua']}, ".
													"{$parametros['materia']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
        
        $where_horarios = "";
		foreach($datos as $dato) {
			$nuevo[$dato[2]."-".$dato[3]][catalogo::id] = catalogo::generar_id($dato[2].$dato[3]);
			$nuevo[$dato[2]."-".$dato[3]]['COMISION'] = $dato[2];
			$nuevo[$dato[2]."-".$dato[3]]['SUBCOMISION'] = $dato[3];
			$nuevo[$dato[2]."-".$dato[3]]['SUBCOMISION_NOMBRE'] = $dato[4];
			$nuevo[$dato[2]."-".$dato[3]]['TIPO_CLASE'] = $dato[5];
			$nuevo[$dato[2]."-".$dato[3]]['TIPO_CLASE_NOMBRE'] = $dato[6];
			$nuevo[$dato[2]."-".$dato[3]]['DOCENTE'] = $dato[7];
			$nuevo[$dato[2]."-".$dato[3]]['TIENE_CUPO'] = $dato[9];
			$nuevo[$dato[2]."-".$dato[3]]['COMISION_CUPO'] = $dato[10];
			$nuevo[$dato[2]."-".$dato[3]]['COMISION_INSCRIPTOS'] = $dato[11];
			if ($dato[9] == 'S') { //tiene cupo?
				$nuevo[$dato[2]."-".$dato[3]]['PORCENTAJE_CUPO'] = 	($dato[11] / $dato[10])*100;
			} else
			{
				$nuevo[$dato[2]."-".$dato[3]]['PORCENTAJE_CUPO'] = 	100;
			};	
            
            // Recopilo comisiones y subcomisiones
            $where_horarios .= "(s.comision = '".$dato[2]."' AND s.subcomision = '".$dato[3]."') OR ";
		}
        
        // horarios subcomisiones
        if (!empty($where_horarios)){
            $where_horarios = substr($where_horarios, 0, -4);            
            // Recuepera el horario de cursada de la subcomision. Dias y Horarios
            $sql_horarios = "SELECT 
                      DECODE(a.dia_semana, 1, 'Domingo', 2, 'Lunes', 3, 'Martes',4, 'Miércoles', 5, 'Jueves', 6, 'Viernes', 7, 'Sabado', '') as dia,
                      NVL(tc.descripcion, '') as tipo_clase,
                      to_char(a.hs_comienzo_clase, '%H:%M') || ' a ' || NVL(to_char(a.hs_finaliz_clase, '%H:%M'), '-') as hora_desde_hasta,
                      sga_aulas.nombre_aula as nombre_aula,
                      a.dia_semana as dia_semana,
                      a.hs_comienzo_clase,
                      s.comision,
                      s.subcomision
                    FROM 
                         sga_asign_subcom as s,
                         sga_asignaciones as a, 
                         sga_asign_clases as c,
                         OUTER sga_tipo_clase  as tc,
                         OUTER sga_aulas

                   WHERE 
                     (".$where_horarios.") 
                     AND a.asignacion  = s.asignacion
                     AND c.comision    = s.comision
                     AND c.asignacion  = s.asignacion
                     AND tc.tipo_clase = c.tipo_clase
                     AND sga_aulas.edificio = a.edificio
                     AND sga_aulas.aula = a.aula
                  ORDER BY a.dia_semana, a.hs_comienzo_clase";
            $datos_horarios = kernel::db()->consultar($sql_horarios, db::FETCH_ASSOC);
            
            if (!empty($datos_horarios)){
                foreach ($datos_horarios as $hkey => $hvalue){
                    $nuevo[$hvalue['COMISION']."-".$hvalue['SUBCOMISION']]['HORARIO'][] = $hvalue;
                }
            }
        }
		return $nuevo;
	}

	//---------------------------------------------------------------
	// INFO
	//---------------------------------------------------------------

	/**
	 * parametros: _ua, comision, carrera, plan, version
	 * cache: memoria
	 * filas: n
	 */
	function info_comision($parametros) 
	{
		$sql = "SELECT 
				  c.comision,
				  c.nombre, 
				  c.sede, 
				  c.anio_academico, 
				  c.periodo_lectivo, 
				  c.catedra,
				  c.turno,
				  c.capacidad as cupo,
				  c.materia as materia,
				  NVL(atmp.nombre_reducido, m.nombre_reducido) as materia_nombre,
				  DECODE(m.promovible , 'N', 'R', ( DECODE( (SELECT COUNT(*) FROM  sga_det_escala as d  WHERE d.resultado = 'P' AND d.escala_notas = c.escala_notas), 0 , 'R', 'P'))) as calidad_insc
			 FROM sga_comisiones as c,
			      OUTER sga_atrib_mat_plan as atmp,
				  sga_materias as m 
			 WHERE c.unidad_academica = m.unidad_academica 
			   AND c.materia = m.materia
			   AND c.comision = {$parametros['comision']} 
			   AND atmp.unidad_academica = c.unidad_academica
			   AND atmp.carrera          = {$parametros['carrera']}
			   AND atmp.plan             = {$parametros['plan']}
			   AND atmp.version          = {$parametros['version']}
			   AND atmp.materia          = c.materia			   
			   
			   ";

			  $datos = kernel::db()->consultar_fila($sql);
		// Determino la calidad a utilizar
		//  ALE: "Solo verificar el valor de "calidad_insc" para la calidad final de la inscripcion si
		//  el parametro " = P", en ese caso va el valor devuelto por la consulta, sino va R."
		$calidad = \siu\modelo\entidades\parametro::inscripcion_cursada_calidad();
		if($calidad != 'P') {
			$datos['calidad_insc'] = 'R';
		} 
		return $datos;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function asignaciones($parametros) 
	{
		$sql = "
		-- COMISIONES	
		SELECT  
			sga_comisiones.comision, 
			sga_comisiones.nombre, 
			sga_comisiones.sede, 
			sga_comisiones.anio_academico, 
			sga_comisiones.periodo_lectivo, 
			sga_comisiones.catedra, 
			sga_comisiones.turno, 
			sga_comisiones.capacidad as cupo, 
			sga_comisiones.materia as materia,  
			NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_materia,
			sga_asignaciones.dia_semana, 
			sga_asignaciones.fecha_asign_desde, 
			sga_asignaciones.fecha_asign_hasta, 
			sga_asignaciones.hs_comienzo_clase, 
			sga_asignaciones.hs_finaliz_clase,
			-- to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M') as hs_comienzo_clase, 
			-- to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M') hs_finaliz_clase, 
			sga_asignaciones.aula, 
			sga_aulas.nombre_aula as nombre_aula, 
			sga_asignaciones.edificio,
			'(' || sga_comisiones.materia || ') ' || NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'),'') || NVL(' a ' || to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'') || NVL( ' - ' || sga_aulas.nombre_aula,'') as desc_grilla_codigo,
			NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) || ' - ' || NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'),'') || NVL(' a ' || to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'') || NVL( ' - ' || sga_aulas.nombre_aula,'') as desc_grilla_nombre
		FROM  
		    sga_alumnos,
			sga_insc_cursadas,
			sga_comisiones,
			sga_atrib_mat_plan as atmp,  
			sga_periodos_lect,
			sga_materias, 
			OUTER (sga_asign_clases, OUTER (sga_asignaciones, OUTER sga_aulas))
			
		WHERE  sga_alumnos.unidad_academica = {$parametros['_ua']}
			AND sga_alumnos.nro_inscripcion  = {$parametros['nro_inscripcion']}
			AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica 
			AND sga_insc_cursadas.carrera  = sga_alumnos.carrera 
			AND sga_insc_cursadas.legajo  = sga_alumnos.legajo 
			AND sga_comisiones.comision    = sga_insc_cursadas.comision
			AND atmp.unidad_academica = sga_alumnos.unidad_academica
			AND atmp.carrera          = sga_alumnos.carrera
			AND atmp.plan             = sga_alumnos.plan
			AND atmp.version          = sga_insc_cursadas.version
			AND atmp.materia          = sga_comisiones.materia
			AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
			AND sga_materias.materia    = sga_comisiones.materia
			AND sga_asign_clases.comision   = sga_comisiones.comision 
			AND sga_asignaciones.asignacion = sga_asign_clases.asignacion
			AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
			AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
			AND sga_periodos_lect.fecha_fin >= TODAY
			AND NOT EXISTS (SELECT 1 FROM sga_subcomisiones as sc  WHERE sc.comision = sga_comisiones.comision)
			AND sga_aulas.edificio = sga_asignaciones.edificio
			AND sga_aulas.aula     = sga_asignaciones.aula

		UNION ALL 

		-- SUBCOMISIONES
		SELECT 
			sga_comisiones.comision, 
			sga_comisiones.nombre, 
			sga_comisiones.sede, 
			sga_comisiones.anio_academico, 
			sga_comisiones.periodo_lectivo, 
			sga_comisiones.catedra, 
			sga_comisiones.turno, 
			sga_comisiones.capacidad as cupo, 
			sga_comisiones.materia as materia,  
			NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_materia,
			sga_asignaciones.dia_semana, 
			sga_asignaciones.fecha_asign_desde, 
			sga_asignaciones.fecha_asign_hasta, 
			sga_asignaciones.hs_comienzo_clase, 
			sga_asignaciones.hs_finaliz_clase,
			-- to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M') as hs_comienzo_clase, 
			-- to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M') hs_finaliz_clase, 
			sga_asignaciones.aula, 
			sga_aulas.nombre_aula as nombre_aula, 
			sga_asignaciones.edificio, 
			'(' || sga_comisiones.materia || ') ' || NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'),'') || NVL(' a ' || to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'') || NVL( ' - ' || sga_aulas.nombre_aula,'') as desc_grilla_codigo,
			NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) || ' - ' ||  NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'),'') || NVL(' a ' || to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'') || NVL( ' - ' || sga_aulas.nombre_aula,'') as desc_grilla_nombre
		FROM  
			sga_alumnos,
			sga_insc_cursadas, 
			sga_insc_subcom, 
			sga_comisiones,
			sga_atrib_mat_plan as atmp,
			sga_periodos_lect,
			sga_materias, 
			OUTER (sga_asign_subcom, OUTER (sga_asignaciones, OUTER sga_aulas))
		WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
			AND sga_alumnos.nro_inscripcion  = {$parametros['nro_inscripcion']}
			AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica 
			AND sga_insc_cursadas.carrera = sga_alumnos.carrera 
			AND sga_insc_cursadas.legajo  = sga_alumnos.legajo 
			AND sga_insc_cursadas.unidad_academica = sga_insc_subcom.unidad_academica 
			AND sga_insc_cursadas.carrera  = sga_insc_subcom.carrera 
			AND sga_insc_cursadas.legajo   = sga_insc_subcom.legajo 
			AND sga_insc_cursadas.comision = sga_insc_subcom.comision
			AND sga_comisiones.comision = sga_insc_cursadas.comision
			AND atmp.unidad_academica = sga_alumnos.unidad_academica
			AND atmp.carrera          = sga_alumnos.carrera
			AND atmp.plan             = sga_alumnos.plan
			AND atmp.version          = sga_insc_cursadas.version
			AND atmp.materia          = sga_comisiones.materia
			AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
			AND sga_materias.materia          = sga_comisiones.materia
			AND sga_asign_subcom.comision    = sga_insc_subcom.comision 
			AND sga_asign_subcom.subcomision = sga_insc_subcom.subcomision 
			AND sga_asignaciones.asignacion = sga_asign_subcom.asignacion
			AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
			AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
			AND sga_periodos_lect.fecha_fin >= TODAY
			AND sga_aulas.edificio = sga_asignaciones.edificio
			AND sga_aulas.aula     = sga_asignaciones.aula
			";

		
		return kernel::db()->consultar($sql);
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
         * param_null: 
	 * cache: memoria
	 * filas: n
	 */
	function inscripciones($parametros)
	{
		$sql = "SELECT 
			   sga_alumnos.carrera as carrera,
			   sga_alumnos.legajo as legajo,
			   sga_comisiones.materia as materia,
			   NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_reducido_materia,
			   NVL(atmp.nombre_materia, sga_materias.nombre) as nombre_materia,
			   sga_comisiones.comision as comision,
			   sga_comisiones.nombre as nombre_comision,
			   sga_comisiones.anio_academico as anio_academico,
			   sga_comisiones.periodo_lectivo as periodo_lectivo,
			   sga_comisiones.turno as turno_cursada,
			   sp_docentes_com(sga_comisiones.comision) as docente,
			   sga_insc_cursadas.fecha_inscripcion as fecha_inscripcion,
			   (SELECT fic.fecha_tope_bajas
			      FROM sga_fec_insc_cur as fic
			     WHERE fic.anio_academico  = sga_comisiones.anio_academico
			       AND fic.periodo_lectivo = sga_comisiones.periodo_lectivo
			       AND sga_insc_cursadas.fecha_inscripcion BETWEEN fic.fecha_inicio AND fic.fecha_fin
			   ) as fecha_tope_baja,
			   DECODE(sga_comisiones.turno, 'M','Mañana', 'T', 'Tarde', 'N', 'Noche', '') as turno_cursada,
			   to_char(sga_insc_cursadas.fecha_inscripcion, \"%d/%m/%Y %H:%M:%S\") as sfecha_inscripcion,
			   DECODE (sga_insc_cursadas.calidad_insc , 'R', 'Regular','P','Promocional') as calidad,
			   DECODE (sga_insc_cursadas.estado, 'A', 'Aceptado','E','Aceptado', 'P', 'Pendiente') as estado_inscripcion,
			   sga_insc_cursadas.nro_transaccion as nro_transaccion,
			   sga_comisiones.catedra as catedra,
			   sga_alumnos.plan as plan		
			FROM 
			   sga_alumnos,
			   sga_insc_cursadas,
			   sga_comisiones,
			   sga_atrib_mat_plan as atmp,
			   sga_materias,
			   sga_periodos_lect
			WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
			  AND sga_alumnos.nro_inscripcion  = {$parametros['nro_inscripcion']}
			  AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
			  AND sga_insc_cursadas.carrera  = sga_alumnos.carrera
                          AND sga_insc_cursadas.legajo   = sga_alumnos.legajo
			  AND sga_comisiones.comision = sga_insc_cursadas.comision
			  AND atmp.unidad_academica = sga_alumnos.unidad_academica
			  AND atmp.carrera          = sga_alumnos.carrera
			  AND atmp.plan             = sga_alumnos.plan
			  AND atmp.version          = sga_insc_cursadas.version
			  AND atmp.materia          = sga_comisiones.materia
			  AND sga_materias.unidad_academica = sga_insc_cursadas.unidad_academica
			  AND sga_materias.materia  = sga_comisiones.materia
			  AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
			  AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
			  AND sga_periodos_lect.fecha_fin >= TODAY";
                          
		$datos = kernel::db()->consultar($sql);
		
		foreach($datos as $key => $dato) {
			$datos[$key]['URL_NRO_TRANSACCION'] = catalogo::generar_id($dato['NRO_TRANSACCION']);
		}
		return $datos;
	}

	/**
	 * parametros: transaccion
	 * cache: no
	 * filas: n
	 */
	function info_comprobante_inscripcion($parametros) 
	{
		$sql = "SELECT
			   sga_unidades_acad.nombre as nombre_unidad_academica,
			   sga_alumnos.carrera as carrera,
			   sga_carreras.nombre as nombre_carrera,
			   sga_personas.apellido || ', ' || sga_personas.nombres as nombre_alumno,
			   sga_alumnos.legajo as legajo,
			   sga_alumnos.plan as plan,
			   sga_materias.materia as materia,
			   NVL(atmp.nombre_materia, sga_materias.nombre) as nombre_materia,
			   NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_red_materia,
			   sga_comisiones.nombre as nombre_comision,
			   sga_comisiones.anio_academico as anio_academico,
			   sga_comisiones.periodo_lectivo as periodo_lectivo,
			   DECODE(sga_comisiones.turno, 'M','Mañana', 'T', 'Tarde', 'N', 'Noche', '') as turno_cursada,
			   to_char(sga_insc_cursadas.fecha_inscripcion, \"%d/%m/%Y %H:%M:%S\") as fecha_inscripcion,
			   DECODE (sga_insc_cursadas.calidad_insc , 'R', 'Regular','P','Promocional') as calidad,
			   DECODE (sga_insc_cursadas.estado, 'A', 'Aceptado','E','Aceptado', 'P', 'Pendiente') as estado_inscripcion,
			   sga_insc_cursadas.nro_transaccion as nro_transaccion,
			   sga_sedes.nombre as nombre_sede,
			   sga_comisiones.catedra as catedra
			FROM 
			   sga_insc_cursadas, 
			   sga_alumnos,
			   sga_comisiones,
			   sga_atrib_mat_plan as atmp,
			   sga_personas,
			   sga_carreras,
			   sga_materias,
			   sga_unidades_acad,
			   sga_sedes
			WHERE sga_insc_cursadas.nro_transaccion = {$parametros['transaccion']}
			  AND sga_alumnos.unidad_academica = sga_insc_cursadas.unidad_academica 
			  AND sga_alumnos.carrera = sga_insc_cursadas.carrera 
			  AND sga_alumnos.legajo = sga_insc_cursadas.legajo 
			  AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
			  AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
			  AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica 
			  AND sga_carreras.carrera = sga_alumnos.carrera
			  AND sga_comisiones.comision = sga_insc_cursadas.comision 
			  AND atmp.carrera          = sga_insc_cursadas.carrera
			  AND atmp.plan             = sga_insc_cursadas.plan
			  AND atmp.version          = sga_insc_cursadas.version
			  AND atmp.materia          = sga_comisiones.materia
			  AND sga_materias.unidad_academica = sga_alumnos.unidad_academica
			  AND sga_materias.materia  = sga_comisiones.materia
			  AND sga_unidades_acad.unidad_academica = sga_insc_cursadas.unidad_academica
			  AND sga_sedes.sede = sga_comisiones.sede;";
			  
		$datos = kernel::db()->consultar_fila($sql);

		return $datos;
	}
        
              /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function info_nro_transacciones_inscripciones_historicas($parametros)
	{
		$sql = "SELECT 		sga_insc_cursadas.nro_transaccion
                        FROM sga_insc_cursadas
                        JOIN sga_alumnos ON (sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_insc_cursadas.carrera          = sga_alumnos.carrera
				AND		sga_insc_cursadas.legajo           = sga_alumnos.legajo)
                        WHERE sga_alumnos.nro_inscripcion = {$parametros['nro_inscripcion']}
                        AND sga_insc_cursadas.unidad_academica = {$parametros['_ua']}";
                        
                        
                        
                $datos = kernel::db()->consultar($sql);
		$nuevo = array();
		foreach($datos as $key => $dato) {
			$nuevo[$key]['URL_NRO_TRANSACCION']	= catalogo::generar_id($dato['NRO_TRANSACCION']);
			$nuevo[$key]['NRO_TRANSACCION']		= $dato['NRO_TRANSACCION'];
		}
		return $nuevo;
        }
	
	/**
	 * parametros: transaccion
	 * cache: no
	 * filas: n
	 */
	function info_comprobante_baja($parametros) 
	{
		$sql = "SELECT
			   sga_unidades_acad.nombre as nombre_unidad_academica,
			   sga_alumnos.carrera as carrera,
			   sga_carreras.nombre as nombre_carrera,
			   sga_personas.apellido || ', ' || sga_personas.nombres as nombre_alumno,
			   sga_alumnos.legajo as legajo,
			   sga_alumnos.plan as plan,
			   sga_materias.materia as materia,
			   NVL(atmp.nombre_materia, sga_materias.nombre) as nombre_materia,
			   NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_red_materia,
			   sga_comisiones.nombre as nombre_comision,
			   sga_comisiones.comision as comision,
			   sga_comisiones.anio_academico as anio_academico,
			   sga_comisiones.periodo_lectivo as periodo_lectivo,
			   DECODE(sga_comisiones.turno, 'M','Mañana', 'T', 'Tarde', 'N', 'Noche', '') as turno_cursada,
			   to_char(sga_insc_cur_bajas.fecha_baja, \"%d/%m/%Y %H:%M:%S\") as fecha_baja,
			   to_char(sga_insc_cur_bajas.fecha_inscripcion, \"%d/%m/%Y %H:%M:%S\") as fecha_inscripcion,
			   DECODE (sga_insc_cur_bajas.calidad_insc , 'R', 'Regular','P','Promocional') as calidad,
			   sga_insc_cur_bajas.nro_trans_baja as nro_trans_baja,
			   sga_sedes.nombre as nombre_sede,
			   sga_comisiones.catedra as catedra
			FROM 
			   sga_insc_cur_bajas, 
			   sga_alumnos,
			   sga_comisiones,
			   sga_atrib_mat_plan as atmp,
			   sga_personas,
			   sga_carreras,
			   sga_materias,
			   sga_unidades_acad,
			   sga_sedes
			WHERE sga_insc_cur_bajas.nro_trans_baja = {$parametros['transaccion']}
			  AND sga_alumnos.unidad_academica = sga_insc_cur_bajas.unidad_academica 
			  AND sga_alumnos.carrera = sga_insc_cur_bajas.carrera 
			  AND sga_alumnos.legajo = sga_insc_cur_bajas.legajo 
			  AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
			  AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
			  AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica 
			  AND sga_carreras.carrera = sga_alumnos.carrera
			  AND sga_comisiones.comision = sga_insc_cur_bajas.comision 
			  AND atmp.carrera          = sga_insc_cur_bajas.carrera
			  AND atmp.plan             = sga_insc_cur_bajas.plan
			  AND atmp.version          = sga_insc_cur_bajas.version
			  AND atmp.materia          = sga_comisiones.materia
			  AND sga_materias.unidad_academica = sga_alumnos.unidad_academica
			  AND sga_materias.materia  = sga_comisiones.materia
			  AND sga_unidades_acad.unidad_academica = sga_insc_cur_bajas.unidad_academica
			  AND sga_sedes.sede = sga_comisiones.sede;";
			  
		$datos = kernel::db()->consultar_fila($sql);

		return $datos;
	}
	
	//------------------------------------------------------------------------
	// Modificacion de DATOS
	//------------------------------------------------------------------------
	
	/**
	 * parametros: _ua, carrera, legajo, comision, estado, _interfaz, plan, version, subcomisiones, plan, calidad, materia, nombre_comision, max_insc_cursada, controla_cupo
	 * cache: no
	 * filas: n
	 */	
	function inscripcion_comision($parametros) 
	{
		$esta_en_transaccion = kernel::db()->quote('N');
		$nro_inscripcion = kernel::db()->quote(guarani::persona()->get_nro_inscripcion());
		$sql = "execute procedure sp_i_inscCursadas({$parametros['_ua']}, ".
													"{$parametros['carrera']},".
													"{$parametros['legajo']},".
													"$nro_inscripcion,".
													"{$parametros['comision']},".
													"{$parametros['estado']},".
													"{$parametros['_interfaz']},".
													"{$parametros['materia']},".
													"{$parametros['nombre_comision']},".
													"{$parametros['plan']},".
													"{$parametros['version']},".
													"{$parametros['subcomisiones']},".
													"{$parametros['max_insc_cursada']},".
													"{$parametros['calidad']},".
													"{$parametros['controla_cupo']},
													$esta_en_transaccion)";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}	
	
	/**
	 * parametros: _ua, carrera, legajo, comision, _interfaz, anio_academico, periodo_lectivo, controla_cupo
	 * cache: no
	 * filas: n
	 */	
	function eliminar_inscripcion_comision($parametros) 
	{
		$sql = "execute procedure sp_d_inscCursadas ({$parametros['_ua']}, ".
													"{$parametros['carrera']},".
													"{$parametros['legajo']},".
													"{$parametros['comision']},".
													"{$parametros['_interfaz']},".
													"{$parametros['anio_academico']},".
													"{$parametros['periodo_lectivo']},".
													"{$parametros['controla_cupo']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
}