<?php
namespace siu\operaciones\asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;

class pagelet_planilla extends pagelet
{
 
	public $filtros = array('cantidad' => '', 'fecha' => '','tipo' => '', 'tipo_clase' =>'');
        const ESTADO_FILTRO = 'filtro';
	const ESTADO_PLANILLA = 'planilla';
	
	protected $pantalla = 'filtro';	

function get_nombre()
    {
        return 'planilla';
    }
	
	function get_js_files()
	{
		$js = parent::get_js_files();
		$archivos = array_merge($js, $this->get_vista_form()->get_js_files());
        $archivos[] = kernel::vinculador()->vinculo_recurso("js/date-es-AR.js");
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
	
	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
                $this->pantalla = self::ESTADO_PLANILLA;
	}

	public function get_filtros(){
		return $this->filtros;
	}
	
	public function get_comision_hash(){
		return $this->controlador->comision_hash;
	}

	function prepare()
	{
            $operacion = kernel::ruteador()->get_id_operacion();
            $this->data['planilla'] = $this->controlador->get_planilla($this->pantalla, $this->get_filtros());
            $filtros = $this->get_filtros();
            $this->data['filtro_cantidad'] = $filtros['cantidad'];
            $this->data['filtro_tipo_clase'] = $this->controlador->tipo_clase;
            $this->data['modo'] = $this->pantalla;
            $link = kernel::vinculador()->crear($operacion, 'generar_pdf');
            $this->data['url']['generar_pdf'] = $link;
            $this->add_var_js('comision_hash', $this->controlador->comision_hash);           
            $this->add_var_js('subcomision', $this->controlador->subcomision_id);           
            $this->add_var_js('tipo_clase', $this->controlador->tipo_clase);           
            $this->add_var_js('tipo_clase_desc', $this->controlador->tipo_clase_desc);           
            $this->add_var_js('modo', $this->pantalla);           
	}
        
  }      
?>