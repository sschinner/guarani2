<?php
namespace kernel\util\cache;

use kernel\error_kernel;
use kernel\kernel;

class admin_cache
{
	const tipo_memoria = 'memoria';
	const tipo_sesion = 'sesion';
	const tipo_archivo = 'archivo';
	const tipo_no = 'no';
	
	const manejador_memoria_apc = 'apc';
	const manejador_memoria_memcached = 'memcached';
	
	static protected $forzar_tipo;
	static protected $instancias = array();
	static protected $activo = true;
	static protected $manejador_memoria = self::manejador_memoria_apc;
	
	static function set_manejador_memoria($manejador)
	{
		self::$manejador_memoria = $manejador;
	}
	
	static function set_activo($estado)
	{
		self::$activo = $estado;
	}
	
	static function esta_activo($tipo)
	{
		self::controlar_tipo($tipo);		
		if($tipo == 'no') return false;
		if($tipo == self::tipo_memoria) {
			if (!function_exists('apc_fetch') && !function_exists('apcu_fetch')) {
				return false;
			}
		}
		return self::$activo;
	}	
	
	static function controlar_tipo($tipo)
	{
		if ($tipo != self::tipo_memoria && $tipo != self::tipo_archivo && 
			$tipo != self::tipo_sesion && $tipo != self::tipo_no ) {
			throw new error_kernel('El tipo de cache solicitado es incorrecto: ' . $tipo);
		}
	}

	
	
	static function forzar_tipo($tipo)
	{
		self::controlar_tipo($tipo);
		self::$forzar_tipo = $tipo;
		kernel::log()->add_debug('ADMIN CACHE: forzar tipo',$tipo);			
	}

    /**
     * @param string $tipo ver admin_cache::
     * @return \kernel\util\cache\cache
     */
	static function instancia($tipo)
	{
		self::controlar_tipo($tipo);
		if (isset(self::$forzar_tipo)) $tipo = self::$forzar_tipo;
		if (!isset(self::$instancias[$tipo])) {
			if ($tipo == self::tipo_memoria) {
				if (self::$manejador_memoria == self::manejador_memoria_apc) {
					$nombre_clase = 'memoria_apc';
				} else {
					$nombre_clase = 'memoria_memcached';
				}
			} else {
				$nombre_clase = $tipo;
			}
			
			kernel::log()->add_debug('ADMIN CACHE',': instanciando: ' . $nombre_clase);
			$clase = "\\kernel\\util\\cache\\cache_" . $nombre_clase;
			self::$instancias[$tipo] = new $clase();
		}
		return self::$instancias[$tipo];
	}
}
?>