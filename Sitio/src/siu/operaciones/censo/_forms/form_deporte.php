<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;

class form_deporte extends form_comun
{

	protected $form='deporte';

	public function init()
	{
		$this->crear_elementos();
	}
}
?>