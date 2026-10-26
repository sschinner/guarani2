<?php

namespace kernel\nucleo;

//use kernel\acceso\login_manager;
use kernel\error_kernel;
use kernel\kernel;
use kernel\util\clase_datos;

class sesion_consola extends sesion
{
	protected $path;
	protected $datos;
	
    function __construct()
    {
		$dir = kernel::proyecto()->get_dir_cache();
		$this->path = $dir . '/data_sesion_consola.php'; 
		return;
		if(file_exists($this->path)) {
			require_once($this->path);
			$this->datos = call_user_func(array("data\\consola\\sesion",'data'));
			kernel::log()->add_debug('SESION CONSOLA LOAD', "LOAD: {$this->path}.php");			
		}
    }

	function __destruct()
	{
		$clase = new clase_datos('sesion', null, "data\\consola");
		$clase->agregar_metodo_datos('data', $this->datos);
		$clase->guardar($this->path);
		kernel::log()->add_debug('SESION CONSOLA SAVE', "$this->path");		
	}
	
    function set($clave, $valor)
    {
        $this->datos[$clave] = $valor;
    }
    
    function get($clave)
    {
        return $this->datos[$clave];
    }
    
    function esta_seteada($clave)
    {
        return isset($this->datos[$clave]);
    }
    
    function cerrar()
    {
    }

}

?>
