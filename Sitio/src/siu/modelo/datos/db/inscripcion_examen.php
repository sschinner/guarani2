<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use kernel\util\db\db;

class inscripcion_examen
{
	/**
	 * parametros: _ua, carrera, legajo, nro_inscripcion, plan, version, filtro_materias_con_mesa_exa, filtro_rendir_regul_planes_anteriores
         * no_quote: carrera, plan, version
	 * cache: no
	 * filas: n
	 */
	function lista_materias($parametros) 
	{
		// --------------------------------------------------------------------------------------------- 
		// Materias del plan actual del alumno que no estan aprobadas (con/sin mesas de examen creadas)
		// ----------------------------------------------------------------------------------------------
		$sql = "execute procedure sp_matinscexamalu ({$parametros['_ua']},".
													"'{$parametros['carrera']}',".
													"{$parametros['legajo']},".
													"{$parametros['nro_inscripcion']},".
													"'{$parametros['plan']}',".
													"'{$parametros['version']}', ".
													"{$parametros['filtro_materias_con_mesa_exa']})";
													
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$nuevo[$dato[1]][catalogo::id] = catalogo::generar_id($dato[1]);
			$nuevo[$dato[1]]['CARRERA']					= $parametros['carrera'];
			$nuevo[$dato[1]]['CARRERA_NOMBRE']			= $dato[2];
			$nuevo[$dato[1]]['MATERIA']					= $dato[1];
			$nuevo[$dato[1]]['MATERIA_NOMBRE']			= $dato[3];
			$nuevo[$dato[1]]['ORIENTACION']				= $dato[4];
			$nuevo[$dato[1]]['ORIENTACION_NOMBRE']		= $dato[5];
			$nuevo[$dato[1]]['MATERIA_GENERICA']		= $dato[6];
			$nuevo[$dato[1]]['NOMBRE_MATERIA_GENERICA']	= $dato[7];
                                                      $nuevo[$dato[1]]['PLAN_ACTUAL']	            = '1';   // Materias del Plan Actual del Alumno
			$nuevo[$dato[1]]['PLAN']	                = $parametros['plan'];      // Plan actual del alumno
			$nuevo[$dato[1]]['VERSION']	                = $parametros['version'];   // Version del plan actual del alumno
                                    }
 
 	    
                                    // Solo ejecutar el codigo siguiente si el parametro rendir_regul_planes_anteriores = S
                                    if ($parametros['filtro_rendir_regul_planes_anteriores'] == "'S'")
                                    {
			// --------------------------------------------------------------------------------------------- 
			// Materias del plan anterior que no estan en el plan actual del alumno y estan regularizadas y vigentes
			// ----------------------------------------------------------------------------------------------
			$sql = "execute procedure sp_matInsExamAluPA({$parametros['_ua']},".
														"'{$parametros['carrera']}',".
														"{$parametros['legajo']},".
														"{$parametros['nro_inscripcion']},".
														"'{$parametros['plan']}',".
														"'{$parametros['version']}', ".
														"{$parametros['filtro_materias_con_mesa_exa']})";
			$datos2 = kernel::db()->consultar($sql, db::FETCH_NUM);
                        
 			// Agrego las materias al array anterior
			foreach($datos2 as $dato) {
				$nuevo[$dato[1]][catalogo::id] = catalogo::generar_id($dato[0]);
				$nuevo[$dato[1]]['CARRERA']	         		= $parametros['carrera'];
				$nuevo[$dato[1]]['CARRERA_NOMBRE']			= '';
				$nuevo[$dato[1]]['MATERIA']					= $dato[0];
				$nuevo[$dato[1]]['MATERIA_NOMBRE']			= $dato[1];
				$nuevo[$dato[1]]['ORIENTACION']				= $dato[2];
				$nuevo[$dato[1]]['ORIENTACION_NOMBRE']		= $dato[3];
				$nuevo[$dato[1]]['MATERIA_GENERICA']		= $dato[4];
				$nuevo[$dato[1]]['NOMBRE_MATERIA_GENERICA']	= $dato[5];
				$nuevo[$dato[1]]['PLAN_ACTUAL']	            = '0';       // Materias regularizadas de planes anteriores
				$nuevo[$dato[1]]['PLAN']	                = $dato[6];  // Plan en que regularizo la materia
				$nuevo[$dato[1]]['VERSION']	                = $dato[7];  // Version del plan donde regularizó la materia
                                                        }
 		}
                
		return $nuevo;
	}

	/**
	 * parametros: _ua, carrera, legajo, materia, plan, version, es_plan_actual, param_exa_tipo_insc, param_exa_sede, param_exa_modalidad
                   * no_quote: es_plan_actual
	 * cache: no
	 * filas: n
	 */
	function lista_mesas($parametros)
	{
		// -----------------------------------------------------------------------------------------------------
		//Recupera la lista de mesas de examen de la materia pasada por parámetro  para inscripciones a examenes
		// -----------------------------------------------------------------------------------------------------

		// es_plan_actual: 1 - La materia es del plan Actual del alumno
		//                 0 - La materia es de un plan anterior del alumno.
		// 
		// Parámetros del sistema que reciben los procedures:
		//   param_exa_tipo_insc   ->  insc_examen_seleccion_auto_tipo_insc
		//   param_exa_sede        ->  rinde_en_cualquier_sede
		//   param_exa_modalidad   ->  modalidad_de_inscripciones_a_examenes
		
		// --------------------------------------------------
		// La materia es del plan actual del alumno
		// --------------------------------------------------
		if ($parametros['es_plan_actual'] == 1) {
			$sql = "execute procedure sp_mesasmatinscex({$parametros['_ua']},
													  {$parametros['carrera']},
													  {$parametros['legajo']},
													  {$parametros['materia']},
													  NULL,
													  {$parametros['plan']},
													  {$parametros['version']},
													  {$parametros['param_exa_tipo_insc']},
													  {$parametros['param_exa_sede']},
													  {$parametros['param_exa_modalidad']})";
		 }
                 
                                    /*
                                            // ----------------------------------------------------------------
                                            // La materia es de un plan anterior..
                                            // ----------------------------------------------------------------
                                     */
                 
		if ($parametros['es_plan_actual'] == 0) {
			$sql = "execute procedure sp_mesmatinscexant({$parametros['_ua']},
													   {$parametros['carrera']},
													   {$parametros['legajo']},
													   {$parametros['materia']},
													   NULL,
													   {$parametros['plan']},
													   {$parametros['version']},
													   {$parametros['param_exa_tipo_insc']},
													   {$parametros['param_exa_sede']},
													   {$parametros['param_exa_modalidad']})";
		}

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			// OJO. SI ESTA CLAVE CAMBIA TAMBIÉN LO HACE LA CLAVE DE info_inscripciones
			$key = catalogo::generar_id($dato[0].$dato[1].$dato[2].$dato[5].$dato[6].$dato[7].$dato[11].$dato[3]);
			$nuevo[$key][catalogo::id]	= $key;
			$nuevo[$key]['UNIDAD_ACADEMICA']	= $dato[0];
			$nuevo[$key]['CARRERA']				= $dato[1];
			$nuevo[$key]['LEGAJO']				= $dato[2];
			$nuevo[$key]['MATERIA']				= $dato[3];
			$nuevo[$key]['MATERIA_GENERICA']	= $dato[4];
			$nuevo[$key]['ANIO_ACADEMICO']		= $dato[5];
			$nuevo[$key]['TURNO_EXAMEN']		= $dato[6];
			$nuevo[$key]['MESA_EXAMEN']			= $dato[7];
			$nuevo[$key]['CATEDRA']				= $dato[8];
			$nuevo[$key]['GRUPO_CARRERA']		= $dato[9];
			$nuevo[$key]['INSCRIBIR_COMO']		= $dato[10];
			$nuevo[$key]['LLAMADO']				= $dato[11];
			$nuevo[$key]['FECHA_INI_INSC_LLAMADO']= $dato[12];
			$nuevo[$key]['FECHA_FIN_INSC_LLAMADO']= $dato[13];
			$nuevo[$key]['HORA_PRESTAMO_AULA']	= $dato[14];
			$nuevo[$key]['FECHA_PRESTAMO_AULA']	= $dato[15];
			$nuevo[$key]['DOCENTES']			= $dato[16];
			$nuevo[$key]['SEDE']				= $dato[17];
			$nuevo[$key]['SEDE_NOMBRE']			= $dato[18];
                                                      $nuevo[$key]['FECHA_EXAMEN']		= $dato[19];  // Formato dd/mm/yyyy
		}
		
		// Retorno las mesas de examen de la materia.
		return $nuevo;	
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function info_inscripciones($parametros)
	{
		$sql = "SELECT
						sga_insc_examen.unidad_academica,
						sga_insc_examen.carrera,
						sga_insc_examen.legajo,
						sga_insc_examen.tipo_inscripcion,
						sga_insc_examen.materia,
						sga_insc_examen.anio_academico,
						sga_insc_examen.turno_examen,
						sga_insc_examen.llamado,
						sga_insc_examen.mesa_examen,
						sga_insc_examen.fecha_inscripcion,
						sga_insc_examen.nro_transaccion,
						sga_insc_examen.estado,
						(SELECT count(*) 
							FROM sga_insc_examen as ie
							WHERE ie.unidad_academica  = sga_insc_examen.unidad_academica
							  AND ie.materia           = sga_insc_examen.materia
							  AND ie.anio_academico    = sga_insc_examen.anio_academico
							  AND ie.turno_examen      = sga_insc_examen.turno_examen
							  AND ie.mesa_examen       = sga_insc_examen.mesa_examen
							  AND ie.llamado           = sga_insc_examen.llamado
							  AND ie.fecha_inscripcion <= sga_insc_examen.fecha_inscripcion
						) as orden_insc

				FROM
						sga_alumnos,
						sga_insc_examen,
						sga_llamados_mesa,
						sga_prestamos

				WHERE	sga_alumnos.unidad_academica = {$parametros['_ua']}	
				AND		sga_alumnos.nro_inscripcion  = {$parametros['nro_inscripcion']}
				AND		sga_insc_examen.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_insc_examen.carrera          = sga_alumnos.carrera
				AND		sga_insc_examen.legajo           = sga_alumnos.legajo
				AND		sga_llamados_mesa.unidad_academica  = sga_insc_examen.unidad_academica
				AND		sga_llamados_mesa.materia           = sga_insc_examen.materia
				AND		sga_llamados_mesa.anio_academico    = sga_insc_examen.anio_academico
				AND		sga_llamados_mesa.turno_examen      = sga_insc_examen.turno_examen
				AND		sga_llamados_mesa.mesa_examen       = sga_insc_examen.mesa_examen
				AND		sga_llamados_mesa.llamado           = sga_insc_examen.llamado
				AND		sga_prestamos.prestamo = sga_llamados_mesa.prestamo 
				AND		sga_prestamos.fecha    >= TODAY
				";
			
		$datos = kernel::db()->consultar($sql);
		$nuevo = array();
		foreach($datos as $dato) {
			// OJO. SI ESTA CLAVE CAMBIA TAMBIÉN LO HACE LA CLAVE DE lista_mesas
			$key = catalogo::generar_id(
					$dato['UNIDAD_ACADEMICA'].
					$dato['CARRERA'].
					$dato['LEGAJO'].
					$dato['ANIO_ACADEMICO'].
					$dato['TURNO_EXAMEN'].
					$dato['MESA_EXAMEN'].
					$dato['LLAMADO'].
					$dato['MATERIA']
			);
			
			$nuevo[$key][catalogo::id]	= $key;
			$nuevo[$key]['UNIDAD_ACADEMICA']	= $dato['UNIDAD_ACADEMICA'];
			$nuevo[$key]['CARRERA']				= $dato['CARRERA'];
			$nuevo[$key]['LEGAJO']				= $dato['LEGAJO'];
			$nuevo[$key]['TIPO_INSCRIPCION']	= $dato['TIPO_INSCRIPCION'];
			$nuevo[$key]['MATERIA']				= $dato['MATERIA'];
			$nuevo[$key]['ANIO_ACADEMICO']		= $dato['ANIO_ACADEMICO'];
			$nuevo[$key]['TURNO_EXAMEN']		= $dato['TURNO_EXAMEN'];
			$nuevo[$key]['LLAMADO']				= $dato['LLAMADO'];
			$nuevo[$key]['MESA_EXAMEN']			= $dato['MESA_EXAMEN'];
			$nuevo[$key]['FECHA_INSCRIPCION']	= $dato['FECHA_INSCRIPCION'];
			$nuevo[$key]['URL_NRO_TRANSACCION']	= catalogo::generar_id($dato['NRO_TRANSACCION']);
			$nuevo[$key]['NRO_TRANSACCION']		= $dato['NRO_TRANSACCION'];
			$nuevo[$key]['ESTADO']				= $dato['ESTADO'];
			$nuevo[$key]['ORDEN_INSC']				= $dato['ORDEN_INSC'];
		}
		return $nuevo;
	}
	
   /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function info_nro_transacciones_inscripciones_historicas($parametros) {
		$sql = "SELECT sga_insc_examen.nro_transaccion 
                        FROM sga_insc_examen
                        JOIN sga_alumnos ON (sga_insc_examen.unidad_academica = sga_alumnos.unidad_academica
                                            AND	sga_insc_examen.carrera = sga_alumnos.carrera
                                            AND	sga_insc_examen.legajo = sga_alumnos.legajo)
                        WHERE sga_alumnos.nro_inscripcion = {$parametros['nro_inscripcion']}
                        AND sga_insc_examen.unidad_academica = {$parametros['_ua']}";
		$datos = kernel::db()->consultar($sql);
		$nuevo = array();
		foreach ($datos as $key => $dato) {
			$nuevo[$key]['URL_NRO_TRANSACCION'] = catalogo::generar_id($dato['NRO_TRANSACCION']);
			$nuevo[$key]['NRO_TRANSACCION'] = $dato['NRO_TRANSACCION'];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function info_nro_transacciones_bajas($parametros) {
		$sql = "SELECT  sga_insc_exa_bajas.nro_transaccion,
						sga_insc_exa_bajas.nro_transac_baja 
                        FROM sga_insc_exa_bajas
                        JOIN sga_alumnos ON (sga_insc_exa_bajas.unidad_academica = sga_alumnos.unidad_academica
                                            AND	sga_insc_exa_bajas.carrera = sga_alumnos.carrera
                                            AND	sga_insc_exa_bajas.legajo = sga_alumnos.legajo)
                        WHERE sga_alumnos.nro_inscripcion = {$parametros['nro_inscripcion']}
                        AND sga_insc_exa_bajas.unidad_academica = {$parametros['_ua']}";
		$datos = kernel::db()->consultar($sql);
		$nuevo = array();
		foreach ($datos as $key => $dato) {
			$nuevo[$key]['URL_NRO_TRANSACCION'] = catalogo::generar_id($dato['NRO_TRANSACCION']);
			$nuevo[$key]['URL_NRO_TRANSACCION_BAJA'] = catalogo::generar_id($dato['NRO_TRANSAC_BAJA']);
			$nuevo[$key]['NRO_TRANSACCION'] = $dato['NRO_TRANSACCION'];
			$nuevo[$key]['NRO_TRANSACCION_BAJA'] = $dato['NRO_TRANSAC_BAJA'];
		}
		return $nuevo;
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
						sga_insc_examen.unidad_academica,
						sga_insc_examen.carrera,
						sga_carreras.nombre as nombre_carrera,
						sga_personas.apellido || ' ' || sga_personas.nombres as nombre_alumno,
						sga_insc_examen.legajo,
						sga_insc_examen.tipo_inscripcion, 
						sga_tipos_mesa.descripcion as tipo_insc_desc,
						sga_insc_examen.materia,
						NVL(atmp.nombre_materia , sga_materias.nombre) as nombre_materia,
						NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_red_materia,
						sga_insc_examen.anio_academico,
						sga_insc_examen.turno_examen,
						sga_insc_examen.llamado,
						sga_insc_examen.mesa_examen,
						DECODE(sga_insc_examen.estado, 'P', 'Pendiente', 'A', 'Aceptado', 'E', 'Aceptado') as estado_inscripcion,
						to_char(sga_insc_examen.fecha_inscripcion, '%d/%m/%Y %H:%M') as fecha_inscripcion,
						sga_insc_examen.nro_transaccion,
						to_char(sga_prestamos.fecha, '%d/%m/%Y') as fecha_mesa_examen,
						to_char(sga_prestamos.hora_inicio, '%H:%M') as hora_inicio,
						sga_mesas_examen.catedra as catedra,
						sga_sedes.nombre as nombre_sede,
						(SELECT count(*) 
							FROM sga_insc_examen as ie
							WHERE ie.unidad_academica  = sga_insc_examen.unidad_academica
							  AND ie.materia           = sga_insc_examen.materia
							  AND ie.anio_academico    = sga_insc_examen.anio_academico
							  AND ie.turno_examen      = sga_insc_examen.turno_examen
							  AND ie.mesa_examen       = sga_insc_examen.mesa_examen
							  AND ie.llamado           = sga_insc_examen.llamado
							  AND ie.fecha_inscripcion <= sga_insc_examen.fecha_inscripcion
						) as orden_insc
				FROM
						sga_insc_examen,
						sga_atrib_mat_plan as atmp,
						sga_alumnos,
						sga_personas,
						sga_carreras,
						sga_mesas_examen,
						sga_llamados_mesa,
						sga_prestamos,
						sga_unidades_acad,
						sga_tipos_mesa,
						sga_materias,
						sga_sedes
				WHERE	sga_insc_examen.nro_transaccion = {$parametros['transaccion']}	
				AND		atmp.unidad_academica = sga_alumnos.unidad_academica
				AND		atmp.carrera          = sga_alumnos.carrera
				AND		atmp.plan             = sga_insc_examen.plan
				AND		atmp.version          = sga_insc_examen.version
				AND		atmp.materia          = sga_insc_examen.materia
				AND		sga_insc_examen.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_insc_examen.carrera          = sga_alumnos.carrera
				AND		sga_insc_examen.legajo           = sga_alumnos.legajo
				AND		sga_personas.unidad_academica    = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion     = sga_alumnos.nro_inscripcion
				AND		sga_carreras.unidad_academica    = sga_insc_examen.unidad_academica 
				AND		sga_carreras.carrera             = sga_insc_examen.carrera
				AND		sga_tipos_mesa.tipo_mesa           = sga_insc_examen.tipo_inscripcion
				AND		sga_unidades_acad.unidad_academica = sga_insc_examen.unidad_academica
				AND		sga_materias.unidad_academica     = sga_insc_examen.unidad_academica
				AND		sga_materias.materia              = sga_insc_examen.materia
				AND		sga_mesas_examen.unidad_academica = sga_insc_examen.unidad_academica
				AND		sga_mesas_examen.materia        = sga_insc_examen.materia
				AND		sga_mesas_examen.anio_academico = sga_insc_examen.anio_academico
				AND		sga_mesas_examen.turno_examen   = sga_insc_examen.turno_examen
				AND		sga_mesas_examen.mesa_examen    = sga_insc_examen.mesa_examen
				AND		sga_sedes.sede = sga_mesas_examen.sede
				AND		sga_llamados_mesa.unidad_academica = sga_insc_examen.unidad_academica
				AND		sga_llamados_mesa.materia          = sga_insc_examen.materia
				AND		sga_llamados_mesa.anio_academico   = sga_insc_examen.anio_academico
				AND		sga_llamados_mesa.turno_examen     = sga_insc_examen.turno_examen
				AND		sga_llamados_mesa.mesa_examen      = sga_insc_examen.mesa_examen
				AND		sga_llamados_mesa.llamado          = sga_insc_examen.llamado
				AND		sga_prestamos.prestamo             = sga_llamados_mesa.prestamo 
				";

		$datos = kernel::db()->consultar_fila($sql);
		if($datos) {
			foreach(array_keys($datos) as $campos) {
				$datos[$campos] = $datos[$campos];
			}
		}		
		return $datos;
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
						sga_insc_exa_bajas.unidad_academica,
						sga_insc_exa_bajas.carrera,
						sga_carreras.nombre as nombre_carrera,
						sga_personas.apellido || ' ' || sga_personas.nombres as nombre_alumno,
						sga_insc_exa_bajas.legajo,
						sga_insc_exa_bajas.tipo_inscripcion, 
						sga_tipos_mesa.descripcion as tipo_insc_desc,
						sga_insc_exa_bajas.materia,
						NVL(atmp.nombre_materia , sga_materias.nombre) as nombre_materia,
						NVL(atmp.nombre_reducido, sga_materias.nombre_reducido) as nombre_red_materia,
						sga_insc_exa_bajas.anio_academico,
						sga_insc_exa_bajas.turno_examen,
						sga_insc_exa_bajas.llamado,
						sga_insc_exa_bajas.mesa_examen,
						to_char(sga_insc_exa_bajas.fecha_inscripcion, '%d/%m/%Y %H:%M') as fecha_inscripcion,
						to_char(sga_insc_exa_bajas.fecha_baja, '%d/%m/%Y %H:%M') as fecha_baja,
						sga_insc_exa_bajas.nro_transac_baja as nro_trans_baja,
						to_char(sga_prestamos.fecha, '%d/%m/%Y') as fecha_mesa_examen,
						to_char(sga_prestamos.hora_inicio, '%H:%M') as hora_inicio,
						sga_mesas_examen.catedra as catedra,
						sga_sedes.nombre as nombre_sede

				FROM
						sga_insc_exa_bajas,
						sga_atrib_mat_plan as atmp,
						sga_alumnos,
						sga_personas,
						sga_carreras,
						sga_mesas_examen,
						sga_llamados_mesa,
						sga_prestamos,
						sga_unidades_acad,
						sga_tipos_mesa,
						sga_materias,
						sga_sedes,
						sga_planes
						
				WHERE	sga_insc_exa_bajas.nro_transac_baja = {$parametros['transaccion']}	
				AND		sga_insc_exa_bajas.unidad_academica = sga_alumnos.unidad_academica
				AND		sga_insc_exa_bajas.carrera          = sga_alumnos.carrera
				AND		sga_insc_exa_bajas.legajo           = sga_alumnos.legajo
				AND		sga_personas.unidad_academica       = sga_alumnos.unidad_academica
				AND		sga_personas.nro_inscripcion        = sga_alumnos.nro_inscripcion
				AND		sga_carreras.unidad_academica       = sga_alumnos.unidad_academica 
				AND		sga_carreras.carrera                = sga_alumnos.carrera
				AND		sga_tipos_mesa.tipo_mesa            = sga_insc_exa_bajas.tipo_inscripcion
				AND		sga_unidades_acad.unidad_academica  = sga_insc_exa_bajas.unidad_academica
				AND		sga_materias.unidad_academica       = sga_insc_exa_bajas.unidad_academica
				AND		sga_materias.materia                = sga_insc_exa_bajas.materia
				AND		sga_mesas_examen.unidad_academica   = sga_insc_exa_bajas.unidad_academica
				AND		sga_mesas_examen.materia            = sga_insc_exa_bajas.materia
				AND		sga_mesas_examen.anio_academico     = sga_insc_exa_bajas.anio_academico
				AND		sga_mesas_examen.turno_examen       = sga_insc_exa_bajas.turno_examen
				AND		sga_mesas_examen.mesa_examen        = sga_insc_exa_bajas.mesa_examen
				AND		sga_sedes.sede = sga_mesas_examen.sede
				AND		sga_llamados_mesa.unidad_academica  = sga_insc_exa_bajas.unidad_academica
				AND		sga_llamados_mesa.materia           = sga_insc_exa_bajas.materia
				AND		sga_llamados_mesa.anio_academico    = sga_insc_exa_bajas.anio_academico
				AND		sga_llamados_mesa.turno_examen      = sga_insc_exa_bajas.turno_examen
				AND		sga_llamados_mesa.mesa_examen       = sga_insc_exa_bajas.mesa_examen
				AND		sga_llamados_mesa.llamado           = sga_insc_exa_bajas.llamado
				AND		sga_prestamos.prestamo              = sga_llamados_mesa.prestamo
				AND 	sga_alumnos.unidad_academica		= sga_planes.unidad_academica
				AND 	sga_alumnos.carrera					= sga_planes.carrera
				AND 	sga_alumnos.plan					= sga_planes.plan
				AND		atmp.unidad_academica 				= sga_planes.unidad_academica
				AND		atmp.carrera          				= sga_planes.carrera
				AND		atmp.plan             				= sga_planes.plan
				AND		atmp.version          				= sga_planes.version_actual
				AND		atmp.materia          				= sga_insc_exa_bajas.materia
				";

		$datos = kernel::db()->consultar_fila($sql);
		if($datos) {
			foreach(array_keys($datos) as $campos) {
				$datos[$campos] = $datos[$campos];
			}
		}		
		return $datos;
	}
	
	/**
	 * parametros: _ua, materia, anio_academico, turno_examen, mesa_examen, carrera, plan, plan_version
	 * cache: no
	 * filas: 1
	 */
	function info_mesa($parametros) 
	{
		throw new siu\errores\error_guarani('ver esta consulta de mesa de examen - completar argumentos de busqueda');
		//@TODO Rehacer la consulta
		$sql = "SELECT *
				FROM sga_mesas_examen,
				     sga_atrib_mat_plan as atmp 
				WHERE sga_mesas_examen.unidad_academica = {$parametros['_ua']}
			    AND sga_mesas_examen.materia = {$parametros['materia']}
			    AND sga_mesas_examen.anio_academico = {$parametros['anio_academico']}
			    AND sga_mesas_examen.turno_examen = {$parametros['turno_examen']}
			    AND sga_mesas_examen.mesa_examen = {$parametros['mesa_examen']}
			    AND atmp.unidad_academica = sga_mesas_examen.unidad_academica
			    AND atmp.carrera          = {$parametros['carrera']}
			    AND atmp.plan             = {$parametros['plan']}
			    AND atmp.version          = {$parametros['plan_version']}
			    AND atmp.materia          = sga_mesas_examen.materia";
				
		return kernel::db()->consultar_fila($sql);
	}
	
	/**
	 * parametros: _ua, carrera, legajo, mesa
	 * cache: no
	 * filas: 1
	 */
	function info_inscripcion($parametros)  // TODO ver si alguien usa este método
	{
		$sql = "";
		//$datos = kernel::db()->consultar_fila($sql);
		$datos = array();
		return $datos;
	}	
	
	
	//------------------------------------------------------------------------
	// Modificacion de DATOS
	//------------------------------------------------------------------------
		
	/**
	 * parametros: _ua, carrera, plan, version, legajo, nro_inscripcion, materia, anio_academico, turno_examen, mesa_examen, llamado, tipo_inscripcion, estado_controles, _interfaz
	 * cache: no
	 * filas: 1
	 */
	
	function inscripcion_mesa_examen($parametros) 
	{
		$sql = "execute procedure sp_i_inscExamenes({$parametros['_ua']},". 
													"{$parametros['carrera']},".
													"{$parametros['legajo']},".
													"{$parametros['nro_inscripcion']},".
													"{$parametros['materia']},".
													"{$parametros['anio_academico']},".
													"{$parametros['turno_examen']},".
													"{$parametros['mesa_examen']},".
													"{$parametros['llamado']},".
													"{$parametros['tipo_inscripcion']},".
													"NULL,".
													"{$parametros['estado_controles']},".
													"{$parametros['_interfaz']},".
													"'N',".
													"{$parametros['plan']},".
													"{$parametros['version']})";
		return kernel::db()->consultar_fila($sql, db::FETCH_NUM);
	}	
	
	/**
	 * parametros: _ua, carrera, legajo, materia, anio_academico, turno_examen, mesa_examen, llamado, _interfaz
	 * cache: no
	 * filas: 1
	 */	
	function eliminar_inscripcion_mesa($parametros) 
	{
		$sql = "execute procedure sp_d_inscexam({$parametros['_ua']},".
												"{$parametros['carrera']},".
												"{$parametros['legajo']},".
												"{$parametros['materia']},".
												"{$parametros['anio_academico']},".
												"{$parametros['turno_examen']},".
												"{$parametros['mesa_examen']},".
												"{$parametros['llamado']},".
												"{$parametros['_interfaz']})";
												
		return kernel::db()->consultar_fila($sql, db::FETCH_NUM);
	}	
	
	
}
?>