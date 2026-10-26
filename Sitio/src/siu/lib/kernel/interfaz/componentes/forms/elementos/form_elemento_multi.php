<?php

namespace kernel\interfaz\componentes\forms\elementos;

use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;

class form_elemento_multi extends form_elemento
{
	protected $html;

	function __construct($nombre, $def)
	{
		parent::__construct($nombre, $def);
		$this->def[form_elemento_config::elemento] = array('tipo' => 'multicheckbox');
	}


}

?>
