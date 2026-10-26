<?php

namespace siu\extension_kernel\formularios;

use siu\guarani;


abstract class builder_filtro extends builder_formulario {


	protected function instanciar_vista_formulario()
	{
		$vista =  parent::instanciar_vista_formulario();
		$vista->get_salida()->set_horizontal()->set_es_minimizable(true);

		return $vista;
	}


}