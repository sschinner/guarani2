<?php

namespace siu\extension_kernel\formularios;


use kernel\interfaz\componentes\forms\elementos\form_elemento_fijo;
use kernel\interfaz\componentes\forms\form_accion;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\salida_layout_grilla;
use kernel\interfaz\componentes\forms\vista_accion;
use kernel\interfaz\componentes\forms\vista_elemento;

class salida_bootstrap_grilla implements salida_layout_grilla
{


	protected $minimizable = true;

	protected $horizontal = false;


	function __construct()
	{
	}

	/**
	 * Pone los labels horizontales o arriba de los elementos
	 */
	public function set_horizontal()
	{
		$this->horizontal = true;
		return $this;
	}


	function set_es_minimizable($es_minimizable)
	{
		$this->minimizable = $es_minimizable;
		return $this;
	}


	public function crear_encabezado($id_html, $action)
	{
		$clase = $this->minimizable ? ' minimizable' : '';
		$html = "<div class='g3-form clearfix$clase'>";

		$class = $this->horizontal ? 'form-horizontal' : 'form';

		$html .= "<form id='$id_html' action='$action' method='post' class='$class'>";
		return $html;
	}

	public function crear_csrf($csrf_key, $nombre_csrf)
	{
		return "<input type='hidden' name='$nombre_csrf' value='$csrf_key'>";
	}


	private function generar_encabezado_grupo_minimizable($id_grupo = 'n_a', $nombre_grupo)
	{
		return "
			<div class='accordion-group'>
				<div class='encabezado-form clearfix accordion-heading '  data-toggle='collapse' data-target='#ac_$id_grupo'>
					$nombre_grupo <span class='js-minimizar'><i class='icon-chevron-up icon-white'></i></span>
				</div>
				<div id='ac_$id_grupo' class='accordion-cuerpo collapse in'>
					<div id='$id_grupo' class='g3-form-form accordion-interno'>
			";
	}


	private function generar_encabezado_grupo($id_grupo = 'n_a', $nombre_grupo)
	{
        $html_titulo = "";
        if ($nombre_grupo){
            $html_titulo = "<div class='encabezado-form clearfix accordion-heading '>
					$nombre_grupo
				</div>";
        }
		return "
			<div class='accordion-group'>
				$html_titulo
				<div id='ac_$id_grupo' class='accordion-cuerpo'>
					<div id='$id_grupo' class='g3-form-form accordion-interno'>
			";

	}


	public function crear_encabezado_grupo($grupo, $titulo)
	{
		$html = '';
		if ($this->minimizable) {
			$html .= $this->generar_encabezado_grupo_minimizable($grupo, $titulo);

		} else {
			$html .= $this->generar_encabezado_grupo($grupo, $titulo);
		}
		return $html;
	}

	public function crear_cierre()
	{
		return "</form></div>";

	}


	public function crear_cierre_grupo()
	{
		return "</div></div></div>";

	}

	public function crear_encabezado_fila()
	{
		return "<div class='controls-row'>";
	}

	public function crear_cierre_fila()
	{
		return "</div>";
	}

	public function crear_encabezado_elemento($span, $offset, $tiene_error)
	{
		$clase_error = ($tiene_error) ? ' error' : '';
		$clase_offset = $offset > 0 ? " offset$offset" : '';
		$clase_span = " span$span";

		return "<div class='control-group$clase_error$clase_offset$clase_span'>";

	}

	public function crear_elemento(form_elemento $elemento, vista_elemento $renderer = null)
	{
		if ($renderer != null && $renderer->renderiza_label()) {
			return $renderer->render($elemento);
		} else {

			$obligatorio = $elemento->get_obligatorio();
			$error = "<span class='text-error'>" . $elemento->get_error() . "</span>"; //string
			$texto_ayuda = $elemento->get_ayuda(); //string

			$clase_label = $obligatorio ? ' label-obligatorio' : ' label-no-obligatorio';

			$label_html = $this->crear_label_elemento($elemento, $clase_label);


			$elemento_html = "<div class='controls'> ";

//			if($renderer == null){ //todos tendrian que tener un renderer
//				$elemento_html .= $this->html_elemento($elemento);
//			}else {
			$elemento_html .= $renderer->render($elemento);
//			}

			$elemento_html .= " </div>";

			$ayuda_html = $this->crear_ayuda_elemento($texto_ayuda);

			$html = $label_html . $elemento_html . $ayuda_html . $error;

			return $html;
		}
	}

	public function crear_cierre_elemento()
	{
		return "</div>";
	}

	public function crear_elemento_plano(form_elemento $campo)
	{
		return $this->html_elemento($campo);
	}

	public function crear_ayuda_elemento($texto_ayuda)
	{
		if ($texto_ayuda != '') {
			return "<span class='form-ayuda' title='$texto_ayuda'><i class='icon-question-sign'></i></span>";
		}
	}

	public function crear_submit_button($nombre, $valor)
	{
		$html = "<button id='$nombre' name='$nombre' type='submit' class='btn btn-info'>$valor</button>";
		return $html;
	}

	protected function crear_label_elemento(form_elemento $elemento, $clase_label)
	{
		$label = $elemento->get_zend_element()->renderLabel();
		$label_html = "<div class='control-label$clase_label'>" . $label . '</div>';
		return $label_html;
	}

	protected function html_elemento(form_elemento $elemento)
	{
		if ($elemento instanceof form_elemento_fijo) {
			return $elemento->get_html();
		} else {
			return $elemento->get_vista_helper()->render($elemento);
			//todo: sacar
			//return $elemento->get_zend_element()->renderViewHelper();
		}
	}

	public function crear_accion(form_accion $accion)
	{
		return $accion->get_vista_helper()->render($accion);
	}
}