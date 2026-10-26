<?php

namespace kernel\interfaz\componentes\forms\elementos;

use kernel\interfaz\componentes\forms\elementos\form_elemento_fijo;
use kernel\interfaz\componentes\forms\elementos\form_elemento_ml;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\vista_elemento;

use kernel\error_kernel;

class form_vista_ml implements vista_elemento
{

	protected $mje_vacio;

	function set_mensaje_vacio($mje)
	{
		$this->mje_vacio = $mje;
	}

	public function render(form_elemento $elem_ml)
	{

		$html = $this->html_ml($elem_ml); //downcast
		if (isset($this->mje_vacio)) {
			$html .= $this->html_mje_vacio($this->mje_vacio);
		}
		return $html;
	}

	protected function html_ml(form_elemento_ml $ml)
	{
		$cols_tn = $ml->get_columna_todo_nada();
		$id = $ml->get_id_html();
		$html = "<table class='form-ml table' id='$id'>";
		$html .= "<thead>";
		foreach ($ml->get_columnas() as $columna) {
			$label = $columna->get_label();
			$html .= "<th>";
			if (in_array($columna->get_nombre(), $cols_tn)){
				if ($columna->get_elemento_html_tipo() == 'checkbox'){
					// checkbox todo nada
					$html .= "<input type='checkbox' name='tn_".$columna->get_nombre()."' id='tn_".$columna->get_nombre()."' class='todo_nada' />";
				} else {
					throw new error_kernel("el tipo de elemento definido como columna todo o nada ->set_columna_todo_nada(), no es un tipo válido. (debe ser de tipo checkbox)");
				}
		}
			$html .= $label;
			$html .= "</th>";
		}

		if ($ml->get_permite_alta_baja()) {
			$html .= "<th></th>";
		}
		$html .= "</thead>";

		$html .= "<tbody>";

		foreach ($ml->get_filas() as $fila) {
			$valores = $fila->get_valor();
			if (! isset($valores[analisis_columna]) || $valores[analisis_columna] != analisis_baja)
			{
				if (!$fila->es_template()) {
					$html .= "<tr class='form-ml-row'";
					if ($fila->tiene_titulo()){
						$html .= " title='{$fila->get_titulo()}'";
					}
					$html .= ">";
				} else {
					$html .= "<tr class='hide form-template-row'>";
				}

				foreach ($fila->get_columnas() as $columna) {
					$elem = $this->html_elemento($columna);
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

					if (in_array($columna->get_nombre(), $cols_tn)){
						// checkbox todo nada
						$class = ' tn_'.$columna->get_nombre();
					}

					$html .= "<td class='form-ml-data $class' $data title='$title'>$elem</td>";
				}

				if ($ml->get_permite_alta_baja()) {
					$html .= "<td class='form-ml-remove-row'><button class='btn btn-mini btn-warning'><i class='icon-remove'></i>".  ucfirst(\kernel\kernel::traductor()->trans('form_ml_btn_borrar'))."</button></td>";
				}

				$html .= "</tr>";
			}
		}

		$html .= "</tbody>";

		$html .= "</table>";

		return $html;
	}

	protected function html_elemento(form_elemento $elemento)
	{
		if ($elemento instanceof form_elemento_fijo) {
			return $elemento->get_html();
		} else if($elemento->get_vista_helper() != null){
			return $elemento->get_vista_helper()->render($elemento);
		}else{
			return $elemento->get_zend_element()->renderViewHelper();
		}
	}

	protected function html_mje_vacio($mje_vacio)
	{
		return "<div class='alert js-ml-mje-vacio' style='display:none'>$mje_vacio</div>";
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