<?php
namespace kernel\interfaz;

use kernel\kernel;
use kernel\nucleo\controlador;
use kernel\nucleo\recursos;
use kernel\interfaz\vistas\parte_vista_pagelet;
use kernel\util\modelo\decorador_entidad;
use kernel\util\u;

abstract class pagelet implements unidad_renderizacion_ajax, parte_vista_pagelet
{
	const MODO_SKELETON = 0;
	const MODO_CONTENIDO = 1;
	const MODO_COMPLETO = 2;
	public $data = array();

	/**
	 * Estado interno del pagelet, a partir de este estado se deciden los datos
	 * que se van a mostrar en el pagelet
	 */
	public $estado = 'inicial';

	/**
	 * A partir de este modo se decide si se renderiza:
	 *  * MODO_SKELETON: sólo el div que contiene al pagelet
	 *  * MODO_CONTENIDO: sólo el contenido del pagelet
	 *  * MODO_COMPLETO: el div con el contenido adentro
	 */
	public $modo = self::MODO_CONTENIDO;
	/**
	 * @var controlador
	 */
	protected $controlador;

	/**
	 * @var \kernel\util\memoria\memoria_sesion
	 */
	protected $memoria;

	protected $is_empty = false;
	protected $is_visible = true;

	protected $mensajes_js = array();
	protected $vars_js = array();

	protected $overwritten_template;

	protected $prioridad = 0;

	protected $hay_archivo_js;

	protected $codigo_response = 1;

	protected $forms = array();

	function __construct($id)
	{
		$this->set_id($id);
		$this->registrar_dir_templates();
		$this->ini();
	}

	protected function add_form($form)
	{
		$this->forms[$form->get_id_html()] = $form;
	}

	function get_form($id_html)
	{
		return $this->forms[$id_html];
	}

	protected function registrar_dir_templates()
	{
		$path_dir_templates = $this->get_dir_op();
		$paths = kernel::localizador()->get_paths_dir($path_dir_templates);
		foreach ($paths as $path) {
			kernel::agregar_path_templates($path);
		}
	}

	protected function get_dir_op()
	{
		return recursos::get_dir_op($this->get_operacion_fisica());
	}

	protected function get_dir()
	{
		return recursos::get_dir_pagelet($this->get_operacion_fisica(), $this->get_nombre());
	}

	protected function ini()
	{
	}


	/**
	 *
	 * @return \kernel\util\memoria\memoria_sesion
	 */
	function memoria()
	{
		return $this->memoria;
	}

	function set_controlador($controlador)
	{
		$this->controlador = $controlador;
	}

	function get_id()
	{
		return $this->id;
	}

	/**
	 * Este método debe ser utilizado con cuidado ya que deja inaccesible
	 * la memoria en sesión que escribió este pagelet
	 */
	function set_id($id)
	{
		$this->id = $id;
		$this->memoria = new \kernel\util\memoria\memoria_sesion($this->id);
	}

	function set_estado_info($id)
	{
		$this->estado = $id;
	}

	function get_estado()
	{
		return $this->estado;
	}

	function set_modo($modo)
	{
		$this->modo = $modo;
	}

//    function get_nombre()
//    {
//        return u::get_class($this);
//    }

	abstract function get_nombre();

	protected function get_contexto()
	{
		return array(
			'this' => $this
		);
	}

	/**
	 * Define si el pagelet va a ser visible desde un principio o va a ser
	 * mostrado con código javascript
	 * @param boolean $visible
	 */
	function set_visible($visible)
	{
		$this->is_visible = $visible;
	}

	function is_visible()
	{
		return $this->is_visible;
	}

	function render()
	{
		$contexto = $this->get_contexto();

		if ($this->modo == self::MODO_SKELETON) {
			$contexto['modo'] = 'skeleton';
		} else {
			if ($this->modo == self::MODO_CONTENIDO) {
				$contexto['modo'] = 'contenido';
			} else {
				$contexto['modo'] = 'completo';
			}
			$this->exec_prepare();
			foreach ($this->data as $key => $data) {
				$contexto[$key] = $data;
			}
		}
		if ($this->is_empty()) { // no se muestra nada
			return '';
		}

		$template = $this->get_template();
		$template->display($contexto);
	}

	function render_ajax()
	{
		$contexto = $this->get_contexto();
		$contexto['modo'] = 'completo'; // en ajax siempre se renderiza completo

		$this->exec_prepare();
		foreach ($this->data as $key => $data) {
			$contexto[$key] = $data;
		}

		$cont = $this->get_template()->render($contexto);
		echo kernel::renderer()->get_respuesta_json($this->get_codigo_response(), $cont);
	}

	protected function get_codigo_response()
	{
		return $this->codigo_response;
	}

	function set_prioridad($prioridad)
	{
		$this->prioridad = $prioridad;
	}

	function get_prioridad()
	{
		return $this->prioridad;
	}

	function get_js_info()
	{
		$info = array(
			'id' => $this->get_id(),
			'visible' => $this->is_visible(),
			'estado' => $this->estado,
			'mensajes' => $this->mensajes_js
		);
		return array_merge($info, $this->vars_js);
	}

	/**
	 * @param boolean $return si es verdadero se retorna en vez de renderizarse
	 * @return string json para incluirse en la página
	 */
	function render_pipe($return = false)
	{
		if ($this->is_empty()) { // no se muestra nada
			return '';
		}

		$object = array(
			'css' => $this->get_css_files(),
			'js' => $this->get_js_files(),
			'op' => $this->get_operacion_fisica(),
			'info' => $this->get_js_info(),
			'content' => $this->get_content(),
			'clase_js' => $this->get_nombre_clase_js(),
			'tiene_archivo_js' => $this->hay_archivo_js
		);

		$json_object = kernel::renderer()->json_encode($object);

		$str = "<script type='text/javascript'>";
		$str .= "kernel.renderer.on_arrival($json_object);";
		$str .= "</script>";

		if (!$return) {
			echo $str;
		} else {
			return $str;
		}
	}

	function is_empty()
	{
		return $this->is_empty;
	}

	protected function set_empty($empty)
	{
		$this->is_empty = $empty;
	}

	protected function set_template($template)
	{
		$this->overwritten_template = $template;
	}

	/**
	 * @return string nombre del template correspondiente al pagelet
	 */
	function get_nombre_tp($con_extension = true)
	{
		if (isset($this->overwritten_template)) {
			return $this->overwritten_template;
		}
//        $nombre  = $this->get_nombre();
//        $nombre .= ($this->estado == 0) ? '' : "_$this->estado";
		/**
		 * @todo el nombre depende del modo
		 */
		$nombre = 'default';
		if ($con_extension) {
			return $nombre . '.twig';
		} else {
			return $nombre;
		}

	}

	/**
	 * Devuelve el nombre de la operación que contiene físicamente al pagelet
	 * @return type
	 */
	protected function get_operacion_fisica()
	{
		return kernel::ruteador()->get_id_operacion();
	}

	/**
	 *
	 * @return \Twig_Template
	 */
	protected function get_template()
	{
		$path_dir_templates = $this->get_dir_op();
		$nombre = $this->get_nombre() . '/' . $this->get_nombre_tp(false);

		$desc_archivo = kernel::localizador()->encontrar_template($path_dir_templates, $nombre);
		return kernel::load_template($desc_archivo['nombre']);
	}


	function get_content()
	{
		$template = $this->get_template();
		return $template->render($this->get_contexto());
	}

	public function get_css_files()
	{
		$op = $this->get_operacion_fisica();
		return kernel::vinculador()->vinculos_css_pagelet($op, $this->get_nombre());
	}

	public function get_js_files()
	{
		$op = $this->get_operacion_fisica();
		$url = kernel::vinculador()->vinculo_js_pagelet($op, $this->get_nombre());
		if ($url == false) {
			$this->hay_archivo_js = false;
			return array();
		} else {
			$this->hay_archivo_js = true;
			return array($url);
		}
	}

	function add_var_js($key, $valor)
	{
		$this->vars_js[$key] = $valor;
	}

	function isset_var_js($key)
	{
		return isset($this->vars_js[$key]);
	}

	/**
	 * Agrega un mensaje que viajará al cliente en el objeto javascript
	 */
	function add_mensaje_js($key, $valor)
	{
		$this->mensajes_js[$key] = $valor;
	}

	public function get_nombre_clase_js()
	{
		return $this->get_nombre();
	}

	public function exec_prepare()
	{
		$this->prepare();
	}

	abstract function prepare();


	function generar_csrf($key = '')
	{
		return $this->controlador->generar_csrf($key);
	}

	function es_mobile()
	{
		return !kernel::agente()->es_browser();
	}

	//-----------------------------------------------------------------------
	// UTILITARIOS TWIG - this.[nombre_funcion]
	//-----------------------------------------------------------------------

	function tiene_acceso_link($link)
	{
		return $link != decorador_entidad::$link_vacio;
	}

	function data_link($link)
	{
		if ($link == decorador_entidad::$link_vacio) {
			return "class= 'data-no-acceso'";
		} else {
			return "data-link='$link' class='link-in-data'";
		}
	}

	function a($href, $inner_html, $class = '', $data = array())
	{
        if(!isset($data['placement'])) $data['placement'] = 'top';
        if(!isset($data['toggle'])) $data['toggle'] = 'tooltip';
        if(!isset($data['original-title'])) $data['original-title'] = kernel::traductor()->trans('no_tenes_derechos');

        $data_attr = "";
        foreach ($data as $id => $value) {
            $data_attr .= " data-$id= '$value'";
        }

		if ($href == decorador_entidad::$link_vacio) {
			return "<span class='link-no-acceso disabled $class' $data_attr>$inner_html</span>";
		} else {
			return "<a href='$href' class='link-acceso $class' $data_attr>$inner_html</a>";
		}
	}


}

?>
