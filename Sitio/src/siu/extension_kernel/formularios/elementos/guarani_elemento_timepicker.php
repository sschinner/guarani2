<?php

namespace siu\extension_kernel\formularios\elementos;

use kernel\interfaz\componentes\forms\form_elemento_config;
use siu\extension_kernel\formularios\guarani_form_elemento;
use kernel\util\validador;

class guarani_elemento_timepicker extends guarani_form_elemento
{
	private $intervalo = 15;
	
	function __construct($nombre, $def)
	{
		// Seteos por defecto del timepicker
		$def_timepicker = array(
			form_elemento_config::valor_default => null,
			form_elemento_config::filtro		=>  validador::TIPO_TIME,
			form_elemento_config::filtro_params => array('format' => 'H:i', 
														 'allowempty' => true),
			form_elemento_config::elemento		=> array('tipo' => 'select'),
			form_elemento_config::validar_select => true,
			form_elemento_config::clase_css		=> 'timepicker',
		);
		$def = array_merge($def_timepicker, $def);
		parent::__construct($nombre, $def);
	}
		
	function get_multi_options()
	{
		return $this->get_campo_def(form_elemento_config::multi_options, $this->get_horas_minutos($this->nombre, $this->nombre, $this->get_intervalo()));
	}
	
	static function get_horas_minutos($campo_clave, $campo_valor, $intervalo = null, $con_no_seleccion=true)
	{
		$datos = array();
		for($i = 0; $i < 24; $i++){
			for($j = 0; $j < 60; $j=$j+$intervalo){
				$hora = ($i < 10) ? "0".($i) : ($i);
				$min = ($j < 10) ? "0".($j) : ($j);
				$datos[$hora.":".$min] = array($campo_clave => $hora.":".$min, $campo_valor => $hora.":".$min);
			}
		}
		return self::armar_combo_opciones($datos, $campo_clave, $campo_valor, $con_no_seleccion, true, "hh:mm");
	}
	
	function set_intervalo ($intervalo)
	{
		$this->intervalo = $intervalo;
	}
	
	private function get_intervalo ()
	{
		return $this->intervalo;
	}
}
?>