<?php
namespace siu\operaciones\inicio_docente;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_actas extends vista_g3w2
{
    function ini()
    {
		$this->set_template('template_vista_actas');
		
		$clase = 'operaciones\inicio_docente\pagelet_actas';
		$pl = kernel::localizador()->instanciar($clase, 'actas');
		$this->add_pagelet($pl);
		
		$clase = 'operaciones\inicio_docente\pagelet_comisiones';
		$pl = kernel::localizador()->instanciar($clase, 'comisiones');
		$this->add_pagelet($pl);

        $clase = 'operaciones\inicio_docente\pagelet_lista_encuestas_pendientes';
        $pl = kernel::localizador()->instanciar($clase, 'lista_encuestas_pendientes');
        $this->add_pagelet($pl);
		
//		$clase = 'operaciones\inicio_docente\pagelet_actas_examen';
//		$pl = kernel::localizador()->instanciar($clase, 'actas_examen');
//		$this->add_pagelet($pl);
//		
//		$clase = 'operaciones\inicio_docente\pagelet_reporte';
//		$pl = kernel::localizador()->instanciar($clase, 'reporte');
//		$this->add_pagelet($pl);
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_inicio_docente"));
    }

}

?>