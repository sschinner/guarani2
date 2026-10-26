<?php
namespace kernel\util\cache;

use kernel\kernel;
use kernel\error_kernel;
use kernel\util\manejador_archivos;
use kernel\util\clase_datos;

class cache_archivo extends cache
{
	function get_tipo()
	{
		return admin_cache::tipo_archivo;
	}
	
	function existe($id)
	{
		$path = $this->get_path($id);
		$path = \realpath($path);
		return file_exists($path);
	}

	function guardar($id, $datos, $expiration=0)
	{
		$path = $this->get_path($id);
		$clase = new clase_datos($id, null, "cache");
		$clase->agregar_metodo_datos('data', $datos);
		$status = $clase->guardar($path);
		kernel::log()->add_debug('CACHE ARCHIVO guardar',$id);		
		if ($status === false){
			manejador_archivos::crear_arbol_directorios(dirname($path));
			$status = $clase->guardar($path);
			if ($status === false) {
				throw new error_kernel('CACHE ARCHIVOS: no es posible crear el cache');
			}
		}
	}

	function buscar($id)
	{
		if(!$this->existe($id)) {
			throw new error_kernel('CACHE ARCHIVOS: No existe el dato buscado');
		}
		$path = $this->get_path($id);
		require_once($path);
		$datos = call_user_func(array("\\cache\\{$id}",'data'));
		kernel::log()->add_debug('CACHE ARCHIVO buscar',$id);
		return $datos;
	}
	
	function get_path($id)
	{
		$path = kernel::proyecto()->get_dir_cache() . '/' . $id . '.php';
		return $path;
	}
	
	function eliminar($id)
	{
		unlink($this->get_path($id));
	}
}
?>