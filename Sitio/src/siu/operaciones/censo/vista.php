<?php
namespace siu\operaciones\censo;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function form($id_form, $datos)
	{
		$clase = "operaciones\\censo\\_forms\\form_$id_form";
		if (kernel::localizador()->existe_clase($clase)) {
			$obj = kernel::localizador()->instanciar($clase, array('id'=>$id_form, 'datos'=>$datos));
		} else {
			throw new \siu\errores\error_guarani("El form '$clase' no existe");
		}

		$obj->setView(new \Zend_View());
		return $obj;
	}

	function mostrar($id_form, $datos)
	{
		$form = $this->form($id_form, $datos);

		// guardamos los formularios visitados
		if (kernel::sesion()->esta_seteada('dcensales_form_visitados')) {
			$form_visitados = kernel::sesion()->get('dcensales_form_visitados');
		}
		$form_visitados[$id_form] = true;

		kernel::sesion()->set('dcensales_form_visitados', $form_visitados);

		$this->pagelet('formulario')->set_form($form);
	}

	function get_action_confirmar() 
	{
		return kernel::vinculador()->crear('censo', 'confirmar');
	}
	
	function get_form_actual() 
	{
		return $this->controlador->get_var('form_actual');
	}
	
	function ini()
	{
	//        $clase = 'operaciones\censo\pagelet_acciones';
	//		$pl = kernel::localizador()->instanciar($clase, 'acciones');
	//        $this->add_pagelet($pl);

		$clase = 'operaciones\censo\pagelet_lista_forms';
		$pl = kernel::localizador()->instanciar($clase, 'lista_forms');
		$this->add_pagelet($pl);

		$clase = 'operaciones\censo\pagelet_formulario';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
		$this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_datos_censales"));
	}
}
?>