<?php
namespace siu\operaciones\notas_cursada;

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
	 * @return carga_notas_cursada
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
	
	function mostrar_promocion_combo($estado_acta, $alumno_promocionable)
	{
		return $estado_acta == 'A' && $alumno_promocionable;
	}
	
	protected function get_renglones()
	{
		// se pide al controlador para hacer validación con los datos enviados al guardar
		$renglones = $this->controlador->get_folio();
		
		foreach ($renglones as $id => $renglon) {
			$renglones[$id]['URL_FICHA'] = kernel::vinculador()->crear('notas_cursada', 'ficha_alumno', array(
				'id' => $renglones[$id]['ID_IMAGEN'],
				'legajo'	=> $renglones[$id]['LEGAJO'],
				'carrera'	=> $renglones[$id]['CARRERA'],
				'comision'	=> $renglones[$id]['COMISION']
			));
		}

		if ($this->errores !== false && $this->errores->hay_renglones()) {
			$renglones_error = $this->errores->get_renglones();
			foreach ($renglones_error as $id => $renglon) {
				$renglones[$id]['ERROR']		= $renglon['msg'];
				$renglones[$id]['NOTA']			= $renglon['renglon']['NOTA'];
				$renglones[$id]['ASISTENCIA']	= $renglon['renglon']['ASISTENCIA'];
				$renglones[$id]['CONDICION']	= $renglon['renglon']['CONDICION'];
				$renglones[$id]['FECHA']		= $renglon['renglon']['FECHA'];
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
			$paginas[$pagina] = kernel::vinculador()->crear('notas_cursada', 'edicion', array($this->controlador->acta, $pagina));
		}
		
		return $paginas;
	}

	protected function get_url_guardar() 
	{
		return kernel::vinculador()->crear('notas_cursada', 'guardar', array($this->controlador->acta, $this->controlador->folio));
	}
	
	function get_comision()
	{
		$cabecera = $this->controlador->get_encabezado();
		return $cabecera[catalogo::id];
	}
	
	function get_url_comision()
	{
		$cabecera = $this->controlador->get_encabezado();
		return $cabecera['URL_COMISION'];
	}
	
    function prepare()
    {
		parent::prepare();
		
		$cierre_parcial = $this->controlador->cierre_parcial();
		$cierre_parcial_modifica_notas = $this->controlador->cierre_parcial_modifica_notas();
		
		$this->data['cierre_parcial']  = $cierre_parcial;
		$this->add_var_js('cierre_parcial', $cierre_parcial);
		$this->data['cierre_parcial_modifica_notas']  = $cierre_parcial_modifica_notas;
		$this->add_var_js('cierre_parcial_modifica_notas', $cierre_parcial_modifica_notas);
		
		$encabezado = $this->get_encabezado();		
		$this->add_var_js('fecha_inicio', $encabezado['FECHA_INICIO']);
		$this->add_var_js('fecha_fin', date('d/m/Y'));
		$this->add_var_js('prom_abierta', $encabezado['PROM_ABIERTA']);
		
		$this->data['encabezado']  = $encabezado;
		$this->data['condiciones'] = $this->get_condiciones();
		$this->add_var_js('url_autocomplete', kernel::vinculador()->crear('notas_cursada', 'auto_alumno', $this->get_comision()));
		$this->add_mensaje_js('no_se_encontraron_alumnos', kernel::traductor()->trans('no_se_encontraron_alumnos'));
		$this->add_mensaje_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		$this->add_mensaje_js('nota_no_coincide_condicion_seleccionada', kernel::traductor()->trans('nota_no_coincide_condicion_seleccionada'));
		$this->add_mensaje_js('fecha_invalida', kernel::traductor()->trans('fecha_invalida_acta', array(
			'%1%' => $encabezado['FECHA_INICIO'],
			'%2%' => date('d/m/Y')
		)));
		$this->add_mensaje_js('asistencia_invalida', kernel::traductor()->trans('asistencia_invalida'));
		$vinculo_mensaje = kernel::vinculador()->crear('mensajes', 'enviar_mensaje', array(
			'comision' =>  $this->get_url_comision()
		));
		
		$this->add_var_js('guardado_exitoso', kernel::traductor()->trans('notas_cursada_guardado_exitoso', array(
			'%1%' => $vinculo_mensaje
		)));
		$this->add_var_js('guardado_error', kernel::traductor()->trans('notas_cursada_guardado_error'));
		$this->add_var_js('msj_navegacion', kernel::traductor()->trans('msj_navegacion'));
    }

}
?>
