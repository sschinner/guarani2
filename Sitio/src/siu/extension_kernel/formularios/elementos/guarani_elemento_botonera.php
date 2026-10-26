<?php

namespace siu\extension_kernel\formularios\elementos;

use kernel\interfaz\componentes\forms\elementos\form_elemento_multi;
use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\util\validador;

use siu\extension_kernel\formularios\elementos\guarani_vista_botonera;
use toba;

class guarani_elemento_botonera extends form_elemento_multi
{

	public static function dias_semana(){
		return array(
			'l' => 'Lunes',
			'm' => 'Martes',
			'x' => 'Miercoles',
			'j' => 'Jueves',
			'v' => 'Viernes',
			's' => 'Sabado',
			'd' => 'Domingo',
//			's' => 'sin_definir'
		);
	}

	public static function turnos(){
		$datos = toba::consulta_php('co_comisiones')->get_listado_turnos_cursadas();
		$turnos = array();

		foreach($datos as $d){
			$turnos[$d['valor']] = $d['descr'];
		}
		return $turnos;
	}

	/**
	 * El parametro obligatorio a definir es
	 * form_elemento_config::multi_options => self::dias_semana()
	 *
	 */
	function __construct($nombre, $def)
	{
		$def = array_merge(array(
					form_elemento_config::filtro		=>  validador::TIPO_INT,
					form_elemento_config::validar_select => true,
					form_elemento_config::valor_default => array(),),
				$def);
		parent::__construct($nombre, $def);
	}

}
?>
