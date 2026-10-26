<?php
namespace kernel\util;

class validador {
	const TIPO_ALPHA	= 1;
	const TIPO_ALPHANUM = 2;
	const TIPO_INT		= 3;
	const TIPO_DATE		= 4;
	const TIPO_TIME		= 5;
	const TIPO_CUSTOM	= 6;
	const TIPO_MAIL		= 7;
	const TIPO_TEXTO	= 8;
	
	const TIPO_ARRAY_ALPHA		= 101;
	const TIPO_ARRAY_ALPHANUM	= 102;
	const TIPO_ARRAY_INT		= 103;
	const TIPO_ARRAY_DATE		= 104;
	const TIPO_ARRAY_TIME		= 105;
	const TIPO_ARRAY_CUSTOM		= 106;
	const TIPO_ARRAY_MAIL		= 107;
	const TIPO_ARRAY_TEXTO		= 108;

	const MAIL_MAX_LENGTH = 127;
//	$subconmisiones = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM, array(
//		'es_array' => true
//	));
    
    static function es_valido($valor, $tipo = self::TIPO_ALPHA, $options = array())
    {
        $valor = self::validar($valor, $tipo, $options);
        return $valor !== false;
    }
    
	static function validar($valor, $tipo = self::TIPO_ALPHA, $options = array())
	{
		$filter_options = array();
		$flags = '';
		
		if (empty($valor)) {
			if (isset($options['allowempty']) && $options['allowempty']) {
				return $valor;
			} else if (array_key_exists('default', $options)) {
				return $options['default'];
			}
		}
		
		switch ($tipo) {
			case ($tipo >= self::TIPO_ARRAY_ALPHA):
				return self::validar_array($valor, $tipo % 100);
				break;
			case self::TIPO_ALPHA:
				$filter = FILTER_VALIDATE_REGEXP;
				$filter_options = array('regexp' => "/^[a-zA-Z]+$/");
				break;
			case self::TIPO_ALPHANUM:
				$filter = FILTER_VALIDATE_REGEXP;
				$filter_options = array('regexp' => "/^[a-zA-Z0-9]+$/");
				break;
			case self::TIPO_INT:
				$is_integer = is_integer($valor);
				$all_digits = ctype_digit($valor);
				return ($is_integer || $all_digits) ? $valor : false;
//				$filter = FILTER_VALIDATE_INT;
//				$filter_options = array(
//					'min_range' => -9223372036854775808,
//					'max_range' => 9223372036854775807
//				);
//				break;
			case self::TIPO_MAIL:
				$filter = FILTER_VALIDATE_EMAIL;
				if (strlen($valor) > self::MAIL_MAX_LENGTH) {
					return false;
				}
				break;
			case self::TIPO_TEXTO:
				return $valor;
				break;
			case self::TIPO_DATE:
				$date = date_parse_from_format($options['format'], $valor);
				if ($date['error_count'] == 0) {
					if (checkdate($date['month'], $date['day'], $date['year'])) {
						return $valor;
					}
				}
				return false;
			case self::TIPO_TIME:
				$date = date_parse_from_format($options['format'], $valor);
				if ($date['error_count'] == 0) {
					if (self::checktime($date['hour'], $date['minute'], $date['second'])) {
						return $valor;
					}
				}
				return false;
			case self::TIPO_CUSTOM:
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
	
	protected static function validar_array($valores, $tipo)
	{
		foreach ($valores as $valor) {
			$rs = self::validar($valor, $tipo);
			if ($rs === false) {
				return false;
			}
		}
		
		return $valores;
	}
	
	static function const_name($value) 
	{
        $x = $value;
        $fooClass = new \ReflectionClass ( '\kernel\util\validador' );
        $constants = $fooClass->getConstants();

        $constName = null;
        foreach ( $constants as $name => $value )
        {
                if ( $value == $x )
                {
                        $constName = $name;
                        break;
                }
        }

        return $constName;
    }
}

?>
