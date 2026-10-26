<?php
namespace kernel\util\cache;

use kernel\kernel;
use kernel\error_kernel;
/**
 *	Para la recoleccion de basura en la sesion es interesante
 *	marcar cada entrada con la cantidad de requests que pasaron desde que se la
 *	utilizo por ultima vez
 */
class cache_sesion extends cache
{
	function get_tipo()
	{
		return admin_cache::tipo_sesion;
	}
	
	function existe($id)
	{
		return kernel::sesion()->esta_seteada($id);
	}

	function guardar($id, $datos, $expiration=0)
	{
        // Se ignora el parametro $expiration ya que la sesion no tiene
		kernel::sesion()->set($id, $datos);
		kernel::log()->add_debug('CACHE SESION guardar',$id);
	}

	function buscar($id)
	{
		if(!$this->existe($id)) {
			throw new error_kernel('CACHE SESION: No existe la entrada solicitada');
		}
		kernel::log()->add_debug('CACHE SESION buscar',$id);
		return kernel::sesion()->get($id);
	}
	
	function eliminar($id)
	{
		
	}
}

?>