<?php
namespace siu\operaciones\censo_docente;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function form($id_form, $datos) 
	{
		$clase = "operaciones\\censo_docente\\_forms\\form_$id_form";
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
        $this->pagelet('formulario')->set_form($form);
	}
	
    function ini()
    {
        $clase = 'operaciones\censo_docente\pagelet_formulario';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);
		
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_datos_censales"));
    }
}
?>