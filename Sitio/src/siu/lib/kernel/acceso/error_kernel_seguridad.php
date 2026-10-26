<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of error_kernel_seguridad
 *
 * @author andres
 */
namespace kernel\acceso;
class error_kernel_seguridad extends \kernel\error_kernel
{
    protected $mensaje;
    
    function __construct($mensaje)
    {
        parent::__construct('error');
        $this->mensaje = $mensaje;
    }
    
    function get_error_seguridad()
    {
        return $this->mensaje;
    }
}

?>
