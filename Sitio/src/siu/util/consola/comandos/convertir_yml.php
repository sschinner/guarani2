<?php

require_once realpath(dirname(__FILE__).'/../../../bootstrap.php');
$raiz = \siu\bootstrap::get_dir_raiz();
$yml_files = array(
//			$raiz.'/instalacion/config_template.yml',
//			$raiz.'/instalacion/login_template.yml',
	$raiz.'/instalacion/login.yml',
	$raiz.'/instalacion/config.yml',
//			$raiz.'/src/siu/mensajes/mensajes.es.yml',
//			$raiz.'/src/pers/ejemplo01/mensajes/mensajes.es.yml'
);
require_once($raiz . '/src/siu/lib/sfyaml/sfYaml.php');
foreach ($yml_files as $file) {
	if (!file_exists($file)) {
		continue;
	}
	$pathparts = pathinfo($file);
	$dir  = $pathparts['dirname'];
	$name = $pathparts['filename'];

	$conf = \sfYaml::load($file);
	$contenido = "<?php\n return ".var_export($conf, true).";";
	file_put_contents("$dir/$name.php", $contenido);
	unlink($file);
}
echo "proceso finalizado\n";