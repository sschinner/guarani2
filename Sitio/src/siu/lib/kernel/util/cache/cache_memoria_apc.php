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
		if (function_exists('apc_fetch')) {
			$retorno = false;
			\apc_fetch($id, $retorno);
			return $retorno;
		} elseif (function_exists('apcu_fetch')) {
			$retorno = false;
			@apcu_fetch($id, $retorno);
			return $retorno;
		}
		return false;
	}

	function guardar($id, $datos, $expiration=0)
	{
		if (function_exists('apc_store')) {
			return \apc_store($id, $datos, $expiration);
		} elseif (function_exists('apcu_store')) {
			return @apcu_store($id, $datos, $expiration);
		}
		return false;
	}

	function buscar($id)
	{
		if (function_exists('apc_fetch')) {
			return \apc_fetch($id);
		} elseif (function_exists('apcu_fetch')) {
			return @apcu_fetch($id);
		}
		return false;
	}

	function eliminar($id)
	{
		if (function_exists('apc_delete')) {
			return \apc_delete($id);
		} elseif (function_exists('apcu_delete')) {
			return @apcu_delete($id);
		}
		return false;
	}
}
?>