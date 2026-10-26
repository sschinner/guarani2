<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;

class form_discapacidad extends form_comun
{
	protected $form = 'discapacidad';

	public function init()
	{
		$this->crear_elementos();
	}
}
?>