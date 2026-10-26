<?php
namespace kernel\interfaz\vistas;
use kernel\interfaz\vista as vista_base;
use kernel\kernel;
use kernel\nucleo\recursos;

class vista_error extends vista_base
{
	protected $mensaje;
	
	function __construct($mensaje)
	{
		parent::__construct();
		$this->mensaje = $mensaje;
	}
	
	function ini()
    {
        kernel::pagina()->set_etiqueta('titulo', "SIU Guarani");
        kernel::pagina()->set_etiqueta('sub_titulo', "Error");
    }
	
	protected function get_contexto()
	{
		return array('mensaje' => $this->mensaje);
	}
	
	protected function get_template()
	{
		$nombre = 'vista_error.twig';
        return kernel::load_template($nombre);
	}
}

?>
