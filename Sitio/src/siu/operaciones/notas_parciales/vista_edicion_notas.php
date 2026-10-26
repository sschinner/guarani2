<?php
namespace siu\operaciones\notas_parciales;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_edicion_notas extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_edicion_notas');
		
		$clase = 'operaciones\notas_parciales\pagelet_cabecera';
		$pl = kernel::localizador()->instanciar($clase, 'cabecera');
		$this->add_pagelet($pl);
		$pl->set_estado_info(pagelet_cabecera::ESTADO_EDICION);
		
		$clase = 'operaciones\notas_parciales\pagelet_herramientas';
		$pl = kernel::localizador()->instanciar($clase, 'herramientas');
		$this->add_pagelet($pl);
		
		$clase = 'operaciones\notas_parciales\pagelet_edicion_notas';
		$pl = kernel::localizador()->instanciar($clase, 'edicion_notas');
		$this->add_pagelet($pl);
		
		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->agregar_a_contexto('url_back', kernel::vinculador()->crear($operacion));
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_notas_parcial_edicion"));
    }
}

?>