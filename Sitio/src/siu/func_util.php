<?php

if (!function_exists('utf8_decode')) {
	function utf8_decode($data) {
		return $data;
	}
}
if (!function_exists('utf8_encode')) {
	function utf8_encode($data) {
		return $data;
	}
}

if (!defined('MB_CASE_UPPER')) {
	define('MB_CASE_UPPER', 0);
}
if (!defined('MB_CASE_LOWER')) {
	define('MB_CASE_LOWER', 1);
}
if (!defined('MB_CASE_TITLE')) {
	define('MB_CASE_TITLE', 2);
}

if (!function_exists('mb_strtolower')) {
	function mb_strtolower($str, $encoding = null) {
		return strtolower($str);
	}
}
if (!function_exists('mb_strtoupper')) {
	function mb_strtoupper($str, $encoding = null) {
		return strtoupper($str);
	}
}
if (!function_exists('mb_substr')) {
	function mb_substr($str, $start, $length = null, $encoding = null) {
		if ($length === null) {
			return substr($str, $start);
		}
		return substr($str, $start, $length);
	}
}
if (!function_exists('mb_strlen')) {
	function mb_strlen($str, $encoding = null) {
		return strlen($str);
	}
}
if (!function_exists('mb_strpos')) {
	function mb_strpos($haystack, $needle, $offset = 0, $encoding = null) {
		return strpos($haystack, $needle, $offset);
	}
}
if (!function_exists('mb_stripos')) {
	function mb_stripos($haystack, $needle, $offset = 0, $encoding = null) {
		return stripos($haystack, $needle, $offset);
	}
}
if (!function_exists('mb_substr_count')) {
	function mb_substr_count($haystack, $needle, $encoding = null) {
		return substr_count($haystack, $needle);
	}
}
if (!function_exists('mb_convert_case')) {
	function mb_convert_case($str, $mode = MB_CASE_UPPER, $encoding = null) {
		if ($mode == MB_CASE_UPPER) {
			return strtoupper($str);
		} elseif ($mode == MB_CASE_LOWER) {
			return strtolower($str);
		} elseif ($mode == MB_CASE_TITLE) {
			return ucwords(strtolower($str));
		}
		return $str;
	}
}
if (!function_exists('mb_internal_encoding')) {
	function mb_internal_encoding($encoding = null) {
		if ($encoding === null) {
			return ini_get('default_charset') ? ini_get('default_charset') : 'ISO-8859-1';
		}
		return true;
	}
}
if (!function_exists('mb_get_info')) {
	function mb_get_info($type = 'all') {
		return $type == 'all' ? array() : false;
	}
}
if (!function_exists('mb_detect_encoding')) {
	function mb_detect_encoding($str, $encoding_list = null, $strict = false) {
		return 'ISO-8859-1';
	}
}
if (!function_exists('mb_split')) {
	function mb_split($pattern, $string, $limit = -1) {
		return preg_split('/' . str_replace('/', '\/', $pattern) . '/u', $string, $limit);
	}
}
if (!function_exists('mb_ereg')) {
	function mb_ereg($pattern, $string, $regs = null) {
		if ($regs !== null) {
			return preg_match('/' . $pattern . '/u', $string, $regs);
		}
		return preg_match('/' . $pattern . '/u', $string);
	}
}
if (!function_exists('mb_eregi')) {
	function mb_eregi($pattern, $string, $regs = null) {
		if ($regs !== null) {
			return preg_match('/' . $pattern . '/iu', $string, $regs);
		}
		return preg_match('/' . $pattern . '/iu', $string);
	}
}
if (!function_exists('mb_ereg_replace')) {
	function mb_ereg_replace($pattern, $replacement, $string, $option = 'msr') {
		return preg_replace('/' . $pattern . '/u' . (strpos($option, 'i') !== false ? 'i' : ''), $replacement, $string);
	}
}

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
 * una llamada est�tica a una clase que puede estar personalizada
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
	if (!is_array($arreglo)) {
		if (is_string($arreglo)) {
			if (function_exists('utf8_decode')) {
				return utf8_decode($arreglo);
			}
			return $arreglo;
		}
		return $arreglo;
	}
	$salida = array();
	foreach ($arreglo as $clave => $valor) {
		if (is_array($valor)) {
			$salida[$clave] = array_a_latin1($valor);
		} elseif (is_string($valor)) {
			if (function_exists('utf8_decode')) {
				$salida[$clave] = utf8_decode($valor);
			} else {
				$salida[$clave] = $valor;
			}
		} else {
			$salida[$clave] = $valor;
		}
	}
	return $salida;
}

function array_a_utf8($datos){
	if (is_string($datos)) {
		if (function_exists('utf8_encode')) {
			return utf8_encode($datos);
		}
		return $datos;
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
