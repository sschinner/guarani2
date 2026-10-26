<?php
namespace siu\operaciones\notas_examen;

use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_renglones extends \siu\operaciones\_comun\pagelets\pagelet_renglones
{
	
    function get_nombre()
    {
        return 'renglones';
    }

	/**
	 * @return carga_notas_examen
	 */
	protected function modelo()
	{
		return $this->controlador->modelo();
	}

	protected function get_escala()
	{
		$encabezado = $this->get_encabezado();
		return $encabezado['ESCALA_NOTAS'];
	}

	protected function get_renglones()
	{
		$acta = $this->get_encabezado();
		// se pide al controlador para hacer validación con los datos enviados al guardar
		$renglones = $this->controlador->get_folio();

		foreach ($renglones as $id => $renglon) {
			$renglones[$id]['URL_FICHA'] = kernel::vinculador()->crear('notas_examen', 'ficha_alumno', array(
				'id' => $renglones[$id]['ID_IMAGEN'],
				'materia'	=> $acta['MATERIA'],
				'carrera'	=> $renglones[$id]['CARRERA'],
				'legajo'	=> $renglones[$id]['LEGAJO']
			));
		}

		if ($this->errores !== false && $this->errores->hay_renglones()) {
			$renglones_error = $this->errores->get_renglones();
			foreach ($renglones_error as $id => $renglon) {
				$renglones[$id]['ERROR'] = $renglon['msg'];
				$renglones[$id]['NOTA'] = $renglon['renglon']['NOTA'];
				$renglones[$id]['FECHA'] = $renglon['renglon']['FECHA'];
				$renglones[$id]['RESULTADO'] = $renglon['renglon']['RESULTADO'];
			}
		}
		return $renglones;
	}
	
	protected function get_condiciones()
	{
		return $this->modelo()->info__condiciones();
	}
	
	function hay_renglones()
	{
		$encabezado = $this->get_encabezado();
		return $encabezado['FOLIOS'] > 0;
	}
	
	function get_pagina_actual()
	{
		return $this->controlador->folio;
	}
	
	function get_paginas()
	{
		$encabezado = $this->get_encabezado();
		$paginas = array();
		for ($pagina = 1; $pagina <= $encabezado['FOLIOS']; $pagina++) {
			$paginas[$pagina] = kernel::vinculador()->crear('notas_examen', 'edicion', array($this->controlador->acta, $pagina));
		}
		
		return $paginas;
	}

	protected function get_url_guardar() 
	{
		return kernel::vinculador()->crear('notas_examen', 'guardar', array($this->controlador->acta, $this->controlador->folio));
	}

	function get_acta()
	{
		$cabecera = $this->controlador->get_encabezado();
		klog2('ENCABEZADO', $cabecera)
				;
		return $cabecera[catalogo::id];
	}

    function prepare()
    {
		parent::prepare();

//		$this->data['condiciones'] = $this->get_condiciones();
		$this->add_mensaje_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		$this->add_mensaje_js('asistencia_invalida', kernel::traductor()->trans('asistencia_invalida'));
		$this->add_var_js('url_autocomplete', kernel::vinculador()->crear('notas_examen', 'auto_alumno', $this->get_acta()));
		$this->add_mensaje_js('no_se_encontraron_alumnos', kernel::traductor()->trans('no_se_encontraron_alumnos'));

		$encabezado = $this->get_encabezado();
		$this->add_var_js('fecha_inicio', $encabezado['DIA']);
		$this->add_var_js('fecha_fin', date('d/m/Y'));
		$this->add_mensaje_js('fecha_invalida', kernel::traductor()->trans('fecha_invalida_acta', array(
			'%1%' => $encabezado['DIA'],
			'%2%' => date('d/m/Y')
		)));

		$this->add_var_js('guardado_exitoso', kernel::traductor()->trans('notas_examen_guardado_exitoso'));
		$this->add_var_js('guardado_error', kernel::traductor()->trans('notas_examen_guardado_error'));
    }

}
?>
