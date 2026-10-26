<?php
namespace siu\operaciones\solicitud_certificado;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\_comun\operaciones\reporte\vista
{

    protected $pagelet_segunda_columna = 'formulario';

    function ini()
    {
		$clase = 'operaciones\solicitud_certificado\pagelet_certificados';
		$pl = kernel::localizador()->instanciar($clase, 'certificados');
		$this->add_pagelet($pl);

		$clase = 'operaciones\solicitud_certificado\pagelet_formulario';
		$pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);

        $clase = 'operaciones\solicitud_certificado\pagelet_certificado_evaluacion';
        $pl = kernel::localizador()->instanciar($clase, 'certificado_evaluacion');
        $this->add_pagelet($pl);
	
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_solicitud_certificado"));		
    }

    function set_pagelet_segunda_columna($pagelet_name){

        $this->pagelet_segunda_columna = $pagelet_name;

    }

    function get_pagelet_segunda_columna(){

        return $this->pagelet_segunda_columna;

    }
}
?>