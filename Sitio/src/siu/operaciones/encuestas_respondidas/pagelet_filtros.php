<?php

namespace siu\operaciones\encuestas_respondidas;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_filtros extends pagelet {

    public function get_nombre(){
        return 'filtros';
    }

    function prepare()
    {
        $operacion = kernel::ruteador()->get_id_operacion();

        $this->add_var_js('url_filtrar', kernel::vinculador()->crear($operacion, 'index'));
        $this->add_var_js('url_buscar_materias', kernel::vinculador()->crear($operacion, 'buscar_materias'));
        $this->add_var_js('url_buscar_docentes', kernel::vinculador()->crear($operacion, 'buscar_docentes'));
    }

    function get_js_files()
    {
        $js = parent::get_js_files();
        $archivos = array_merge($js, $this->get_vista_form()->get_js_files());
        return $archivos;
    }

    /**
     * @return guarani_form
     */
    function get_form()
    {
        return $this->get_form_builder()->get_formulario();
    }

    function get_vista_form(){
        return $this->get_form_builder()->get_vista();
    }

    /**
     * @return builder_form_filtro
     */
    function get_form_builder()
    {
        return $this->controlador->get_form_builder();
    }
}