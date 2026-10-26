<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;

class controles
{
	function __call($metodo, $parametros) 
	{
		$procedure = $parametros[0]['__store_procedure__'];
		
		// se unquotea el nombre del procedure. Se hace acá para no meter una
		// excepción en el catalogo que tenga en cuenta si el parametro quoteado
		// es '__store_procedure__'
		$procedure = substr($procedure, 1, -1);
		
		unset($parametros[0]['__store_procedure__']);
		$str_param = implode(",",$parametros[0]);	
		if($procedure == 'ctr_bloqueoHorario'){
			$str_param = $str_param.',1';
		}
		
		$sql = "EXECUTE PROCEDURE $procedure ({$str_param})";
		return kernel::db()->consultar_fila($sql, db::FETCH_NUM);
	}
	
}
?>