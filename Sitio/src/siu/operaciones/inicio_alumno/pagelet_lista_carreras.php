<?php

namespace siu\operaciones\inicio_alumno;

use kernel\kernel;
use kernel\interfaz\pagelet;

class pagelet_lista_carreras extends pagelet
{
    function get_nombre()
    {
        return 'lista_carreras';
    }

    function prepare()
    {
		$this->data['periodos_lectivos'] = $this->controlador->info_periodos_lectivos();
		$this->data['turnos_examen'] = $this->controlador->info_turnos_examen();
        kernel::log()->add_debug('carreras', $this->data);
    }
}
?>