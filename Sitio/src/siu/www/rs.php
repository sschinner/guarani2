<?php
require_once(realpath(dirname(__FILE__).'/../bootstrap.php'));

	\siu\bootstrap::cargar();
	if (kernel\kernel::proyecto()->get_produccion()) {
		die();
	}
	\kernel\nucleo\acceso_recurso::procesar();

?>