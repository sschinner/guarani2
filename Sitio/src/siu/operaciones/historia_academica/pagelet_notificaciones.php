<?php

namespace siu\operaciones\historia_academica;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_notificaciones extends pagelet
{
	protected $notificaciones = array();
	
	function ini()
	{		
	}
	
    function get_nombre()
    {
        return 'notificaciones';
    }
    
    function prepare()
    {
    }
}
?>