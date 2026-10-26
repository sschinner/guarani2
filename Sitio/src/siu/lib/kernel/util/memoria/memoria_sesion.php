<?php

namespace kernel\util\memoria;

class memoria_sesion implements interface_memoria
{
    protected $nombre;
    
    /**
     * Asume la sesión iniciada
     * @param string $nombre nombre del espacio de memoria
     */
    function __construct($nombre)
    {
        $this->nombre = $nombre;
        if (!isset($_SESSION[$nombre])) {
            $_SESSION[$nombre] = array();    
        }        
    }
    
    public function agregar($clave, $valor)
    {
        $_SESSION[$this->nombre][$clave] = $valor;
    }
    
    public function get($clave)
    {
        return $_SESSION[$this->nombre][$clave];
    }
    
    /**
     * Limpia la memoria
     * @param string $clave si especifica este parámetro se borra la entrada con esta clave
     */
    public function limpiar($clave = null)
    {
        if ($clave === null) {
            $_SESSION[$this->nombre] = array();
        } else {
            unset($_SESSION[$this->nombre][$clave]);
        }
        
    }

    public function tiene($clave)
    {
        return isset($_SESSION[$this->nombre][$clave]);        
    }
}

?>
