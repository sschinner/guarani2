<?php
namespace siu\conf;
use kernel\util\validador;
use siu\modelo\datos\catalogo;

class definicion_datos_censales_docente
{
    const filtro = 'filtro';
    const filtro_params = 'filtro_params';
    const largo = 'largo';
    const obligatorio = 'obligatorio';
	const label = 'label';
	const clase_css = 'clase_css';
	const elemento = 'elemento_html';
	const sub_form = 'subform';
	const multiOptions = 'multiOptions';
	const nombre = 'nombre';
	const format = 'format';
	
	static protected $definicion_tabla;
	
    static protected $def = array (
		
		// --------------------   SUB_FORM PRINCIPALES---------------------------------		
		'CENS_CALLE_PER_LECT' => array(	self::filtro => validador::TIPO_TEXTO,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
			
									),
		'CENS_NUMERO_PER_LECT' => array(    self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
										),
		
		'CENS_PISO_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),
		
        'CENS_DPTO_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),
		
        'CENS_UNIDAD_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
									),
		
		'CENS_LOC_PER_LECT_TEXTO' => array (self::obligatorio => false,
											self::elemento => array('nombre' => 'text',
																	'readonly' => true),
											self::sub_form => 'principales',
			
											),
		'CENS_LOC_PER_LECT'		=> array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'hidden'),
											self::sub_form => 'principales'
										),
		'CENS_CP_PER_LECT' => array(	self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text',  
																'readonly' => true),
										self::sub_form => 'principales'
									),
		'CENS_TE_PER_LECT' => array(    self::filtro => validador::TIPO_CUSTOM,
				                        self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
										self::format => '^[0-9\s\(\)\-]{0,18}'),
		
		'AUX1_CELULAR_NUMERO' => array(	self::filtro => validador::TIPO_CUSTOM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
										self::format => '^[0-9\s\(\)\-]{0,18}'),
		
		'AUX1_CELULAR_COMPANIA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'principales')
		);
		
	static function hay_campo($campo)
	{
		return isset(static::$def[$campo]);
	}
	
	static function es_campo_a_validar($campo)
	{
		if (isset(static::$def[$campo]) && isset(static::$def[$campo][static::filtro])) {
			return true;
		}
		return false;
	}
	
    static function get_campo($campo)
    {
		if (!isset(static::$definicion_tabla) || empty(static::$definicion_tabla)) {
			static::$definicion_tabla = catalogo::consultar('datos_censales', 'get_definicion_campos', array()); 
		}
        if (isset(static::$def[$campo])) {
			$def_campo = static::$def[$campo];
			// se obtiene el largo del campo y lo seteo para limitar los input
			foreach (static::$definicion_tabla as $definicion) {
				if (strtoupper($definicion['COLNAME']) == substr($campo,5)) {
					if ( $definicion['COLTYPE'] == 2) {
						// 2 es el tipo entero pero la definicion de informix pone 'COLLENGTH' = 4
						$def_campo['largo'] = 6;
					} else {
						$def_campo['largo'] = $definicion['COLLENGTH'];
					}
				}
			}
            return $def_campo;
        }
		throw new \siu\errores\error_guarani("DEFINICION DATOS CENSALES: campo '$campo' no está definido");
	}
	
	static function get_campos($sub_formulario) 
	{
		$retorno = array();
		foreach(static::$def as $campo_nombre => $campo) {
			if($campo[static::sub_form] == $sub_formulario) {
				$retorno[] = $campo_nombre;
			}
			
		}
		return $retorno;
	}
	
	static function get_def()
	{
		return static::$def;
	}
	
}