<?php

namespace kernel\interfaz\componentes\forms;

use kernel\nucleo\controlador;
use kernel\error_kernel;


class layout_grilla extends layout_vista
{
	/**
	 * @var salida_layout_grilla
	 */
	protected $salida;
	/**
	 * @var form
	 */
	protected $form;

	/**
	 * todo: explicar la configuracion.
	 */
	protected $config;

	function __construct($config)
	{
		$this->config = $config;
	}

	public function render_encabezado()
	{

		$form = $this->form;
		$html = $this->salida->crear_encabezado($form->get_id_html(), $form->get_action());

		if ($this->form->csrf_activo()) {
			$csrf_key = $this->form->get_csrf_key();
			$csrf_nombre = controlador::CSRF_KEY;
			$html .= $this->salida->crear_csrf($csrf_key, $csrf_nombre);
		}
		return $html;
	}

	public function render_cierre()
	{
		return $this->salida->crear_cierre();
	}

	public function render_cuerpo()
	{
		return $this->generar_campos_config($this->config);
	}

	public function render_acciones()
	{
		$html = '';
		foreach($this->form->get_acciones() as $accion){
			$html .= $this->salida->crear_accion($accion);
		}
		return $html;
	}

	protected function generar_campos_config($config)
	{
		$html = '';
		foreach ($config as $grupo) {

			//if(!isset($grupo['grupo'])) continue; //no es un grupo
			$grupo_id = isset($grupo['grupo']) ? $grupo['grupo']: null;

			$titulo_grupo = isset($grupo['titulo']) ? $grupo['titulo'] : '';

			$html .= $this->salida->crear_encabezado_grupo($grupo_id, $titulo_grupo);

			$html .= $this->generar_filas($grupo['filas']);

			$html .= $this->salida->crear_cierre_grupo();
		}
		return $html;

	}

	/**
	 * @param $filas
	 * @return string
	 * @internal param $grupo
	 */
	protected function generar_filas($filas)
	{
		$html = '';
		foreach ($filas as $fila) {
			$html .= $this->salida->crear_encabezado_fila();
			$html .= $this->generar_elementos($fila);
			$html .= $this->salida->crear_cierre_fila();
		}
		return $html;
	}

	protected function generar_elementos($fila)
	{
		$campos = $this->form->get_campos();
		$html = '';
		foreach ($fila as $id => $elemento) {
			list($span, $offset) = $this->get_span_offset($elemento);

			if (isset($elemento['plano'])) {
				$html .= $this->generar_elemento_plano($elemento, $span, $offset);
			} else {
				/** @var form_elemento $campo */
				$campo = $campos[$id];
				if ($campo == null)
					throw new error_kernel("No existe el elemento $id en la configuracion de la grilla");
				if (!$campo->get_activo())
					return $html;
				if ($campo->get_elemento_html_tipo() == 'hidden') {
					$html .= $this->salida->crear_elemento_plano($campo);
					return $html;
				}
				$html .= $this->generar_campo($campo, $elemento, $span, $offset);
			}
		}
		return $html;
	}

	/**
	 * @param $elemento
	 * @param $span
	 * @param $offset
	 * @return mixed
	 */
	protected function generar_elemento_plano($elemento, $span, $offset)
	{
		$html = '';
		$html .= $this->pre_elemento($elemento, $span, $offset, false);
		$html .= $elemento['plano']->render(); //html plano
		$html .= $this->post_elemento($elemento);
		return $html;
	}

	protected function generar_campo($campo, $elemento, $span, $offset)
	{
		$html = '';
		$html .= $this->pre_elemento($elemento, $span, $offset, $campo->tiene_error());
		$renderer = $campo->get_vista_helper();
		$html .= $this->salida->crear_elemento($campo, $renderer);
		$html .= $this->post_elemento($elemento);
		return $html;
	}

	protected function pre_elemento($elemento, $span, $offset, $error)
	{
		if (isset($elemento['alinear_en_grilla']) && !$elemento['alinear_en_grilla']) {
			return '';
		}
		return $this->salida->crear_encabezado_elemento($span, $offset, $error);
	}

	protected function post_elemento($elemento)
	{
		if (isset($elemento['alinear_en_grilla']) && !$elemento['alinear_en_grilla']) {
			return '';
		}
		return $this->salida->crear_cierre_elemento();
	}

	protected function get_span_offset($elemento)
	{
		$span = (isset($elemento['span'])) ? $elemento['span'] : '12';
		$offs = (isset($elemento['offset'])) ? $elemento['offset'] : '0';
		return array($span, $offs);

	}

}