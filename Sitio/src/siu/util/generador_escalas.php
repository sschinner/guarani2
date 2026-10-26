<?php
namespace siu\util;

use siu\guarani;
use kernel\kernel;

class generador_escalas {
	static function generar()
	{
		$path = guarani::path_escalas();
		\kernel\util\manejador_archivos::crear_arbol_directorios($path);
		self::generar_escalas($path);
		
		self::generar_condiciones_y_resultados();
	}
	
	static function get_path_condiciones()
	{
		return guarani::path_condiciones_js().'/cond_res.js';
	}
	
	static protected function generar_escalas($path)
	{
		$sql ="select *
				FROM sga_det_escala
				order by escala_notas asc, nota asc;";
		$raw_escalas = kernel::db()->consultar($sql);
		// Los nombres de las variables a las que se mapean los conceptos.
		// De la 'A' a la 'z'
		//$vars = array_merge(range('A','Z'), range('a','z'));

		// Se guardan las escalas en un formato parseable
		$escalas = array();
		
		foreach ($raw_escalas as $raw_escala) {
			$concepto = $raw_escala['CONCEPTO'];
			if (empty($concepto)) {
				$concepto = '_vacio_';
			}
			
			$escalas[$raw_escala['ESCALA_NOTAS']][$raw_escala['NOTA']] = array(
				'r' => $raw_escala['RESULTADO'],
				'c'  => $concepto
			);
		}
		
		foreach ($escalas as $key => $escala) {
			$contenido  = "<?php\n";
			//$contenido .= "namespace siu\escalas\ua_".$ua.";\n";
			$contenido .= "class escala_".$key." {\n";
			$contenido .= "		static function get_escala()\n";
			$contenido .= "		{\n";
			$contenido .= "			return ".var_export($escala, true).";\n";
			$contenido .= "		}\n";
			$contenido .= "}";
			//echo $path."/escala_".$key.".php\n";			
			file_put_contents($path."/escala_".$key.".php", $contenido);
		}
	}
	
    static function generar_condiciones_y_resultados()
    {
		$sql ="SELECT *	FROM sga_cond_regular ORDER BY resultado, result_defecto DESC;";
		$raw_condiciones = kernel::db()->consultar($sql);
		
		$condiciones = array();
		foreach ($raw_condiciones as $condicion) {
			$condiciones[$condicion['COND_REGULARIDAD']] = array(
				'cond' => $condicion['COND_REGULARIDAD'], // se repite para acceder más fácilmente desde js
				'desc' => $condicion['DESCRIPCION'],
				'resultado' => $condicion['RESULTADO'],
				'preset' => $condicion['RESULT_DEFECTO']
			);
		}
		
		$resultados = guarani::mapeo_resultados();
		
		$cond_js = kernel::renderer()->json_encode($condiciones);
		$res_js = kernel::renderer()->json_encode($resultados);
		$js = "
			var _condiciones = $cond_js;
			var _resultados = $res_js;
		";
		\kernel\util\manejador_archivos::crear_archivo_con_datos(self::get_path_condiciones(), $js);
    }
}
?>
