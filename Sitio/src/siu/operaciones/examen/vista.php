<?php

namespace siu\operaciones\examen;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;
use siu\modelo\entidades\parametro;

class vista extends vista_g3w2 {

    protected $hay_mensajes = false;
    protected $error = false;

    function ini() {
        $clase = 'operaciones\examen\pagelet_info_materia_examen';
        $pl = kernel::localizador()->instanciar($clase, 'info_materia_examen');
        $this->add_pagelet($pl, 20);

        $clase = 'operaciones\_comun\pagelets\pagelet_lista_materias';
        $pl = kernel::localizador()->instanciar($clase, 'lista_materias');
        
        $filtra_planes = (parametro::rendir_regul_planes_anteriores() == "S") ? true : false;
        $pl->set_filtrar_planes($filtra_planes);
        $this->add_pagelet($pl, 10);

        $notif_activa = parametro::usa_asignacion_horaria() == 'S';
        if (kernel::agente()->es_browser() && $notif_activa) {
            $clase = 'operaciones\_comun\pagelets\pagelet_notificaciones';
            $pl = kernel::localizador()->instanciar($clase, 'notificaciones');
            $this->add_pagelet($pl, 0);
        }

        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans('tit_inscripcion_examen'));
    }

    function set_error($error) {
        $this->error = $error;
    }

    function set_hay_mensajes($hay_mensajes) {
        $this->hay_mensajes = $hay_mensajes;
    }

    protected function before_render() {
        $this->agregar_a_contexto('hay_mensajes', $this->hay_mensajes);
        if ($this->hay_mensajes) {
            // se buscan en el controlador que es donde se generan
            $this->agregar_a_contexto('mensajes', $this->controlador->get_var('mensajes'));
        }

        $this->agregar_a_contexto('error', $this->error);
    }

    /**
     * Se agrega una función en especial para poder desactivar la renderización
     * en caso de haya error
     * @param type $nombre 
     */
    function render_pagelet($nombre) {
        if (!$this->error) {
            return $this->pagelet($nombre)->render();
        }

        return '';
    }

}

?>