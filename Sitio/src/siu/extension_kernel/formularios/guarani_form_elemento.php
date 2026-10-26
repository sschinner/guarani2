<?php

namespace siu\extension_kernel\formularios;

use kernel\interfaz\componentes\forms\form_elemento;
use kernel\kernel;
use siu\extension_kernel\formularios\elementos\guarani_vista_default;

class guarani_form_elemento extends form_elemento
{
	const NO_SELECCION	= NULL;

	function __construct($nombre, $def)
	{
		parent::__construct($nombre, $def);
	}

	static function armar_combo_opciones($datos, $campo_clave, $campo_valor, $con_no_seleccion=true, $omitir_no_seleccion_opcion_unica=true, $mensaje_no_seleccion = "")
	{
		$combo = array();
		if (!empty($datos)) {
			if (($con_no_seleccion) && ((count($datos) > 1) || ((count($datos) <= 1) && !$omitir_no_seleccion_opcion_unica) )) {
				if (!empty($mensaje_no_seleccion)){
					$combo[self::NO_SELECCION] = $mensaje_no_seleccion;
				} else {
					$combo[self::NO_SELECCION] = kernel::traductor()->trans('descr_no_seleccion');
				}
			}
			foreach ($datos as $dato) {
				$combo[$dato[$campo_clave]] = $dato[$campo_valor];
			}
		}
		return $combo;
	}
}
?>