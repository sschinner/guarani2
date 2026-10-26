<?php
namespace kernel\util;

/**
 * Description of config
 *
 * @author andres
 */
class config {
	static function load($file)
	{
		return include $file;
	}
}

?>
