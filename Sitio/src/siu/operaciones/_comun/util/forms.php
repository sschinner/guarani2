<?php
namespace siu\operaciones\_comun\util;
use siu\errores\error_guarani;

class forms 
{
	const SELECT_ID_NULO = '';
	
	static function rs_to_select($datos, $opcion_nula='')
	{
		if($opcion_nula) {
			$array_resultado = array(self::SELECT_ID_NULO => $opcion_nula);
		}
		$cant = count($datos);
		for($i = 0; $i < $cant; $i++){
			$array_resultado[$datos[$i]['ID']] = $datos[$i]['DESC'];
		}
		return $array_resultado;	
	}
}

?>