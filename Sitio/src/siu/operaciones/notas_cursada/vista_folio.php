<?php
namespace siu\operaciones\notas_cursada;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_folio extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_folio');
		
		$clase = 'operaciones\notas_cursada\pagelet_cabecera';
		$pl = kernel::localizador()->instanciar($clase, 'cabecera');
		$this->add_pagelet($pl);

		$clase = 'operaciones\notas_cursada\pagelet_herramientas';
		$pl = kernel::localizador()->instanciar($clase, 'herramientas');
		$this->add_pagelet($pl);
		
		$clase = 'operaciones\notas_cursada\pagelet_renglones';
		$pl = kernel::localizador()->instanciar($clase, 'renglones');
		$this->add_pagelet($pl);

		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->agregar_a_contexto('url_back', kernel::vinculador()->crear($operacion));
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_notas_cursada"));
    }

}

?>