<?php
namespace kernel\interfaz;

use kernel\acceso\menu;
use kernel\kernel;
use kernel\nucleo\recursos;
use kernel\interfaz\vistas\vista_error;

class pagina implements unidad_renderizacion
{
    protected $etiquetas;
    /**
     * @var kernel\interfaz\vista
     */
    protected $vista;

    function __construct()
    {
        $this->etiquetas = array();
		$this->registrar_dir_templates();
    }
	
	protected function registrar_dir_templates()
	{
		$path_dir_templates = recursos::get_dir_proyecto_templates();
		$paths = kernel::localizador()->get_paths_dir($path_dir_templates);
		foreach ($paths as $path) {
			kernel::agregar_path_templates($path);
		}
	}

    function set_vista($vista)
    {
        $this->vista = $vista;
    }
    function get_vista()
    {
        return $this->vista;
    }
	
    function set_etiqueta($id, $contenido)
    {
        $this->etiquetas[$id] = $contenido;
    }

    function get_etiqueta($id)
    {
        return $this->etiquetas[$id];
    }

    function get_titulo_completo()
    {
        return $this->get_etiqueta('titulo');
    }
    
    function get_css()
    {
        
    }
    
    protected function get_nombre_template()
    {
		if (kernel::proyecto()->es_pipe_nav()) {
			return 'pipe.twig';
		} else {
			return 'full.twig';
		}
    }

    /**
     * @return menu
     */
    protected function get_menu_desde_conf()
    {
        /**
         * @var $menu menu
         */
        $menu = kernel::persona()->perfil()->get_menu();

        return $menu;
    }

    protected function get_menu()
    {
        $menu = $this->get_menu_desde_conf();

        if ($menu->esta_vacio()) {
            return array();
        }

        $menu_preparado = array();

        foreach ($menu as $key_item => $data) {
            $tmp = array();

			if ($menu->tiene_submenu($key_item)) {

                $submenues = explode("|", $key_item);
                $key_item = current($submenues);

                $seleccionado = false;
                $this->armar_submenu($submenues, $tmp, $menu_preparado, $data, $seleccionado);
                $tmp['seleccionado'] = $seleccionado;

			} else {
				$nombre_op = $data['nombre_operacion'];
				$tmp['id'] = $nombre_op;
				$tmp['url'] = kernel::vinculador()->crear($nombre_op);
				$tmp['nombre'] = ($data['texto'] != '') ? $data['texto'] : 'header.menu.'.$nombre_op;
				$tmp['tiene_submenu'] = false;
                $tmp['seleccionado'] = $nombre_op == kernel::ruteador()->get_id_operacion();
			}

			$menu_preparado[$key_item] = $tmp;
        }

        return $menu_preparado;
    }

    protected function armar_submenu($submenues, &$tmp, &$menu_preparado, $data, &$seleccionado){

        //Tomo el submenu actual
        $submenu = array_shift($submenues);

        //Si existe el item en el menu
        if(isset($menu_preparado[$submenu])){
            $tmp = $menu_preparado[$submenu];
            if(isset($tmp['seleccionado'])) $seleccionado = $tmp['seleccionado'];
        }
        else{//Si no existe el item en el menu
            $tmp['submenu'] = array();
            $tmp['nombre'] = "header.menu.{$submenu}";
        }

        //si es el ultimo submenu de la jerarquia
        if(count($submenues) == 0){

            if(!isset($tmp['submenues'])) $tmp['submenues'] = array();

            foreach ($data as $key_subitem => $data_subitem) {
                $nombre_op = $data_subitem['nombre_operacion'];
                $tmp['submenu'][] = array(
                    'id' => $nombre_op,
                    'url' => kernel::vinculador()->crear($nombre_op),
                    'nombre' => ($data_subitem['texto'] != '') ? $data_subitem['texto'] : "header.menu.{$nombre_op}",
                );
                if ($nombre_op == kernel::ruteador()->get_id_operacion()) {
                    $seleccionado = true;
                }
            }

            return true;
        }
        else{

            $siguiente_nivel = current($submenues);
            $tmp['submenues'][] = $siguiente_nivel;
            $tmp['submenues'] = array_values(array_unique($tmp['submenues']));
            if(!isset($tmp[$siguiente_nivel])) $tmp[$siguiente_nivel] = array();
            $this->armar_submenu($submenues, $tmp[$siguiente_nivel], $menu_preparado[$submenu], $data, $seleccionado);

        }

    }

    protected function get_info_persona()
    {
        if (! kernel::sesion()->abierta()) {
            return array('logueada' => false);
        }
        return array(
            'logueada' => true,
//            'url_logout' => kernel::vinculador()->crear('acceso', 'logout'),
            'nombre' => kernel::persona()->get_nombre()
        );
    }
    
    protected function get_template()
    {
        $nombre = $this->get_nombre_template();
        return kernel::load_template($nombre);
    }
	
	protected function get_template_header()
	{
		$path_dir_templates = recursos::get_dir_proyecto_templates();
		$desc_archivo = kernel::localizador()->encontrar_template($path_dir_templates, 'header');
		return $desc_archivo['nombre'];
	}

	protected function get_template_footer()
	{
		$path_dir_templates = recursos::get_dir_proyecto_templates();
		$desc_archivo = kernel::localizador()->encontrar_template($path_dir_templates, 'footer');
		return $desc_archivo['nombre'];
	}

	protected function get_template_res()
	{
		$path_dir_templates = recursos::get_dir_proyecto_templates();
		$desc_archivo = kernel::localizador()->encontrar_template($path_dir_templates, 'res');
		return $desc_archivo['nombre'];
	}
    
    protected function get_contexto_template()
    {
        $url_recursos = (kernel::proyecto()->get_produccion()) ? kernel::proyecto()->get_url_recursos() : '';
        $url_base = kernel::proyecto()->get_alias();

        return array(
            'etiquetas' => $this->etiquetas,
			'template_header' => $this->get_template_header(),
			'template_footer' => $this->get_template_footer(),
			'template_res' => $this->get_template_res(),
            'persona' => $this->get_info_persona(),
			'produccion' => kernel::proyecto()->get_produccion(),
			'ajax_nav' => kernel::proyecto()->get_ajax_nav(),
			'alias' => kernel::proyecto()->get_alias(),
			'pretty_urls' => (kernel::usa_pretty_urls()) ? 'true' : 'false',
            'menu' => $this->get_menu(),
            'url_recursos' => $url_recursos,
            'url_base' => $url_base,
			'encoding' => kernel::proyecto()->get_encoding(),
			'es_browser' => kernel::agente()->es_browser(),
            'es_celular' => kernel::agente()->es_celular(),
            'vista' => $this->vista,
            'op_default' => kernel::persona()->perfil()->get_parametro('index'),
            'op_actual' => kernel::ruteador()->get_id_operacion(),
            'titulo' => $this->get_titulo_completo()
        );
    }
    
    function render()
    {
        $tp = $this->get_template();                                                                
        $tp->display($this->get_contexto_template());

    }

	function render_error($mensaje)
	{
		if($this->get_vista() != null){
			$this->get_vista()->add_error($mensaje);
			$this->render();
		}else {
			echo "<pre>";
			print_r($mensaje);
			echo "</pre";
		}

//		$this->set_vista(new vista_error($mensaje));
	}
}
?>
