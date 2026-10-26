<?php
namespace kernel\interfaz\componentes\forms;


use kernel\error_kernel;
use kernel\kernel;

abstract class form
{
	protected $campos = array();
	protected $acciones = array();

	protected $id_html;
	protected $action;
	protected $csrf = false;
	protected $csrf_key = false;

	//protected $vista; //TODO: sacar, y usar el helper.
	protected $zend_form_util;
	protected $tiene_datos = false;

	protected $inicializado = false;

	function __construct()
	{
		//$this->vista = new vista_form_bootstrap();
		$this->zend_form_util = new zend_form_util();
	}

	function set_id_html($id_html){
		$this->id_html = $id_html;
	}

	function get_id_html(){
		return $this->id_html;
	}

	function set_action($action){
		$this->action = $action;
	}
	function get_action(){
		return $this->action;
	}

	public function get_campos()
	{
		if (!$this->inicializado){
			throw new error_kernel("Aun no se inicializo el formulario");
		}
		return $this->campos;
	}

	public function get_acciones()
	{
		if (!$this->inicializado){
			throw new error_kernel("Aun no se inicializo el formulario");
		}
		return $this->acciones;
	}

	//protected abstract function generar_definicion();

	public function add_elemento(form_elemento $elemento)
	{
		if ($this->inicializado && isset($this->campos[$elemento->get_nombre()])) {
			// ya se agregó el elemento, probablemente en el procesar(). No hay
			// que reemplazarlo ya que contiene data sobre los posibles errores
			return $elemento;
		}
		if (isset($this->campos[$elemento->get_nombre()])) {
			kernel::log()->add_php_warning("El campo '{$elemento->get_nombre()}' se agregó más de una vez en el form '{$this->get_id_html()}'");
		}
		$this->campos[$elemento->get_nombre()] = $elemento;
		$elemento->added_to_form($this->get_id_html());
		return $elemento;
	}

	function add_accion(form_accion $accion){
		$this->acciones[] = $accion;
		return $accion;
	}

	function inicializar()
	{
		//$this->generar_definicion();
		$this->init_zend_form();
		$this->inicializado = true;
	}

	/**
	 * @param string $fuente POST o GET
	 * @throws \kernel\error_kernel si la fuente no es valida
	 * @return bool
	 */
	function procesar($fuente = 'POST')
	{
		$this->inicializar();
		if($fuente == 'POST'){
			$this->set_datos_desde_post();
		}else if ($fuente == 'GET'){
			$this->set_datos_desde_get();
		}else{
			throw new error_kernel("Solo se puede procesar un form desde POST o GET");
		}

		return $this->validar();
	}

	function evt_pre_render()
	{
		foreach ($this->campos as $campo) {
			$campo->evt_pre_render();
		}
	}
	
	/**
	 *
	 * @param array $datos arreglo asociativo donde la clave es el nombre del campo
	 * y el valor es el valor que aparecerá en el elemento
	 */
	function set_datos($datos)
	{
		foreach ($this->campos as $nombre => $campo) {
			if ($campo->tiene_group()) {
				$grupo = $campo->get_group();
				if (isset($datos[$grupo]) && isset($datos[$grupo][$nombre])) {
					$valor = $datos[$grupo][$nombre];
					$campo->set_valor($valor);
				}
			} else {
				if (isset($datos[$nombre])) {
					$valor = $datos[$nombre];
					$campo->set_valor($valor);
				}
			}

		}

		$this->tiene_datos = true;
	}

	function set_datos_desde_post()
	{
		$this->set_datos_desde_fuente($_POST, 'POST');

//		$id_form = $this->get_id_html();
//		if ($id_form != '' && !isset($_POST[$id_form])) {
//			throw new error_kernel("No existe el formulario '$id_form' en el post");
//		}
//
//		if(empty($id_form)){
//			$this->set_datos_arreglo($_POST);
//
//		}else {
//			$this->set_datos_arreglo($_POST[$id_form]);
//		}
//
//		$this->tiene_datos = true;
	}

	function set_datos_desde_get()
	{
		$this->set_datos_desde_fuente($_GET, 'GET');
	}

	private function set_datos_desde_fuente($fuente, $desc)
	{
		$id_form = $this->get_id_html();
		if (!empty($id_form) && !isset($fuente[$id_form])) {
			throw new error_kernel("No existe el formulario '$id_form' en el $desc");
		}
		$datos = empty($id_form)? $fuente: $fuente[$id_form];
		$this->set_datos_arreglo($datos);
		$this->refrescar_campos_fijos();
		$this->tiene_datos = true;
	}

	private function refrescar_campos_fijos()
	{
		foreach ($this->campos as $campo) {
			if ($campo instanceof elementos\form_elemento_fijo) {
				$campo->set_valor_desde_sesion();
			}
		}
	}

	private function set_datos_arreglo($datos)
	{
		foreach ($this->campos as $nombre => $campo) {
			if ($campo->tiene_group()) {
				$grupo = $campo->get_group();
				if (isset($datos[$grupo]) && isset($datos[$grupo][$nombre])) {
					$valor = $datos[$grupo][$nombre];
                    if((kernel::proyecto()->get_encoding() != 'utf-8') && mb_detect_encoding($valor, 'UTF-8', true)){
                        $valor = utf8_decode($valor);
                    }
					$campo->set_valor_desde_post($valor);
				}
			} else {
				if (isset($datos[$nombre])) {
					$valor = $datos[$nombre];
                    //Este if se agrego debido a que si en la url venia una query string con acentos...
                    //dichos acentos eran reemplazados por caracteres extraños por un problema de encoding...
                    //el problema se daba al querer recuperar los valores de un filtro a traves de una query string con acentos.
                    if((kernel::proyecto()->get_encoding() != 'utf-8') && mb_detect_encoding($valor, 'UTF-8', true)){
                        $valor = utf8_decode($valor);
                    }
					$campo->set_valor_desde_post($valor);
				}
			}
		}

//		foreach ($this->campos as $nombre => $campo) {
//			if ($campo->tiene_group()) {
//				$grupo = $campo->get_group();
//				if (isset($_POST[$id_form][$grupo]) && isset($_POST[$id_form][$grupo][$nombre])) {
//					$valor = $_POST[$id_form][$grupo][$nombre];
//					$campo->set_valor_desde_post($valor);
//				}
//			} else {
//				if (isset($_POST[$id_form][$nombre])) {
//					$valor = $_POST[$id_form][$nombre];
//					$campo->set_valor_desde_post($valor);
//				}
//			}
//		}
	}

	function validar()
	{
		$form_valido = true;
		foreach ($this->campos as $campo) {
			$valido = $campo->validar();
			if (!$valido) {
				$form_valido = false;
				kernel::log()->add_debug("FALLA FORM VALIDAR {$this->get_id_html()}", $campo->get_nombre());
			}
		}
		return $form_valido;
	}

	function desactivar_campo($nombre)
	{
		$this->get_campo($nombre)->set_activo(false);
	}

	function tiene_datos()
	{
		return $this->tiene_datos;
	}

	function get_datos()
	{
		$datos = array();
		foreach ($this->campos as $nombre => $campo) {
			if ($campo->tiene_group()) {
				$grupo = $campo->get_group();
				$datos[$grupo][$nombre] = $campo->get_valor();
			} else {
				$datos[$nombre] = $campo->get_valor();
			}
		}

		return $datos;
	}

	function get_campos_grupo($grupo)
	{
		$campos_grupo = array();
		foreach ($this->campos as $campo) {
			if ($campo->get_group($campo) == $grupo) {
				$campos_grupo[] = $campo;
			}
		}

		return $campos_grupo;
	}

	/**
	 *
	 * @param type $nombre
	 * @return form_elemento
	 * @throws error_kernel
	 */
	protected function get_campo($nombre)
	{
		if (isset($this->campos[$nombre])) {
			return $this->campos[$nombre];
		}

		throw new error_kernel("El campo '$nombre' no existe en el formulario");
	}


	function tiene_error($nombre)
	{
		return $this->get_campo($nombre)->tiene_error();
	}

	function tiene_errores()
	{
		return !empty($this->errores);
	}

	function activar_csrf($key)
	{
		$this->csrf = true;
		$this->csrf_key = $key;
	}

	function desactivar_csrf()
	{
		$this->csrf = false;
	}

	public function csrf_activo()
	{
		return $this->csrf;
	}

	public function get_csrf_key()
	{
		return $this->csrf_key;
	}

	/**
	 * @param string $nombre
	 * @param string $msg
	 */
	function agregar_error($nombre, $msg)
	{
		$this->get_campo($nombre)->set_error($msg);
	}

	protected function init_zend_form($force = false)
	{
		if ($this->inicializado && !$force) {
			return;
		}

		$this->zend_form_util->populate_fields($this->get_id_html(), $this->campos);
	}
	
	/*
	 * Se setea desde fuera del form xq puede haber un error de validación al guardar en 
	 * la base, que por ahora no se hace dentro del form.
	 */
	function set_hubo_error($hubo_error)
	{
		foreach ($this->campos as $campo) {
			$campo->set_hubo_error_form($hubo_error);
		}
	}
}

?>
