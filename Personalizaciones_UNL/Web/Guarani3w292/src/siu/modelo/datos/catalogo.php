<?php
namespace siu\modelo\datos;

use kernel\kernel;
use siu\bootstrap;
use siu\extension_kernel\log;
use kernel\util\asercion;
use siu\guarani;
use siu\errores\error_guarani;
use kernel\util\cache\admin_cache;

class catalogo
{
	const id = '__ID__';
	const prefijo_memcache = 'catalogo__';
	const cache_config_tipo = 'tipo';
	const cache_config_expiracion = 'exp';
	const CACHE_EXPIRATION_MAX = 300; // 5 minutos
	static protected $daos = array();
	static protected $metadata;
	static protected $fecha_actual;

	//----------------------------------------------------
	// Shortcuts
	//----------------------------------------------------

	static function generar_id($id)
	{
		$salt = kernel::proyecto()->get('salt');
		//return sha1($salt . $id);
                //SE AGREGA EL 0 PARA QUE NO MACHEE CON LAS UA
                return "0" . sha1($salt . $id);
	}

	static function fecha_actual()
	{
		if (!isset(self::$fecha_actual)) {
			$temp = self::consultar('sistema','fecha_actual');
			self::$fecha_actual = $temp[0];
		}
		return self::$fecha_actual;
	}
	
	//----------------------------------------------------
	// Acceso al CATALOGO
	//----------------------------------------------------
	
	static function consultar($clase, $metodo, $parametros=array(), $config=array())
	{
		$debug = kernel::log()->es_nivel_activo(log::NIVEL_DEBUG);
		// Recupero metadata de la consulta
		$metadata = self::buscar_metadata_catalogo($clase, $metodo, $config);
		$metodo_con_parametros = isset($metadata['parametros']);
		if ($metodo_con_parametros) {
			$parametros = self::procesar_parametros($clase, $metodo, $metadata, $parametros);
			if(empty($parametros)){
				throw new error_guarani("CATALOGO: acceso sin parametros: $clase - $metodo");
			}
		}
		// Tipo de cache
		if(isset($config[self::cache_config_tipo])){
			$tipo_cache = $config[self::cache_config_tipo];
		} else {
			$tipo_cache = $metadata['cache'];
		}
		$usar_cache = admin_cache::esta_activo($tipo_cache);
		$str_cache = var_export($usar_cache, true);
		kernel::log()->add_debug("CATALOGO: $clase/$metodo | cache [$str_cache] - tipo [$tipo_cache]",
									array('parametros'=>$parametros,'metadata'=>$metadata,'force_cache'=>$config));
		if(!$usar_cache) {
			//---- NO Usar cache: get DB
			if($debug) {
				kernel::log()->cronometro()->marcar('pre-consulta');
			}
			$dao = self::cargar_dao($clase);
			$datos = $dao->$metodo($parametros);
			if($debug) {
				kernel::log()->cronometro()->marcar('post-consulta');
				$tiempo = kernel::log()->cronometro()->tiempo_ultima_marca();
				kernel::log()->acceso_catalogo(	$clase,
												$metodo,
												log::CATALOGO_MEDIO_DB,
												log::CATALOGO_ACCION_LEER,
												$tiempo);
				kernel::log()->add_debug('DATOS',$datos,true);
			}
			return $datos;
		} else {
			//---- Usar CACHE!
			$cache = admin_cache::instancia($tipo_cache);
			$id_cache = self::generar_id_cache($clase,$metodo,$parametros);
			if($cache->existe($id_cache)){
				//-- Hay CACHE!
				if($debug) {
					kernel::log()->cronometro()->marcar("pre-cache [$clase::$metodo]");
				}
				$datos = $cache->buscar($id_cache);
				if($debug) {
					kernel::log()->cronometro()->marcar('post-cache');
					$tiempo = kernel::log()->cronometro()->tiempo_ultima_marca();
					$medio = kernel::log()->get_medio($cache->get_tipo());
					kernel::log()->acceso_catalogo(	$clase,
													$metodo,
													$medio,
													log::CATALOGO_ACCION_LEER,
													$tiempo);
					kernel::log()->add_debug('CATALOGO CACHE DATOS',$datos,true);					
				}
				return $datos;
			} else {
				//-- No Hay CACHE: get DB
				if($debug) {
					kernel::log()->cronometro()->marcar('pre-consulta');
				}
				$dao = self::cargar_dao($clase);
				$datos = $dao->$metodo($parametros);
				if($debug) {
					kernel::log()->cronometro()->marcar('post-consulta');
					$tiempo = kernel::log()->cronometro()->tiempo_ultima_marca();
					kernel::log()->acceso_catalogo(	$clase,
													$metodo,
													log::CATALOGO_MEDIO_DB,
													log::CATALOGO_ACCION_LEER,
													$tiempo);
					kernel::log()->add_debug('DATOS',$datos,true);
				}
				//-- crear CACHE
				if($debug) {
					kernel::log()->add_debug('CATALOGO CACHE - guardar',"$clase/$metodo. MEDIO: ". $cache->get_tipo());
				}
				if($cache->get_tipo()== admin_cache::tipo_memoria){
					if(isset($config[self::cache_config_expiracion])){
						$cache->guardar($id_cache, $datos, $config[self::cache_config_expiracion]);
					} elseif(isset($metadata['cache_expiracion'])){
						$cache->guardar($id_cache, $datos, $metadata['cache_expiracion']);
					} else {
						$cache->guardar($id_cache, $datos, self::CACHE_EXPIRATION_MAX);
					}
				} else {
					$cache->guardar($id_cache, $datos);
				}
				if($debug) {
					kernel::log()->cronometro()->marcar('post-guardar_cache');
					$tiempo = kernel::log()->cronometro()->tiempo_ultima_marca();
					$medio = kernel::log()->get_medio($cache->get_tipo());
					kernel::log()->acceso_catalogo(	$clase,
													$metodo,
													$medio,
													log::CATALOGO_ACCION_GUARDAR,
													$tiempo);	
				}
				return $datos;
			}
		}
	}
	
	static function limpiar_cache($clase, $metodo, $parametros=array(), $cache_config=array())
	{
		// Recupero metadata de la consulta
		$metadata = self::buscar_metadata_catalogo($clase, $metodo);
		$metodo_con_parametros = isset($metadata['parametros']);
		if ($metodo_con_parametros) {
			$parametros = self::procesar_parametros($clase, $metodo, $metadata, $parametros);
			if(empty($parametros)){
				throw new error_guarani("CATALOGO: acceso sin parametros: $clase - $metodo");
			}
		}
		// Tipo de cache
		if(isset($cache_config[self::cache_config_tipo])){
			$tipo_cache = $cache_config[self::cache_config_tipo];
		} else {
			$tipo_cache = $metadata['cache'];
		}
		$usar_cache = admin_cache::esta_activo($tipo_cache);
		if($usar_cache && $tipo_cache == admin_cache::tipo_memoria) {
			$cache = admin_cache::instancia($tipo_cache);
			$id_cache = self::generar_id_cache($clase,$metodo,$parametros);
			$cache->eliminar($id_cache);
			$medio = kernel::log()->get_medio($cache->get_tipo());
			kernel::log()->acceso_catalogo(	$clase,
											$metodo,
											$medio,
											log::CATALOGO_ACCION_INVALIDAR,
											0);
		}
	}
	
	
	static private function generar_id_cache($clase,$metodo,$parametros)
	{
		$separador = '__';
		$separador_array = '_';
		$param = '';
		if(empty($parametros)){
			$clave = '_nopar_';
		} else {
			ksort($parametros); //ordenar
			$param = implode($separador_array, $parametros);
			$param = base64_encode($param);
			$param = str_replace(array('/','+','='),'_',$param);
		}

		$clave = self::prefijo_memcache . $separador . bootstrap::instancia()->get_id_bloque_acceso(). $separador . $clase . $separador . $metodo . $separador . $param;
		return $clave;
	}
	
	/**
	 * Controla que la entrada del catalogo exista
	 */
	static private function buscar_metadata_catalogo($clase, $metodo,$config=array())
	{
		if($clase=='controles') {
			// Hack para los controles configurables, 
			// que envian su metadata desde afuera
			return $config;
		}
		$metodo_metadata = $clase.'__'.$metodo;
		
		$encontrado = false;
		$namespaces = \kernel\kernel::localizador()->get_namespaces();
		foreach ($namespaces as $id => $dir) {
			$clase_catalogo = $id .'\modelo\datos\_info_catalogo';
			if(method_exists($clase_catalogo, $metodo_metadata)) {
				$metadata = call_user_func(array($id .'\modelo\datos\_info_catalogo', $metodo_metadata));
				if(!isset($metadata['cache'])) {
					throw new error_guarani("CATALGO: la entrada [$clase/$metodo] no posee: cache");
				}
				$encontrado = true;
				if($id!='siu') break;
			}
		}
		if (!$encontrado) {
			throw new error_guarani("CATALGO: no existe la entrada [$clase/$metodo] en los namespaces: " . implode(array_keys($namespaces), ',') );
		}
		return $metadata;
	}
	
	/**
	 * Prepara los parametros
	 */
	static private function procesar_parametros($clase, $metodo, $metadata, $_parametros)
	{
		$parametros = array();
		foreach($_parametros as $_id => $_valor) {
			$parametros[mb_strtolower($_id)] = $_valor;
		}
		// cargo parametros automaticos
		if(in_array('_ua',$metadata['parametros'])){
			$parametros['_ua'] = guarani::ua()->get_id();
		}
		if(in_array('_interfaz',$metadata['parametros'])){
			$parametros['_interfaz'] = guarani::interfaz;
		}
		// Se controla que los parametros esten presentes
		if(isset($metadata['param_null'])) { // Opcion que soporta nulos
			foreach($metadata['parametros'] as $clave) {
				if (in_array($clave, $metadata['param_null'])) {
					if (!array_key_exists($clave, $parametros)) {
						throw new error_guarani("CATALOGO: $clase / $metodo - FALTA PARAMETRO: $clave");
					}					
				} else {
					if (!isset($parametros[$clave])) {
						throw new error_guarani("CATALOGO: $clase / $metodo - FALTA PARAMETRO: $clave");
					}
				}
			}				
		} else {
			foreach($metadata['parametros'] as $clave) {
				if (!isset($parametros[$clave])) {
					throw new error_guarani("CATALOGO: $clase / $metodo - FALTA PARAMETRO: $clave");
				}
			}				
		}
		
		//@todo QUOTE: no anda en odbc/ifx
		$metadata['no_quote'] = (!isset($metadata['no_quote'])) ? array() : $metadata['no_quote'];
		$metadata['no_quote'] = (!is_array($metadata['no_quote'])) ? array($metadata['no_quote']) : $metadata['no_quote'];
		
		foreach(array_keys($parametros) as $id) {
            $ignorar_quote = in_array($id, $metadata['no_quote']) || is_bool($parametros[$id]);
			if (! $ignorar_quote) {
				if (is_array($parametros[$id])) {
					foreach (array_keys($parametros[$id]) as $key) {
						$parametros[$id][$key] = kernel::db()->quote($parametros[$id][$key]);
					}
				} else {
					$parametros[$id] = kernel::db()->quote($parametros[$id]);
				}
			} 
		}
		return $parametros;
	}

	static private function cargar_dao($clase)
	{
		if(!isset(self::$daos[$clase])) {
	        $clase_full = "modelo\\datos\\db\\{$clase}";	
            self::$daos[$clase] = kernel::localizador()->instanciar($clase_full);
		}
		return self::$daos[$clase];
	}
	
}
?>
