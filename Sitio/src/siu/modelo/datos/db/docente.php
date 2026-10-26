<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;
use siu\operaciones\_comun\util\caracteres_especiales;

class docente
{
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function agenda_cursadas($parametros)
	{
		$sql = "execute procedure sp_AgendaDocCur(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['MATERIA'] = $dato[5];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[6];
			$nuevo[$id]['MATERIA_NOMBRE_COMPLETO'] = $dato[6]." (".$dato[5].")";
			$nuevo[$id]['DIA_SEMANA_DESC'] = $dato[10];
			$nuevo[$id]['HORA_COMIENZO_CLASE'] = $dato[11];
			$nuevo[$id]['HORA_FIN_CLASE'] = $dato[16];
			$nuevo[$id]['COMISION_NOMBRE'] = $dato[4];
			$nuevo[$id]['COMISION_CATEDRA'] = $dato[7];
			$nuevo[$id]['TURNO'] = $this->mensaje_turno($dato[8]);
			$nuevo[$id]['AULA_NOMBRE'] = $dato[13];
			$nuevo[$id]['VCEDIFICIODESC'] = $dato[15];
			$nuevo[$id]['TIPO_CLASE_DESC'] = $dato[18];
			$nuevo[$id]['SEDE_DISPLAY'] = $dato[21];

			$no_informa = kernel::traductor()->trans('no_informa');
			foreach ($nuevo[$id] as $clave => $valor){
				if (empty($valor)){
					$nuevo[$id][$clave] = $no_informa;
				}
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function agenda_examenes($parametros)
	{
		$sql = "execute procedure sp_AgendaDocExa(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['MATERIA_NOMBRE_COMPLETO'] = $dato[2]." (".$dato[1].")";
			$nuevo[$id]['MATERIA'] = $dato[1];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[2];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[3];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato[4];
			$nuevo[$id]['MESA_EXAMEN'] = $dato[5];
			$nuevo[$id]['LLAMADO'] = $dato[6];
			$nuevo[$id]['LEGAJO'] = $dato[7];
			$nuevo[$id]['DOCENTE_NOMBRE'] = $dato[8];
			$nuevo[$id]['DOCENTE_ROL'] = $dato[9];
			$nuevo[$id]['FECHA'] = $dato[11];
			$nuevo[$id]['HORA_INI'] = $dato[12];
			$nuevo[$id]['HORA_FIN'] = $dato[17];
			$nuevo[$id]['AULA'] = $dato[13];
			$nuevo[$id]['AULA_NOMBRE'] = $dato[14];
			$nuevo[$id]['EDIFICIO'] = $dato[15];
			$nuevo[$id]['EDIFICIO_NOMBRE'] = $dato[16];
			$nuevo[$id]['SEDE'] = $dato[18];
			$nuevo[$id]['SEDE_NOMBRE'] = $dato[19];
			$nuevo[$id]['SEDE_NOMBRE_COMPLETO'] = $dato[19];
			foreach($nuevo[$id] as $clave => $valor){
				if (empty($valor)){
					$nuevo[$id][$clave] = "No informa";
				}
			}
		}
		return $nuevo;
	}

/**
	 * parametros: _ua, nro_inscripcion, filtro_inscripciones
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function lista_comisiones_vigentes ($parametros)
	{
		// $sql = "execute procedure sp_ComisionesDoc(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		// $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
	
	    // Lista las comisiones vigentes que no finalizaron. Comisiones en las que esta asignado el docente.
		
		// filtro_inscripciones = T - Todas / S - Sin Inscripciones / C - Con inscripciones
		$param = substr ( $parametros['filtro_inscripciones'] , 1,1);
		$sql_filtro_insc = "";
		//if (!empty($parametros['filtro_inscripciones'])){
			//if ($parametros['filtro_inscripciones'] == 'S') {
			if ($param == 'S') {
				$sql_filtro_insc .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision) = 0";
			}
//			if ($parametros['filtro_inscripciones'] == 'C') {
			if ($param == 'C') {
				$sql_filtro_insc .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision) > 0";
			}
		//}

		
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
                      DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', '') as turno_desc,
                      sga_sedes.sede as sede,
                      sga_sedes.nombre as sede_nombre,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision AND estado = 'P') as insc_pendientes,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision AND estado IN ('A','E')) as insc_aceptadas
                 FROM sga_docentes,
                      sga_docentes_com,
                      sga_comisiones,
                      sga_periodos_lect,
                      sga_materias,
                      sga_sedes
                WHERE sga_docentes.unidad_academica = {$parametros["_ua"]}
                  AND sga_docentes.nro_inscripcion  = {$parametros["nro_inscripcion"]}
                  AND sga_docentes_com.legajo = sga_docentes.legajo
                  AND sga_comisiones.comision = sga_docentes_com.comision
                  AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                  AND sga_materias.materia          = sga_comisiones.materia
                  AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
                  AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
                  AND sga_periodos_lect.fecha_inactivacion >= TODAY
                  AND sga_periodos_lect.fecha_public_com <= TODAY
                  AND sga_comisiones.sede = sga_sedes.sede" . $sql_filtro_insc .
                " ORDER BY sga_comisiones.materia, sga_comisiones.nombre
              ";  
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$id = catalogo::generar_id($dato['COMISION']);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['COMISION'] = $dato['COMISION'];
			$nuevo[$id]['COMISION_NOMBRE'] = $dato['COMISION_NOMBRE'];
			$nuevo[$id]['SEDE'] = $dato['SEDE'];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato['PERIODO_LECTIVO'];
			$nuevo[$id]['CATEDRA'] = $dato['CATEDRA'];
			$nuevo[$id]['TURNO'] = $this->mensaje_turno($dato['TURNO']);
			$nuevo[$id]['INSCRIPCIONES_PENDIENTES'] = $dato['INSC_PENDIENTES'];
			$nuevo[$id]['INSCRIPCIONES_ACEPTADAS'] = $dato['INSC_ACEPTADAS'];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato['MATERIA_NOMBRE']." (".$dato['MATERIA'].")";
		}
		return $nuevo;		
	}


/**
	 * parametros: _ua, nro_inscripcion, filtro_inscripciones
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function lista_comisiones_subcomisiones_vigentes ($parametros)
	{
	
	    // Lista las comisiones y subcomisiones vigentes que no finalizaron en las que esta asignado el docente.
		
		// filtro_inscripciones = T - Todas / S - Sin Inscripciones / C - Con inscripciones
		$param = substr ( $parametros['filtro_inscripciones'] , 1,1);
		$sql_filtro_insc = "";
		$sql_filtro_insc_subcom = "";
		if ($param == 'S') {
			$sql_filtro_insc .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision) = 0";
			$sql_filtro_insc_subcom .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i, sga_insc_subcom as isc WHERE i.comision = sga_comisiones.comision AND isc.comision = i.comision AND isc.subcomision = sga_subcomisiones.subcomision AND i.unidad_academica = isc.unidad_academica AND i.carrera = isc.carrera AND i.legajo = isc.legajo) = 0";
		}
		if ($param == 'C') {
			$sql_filtro_insc .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision) > 0";
			$sql_filtro_insc_subcom .= " AND (SELECT COUNT(*) FROM sga_insc_cursadas as i, sga_insc_subcom as isc WHERE i.comision = sga_comisiones.comision AND isc.comision = i.comision AND isc.subcomision = sga_subcomisiones.subcomision AND i.unidad_academica = isc.unidad_academica AND i.carrera = isc.carrera AND i.legajo = isc.legajo) > 0";
		}

		$sql = "-- Comisiones sin subcomisiones
				SELECT
		              sga_comisiones.comision as comision,
                      sga_comisiones.nombre as comision_nombre,
                      sga_comisiones.materia as materia,
                      sga_materias.nombre as materia_nombre,
                      sga_materias.nombre_reducido as materia_nombre_red,
                      sga_comisiones.anio_academico  as anio_academico,
                      sga_comisiones.periodo_lectivo as periodo_lectivo,
                      sga_comisiones.catedra as catedra,
                      sga_comisiones.turno as turno,
                      DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', '') as turno_desc,
                      sga_sedes.sede as sede,
                      sga_sedes.nombre as sede_nombre,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision AND estado = 'P') as insc_pendientes,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i WHERE i.comision = sga_comisiones.comision AND estado IN ('A','E')) as insc_aceptadas,
                      cast(null as integer) as subcomision,
                      cast(null as varchar(15)) as subcomision_nombre,
                      cast(null as varchar(100)) as tipo_clase_desc,
                      0 as tiene_subcomision
                 FROM sga_docentes,
                      sga_docentes_com,
                      sga_comisiones,
                      sga_periodos_lect,
                      sga_materias,
                      sga_sedes
                WHERE sga_docentes.unidad_academica = {$parametros['_ua']}
                  AND sga_docentes.nro_inscripcion  = {$parametros['nro_inscripcion']}
                  AND sga_docentes_com.legajo = sga_docentes.legajo
                  AND sga_comisiones.comision = sga_docentes_com.comision
                  AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                  AND sga_materias.materia          = sga_comisiones.materia
                  AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
                  AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
                  AND sga_periodos_lect.fecha_inactivacion >= TODAY
                  AND sga_periodos_lect.fecha_public_com <= TODAY
                  AND sga_comisiones.sede = sga_sedes.sede
                  AND NOT EXISTS (SELECT 1 FROM sga_subcomisiones WHERE comision = sga_comisiones.comision)
                  $sql_filtro_insc 
                  
              UNION ALL
              	  -- Comisiones con subcomisiones	
                  SELECT
		              sga_comisiones.comision as comision,
                      sga_comisiones.nombre as comision_nombre,
                      sga_comisiones.materia as materia,
                      sga_materias.nombre as materia_nombre,
                      sga_materias.nombre_reducido as materia_nombre_red,
                      sga_comisiones.anio_academico  as anio_academico,
                      sga_comisiones.periodo_lectivo as periodo_lectivo,
                      sga_comisiones.catedra as catedra,
                      sga_comisiones.turno as turno,
                      DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', '') as turno_desc,
                      sga_sedes.sede as sede,
                      sga_sedes.nombre as sede_nombre,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i, sga_insc_subcom as isc 
                        WHERE i.comision = sga_comisiones.comision AND i.estado = 'P' AND isc.comision = i.comision AND isc.subcomision = sga_subcomisiones.subcomision
                          AND i.unidad_academica = isc.unidad_academica AND i.carrera = isc.carrera AND i.legajo = isc.legajo ) as insc_pendientes,
                      (SELECT COUNT(*) FROM sga_insc_cursadas as i, sga_insc_subcom as isc 
                          WHERE i.comision = sga_comisiones.comision AND i.estado IN ('A','E') AND isc.comision = i.comision AND isc.subcomision = sga_subcomisiones.subcomision 
                            AND i.unidad_academica = isc.unidad_academica AND i.carrera = isc.carrera AND i.legajo = isc.legajo) as insc_aceptadas,
                      sga_subcomisiones.subcomision as subcomision,
                      sga_subcomisiones.nombre as subcomision_nombre,
                      sga_tipo_clase.descripcion as tipo_clase_desc,
                      1 as tiene_subcomision
                 FROM sga_docentes,
                      sga_docentes_com,
                      sga_comisiones,
                      sga_subcomisiones,
                      sga_tipo_clase,
                      sga_periodos_lect,
                      sga_materias,
                      sga_sedes
                WHERE sga_docentes.unidad_academica = {$parametros['_ua']}
                  AND sga_docentes.nro_inscripcion  = {$parametros['nro_inscripcion']}
                  AND sga_docentes_com.legajo = sga_docentes.legajo
                  AND sga_comisiones.comision = sga_docentes_com.comision
                  AND sga_subcomisiones.comision = sga_comisiones.comision
                  AND EXISTS (SELECT 1 FROM sga_docentes_subco as dsc 
                               WHERE dsc.comision = sga_subcomisiones.comision
                                 AND dsc.subcomision = sga_subcomisiones.subcomision
                                 AND dsc.legajo = sga_docentes.legajo) 
                  AND sga_tipo_clase.tipo_clase = sga_subcomisiones.tipo_clase
                  AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                  AND sga_materias.materia          = sga_comisiones.materia
                  AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
                  AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
                  AND sga_periodos_lect.fecha_inactivacion >= TODAY
                  AND sga_periodos_lect.fecha_public_com <= TODAY
                  AND sga_comisiones.sede = sga_sedes.sede
                  $sql_filtro_insc_subcom
                 ORDER BY 3, 2
              ";  
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			// Formo el id con el de la comision concatenado al de la subcomision.
			$subco = '';
			if (! is_null($dato['SUBCOMISION'])) {
				$subco =  $dato['SUBCOMISION'];
			}
		
			$id = catalogo::generar_id($dato['COMISION'] . '-' . $subco);
			$nuevo[$id][catalogo::id]         = $id;
			$nuevo[$id]['COMISION']           = $dato['COMISION'];
			$nuevo[$id]['COMISION_NOMBRE']    = $dato['COMISION_NOMBRE'];
			$nuevo[$id]['SEDE']               = $dato['SEDE'];
			$nuevo[$id]['PERIODO_LECTIVO']    = $dato['PERIODO_LECTIVO'];
			$nuevo[$id]['CATEDRA']            = $dato['CATEDRA'];
			$nuevo[$id]['TURNO']              = $this->mensaje_turno($dato['TURNO']);
			$nuevo[$id]['INSCRIPCIONES_PENDIENTES'] = $dato['INSC_PENDIENTES'];
			$nuevo[$id]['INSCRIPCIONES_ACEPTADAS']  = $dato['INSC_ACEPTADAS'];
			$nuevo[$id]['INSCRIPCIONES_TOTALES']  = $dato['INSC_PENDIENTES'] + $dato['INSC_ACEPTADAS'];
			$nuevo[$id]['MATERIA_NOMBRE']     = $dato['MATERIA_NOMBRE']." (".$dato['MATERIA'].")";
			$nuevo[$id]['SUBCOMISION']        = $dato['SUBCOMISION'];
			$nuevo[$id]['SUBCOMISION_NOMBRE'] = $dato['SUBCOMISION_NOMBRE'];
			$nuevo[$id]['TIPO_CLASE_DESC']    = $dato['TIPO_CLASE_DESC'];
			$nuevo[$id]['TIENE_SUBCOMISION']  = $dato['TIENE_SUBCOMISION'];
		}
		return $nuevo;		
	}


	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function lista_comisiones($parametros)
	{
		$sql = "execute procedure sp_ComisionesDoc(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$id = catalogo::generar_id($dato[2]);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['COMISION'] = $dato[2];
			$nuevo[$id]['COMISION_NOMBRE'] = $dato[3];
			$nuevo[$id]['SEDE'] = $dato[12];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato[6];
			$nuevo[$id]['CATEDRA'] = $dato[7];
			$nuevo[$id]['TURNO'] = $this->mensaje_turno($dato[8]);
			$nuevo[$id]['CANTIDAD_INSCR'] = $dato[9];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[5]." (".$dato[4].")";
		}
		return $nuevo;
	}

	 /**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function alum_inscriptos_comision($parametros)
	{
		$sql = "execute procedure sp_AluInscCom(" . $parametros["comision"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['LEGAJO'] = $dato[12];
			$nuevo[$id]['ALUMNO'] = $dato[13];
			$nuevo[$id]['CALIDAD'] = $dato[8];
			$nuevo[$id]['ESTADO'] = substr($dato[9],0,1)=='P'?'Pendiente':'Aceptado';
			$nuevo[$id]['CARRERA_COD'] = $dato[10];
			$nuevo[$id]['CARRERA'] = $dato[15];
			$nuevo[$id]['MATERIA_COD'] = $dato[1];
			$nuevo[$id]['MATERIA'] = $dato[2];
			$nuevo[$id]['SEDE_COD'] = $dato[16];
			$nuevo[$id]['SEDE'] = $dato[17];
			$nuevo[$id]['COMISION'] = $dato[6];
			$nuevo[$id]['CATEDRA'] = $dato[7];
			$nuevo[$id]['ANIO'] = $dato[3];
			$nuevo[$id]['PER_LEC'] = $dato[4];
			$nuevo[$id]['SUBCOMISION'] = '';
			$nuevo[$id]['SUBCOMISION_NOMBRE'] = '';
		}
		return $nuevo;
	}
	
	 /**
	 * parametros: comision, subcomision
	 * cache: no
	 * filas: n
	 */
	function alum_inscriptos_subcomision($parametros)
	{
		$sql = "execute procedure sp_AluInscSubCom(" . $parametros["comision"].','.$parametros["subcomision"].")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['LEGAJO'] = $dato[12];
			$nuevo[$id]['ALUMNO'] = $dato[13];
			$nuevo[$id]['CALIDAD'] = $dato[8];
			$nuevo[$id]['ESTADO'] = substr($dato[9],0,1)=='P'?'Pendiente':'Aceptado';
			$nuevo[$id]['CARRERA_COD'] = $dato[10];
			$nuevo[$id]['CARRERA'] = $dato[11];
			$nuevo[$id]['MATERIA_COD'] = $dato[1];
			$nuevo[$id]['MATERIA'] = $dato[2];
			$nuevo[$id]['SEDE_COD'] =''; //$dato[16];
			$nuevo[$id]['SEDE'] = '';//$dato[17];
			$nuevo[$id]['COMISION'] = $dato[6];
			$nuevo[$id]['CATEDRA'] = $dato[7];
			$nuevo[$id]['ANIO'] = $dato[3];
			$nuevo[$id]['PER_LEC'] = $dato[4];
			$nuevo[$id]['SUBCOMISION'] = $dato[15];
			$nuevo[$id]['SUBCOMISION_NOMBRE'] =  $dato[16];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, filtro_inscripciones
	 * cache: no
	 * filas: n
	*/
	function lista_mesas_vigentes($parametros)
	{
		/*		
		$sql = "execute procedure sp_mesasdoc(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);*/
		
		// filtro_inscripciones = T - Todas / S - Sin Inscripciones / C - Con inscripciones
		$sql_filtro_insc = "";
//		if (!empty($parametros['filtro_inscripciones'])){
			$param = substr ( $parametros['filtro_inscripciones'] , 1,1);

//			if ($parametros['filtro_inscripciones'] == 'C') {
			if ($param == 'C') {
			//if (strcmp($parametros['filtro_inscripciones'], 'C')  == 0) {
				$sql_filtro_insc = " AND ((SELECT COUNT(*) FROM sga_insc_examen as i WHERE 
						i.unidad_academica		= sga_llamados_mesa.unidad_academica
						AND i.materia			= sga_llamados_mesa.materia
						AND i.anio_academico	= sga_llamados_mesa.anio_academico
						AND i.turno_examen		= sga_llamados_mesa.turno_examen
						AND i.mesa_examen		= sga_llamados_mesa.mesa_examen
						AND i.llamado			= sga_llamados_mesa.llamado) > 0) ";
			};
			
//			if ($parametros['filtro_inscripciones'] == 'S') {
			if ($param == 'S') {
				$sql_filtro_insc = " AND ((SELECT COUNT(*) FROM sga_insc_examen as i WHERE 
						i.unidad_academica		= sga_llamados_mesa.unidad_academica
						AND i.materia			= sga_llamados_mesa.materia
						AND i.anio_academico	= sga_llamados_mesa.anio_academico
						AND i.turno_examen		= sga_llamados_mesa.turno_examen
						AND i.mesa_examen		= sga_llamados_mesa.mesa_examen
						AND i.llamado			= sga_llamados_mesa.llamado) = 0) ";
			};
			
//		}

         // Lista de mesas de examen de fechas de hoy o futuras	
         // Mesas de examen donde se encuentra el docente.
         $sql = "SELECT
                    sga_docentes_llama.materia as materia,
                    sga_materias.nombre as materia_nombre,
                    sga_materias.nombre_reducido as materia_nombre_red,
                    sga_docentes_llama.anio_academico as anio_academico,
                    sga_docentes_llama.turno_examen as turno_examen,
                    sga_docentes_llama.mesa_examen as mesa_examen,
                    sga_docentes_llama.llamado as llamado,
                    nvl(TO_CHAR(sga_prestamos.fecha , "."'%d/%m/%Y'"."),' ') ||' ' ||nvl( TO_CHAR(sga_prestamos.hora_inicio, "."'%H:%M'".") , ' ') as momento,
                    sga_sedes.sede as sede,
                    sga_sedes.nombre as sede_nombre,
                    sga_prestamos.fecha as fecha,
                    sga_prestamos.hora_inicio as hora_inicio,
                    (SELECT COUNT(*) FROM sga_insc_examen as i WHERE 
						i.unidad_academica		= sga_llamados_mesa.unidad_academica
						AND i.materia			= sga_llamados_mesa.materia
						AND i.anio_academico	= sga_llamados_mesa.anio_academico
						AND i.turno_examen		= sga_llamados_mesa.turno_examen
						AND i.mesa_examen		= sga_llamados_mesa.mesa_examen
						AND i.llamado			= sga_llamados_mesa.llamado) as cantidad_inscr
         
               FROM sga_docentes,
                    sga_docentes_llama,
                    sga_llamados_mesa,
                    sga_turnos_examen,
                    sga_materias,
                    sga_prestamos,
                    sga_mesas_examen,
                    sga_sedes
         
                WHERE sga_docentes.unidad_academica = {$parametros["_ua"]}
                  AND sga_docentes.nro_inscripcion  = {$parametros["nro_inscripcion"]}
                  AND sga_docentes_llama.legajo  = sga_docentes.legajo
                  AND sga_llamados_mesa.unidad_academica = sga_docentes_llama.unidad_academica
                  AND sga_llamados_mesa.materia          = sga_docentes_llama.materia
                  AND sga_llamados_mesa.anio_academico   = sga_docentes_llama.anio_academico
                  AND sga_llamados_mesa.turno_examen     = sga_docentes_llama.turno_examen
                  AND sga_llamados_mesa.mesa_examen      = sga_docentes_llama.mesa_examen
                  AND sga_llamados_mesa.llamado          = sga_docentes_llama.llamado
                  AND sga_llamados_mesa.habilitado       = 'S'
           
                  AND sga_turnos_examen.anio_academico   = sga_llamados_mesa.anio_academico
                  AND sga_turnos_examen.turno_examen     = sga_llamados_mesa.turno_examen
                  AND sga_turnos_examen.fecha_public_mesas <= TODAY
                  
                  AND sga_materias.unidad_academica      = sga_llamados_mesa.unidad_academica
                  AND sga_materias.materia               = sga_llamados_mesa.materia
           
                  AND sga_prestamos.prestamo             = sga_llamados_mesa.prestamo
                  AND sga_prestamos.fecha                >= TODAY
           
                  AND sga_llamados_mesa.unidad_academica = sga_mesas_examen.unidad_academica
                  AND sga_llamados_mesa.materia          = sga_mesas_examen.materia
                  AND sga_llamados_mesa.anio_academico   = sga_mesas_examen.anio_academico
                  AND sga_llamados_mesa.turno_examen     = sga_mesas_examen.turno_examen
                  AND sga_llamados_mesa.mesa_examen      = sga_mesas_examen.mesa_examen
                  AND sga_mesas_examen.sede = sga_sedes.sede".$sql_filtro_insc.
                " ORDER BY sga_materias.nombre, 
                         sga_prestamos.fecha, 
                         sga_prestamos.hora_inicio, 
                         sga_docentes_llama.anio_academico, 
                         sga_docentes_llama.llamado
                ";         
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

		$nuevo = array();
		foreach($datos as $dato) {
			$id = catalogo::generar_id($dato['MATERIA'].$dato['ANIO_ACADEMICO'].$dato['TURNO_EXAMEN'].$dato['MESA_EXAMEN'].$dato['LLAMADO']);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['MATERIA'] = $dato['MATERIA'];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato['MATERIA_NOMBRE'];
			$nuevo[$id]['MATERIA_NOMBRE_COMPLETO'] = $dato['MATERIA_NOMBRE']." (".$dato['MATERIA'].")";
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato['ANIO_ACADEMICO'];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato['TURNO_EXAMEN'];
			$nuevo[$id]['MESA_EXAMEN'] = $dato['MESA_EXAMEN'];
			$nuevo[$id]['LLAMADO'] = $dato['LLAMADO'];
			$nuevo[$id]['MOMENTO'] = $dato['MOMENTO'];
			$nuevo[$id]['SEDE'] = $dato['SEDE'];
			$nuevo[$id]['CANTIDAD_INSCR'] = $dato['CANTIDAD_INSCR'];
		}
		return $nuevo;
	
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	*/
	function lista_mesas($parametros)
	{
		$sql = "execute procedure sp_mesasdoc(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$id = catalogo::generar_id($dato[1].$dato[3].$dato[4].$dato[5].$dato[6]);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['MATERIA'] = $dato[1];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[2];
			$nuevo[$id]['MATERIA_NOMBRE_COMPLETO'] = $dato[2]." (".$dato[1].")";
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[3];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato[4];
			$nuevo[$id]['MESA_EXAMEN'] = $dato[5];
			$nuevo[$id]['LLAMADO'] = $dato[6];
			$nuevo[$id]['MOMENTO'] = $dato[7];
			$nuevo[$id]['SEDE'] = $dato[9];
			$nuevo[$id]['CANTIDAD_INSCR'] = $dato[11];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, materia, anio_academico, turno_examen, mesa_examen, llamado
	 * cache: no
	 * filas: n
	 */
	function alum_inscriptos_examen($parametros)
	{
		$sql = "execute procedure sp_AluInscExa({$parametros["_ua"]},
												{$parametros["materia"]},
												{$parametros["anio_academico"]},
												{$parametros["turno_examen"]},
												{$parametros["mesa_examen"]},
												{$parametros["llamado"]})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['MATERIA'] = $dato[1];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[2];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[3];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato[4];
			$nuevo[$id]['MESA_EXAMEN'] = $dato[5];
			$nuevo[$id]['LLAMADO'] = $dato[6];
			$nuevo[$id]['MOMENTO'] = $dato[7];
			$nuevo[$id]['EDIFICIO'] = $dato[8];
			$nuevo[$id]['EDIFICIO_NOMBRE'] = $dato[9];
			$nuevo[$id]['AULA'] = $dato[10];
			$nuevo[$id]['AULA_NOMBRE'] = $dato[11];
			$nuevo[$id]['CARRERA'] = $dato[12];
			$nuevo[$id]['CARRERA_NOMBRE'] = $dato[13];
			$nuevo[$id]['LEGAJO'] = $dato[14];
			$nuevo[$id]['APELLIDO_NOMBRE'] = $dato[15];
			$nuevo[$id]['TIPO_INSCRIPCION'] = $dato[16];
			$nuevo[$id]['ESTADO'] = substr($dato[17],0,1)=='P'?'Pendiente':'Aceptado';
			$nuevo[$id]['FECHA_INSCRIPCION'] = $dato[22];
			$nuevo[$id]['FECHA_INSCRIPCION_ORD'] = $dato[21];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, anio_academico, periodo_lectivo, nombre
	 * param_null: anio_academico, periodo_lectivo, nombre
	 * cache: no
	 * filas: n
	 */
	function acta_cursadas($parametros)
	{
		$sql = "execute procedure sp_busq_actareg(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .",";
		if (empty($parametros["anio_academico"]) or $parametros["anio_academico"] == "''") $sql .= "NULL"; else $sql .= $parametros["anio_academico"];        
		if (empty($parametros["periodo_lectivo"]) or $parametros["periodo_lectivo"] == "''") $sql .= ",NULL"; else $sql .= ", ".$parametros["periodo_lectivo"];
		if (empty($parametros["nombre"]) or $parametros["nombre"] == "''") $sql .= ", NULL)"; else $sql .= ", ".$parametros["nombre"].");";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['URL_ACTA'] = catalogo::generar_id($dato[3]);
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[1];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato[2];
			$nuevo[$id]['ACTA'] = $dato[3];
			$nuevo[$id]['MATERIA'] = $dato[4];
			$nuevo[$id]['NOMBRE_MATERIA'] = $dato[5];			
			$nuevo[$id]['FECHA_CIERRE'] = $dato[6];            
			$nuevo[$id]['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($dato[7]);
			$nuevo[$id]['SEDE'] = $dato[8];
			$nuevo[$id]['NOMBRE_SEDE'] = $dato[9];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, acta
	 * cache: no
	 * filas: n
	 */
	function detalle_acta_cursada($parametros)
	{
		// *********** Datos de la cabecera del Acta ******************
		$sql_cab = "EXECUTE PROCEDURE sp_cab_actacursado(".$parametros['_ua'].",". $parametros['acta'].")"; 
		$datos_cab = kernel::db()->consultar($sql_cab, db::FETCH_NUM);

		// ******************* Alumnos del Acta *******************************
		$sql = "execute procedure sp_detalle_acta_cu(" . $parametros["_ua"] . ", " . $parametros["acta"] .")";        
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		
		// ENCABEZADO
		if (!empty($datos_cab)){
			$datos_cab = $datos_cab[0];
			
			// Docentes de la comision
			$sql_doc = "EXECUTE PROCEDURE sp_docentes_com(".$datos_cab[4].")"; 
			$datos_doc = kernel::db()->consultar($sql_doc, db::FETCH_NUM);
			
			// El valor de retorno $datos_cab[13] corresponde al estado del Acta de Promocion!!!
			// Estado del Acta de Regulares:
			$nuevo['ENCABEZADO']['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($datos_cab[20]);
			$nuevo['ENCABEZADO']['MATERIA'] = $datos_cab[7].' (' . $datos_cab[6] . ')';
			$nuevo['ENCABEZADO']['ACTA'] = $datos_cab[1];
			$nuevo['ENCABEZADO']['ANIO_ACAD'] = $datos_cab[8];
			$nuevo['ENCABEZADO']['FOLIOS'] = $datos_cab[17];
			$nuevo['ENCABEZADO']['PER_LEC'] = $datos_cab[9];
			$nuevo['ENCABEZADO']['COMISION'] = $datos_cab[4];
			$nuevo['ENCABEZADO']['COMISION_NOMBRE'] = $datos_cab[5];
			$nuevo['ENCABEZADO']['LIBRO'] = $datos_cab[19];
			$nuevo['ENCABEZADO']['DOCENTES'] = "-";
			if (!empty($datos_doc)){
				$nuevo['ENCABEZADO']['DOCENTES'] = $datos_doc[0][0];
			}

			$nuevo['ENCABEZADO']['OBS'] = "-";
			if (!empty($datos_cab) && !empty($datos_cab[18])){
				$nuevo['ENCABEZADO']['OBS'] = $datos_cab[18];
			}
		}

		if (!empty($datos)){
			$folio = false;
			foreach($datos as $id => $dato) {
				if ($folio <> $dato[23]){
					$folio = $dato[23];
				}

				$nuevo['CUERPO'][$folio][$id]['CARRERA'] = $dato[21];
				$nuevo['CUERPO'][$folio][$id]['RENGLON'] = $dato[24];
				$nuevo['CUERPO'][$folio][$id]['LEGAJO'] = $dato[22];
				$nuevo['CUERPO'][$folio][$id]['APE_NOM'] = $dato[33].", ".$dato[34];
				$nuevo['CUERPO'][$folio][$id]['FECHA'] = datos_comunes_actas::get_fecha($dato[26]);
				$nuevo['CUERPO'][$folio][$id]['NOTA_NUM'] = $dato[28];
				$nuevo['CUERPO'][$folio][$id]['CONDICION'] = $dato[25];
				$nuevo['CUERPO'][$folio][$id]['RESULTADO'] = datos_comunes_actas::get_resultado($dato[27]);

				if ($dato[36] != "") {
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '(' . $dato[36] . ')';
				} else {
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '&nbsp;';
				}
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, anio_academico, turno, nombre
	 * param_null: anio_academico, turno, nombre
	 * cache: no
	 * filas: n
	 */
	function acta_examenes($parametros)
	{
		$sql = "execute procedure sp_busq_actaexa(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .",";
		if (empty($parametros["anio_academico"]) or $parametros["anio_academico"] == "''") $sql .= "NULL"; else $sql .= $parametros["anio_academico"]."";
		if (empty($parametros["turno"]) or $parametros["turno"] == "''") $sql .= ", NULL"; else $sql .= ", ".$parametros["turno"]."";
		if (empty($parametros["nombre"]) or $parametros["nombre"] == "''") $sql .= ", NULL)"; else $sql .= ", ".$parametros["nombre"].");";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		$i = 0;
		foreach($datos as $id => $dato) {
			if ($dato[9] != "B"){
				$nuevo[$i]['ANIO_ACADEMICO'] = $dato[5];
				$nuevo[$i]['ID_ANIO_ACADEMICO'] = catalogo::generar_id($dato[5]);
				$nuevo[$i]['TURNO_EXAMEN'] = $dato[6];
				$nuevo[$i]['ID_TURNO_EXAMEN'] = catalogo::generar_id($dato[6]);
				$nuevo[$i]['SEDE'] = $dato[12];
				$nuevo[$i]['ACTA'] = $dato[1];
				$nuevo[$i]['URL_ACTA'] = catalogo::generar_id($dato[1]);
				$nuevo[$i]['TIPO_ACTA'] = datos_comunes_actas::get_tipo_acta($dato[2]);
				$nuevo[$i]['MATERIA'] = $dato[4]." (".$dato[3].")";
				$nuevo[$i]['ESTADO'] = datos_comunes_actas::get_estado_acta($dato[9]);
				$nuevo[$i]['ROL_DOCENTE'] = datos_comunes_actas::get_rol_docente($dato[10]);
				$nuevo[$i]['FECHA'] = $dato[14];
				$nuevo[$i]['MESA'] = $dato[15];

				if (!empty($dato[8])){
					$nuevo[$i]['FECHA_CIERRE'] = date("d/m/Y", strtotime($dato[8]));
				} else {
					$nuevo[$i]['FECHA_CIERRE'] = "-";
				}
				$i++;
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, tipo_acta, acta
	 * cache: no
	 * filas: n
	 */
	function detalle_acta_examen($parametros)
	{
		// *********** Cabecera del Acta de examen *********************
		$sql_cab = "EXECUTE PROCEDURE sp_cab_acta_examen(" . $parametros["_ua"] . ", ".$parametros["tipo_acta"].", " . $parametros["acta"] .")";
		$datos_cab = kernel::db()->consultar($sql_cab, db::FETCH_NUM);
		
		
		// *********** Alumnos del Acta de Examen **********************
		$sql = "execute procedure sp_detalle_acta_ex(" . $parametros["_ua"] . ", ".$parametros["tipo_acta"].", " . $parametros["acta"] .")";        
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		// ENCABEZADO
		if (!empty($datos_cab)){
			$datos_cab = $datos_cab[0];
			
			// *********** Docentes ****************************************
			$sql_doc = "EXECUTE PROCEDURE sp_doc_una_mesa(".$parametros["_ua"].",'".$datos_cab[3]."','".$datos_cab[5]."','".$datos_cab[6]."','".$datos_cab[7]."','".$datos_cab[8]."')";
			$docentes = kernel::db()->consultar($sql_doc, db::FETCH_NUM);
			
			$nuevo['ENCABEZADO']['MATERIA'] = $datos_cab[4].' (' . $datos_cab[3] . ')';
			$nuevo['ENCABEZADO']['ACTA'] = $datos_cab[2];
			$nuevo['ENCABEZADO']['ANIO_ACAD'] = $datos_cab[5];
			$nuevo['ENCABEZADO']['FOLIO'] = $datos_cab[16];
			$nuevo['ENCABEZADO']['FECHA'] = $datos_cab[10];
			$nuevo['ENCABEZADO']['TURNO'] = $datos_cab[6];
			$nuevo['ENCABEZADO']['MESA'] = $datos_cab[7];
			$nuevo['ENCABEZADO']['LIBRO'] = $datos_cab[19];
			$nuevo['ENCABEZADO']['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($datos_cab[20]);
			
			$nuevo['ENCABEZADO']['DOCENTES'] = "";
			if (!empty($docentes)){
				$nuevo['ENCABEZADO']['DOCENTES'] = $docentes[0][0];
			}

			$nuevo['ENCABEZADO']['OBS'] = "-";
			if (!empty($datos_cab[15])){
				$nuevo['ENCABEZADO']['OBS'] = $datos_cab[15];
			}
		}
		
		if (!empty($datos)){
			$folio = false;
			foreach($datos as $id => $dato) {
				if ($folio <> $dato[5]){
					$folio = $dato[5];
				}

				$nuevo['CUERPO'][$folio][$id]['RENGLON'] = $dato[6];
				$nuevo['CUERPO'][$folio][$id]['LEGAJO'] = $dato[3];
				$nuevo['CUERPO'][$folio][$id]['APE_NOM'] = $dato[16].", ".$dato[17];
				$nuevo['CUERPO'][$folio][$id]['CONDICION'] = datos_comunes_actas::get_condicion($dato[7]);
				$nuevo['CUERPO'][$folio][$id]['NOTA_NUM'] = $dato[10];

				if (!empty($dato[8])){
					$nuevo['CUERPO'][$folio][$id]['FECHA'] = date("d/m/Y", strtotime($dato[8]));
				} else {
					$nuevo['CUERPO'][$folio][$id]['FECHA'] = $dato[8];
				}

				if ($dato[14] != "") 
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '(' . $dato[14] . ')';
				else 
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '&nbsp;';

				$nuevo['CUERPO'][$folio][$id]['RESULTADO'] = datos_comunes_actas::get_resultado($dato[9]);
				$nuevo['CUERPO'][$folio][$id]['CONCEPTO'] = $dato[15];
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion, anio_academico, periodo_lectivo, nombre
	 * param_null: anio_academico, periodo_lectivo, nombre
	 * cache: no
	 * filas: n
	 */
	function acta_promociones($parametros)
	{
		$sql = "execute procedure sp_busq_actapromo(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .",";

		if ($parametros["anio_academico"] =="''") $sql .= "NULL"; else $sql .= $parametros["anio_academico"]."";
		if ($parametros["periodo_lectivo"] =="''") $sql .= ", NULL"; else $sql .= ", ".$parametros["periodo_lectivo"];
		if ($parametros["nombre"] =="''") $sql .= ", NULL)"; else $sql .= ", ".$parametros["nombre"].");";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();

		foreach($datos as $id => $dato) {
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[1];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato[2];
			$nuevo[$id]['ACTA'] = $dato[3];
			$nuevo[$id]['MATERIA'] = $dato[4];
			$nuevo[$id]['NOMBRE_MATERIA'] = $dato[5];
			$nuevo[$id]['FECHA_CIERRE'] = $dato[6];            
			$nuevo[$id]['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($dato[7]);
			$nuevo[$id]['SEDE'] = $dato[8];
			$nuevo[$id]['NOMBRE_SEDE'] = $dato[9];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, acta
	 * cache: no
	 * filas: n
	 */
	function detalle_acta_promociones($parametros)
	{
	// *************** Cabecera del Acta de Promocion ****************************
	// No existe procedure para la cabecera del acta de promocion.
	$sql_cab = "SELECT 
					sga_comisiones.comision as comision,
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.materia as materia,
					NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre) as materia_nombre, 
					sga_comisiones.anio_academico as anio_academico,
					sga_comisiones.periodo_lectivo as periodo_lectivo,
					sga_comisiones.escala_notas as escala_notas,
					sga_actas_promo.libro as libro,
					sga_libros_de_acta.nombre as libro_nombre,
					sga_actas_promo.observaciones as observaciones,
					DECODE (sga_actas_promo.estado, 'A', 'Abierta', 'C', 'Cerrada', 'B', 'Anulada','') as estado,
					sga_sedes.nombre as sede_nombre,
					sga_actas_promo.estado, 
					CASE sga_actas_promo.estado
						WHEN 'A' THEN (SELECT MAX(folio_promocion) FROM sga_curs_pendiente WHERE unidad_academica = sga_actas_promo.unidad_academica AND acta_promocion = sga_actas_promo.acta)
						WHEN 'C' THEN (SELECT MAX(folio) FROM sga_det_acta_promo WHERE unidad_academica = sga_actas_promo.unidad_academica AND acta = sga_actas_promo.acta)
						WHEN 'B' THEN (SELECT MAX(folio) FROM sga_det_acta_promo WHERE unidad_academica = sga_actas_promo.unidad_academica AND acta = sga_actas_promo.acta)
						ELSE 1
					END as cant_folios
				FROM	sga_actas_promo,
						sga_comisiones,
						sga_materias,
						sga_sedes, 
						OUTER(sga_planes, sga_atrib_mat_plan),
						OUTER sga_libros_de_acta
				WHERE sga_actas_promo.unidad_academica = {$parametros['_ua']}
				AND sga_actas_promo.acta = {$parametros['acta']}
				AND sga_comisiones.comision = sga_actas_promo.comision
				AND sga_materias.unidad_academica  = sga_comisiones.unidad_academica
				AND sga_materias.materia           = sga_comisiones.materia
				AND sga_planes.unidad_academica = sga_comisiones.unidad_academica
				AND sga_planes.carrera          = sga_comisiones.carrera
				AND sga_planes.plan             = sga_comisiones.plan
				AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
				AND sga_atrib_mat_plan.carrera          = sga_planes.carrera
				AND sga_atrib_mat_plan.plan             = sga_planes.plan
				AND sga_atrib_mat_plan.version          = sga_planes.version_actual
				AND sga_atrib_mat_plan.materia          = sga_comisiones.materia
				AND sga_comisiones.sede = sga_sedes.sede
				AND sga_libros_de_acta.libro = sga_actas_promo.libro
				";
		$datos_cab = kernel::db()->consultar($sql_cab, db::FETCH_ASSOC);

		// *************** Alumnos del acta de Promocion ****************************
		$sql = "execute procedure sp_detalle_acta_pr({$parametros["_ua"]},{$parametros["acta"]})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		if(!empty($datos_cab)){
			$datos_cab = $datos_cab[0];
			// Docentes de la comision
			$sql_doc = "execute procedure sp_docentes_com({$datos_cab['COMISION']})";
			$datos_doc = kernel::db()->consultar($sql_doc, db::FETCH_NUM);
			
			$nuevo['ENCABEZADO']['MATERIA']   = $datos_cab['MATERIA_NOMBRE'].' (' . $datos_cab['MATERIA'] . ')';                    
			$nuevo['ENCABEZADO']['ACTA']      = str_replace("'", "", $parametros["acta"]);
			$nuevo['ENCABEZADO']['ANIO_ACAD'] = $datos_cab['ANIO_ACADEMICO'];
			$nuevo['ENCABEZADO']['PER_LEC']   = $datos_cab['PERIODO_LECTIVO'];
			$nuevo['ENCABEZADO']['COMISION']  = $datos_cab['COMISION'];
			$nuevo['ENCABEZADO']['COMISION_NOMBRE']  = $datos_cab['COMISION_NOMBRE'];
			$nuevo['ENCABEZADO']['LIBRO']     = $datos_cab['LIBRO_NOMBRE'];
			$nuevo['ENCABEZADO']['OBS']       = $datos_cab['OBSERVACIONES'];
			$nuevo['ENCABEZADO']['FOLIOS']    = $datos_cab['CANT_FOLIOS'];
			$nuevo['ENCABEZADO']['ESTADO_ACTA']    = datos_comunes_actas::get_estado_acta($datos_cab['ESTADO']);
			$nuevo['ENCABEZADO']['DOCENTES']  = "-";
			if (!empty($datos_doc)){
				$nuevo['ENCABEZADO']['DOCENTES'] = $datos_doc[0][0];
			}
		}
		
		// Alumnos del acta de promocion
		if (!empty($datos)){
			$folio = false;
			foreach($datos as $id => $dato) {
				if ($folio <> $dato[20]){
					$folio = $dato[20];
				}

				$nuevo['CUERPO'][$folio][$id]['CARRERA'] = $dato[18];
				$nuevo['CUERPO'][$folio][$id]['LEGAJO'] = $dato[19];
				$nuevo['CUERPO'][$folio][$id]['FOLIO'] = $dato[20];
				$nuevo['CUERPO'][$folio][$id]['RENGLON'] = $dato[21];
				$nuevo['CUERPO'][$folio][$id]['APE_NOM'] = $dato[30].", ".$dato[31];
				$nuevo['CUERPO'][$folio][$id]['FECHA'] = datos_comunes_actas::get_fecha($dato[23]);
				$nuevo['CUERPO'][$folio][$id]['NOTA_NUM'] = $dato[25];
				$nuevo['CUERPO'][$folio][$id]['CONDICION'] = $dato[25];
				$nuevo['CUERPO'][$folio][$id]['RESULTADO'] = datos_comunes_actas::get_resultado($dato[24]);

				if ($dato[33] != "")
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '(' . $dato[33] . ')';
				else 
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '&nbsp;';
			}
		}
		return $nuevo;
	}

	/**
	* Lista de materias de comisiones/mesas de examen donde estuvo asignado el docente (en term viene el dato ingresando en el combo)
	* parametros: _ua, term, legajo
    * no_quote: term
	* cache: memoria
	* filas: n
	*/
	function lista_materias($parametros)
	{
        $filtro_termino = "";

        if ($parametros['term'] != ""){

            $termino = strtolower($parametros['term']);
            $term = kernel::db()->quote_like($termino, '%', '%');
            $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');

            $filtro_termino = " AND (
                        LOWER(materia) LIKE $term OR
                        LOWER(nombre) LIKE $term OR
                        LOWER(materia) LIKE $term_sin_car_esp OR
                        LOWER(nombre) LIKE $term_sin_car_esp
                        )";
        }


        // Recupera las materias de las comisiones y mesas donde estuvo alguna vez asignado el docente.
        $sql = "SELECT unidad_academica, materia, nombre
                FROM sga_materias
                WHERE unidad_academica = {$parametros['_ua']}
                AND estado <> 'B'
                AND (materia IN (SELECT c.materia FROM sga_docentes_com as cd, sga_comisiones as c
                                 WHERE cd.legajo = {$parametros['legajo']}
                                   AND c.comision = cd.comision
                                   ) OR
                     materia IN (SELECT me.materia FROM sga_docentes_llama as dll, sga_mesas_examen as me
                                 WHERE dll.legajo = {$parametros['legajo']}
                                   AND me.unidad_academica = dll.unidad_academica
                                   AND me.materia          = dll.materia
                                   AND me.anio_academico   = dll.anio_academico
                                   AND me.turno_examen     = dll.turno_examen
                                   AND me.mesa_examen      = dll.mesa_examen)
                    )  
                $filtro_termino
                ";

		$datos = kernel::db()->consultar($sql);

		$res = array();
		foreach ($datos as $dato){
			$paquete = array();
			$paquete['id'] = catalogo::generar_id($dato['MATERIA']);
			$paquete['materia'] = $dato['MATERIA'];
			$paquete['label'] = "({$dato['MATERIA']}) {$dato['NOMBRE']}";
			$res[] = $paquete;
		}
		return $res;
	}
	
	
	private function mensaje_turno($id)
	{
		switch ($id) {
			case "T":
			return "Tarde";
		break;
		case "N":
			return "Noche";
		break;
		case "M":
			return "Mañana";
		break;
		default:
			return " ";
		break;
		}
	}
}
?>