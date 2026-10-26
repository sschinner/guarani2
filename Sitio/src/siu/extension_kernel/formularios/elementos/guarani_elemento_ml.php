<?php

namespace siu\extension_kernel\formularios\elementos;


use kernel\interfaz\componentes\forms\elementos\form_elemento_ml;

class guarani_elemento_ml extends form_elemento_ml
{

	function __construct($nombre)
	{
		parent::__construct($nombre);
	}



	/**
	 * @return guarani_vista_ml
	 */
	function get_vista_helper()
	{
		//Overrideo para devolver el subtipo de vista que se usa
		return parent::get_vista_helper();
	}


}
?>
