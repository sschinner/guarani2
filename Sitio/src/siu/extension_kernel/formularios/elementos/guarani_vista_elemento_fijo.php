<?php

namespace siu\extension_kernel\formularios\elementos;


use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\vista_elemento;

class guarani_vista_elemento_fijo implements vista_elemento {


	public function render(form_elemento $elemento){
		$attribs = array();
		foreach ($elemento->get_data_html5() as $key => $valor) {
			$attribs[] = "data-$key=$valor";
		}
		$string_attribs = implode(' ', $attribs);
		
		$html = "<div class='control-label'>";
		$html .=	"<dt id='{$elemento->get_id_html()}-label'>";
		$html .=		"<label for='{$elemento->get_id_html()}'>{$elemento->get_label()}</label>";
		$html .=	"</dt>";
		$html .= "</div>";
		$html .= "<div class='controls'>";
		$html .=	"<label id='{$elemento->get_id_html()}' $string_attribs>{$elemento->get_valor()}</label>";
		$html .= "</div>";
		return $html;

	}


	/**
	 * @return boolean Dice si tambien dibuja la etiqueta. Si no la dibuja, se la dibuja
	 * la vista.
	 */
	public function renderiza_label()
	{
		return true;
	}
}