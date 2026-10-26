<?php
namespace siu\operaciones\resumen_cursada;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_filtro extends pagelet {
	public function get_nombre(){
		return 'filtro';
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
    
	function get_periodo()
	{
		return $this->controlador->get_periodo();
	}
    
	function get_anio_academico()
	{
		return $this->controlador->get_anio_academico();
	}

	public function prepare()
	{   
        $operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_buscar_periodos', kernel::vinculador()->crear($operacion, 'buscar_periodos'));
        $this->add_var_js('mensaje_seleccione', kernel::traductor()->trans('actas.filtro_seleccione'));
        
        $periodo_hash = $this->get_periodo();
        $anio_academico_hash = $this->get_anio_academico();
        $this->add_var_js('periodo_hash', $periodo_hash);
        $this->add_var_js('anio_academico_hash', $anio_academico_hash);        
        $this->data['periodo_hash'] = $periodo_hash;
        $this->data['anio_academico_hash'] = $anio_academico_hash;
        $this->data['comisiones'] = $this->controlador->get_comisiones($anio_academico_hash, $periodo_hash);
	}
}
?>