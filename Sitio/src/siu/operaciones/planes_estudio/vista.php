<?php
namespace siu\operaciones\planes_estudio;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
    function ini()
    {	
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_planes_estudio"));
    }
}
?>