<?php
namespace siu\extension_kernel\formularios\elementos;

use kernel\interfaz\componentes\forms\form_accion;
use kernel\interfaz\componentes\forms\vista_accion;

class guarani_accion_boton implements vista_accion
{


	public function render(form_accion $a)
	{

		$html = "<button id='$a->id' type='$a->type' class='btn btn-info'";

		if (!empty($a->name)) {
			$html .= " name='$a->name'";
		}

		$html .= "> $a->innerHtml</button>";

		return $html;
	}

}