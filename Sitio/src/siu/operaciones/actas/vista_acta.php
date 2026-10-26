<?php
namespace siu\operaciones\actas;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista_acta extends vista_g3w2
{
    function ini()
    {
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_actas"));
		
		$this->set_template('template_acta');
    }
}
?>