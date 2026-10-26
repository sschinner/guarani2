<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;

class form_estudios extends form_comun
{
	protected $form = 'estudios';

	public function init()
	{
		$this->crear_elementos();
	}
}
?>