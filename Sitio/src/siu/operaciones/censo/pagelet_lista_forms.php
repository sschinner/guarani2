<?php
namespace siu\operaciones\censo;
use \kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_lista_forms extends pagelet
{
	public $actual_form = "";
	private $menu_items = array(
		array(
			'form' => 'principales'
			),
		array(
			'form' => 'financiamiento'
			),
		array(
			'form' => 'trabajo'
			),
		array(
			'form' => 'padres'
			),
		array(
			'form' => 'estudios'
			),
		array(
			'form' => 'tecnologia'
			),
		array(
			'form' => 'deporte'
			),
		array(
			'form' => 'idioma'
			)
	);

	function get_nombre()
	{
		return 'lista_forms';
	}

	function get_menu()
	{
		$operacion = kernel::ruteador()->get_id_operacion();

		$menu = $this->menu_items;
		$faltantes = $this->controlador->get_campos_faltantes();
		$visitados = array();
		
		foreach($menu as $key => $value) {
			$form = $value['form'];
			$menu[$key]['nombre'] = ucfirst(kernel::traductor()->trans('censo.menu_'.$form));
			$menu[$key]['url'] = kernel::vinculador()->crear($operacion, 'index', $form);
			$menu[$key]['con_faltantes'] = isset($faltantes[$form]);
			
			if ($this->controlador->modo_reinscripcion()) {
				$visitados = $this->controlador->get_forms_visitados();
				if (isset($visitados[$form])) {
					$menu[$key]['visitado'] = true;
				}
			}
		
		}
		
		return $menu;
	}

	function prepare()
	{
		$this->data['form_actual'] = $this->controlador->get_var('form_actual');
		$this->data['url_imgs'] = kernel::vinculador()->vinculo_recurso('img');
		$this->data['menu'] = $this->get_menu();
		$this->data['visitados'] = $this->controlador->get_forms_visitados();

		if ($this->controlador->modo_reinscripcion()) {
			$this->data['modo_reinscripcion'] = true;
			$this->add_var_js('modo_reinscripcion', true);
		}

		$this->add_var_js('url_reinscripcion', kernel::vinculador()->crear('reinscripcion', 'reinscribir'));

		$this->add_var_js('se_perderan_datos', kernel::traductor()->trans('censo.se_perderan_datos'));

		$this->add_var_js('reinscripcion_mensaje', kernel::traductor()->trans('reinscripcion_mensaje'));
		$this->add_var_js('reinscripcion_verificacion_completa', kernel::traductor()->trans('reinscripcion_verificacion_completa'));
		$this->add_var_js('reinscripcion_completa', kernel::traductor()->trans('reinscripcion_completa'));
        
        $this->data['url_form_discapacidad'] = kernel::vinculador()->crear('censo', 'datos_discapacidad');
	}
}
?>