<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;
use siu\operaciones\_comun\util\caracteres_especiales;

class alumno
{
	/**
	 * parametros: _ua, carrera, legajo, periodo_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function es_reingresante_carrera($parametros)
	{
		$sql = "EXECUTE PROCEDURE sp_esingresantepi({$parametros['_ua']}".
													",".$parametros['carrera'].
													",".$parametros['legajo'].
													",".$parametros['periodo_inscripcion'].")";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos[0];
	}

	/**
	 * parametros: _ua, carrera, legajo, materia
	 * cache: no
	 * filas: 1
	 */
	function get_datos_ultima_cursada_materia($parametros)
	{
		$sql = "SELECT FIRST 1
					sga_comisiones.anio_academico as anio_academico,
					sga_comisiones.periodo_lectivo as periodo_lectivo,
					to_char(sga_cursadas.fecha_regularidad, '%d/%m/%Y')  as sfecha_regularidad,
					NVL(to_char(sga_cursadas.fin_vigencia_regul, '%d/%m/%Y'), 'Sin Vencimiento') as sfecha_fin_vigencia,
					CASE 
						WHEN sga_cursadas.fin_vigencia_regul IS NULL THEN 1
						WHEN sga_cursadas.fin_vigencia_regul IS NOT NULL AND sga_cursadas.fin_vigencia_regul >= TODAY THEN 1
						ELSE 0
					END as es_vigente,
					sga_cursadas.comision,
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.catedra as catedra,
					sga_cursadas.nota,
					sga_det_escala.descripcion as nota_descripcion,
					sga_det_escala.concepto as nota_concepto,
					-- ********************************************************************
					-- U820 Se decodifica el resultado aprobado de la cursada como Regular
					--DECODE(sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre') as resultado_desc,

					DECODE(sga_cursadas.resultado, 'P', 'Aprobado', 'A','Regular', 'R', 'Reprobado', 'U','Libre') as 
resultado_desc,
					-- ********************************************************************
					DECODE(sga_cursadas.origen, 'P', 'Promoción', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equivalencia en otra Carrera', 'CE', 'Cursada en otra Carrera' ) as origen,
					sga_cursadas.plan as plan,
					sga_cursadas.fecha_regularidad as fecha_regularidad
				FROM	sga_cursadas
						LEFT JOIN sga_comisiones ON sga_comisiones.comision = sga_cursadas.comision
						LEFT JOIN sga_det_escala ON (sga_det_escala.escala_notas = sga_cursadas.escala_notas AND sga_det_escala.nota = sga_cursadas.nota)
				WHERE	sga_cursadas.unidad_academica = {$parametros['_ua']}
					AND	sga_cursadas.carrera = {$parametros['carrera']}
					AND	sga_cursadas.legajo  = {$parametros['legajo']}
					AND	sga_cursadas.materia = {$parametros['materia']}
				ORDER BY sga_cursadas.fecha_regularidad desc";
		return kernel::db()->consultar_fila($sql);
	}

	/**
	 * parametros: _ua, legajo, carrera
	 * cache: memoria
	 * filas: n
	 */
	function get_actividad_academica($parametros) 
	{
		$sql = "SELECT	cast('Aprobacion' as varchar(11)) as tipo, -- Historia Academica - Aprobaciones
						sga_atrib_mat_plan.anio_de_cursada, -- Año de cursada definido en el plan
						sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
						year(vw_hist_academica.fecha) as anio,
						vw_hist_academica.materia,
						sga_atrib_mat_plan.nombre_materia as materia_nombre,
						sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
						to_char(vw_hist_academica.fecha, '%d/%m/%Y') as fecha_display,
						to_char(vw_hist_academica.fecha, '%Y%m%d') as fecha_orden,
						cast(null as integer) as comision, -- comision en cursadas
						vw_hist_academica.escala_notas,
						vw_hist_academica.nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						vw_hist_academica.resultado as resultado,
						DECODE(vw_hist_academica.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promoción', 'U', 'Ausente', '') as resultado_descripcion,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('Examen' as varchar(12))
							WHEN 'Examen equivalente'			THEN cast('Examen' as varchar(12))
							WHEN 'Promoción'					THEN cast('Promocion' as varchar(12))
							WHEN 'Promoción en otra carrera'	THEN cast('Promocion' as varchar(12))
							WHEN 'Homologada'					THEN cast('Homologada' as varchar(12))
							WHEN 'Equivalencia'					THEN 'Equivalencia'
							WHEN 'Equivalencia equivalente'		THEN 'Equivalencia'
							WHEN 'Otras'						THEN cast('Otras'  as varchar(12))
						END as origen,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('examen' as varchar(40))
							WHEN 'Examen equivalente'			THEN cast('examen' as varchar(40))
							WHEN 'Promoción'					THEN cast('promocion' as varchar(40))
							WHEN 'Promoción en otra carrera'	THEN cast('promocion' as varchar(40))
							WHEN 'Homologada'					THEN cast('homologada' as varchar(40))
							WHEN 'Equivalencia'					THEN cast('equivalencia_total' as varchar(40))
							WHEN 'Equivalencia equivalente'		THEN cast('equivalencia_total_equivalente' as varchar(40))
							WHEN 'Otras'						THEN cast('otras'  as varchar(40))
						END as origen_desc,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen equivalente'			THEN 1
							WHEN 'Promoción en otra carrera'	THEN 1
							WHEN 'Equivalencia equivalente'		THEN 1
							ELSE 0
						END as origen_otra_carrera,
						1 as vigente, 		   -- vigente en cursadas
						cast(null as integer) as cond_regularidad, -- condicion de regularidad en cursadas
						sga_atrib_mat_plan.credito,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen' 						THEN vw_hist_academica.acta
							WHEN 'Examen equivalente' 			THEN vw_hist_academica.acta
							WHEN 'Promoción' 					THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN 'Promoción en otra carrera'	THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN 'Homologada' 					THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia' 				THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia equivalente' 	THEN vw_hist_academica.nro_resolucion
							ELSE '' 
						END as acta_resolucion,
						vw_hist_academica.plan,
						vw_hist_academica.version,
						vw_hist_academica.equivalencia,
						cast(null as char(10)) as fecha_fin_vigencia,
						cast(null as varchar(15))	as comision_nombre, 
						cast(null as integer)		as anio_academico, 
						cast(null as varchar(20))	as periodo_lectivo, 
						cast(null as varchar(10))	as turno_cursada, 
						cast(null as varchar(15))	as catedra, 
						cast(null as varchar(15))	as calidad_insc, 
						cast(null as varchar(10))	as estado_insc, 
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Equivalencia'  THEN 'ET' 
							WHEN 'Equivalencia equivalente' THEN 'ET'
							ELSE cast(null as char(2))
						END as equivalencia_tipo
			FROM	vw_hist_academica,
			OUTER	sga_det_escala, 
					sga_atrib_mat_plan
			WHERE	vw_hist_academica.unidad_academica		= sga_atrib_mat_plan.unidad_academica
			AND		vw_hist_academica.carrera				= sga_atrib_mat_plan.carrera
			AND		vw_hist_academica.plan					= sga_atrib_mat_plan.plan
			AND		vw_hist_academica.version				= sga_atrib_mat_plan.version
			AND		vw_hist_academica.materia				= sga_atrib_mat_plan.materia
			AND		vw_hist_academica.unidad_academica		= {$parametros['_ua']}
			AND		vw_hist_academica.carrera				= {$parametros['carrera']}
			AND		vw_hist_academica.legajo				= {$parametros['legajo']}
			AND		vw_hist_academica.forma_aprobacion		<> 'Homologada'
			AND		sga_det_escala.escala_notas	= vw_hist_academica.escala_notas 
			AND		sga_det_escala.nota			= vw_hist_academica.nota
			UNION ALL
			SELECT	cast('Regularidad' as varchar(11)) as tipo, -- Regularidades 
					sga_atrib_mat_plan.anio_de_cursada, -- AÃ±o de cursada definido en el plan
					sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
					year(sga_cursadas.fecha_regularidad) as anio,
					sga_cursadas.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
					sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
					to_char(sga_cursadas.fecha_regularidad, '%d/%m/%Y') as fecha_display,
					to_char(sga_cursadas.fecha_regularidad, '%Y%m%d') as fecha_orden,
					sga_cursadas.comision,
					sga_cursadas.escala_notas,
					sga_cursadas.nota,
					sga_det_escala.descripcion as nota_descripcion,
					sga_det_escala.concepto as nota_concepto,
					sga_cursadas.resultado as resultado,
					-- ********************************************************************
					-- U820 Se decodifica el resultado aprobado de la cursada como Regular
					--DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Regular', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					-- ********************************************************************
					--	DECODE( sga_cursadas.origen, 'P', 'Promoción', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equiv. Equivalente', 'CE', 'Cursada Equiv.' ) as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('Promocion' as varchar(12))
						WHEN 'C' THEN cast('Cursada' as varchar(12)) 
						WHEN 'E' THEN 'Equivalencia'
						WHEN 'EE' THEN 'Equivalencia'
						WHEN 'CE' THEN cast('Cursada' as varchar(12))
					END as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('promocion' as varchar(40))
						WHEN 'C' THEN cast('cursada' as varchar(40))
						WHEN 'E' THEN cast('equivalencia_parcial' as varchar(40))
						WHEN 'EE' THEN cast('equivalencia_parcial_equivalente' as varchar(40))
						WHEN 'CE' THEN cast('cursada' as varchar(40))
					END as origen_desc,
					CASE sga_cursadas.origen
						WHEN 'EE' THEN 1
						WHEN 'CE' THEN 1
						ELSE 0
					END as origen_otra_carrera,
					CASE 
						WHEN sga_cursadas.fin_vigencia_regul IS NULL THEN 1
						WHEN sga_cursadas.fin_vigencia_regul IS NOT NULL AND sga_cursadas.fin_vigencia_regul >= TODAY THEN 1
					ELSE 0
					END as vigente,
					sga_cursadas.cond_regularidad,
					sga_atrib_mat_plan.credito,
					CASE sga_cursadas.origen
						WHEN 'P'		THEN cast(sga_cursadas.acta_promocion as varchar(15))
						WHEN 'C' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'CE' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'E'		THEN sga_cursadas.nro_resolucion
						WHEN 'EE'   	THEN sga_cursadas.nro_resolucion 
						ELSE '' 
					END as acta_resolucion,
					sga_cursadas.plan,
					sga_cursadas.version,
					sga_cursadas.equivalencia,
					to_char(sga_cursadas.fin_vigencia_regul, '%d/%m/%Y') as fecha_fin_vigencia,
					cast(null as varchar(15))	as comision_nombre, 
					cast(null as integer)		as anio_academico, 
					cast(null as varchar(20))	as periodo_lectivo, 
					cast(null as varchar(10))	as turno_cursada, 
					cast(null as varchar(15))	as catedra, 
					cast(null as varchar(15))	as calidad_insc, 
					cast(null as varchar(10))	as estado_insc, 
					CASE sga_cursadas.origen
						WHEN 'E' THEN 'EP'
						WHEN 'EE' THEN 'EP'
						ELSE cast(null as char(2))
					END as equivalencia_tipo
			FROM	sga_cursadas,
					OUTER sga_det_escala,
					sga_atrib_mat_plan
			WHERE	sga_atrib_mat_plan.unidad_academica = sga_cursadas.unidad_academica 
			AND		sga_atrib_mat_plan.carrera          = sga_cursadas.carrera 
			AND		sga_atrib_mat_plan.plan             = sga_cursadas.plan 
			AND		sga_atrib_mat_plan.version          = sga_cursadas.version
			AND		sga_atrib_mat_plan.materia          = sga_cursadas.materia
			AND		sga_cursadas.origen		<> 'P' -- Las promociones las obtengo por la vista vw-hist_academica
			AND		sga_cursadas.unidad_academica		= {$parametros['_ua']}
			AND		sga_cursadas.carrera				= {$parametros['carrera']}
			AND		sga_cursadas.legajo					= {$parametros['legajo']}
			AND		sga_det_escala.escala_notas = sga_cursadas.escala_notas 
			AND		sga_det_escala.nota = sga_cursadas.nota
			UNION ALL
			SELECT	cast('En Curso' as varchar(11)) as tipo, -- En Curso
					sga_atrib_mat_plan.anio_de_cursada, 
					sga_atrib_mat_plan.periodo_dictado, 
					sga_comisiones.anio_academico as anio, 
					sga_comisiones.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
					sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
					to_char(sga_periodos_lect.fecha_inicio , '%d/%m/%Y') as fecha_display,
					to_char(sga_periodos_lect.fecha_inicio, '%Y%m%d') as fecha_orden,
					sga_insc_cursadas.comision,
					cast(null as int) as escala_notas, 
					cast(null as varchar(5)) as nota, 
					cast(null as varchar(50)) as nota_descripcion, 
					cast(null as varchar(15)) as nota_concepto, 
					cast(null as char(1)) as resultado, 
					cast(null as varchar(10)) as resultado_descripcion, 
					cast('EnCurso' as varchar(12)) as origen,
					cast('en_curso' as varchar(40)) as origen_desc,
					0 as origen_otra_carrera,
					cast(null as int) as vigente, 
					cast(null as int) as cond_regularidad, 
					cast(null as int) as credito, 
					cast(null as varchar(15)) as acta_resolucion,						
					sga_insc_cursadas.plan,
					sga_insc_cursadas.version,
					cast(null as int) as equivalencia,			-- no se usa
					cast(null as char(10)) as fecha_fin_vigencia,	 -- no se usa
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.anio_academico,
					sga_comisiones.periodo_lectivo,
					DECODE(sga_comisiones.turno, 'M', 'Mañana', 'T', 'Tarde','N', 'Noche', '') as turno_cursada,
					NVL(sga_comisiones.catedra, '') as catedra,
					DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional') as calidad_insc,
					DECODE(sga_insc_cursadas.estado, 'A', 'Aceptada', 'P', 'Pendiente', 'E', 'Exceptuada') as estado_insc,
					cast(null as char(2)) as equivalencia_tipo
			FROM	sga_insc_cursadas,
					sga_comisiones,
					sga_periodos_lect,
					sga_atrib_mat_plan
			WHERE	sga_insc_cursadas.comision = sga_comisiones.comision
			AND		sga_atrib_mat_plan.unidad_academica  = sga_insc_cursadas.unidad_academica
			AND		sga_atrib_mat_plan.carrera           = sga_insc_cursadas.carrera
			AND		sga_atrib_mat_plan.plan              = sga_insc_cursadas.plan
			AND		sga_atrib_mat_plan.version           = sga_insc_cursadas.version
			AND		sga_atrib_mat_plan.materia           = sga_comisiones.materia
			AND		sga_periodos_lect.anio_academico	 = sga_comisiones.anio_academico
			AND		sga_periodos_lect.periodo_lectivo	 = sga_comisiones.periodo_lectivo
			AND		sga_periodos_lect.fecha_fin >= TODAY  -- Vigente
			-- El alumno no esta en un acta de cursada cerrada
			AND NOT EXISTS (Select 1 FROM sga_actas_cursado WHERE sga_actas_cursado.comision = sga_comisiones.comision AND sga_actas_cursado.estado = 'C')
			-- El alumno no haya promocionado la materia
			AND NOT EXISTS (SELECT 1 
							FROM sga_actas_promo as a, sga_det_acta_promo as b
							WHERE a.comision = sga_comisiones.comision
							AND a.estado = 'C'
							AND b.unidad_academica = sga_insc_cursadas.unidad_academica 
							AND b.carrera  = sga_insc_cursadas.carrera
							AND b.legajo   = sga_insc_cursadas.legajo
							AND b.acta     = a.acta
							AND b.estado    = 'A'
							AND b.resultado = 'P' -- Promocionado
							AND b.rectificado = 'N')
			AND	 sga_insc_cursadas.unidad_academica   =  {$parametros['_ua']}
			AND	 sga_insc_cursadas.carrera            =	{$parametros['carrera']}
			AND	 sga_insc_cursadas.legajo             =	{$parametros['legajo']}
			ORDER BY 9 DESC
		";
		$datos = kernel::db()->consultar($sql);
		return $datos;
	}

	/**
	 * parametros: _ua, legajo, carrera, acta
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_aprobada($parametros)
	{
		
		$sql = "SELECT 	sga_actas_examen.anio_academico,
						sga_actas_examen.turno_examen,
						sga_actas_examen.mesa_examen,
						DECODE (sga_detalle_acta.tipo_inscripcion, 'R','Regular', 'L' , 'Libre', 'T', 'Tesis', '') as tipo
				FROM	sga_actas_examen,
						sga_detalle_acta
				WHERE	sga_actas_examen.tipo_acta			= 'N'
				AND     sga_detalle_acta.unidad_academica	= sga_actas_examen.unidad_academica
				AND  	sga_detalle_acta.tipo_acta			= sga_actas_examen.tipo_acta
				AND  	sga_detalle_acta.acta				= sga_actas_examen.acta
				AND		sga_actas_examen.unidad_academica	= {$parametros['_ua']}		
				AND     sga_detalle_acta.carrera			= {$parametros['carrera']}
				AND		sga_detalle_acta.legajo				= {$parametros['legajo']}
				AND		sga_actas_examen.acta				= {$parametros['acta']}
		";
		
		$datos = kernel::db()->consultar($sql);
		return $datos;
	}

	/**
	 * parametros: _ua, legajo, carrera, comision
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_en_curso($parametros)
	{
		$datos = array();
		$datos['evaluaciones'] = $this->get_datos_parciales($parametros);
		return $datos;
	}

	/**
	 * parametros: _ua, legajo, carrera, acta
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_promo($parametros)
	{
		$datos = array();
		$sql = "SELECT	sga_comisiones.comision,
						sga_comisiones.escala_notas,
						sga_comisiones.anio_academico,
						sga_comisiones.nombre,
						sga_comisiones.periodo_lectivo,
						sga_comisiones.catedra,
						DECODE(sga_comisiones.turno, 'M', 'Mañana', 'T', 'Tarde','N', 'Noche', '') as turno_cursada
				FROM	sga_actas_promo,
						sga_comisiones
				WHERE	sga_comisiones.comision = sga_actas_promo.comision
				AND		sga_actas_promo.unidad_academica	= {$parametros['_ua']}	
				AND		sga_actas_promo.acta				= {$parametros['acta']}";

		$datos_comision = array();
		$datos_comision  = kernel::db()->consultar_fila($sql);
		$parametros['comision'] = $datos_comision['COMISION'];

		if(!empty($datos_comision)) {
			$datos['evaluaciones'] = $this->get_datos_parciales($parametros);
		}
		$datos['comision']		= $datos_comision;

		return $datos;

	}

	/**
	 * parametros: _ua, legajo, carrera, acta
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_cursada($parametros)
	{
		$datos = array();
		$sql = "SELECT	sga_comisiones.comision,
						sga_comisiones.escala_notas,
						sga_comisiones.anio_academico,
						sga_comisiones.nombre,
						sga_comisiones.periodo_lectivo,
						sga_comisiones.catedra,
						DECODE(sga_comisiones.turno, 'M', 'Mañana', 'T', 'Tarde','N', 'Noche', '') as turno_cursada
				FROM	sga_actas_cursado,
						sga_comisiones
				WHERE	sga_comisiones.comision = sga_actas_cursado.comision
				AND		sga_actas_cursado.unidad_academica	= {$parametros['_ua']}	
				AND		sga_actas_cursado.acta				= {$parametros['acta']}";
		$datos = kernel::db()->consultar_fila($sql);
		return $datos;
	}

	/**
	 * parametros: _ua, equivalencia
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_equiv($parametros) 
	{
		$sql = "SELECT	sga_equiv_otorgada.vencimiento,
						to_char(sga_equiv_otorgada.vencimiento, '%d/%m/%Y') as fecha_vencimiento,
						sga_equiv_operac.nro_resolucion,
						sga_equiv_resol.observaciones,
						sga_equiv_otorgada.temas_a_rendir
				FROM	sga_equiv_otorgada, 
						sga_equiv_operac,
						sga_equiv_resol
				WHERE  	sga_equiv_operac.operacion_equiv 	= sga_equiv_otorgada.operacion_equiv
				AND		sga_equiv_resol.nro_resolucion  	= sga_equiv_operac.nro_resolucion
				AND    	sga_equiv_otorgada.equivalencia 	= {$parametros['equivalencia']}";
		
		return kernel::db()->consultar_fila($sql);
	}

	/**
	 * parametros: _ua, legajo, carrera, comision
	 * cache: memoria
	 * filas: n
	 */
	function get_datos_parciales($parametros)
	{
		$sql = "SELECT
						sga_atr_eval_parc.evaluacion as evaluacion,
						sga_eval_parc.descripcion as evaluacion_desc,
						sga_tipo_eval_parc.descripcion as tipo_evaluacion,
						sga_eval_parc_alum.fecha_hora as fecha_hora_parcial,
						to_char(sga_eval_parc_alum.fecha_hora, '%d/%m/%Y') as sfecha,
						to_char(sga_eval_parc_alum.fecha_hora, '%Y%m%d') as sfecha_orden,
						sga_eval_parc_alum.nota as nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						sga_eval_parc_alum.resultado as resultado,
						DECODE( sga_eval_parc_alum.resultado, 'A', 'Aprobado' , 'R', 'Reprobado' , 'U', 'Ausente' , 'P', 'Promocionado' ) as resultado_desc,
						sga_eval_parc_alum.corregido_por as corregido_por,
						sga_eval_parc_alum.observaciones as observaciones
				FROM 	sga_atr_eval_parc,
						sga_eval_parc,
						sga_tipo_eval_parc,
						sga_eval_parc_alum,
						OUTER sga_det_escala 
				WHERE	sga_eval_parc.evaluacion = sga_atr_eval_parc.evaluacion
				AND		sga_tipo_eval_parc.tipo_evaluac_parc = sga_eval_parc.tipo_evaluac_parc
				AND		sga_tipo_eval_parc.visible_al_alumno = 'S'
				AND		sga_eval_parc_alum.comision         = sga_atr_eval_parc.comision
				AND		sga_eval_parc_alum.evaluacion      = sga_atr_eval_parc.evaluacion
				AND		sga_det_escala.escala_notas = sga_atr_eval_parc.escala_notas
				AND		sga_det_escala.nota               = sga_eval_parc_alum.nota
				AND		sga_atr_eval_parc.comision			= {$parametros['comision']}
				AND		sga_eval_parc_alum.unidad_academica = {$parametros['_ua']}
				AND		sga_eval_parc_alum.carrera          = {$parametros['carrera']}
				AND		sga_eval_parc_alum.legajo           = {$parametros['legajo']}
				ORDER BY sga_eval_parc_alum.fecha_hora, sga_atr_eval_parc.evaluacion
				";

			return kernel::db()->consultar($sql);
	}

	/**
	 * parametros: _ua, legajo, carrera, plan, version
	 * cache: memoria
	 * filas: n
	 */
	function get_materias_genericas_alumno($parametros)
	{
		$datos = array();
		$sql = "SELECT	sga_mat_genericas.materia_generica,
						sga_mat_genericas.materia_optativa,
						sga_materias.nombre
				FROM	sga_opt_generica,
						sga_mat_genericas,
						sga_materias
				WHERE	sga_opt_generica.unidad_academica	= {$parametros["_ua"]}
				AND		sga_opt_generica.carrera			= {$parametros["carrera"]}
				AND		sga_opt_generica.plan				= {$parametros["plan"]} 
				AND		sga_opt_generica.version			= {$parametros["version"]} 
				AND		sga_mat_genericas.unidad_academica	= sga_opt_generica.unidad_academica
				AND		sga_mat_genericas.materia_generica	= sga_opt_generica.materia_generica
				AND		sga_mat_genericas.materia_optativa	= sga_opt_generica.materia_optativa
				AND		sga_materias.unidad_academica		= sga_opt_generica.unidad_academica
				AND		sga_materias.materia				= sga_opt_generica.materia_optativa
				AND		NOT EXISTS (
									SELECT	op_alu3.materia_optativa
									FROM	sga_opt_gen_alumno as op_alu3
									WHERE	op_alu3.unidad_academica	= sga_opt_generica.unidad_academica
									AND		op_alu3.carrera				= sga_opt_generica.carrera
									AND		op_alu3.legajo				=  {$parametros["legajo"]}
									AND		op_alu3.materia_optativa	= sga_opt_generica.materia_optativa
									)
				UNION ALL
				SELECT	sga_mat_genericas.materia_generica,
						sga_mat_genericas.materia_optativa,
						sga_materias.nombre
				FROM	sga_opt_gen_alumno,
						sga_mat_genericas,
						sga_materias
				WHERE	sga_opt_gen_alumno.unidad_academica	= {$parametros["_ua"]}
				AND		sga_opt_gen_alumno.carrera			= {$parametros["carrera"]}
				AND		sga_opt_gen_alumno.plan				= {$parametros["plan"]} 
				AND		sga_opt_gen_alumno.version			= {$parametros["version"]} 
				AND		sga_mat_genericas.unidad_academica = sga_opt_gen_alumno.unidad_academica
				AND		sga_mat_genericas.materia_generica = sga_opt_gen_alumno.materia_generica
				AND		sga_mat_genericas.materia_optativa = sga_opt_gen_alumno.materia_optativa
				AND		sga_materias.unidad_academica		= sga_opt_gen_alumno.unidad_academica
				AND		sga_materias.materia				= sga_opt_gen_alumno.materia_optativa
				ORDER BY 1,2,3;
				";

		$genericas = kernel::db()->consultar($sql);

		$datos = array();
		foreach ($genericas as $key => $generica) {
			$insertar['MATERIA_OPTATIVA']	= $generica['MATERIA_OPTATIVA'];
			$insertar['NOMBRE']				= $generica['NOMBRE'];
			$datos[$generica['MATERIA_GENERICA']][] = $insertar;
		}
		return $datos;
	}

	/**
	 * parametros: _ua, carrera, plan, version
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_plan_estudios($parametros)
	{
		$ret = array();
		//$sql = "execute procedure sp_planDeEstudios(" . $parametros["_ua"] . ", " . $parametros["carrera"] .",".$parametros['plan'] .",".$parametros['version'].")";
		$sql = "SELECT 
					sga_atrib_mat_plan.nombre_materia,
					sga_atrib_mat_plan.materia,
					sga_atrib_mat_plan.anio_de_cursada,
					sga_atrib_mat_plan.periodo_dictado,
					DECODE(sga_atrib_mat_plan.tipo_materia, 'G', 'Genérica', 'N', 'Normal', 'O', 'Optativa') as tipo_materia,
					sga_atrib_mat_plan.credito,
					sga_atrib_mat_plan.obligatoria,
					sga_atrib_mat_plan.tipo_materia as tipo_inicial,
					NVL(sga_atrib_mat_plan.anio_de_cursada,0) as anio_cursada_orden,
					NVL(sga_atrib_mat_plan.periodo_dictado,'') as per_dictado_orden
					     
				FROM sga_atrib_mat_plan
				WHERE sga_atrib_mat_plan.unidad_academica = {$parametros["_ua"]}
				AND sga_atrib_mat_plan.carrera = {$parametros["carrera"]}
				AND sga_atrib_mat_plan.plan = {$parametros["plan"]}
				AND sga_atrib_mat_plan.version = {$parametros["version"]}
				ORDER BY 9, 10, 1
				";
		$detalle_plan = kernel::db()->consultar($sql, db::FETCH_NUM);
		$genericas = $this->get_materias_genericas_alumno($parametros);

		foreach ($detalle_plan as $key => $materia) {
			$ret[$key]['MATERIA']			= $materia[1];
			$ret[$key]['NOMBRE_MATERIA']	= $materia[0]." (".$materia[1].")";
			$ret[$key]['TIPO']				= $materia[7];
			$ret[$key]['TIPO_DETALLE']		= kernel::traductor()->trans("plan.estado.".trim($materia[7]));
			$ret[$key]['ANIO']				= $materia[2];
			$ret[$key]['PERIODO']			= $materia[3];
			$ret[$key]['CREDITO']			= $materia[5];
			if ($materia[7] == 'G') {
				$ret[$key]['OPTATIVAS'] = $genericas[$detalle_plan[$key][1]];
			}
		}
		$ret_final = array();
		$ret_final['detalle'] = $ret;
		return  $ret_final; 
	}

	/**
	 * parametros: _ua,  carrera, plan
	 * cache: memoria
	 * filas: 1
	 */
	function get_titulo_grado($parametros)
	{
		$sql = "SELECT	sga_orientaciones.titulo,
						CASE sga_titulos_plan.calculo_egreso
						  WHEN 'CC' THEN 1
						  WHEN 'CO' THEN 1
						  WHEN 'CT' THEN 1
						  ELSE 0
						END as es_x_creditos
				FROM	sga_orientaciones,
						sga_titulos,
						sga_titulos_plan
				WHERE	sga_orientaciones.unidad_academica	= sga_titulos.unidad_academica
				AND		sga_orientaciones.titulo			= sga_titulos.titulo
				
				AND		sga_orientaciones.unidad_academica	= sga_titulos_plan.unidad_academica
				AND		sga_orientaciones.carrera			= sga_titulos_plan.carrera
				AND		sga_orientaciones.plan				= sga_titulos_plan.plan
				AND		sga_orientaciones.titulo			= sga_titulos_plan.titulo

				AND		sga_orientaciones.unidad_academica	= '".$parametros['_ua']."'
				AND		sga_orientaciones.carrera			= '".$parametros['carrera']."'
				AND		sga_orientaciones.plan				= '".$parametros['plan']."'
				AND		sga_orientaciones.orientacion		= '0'
				AND		sga_titulos.nivel					= 'GRADO';";

		return kernel::db()->consultar_fila($sql);

	}

	/**
	 * parametros: _ua,  carrera, legajo, titulo, materia
	 * cache: memoria
	 * filas: 1
	 */
	function get_resultado_generica($parametros)
	{
		/** Se realiza de la misma manera que en sp_evalua_materia retorna **/

		//Retorna:  char(1) = A - Aprobo / R - No Aprobo la Mat. Generica
		//integer = sumatoria de los crÃ©ditos de las optativas aprobadas

		$sql = "execute procedure sp_resultGenerica(".$parametros["_ua"].", 
													'".$parametros["carrera"]."',
													'".$parametros["legajo"]."',
													'".$parametros["titulo"]."',
													'0',
													".$parametros["materia"].")";

		return kernel::db()->consultar($sql, db::FETCH_NUM);
	}

	/**
	 * parametros: _ua,  carrera, plan, version, materia
	 * cache: memoria
	 * filas: n
	 */
	function get_optativas_generica($parametros)
	{
		$sql = "SELECT  sga_mat_genericas.materia_optativa,
						sga_atrib_mat_plan.nombre_materia,
						sga_atrib_mat_plan.nombre_reducido
				FROM 	sga_mat_genericas,
						sga_atrib_mat_plan
				WHERE 	sga_mat_genericas.unidad_academica = sga_atrib_mat_plan.unidad_academica
				AND		sga_mat_genericas.materia_optativa = sga_atrib_mat_plan.materia
				
				AND		sga_mat_genericas.unidad_academica	= '".$parametros['_ua']."'
				AND 	sga_atrib_mat_plan.carrera			= '".$parametros['carrera']."'
				AND 	sga_atrib_mat_plan.plan 			= '".$parametros['plan']."'
				AND 	sga_atrib_mat_plan.version 			= '".$parametros['version']."' 
				AND     sga_mat_genericas.materia_generica	= '".$parametros["materia"]."' 
				order by 1,2";
		
		return kernel::db()->consultar($sql);
	}

	/**
	 * parametros: _ua,  carrera, plan, version, materia
	 * cache: memoria
	 * filas: n
	 */
	function get_correlativas($parametros)
	{
		$sql = "SELECT	DECODE(sga_correlativas.condicion, 'C', 'cursar', 'A', 'aprobar','') as condicion,
						'CC' as tipo,
						sga_correlativas.orden,
						atmp.materia,
						atmp.nombre_materia,
						atmp.nombre_reducido,
						sga_correlativas.conector_logico,
						DECODE (sga_correlativas.condicion_anterior, 'A', 'Aprobada', 'C', 'Cursada', 'En curso') as estado,
						cast(NULL as varchar(255)) as descripcion
				FROM	sga_correlativas,
						sga_atrib_mat_plan as atmp
				WHERE	sga_correlativas.unidad_academica	= ".$parametros['_ua']."
				AND		sga_correlativas.carrera			= ".$parametros['carrera']."
				AND		sga_correlativas.plan				= ".$parametros['plan']."
				AND		sga_correlativas.version			= ".$parametros['version']."
				AND		sga_correlativas.materia			= ".$parametros["materia"]."
				AND		sga_correlativas.unidad_academica = atmp.unidad_academica
				AND		sga_correlativas.carrera = atmp.carrera
				AND		sga_correlativas.plan = atmp.plan
				AND		sga_correlativas.version = atmp.version
				AND		sga_correlativas.materia_anterior = atmp.materia
				UNION ALL
				SELECT	DECODE(sga_correlativ_esp.cursar_aprobar, 'C', 'cursar', 'A', 'aprobar','') as condicion,
						'CE' as tipo,
						cast(NULL as integer),
						cast(NULL as varchar(5)),
						cast(NULL as varchar(255)),
						cast(NULL as varchar(100)),
						cast(NULL as char(1)),
						cast(NULL as varchar(10)),
						sga_correlativ_esp.descripcion as descripcion
				FROM	sga_correlativ_esp
				WHERE	sga_correlativ_esp.unidad_academica	= ".$parametros['_ua']."
				AND		sga_correlativ_esp.carrera			= ".$parametros['carrera']."
				AND		sga_correlativ_esp.plan				= ".$parametros['plan']."
				AND		sga_correlativ_esp.version			= ".$parametros['version']."
				AND		sga_correlativ_esp.materia			= ".$parametros["materia"]."
				ORDER BY 1, 2, 3";
		
		return kernel::db()->consultar($sql);
		
	}

	/**
	 * parametros: _ua, carrera, legajo
	 * cache: memoria
	 * filas: n
	 */
	function historia_academica($parametros)
	{
		$sql = "SELECT *
				FROM vw_hist_academica 
				WHERE unidad_academica = {$parametros['_ua']}
				AND carrera = {$parametros['carrera']}
			    AND legajo = {$parametros['legajo']} ";
		$datos = kernel::db()->consultar($sql);
		return $datos;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function actuacion_provisoria($parametros)
	{
		$sql = "execute procedure sp_ActProvisoria({$parametros['_ua']}, {$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$resultado = array();
		$actas = "";
		if (!empty($datos)){
			$i=0;
			foreach($datos as $dato){
				$resultado[$i]['materia'] = $dato[8]." (".$dato[7].")";
				$parametros = array('escala_notas' =>$dato[11],
									'nota' => "'".$dato[6]."'");
				$nota_descripcion = $this->get_nota_descripcion($parametros);
				if ($nota_descripcion != ""){
					$resultado[$i]['nota'] = $dato[6]." (".$nota_descripcion.")";
					} else {
					$resultado[$i]['nota'] = $dato[6];	
					}
				$resultado[$i]['resultado'] = datos_comunes_actas::get_resultado($dato[5]);
				$resultado[$i]['fecha_examen'] = date("d/m/Y", strtotime($dato[4]));
				$resultado[$i]['carrera_reducido'] = $dato[9];
				$resultado[$i]['carrera'] = $dato[1];
				$resultado[$i]['legajo'] = $dato[2];
				$resultado[$i]['plan'] = $dato[12];
				$resultado[$i]['acta'] = $dato[3];
				$actas .= "'".$dato[3]."',";
				$i++;
			}

			$actas = substr($actas, 0, -1);
			$sql_info = "SELECT	sga_actas_examen.acta, 
								sga_actas_examen.anio_academico, 
								sga_actas_examen.turno_examen, 
								sga_actas_examen.llamado, 
								sga_actas_examen.mesa_examen 
						 FROM	sga_actas_examen
						 WHERE sga_actas_examen.acta IN ($actas);
						 ";
			$datos_info = kernel::db()->consultar($sql_info, db::FETCH_ASSOC);
			$nuevo_info = array();
			foreach($datos_info as $dato_info){				
				$nuevo_info[$dato_info['ACTA']] = $dato_info;
				unset($nuevo_info[$dato_info['ACTA']]['ACTA']);
			}

			foreach($resultado as $key => $result){
				$resultado[$key]['detalle']['anio_academico'] = $nuevo_info[$result['acta']]['ANIO_ACADEMICO'];
				$resultado[$key]['detalle']['turno_examen'] = $nuevo_info[$result['acta']]['TURNO_EXAMEN'];
				$resultado[$key]['detalle']['mesa_examen'] = $nuevo_info[$result['acta']]['MESA_EXAMEN'];
				$resultado[$key]['detalle']['llamado'] = $nuevo_info[$result['acta']]['LLAMADO'];
				unset($resultado[$key]['acta']);
			}
		}
		return $resultado;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function actuacion_provisoria_cursada($parametros)
	{
		$sql = "execute procedure sp_actProvCurs({$parametros['_ua']}, {$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$resultado = array();
		$i=0;
		foreach($datos as $dato){
			$resultado[$i]['materia'] = $dato[12]." (".$dato[8].")";
			$parametros = array('escala_notas' =>$dato[13],
								'nota' => "'".$dato[7]."'");
			$nota_descripcion = $this->get_nota_descripcion($parametros);
			if ($nota_descripcion != ""){
				$resultado[$i]['nota'] = $dato[7]." (".$nota_descripcion.")";
			}else{
				$resultado[$i]['nota'] = $dato[7];	
			}		
			$resultado[$i]['resultado'] = datos_comunes_actas::get_resultado($dato[5]);
			if (!empty($dato[4])){
				$resultado[$i]['fecha_regularidad'] = date("d/m/Y", strtotime($dato[4]));				
			} else {
				$resultado[$i]['fecha_regularidad'] = " ";
			}
			$resultado[$i]['carrera_reducido'] = $dato[10];
			$resultado[$i]['carrera'] = $dato[1];
			$resultado[$i]['legajo'] = $dato[2];			
			$resultado[$i]['plan'] = $dato[14];			
			$resultado[$i]['comision'] = $dato[11];
			$i++;
		}
		return $resultado;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function aulas($parametros)
	{
		$sql = "execute procedure sp_agendaDeClases({$parametros['_ua']}, {$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: n
	 */
	function tesis($parametros)
	{
		$sql = "execute procedure sp_estad_tesis_per({$parametros['_ua']}, {$parametros['nro_inscripcion']})";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;
				
		foreach($datos as $dato){			
			$linea['titulo'] = "(".$dato[3].") ".$dato[4];
			$linea['carrera'] = $dato[7];
			$linea['legajo'] = $dato[2];
			$linea['fecha_alta'] = $dato[8];
			$linea['fecha_vencimiento'] = $dato[9];
			$linea['fecha_aprobacion'] = $dato[10];
			$linea['estado'] = $dato[5];
			
			$nuevo[$i] = $linea;
			$i++;
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, carrera, legajo
	 * cache: memoria
	 * filas: n
	 */
	function regularidades($parametros)
	{
		$sql = "execute procedure sp_regulAlumno({$parametros['_ua']}, {$parametros['carrera']}, {$parametros['legajo']},3,3,3)";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['MATERIA'] = $dato[3];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[12];
			$nuevo[$id]['RESULTADO'] = $dato[7];
			$nuevo[$id]['FECHA_REGULARIDAD'] = "";
			$nuevo[$id]['FECHA_VENCIMIENTO'] = "";

			if (!empty($dato[10])){
				$nuevo[$id]['FECHA_REGULARIDAD'] = date("d/m/Y", strtotime($dato[10]));
			}

			if (!empty($dato[9])){
				$nuevo[$id]['FECHA_VENCIMIENTO'] = date("d/m/Y", strtotime($dato[9]));
			}

			$nuevo[$id]['DETALLE']['FECHA_VENCIMIENTO'] = $nuevo[$id]['FECHA_VENCIMIENTO'];
			$nuevo[$id]['DETALLE']['ANIO_ACADEMICO'] = $dato[4];
			$nuevo[$id]['DETALLE']['PER_LEC'] = $dato[5];
			$nuevo[$id]['DETALLE']['ORIGEN'] = $dato[8];
			$parametros = array('escala_notas' =>$dato[23],
								'nota' => "'".$dato[19]."'");
			$nota_descripcion = $this->get_nota_descripcion($parametros);
			if ($nota_descripcion != ""){
				$nuevo[$id]['DETALLE']['NOTA'] = $dato[19]." (".$nota_descripcion.")";
			} else {
				$nuevo[$id]['DETALLE']['NOTA'] = $dato[19];
			}			
		}
		return $nuevo;
	}

	/**
	 * cache: no
	 * filas: n
	 */
	function periodos_lectivos()
	{
		$sql = "execute procedure sp_perlects_actual()";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato){
			$id = catalogo::generar_id($dato[0].$dato[1]);
			$nuevo[$id] = $dato;
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, anio, periodo_lectivo
	 * cache: no
	 * filas: n
	 */
	function creditos($parametros)
	{
		$datos = array();
		$sql = "execute procedure sp_CredAluAnioPl ({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['anio']}, {$parametros['periodo_lectivo']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$resultado = array();
		$i = 0;
		foreach ($datos as $valor){
			$resultado[$i]['carrera'] = $valor[1];
			$resultado[$i]['cred_mano'] = $valor[3];
			$resultado[$i]['cred_cur'] = $valor[4];
			$i++;
		}
		return $resultado;
	}

	/**
	 * recupero las comisiones de la materia a las que el alumno está inscripto
	 * parametros: _ua, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function comision_inscripto($parametros)
	{
		$sql = "execute procedure sp_InscCurAlu({$parametros['_ua']}, {$parametros['carrera']}, {$parametros['legajo']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach ($datos as $dato){
			$id = catalogo::generar_id($dato[8]); //comision
			$nuevo[$id] = $dato;
		}
		return $nuevo;
	}

	/**
	 * recupero las comisiones/subcomisiones de periodos letivos que no finalizaron en que el alumno esta inscripto a cursar
	 * parametros: _ua, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function comisiones_subcomisiones_inscripto($parametros)
	{
		 // Retorna las comisiones y subcomisiones en las que el alumno esta inscripto.
		 // Si la comision no tiene subcomisiones, retorna una fila
		 // Si la comision tiene subcomsiones, retorna una fila por cada subcomsion.
		$sql = "-- Comisiones sin subcomisiones
			SELECT 
	 	       sga_insc_cursadas.unidad_academica,
               sga_insc_cursadas.carrera,
               sga_insc_cursadas.legajo,
               sga_insc_cursadas.comision,
               sga_insc_cursadas.plan,
               sga_comisiones.materia,
               DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional'),
               sga_insc_cursadas.fecha_inscripcion,
               sga_comisiones.periodo_lectivo,
               sga_comisiones.anio_academico,
               sga_insc_cursadas.nro_transaccion,
               DECODE(sga_insc_cursadas.estado, 'A', 'Activa', 'P', 'Pendiente', 'B', 'Baja', 'E', 'Exceptuado'),
               sga_comisiones.nombre,
               sga_comisiones.turno,
               sga_comisiones.catedra,
               sga_carreras.nombre,
               sga_atrib_mat_plan.nombre_materia,
               sga_atrib_mat_plan.nombre_reducido,
               to_char(sga_insc_cursadas.fecha_inscripcion, '%d/%m/%Y %H:%M') as fecha_inscripcion,
               CAST(NULL as integer) as subcomision,
               CAST(NULL as varchar(15)) as subcomision_nombre,
               CAST(NULL as varchar(100)) as tipo_clase_desc,
               0 as insc_a_subcomision

          FROM sga_insc_cursadas,
               sga_comisiones,
               sga_periodos_lect,
			   sga_carreras,
               sga_atrib_mat_plan,
			   sga_planes
         WHERE sga_insc_cursadas.unidad_academica   = {$parametros['_ua']}
           AND sga_insc_cursadas.carrera            = {$parametros['carrera']} 
           AND sga_insc_cursadas.legajo             = {$parametros['legajo']}
           AND sga_carreras.unidad_academica   = sga_insc_cursadas.unidad_academica   
           AND sga_carreras.carrera            =  sga_insc_cursadas.carrera
           AND sga_comisiones.comision              = sga_insc_cursadas.comision
           AND sga_planes.unidad_academica          = sga_insc_cursadas.unidad_academica
           AND sga_planes.carrera                   = sga_insc_cursadas.carrera
           AND sga_planes.plan                      = sga_insc_cursadas.plan
           AND sga_atrib_mat_plan.unidad_academica  = sga_planes.unidad_academica
           AND sga_atrib_mat_plan.carrera           = sga_planes.carrera
           AND sga_atrib_mat_plan.plan              = sga_planes.plan
           AND sga_atrib_mat_plan.version           = sga_planes.version_actual
           AND sga_atrib_mat_plan.materia           = sga_comisiones.materia
           AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
           AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
           AND sga_periodos_lect.fecha_fin >= TODAY
           AND NOT EXISTS (SELECT 1 FROM sga_subcomisiones as sc WHERE sc.comision = sga_comisiones.comision)
         UNION ALL
		       -- Comisiones con subcomisiones
		       SELECT 
	 	       sga_insc_cursadas.unidad_academica,
               sga_insc_cursadas.carrera,
               sga_insc_cursadas.legajo,
               sga_insc_cursadas.comision,
               sga_insc_cursadas.plan,
               sga_comisiones.materia,
               DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional'),
               sga_insc_cursadas.fecha_inscripcion,
               sga_comisiones.periodo_lectivo,
               sga_comisiones.anio_academico,
               sga_insc_cursadas.nro_transaccion,
               DECODE(sga_insc_cursadas.estado, 'A', 'Activa', 'P', 'Pendiente', 'B', 'Baja', 'E', 'Exceptuado'),
               sga_comisiones.nombre,
               sga_comisiones.turno,
               sga_comisiones.catedra,
               sga_carreras.nombre,
               sga_atrib_mat_plan.nombre_materia,
               sga_atrib_mat_plan.nombre_reducido,
               to_char(sga_insc_cursadas.fecha_inscripcion, '%d/%m/%Y %H:%M') as fecha_inscripcion,
               sga_insc_subcom.subcomision as subcomision,
               sga_subcomisiones.nombre as subcomision_nombre,
               sga_tipo_clase.descripcion as tipo_clase_desc,
               1 as insc_a_subcomision

          FROM sga_insc_cursadas,
               sga_comisiones,
               sga_insc_subcom,
               sga_subcomisiones,
               OUTER sga_tipo_clase,
               sga_periodos_lect,
               sga_atrib_mat_plan,
			   sga_carreras,
			   sga_planes
         WHERE sga_insc_cursadas.unidad_academica   = {$parametros['_ua']}
           AND sga_insc_cursadas.carrera            = {$parametros['carrera']} 
           AND sga_insc_cursadas.legajo             = {$parametros['legajo']}
           AND sga_carreras.unidad_academica   =sga_carreras.unidad_academica
           AND sga_carreras.carrera            = sga_insc_cursadas.carrera
           AND sga_insc_subcom.comision             = sga_insc_cursadas.comision
           AND sga_insc_subcom.unidad_academica     = sga_insc_cursadas.unidad_academica
           AND sga_insc_subcom.carrera              = sga_insc_cursadas.carrera
           AND sga_insc_subcom.legajo               = sga_insc_cursadas.legajo
           AND sga_comisiones.comision              = sga_insc_cursadas.comision
           AND sga_subcomisiones.comision           = sga_insc_cursadas.comision
           AND sga_subcomisiones.subcomision        = sga_insc_subcom.subcomision
           AND sga_tipo_clase.tipo_clase            = sga_subcomisiones.tipo_clase
           AND sga_planes.unidad_academica          = sga_insc_cursadas.unidad_academica
           AND sga_planes.carrera                   = sga_insc_cursadas.carrera
           AND sga_planes.plan                      = sga_insc_cursadas.plan
           AND sga_atrib_mat_plan.unidad_academica  = sga_planes.unidad_academica
           AND sga_atrib_mat_plan.carrera           = sga_planes.carrera
           AND sga_atrib_mat_plan.plan              = sga_planes.plan
           AND sga_atrib_mat_plan.version           = sga_planes.version_actual
           AND sga_atrib_mat_plan.materia           = sga_comisiones.materia
           AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
           AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
           AND sga_periodos_lect.fecha_fin >= TODAY
         
         ORDER BY 8,17";
		   
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		// ID = legajo, comision, subcomision
		foreach ($datos as $dato){
			$id = catalogo::generar_id($dato[2].$dato[3].$dato[19]);
			$nuevo[$id] = $dato;
		}
		
		// Para inscripciones a subcomisiones, se agrega un registro en el array sólo con la comisión
		foreach($nuevo as $comision){
			if($comision[22]==1){
				$id = catalogo::generar_id($comision[2].$comision[3]);
				$com[$id] = $comision;
				$com[$id][19] = null;
				$com[$id][20] = null;
			};
			$nuevo = array_merge($nuevo, $com);
		}
		sort($nuevo);
		return $nuevo;
	}


	/**
	 * recupero las clases de una comision/subcomision
	 * parametros: _ua, carrera, legajo, comision
	 * cache: no
	 * filas: n
	 */
	function temas_dictados($parametros)
	{
		//recuperar subcomisiones
		$sql_subs = "SELECT subcomision FROM sga_insc_subcom 
					WHERE unidad_academica = {$parametros['_ua']}
					AND carrera = {$parametros['carrera']}
					AND legajo = {$parametros['legajo']}
					AND comision = {$parametros['comision']}";

		$subcomisiones = kernel::db()->consultar($sql_subs, db::FETCH_NUM);

		$resultado_sub = array();
		if (empty($subcomisiones)){
			$sql = "execute procedure sp_ClasesComision({$parametros['comision']}, null)";
			$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
			$resultado_sub[0] = $datos;
		} else {
			foreach($subcomisiones as $subcomision){
				$sql = "execute procedure sp_ClasesComision({$parametros['comision']}, '$subcomision[0]')";
				$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
				$resultado_sub[$subcomision[0]] = $datos;
			}
		}

		$comision = str_replace("'", "", $parametros['comision']);
		$resultado = array();
		if (!empty($resultado_sub)){
			foreach($resultado_sub as $sub => $datos){
				$i=0;
				$id_sub = ($sub == "null") ? 0:+ $sub;
				$resultado[$id_sub]['subcomision'] = ($sub == "null") ? "":+ $sub;
				$resultado[$id_sub]['subcomision_nombre'] = $datos[0][7];
				$resultado[$id_sub]['comision'] = $comision;
				$resultado[$id_sub]['materia'] = $datos[0][3];
				foreach($datos as $dato){
					$resultado[$id_sub]['datos'][$i]['fecha'] = $dato[15]. " ". date("d/m/Y", strtotime($dato[9]));
					$inicio = \DateTime::createFromFormat('H:i:s', $dato[12]);	
					$fin = \DateTime::createFromFormat('H:i:s', $dato[13]);	
					$resultado[$id_sub]['datos'][$i]['inicio'] = $inicio->format('H:i')." - ".$fin->format('H:i');
					//$resultado[$id_sub]['datos'][$i]['fin'] = $fin->format('H:i');
					$resultado[$id_sub]['datos'][$i]['horas'] = $dato[14];
					$resultado[$id_sub]['datos'][$i]['tema'] = $dato[10];
					$resultado[$id_sub]['datos'][$i]['tipo_clase'] = $dato[16];
					$i++;
				}
			}			
		}
		return $resultado;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function estado_titulo($parametros)
	{
		$sql = "execute procedure sp_fichalutratitu({$parametros['_ua']}, {$parametros['nro_inscripcion']})";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		$i = 0;
		if (!empty($datos) && !empty($datos[0][8])){
			foreach($datos as $dato){
				$linea = array();

				if (isset($dato[18])){
					$linea['fecha'] = date("d/m/Y", strtotime($dato[18]));
				} else {
					$linea['fecha'] = "";
				}

				$linea['expediente'] = $dato[12];
				$linea['estado'] = $dato[16];
				$linea['prom_c_aplazos'] = $dato[13];
				$linea['prom_s_aplazos'] = $dato[14];

				$linea['carrera'] = "(".$dato[6].") ".$dato[5];
				$linea['legajo'] = $dato[8];
				$linea['plan'] = $dato[9];
				$linea['titulo'] = $dato[7];

				if (isset($dato[11])){
					$linea['fecha_egreso'] = date("d/m/Y", strtotime($dato[11]));
				} else {
					$linea['fecha_egreso'] = "";
				}

				if (isset($dato[19])){
					$linea['fecha_jura'] = date("d/m/Y", strtotime($dato[19]));
				} else {
					$linea['fecha_jura'] = "";
				}
				$nuevo[$i] = $linea;
				$i++;
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, alcance
	 * cache: no
	 * filas: n
	 */
	function inscripciones_examen_rechazadas($parametros)
	{
		$sql = "execute procedure sp_inscExamRecha({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['alcance']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;
		foreach($datos as $i => $dato){
			//$nuevo[$i]['materia'] = $dato[19]." (". $dato[3] .")";
			$nuevo[$i]['materia'] = $dato[19];
			$nuevo[$i]['anio'] = $dato[5];
			$nuevo[$i]['mesa'] = $dato[8];
			$nuevo[$i]['turno'] = $dato[6];
			$nuevo[$i]['fecha_dia'] = $dato[16];
			$nuevo[$i]['fecha_hora'] = $dato[17];
			$nuevo[$i]['fecha_inscr'] = $dato[4];
			$nuevo[$i]['tipo'] = $dato[20];			
			$nuevo[$i]['estado'] = $dato[21];
			$nuevo[$i]['sede'] = $dato[27];
			$nuevo[$i]['motivo'] = $dato[28];
			$nuevo[$i]['orden'] = $dato[5].$dato[6].$dato[16].$dato[4];
			$i++;
		}		
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, estado, alcance
	 * cache: no
	 * filas: n
	 */
	function inscripciones_examenes($parametros)
	{
		$sql = "execute procedure sp_inscExam({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['estado']}, {$parametros['alcance']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		$i = 0;

		foreach($datos as $dato){
			$nuevo[$i]['url_materia'] = catalogo::generar_id($dato[3]);
			$nuevo[$i]['url_mesa'] = catalogo::generar_id($dato[8]);
			$nuevo[$i]['materia'] = $dato[19]; //nombre reducido de la materia 
			$nuevo[$i]['carrera'] = $dato[1];
			$nuevo[$i]['anio'] = $dato[5];
			$nuevo[$i]['mesa'] = $dato[8];
			$nuevo[$i]['turno'] = $dato[6];
			$nuevo[$i]['fecha_dia'] = $dato[16];   // Fecha del examen. Formato dd/mm/yyyy 
			$nuevo[$i]['fecha_insc'] = substr($dato[17],10);  // Fecha de inscripcion. formato dd/mm/yyyy
			$nuevo[$i]['fecha_hora'] = $dato[17];  // Fecha y hora de inscripcion formato dd/mm/yyyy hh:mm
			$nuevo[$i]['tipo'] = $dato[20];
			$nuevo[$i]['estado'] = $dato[21];
			$nuevo[$i]['sede'] = $dato[27];
			$nuevo[$i]['docentes'] = $dato[18];
			$nuevo[$i]['fecha_inscr'] = $dato[4];
			$nuevo[$i]['orden'] = $dato[5].$dato[6].$dato[16].$dato[4];
			$nuevo[$i]['nro_transaccion'] = $dato[24];

			// Se agregan estos campos para que funcione el código de baja
			// genérico en transacciones/inscripcion_examen.php::eliminar_inscripcion($mesa)
			$nuevo[$i]['MATERIA'] = $dato[3];
			$nuevo[$i]['ANIO_ACADEMICO'] = $dato[5];
			$nuevo[$i]['TURNO_EXAMEN'] = $dato[6];
			$nuevo[$i]['MESA_EXAMEN'] = $dato[8];
			$nuevo[$i]['LLAMADO'] = $dato[7];
			$nuevo[$i]['ORDEN_INSC'] = $dato[28];
			$i++;
		}

		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, estado, alcance
	 * cache: no
	 * filas: n
	 */
	function inscripciones_cursadas($parametros)
	{
		$sql = "execute procedure sp_inscCursadas({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['estado']}, {$parametros['alcance']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;
		foreach($datos as $dato){
			$nuevo[$i]['url_materia'] = catalogo::generar_id($dato[5]);
			$nuevo[$i]['url_comision'] = catalogo::generar_id($dato[3]);
			$nuevo[$i]['id_comision'] = $dato[3];
			$nuevo[$i]['carrera'] = $dato[1];
			$nuevo[$i]['materia'] = $dato[20];
			$nuevo[$i]['comision'] = $dato[12];
			$nuevo[$i]['fecha'] = date("d/m/Y", strtotime($dato[7]));
			$nuevo[$i]['anio_acad'] = $dato[9];
			$nuevo[$i]['estado'] = $dato[11];
			$nuevo[$i]['sede'] = $dato[22];
			$nuevo[$i]['per_lec'] = $dato[8];
			$nuevo[$i]['turno'] = $dato[18];
			$nuevo[$i]['catedra'] = $dato[13];			
			$nuevo[$i]['orden'] = $dato[9].$dato[8].$dato[18];
			$nuevo[$i]['nro_transaccion'] = $dato[10];
                        $nuevo[$i]['url_nro_transaccion'] = catalogo::generar_id($dato[10]);
			$i++;
		}

		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, alcance
	 * cache: no
	 * filas: n
	 */
	function inscripciones_cursadas_rechazadas($parametros)
	{
		$sql = "execute procedure sp_inscCurs_Recha({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['alcance']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;
		foreach($datos as $dato){
			//$nuevo[$i]['materia'] = $dato[20]." (". $dato[5] .")";
			$nuevo[$i]['materia'] = $dato[20];
			$nuevo[$i]['comision'] = $dato[12];			
			$nuevo[$i]['fecha'] = date("d/m/Y", strtotime($dato[7]));
			$nuevo[$i]['anio_acad'] = $dato[9];
			$nuevo[$i]['estado'] = $dato[11];			
			$nuevo[$i]['sede'] = $dato[22];
			$nuevo[$i]['per_lec'] = $dato[8];
			$nuevo[$i]['turno'] = $dato[18];
			$nuevo[$i]['catedra'] = $dato[13];
			$nuevo[$i]['motivo'] = $dato[23];
			$nuevo[$i]['orden'] = $dato[9].$dato[8].$dato[18];
			$i++;
		}
		
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, term
	 * cache: no
	 * no_quote: term
	 * filas: n
	 */
	function buscar_alumno($parametros)
	{
        $termino = strtolower($parametros['term']);
        $delimitadores = array(",", ";");
        $termino = trim(str_replace($delimitadores, " ", $termino));
        $terminos = explode(" ", $termino);
        $no_vacio = function($string) {
            return $string != "";
        };
        $terminos = array_filter($terminos, $no_vacio);//quito los terminos vacios "".
        $terminos = array_unique($terminos);//quito los terminos repetidos.

        $like = "";
        if(count($terminos) > 0){
            $i = 0;
            $like .= " AND (";
            foreach($terminos as $term){

                if($i != 0){
                    $like .= " AND ";
                }

                $like .= "LOWER(p.apellido || ' ' || p.nombres || ' ' || a.legajo || ' ' || p.nro_documento) LIKE ".kernel::db()->quote_like($term, '%', '%');
                $i++;
            }
            $like .= ")";
        }

        $sql = "
				SELECT
					DISTINCT p.nro_inscripcion as nro_inscripcion,
					'(' || td.desc_abreviada || ': ' || p.nro_documento || ') ' || p.apellido || ', ' || p.nombres || ' (' || a.legajo || ')' as descripcion,
					p.apellido || ', ' || p.nombres as descripcion_persona
				FROM
					sga_alumnos as a
					JOIN sga_personas as p ON (p.unidad_academica = a.unidad_academica AND p.nro_inscripcion = a.nro_inscripcion)
					JOIN mdp_tipo_documento td ON (p.tipo_documento = td.tipo_documento)
				WHERE a.unidad_academica  = {$parametros['_ua']}
				{$like} 
				ORDER BY 2";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		if (!empty($datos)){
			foreach($datos as $key => $value) {
				$nuevo[$key][catalogo::id] = catalogo::generar_id($value[0]);
				$nuevo[$key][0] = $value[0];
				$nuevo[$key][1] = $value[1];
				$nuevo[$key][2] = $value[2];
			}
		}
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function datos_personales($parametros)
	{
		$sql = "EXECUTE PROCEDURE sp_fichaludatper ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach ($datos as $key => $dato) {
			$nuevo[$key]['unidad_academica'] = $dato[0];
			$nuevo[$key]['nro_inscripcion'] = $dato[1];
			$nuevo[$key]['apellido'] = $dato[2];
			$nuevo[$key]['nombres'] = $dato[3];
			$nuevo[$key]['documento_tipo'] = $dato[10];
			$nuevo[$key]['documento_numero'] = $dato[4];
			$nuevo[$key]['fecha_inscripcion'] = $dato[5];
			$nuevo[$key]['cedula_numero'] = $dato[7];
			$nuevo[$key]['cedula_emisor'] = $dato[11];
			$nuevo[$key]['titulo_secundario'] = $dato[12];
			$nuevo[$key]['anio_ingreso'] = $dato[6];

			$nuevo[$key]['domicilio_fecha_actualiza'] = $dato[13];
			$nuevo[$key]['domcilio_calle'] = $dato[14];
			$nuevo[$key]['domicilio_nro'] = $dato[15];
			$nuevo[$key]['domicilio_piso'] = $dato[16];
			$nuevo[$key]['domicilio_dpto'] = $dato[17];
			$nuevo[$key]['domicilio_unidad'] = $dato[18];
			
			
			$nuevo[$key]['telefono_linea'] = $dato[20];
			$nuevo[$key]['cel_nro'] = $dato[22];
			$nuevo[$key]['email'] = $dato[21];
			$nuevo[$key]['localidad'] = $dato[24];
			$nuevo[$key]['pcia'] = $dato[25];
			
			
			$nuevo[$key]['nacionalidad'] = $dato[26];
			$nuevo[$key]['localidad_nac'] = $dato[28];
			$nuevo[$key]['partido_nac'] = $dato[29];
			$nuevo[$key]['provincia_nac'] = $dato[30];
			$nuevo[$key]['pais_nac'] = $dato[31];
			
			$nuevo[$key]['fecha_nac'] = $dato[27];
			$nuevo[$key]['colegio_secundario'] = $dato[32];
			$nuevo[$key]['localidad_colegio'] = $dato[33];
			$nuevo[$key]['partido_colegio'] = $dato[34];
			$nuevo[$key]['provincia_colegio'] = $dato[35];
			$nuevo[$key]['pais_colegio'] = $dato[36];
		}
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function carreras($parametros){
		/*
		-- descripcion del RETURN. 
		-- vc_ua,  
		-- vc_NroInscripcion,  
		-- vc_apellido,  
		-- vc_nombres,  
		-- vc_carrera,  
		-- vc_carrera_nombre,  
		-- vc_legajo,  
		-- vc_Plan,  
		-- vd_FechaDesde,  
		-- vi_anio_academico de reinscripcion, 
		-- vc_Calidad,  
		-- vc_Regular,  
		-- vc_Observacion 
		-- vi_anio_acad_insc  Año academico de la Inscripcion 
		-- Resultado de la Insc a carrera 
		-- Descripcion de la situacion de la insc a carrera 
		-- sede original 
		-- sede actual 
		-- codigo sede original 
		-- codigo sede actual 
		-- resolucion ingreso 
		-- observaciones 
		-- descripcion tipo ingreso
		 */
		$sql = "EXECUTE PROCEDURE sp_fichalucarreras ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'vc_ua' => $dato[0],
				'vc_NroInscripcion' => $dato[1],
				'vc_apellido' => $dato[2],
				'vc_nombres' => $dato[3],
				'vc_carrera' => $dato[4],
				'vc_carrera_nombre' => $dato[5],
				'vc_legajo' => $dato[6],
				'vc_Plan' => $dato[7],
				'vd_FechaDesde' => $dato[8],
				'vi_anio_academico' => $dato[9],
				'vc_Calidad' => $dato[10],
				'vc_Regular' => $dato[11],
				'vc_Observacion' => $dato[12],
				'vi_anio_acad_insc' => $dato[13],
				'res_insc_carrera' => $dato[14],
				'desc_sit_insc_carrera' => $dato[15],
				'sede_original' => $dato[16],
				'sede_actual' => $dato[17],
				'codigo_sede_original' => $dato[18],
				'codigo_sede_actual' => $dato[19],
				'resolucion_ingreso' => $dato[20],
				'observaciones' => $dato[21],
				'descripcion_tipo_ingreso' => $dato[22]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function promedios($parametros){
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- varchar(5),   -- carrera 
		-- varchar(255), -- carrera_nombre 
		-- varchar(15),  -- legajo 
		-- varchar(5),   -- plan 
		-- decimal(6,2), -- promedio_con_aplazos 
		-- decimal(6,2), -- promedio_sin_aplazos 
		 */
		$sql = "EXECUTE PROCEDURE sp_fichaluprom ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'carrera_nombre' => $dato[5],
				'legajo' => $dato[6],
				'plan' => $dato[7],
				'promedio_con_aplazos' => $dato[8],
				'promedio_sin_aplazos' => $dato[9]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function perdidas_regularidad($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichaluperreg ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['legajo'] = $dato[6];
				$nuevo[$i]['anio_academico'] = $dato[7];
				$nuevo[$i]['perdida_regularidad'] = $dato[8];
				$nuevo[$i]['fecha_baja_regularidad'] = $dato[9];
				$nuevo[$i]['nro_resolucion_baja'] = $dato[10];
				$nuevo[$i]['fecha_rehab'] = $dato[11];
				$nuevo[$i]['nro_resolucion_rehab'] = $dato[12];
				$nuevo[$i]['fecha_venc_rehab'] = $dato[13];
				$nuevo[$i]['contabiliza'] = $dato[14];
				$nuevo[$i]['anio_rehab'] = $dato[15];
				$nuevo[$i]['tipo_rehab'] = $dato[16];
				$nuevo[$i]['fecha_baja_rehab'] = $dato[17];
				$nuevo[$i]['fecha_solucion'] = $dato[18];
				$nuevo[$i]['motivo_solucion'] = $dato[19];
				$nuevo[$i]['estado'] = $dato[20];
				$i ++;
			}
		}
		return $nuevo;		
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function sanciones($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichalusanper ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['tipo_sancion'] = $dato[4];
				$nuevo[$i]['resolucion'] = $dato[5];
				$nuevo[$i]['fecha_desde'] = $dato[6];
				$nuevo[$i]['fecha_hasta'] = $dato[7];
				$nuevo[$i]['estado'] = $dato[8];
				$nuevo[$i]['resolucion_cancelacion'] = $dato[9];
				$nuevo[$i]['fecha_cancelacion'] = $dato[10];
				$nuevo[$i]['afecta'] = $dato[11];
				$nuevo[$i]['carrera'] = $dato[12];
				$nuevo[$i]['grupo_carrera'] = $dato[13];
				$i ++;
			}
		}
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function ficha_alumno_regularidades($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichaluregular ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "" || $dato[$i] == "N");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'vc_UA' => $dato[0],
				'vc_NroInscripcion' => $dato[1],
				'vc_Apellido' => $dato[2],
				'vc_Nombres' => $dato[3],
				'vc_Carrera' => $dato[4],
				'vc_CarreraNombre' => $dato[5],
				'vc_Legajo' => $dato[6],
				'vc_Materia' => $dato[7],
				'vc_MateriaNombre' => $dato[8],
				'vc_Anio' => $dato[9],
				'vc_PerLect' => $dato[10],
				//U820 ************************
				'vc_Resultado' => $dato[12],
				'vc_ResultadoDesc' => $dato[11],
				//U820 ************************
				'vc_Origen' => $dato[13],
				'vd_FinVigencia' => $dato[14],
				'vd_Regularidad' => $dato[15],
				'vc_CondRegular' => $dato[16],
				'vc_PlanReg' => $dato[17],
				'regularidad_vigente_o_no_vigente' => $dato[18],
				'nota' => $dato[19],
				'nro_acta_regulares' => $dato[20],
				'materia_aprobada' => $dato[21],
				'nro_resolucion_equivalencia' => $dato[23],
				'vc_ComNombre' => $dato[23]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function actividades_extracurriculares($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichaluactextr ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['legajo'] = $dato[6];
				$nuevo[$i]['resol_activ'] = $dato[7];
				$nuevo[$i]['area'] = $dato[8];
				$nuevo[$i]['area_nombre'] = $dato[9];
				$nuevo[$i]['actividad'] = $dato[10];
				$nuevo[$i]['actividad_nombre'] = $dato[11];
				$nuevo[$i]['fecha'] = $dato[12];
				$nuevo[$i]['puntaje'] = $dato[13];
				$nuevo[$i]['plan'] = $dato[14];
				$nuevo[$i]['version'] = $dato[15];
				$i ++;
			}
		}
		return $nuevo;	
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function requisitos($parametros){
		
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- varchar(5),   -- carrera 
		-- varchar(255), -- carrera_nombre 
		-- varchar(15),  -- legajo 
		-- varchar(5),   -- requisito 
		-- varchar(60),  -- req_nombre 
		-- date,         -- req_fecha 
		-- varchar(255), -- req_obser 
		-- char(1),      -- obligatorio 
		-- char(1),      -- exceptuado 
		-- date --       -- fecha_prorroga
		 */
		$sql = "EXECUTE PROCEDURE sp_fichalurequi ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'carrera_nombre' => $dato[5],
				'legajo' => $dato[6],
				'requisito' => $dato[7],
				'req_nombre' => $dato[8],
				'req_fecha' => $dato[9],
				'req_obser' => $dato[10],
				'obligatorio' => $dato[11],
				'exceptuado' => $dato[12],
				'fecha_prorroga' => $dato[13]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function ficha_alumno_historia_academica($parametros){
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- varchar(5),   -- carrera 
		-- varchar(255), -- carrera_nombre 
		-- varchar(15),  -- legajo 
		-- varchar(5),   -- plan 
		-- varchar(5),   -- version 
		-- varchar(5),   -- materia 
		-- varchar(255), -- nombre de la materia 
		-- date,         -- fecha 
		-- varchar(15),  -- resultado 
		-- varchar(5),   -- nota 
		-- varchar(20),  -- forma de aprobacion 
		-- char(1),      -- tipo de acta 
		-- varchar(10),  -- acta 
		-- varchar(10),  -- acta promocion 
		-- varchar(15)   -- nro resolucion
		-- integer --folio fisico 
		 */
		$sql = "EXECUTE PROCEDURE sp_fichaluhisacad ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'carrera_nombre' => $dato[5],
				'legajo' => $dato[6],
				'plan' => $dato[7],
				'version' => $dato[8],
				'materia' => $dato[9],
				'nombre_materia' => $dato[10],
				'fecha' => $dato[11],
				'resultado' => $dato[12],
				'nota' => $dato[13],
				'forma_aprobacion' => $dato[14],
				'tipo_acta' => $dato[15],
				'acta' => $dato[16],
				'acta_promocion' => $dato[17],
				'nro_resolucion' => $dato[18],
				'folio_fisico' => $dato[19],
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function historia_academica_no_valida($parametros){
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- varchar(5),   -- carrera 
		-- varchar(255), -- carrera_nombre 
		-- varchar(15),  -- legajo 
		-- varchar(5),   -- plan 
		-- varchar(5),   -- version 
		-- varchar(5),   -- materia 
		-- varchar(255), -- nombre de la materia 
		-- date,         -- fecha 
		-- varchar(15),  -- resultado 
		-- varchar(5),   -- nota 
		-- varchar(20),  -- forma de aprobacion 
		-- char(1),      -- tipo de acta 
		-- varchar(10),  -- acta 
		-- integer,      -- acta promocion 
		-- varchar(15)   -- nro resolucion 
		-- INTEGER       -- Equivalencia 
		-- char(1)       -- Estado de la Nota (I/N/B) 
		-- integer       -- Motivo Movimiento 
		-- datetime      -- Fecha movimiento 
		-- varchar(15)   -- Nro Resolucion 
		-- varchar(255)  -- Observaciones 
		-- varchar(40)   -- Descripcion Abreviada Movimiento 
		*/
		
		$sql = "EXECUTE PROCEDURE sp_fichaluhainv ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'carrera_nombre' => $dato[5],
				'legajo' => $dato[6],
				'plan' => $dato[7],
				'version' => $dato[8],
				'materia' => $dato[9],
				'nombre_materia' => $dato[10],
				'fecha' => $dato[11],
				'resultado' => $dato[12],
				'nota' => $dato[13],
				'forma_aprobacion' => $dato[14],
				'tipo_acta' => $dato[15],
				'acta' => $dato[16],
				'acta_promocion' => $dato[17],
				'nro_resolucion' => $dato[18],
				'equivalencia' => $dato[19],
				'estado_nota' => $dato[20],
				'motivo_movimiento' => $dato[21],
				'fecha_movimiento' => $dato[22],
				'nro_resolucion_movimiento' => $dato[23],
				'observaciones_movimiento' => $dato[24],
				'desc_abreviada_movimiento' => $dato[25],
			);
			/* agregar al array el campo "acta_resolucion" para mostrarlo en el listado, y se setea segun estos valores:*/
			
			switch ($dato[14]){
				case 'Examen':
				case 'Examen equivalente':
					$dato_con_key['acta_resolucion'] = $dato[16];
				break;
				case 'Promoción':
				case 'Promoción en otra carrera':
				case 'Cursada':
				case 'Cursada Equivalente':
					$dato_con_key['acta_resolucion'] = $dato[17];
				break;
				case 'Equivalencia':
				case 'Equivalencia Parcial':
				case 'Equiv Parcial Equivalente':
				case 'Equiv. Parcial Equivalente':
					$dato_con_key['acta_resolucion'] = $dato[18];
				break;
			}
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function homologaciones($parametros){
		
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- varchar(5),   -- carrera 
		-- varchar(255), -- carrera_nombre 
		-- varchar(15),  -- legajo 
		-- varchar(5),   -- plan 
		-- varchar(5),   -- version 
		-- varchar(5),   -- materia 
		-- varchar(255), -- nombre de la materia 
		-- date,         -- fecha 
		 */
		
		$sql = "EXECUTE PROCEDURE sp_fichaluMatHom ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 9; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'carrera_nombre' => $dato[5],
				'legajo' => $dato[6],
				'plan' => $dato[7],
				'version' => $dato[8],
				'materia' => $dato[9],
				'nombre_materia' => $dato[10],
				'fecha' => $dato[11]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function certificados_solicitados($parametros){
		/*
		-- Descripcion del Return: 
		-- varchar(5),   -- unidad_academica 
		-- varchar(10),  -- nro_inscripcion 
		-- varchar(30),  -- apellido 
		-- varchar(30),  -- nombres 
		-- integer,      -- vc_Certificado,  
		-- varchar(60),  -- vc_NombreCertif,  
		-- integer,      -- vi_CantPedida,  
		-- integer,      -- vi_CopiasPedidas,  
		-- integer,      -- vi_CopiasImpresas
		 */
		$sql = "EXECUTE PROCEDURE sp_FichAluCerPed ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'unidad_academica' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'vc_Certificado' => $dato[4],
				'vc_NombreCertif' => $dato[5],
				'vi_CantPedida' => $dato[6],
				'vi_CopiasPedidas' => $dato[7],
				'vi_CopiasImpresas' => $dato[8]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function cambios_calidad($parametros){
		/*
		-- descripcion del RETURN. 
		pUA
		pNroInscripcion 
		vc_carrera
		vc_legajo
		vc_carrera_nombre
		vc_apellido
		vc_nombres
		vd_fecha
		vc_calidad
		vc_calidad_desc
		iMotivo
		vc_MotivoDesc
		vc_NroResolucion
		vc_responsable
		vc_observaciones
		 */
		$sql = "EXECUTE PROCEDURE sp_FichAluCalidad({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'pUA' => $dato[0],
				'pNroInscripcion' => $dato[1],
				'vc_carrera' => $dato[2],
				'vc_legajo' => $dato[3],
				'vc_carrera_nombre' => $dato[4],
				'vc_apellido' => $dato[5],
				'vc_nombres' => $dato[6],
				'vd_fecha' => $dato[7],
				'vc_calidad' => $dato[8],
				'vc_calidad_desc' => $dato[9],
				'iMotivo' => $dato[10],
				'vc_MotivoDesc' => $dato[11],
				'vc_NroResolucion' => $dato[12],
				'vc_responsable' => $dato[13],
				'vc_observaciones' => $dato[14]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function porcentaje_aprobacion($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichaluporcapro({$parametros['_ua']},{$parametros['nro_inscripcion']})";	
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['titulo'] = $dato[6];
				$nuevo[$i]['titulo_nombre'] = $dato[7];
				$nuevo[$i]['orientacion'] = $dato[8];
				$nuevo[$i]['orientacion_nombre'] = $dato[9];
				$nuevo[$i]['legajo'] = $dato[10];
				$nuevo[$i]['plan'] = $dato[11];
				$nuevo[$i]['porcentaje_aprobacion_orientacion'] = $dato[12];
				$nuevo[$i]['porcentaje_aprobacion_titulo'] = $dato[13];
				$nuevo[$i]['version_plan'] = $dato[14];
				$i ++;
			}
		}
		return $nuevo;		
	}
	
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function rep_inscripciones_cursadas($parametros){
		$sql = "EXECUTE PROCEDURE sp_FichAluInscCur({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][1])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['carrera'] = $dato[1];
				$nuevo[$i]['legajo'] = $dato[2];
				$nuevo[$i]['comision'] = $dato[3];
				$nuevo[$i]['plan'] = $dato[4];
				$nuevo[$i]['materia'] = $dato[5];
				$nuevo[$i]['calidad_insc'] = $dato[6];
				$nuevo[$i]['fecha_insc'] = $dato[7];
				$nuevo[$i]['periodo_lectivo'] = $dato[8];
				$nuevo[$i]['anio_academico'] = $dato[9];
				$nuevo[$i]['nro_transaccion'] = $dato[10];
				$nuevo[$i]['estado'] = $dato[11];
				$nuevo[$i]['comision_nombre'] = $dato[12];
				$nuevo[$i]['catedra_nombre'] = $dato[13];
				$nuevo[$i]['catedra_nombre_reducido'] = $dato[14];
				$nuevo[$i]['materia_nombre'] = $dato[15];
				$nuevo[$i]['alumno_nombre'] = $dato[16];
				$nuevo[$i]['interfase'] = $dato[17];
				$nuevo[$i]['turno_comision'] = $dato[18];
				$nuevo[$i]['creditos_materia'] = $dato[19];
				$i ++;
			}
		}
		return $nuevo;	
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function rep_inscripciones_examenes($parametros){
		$sql = "EXECUTE PROCEDURE sp_inscexam({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][1])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['carrera'] = $dato[1];
				$nuevo[$i]['legajo'] = $dato[2];
				$nuevo[$i]['materia'] = $dato[3];
				$nuevo[$i]['fecha_hora_inscripcion'] = $dato[4];
				$nuevo[$i]['anio_academico'] = $dato[5];
				$nuevo[$i]['turno_examen'] = $dato[6];
				$nuevo[$i]['llamado'] = $dato[7];
				$nuevo[$i]['mesa_examen'] = $dato[8];
				$nuevo[$i]['tipo_inscripcion'] = $dato[9];
				$nuevo[$i]['estado'] = $dato[10];
				$nuevo[$i]['equiv_parcial'] = $dato[11];
				$nuevo[$i]['materia_generica'] = $dato[12];
				$nuevo[$i]['catedra'] = $dato[13];
				$nuevo[$i]['admite_libres'] = $dato[14];
				$nuevo[$i]['grupo_carrera'] = $dato[15];
				$nuevo[$i]['dia_aula'] = $dato[16];
				$nuevo[$i]['hora_aula'] = $dato[17];
				$nuevo[$i]['docentes'] = $dato[18];
				$nuevo[$i]['materia_nombre_reducido'] = $dato[19];
				$nuevo[$i]['tipo_insc_nombre'] = $dato[20];
				$nuevo[$i]['estado_nombre'] = $dato[21];
				$nuevo[$i]['nombre_carrera_reducido'] = $dato[22];
				$nuevo[$i]['apellido_nombre'] = $dato[23];
				$nuevo[$i]['nro_transaccion'] = $dato[24];
				$nuevo[$i]['nombre_materia_completo'] = $dato[25];
				$nuevo[$i]['sede'] = $dato[26];
				$nuevo[$i]['nombre_sede'] = $dato[27];
				$i ++;
			}
		}
		return $nuevo;	
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function antecedentes_docentes($parametros){
		/*
		vc_unidad_acad,  
        vc_nro_inscrip, 
        vc_apellido, 
        vc_nombres, 
        vi_actuacion_doc,    
        vi_institucion,  
        vc_nombre_institu,    
        vc_cargo,    
        vc_materia,    
        vc_hora_sem_trab,    
        vc_fecha_desde,    
        vc_fecha_hasta,    
        vc_institucion_pre 
		 */
		$sql = "EXECUTE PROCEDURE sp_fichaluactuadoc({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'vc_unidad_acad' => $dato[0],
				'vc_nro_inscrip' => $dato[1],
				'vc_apellido' => $dato[2],
				'vc_nombres' => $dato[3],
				'vi_actuacion_doc' => $dato[4],
				'vi_institucion' => $dato[5],
				'vc_nombre_institu' => $dato[6],
				'vc_cargo' => $dato[7],
				'vc_materia' => $dato[8],
				'vc_hora_sem_trab' => $dato[9],
				'vc_fecha_desde' => $dato[10],
				'vc_fecha_hasta' => $dato[11],
				'vc_institucion_pre' => $dato[12]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function antecedentes_academicos($parametros){
		/*
		vc_unidad_acad,  
        vc_nro_inscrip, 
        vc_apellido, 
        vc_nombres, 
        vi_formacion_acad,    
        vc_titulo_superior,    
        vc_nombre_titsuper, 
        vi_institucion,    
        vc_nombre_institu,  
        vc_fecha_ingreso,    
        vc_fecha_egreso,    
        vc_titulo_tesis,    
        vc_director_tesis,    
        vc_categoria_coneau, 
        vi_duracion_teorica,    
        vc_titulo_sup_prein,    
        vc_institucion_prein 
		 */
		$sql = "EXECUTE PROCEDURE sp_fichaluformacad({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'vc_unidad_acad' => $dato[0],
				'vc_nro_inscrip' => $dato[1],
				'vc_apellido' => $dato[2],
				'vc_nombres' => $dato[3],
				'vi_formacion_acad' => $dato[4],
				'vc_titulo_superior' => $dato[5],
				'vc_nombre_titsuper' => $dato[6],
				'vi_institucion' => $dato[7],
				'vc_nombre_institu' => $dato[8],
				'vc_fecha_ingreso' => $dato[9],
				'vc_fecha_egreso' => $dato[10],
				'vc_titulo_tesis' => $dato[11],
				'vc_director_tesis' => $dato[12],
				'vc_categoria_coneau' => $dato[13],
				'vi_duracion_teorica' => $dato[14],
				'vc_titulo_sup_prein' => $dato[15],
				'vc_institucion_prein' => $dato[16]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function titulos($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichalutitulos({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['titulo'] = $dato[6];
				$nuevo[$i]['titulo_nombre'] = $dato[7];
				$nuevo[$i]['legajo'] = $dato[8];
				$nuevo[$i]['plan'] = $dato[9];
				$nuevo[$i]['version'] = $dato[10];				
				$nuevo[$i]['fecha_egreso'] = $dato[11];
				$nuevo[$i]['nro_expediente'] = $dato[12];
				$nuevo[$i]['promedio_general'] = $dato[13];
				$nuevo[$i]['promedio_sin_aplazos'] = $dato[14];
				$nuevo[$i]['estado'] = $dato[15];
				$nuevo[$i]['estado_nombre'] = $dato[16];
				$i ++;
			}
		}
		return $nuevo;	
	}	
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function tramite_titulos($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichalutratitu({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		$i = 0;
		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['titulo'] = $dato[6];
				$nuevo[$i]['titulo_nombre'] = $dato[7];
				$nuevo[$i]['legajo'] = $dato[8];
				$nuevo[$i]['plan'] = $dato[9];
				$nuevo[$i]['version'] = $dato[10];				
				$nuevo[$i]['fecha_egreso'] = $dato[11];
				$nuevo[$i]['nro_expediente'] = $dato[12];
				$nuevo[$i]['promedio_general'] = $dato[13];
				$nuevo[$i]['promedio_sin_aplazos'] = $dato[14];
				$nuevo[$i]['estado'] = $dato[15];
				$nuevo[$i]['estado_nombre'] = $dato[16];
				$nuevo[$i]['estado_nuevo'] = $dato[17];
				$nuevo[$i]['fecha_seguimiento'] = $dato[18];
				$nuevo[$i]['fecha_colacion'] = $dato[19];
				$i ++;
			}
		}
		return $nuevo;	
	}	

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function antecedentes_laborales($parametros){
		$sql = "EXECUTE PROCEDURE sp_fichaluactuapro({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){			
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['actuacion_profesional'] = $dato[4];
				$nuevo[$i]['empresa'] = $dato[5];
				$nuevo[$i]['cargo'] = $dato[6];
				$nuevo[$i]['area'] = $dato[7];
				$nuevo[$i]['hs_semanales_trabajadas'] = $dato[8];
				$nuevo[$i]['fecha_desde'] = $dato[9];
				$nuevo[$i]['fecha_hasta'] = $dato[10];
				$i ++;
			}
		}
		return $nuevo;	
	}	

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function prorrogas_regularidad($parametros){
		$sql = "EXECUTE PROCEDURE sp_FichAluProrreg({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		$i = 0;

		if (!empty($datos) && !empty($datos[0][4])){
			foreach($datos as $dato){	
				$nuevo[$i]['unidad_academica'] = $dato[0];
				$nuevo[$i]['nro_inscripcion'] = $dato[1];
				$nuevo[$i]['apellido'] = $dato[2];
				$nuevo[$i]['nombres'] = $dato[3];
				$nuevo[$i]['carrera'] = $dato[4];
				$nuevo[$i]['carrera_nombre'] = $dato[5];
				$nuevo[$i]['legajo'] = $dato[6];
				$nuevo[$i]['prorroga'] = $dato[7];
				$nuevo[$i]['materia'] = $dato[8];
				$nuevo[$i]['materia_nombre'] = $dato[9];
				$nuevo[$i]['tipo'] = $dato[10];
				$nuevo[$i]['fecha_prorroga'] = $dato[11];
				$nuevo[$i]['fin_vigencia_reg_ant'] = $dato[12];
				$nuevo[$i]['prorroga_hasta'] = $dato[13];
				$nuevo[$i]['resolucion_nro'] = $dato[14];
				$nuevo[$i]['anio'] = $dato[15];
				$nuevo[$i]['per_lect'] = $dato[16];
				$nuevo[$i]['acta'] = $dato[17];
				$nuevo[$i]['tramite_equiv'] = $dato[18];
				$nuevo[$i]['resolucion_equiv'] = $dato[19];
				$nuevo[$i]['equivalencia'] = $dato[20];
				$i ++;
			}
		}
		return $nuevo;	
	}	
	
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function excepciones($parametros){
		/*
		  RETURNING 
		  VARCHAR(5),   -- 0  ua
		  VARCHAR(10),  -- 1  nro_inscripcion
		  VARCHAR(30),  -- 2  apellido
		  VARCHAR(30),  -- 3  nombres
		  VARCHAR(5),   -- 4  carrera
		  VARCHAR(255), -- 5  nombre carrera
		  VARCHAR(15),  -- 6  legajo
		  VARCHAR(5),   -- 7  materia
		  VARCHAR(255), -- 8  nombre materia
		  INTEGER,      -- 9  anio academico
		  VARCHAR(20),  -- 10 turno examen/periodo_lectivo
		  VARCHAR(15),  -- 11 mesa examen/nombre comision
		  INTEGER,      -- 12 llamado/ comision
		  INTEGER,      -- 13 motivo excepcion
		  VARCHAR(255), -- 14 descripcion motivo
		  VARCHAR(7),   -- 15 cursada o examen
		  VARCHAR(255), -- 16 Observaciones de la excepcion
		  VARCHAR(255), -- 17 Mensaje del control exceptuado
		  INTEGER, -- 18 Control que falla
		  VARCHAR(40); -- 19 Descripcion abreviada del Control
		 */
		$sql = "EXECUTE PROCEDURE sp_FichAluExcepc({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$datos_con_key = array();
		foreach ($datos as $dato) {
			
			$vacio = true;
			for($i = 4; $i < count($dato); $i++){
				$vacio &= ($dato[$i] == "");
			}
			
			if($vacio){
				continue;
			}
			
			$dato_con_key = array(
				'ua' => $dato[0],
				'nro_inscripcion' => $dato[1],
				'apellido' => $dato[2],
				'nombres' => $dato[3],
				'carrera' => $dato[4],
				'nombre_carrera' => $dato[5],
				'legajo' => $dato[6],
				'materia' => $dato[7],
				'nombre_materia' => $dato[8],
				'anio_academico' => $dato[9],
				'turno_examen_periodo_lectivo' => $dato[10],
				'mesa_examen_nombre_comision' => $dato[11],
				'llamado_comision' => $dato[12],
				'motivo_excepcion' => $dato[13],
				'descripcion_motivo' => $dato[14],
				'cursada_o_examen' => $dato[15],
				'observaciones_de_la_excepcion' => $dato[16],
				'mensaje_control_exceptuado' => $dato[17],
				'control_que_falla' => $dato[18],
				'descripcion_abreviada_control' => $dato[19]
			);
			$datos_con_key[] = $dato_con_key;
		}
		return $datos_con_key;
	}	

	/**
	 * parametros: _ua, nro_inscripcion, carrera
	 * cache: no
	 * filas: n
	 */
	function get_titulos_carrera($parametros){

		$sql = "SELECT 
					sga_titulos.nombre as titulo_nombre,
					sga_titulos_plan.titulo
				FROM 	sga_alumnos,
					sga_titulos_plan,
						sga_titulos
				WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
				AND sga_alumnos.nro_inscripcion = {$parametros['nro_inscripcion']}
				AND sga_titulos_plan.carrera = {$parametros['carrera']}
				AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
				AND sga_titulos_plan.plan = sga_alumnos.plan
				AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
				AND sga_titulos.titulo = sga_titulos_plan.titulo
				ORDER BY sga_titulos.nombre";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, titulo, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function promedio_general($parametros){
		
		$sql = "EXECUTE PROCEDURE sp_promgralt({$parametros['unidad_academica']},{$parametros['nro_inscripcion']}, '{$parametros['titulo']}', {$parametros['carrera']}, {$parametros['legajo']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos[0];
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, titulo, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function promedio_sin_aplazos($parametros){

		$sql = "EXECUTE PROCEDURE sp_promsinaplazost({$parametros['unidad_academica']},{$parametros['nro_inscripcion']}, '{$parametros['titulo']}', {$parametros['carrera']}, {$parametros['legajo']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos[0];
	}

	/**
	 * parametros: _ua, nro_inscripcion, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function get_promedios_por_titulo($parametros){

		$titulos =  $this->get_titulos_carrera($parametros);
		$datos = array();
		foreach ($titulos as $titulo) {
			$params= array('unidad_academica' => $parametros['_ua'],
						  'nro_inscripcion' => $parametros['nro_inscripcion'],
						  'titulo' => $titulo[1],
						  'carrera' => $parametros['carrera'],
						  'legajo' => $parametros['legajo']				
			);
				
			$datos_titulo['nombre']	= $titulo[0];
			$datos_titulo['promedio_general']= $this->promedio_general($params);
			$datos_titulo['promedio_sin_aplazos']= $this->promedio_sin_aplazos($params);
			$datos[$titulo[1]] = $datos_titulo;
		}
		return $datos;
	}
	
	/**
	 * parametros: escala_notas, nota
	 * cache: memoria
	 * filas: n
	 */
	function get_nota_descripcion($parametros)
	{
		if(is_null($parametros[escala_notas]) OR $parametros[escala_notas] == "" OR is_null($parametros[nota]) OR $parametros[nota] == "" )
		{
			return "";
		}

		$sql = "SELECT	descripcion
				FROM	sga_det_escala
				WHERE	escala_notas = {$parametros['escala_notas']}
				AND		nota = {$parametros['nota']}";
		
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos[0];
	}
	
	

	/**
	 * parametros: _ua,  carrera, legajo, orientacion
	 * cache: memoria
	 * filas: 1
	 */
	function realizo_materias_de_la_orientacion($parametros)
	{
		/* Verifica si el alumno realizó alguna materia de la orientación.
		Busca materias de la orientacion que esten en acta de examen/promocion/cursada, equivalencias
		o que tenga inscripcion a cursada o examen.
		Devuelve: 
		          true  = el alumno realizó materias de la orientación
		          false = el alumno no realizó materias de la orientación
		*/
		
		// -------------------------------------------------------------------------------
		// 1. Verifico en la historia academica si el alumno realizó alguna materia de la orientacion
		// -------------------------------------------------------------------------------
		$sql = "SELECT count(*) AS cant
		          FROM vw_hist_academica 
		          WHERE unidad_academica = {$parametros['_ua']}
				    AND carrera	= {$parametros['carrera']}
				    AND legajo	= {$parametros['legajo']}
				    AND materia IN (SELECT mp.materia 
				                      FROM sga_alumnos as a,
				                           sga_planes as p,
				                           vw_materias_plan as mp
				                     WHERE a.unidad_academica = {$parametros['_ua']}
				                       AND a.carrera = {$parametros['carrera']}
				                       AND a.legajo = {$parametros['legajo']}
				                       AND p.unidad_academica = a.unidad_academica
				                       AND p.carrera = a.carrera
				                       AND p.plan = a.plan
				                       AND mp.unidad_academica = p.unidad_academica
				                       AND mp.carrera = p.carrera
				                       AND mp.plan = p.plan
				                       AND mp.version = p.version_actual
				                       AND mp.orientacion = {$parametros['orientacion']}
				                     )";  
		
		$datos = kernel::db()->consultar_fila($sql);
		
		// Si tiene algun examen final, promocion o equivalencia de una materia de la orientacion, salgo.
		if ($datos['CANT'] > 0) return true;
		
		// -------------------------------------------------------------------------------
		// 2. Ahora verifico en las cursadas y equivalencias parciales si el alumno realizó alguna materia de la orientacion
		// -------------------------------------------------------------------------------
		$sql = "SELECT count(*) AS cant
		          FROM sga_cursadas
		          WHERE unidad_academica = {$parametros['_ua']}
				    AND carrera	= {$parametros['carrera']}
				    AND legajo	= {$parametros['legajo']}
				    AND materia IN (SELECT mp.materia 
				                      FROM sga_alumnos as a,
				                           sga_planes as p,
				                           vw_materias_plan as mp
				                     WHERE a.unidad_academica = {$parametros['_ua']}
				                       AND a.carrera = {$parametros['carrera']}
				                       AND a.legajo = {$parametros['legajo']}
				                       AND p.unidad_academica = a.unidad_academica
				                       AND p.carrera = a.carrera
				                       AND p.plan = a.plan
				                       AND mp.unidad_academica = p.unidad_academica
				                       AND mp.carrera = p.carrera
				                       AND mp.plan = p.plan
				                       AND mp.version = p.version_actual
				                       AND mp.orientacion = {$parametros['orientacion']}
				                     )";  
		
		$datos = kernel::db()->consultar_fila($sql);

		// Si curso o tiene equivalencia parcial entonces salgo
		if ($datos['CANT'] > 0) return true;

		// -------------------------------------------------------------------------------
		// 3. Ahora verifico si tiene alguna inscripcion a cursada 
		// -------------------------------------------------------------------------------
		$sql = "SELECT count(*) AS cant
		          FROM sga_insc_cursadas, sga_comisiones
		          WHERE sga_insc_cursadas.unidad_academica = {$parametros['_ua']}
				    AND sga_insc_cursadas.carrera	= {$parametros['carrera']}
				    AND sga_insc_cursadas.legajo	= {$parametros['legajo']}
				    AND sga_comisiones.comision = sga_insc_cursadas.comision
				    AND sga_comisiones.materia IN (SELECT mp.materia 
				                      FROM sga_alumnos as a,
				                           sga_planes as p,
				                           vw_materias_plan as mp
				                     WHERE a.unidad_academica = {$parametros['_ua']}
				                       AND a.carrera = {$parametros['carrera']}
				                       AND a.legajo = {$parametros['legajo']}
				                       AND p.unidad_academica = a.unidad_academica
				                       AND p.carrera = a.carrera
				                       AND p.plan = a.plan
				                       AND mp.unidad_academica = p.unidad_academica
				                       AND mp.carrera = p.carrera
				                       AND mp.plan = p.plan
				                       AND mp.version = p.version_actual
				                       AND mp.orientacion = {$parametros['orientacion']}
				                     )";  
		
		$datos = kernel::db()->consultar_fila($sql);
		
		// Si se inscribio a cursar en alguna materia de la orientacion, salgo
		if ($datos['CANT'] > 0) return true;

		// -------------------------------------------------------------------------------
		// 4. Ahora verifico en las inscripciones a examenes si el alumno se inscribió a alguna materia de la orientacion
		// -------------------------------------------------------------------------------
		$sql = "SELECT count(*) AS cant
		          FROM sga_insc_examen
		          WHERE unidad_academica = {$parametros['_ua']}
				    AND carrera	= {$parametros['carrera']}
				    AND legajo	= {$parametros['legajo']}
				    AND materia IN (SELECT mp.materia 
				                      FROM sga_alumnos as a,
				                           sga_planes as p,
				                           vw_materias_plan as mp
				                     WHERE a.unidad_academica = {$parametros['_ua']}
				                       AND a.carrera = {$parametros['carrera']}
				                       AND a.legajo = {$parametros['legajo']}
				                       AND p.unidad_academica = a.unidad_academica
				                       AND p.carrera = a.carrera
				                       AND p.plan = a.plan
				                       AND mp.unidad_academica = p.unidad_academica
				                       AND mp.carrera = p.carrera
				                       AND mp.plan = p.plan
				                       AND mp.version = p.version_actual
				                       AND mp.orientacion = {$parametros['orientacion']}
				                     )";  
		
		$datos = kernel::db()->consultar_fila($sql);
		
		// Si se inscribió en alguna materia de la orientacion salgo
		if ($datos['CANT'] > 0) return true;
		
		// Si llego hasta aca entonces no hizo ninguna materia de la orientación.
		return false;

	}


	/**
	 * parametros: _ua, carrera, legajo, comision, subcomision, clases
	 * param_null: subcomision
	 * cache: no
	 * filas: n
	 */
	function rep_historial_de_asistencias($parametros){
		// Recupera el historial de asistencias en una comision o en una subcomision.

		// Recupero parametdos del Sistema % inasistencia para prom y regularizar
		$porc_asist_regular = \siu\modelo\entidades\parametro::asist_porcentaje_inasist_regul();
		$porc_asist_promocion = \siu\modelo\entidades\parametro::asist_porcentaje_inasist_promo();
		
		// Historial de asistencias en una comision/subcomision
		if($parametros["subcomision"]== "''")
		{
			$subcomision = "NULL";
		}
		else
		{
			$subcomision = $parametros["subcomision"];
		}
			$sql = "EXECUTE PROCEDURE sp_historial_asist(".
					$parametros['_ua'].",".
					$parametros['carrera'].",".
					$parametros['legajo'].",".
					$parametros['comision'].",".
					$subcomision.",".
					$parametros['clases'].")";			
					
			
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		//$i = 0;

		//if (!empty($datos) && !empty($datos[0][1])){
			foreach($datos as $dato){			
 		        $nuevo[$dato[0]]['comision']        = $dato[0]; 
 	            $nuevo[$dato[0]]['materia']         = $dato[1]; 
 		        $nuevo[$dato[0]]['carrera_com']     = $dato[2]; 
 	            $nuevo[$dato[0]]['anio_academico']  = $dato[3]; 
 		        $nuevo[$dato[0]]['periodo_lectivo'] = $dato[4]; 
 		        $nuevo[$dato[0]]['comision_nombre'] = $dato[5]; 
 		        $nuevo[$dato[0]]['materia_nombre']  = $dato[6]; 
 		        $nuevo[$dato[0]]['carrera_nombre']  = $dato[7]; 
 	            $nuevo[$dato[0]]['unidad_academica'] = $dato[8]; 
 	            $nuevo[$dato[0]]['carrera']         = $dato[9]; 
			    $nuevo[$dato[0]]['legajo']          = $dato[10]; 
				$nuevo[$dato[0]]['apellido']        = $dato[11]; 
				$nuevo[$dato[0]]['nombres']         = $dato[12]; 
				$nuevo[$dato[0]]['subcomision_nombre'] = $dato[18]; 
				$nuevo[$dato[0]]['sede']            = $dato[19]; 
				$nuevo[$dato[0]]['sede_nombre']     = $dato[20]; 
				$nuevo[$dato[0]]['porc_asist_regular']   = $porc_asist_regular; 
				$nuevo[$dato[0]]['porc_asist_promocion'] = $porc_asist_promocion;

				$clase['clase_fecha']     = $dato[22]." ".$dato[21]; 
				$clase['cant_inasistencias']   = $dato[14]; 
				$clase['desc_inasistencias']  = $dato[15]; 
				$clase['cant_justificadas']    = $dato[16]; 
				$clase['desc_justificacion']   = $dato[17];
				//$clase['dia_semana']   = $dato[22];
				$clase['tipo_clase_desc']   = $dato[23];
				$clase['horas_dictadas']   = $dato[24];
				$clase['tema_previsto']   = $dato[25];
				$clase['tema_dictado']   = $dato[26];
				
				$nuevo[$dato[0]]['cant_clases'] += 1; 
				$nuevo[$dato[0]]['cant_inasistencias'] += $dato[14]; 
				$nuevo[$dato[0]]['cant_justificadas'] += $dato[16]; 

				$nuevo[$dato[0]]['clases'][] = $clase; 
				unset($clase);
				

			}
		
		return $nuevo;	
		
	}
	
/**
	 * parametros: _ua, carrera, legajo
	 * cache: memoria
	 * filas: n
	 */	
	function get_nro_inscripcion($parametros)
	{
		$sql = "SELECT	nro_inscripcion
				FROM	sga_alumnos
				WHERE unidad_academica = {$parametros['_ua']}
				AND carrera = {$parametros['carrera']}
				AND legajo = {$parametros['legajo']}";
		$datos = kernel::db()->consultar_fila($sql);
		return $datos['NRO_INSCRIPCION'];
		
	}
	
	
}	
?>
