<?php

namespace siu\operaciones\_comun\pagelets;

use \kernel\interfaz\pagelet;
use \kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_lista_materias extends pagelet {
    private $filtra_planes = false;
            
    protected function get_operacion_fisica() {
        return '_comun/pagelets';
    }

    function get_nombre() {
        return 'lista_materias';
    }

    function get_js_files() {
        $archivos = parent::get_js_files();
        $archivos[] = kernel::vinculador()->vinculo_recurso("js/filtro_lista.js");
        return $archivos;
    }

    function set_filtrar_planes($valor = false){
        $this->filtra_planes = $valor;
    }
    
    function get_filtrar_planes(){
        return $this->filtra_planes;
    }
    
    function prepare() {
        $modelo = $this->controlador->modelo();
        
        $lista_materias = $modelo->info__lista_materias();
        
        $this->data = $lista_materias;
        $operacion = kernel::ruteador()->get_id_operacion();

        if ($this->controlador->hay_var('materia')) {
            $materia = $this->controlador->get_var('materia');
        } else {
            $materia = '';
        }

        foreach ($this->data as $key => $dato) {
            $this->data[$key]['SELECCIONADA'] = $materia == $dato[catalogo::id];
            $this->data[$key]['URL_MATERIA'] = kernel::vinculador()->crear($operacion, 'elegir_materia', $dato[catalogo::id]);
        }
        
        // activa el filtro por planes en la vista
        $this->add_var_js('filtra_planes', $this->get_filtrar_planes());
    }
    
}

?>
