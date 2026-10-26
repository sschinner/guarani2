<?php

namespace kernel\interfaz\componentes\forms;

interface vista_elemento
{

	public function render(form_elemento $elemento);

	/**
	 * @return boolean Dice si tambien dibuja la etiqueta. Si no la dibuja, se la dibuja
	 * la vista.
	 */
	public function renderiza_label();


}