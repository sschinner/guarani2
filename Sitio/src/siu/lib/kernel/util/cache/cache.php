<?php
namespace kernel\util\cache;

abstract class cache
{
	abstract function get_tipo();
	abstract function existe($id);
	abstract function guardar($id, $datos, $expiration=0);
	abstract function buscar($id);
	abstract function eliminar($id);
	
}
?>