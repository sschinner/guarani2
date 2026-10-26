<?php
// este archivo se utilizó para transformar las claves del censo en el archivo mensajes
$replacements = file_get_contents('replacements.txt');
$replacements = explode("\n", $replacements);
$search = array();
$replace = array();
foreach($replacements as $r) {
	if (empty($r)) continue;
	$aux = explode('#', $r);
	$search[]  = $aux[0].':';
	$replace[] = $aux[1].':';
}
$content = file_get_contents('/home/andres/proyectos/g3w2/trunk/src/siu/mensajes/mensajes.es.yml');
$content = str_replace($search, $replace, $content);
file_put_contents('/home/andres/proyectos/g3w2/trunk/src/siu/mensajes/mensajes.es.yml', $content);
die();
// genera los reemplazos en un archivo aparte y modifica el código
$directory = ".";
$filenames = array();
$iterator = new DirectoryIterator($directory);
foreach ($iterator as $fileinfo) {
	if ($fileinfo->isFile() && $fileinfo->getExtension() == 'php' && $fileinfo->getFileName() != 'regex.php') {
		$filenames[] = $fileinfo->getFilename();
	}
}
$acum = '';
foreach ($filenames as $archivo) {
	echo "parsing $archivo\n";
	$content = file_get_contents($archivo);
	preg_match_all("/->trans\('.*\.(.*)\.(.*)'\);(.*\s*.*Zend_.*)\('(.*)',/im", $content, $matches);
	
	foreach ($matches[1] as $key => $sub_form) {
		$str = "censo.$sub_form.".$matches[2][$key];
		$str2 = "censo.$sub_form.".$matches[4][$key];
		$acum .= "$str#$str2\n";
	}
}
file_put_contents('replacements.txt',$acum);


foreach ($filenames as $archivo) {
	echo "cambiando $archivo\n";
	$content = file_get_contents($archivo);
	$content = preg_replace("/->trans\('.*\.(.*)\.(.*)'\);(.*\s*.*Zend_.*)\('(.*)',/im", "->trans('censo.$1.$4');$3('$4',", $content);
	file_put_contents($archivo, $content);
}


die();

$content = preg_replace("/->trans\('.*\.(.*)\.(.*)'\);(.*\s*.*Zend_.*)\('(.*)',/im", "->trans('censo.$1.$4');$3('$4',", $content);
file_put_contents('result.php', $content);

die();


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
