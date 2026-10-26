<?php
namespace siu\operaciones\ficha_alumno;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends vista_g3w2
{
	function ini()
	{
		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("ficha_alumno"));
	}
}
?>