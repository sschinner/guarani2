<?php
namespace personalizacionPOSGRADO\operaciones\encuestas_egresados;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function ini()
	{
		$clase = 'operaciones\encuestas_egresados\pagelet_reporte';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);
                
               /* $clase = 'operaciones\encuestas_egresados\pagelet_reporte2';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);*/

                
                
		kernel::pagina()->set_etiqueta('titulo',"Encuestas Egresados");
	}
        
        function mostrar()
	{
		$clase = 'operaciones\encuestas_egresados\pagelet_reporte2';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
                $this->add_pagelet($pl);

		kernel::pagina()->set_etiqueta('titulo',"Encuestas Egresados");
	}
}
?>

