<?php

namespace siu\extension_kernel\formularios\elementos;


use kernel\interfaz\componentes\forms\elementos\form_elemento_autocomplete;

class guarani_elemento_autocomplete extends form_elemento_autocomplete
{
	function __construct($nombre, $def)
	{
		parent::__construct($nombre, $def);
	}



	/**
	 * @return guarani_vista_autocompletar
	 */
	function get_vista_helper()
	{
		//Overrideo para devolver el subtipo de vista que se usa
		return parent::get_vista_helper();
	}


}
?>
