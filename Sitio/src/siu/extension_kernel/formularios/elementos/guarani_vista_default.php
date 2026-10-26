<?php

namespace siu\extension_kernel\formularios\elementos;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\vista_elemento;


/**
 * Una vista que wrappea al renderer default de los formularios por si se quiere extender/cambiar a futuro o para usar
 * con un decorador, etc.
 * Class guarani_vista_default
 * @package siu\extension_kernel\formularios\elementos
 */
class guarani_vista_default implements vista_elemento {


	public function render(form_elemento $elemento){
		return $elemento->get_zend_element()->renderViewHelper();

	}


	/**
	 * @return boolean Dice si tambien dibuja la etiqueta. Si no la dibuja, se la dibuja
	 * la vista.
	 */
	public function renderiza_label()
	{
		return false;
	}
}