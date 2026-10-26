<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;

class form_trabajo extends form_comun
{
	protected $form = 'trabajo';

	public function init()
	{
		$this->crear_elementos();
	}
}
?>