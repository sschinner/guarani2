<?php
namespace siu\operaciones\notas_parciales;

use kernel\kernel;
use siu\guarani;

class pagelet_edicion_notas extends \siu\operaciones\_comun\pagelets\pagelet_renglones
{
	function get_nombre()
    {
        return 'edicion_notas';
    }
	
	/**
	 * @return carga_notas_cursada
	 */
	protected function modelo()
	{
		return $this->controlador->modelo();
	}
	
	
	protected function get_renglones()
	{
		// se pide al controlador para hacer validación con los datos enviados al guardar
		$renglones = $this->controlador->get_renglones();
		$encabezado = $this->get_encabezado();
		foreach ($renglones as $id => $renglon) {
			$renglones[$id]['URL_FICHA'] = kernel::vinculador()->crear('notas_cursada', 'ficha_alumno', array(
				'id' => $renglones[$id]['ID_IMAGEN'],
				'legajo'	=> $renglones[$id]['LEGAJO'],
				'carrera'	=> $encabezado['CARRERA'],
				'comision'	=> $encabezado['COMISION']
			));
		}
		
		if ($this->errores !== false && $this->errores->hay_renglones()) {
			$renglones_error = $this->errores->get_renglones();
			foreach ($renglones_error as $id => $renglon) {
				$renglones[$id]['ERROR'] = $renglon['msg'];
				
				$renglones[$id]['NOTA'] = $renglon['renglon']['NOTA'];
				$renglones[$id]['CORREGIDO_POR'] = $renglon['renglon']['CORREGIDO_POR'];
				$renglones[$id]['OBSERVACIONES'] = $renglon['renglon']['OBSERVACIONES'];
			}
		}
		
		return $renglones;
	}

	protected function get_id_parcial()
	{
		return $this->controlador->evaluacion_id;
	}
	
	protected function get_url_guardar() 
	{
		return kernel::vinculador()->crear('notas_parciales', 'editar', $this->controlador->evaluacion_id);
	}
	
	protected function get_escala()
	{
		$encabezado = $this->get_encabezado();
		return $encabezado['ESCALA_NOTAS'];
	}
	
    function prepare()
    {
		parent::prepare();
//		$this->data['condiciones'] = $this->get_condiciones();
		
		$this->add_mensaje_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		$this->add_mensaje_js('asistencia_invalida', kernel::traductor()->trans('asistencia_invalida'));
		$this->add_var_js('edicion_notas_parciales_ok', kernel::traductor()->trans('edicion_notas_parciales_ok'));
		$this->add_var_js('edicion_notas_parciales_error', kernel::traductor()->trans('edicion_notas_parciales_error'));
		$this->add_var_js('msj_navegacion', kernel::traductor()->trans('msj_navegacion'));
    }

}
?>
