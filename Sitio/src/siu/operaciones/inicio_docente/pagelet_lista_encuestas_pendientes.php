<?php

namespace siu\operaciones\inicio_docente;

use kernel\kernel;
use kernel\interfaz\pagelet;

class pagelet_lista_encuestas_pendientes extends pagelet
{
    function get_nombre()
    {
        return 'lista_encuestas_pendientes';
    }

    function prepare()
    {
        $this->data['encuestas_pendientes'] = $this->controlador->info_encuestas_pendientes();
        $this->data['url_operacion_pendientes'] = kernel::vinculador()->crear('encuestas_kolla');

        kernel::log()->add_debug('encuestas_pendientes', $this->data);
    }
}
?>