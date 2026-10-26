<?php
namespace siu\operaciones\configuracion;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function ini()
	{
		$clase = 'operaciones\configuracion\pagelet_configuraciones';
		$pl = kernel::localizador()->instanciar($clase, 'configuraciones');
		$this->add_pagelet($pl);

		$clase = 'operaciones\configuracion\pagelet_cuentas_externas';
		$pl = kernel::localizador()->instanciar($clase, 'cuentas_externas');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_configuracion"));
	}
}
?>