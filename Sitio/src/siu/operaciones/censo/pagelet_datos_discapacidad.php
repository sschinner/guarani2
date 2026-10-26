<?php
namespace siu\operaciones\censo;

use kernel\kernel;
use kernel\util\modelo\procesador_vista;
use kernel\util\u;
use kernel\interfaz\pagelet;
use siu\modelo\datos\catalogo;


class pagelet_datos_discapacidad extends pagelet
{
    const ESTADO_LISTADO = 'listado';
	const ESTADO_EDICION = 'edicion';
	
	protected $pantalla = 'listado';

	function set_pantalla($id)
	{
        $this->pantalla = $id;
	}
	
	function get_accion_edicion()
	{
		return kernel::vinculador()->crear('censo', 'discapacidad_agregar');
	}
	
	function get_accion_volver_edicion()
	{
		return kernel::vinculador()->crear('censo', 'datos_discapacidad');
	}
    
	public function get_nombre()
	{
		return 'datos_discapacidad';
	}

	function get_js_files()
	{
		$archivos = parent::get_js_files();
		$archivos = array_merge($this->get_vista_form()->get_js_files(), $archivos);
		return $archivos;
	}

	public function get_vista_form()
	{
        $vista = $this->controlador->get_vista_form();
		return $vista;
	}

    function get_datos_discapacidad()
	{
		$datos = $this->controlador->modelo()->get_datos_discapacidad();
		foreach ($datos as $key => $dato) {
			$datos[$key]['LINK_EDITAR'] = kernel::vinculador()->crear('censo', 'discapacidad_agregar', array($dato[catalogo::id]));
			$datos[$key]['LINK_ELIMINAR'] = kernel::vinculador()->crear('censo', 'discapacidad_eliminar', array($dato[catalogo::id]));
		}
		return $datos;
	}
    
	public function prepare()
	{
		$this->add_var_js('url_discapacidad', kernel::vinculador()->crear('censo', 'datos_discapacidad'));
        
        $this->data['cant_datos'] = count($this->get_datos_discapacidad());
        $this->data['modo'] = $this->pantalla;
	}
}

?>