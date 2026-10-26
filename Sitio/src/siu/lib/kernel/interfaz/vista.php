<?php
namespace kernel\interfaz;

use kernel\kernel;
use kernel\nucleo\recursos;

abstract class vista implements unidad_renderizacion
{
    protected $contexto;
    protected $controlador;
    protected $forms = array();
    protected $template = 'template';
    protected $js_vars = array();
	protected $error;
	
    function __construct()
    {
		// Se inicializa el contexto con una referencia a la vista para que 
		// pueda ser referenciada desde el template
        $this->contexto = array(
			'this' => $this
		);
		$this->registrar_dir_templates();
		$this->ini();
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
		$op = kernel::ruteador()->get_id_operacion();
		return recursos::get_dir_op($op);
	}
	
	
    function set_controlador($controlador)
    {
        $this->controlador = $controlador;
    }
    
	abstract function ini();

	function add_var_js($nombre, $valor)
	{
		if (! isset($this->contexto['js_vars'])) {
			$this->contexto['js_vars'] = array();
		}
		$this->contexto['js_vars'][$nombre] = $valor;
	}
	
    function get_tipo()
    {
        return 'vista';
    }
	    
    function set_contexto($contexto)
    {
        $this->contexto = $contexto;
    }
    
    function set_template($nombre)
    {
        $this->template = $nombre;
    }
    
    function add_mensaje($clave, $msg, $variables = array())
    {
        if (!isset($this->contexto['mensajes'])) {
            $this->contexto['mensajes'] = array();
        }
        
        $this->contexto['mensajes'][$clave]['valor'] = $msg;
        foreach ($variables as $key => $value) {
            $this->contexto['mensajes'][$clave][$key] = $value;
        }
    }
    
	function agregar_a_contexto($clave, $valor)
	{
		$this->contexto[$clave] = $valor;
	}
	
    /**
     * Devuelve el contexto del template de la vista de la operación
     */
	protected function get_contexto()
    {
        return $this->contexto;
    }
    
    protected function get_template()
    {
		$desc_archivo = kernel::localizador()->encontrar_template($this->get_dir_op(), $this->template);
        return kernel::load_template($desc_archivo['nombre']);
    }
    
    /**
     *
     * @param type $id_form
     * @return \Zend_Form
     */
    function form($id_form) 
    {
		if (!isset($this->forms[$id_form])) {
			throw new \kernel\error_kernel("Debe agregar el form '$id_form' con el método add_form('$id_form') antes de solicitarlo");
		}
        return $this->forms[$id_form];
    }
    
	protected function get_clase_form($id_form)
	{
		$op = kernel::ruteador()->get_id_operacion();
        $clase = "operaciones\\$op\\form_$id_form";
		return $clase;
	}
	
    /**
     * @param string $id_form
     * @return \Zend_Form 
     */
    function add_form($id_form)
    {
        $clase = $this->get_clase_form($id_form);
        
		if (kernel::localizador()->existe_clase($clase)) {
            $obj = kernel::localizador()->instanciar($clase, $id_form);
        } else {
			$obj = new \Zend_Form();
		}
		
		$obj->setView(new \Zend_View());
        $this->forms[$id_form] = $obj;
		return $obj;
    }
    
    protected function init_forms()
	{
		foreach ($this->forms as $key => $form) {
            $this->contexto['form_'.$key] = $form->render();
        }
	}
	
    function render()
    {
		$this->init_forms();
        $this->get_template()->display($this->get_contexto());
    }
	
	function render_ajax()
	{
		$this->init_forms();
		$cont = $this->get_template()->render($this->get_contexto());
        echo kernel::renderer()->get_respuesta_json(1, $cont, array(
            'titulo' => kernel::pagina()->get_titulo_completo(),
            'operacion' => kernel::ruteador()->get_id_operacion()
        ));
	}
	
	function get_css_resources()
	{
		return '';
	}
	
	function get_js_resources()
	{
		return '';
	}
	
	function add_error($mensaje)
	{
		$this->error = $mensaje;
		$this->contexto['_error'] = $mensaje;
	}
	
	function hubo_error()
	{
		return isset($this->error);
	}
	
	function get_error()
	{
		return $this->error;
	}
}
?>
