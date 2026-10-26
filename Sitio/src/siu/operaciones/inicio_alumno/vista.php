<?php
namespace siu\operaciones\inicio_alumno;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;
use siu\modelo\entidades\parametro;

class vista extends vista_g3w2
{
    function ini()
    {
		$clase = 'operaciones\inicio_alumno\pagelet_lista_carreras';
		$pl = kernel::localizador()->instanciar($clase, 'lista_carreras');
        $this->add_pagelet($pl);
		
		$clase = 'operaciones\inicio_alumno\pagelet_lista_encuestas_pendientes';
		$pl = kernel::localizador()->instanciar($clase, 'lista_encuestas_pendientes');
		$this->add_pagelet($pl);

		$clase = 'operaciones\inicio_alumno\pagelet_lista_noticias';
        $pl = kernel::localizador()->instanciar($clase, 'lista_noticias');
        $this->add_pagelet($pl);
		
		$notif_activa = parametro::usa_asignacion_horaria() == 'S';
		if (kernel::agente()->es_browser() && $notif_activa) {
			$clase = 'operaciones\_comun\pagelets\pagelet_notificaciones';
			$pl = kernel::localizador()->instanciar($clase, 'notificaciones');
			$this->add_pagelet($pl);
		}
		
//		$this->data['periodos_lectivos'] =
				
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_inicio_alumno"));
    }
}

?>