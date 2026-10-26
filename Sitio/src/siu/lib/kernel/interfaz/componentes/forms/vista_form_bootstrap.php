<?php
namespace kernel\interfaz\componentes\forms;

use kernel\interfaz\componentes\forms\elementos\form_elemento_fijo;
use kernel\interfaz\componentes\forms\elementos\form_elemento_ml;
use kernel\nucleo\controlador;

class vista_form_bootstrap
{
	function __construct()
	{
	}

	function encabezado($id_html, $action, $csrf_activo, $csrf_key)
	{
		$html = "<form id='$id_html' action='$action' method='post'>";
		if ($csrf_activo) {
			$nombre_csrf = controlador::CSRF_KEY;
			$html .= "<input type='hidden' name='$nombre_csrf' value='$csrf_key'>";
		}

		return $html;
	}

	function elemento(form_elemento $elemento)
	{
		if ($elemento instanceof form_elemento_fijo) {
			return $elemento->get_html();
		} else {
			return $elemento->get_zend_element()->renderViewHelper();
		}
	}

	function label(form_elemento $elemento)
	{
		return $elemento->get_zend_element()->renderLabel();
	}

	function ayuda($texto_ayuda)
	{
		if ($texto_ayuda != '') {
			return "<span class='form-ayuda' title='$texto_ayuda'><i class='icon-question-sign'></i></span>";
		}

		return '';
	}

	function control_group(form_elemento $elemento, $clase_wrapper_css = '')
	{
		$label = $this->label($elemento);
		$obligatorio = $elemento->get_obligatorio();
		$tiene_error = $elemento->tiene_error();
		$error = $elemento->get_error();
		$texto_ayuda = $elemento->get_ayuda();

		if (!$obligatorio) {
			$label = '<span class="label-no-obligatorio">' . $label . '</span>';
		}
		$elemento = $this->elemento($elemento);
		$clase_error = ($tiene_error) ? 'error' : '';

		$html = "<div class='control-group $clase_wrapper_css $clase_error'>";
		$html .= $label;
		$html .= $elemento;
		$html .= $this->ayuda($texto_ayuda);
		if ($tiene_error) {
			$html .= "<span class='help-inline'>{$error}</span>";
		}
		$html .= "</div>";

		return $html;
	}

	function checkbox(form_elemento $elemento)
	{
		$id = $elemento->getId();
		$label = $elemento->get_label();
		$texto_ayuda = $elemento->get_ayuda();
		$obligatorio = $elemento->get_obligatorio();

		$html = "<label for='$id' class='optional checkbox'>";

		if (!$obligatorio) {
			$label = '<span class="label-no-obligatorio">' . $label . '</span>';
		}
		$label .= $this->ayuda($texto_ayuda);
		$html .= $label . $this->elemento($elemento);
		$html .= "</label>";
		return $html;
	}

	function submit_button($nombre, $valor)
	{
		$html = "<button id='$nombre' name='$nombre' type='submit' class='btn btn-info'>$valor</button>";

		return $html;
	}

	function ml(form_elemento_ml $ml)
	{
		$html = "<table class='form-ml table'>";

		$html .= "<thead>";
		foreach ($ml->get_columnas() as $columna) {
			$label = $columna->get_label();
			$html .= "<th>$label</th>";
		}

		if ($ml->get_permite_alta_baja()) {
			$html .= "<th></th>";
		}
		$html .= "</thead>";

		$html .= "<tbody>";

		foreach ($ml->get_filas() as $fila) {
			if (!$fila->es_template()) {
				$html .= "<tr class='form-ml-row'>";
			} else {
				$html .= "<tr class='hide form-template-row'>";
			}

			foreach ($fila->get_columnas() as $columna) {
				$elem = $this->elemento($columna);
				$class = '';
				$data = '';
				if ($columna instanceof form_elemento_fijo) {
					$class = 'ef-fijo';
					$data = "data-nombre='{$columna->get_nombre()}'";
				}
				$title = '';
				if ($columna->tiene_error()) {
					$class .= ' form-ml-data-error';
					$title = $columna->get_error();
				}
				$html .= "<td class='form-ml-data $class' $data title='$title'>$elem</td>";
			}

			if ($ml->get_permite_alta_baja()) {
				$html .= "<td class='form-ml-remove-row'><i class='icon-remove'></i></td>";
			}

			$html .= "</tr>";
		}

		$html .= "</tbody>";

		$html .= "</table>";

		return $html;
	}
}

?>
