<?php
namespace siu\operaciones\asistencias;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_edicion_asistencias extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_edicion_asistencias');
		
		$clase = 'operaciones\asistencias\pagelet_cabecera';
		$pl = kernel::localizador()->instanciar($clase, 'cabecera');
		$this->add_pagelet($pl, 1);
		
		$clase = 'operaciones\asistencias\pagelet_edicion_asistencias';
		$pl = kernel::localizador()->instanciar($clase, 'edicion_asistencias');
		$this->add_pagelet($pl, 0);
		
		
		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->agregar_a_contexto('url_back', kernel::vinculador()->crear($operacion));
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_asistencia_edicion"));
    }
}

?>