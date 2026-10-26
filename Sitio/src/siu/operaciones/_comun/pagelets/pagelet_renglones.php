<?php
namespace siu\operaciones\_comun\pagelets;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

abstract class pagelet_renglones extends pagelet
{
	const MAX_CARACTERES_CORREGIDO_POR= 20;
	
	protected $encabezado;
	protected $renglon = false;
	/**
	 * @var \siu\errores\error_guarani_procesar_renglones 
	 */
	protected $errores = false;
	
	protected function get_encabezado()
	{
		if (! isset($this->encabezado)) {
			$this->encabezado = $this->controlador->get_encabezado();
		}
		
		return $this->encabezado;
	}
	
	function get_js_files()
	{
		$archivos = parent::get_js_files();
		
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/plugin_renglones.js");
		
		$acceso= kernel::proyecto()->get_bloque_acceso(); 
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/escalas/$acceso/cond_res.js");
		
		return $archivos;
	}
	
	function set_highlight($renglon)
	{
		$this->renglon = $renglon;
	}
	
	function set_error_guarani_procesar_renglones(\siu\errores\error_guarani_procesar_renglones $e) 
	{
		$this->errores = $e;
	}
	abstract protected function get_escala();
	abstract protected function get_url_guardar();
	
	
	protected function get_escala_notas()
	{
		$encabezado = $this->get_encabezado();
		return $this->controlador->modelo()->info__escala_notas($encabezado['ESCALA_NOTAS']);
	}
	
	function prepare() 
	{
		$this->data = array();
		$this->data['escala_notas'] = $this->get_escala_notas();
		$this->data['renglones'] = $this->get_renglones();
		$this->data['url_guardar'] = $this->get_url_guardar();
		$this->add_var_js('highlight_renglon', $this->renglon);
		
		$this->add_var_js('max_textarea', pagelet_renglones::MAX_CARACTERES_CORREGIDO_POR);
		
		$notas = $this->controlador->get_escala_js();
		$this->add_var_js('escala', $notas);
	}
}
?>
