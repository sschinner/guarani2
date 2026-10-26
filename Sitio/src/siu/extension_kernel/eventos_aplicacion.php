<?php

namespace siu\extension_kernel;

use siu\guarani;
use kernel\kernel;
use kernel\util\cache\admin_cache;

class eventos_aplicacion implements \kernel\nucleo\interface_eventos_aplicacion
{

    function ini()
    {
		kernel::log()->add_debug('UA', guarani::get_ua_id());
		kernel::log()->add_debug('ALIAS', kernel::proyecto()->get_alias());
		if (kernel::proyecto()->get('barra_dev')) {
			header('guarani-log: ' . kernel::log()->get_id());
		}
    }

    function fin()
    {
        
    }
	
	function pre_ini__sesion()
	{
	}
	
    function ini__conexion($db)
    {
        
    }

    function fin__conexion($db)
    {
        
    }

    function fin__request()
    {
        
    }

    function fin__response()
    {
        
    }
}

?>