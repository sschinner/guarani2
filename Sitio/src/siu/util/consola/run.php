<?php
	require_once(realpath(dirname(__FILE__).'/../../bootstrap.php'));
	
	\siu\bootstrap::registrar_autoload(true);

	$app = new \siu\util\consola\gadmin();
	$app->run();
?>