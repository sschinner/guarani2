<?php
namespace kernel\util\cache;
use kernel\kernel;

class cache_memoria_memcached extends cache
{
	protected $cache = array();
	
	function get_tipo()
	{
		return admin_cache::tipo_memoria;
	}
	
	function existe($id, $cache=true)
	{
		if (kernel::proyecto()->memcached() !== null) {
			$value = kernel::proyecto()->memcached()->get($id);
			if($value===false){
				return false;
			} else {
				if($cache) $this->cache[$id] = $value;
				return true;
			}
		}
		return false;
	}

	function guardar($id, $datos, $expiration=0)
	{
  		if (kernel::proyecto()->memcached() !== null) {
			return kernel::proyecto()->memcached()->set($id, $datos, $expiration);
		}
		return false;
	}

	function buscar($id)
	{
		if (kernel::proyecto()->memcached() !== null) {
			if(isset($this->cache[$id])){
				return $this->cache[$id];
			}
			return kernel::proyecto()->memcached()->get($id);
		}
		return false;
	}

	function eliminar($id)
	{
		if (kernel::proyecto()->memcached() !== null) {
			return kernel::proyecto()->memcached()->delete($id);
		}
	}

    function limpiar_cache($demora = 0)
    {
        if (kernel::proyecto()->memcached() !== null) {
            //http://php.net/manual/es/memcached.flush.php
            return kernel::proyecto()->memcached()->flush($demora);
        }
    }

    function get_codigo_resultado()
    {
        if (kernel::proyecto()->memcached() !== null) {
            //http://php.net/manual/es/memcached.getresultcode.php
            return kernel::proyecto()->memcached()->getResultCode();
        }
    }

    function get_mensaje_resultado()
    {
        if (kernel::proyecto()->memcached() !== null) {
            //http://php.net/manual/es/memcached.getresultmessage.php
            return kernel::proyecto()->memcached()->getResultMessage();
        }
    }
}
?>