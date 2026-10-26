<?php
namespace kernel\util;
use memoria\interface_memoria;
use kernel\kernel;

class u
{

	static function unicode_decode($string) 
	{

		$string = preg_replace_callback('#\\\\u([0-9a-f]{4})#ism',
		create_function('$matches', 'return mb_convert_encoding(pack("H*", $matches[1]), "UTF-8", "UCS-2BE");'), 
		$string);

		return $string;

	}
	
    /**
     *
     * @param <type> $obj
     * @return devuelve el nombre de la clase de $obj sin el namespace
     */
    static function get_class($object) {
        if (!is_object($object) && !is_string($object)) {
            return false;
        }

        $class = explode('\\', (is_string($object) ? $object : get_class($object)));
        return $class[count($class) - 1];
    }
    
    static function agregar_dir_include_path($dir)
	{
		$i_path = ini_get("include_path");
		if (substr(PHP_OS, 0, 3) == 'WIN'){
			ini_set("include_path", $i_path . ";.;" . $dir );
		}else{
			ini_set("include_path", $i_path . ":.:" . $dir);
		}
	}
	
	/**
	 * Esta función es vieja, probablemente se desee usar validate_value
	 * @param mixed $valor
	 * @param string $tipo valores posibles: string, int, float, url, string_array, int_array
	 * @param array 
	 *	allow_quotes: boolean
	 *  trim: boolean
	 * @return type 
	 */
	static function sanitize_value($valor, $tipo = 'string', $opciones = array())
	{
		$rs = false;
		switch ($tipo) {
			case 'string': 
				if (isset($opciones['allow_quotes']) && $opciones['allow_quotes']) {
					$s = u::sanitize_string($valor, false, array(
						'flags' => FILTER_FLAG_NO_ENCODE_QUOTES
					));
				} else {
					$s = u::sanitize_string($valor);
				}
				$trim = !isset($opciones['trim']) || $opciones['trim'] !== false; // se trimea por defecto
				return ($trim) ? trim($s) : $s;
			case 'mail': 
				if (filter_var($valor, FILTER_VALIDATE_EMAIL)) {
					return u::sanitize_mail($valor);
				}
				return false;
			case 'int': return u::sanitize_int($valor);
			case 'float': return u::sanitize_float($valor);
			case 'url': return u::sanitize_url($valor);
			case 'string_array': 
				if (empty($valor)) return array();
				$trim = !isset($opciones['trim']) || $opciones['trim'] !== false;
				foreach (array_keys($valor) as $key) {
					$valor[$key] = u::sanitize_string($valor[$key]);
					$valor[$key] = ($trim) ? trim($valor[$key]) : $valor[$key];
				}
				
				return $valor;
			case 'int_array': 
				if (empty($valor)) return array();
				
				foreach (array_keys($valor) as $key) {
					$valor[$key] = u::sanitize_int($valor[$key]);
				}
				
				return $valor;
//			default: throw new \siu\error_guarani("$method param incorrect type: '$type'");
		}
		return '';
	}
	
	static function validate_value($valor, $tipo = 'alpha', $options = array())
	{
		$filter_options = array();
		$flags = '';
		
		if (isset($options['allowempty']) && $options['allowempty']) {
			if (empty($valor)) {
				return '';
			}
		}
		
		switch ($tipo) {
			case 'alpha':
				$filter = FILTER_VALIDATE_REGEXP;
				$filter_options = array('regexp' => "/^[a-zA-Z]+$/");
				break;
			case 'alphanum':
				$filter = FILTER_VALIDATE_REGEXP;
				$filter_options = array('regexp' => "/^[a-zA-Z0-9]+$/");
				break;
			case 'int':
				$filter = FILTER_VALIDATE_INT;
				break;
			case 'date':
				$date = date_parse_from_format($options['format'], $valor);
				if ($date['error_count'] == 0) {
					if (checkdate($date['month'], $date['day'], $date['year'])) {
						return $valor;
					}
				}
				return false;
			case 'time':
				$date = date_parse_from_format($options['format'], $valor);
				if ($date['error_count'] == 0) {
					if (self::checktime($date['hour'], $date['minute'], $date['second'])) {
						return $valor;
					}
				}
				return false;
			case 'custom':
				$filter = FILTER_VALIDATE_REGEXP;
				$format = $options['format'];
				$filter_options = array('regexp' => "/$format$/");
				break;
		}
		
		return filter_var($valor, $filter, array(
			'options' => $filter_options,
			'flags' => $flags
		));
	}
	
	static function checktime($hour, $minute, $seconds = 0) 
	{ 
		if ($hour > -1 && $hour < 24 && $minute > -1 && $minute < 60 && $seconds > -1 && $seconds <60) { 
			return true; 
		} 
		
		return false;
	} 
	
    /**
     * Limpia un string para ser utilizado dentro de algún contexto. Por ej:
     *  $p = u::sanitize($_GET['p'], 'php', 255);
     * @param string $contexto php|html especifica en que contexto va a ser utilizado el string
     * @param string $valor el valor a limpiar
     * @param integer $length largo máximo del valor a retornar
     * @return un string listo para usar de manera segura en $contexto
     */
    static function sanitize($valor, $contexto, $length = false)
    {
        switch ($contexto) {
            case 'php': 
                if ($length !== false) {
                    $valor = mb_substr($valor, 0, $length);
                }
                
                $salida = filter_var($valor, FILTER_SANITIZE_STRING);
                break;
            default:
                throw new \Exception("El contexto '$contexto' no fue definido");
        }
        
        return $salida;
    }
    
    static function sanitize_string($string, $length = false, $options = array())
    {
        if ($length !== false) {
            $string = mb_substr($string, 0, $length);
        }

		return filter_var($string, FILTER_SANITIZE_STRING, $options);
    }
    
    static function sanitize_mail($mail)
    {
        return filter_var($mail, FILTER_SANITIZE_EMAIL);
    }
	
    static function sanitize_int($int)
    {
        return filter_var(intval($int), FILTER_SANITIZE_NUMBER_INT);
    }

	static function sanitize_float($float)
    {
        return filter_var(floatval($float), FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
    }
	
	static function sanitize_url($url)
    {
        return filter_var($url, FILTER_SANITIZE_URL);
    }
    
    
    static function locale_get_lang($locale)
    {
        if (strlen($locale) < 3) {
            return $locale;
        }
        return substr($locale, 0, -strlen(strrchr($locale, '_')));
    }

    /**
     * Genera un string csrf en la memoria pasada por parámetro
     * @param $memoria
     * @param string $sal 
     */
    static function generar_csrf_token($memoria, $sal = '')
    {
        $clave = uniqid();
        $memoria->agregar($clave, true);
        
        return $clave;
    }
    
    /**
     * Chequea la validez de un token csrf en la memoria pasada por parámetro
     * @param $memoria
     * @param string $csrf_token
     */
    static function chequear_csrf_token($memoria, $csrf_token)
    {
        $res = false;
        if ($memoria->tiene($csrf_token)) {
            $res = ($memoria->get($csrf_token) === true);
            $memoria->limpiar($csrf_token);
        }
        
        if (!$res) {
            throw new \kernel\acceso\error_kernel_seguridad("Error de chequeo de csrf [$csrf_token]");
        }
    }
	
	/**
	 * Case insensitive in_array
	 * @param type $needle
	 * @param type $haystack 
	 */
	static function in_arrayi($needle, $haystack)
	{
		foreach ($haystack as $key => $element) {
			if (strtolower($element) == strtolower($needle)) {
				return $key;
			}
		}
		
		return false;
	}
	
	/**
	 * Gets the added elements to $array_1 in $array_2
	 * @param type $array_1
	 * @param type $array_2 
	 */
	static function get_added_elements($array_1, $array_2)
	{
		$rs = array();
		foreach ($array_2 as $element) {
			if (u::in_arrayi($element, $array_1) === false) {
				$rs[] = $element;
			}
		}
		
		return $rs;
	}
	
	/**
	 * Gets the removed elements from $array_1 in $array_2
	 * @param type $array_1
	 * @param type $array_2 
	 */
	static function get_removed_elements($array_1, $array_2)
	{
		$rs = array();
		foreach ($array_1 as $element) {
			if (u::in_arrayi($element, $array_2) === false) {
				$rs[] = $element;
			}
		}
		
		return $rs;
	}
	
	static function update_array($original, $added, $removed)
	{
		$rs = array_merge($original, $added);
		foreach ($removed as $elem) {
			$key = u::in_arrayi($elem, $rs);
			if ($key !== false) {
				unset($rs[$key]);
			}
		}

		return $rs;
	}
	
	static function clear($text) {
		return htmlentities($text, ENT_QUOTES, 'UTF-8');
	}
	
	static function strleft($s1, $s2) 
	{
		return substr($s1, 0, strpos($s1, $s2));
	}
	
	static function relative_time($time = false, $limit = 86400, $format = 'g:i A M jS') {
		if (empty($time) || (!is_string($time) && !is_numeric($time)))
			$time = time(); 
		elseif (is_string($time))
			$time = strtotime($time);

		$now = time();
		$relative = '';

		if ($time === $now)
			$relative = 'now';
		elseif ($time > $now)
			$relative = 'in the future';
		else {
			$diff = $now - $time;

			if ($diff >= $limit)
				$relative = date($format, $time);
			elseif ($diff < 60) {
				$relative = 'less than one minute ago';
			} elseif (($minutes = ceil($diff / 60)) < 60) {
				$relative = $minutes . ' minute' . (((int) $minutes === 1) ? '' : 's') . ' ago';
			} else {
				$hours = ceil($diff / 3600);
				$relative = 'about ' . $hours . ' hour' . (((int) $hours === 1) ? '' : 's') . ' ago';
			}
		}

		return $relative;
	}
	
	/**
	 * dado un string que representa una matriz esta función la devuelve como 
	 * tal. 
	 * @param string $raw el string de entrada
	 * @param array $keys las claves de cada uno de los registros
	 * @param string $sep_reg el separador entre registros
	 * @param string $sep_field el separador entre campos
	 * @return array 
	 */
	static function parse($raw, $keys, $sep_reg = ';,;', $sep_field = ':#:', $debug = false)
	{
		$rs = array();
		if (empty($raw)) {
			return $rs;
		}
		
		$data = explode($sep_reg, $raw);
		if ($debug) {
			kernel::log()->add_debug('DATA', $data);
		}
		foreach ($data as $item) {
			$values = explode($sep_field, $item);
			$rs[] = array_combine($keys, $values);
		}
		
		return $rs;
	}

}

?>
