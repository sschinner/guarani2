<?php
namespace siu\modelo\controles;
use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\modelo\datos\catalogo;

abstract class punto_control
{
	protected $id;
	protected $parametros;
			
	abstract function utiliza_unidad_academica();
	abstract function lista_parametros();
	abstract function info();
	abstract function info_parametros();

	function __construct($id)
	{
		$this->id = $id;
	}
	
	function get_id()
	{
		return $this->id;
	}

	/**
	 * @todo: falta la validacion de tipos de parametro
	 */
	function set_parametros($parametros, $operacion, $evento)
	{
		// Parametros automaticos
		if ($this->utiliza_unidad_academica()) {
			$parametros['unidad_academica'] = guarani::ua()->get_id();
		}
		// Validacion
		foreach($this->lista_parametros() as $p) {
			if(!isset($parametros[$p])) {
				throw new error_guarani('Puntos de control: parametros incorrectos, falta: ' . $p);
			}
		}
		$this->parametros = $parametros;
		$this->operacion = $operacion;
		$this->evento = $evento;
	}

	function get_controles()
	{
		$info_controles = array();
		if(!isset($this->operacion)||!isset($this->evento)||!isset($this->parametros)) {
			throw new error_guarani('PUNTO de CONTROL: No hay parametros');
		}		
		// recuperar controles
		$parametros = array('operacion' => $this->operacion,
							'evento' => $this->evento, 
							'punto_control' => $this->id);
		$cache = array();
		//$cache[catalogo::cache_config_tipo] = \kernel\util\cache\admin_cache::tipo_no;
		//$cache[catalogo::cache_config_expiracion] = 20;		
		$controles = catalogo::consultar('sistema', 'controles_activos_punto', $parametros, $cache);
		// La pregunta que sigue es porque la base devuelve un registro "No hay controles"
		$hay_controles = isset($controles[0][0]) && isset($controles[0][1]) &&  
							$controles[0][0] != 0 && $controles[0][1] != 0;
		if ($hay_controles) {
			// Disparar controles asociados
			foreach($controles as $control) {
				 $info_controles[] = array( 'punto' => $this->id,
											'control' => $control[1],
											'actua_como' => $control[3],
											'cacheable' => $control[6],
											'store_procedure' => $control[2],
											'parametros' => $this->parametros,
											'metadata_parametros'=>$this->lista_parametros()
									 );
			}
		}
		return $info_controles;
	}
}
?>