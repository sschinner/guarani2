<?php
namespace siu\operaciones\mensajes;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_envio_mensaje extends vista_g3w2
{
	function ini()
	{
		$this->set_template('template_envio_mensaje');

		$clase = 'operaciones\mensajes\pagelet_envio_mensajes';
		$pl = kernel::localizador()->instanciar($clase, 'envio_mensajes');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_mensajes_enviar"));
	}
}
?>