<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use kernel\util\db\db;

class orientacion
{
	/**
	 * Orientaciones disponibles
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function lista_orientaciones($parametros)
	{
		$sql = "execute procedure sp_orientplanesper(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"]  . ")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		if (!empty($datos)){
			foreach($datos as $key => $value) {
				$nuevo[$key][catalogo::id] = catalogo::generar_id($value[1]."-".$value[2]."-".$value[4]."-".$value[5]."-".$value[6]);
				$nuevo[$key]["carrera"] = $value[1];
				$nuevo[$key]["orientacion"] = $value[4];
				$nuevo[$key]["plan"] = $value[6];
				$nuevo[$key]["nombre"] = $value[8];
				$nuevo[$key]["titulo_id"] = $value[5];
				$nuevo[$key]["titulo"] = $value[9];
			}			
		}
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, carrera, legajo, plan, titulo, orientacion, movimiento, observaciones
	 * param_null: observaciones
	 * cache: no
	 * filas: n
	 */
	function seleccionar_orientacion($parametros)
	{
		$nro_resolucion = "NULL";
		
		$sql = "execute procedure sp_u_OrientAlumno({$parametros['_ua']}, {$parametros['carrera']}, 
				{$parametros['legajo']}, {$parametros['plan']},{$parametros['titulo']},{$parametros['orientacion']},
				{$parametros['movimiento']},$nro_resolucion,{$parametros['observaciones']})";
				
		return kernel::db()->consultar($sql, db::FETCH_NUM);
	}
	
	/**
	 * parametros: _ua, carrera, legajo
	 * cache: no
	 * filas: n
	 */
	function orientacion_actual($parametros)
	{		
		$sql = "SELECT dba.sga_orient_alumno.orientacion,
        dba.sga_orientaciones.nombre,
		dba.sga_alumnos.plan, 
        dba.sga_orient_alumno.titulo,
        dba.sga_titulos.nombre
		
		FROM dba.sga_alumnos,
			dba.sga_orient_alumno,
			dba.sga_orientaciones,
			dba.sga_titulos      
		WHERE dba.sga_alumnos.unidad_academica = {$parametros['_ua']} 
		AND dba.sga_alumnos.carrera = {$parametros['carrera']} 
		AND dba.sga_alumnos.legajo = {$parametros['legajo']}


		AND dba.sga_orient_alumno.unidad_academica =  dba.sga_alumnos.unidad_academica
		AND dba.sga_orient_alumno.carrera =  dba.sga_alumnos.carrera
		AND dba.sga_orient_alumno.legajo  =  dba.sga_alumnos.legajo
		AND dba.sga_orient_alumno.plan  =  dba.sga_alumnos.plan

		AND dba.sga_orientaciones.unidad_academica = dba.sga_orient_alumno.unidad_academica
		AND dba.sga_orientaciones.carrera    = dba.sga_orient_alumno.carrera
		AND dba.sga_orientaciones.plan    = dba.sga_orient_alumno.plan
		AND dba.sga_orientaciones.titulo    = dba.sga_orient_alumno.titulo
		AND dba.sga_orientaciones.orientacion    = dba.sga_orient_alumno.orientacion

		AND dba.sga_titulos.unidad_academica = dba.sga_orient_alumno.unidad_academica
		AND dba.sga_titulos.titulo = dba.sga_orient_alumno.titulo";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	
	/**
	 * parametros: _ua, carrera, legajo, titulo
	 * cache: no
	 * filas: n
	 */
	function orientacion_actual_titulo($parametros)
	{		
		$sql = "SELECT dba.sga_orient_alumno.orientacion,
        dba.sga_orientaciones.nombre,
		dba.sga_alumnos.plan, 
        dba.sga_orient_alumno.titulo,
        dba.sga_titulos.nombre
		
		FROM dba.sga_alumnos,
			dba.sga_orient_alumno,
			dba.sga_orientaciones,
			dba.sga_titulos      
		WHERE dba.sga_alumnos.unidad_academica = {$parametros['_ua']} 
		AND dba.sga_alumnos.carrera = {$parametros['carrera']} 
		AND dba.sga_alumnos.legajo = {$parametros['legajo']}


		AND dba.sga_orient_alumno.unidad_academica =  dba.sga_alumnos.unidad_academica
		AND dba.sga_orient_alumno.carrera	=  dba.sga_alumnos.carrera
		AND dba.sga_orient_alumno.legajo	=  dba.sga_alumnos.legajo
		AND dba.sga_orient_alumno.plan		=  dba.sga_alumnos.plan
		AND dba.sga_orient_alumno.titulo	= {$parametros['titulo']}

		AND dba.sga_orientaciones.unidad_academica = dba.sga_orient_alumno.unidad_academica
		AND dba.sga_orientaciones.carrera    = dba.sga_orient_alumno.carrera
		AND dba.sga_orientaciones.plan    = dba.sga_orient_alumno.plan
		AND dba.sga_orientaciones.titulo    = dba.sga_orient_alumno.titulo
		AND dba.sga_orientaciones.orientacion    = dba.sga_orient_alumno.orientacion

		AND dba.sga_titulos.unidad_academica = dba.sga_orient_alumno.unidad_academica
		AND dba.sga_titulos.titulo = dba.sga_orient_alumno.titulo";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: _ua, carrera, legajo, plan
	 * cache: no
	 * filas: n
	 */
	function titulos_orientacion($parametros)
	{		
		$sql = "
			SELECT t.titulo, t.nombre, t.nivel,
				   (SELECT op.nombre 
					  FROM sga_orient_alumno as oa,
						   sga_orientaciones as op
					 WHERE oa.unidad_academica = tp.unidad_academica
					   AND oa.carrera = tp.carrera
					   AND oa.legajo  = {$parametros['legajo']}
					   AND oa.plan    = tp.plan
					   AND oa.titulo  = tp.titulo

					   AND op.unidad_academica = oa.unidad_academica
					   AND op.carrera = oa.carrera
					   AND op.plan    = oa.plan
					   AND op.titulo  = oa.titulo
					   AND op.orientacion  = oa.orientacion
					) as orient_elegida,
					tp.elige_orient

			  FROM sga_titulos_plan as tp, 
				   sga_titulos as t

			WHERE tp.unidad_academica	=	{$parametros['_ua']} 
			  AND tp.carrera			=	{$parametros['carrera']}
			  AND tp.plan				=	{$parametros['plan']}
			  AND tp.tiene_orient = 'S'
			  AND t.unidad_academica = tp.unidad_academica
			  AND t.titulo = tp.titulo";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
}
?>