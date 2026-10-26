<?php

namespace siu\operaciones\encuestas_resultados;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_filtros extends pagelet {

    public function get_nombre(){
        return 'filtros';
    }

    function prepare()
    {
        $operacion = kernel::ruteador()->get_id_operacion();
        
        $this->add_var_js('url_buscar_periodos_lectivos_turnos_examen', kernel::vinculador()->crear($operacion, 'buscar_per_lec_tur_exam'));
        $this->add_var_js('url_buscar_materias', kernel::vinculador()->crear($operacion, 'buscar_materias'));
        $this->add_var_js('mensaje_seleccione', kernel::traductor()->trans('actas.filtro_seleccione'));
        $this->add_var_js('url_filtrar', kernel::vinculador()->crear($operacion, 'index'));
        
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
