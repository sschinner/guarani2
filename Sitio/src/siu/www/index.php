<?php
require_once(realpath(dirname(__FILE__).'/../bootstrap.php'));

	ini_set("memory_limit", "256M");
	// Ver: http://php.net/manual/es/timezones.america.php
	date_default_timezone_set('America/Argentina/Buenos_Aires');
	ini_set("default_charset", "ISO-8859-1");

	// Los siguientes parámetros no pueden ser modificados con ini_set:
	//ini_set("output_buffering", "On");
	//ini_set("upload_max_filesize", 8192);
	//ini_set("post_max_size", 8192);
	
	\siu\bootstrap::cargar();
	\kernel\nucleo\acceso_web::procesar();

?>