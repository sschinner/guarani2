<?php
namespace personalizacionCEMEDDIPLOMA\operaciones\redireccion;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function ini()
	{
		$clase = 'operaciones\redireccion\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);
                
               /* $clase = 'operaciones\encuestas_egresados\pagelet_reporte2';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);*/

                
                
		//kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("Electivas"));
	}
        function set_hay_mensajes($hay_mensajes)
	{
		$this->hay_mensajes = $hay_mensajes;
	}
       /* function mostrar()
	{
		$clase = 'operaciones\encuestas_egresados\pagelet_reporte2';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo',"Encuestas Egresados");
	}*/
}
?>

