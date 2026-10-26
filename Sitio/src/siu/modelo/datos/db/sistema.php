<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use \siu\modelo\datos\catalogo;

class sistema
{
	/**
	 * parametros: _ua, operacion, evento, _interfaz, punto_control
	 * cache: memoria
	 * cache_expiracion: 120
	 * filas: n
	 */
	function controles_activos_punto($parametros) 
	{
		$sql = "execute procedure ctr_ctrlsADisparar({$parametros['_ua']}, ".
														"{$parametros['operacion']},".
														"{$parametros['evento']},".
														"{$parametros['_interfaz']},".
														"{$parametros['punto_control']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;				
	}	
	
	/**
	 * parametros: conversion, creacion, script_corrido
	 * cache: memoria
	 */
	function version_base_valida($parametros) 
	{
		$sql = " 
			SELECT version 
			FROM app_versiones 
			WHERE version IN ({$parametros['conversion']},{$parametros['creacion']})
			  AND script_corrido = {$parametros['script_corrido']}
			  AND version NOT LIKE 'UNL%'
			GROUP BY version
			HAVING max(fecha_actualiz) = (SELECT max(fecha_actualiz) FROM app_versiones WHERE version NOT LIKE 'UNL%')
		";
		
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return !empty($datos);
	}	
	/**
	 * parametros: parametro
	 * cache: memoria
	 * filas: n
	 */
	function parametro($parametros) 
	{
		$sql = "execute procedure sp_param_sistema({$parametros['parametro']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;				
	}	
	
	/**
	 * cache: memoria
	 * filas: n
	 */
	function sedes($parametros) 
	{
		$sql = "SELECT sede, nombre FROM sga_sedes;";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        $nuevo = array();
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['SEDE']);
        }
        return $nuevo;
	}	
	
	/**
	 * parametros: _ua
	 * cache: memoria
	 * cache_expiracion: 60
	 * filas: 1
	 */
	function fecha_actual($parametros) 
	{
		$parametros['formato'] = '%d-%m-%Y';
		$datos = catalogo::consultar('sistema', 'fecha_actual_formato', $parametros);
		return $datos;
	}	

	/**
	 * parametros: _ua, formato
	 * cache: memoria
	 * cache_expiracion: 60
	 * filas: 1
	 */
	function fecha_actual_formato($parametros) 
	{
		$sql = "select to_char( TODAY, {$parametros['formato']}) from sga_unidades_acad where unidad_academica = {$parametros['_ua']}";		
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}	
	
	/**
	 * parametros: mensaje
	 * cache: memoria
	 * filas: 1
	 */
	function mensaje($parametros) 
	{
		$sql = "EXECUTE PROCEDURE mme_muestramensaje({$parametros['mensaje']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;				
	}

	/**
	 * parametros: escala_notas
	 * cache: memoria
	 * filas: n
	 */
	function escala_notas($parametros)
	{
        $sql = " EXECUTE PROCEDURE sp_detalle_escala(  {$parametros['escala_notas']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['ESCALA'] = $dato[0];
			$nuevo[$id]['DESCRIPCION'] = $dato[1];
			$nuevo[$id]['RESULTADO'] = $dato[2];
			$nuevo[$id]['VALOR'] = $dato[3];
        }
		return $nuevo;	 
	}	
	
	//------------------------------------------------------------------------
	// CACHE
	//------------------------------------------------------------------------
	
	/**
	 * parametros: _ua
	 * cache: no
	 * filas: n
	 */
	function cache_lista_carreras($parametros) 
	{
		$sql = "SELECT DISTINCT sga_carreras.unidad_academica, 
								sga_carreras.carrera, 
								sga_carreras.nombre, 
								sga_carreras.nombre_reducido
			   FROM sga_carreras, sga_planes
			   WHERE sga_carreras.unidad_academica = sga_planes.unidad_academica
				AND sga_carreras.unidad_academica = {$parametros['_ua']}
				  AND sga_carreras.carrera = sga_planes.carrera
				  AND sga_planes.estado IN ('V','A')";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;				
	}

	/**
	 * parametros: _ua, CARRERA
	 * cache: no
	 * filas: n
	 */
	function cache_lista_alumnos_carrera($parametros) 
	{
		$sql = "SELECT sga_alumnos.nro_inscripcion,
				sga_alumnos.carrera,
				sga_alumnos.legajo,
				sga_alumnos.plan,
				sga_planes.version_actual as version
        FROM sga_alumnos, sga_personas, sga_planes
        WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
           AND sga_alumnos.carrera = {$parametros['CARRERA']}
          AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion       = sga_alumnos.nro_inscripcion
          AND sga_planes.unidad_academica = sga_alumnos.unidad_academica
          AND sga_planes.carrera       = sga_alumnos.carrera
          AND sga_planes.plan          = sga_alumnos.plan
          AND calidad IN ('A','P') ";
		return kernel::db()->consultar($sql, db::FETCH_ASSOC);
	}

	/**
	 * parametros: _ua
	 * cache: no
	 * filas: n
	 */
	function cache_lista_alumnos_ua($parametros) 
	{
		$sql = "SELECT sga_alumnos.nro_inscripcion,
				sga_alumnos.carrera,
				sga_alumnos.legajo,
				sga_alumnos.plan,
				sga_planes.version_actual as version
        FROM sga_alumnos, sga_personas, sga_planes
        WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
          AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion       = sga_alumnos.nro_inscripcion
          AND sga_planes.unidad_academica = sga_alumnos.unidad_academica
          AND sga_planes.carrera       = sga_alumnos.carrera
          AND sga_planes.plan          = sga_alumnos.plan
          AND calidad IN ('A','P') ";
		return kernel::db()->consultar($sql, db::FETCH_ASSOC);
	}

	/**
	 * parametros: _ua
	 * cache: no
	 * filas: n
	 */
	function cache_lista_alumnos_solicitud_actualizacion($parametros) 
	{
		$sql = "SELECT sga_alumnos.nro_inscripcion,
				sga_alumnos.carrera,
				sga_alumnos.legajo
        FROM x";
		return kernel::db()->consultar($sql, db::FETCH_ASSOC);
	}
	
	
}
?>