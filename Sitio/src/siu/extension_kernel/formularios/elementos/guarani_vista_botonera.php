<?php

namespace siu\extension_kernel\formularios\elementos;


use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\vista_elemento;

class guarani_vista_botonera implements vista_elemento {


	public function render(form_elemento $elemento){
		 $elem = $elemento->get_zend_element();

		 return "<div class='botonera btn-group' id='{$elem->getId()}'>".$elem->renderViewHelper() ."</div>"; //$elemento->get_zend_element()->renderViewHelper();
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