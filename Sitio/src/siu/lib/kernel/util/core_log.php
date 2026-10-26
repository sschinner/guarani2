<?php
namespace kernel\util;

class core_log
{
	static protected $path;

	static function msg($texto)
	{
		$texto .= "\n--------------------------------\n";
		file_put_contents(self::get_path(),$texto, FILE_APPEND);
	}

	static protected function get_path()
	{
		if (!isset(self::$path)) {
			$archivo = date("Y_m_d___H_i_s") . '___' . uniqid() . '.log';
			self::$path = conf::from('core')->get('path_log') . '/' . $archivo;
			$txt = "--------------------------------------------------------------\n";
			$txt .= date("j/n/Y - H:i:s") . "\n";
			$txt .= "--------------------------------------------------------------\n";
			file_put_contents(self::$path, $txt);
		}
		return self::$path;
	}
}
?>