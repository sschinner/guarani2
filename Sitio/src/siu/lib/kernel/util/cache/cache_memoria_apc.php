<?php
namespace kernel\util\cache;

class cache_memoria_apc extends cache
{
	function get_tipo()
	{
		return admin_cache::tipo_memoria;
	}
	
	function existe($id, $cache=true)
	{
		$retorno = false;
		\apc_fetch($id, $retorno);
		return $retorno;
	}

	function guardar($id, $datos, $expiration=0)
	{
		return \apc_store($id, $datos, $expiration);
	}

	function buscar($id)
	{
		return \apc_fetch($id);
	}

	function eliminar($id)
	{
		return \apc_delete($id);
	}
}
?>