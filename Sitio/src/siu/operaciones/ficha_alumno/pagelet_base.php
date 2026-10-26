<?php
namespace siu\operaciones\ficha_alumno;

use kernel\interfaz\pagelet;

class pagelet_base extends pagelet
{
	public function get_nombre()
	{
		return 'base';
	}
	
	public function prepare()
	{
		$this->data['categoria_actual'] = $this->controlador->get_categoria_actual();
		$this->data['reporte_actual'] = $this->controlador->get_reporte_actual();
		$this->data['menu_reportes'] = $this->controlador->get_menu_reportes();
	}
}
?>