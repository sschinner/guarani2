<?php
namespace siu\operaciones\encuestas_kolla;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {
		$pendientes = kernel::persona()->get_encuestas_pendientes();

		if (!empty($pendientes))
		{
            $clase = 'operaciones\encuestas_kolla\pagelet_listado_encuestas';
            $pl = kernel::localizador()->instanciar($clase, 'listado_encuestas');
            $this->add_pagelet($pl);

            $clase = 'operaciones\encuestas_kolla\pagelet_encuesta';
            $pl = kernel::localizador()->instanciar($clase, 'encuesta');
            $this->add_pagelet($pl);
		}
		else {
			$this->set_template('template_vacio');
		}
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_encuestas_kolla"));	
	
    }
}
?>