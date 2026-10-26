<?php
// Con este archivo se sacaron las comillas de todos los archivos que acceden a la
// base para que se pueda agregar el quote genérico

$directory = ".";
$filenames = array();
$iterator = new DirectoryIterator($directory);
foreach ($iterator as $fileinfo) {
	if ($fileinfo->isFile() && $fileinfo->getFileName() != 'regex.php') {
		$filenames[] = $fileinfo->getFilename();
	}
}

// original => v1
foreach ($filenames as $archivo) {
	echo "cambiando $archivo\n";
	$content = file_get_contents($archivo);
	$content = preg_replace('/(execute procedure.*\()\s*\'/im', '$1', $content);
	$content = preg_replace('/(\{\$parametros\[.*\]\})\'\s*,(\s*)\'/im', '$1,$2', $content);
	$content = preg_replace('/(execute procedure.*\(.*)\'?\);?\s*"\s*;/imsU', '$1)";', $content);
	$content = preg_replace('/\'(\{\$parametros\[.*\]\})\'/im', '$1', $content);
	file_put_contents($archivo, $content);
}


//$content = file_get_contents('unidad_academica.php');
//
//
//// se sacan las 1ras comillas
//// esto: execute procedure sp_i_inscCursadas('{$parametros['_ua']}', '".
//// en esto: execute procedure sp_i_inscCursadas({$parametros['_ua']}', '".
//$content = preg_replace('/(execute procedure.*\()\'/im', '$1', $content);
//
//
//// esto $sql = "execute procedure sp_matInscCurAlu({$parametros['_ua']}', '".
//// en esto $sql = "execute procedure sp_matInscCurAlu({$parametros['_ua']}, ".
//$content = preg_replace('/(\{\$parametros\[.*\]\})\'\s*,(\s*)\'/im', '$1,$2', $content);
//
//// se saca la comilla que cierra al último parámetro
//$content = preg_replace('/(execute procedure.*\(.*)\'\)/imsU', '$1)', $content);
//
//
//// esta es para las que no están adentro de procedures
//$content = preg_replace('/\'(\{\$parametros\[.*\]\})\'/im', '$1', $content);
//
//
//file_put_contents('unidad_academica2.php', $content);
?>
