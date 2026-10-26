<?php

function klog($var)
{
	static $_log_count = 0;
	\kernel\kernel::log()->add_debug("LOG #$_log_count", $var);
	$_log_count++;
}

function klog2($nombre, $var)
{
	\kernel\kernel::log()->add_debug($nombre, $var);
}

function trans($id,$params=array())
{
	return \kernel\kernel::traductor()->trans($id, $params);
}

/**
 * Alias de kernel::localizador()->invocacion_estatica. Se utiliza para realizar
 * una llamada estática a una clase que puede estar personalizada
 * @param string $clase
 * @param string $metodo
 * @param mixed $params
 * @return mixed
 */
function estatica($clase, $metodo, $params = array())
{
	return \kernel\kernel::localizador()->invocacion_estatica($clase, $metodo,$params);
}

function constante($clase, $nombre)
{
	return \kernel\kernel::localizador()->constante($clase, $nombre);
}

function convertir_fecha_formato_base($fecha)
{
	$date = \date_parse_from_format('d/m/Y', $fecha);
	return $date['year'].'-'.$date['month'].'-'.$date['day'];
}

function convertir_fecha_formato_frontend($fecha)
{
	$date = \date_parse_from_format('Y-m-d', $fecha);
	$dia = ($date['day'] < 10) ? '0'.$date['day'] : $date['day'];
	$mes = ($date['month'] < 10) ? '0'.$date['month'] : $date['month'];
	$anio = $date['year'];
	return $dia.'/'.$mes.'/'.$anio;
}

function a_minusculas($cadena)
{
	$cadena = trim($cadena);
	return mb_convert_case($cadena, MB_CASE_LOWER, \kernel\kernel::proyecto()->get_encoding());
}

function capitalizar($cadena)
{
	return mb_convert_case($cadena, MB_CASE_TITLE, \kernel\kernel::proyecto()->get_encoding());
}


/** Transforma un json o arreglo en utf8 a un arreglo en latin1 */
function rest_decode($datos)
{
	if(is_string($datos) ){
		$datos = json_decode($datos);
	} //es un json ya decodificada guzzle->response->json
	return array_a_latin1($datos);
}

/** Transforma un arreglo en latin1 a un json en utf8 */
function rest_encode($datos)
{
	$array = array_a_utf8($datos);
	return json_encode($array);
}

function array_a_latin1($arreglo)
{
	$salida = array();
	foreach ($arreglo as $clave => $valor) {
		if (is_array($valor)) {
			$salida[$clave] = array_a_latin1($valor);
		} elseif (is_string($valor)) {
			$salida[$clave] = utf8_decode($valor);
		} else {
			$salida[$clave] = $valor;
		}
	}
	return $salida;
}

function array_a_utf8($datos){
	if (is_string($datos)) {
		return utf8_encode($datos);
	}
	if (!is_array($datos)) {
		return $datos;
	}
	$ret = array();
	foreach ($datos as $i => $d) {
		$ret[$i] = array_a_utf8($d);
	}
	return $ret;
}


?>
