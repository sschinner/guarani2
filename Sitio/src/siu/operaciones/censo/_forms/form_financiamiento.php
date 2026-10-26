<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;

class form_financiamiento extends form_comun
{
	protected $form = 'financiamiento';

	public function init()
	{
		$this->crear_elementos();
	}
}
?>