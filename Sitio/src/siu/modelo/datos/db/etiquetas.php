<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;

class etiquetas
{
	/**
	 * cache: memoria
	 * filas: n
	 */
	function empresas_celulares($parametros) 
	{
		$sql = "SELECT celular_compania as id, nombre as desc FROM mdp_celular_comp";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 * filas: n
	 */
	function paises (){
		$sql = "SELECT pais as id, nombre as desc FROM mug_paises order by nombre";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 * parametros: pais
	 * filas: n
	 */
	function provincias ($parametros)
	{
		$sql = "SELECT	provincia as id, 
						nombre as desc 
				FROM	mug_provincias 
				WHERE	pais = {$parametros['pais']}
				ORDER BY nombre";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 * parametros: provincia_id, localidad
	 * no_quote: localidad
	 * filas: n
	 */
	function localidades ($parametros) 
	{
		$localidad = $parametros['localidad'];
		$localidad = kernel::db()->quote_like($localidad, '%', '%');
		$localidad = strtoupper($localidad);
		
		$sql = "SELECT 
				mug_localidades.localidad || '_'  || NVL(mug_cod_postales.codigo_postal, '-') || '_'  || mug_localidades.nombre as id, 
				mug_localidades.nombre  || ' ('  || NVL(mug_cod_postales.codigo_postal, 'Sin código postal') || ')'  as desc , 
				mug_localidades.nombre as nombre,
				mug_localidades.localidad as localidad
			FROM mug_localidades, 
                       OUTER mug_cod_postales 
			WHERE mug_localidades.localidad = mug_cod_postales.localidad
			  AND mug_localidades.dpto_partido IN (SELECT mug_dptos_partidos.dpto_partido FROM mug_dptos_partidos WHERE mug_dptos_partidos.provincia = {$parametros['provincia_id']}) 
			  AND UPPER(mug_localidades.nombre) LIKE $localidad
			ORDER BY mug_localidades.nombre";
			
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		if (!empty($datos))
		{
			return $datos;
		}
		else
		{
			return false;
		}		
	}
	
	/**
	 * cache: memoria
	 * parametros: localidad
	 * filas: 1
	 */
	function nombre_localidad ($parametros)
	{
		$sql = "SELECT 
			mug_localidades.nombre_abreviado || ', '  || mug_provincias.nombre || ', ' || mug_paises.nombre as texto
			FROM mug_localidades, mug_provincias, mug_paises, mug_dptos_partidos
			WHERE mug_localidades.dpto_partido =  mug_dptos_partidos.dpto_partido
			AND mug_provincias.provincia =  mug_dptos_partidos.provincia
			AND mug_provincias.pais =  mug_paises.pais 
			AND mug_localidades.localidad = {$parametros['localidad']}";
			
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);		
		if (!empty($datos))
		{
			return $datos['TEXTO'];
		}
		else
		{
			return false;
		}		
	}

	/**
	 * cache: memoria
	 */
	function tipos_documento()
	{
		$sql = 'execute PROCEDURE sp_tiposdocumento()';
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id] = array(
				'id' => $dato[0],
				'nombre' => $dato[1],
				'abrev' => $dato[2]
			);
		}
		
		return $nuevo;
	}
	
	/**
	 * cache: memoria
	 * filas: n
	 */
	function empresas() 
	{
		$sql = "SELECT empresa as id, nombre as desc FROM mdp_empresas";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 * filas: n
	 */
	function sectores_ac_ec() 
	{
		$sql = "SELECT sector as id, nombre as desc FROM mdp_act_ec_sector";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 * parametros: sector
	 * param_null: sector
	 * filas: n
	 */
	function subsectores_ac_ec($parametros) 
	{
		$sql = "SELECT subsector as id, nombre as desc FROM mdp_act_ec_subsect WHERE sector = {$parametros['sector']}";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 **/
	function tipos_discapacidad() 
	{
		$sql = 'SELECT tipo_discapacidad as id, desc_abreviada as abrev, descripcion as desc FROM mdp_discap_tipos';
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 **/
	function tipos_caracter() 
	{
		$sql = 'SELECT tipo_caracter as id, descripcion as desc FROM mdp_discap_caracter';
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
	
	/**
	 * cache: memoria
	 **/
	function tipos_grado() 
	{
		$sql = 'SELECT tipo_grado as id, descripcion as desc FROM mdp_discap_grado';
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}
}
?>