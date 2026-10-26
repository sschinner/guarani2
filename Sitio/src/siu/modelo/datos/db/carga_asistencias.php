<?php
namespace siu\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\alumno_foto;

class carga_asistencias
{
    /**
	 * parametros: _ua, legajo
	 * cache: no
	 * filas: n
	 */
    function listado_comisiones_docente($parametros)
    {
        $sql = "SELECT	(SELECT COUNT(*) FROM sga_subcomisiones 
				WHERE	sga_subcomisiones.comision = sga_comisiones.comision) as cnt_subcomisiones,
						sga_comisiones.materia,
						sga_materias.nombre as materia_nombre,
						sga_comisiones.comision,
						sga_comisiones.nombre as comision_nombre,
						sga_comisiones.anio_academico,
						sga_comisiones.periodo_lectivo,
						sga_comisiones.catedra,
						DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', 'No informa') as turno,
						sga_sedes.sede,
						sga_sedes.nombre as sede_nombre,
						(SELECT COUNT(*)  FROM sga_insc_cursadas WHERE comision = sga_comisiones.comision AND estado in ('A','P','E')) as cant_inscriptos,
						(SELECT COUNT (DISTINCT sga_inasis_acum.legajo) FROM sga_inasis_acum WHERE sga_inasis_acum.comision = sga_comisiones.comision AND sga_inasis_acum.estado = 'L') as cant_libres 
				FROM	sga_docentes_com
				JOIN	sga_comisiones		ON (sga_comisiones.comision = sga_docentes_com.comision)
				JOIN	sga_periodos_lect	ON (sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
											AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo)
				JOIN	sga_materias		ON (sga_materias.unidad_academica = sga_comisiones.unidad_academica
											AND sga_materias.materia = sga_comisiones.materia)
				JOIN	sga_sedes			ON (sga_sedes.sede = sga_comisiones.sede)
			
				WHERE	sga_docentes_com.legajo =  {$parametros['legajo']}
				AND sga_periodos_lect.fecha_inactivacion >= TODAY
				ORDER BY sga_comisiones.anio_academico, sga_comisiones.periodo_lectivo";
				
				$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
				$resultado = array();
				foreach(array_keys($datos) as $id) {
					$resultado[$datos[$id]['COMISION']] = $datos[$id];
					$resultado[$datos[$id]['COMISION']][catalogo::id] = catalogo::generar_id($datos[$id]['COMISION']);
				}
				return $resultado;
    }

	
    /**
	 * parametros: _ua, docente, per_lect, materia
	 * param_null: docente, per_lect, materia
	 * cache: no
	 * filas: n
	 */
    function listado_comisiones_filtro($parametros)
    {
		/* FILTROS y JOINS */
		$join_docente = "";
		$filtro_docente = "";
		$filtro_periodo_lectivo = "";
		$filtro_materia = "";
		
		if($parametros['docente'] != "''"){
			$join_docente	= " JOIN sga_docentes_com ON (sga_comisiones.comision = sga_docentes_com.comision) ";
			$filtro_docente	= " AND sga_docentes_com.legajo =  {$parametros['docente']}	";					  
		}
		
		if($parametros['per_lect'] != "''"){
			$filtro_periodo_lectivo	= " AND sga_periodos_lect.periodo_lectivo = {$parametros['per_lect']} ";
		}
		
		if($parametros['materia'] != "''"){
			$filtro_materia	= " AND sga_materias.materia = {$parametros['materia']} ";
		}
				
        $sql = "SELECT	(SELECT COUNT(*) FROM sga_subcomisiones 
				WHERE	sga_subcomisiones.comision = sga_comisiones.comision) as cnt_subcomisiones,
						sga_comisiones.materia,
						sga_materias.nombre as materia_nombre,
						sga_comisiones.comision,
						sga_comisiones.nombre as comision_nombre,
						sga_comisiones.anio_academico,
						sga_comisiones.periodo_lectivo,
						sga_comisiones.catedra,
						DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', 'No informa') as turno,
						sga_sedes.sede,
						sga_sedes.nombre as sede_nombre,
						(SELECT COUNT(*)  FROM sga_insc_cursadas WHERE comision = sga_comisiones.comision AND estado in ('A','P','E')) as cant_inscriptos,
						(SELECT COUNT (DISTINCT sga_inasis_acum.legajo) FROM sga_inasis_acum WHERE sga_inasis_acum.comision = sga_comisiones.comision AND sga_inasis_acum.estado = 'L') as cant_libres 
				FROM	sga_comisiones
				$join_docente
				JOIN	sga_periodos_lect	ON (sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
											AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo)
				JOIN	sga_materias		ON (sga_materias.unidad_academica = sga_comisiones.unidad_academica
											AND sga_materias.materia = sga_comisiones.materia)
				JOIN	sga_sedes			ON (sga_sedes.sede = sga_comisiones.sede)
			
				WHERE sga_periodos_lect.fecha_inactivacion >= TODAY
				$filtro_docente
				$filtro_periodo_lectivo
				$filtro_materia
				ORDER BY sga_comisiones.anio_academico, sga_comisiones.periodo_lectivo";
				
				$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
				$resultado = array();
				foreach(array_keys($datos) as $id) {
					$resultado[$datos[$id]['COMISION']] = $datos[$id];
					$resultado[$datos[$id]['COMISION']][catalogo::id] = catalogo::generar_id($datos[$id]['COMISION']);
				}
				return $resultado;
    }
	
	/**
	 * parametros: _ua, legajo, comision, filas
	 * param_null: legajo
	 * cache: memoria
	 * cache_expiracion: 3600
	 * filas: n* 
	 */
	
	function get_clases_subcomisiones_docente($parametros)
	{
		
		
		$first = '';
		$filas = filter_var($parametros['filas'], FILTER_SANITIZE_NUMBER_INT);
		if ($filas > 0) {
			$first = "FIRST $filas";
		}
		
		$join_legajo = "";
		$where_legajo = "";
		if($parametros["legajo"] != "''")
		{
			$join_legajo = " sga_docentes_subco, ";
			
			$where_legajo = " AND sga_docentes_subco.comision = sga_subcomisiones.comision ";
			$where_legajo .= " AND sga_docentes_subco.subcomision = sga_subcomisiones.subcomision ";
			$where_legajo .= " AND sga_docentes_subco.legajo = {$parametros['legajo']} ";
		}
		
		// Clases de las subcomiiones en donde se encuentra el docente.
		// Podrian compartir banda horaria las subcomisiones. Ordenadas por fecha y hora de inicio.
		$sql = "SELECT	$first
						sga_comisiones.comision,
						sga_comisiones.nombre as comision_nombre,
						sga_materias.materia as materia,
						sga_materias.nombre  as materia_nombre,		
						sga_asign_subcom.subcomision,
						sga_subcomisiones.nombre as subcomision_nombre,
						sga_calendcursada.clase,
						sga_asignaciones.dia_semana as dia_semana,
						to_char(sga_calendcursada.fecha, '%d/%m/%Y') as fecha_clase,
						sga_calendcursada.fecha as fecha_orden,
						sga_tipo_clase.descripcion as tipo_clase,
						to_char(sga_asignaciones.hs_comienzo_clase,'%H:%M') as hs_comienzo_clase,
						to_char(sga_asignaciones.hs_finaliz_clase ,'%H:%M') as hs_finaliz_clase,
						sga_asign_clases.cantidad_horas
					--	sga_calendcursada.tema_previsto as planificado,
					--	sga_calendcursada.tema as dictado,
				FROM	sga_comisiones,
						sga_subcomisiones,
						sga_materias,
						$join_legajo
						sga_calendcursada,   
						sga_asign_clases,   
						OUTER sga_tipo_clase,
						sga_asignaciones,
						sga_asign_subcom
						
				WHERE	sga_comisiones.comision = {$parametros['comision']}
				AND		sga_subcomisiones.comision = sga_comisiones.comision
				AND		sga_materias.unidad_academica   = sga_comisiones.unidad_academica
				AND		sga_materias.materia            = sga_comisiones.materia
				AND		sga_calendcursada.comision = sga_comisiones.comision
				AND		sga_calendcursada.valido = 'S'
				AND		sga_calendcursada.fecha       <= TODAY
				AND		sga_asign_clases.comision   = sga_calendcursada.comision  
				AND		sga_asign_clases.asignacion = sga_calendcursada.asignacion  
				AND		sga_asignaciones.asignacion = sga_asign_clases.asignacion  

				AND		sga_asign_subcom.comision     = sga_subcomisiones.comision 
				AND		sga_asign_subcom.subcomision  = sga_subcomisiones.subcomision
				AND		sga_asign_subcom.asignacion   = sga_asign_clases.asignacion 
				
				AND		sga_tipo_clase.tipo_clase	= sga_asign_clases.tipo_clase

				$where_legajo
					
				ORDER BY 10 desc, 12";
		
				$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
				
				foreach(array_keys($datos) as $id) {
					$datos[$id][catalogo::id] = catalogo::generar_id($datos[$id]['COMISION'].$datos[$id]['CLASE']);
					$param['comision_id'] = catalogo::generar_id($datos[$id]['COMISION']);
					$param['filas'] = 0;
					$param['clase_id'] = $datos[$id][catalogo::id];
					$datos[$id]['LINK'] = kernel::vinculador()->crear('asistencias', 'editar', $param);
				}
				
				return $datos;
		
	}	
	
	/**
	 * parametros: _ua, comision, filas
	 * cache: memoria
	 * cache_expiracion: 3600
	 * filas: n* 
	 */
    function get_clases_comisiones_docente($parametros)
	{
		$first = '';
		$filas = filter_var($parametros['filas'], FILTER_SANITIZE_NUMBER_INT);
		if ($filas > 0) {
			$first = "FIRST $filas";
		}		
		
		$sql = "SELECT	$first
						sga_comisiones.comision,
						sga_comisiones.nombre as comision_nombre,
						0 as subcomision,
						'' as subcomision_nombre,
						sga_materias.materia as materia,
						sga_materias.nombre  as materia_nombre,
						sga_calendcursada.clase,
						sga_asignaciones.dia_semana as dia_semana,
						to_char(sga_calendcursada.fecha, '%d/%m/%Y') as fecha_clase,
						sga_tipo_clase.descripcion as tipo_clase,
					--	sga_calendcursada.tema_previsto as planificado,
					--	sga_calendcursada.tema as dictado,
						to_char(sga_asignaciones.hs_comienzo_clase,'%H:%M') as hs_comienzo_clase,
						to_char(sga_asignaciones.hs_finaliz_clase ,'%H:%M') as hs_finaliz_clase,
						sga_asign_clases.cantidad_horas,
						sga_calendcursada.fecha

				FROM	sga_comisiones,
						sga_materias,   
						sga_calendcursada,   
						sga_asignaciones,
						sga_asign_clases,
						OUTER sga_tipo_clase

				WHERE	sga_comisiones.comision         = {$parametros['comision']}
  				AND		sga_materias.unidad_academica   = sga_comisiones.unidad_academica
				AND		sga_materias.materia            = sga_comisiones.materia
				AND		sga_comisiones.comision			= sga_calendcursada.comision
				AND		sga_calendcursada.asignacion	= sga_asignaciones.asignacion 
				AND		sga_calendcursada.valido		= 'S'
				AND		sga_calendcursada.comision      = sga_asign_clases.comision
				AND		sga_calendcursada.asignacion    = sga_asign_clases.asignacion
				AND		sga_calendcursada.fecha        <= TODAY
				AND     sga_tipo_clase.tipo_clase = sga_asign_clases.tipo_clase
				ORDER BY sga_calendcursada.fecha DESC;";
		
				$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
				
				foreach(array_keys($datos) as $id) {
					$datos[$id][catalogo::id] = catalogo::generar_id($datos[$id]['COMISION'].$datos[$id]['CLASE']);
					$param['comision_id'] = catalogo::generar_id($datos[$id]['COMISION']);
					$param['filas'] = 0;
					$param['clase_id'] = $datos[$id][catalogo::id];
					$datos[$id]['LINK'] = kernel::vinculador()->crear('asistencias', 'editar', $param);
				}
				
				return $datos;
		
	}	
	
	/**
	 * parametros: clase
	 * cache: no
	 * filas: n
	 */
    function clase_detalle($parametros)
    {
		$sql = "execute procedure sp_AsisAluClas({$parametros["clase"]})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id][catalogo::id] = catalogo::generar_id($dato[15].$dato[16].$dato[4]);
			$nuevo[$id]['CARRERA'] = $dato[15];
			$nuevo[$id]['LEGAJO'] = $dato[16];
			$nuevo[$id]['COMISION'] = $dato[4];
			$nuevo[$id]['CLASE'] = $dato[10];
			$nuevo[$id]['NOMBRE'] = "{$dato[17]}, {$dato[18]}"; 
			$nuevo[$id]['INASISTENCIA'] = $dato[19]; 
			$nuevo[$id]['ID_IMAGEN'] = $dato[21]; 
			if (!empty($nuevo[$id]['ID_IMAGEN'])) {
				$nuevo[$id]['URL_IMAGEN'] = alumno_foto::url_imagen($nuevo[$id]['ID_IMAGEN']);
				$nuevo[$id]['URL_IMAGEN_MEDIANA'] = alumno_foto::url_imagen($nuevo[$id]['ID_IMAGEN'], alumno_foto::TAMANIO_MEDIANA);
				$nuevo[$id]['URL_IMAGEN_GRANDE'] = alumno_foto::url_imagen($nuevo[$id]['ID_IMAGEN'], alumno_foto::TAMANIO_GRANDE);
			} else {
				$nuevo[$id]['URL_IMAGEN'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
				$nuevo[$id]['URL_IMAGEN_MEDIANA'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm_grande.png');
				$nuevo[$id]['URL_IMAGEN_GRANDE'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm_grande.png');
			}			
		}
		return $nuevo;
	}
        /**
	 * parametros: id_comision
	 * cache: memoria
	 * cache_expiracion: 3600
	 * filas: n
	 */
        function tipo_clase_comision ($parametros){
            
            $sql = "SELECT
                    sga_tipo_clase.tipo_clase,   
                    sga_tipo_clase.descripcion  
                    FROM sga_tipo_clase,
                    sga_asign_clases
                    WHERE sga_asign_clases.comision = {$parametros['id_comision']}
                    AND sga_tipo_clase.tipo_clase = sga_asign_clases.tipo_clase";
                    
            $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
            $nuevo = array('' => kernel::traductor()->trans('asistencias.planilla.filtro_seleccione'));
            foreach ($datos as $dato){
                $nuevo[$dato['TIPO_CLASE']] = $dato['DESCRIPCION'];
            }
            return $nuevo;
        }
        /**
	 * parametros: tipo_clase
	 * cache: no
	 * cache_expiracion: 3600
	 * filas: n
	 */
        function tipo_clase_desc ($parametros){
            
            $sql = "SELECT	sga_tipo_clase.descripcion  
                    FROM	sga_tipo_clase
                    WHERE	sga_tipo_clase.tipo_clase = {$parametros['tipo_clase']}";
                    
            $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
            return $datos[0]['DESCRIPCION'];
        }
    
    /**
	 * parametros: _ua, carrera, legajo, comision, clase, cantidad
	 * cache: no
	 * filas: 1
	 */
	function guardar($parametros) 
	{
        $sql = "EXECUTE PROCEDURE sp_u_asisaluclas(" .
                                  $parametros["_ua"] . ",".
                                  $parametros["carrera"] . "," .
                                  $parametros["legajo"] . "," .
                                  $parametros["comision"] . "," .
                                  $parametros["clase"] . "," .
                                  $parametros["cantidad"] . ",".
                                  "NULL);";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;                                                         
    }	
	
	/**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function listado_alumnos_libres($parametros)
	{
		$sql = "SELECT 
				sga_inasis_acum.tramo, 
				sga_inasis_acum.cant_acumuladas, 
				sga_inasis_acum.cant_justificadas,
				sga_alumnos.legajo,
				sga_personas.apellido || ' ' || sga_personas.nombres as apellido_nombre
				FROM sga_inasis_acum 
				JOIN sga_alumnos ON (
				sga_inasis_acum.unidad_academica = sga_alumnos.unidad_academica AND 
				sga_inasis_acum.carrera = sga_alumnos.carrera AND 
				sga_inasis_acum.legajo = sga_alumnos.legajo
				) 
				JOIN sga_personas ON (
				sga_personas.unidad_academica = sga_alumnos.unidad_academica AND 
				sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion
				) 
				WHERE sga_inasis_acum.estado = 'L' 
				AND sga_inasis_acum.comision = {$parametros['comision']} 
				ORDER BY 
				sga_inasis_acum.tramo, 
				sga_personas.apellido || ' ' || sga_personas.nombres
				";
				
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * parametros: comision, subcomision, fecha, cantidad, tipo,tipo_clase
	 * param_null: subcomision, fecha, cantidad, tipo_clase
	 * cache: no
	 * filas: n
	 */
	function get_planilla($parametros)
	{

		if($parametros["subcomision"]== "''")
		{
			$subcomision = "NULL";
		}
		else
		{
			$subcomision = $parametros["subcomision"];
		}

		$sql = "EXECUTE PROCEDURE sp_datos_planilla(" .
                                  $parametros["comision"] . "," .
                                  $subcomision . "," .
                                  $parametros["fecha"] . "," .
                                  $parametros["cantidad"] . "," .
                                  $parametros["tipo"] . "," .
                                  $parametros["tipo_clase"] . 
                                  ");";													
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$corte = array();
                $i = 0;
		foreach ($datos as $dato){
                        $i += 1;
			$corte[$dato[4]]['COMISION'] = $dato[0];
			$corte[$dato[4]]['FECHA'] = $dato[1];
			$corte[$dato[4]]['CARRERA_COM'] = $dato[2];
			$corte[$dato[4]]['CARRERA_NOMBRE'] = $dato[3];
			$corte[$dato[4]]['MATERIA'] = $dato[4];
			$corte[$dato[4]]['MATERIA_NOMBRE'] = $dato[5];
			$corte[$dato[4]]['COMISION_NOMBRE'] = $dato[6];
			$corte[$dato[4]]['PERIODO_LECTIVO'] = $dato[7];
			$corte[$dato[4]]['TURNO'] = $dato[8];
			$corte[$dato[4]]['ANIO_ACADEMICO'] = $dato[9];
			$corte[$dato[4]]['CATEDRA'] = $dato[10];
			$corte[$dato[4]]['DOCENTES'] = $dato[11];
			$corte[$dato[4]]['AULA'] = $dato[12];
			$corte[$dato[4]]['SUBCOMISION'] = $dato[23];
			$corte[$dato[4]]['SUB_NOMBRE'] = $dato[24];
			$corte[$dato[4]]['FECHAS'][1] = (!empty($dato[17]) ? date("d/m/Y", strtotime($dato[17])) : '  /  /   '); 
			$corte[$dato[4]]['FECHAS'][2] = (!empty($dato[18]) ? date("d/m/Y", strtotime($dato[18])) : '  /  /   '); 
			$corte[$dato[4]]['FECHAS'][3] = (!empty($dato[19]) ? date("d/m/Y", strtotime($dato[19])) : '  /  /   '); 
			$corte[$dato[4]]['FECHAS'][4] = (!empty($dato[20]) ? date("d/m/Y", strtotime($dato[20])) : '  /  /   '); 
			$corte[$dato[4]]['FECHAS'][5] = (!empty($dato[21]) ? date("d/m/Y", strtotime($dato[21])) : '  /  /   '); 


			$alumno['NRO'] = $i; 
			$alumno['ALUMNO'] = $dato [13]; 
			$alumno['UA'] = $dato [14]; 
			$alumno['CARRERA'] = $dato [15]; 
			$alumno['LEGAJO'] = $dato [16]; 
            $alumno['ACUMULADAS'] = $dato [22]; 
            $alumno['ACUMULADAS_TIPOCLASE'] = $dato [27]; 
			
			$corte[$dato[4]]['ALUMNOS'][] = $alumno;
			unset($alumno);
		} 
		return $corte;
	}
	
	/**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function get_subcomisiones($parametros)
	{
        $sql = "SELECT		s.subcomision, s.tipo_clase, s.nombre, t.descripcion
				FROM		sga_subcomisiones	s
				INNER JOIN	sga_tipo_clase		t
				ON			s.tipo_clase	=	t.tipo_clase
				WHERE		s.comision = {$parametros['comision']}";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$subcomisiones = array();
		foreach($datos as $dato)
		{
			$subcomision['SUBCOMISION'] = $dato[0];
			$subcomision['TIPO_CLASE'] = $dato[1];
			$subcomision['TIPO_CLASE_NOMBRE'] = $dato[3];
			$subcomision['NOMBRE'] = $dato[2];
			
			$subcomisiones['subcomisiones'][] = $subcomision;
			unset($subcomision);
		}
		return $subcomisiones;
	}	
}
?>