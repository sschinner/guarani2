<?php
namespace kernel\util;
use kernel\acceso\error_kernel_seguridad;

class manejador_bolsa_opciones
{
    const PREFIJO_SESION = '__kernel_bolsa_';
    
    /**
     * Agrega una opción a una bolsa de parametros
     * @param type $id_bolsa
     * @param type $opcion
     * @return string la clave interna en la bolsa
     */
    function agregar($id_bolsa, $opcion)
    {
        if (!$this->existe_bolsa($id_bolsa)) {
            $this->crear_bolsa($id_bolsa);
        }
        
        return $this->agregar_opcion($id_bolsa, $opcion);        
    }
    
    /**
     * Busca una opción en una bolsa
     * @param type $id_bolsa
     * @param type $key
     * @return mixed el contenido de la opción
     */
    function buscar($id_bolsa, $key)
    {
        if (!$this->existe_bolsa($id_bolsa)) {
            throw new error_kernel_seguridad("La bolsa '$id_bolsa' no existe");
        }
        
        if (!$this->existe_opcion($id_bolsa, $key)) {
            throw new error_kernel_seguridad("La clave '$key' no existe en la bolsa '$id_bolsa'");
        }
        
        return $this->get_opcion($id_bolsa, $key);
    }
    
    /**
     * Marca una bolsa de parámetros para que sea borrada en el próximo request
     * @param $id_bolsa
     */
    function marcar_para_borrado($id_bolsa)
    {
        $key_borrar = self::PREFIJO_SESION.'_marcadas';
        
    }
    
    /**
     * Borra una bolsa. Si se especifica el segundo parámetro se borrarán todas
     * las entradas de la bolsa salvo la clave que se especifique.
     * @param type $id_bolsa
     * @param type $excepto 
     */
    function borrar($id_bolsa, $excepto = false)
    {
        if (!$this->existe_bolsa($id_bolsa)) {
            throw new error_kernel_seguridad("La bolsa '$id_bolsa' no existe");
        }
        
        if ($excepto === false) { // se borra la bolsa entera
            $this->borrar_bolsa($id_bolsa);
        } else {
            foreach ($this->get_bolsa($id_bolsa) as $key => $value) {
                if ($key != $excepto) {
                    $this->borrar_opcion($id_bolsa, $key);
                }
            }
        }
    }
	
	/**
	 * Agrega varias opciones a un bolsa de parámetros, 
	 * Retorna un array indizado por las claves internas correspondientes de la bolsa
	 *  
	 * @param type $id_bolsa
	 * @param type $opciones
	 * @return type 
	 */
	function agregar_opciones($id_bolsa, $opciones)
	{
		foreach ($opciones as $key => $opcion) {
			$retorno[self::agregar($id_bolsa, $opcion)] = $opcion;
		}
		return $retorno;
	}

    protected function armar_id_sesion($id_bolsa)
    {
        return self::PREFIJO_SESION.$id_bolsa;
    }
    
    // Los métodos siguientes son los que acceden a la sesión
    
    protected function crear_bolsa($id_bolsa)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        $_SESSION[$id] = array();
    }   
    
    protected function existe_bolsa($id_bolsa)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        return isset($_SESSION[$id]);
    }
    
    protected function borrar_bolsa($id_bolsa)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        unset($_SESSION[$id]);
    }
    
    protected function get_bolsa($id_bolsa)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        return $_SESSION[$id];
    }
    
    protected function agregar_opcion($id_bolsa, $opcion)
    {
        $id_sesion = $this->armar_id_sesion($id_bolsa);
//        $key = uniqid();
        /**
         * @todo cambiar esto. lo puse así para que el id dependa del contenido
         */
        $key = md5(serialize($opcion));
        $_SESSION[$id_sesion][$key] = $opcion;
        
        return $key;
    }
    
    protected function existe_opcion($id_bolsa, $key)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        return isset($_SESSION[$id][$key]);
    }
    
    protected function get_opcion($id_bolsa, $key)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        return $_SESSION[$id][$key];
    }
    
    protected function borrar_opcion($id_bolsa, $key)
    {
        $id = $this->armar_id_sesion($id_bolsa);
        unset($_SESSION[$id][$key]);
    }
}

?>
