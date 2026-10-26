<?php
namespace kernel\util;

use kernel\error_kernel;

class asercion
{
	
	static function no_es_nulo($variable, $texto="ATENCION, el elemento es NULO")
	{
		if(!isset($variable)){
			throw new error_kernel($texto);
		}
	}

	static function es_objeto($instancia, $texto="ATENCION, el elemento no es un OBJETO")
	{
		if(!is_object($instancia)){
			throw new error_kernel($texto);
		}
	}

	static function es_array($array, $texto="ATENCION, el elemento no es un ARRAY", $en_lugar_de=false)
	{
		if(!is_array($array)){
			if ($en_lugar_de) {
				$recibido = var_export($array, true);
				$texto .= "\nEn su lugar se recibio el valor: <pre>$recibido</pre>";
			}
			throw new error_kernel($texto);
		}
	}

	static function array_posee_claves($array_datos, $array_claves, $texto="ATENCION, falta una clave requerida en una array")
	{
		foreach($array_claves as $clave) {
			if (!isset($array_datos[$clave])) {
				throw new error_kernel($texto . "- clave: $clave");
			}
		}
	}
	
	static function arrays_igual_largo($array_1, $array_2, $texto="ATENCION, los arrays no tienen el mismo tamaño")
	{
		self::es_array($array_1,$texto . "- El parametro 1 no es un array");
		self::es_array($array_2,$texto . "- El parametro 2 no es un array");
		if( count($array_1) != count($array_2) ){
			throw new error_kernel($texto);
		}		
	}

	static function es_array_dimension($array, $dimension, $texto="ERROR: ")
	{
		if(!is_array($array)){
			throw new error_kernel($texto . "el elemento no es un ARRAY");
		}else{
			$dim_real = count($array);
			if($dim_real!=$dimension){
				throw new error_kernel($texto . "El tama�o del array es incorrecto: $dim_real (Esperado: $dimension).");
			}
		}
	}

	static function es_array_o_null($array, $texto="ATENCION, el elemento no es un ARRAY y no es NULO")
	{
		if(is_null($array)){
			return;
		}
		if(!is_array($array)){
			throw new error_kernel($texto);
		}
	}

}		
?>