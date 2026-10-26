<?php
namespace siu\operaciones\notas_parciales;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_lista_notas extends pagelet
{
	protected $encabezado;

	
    function get_nombre()
    {
        return 'lista_notas';
    }
	
	/**
	 * @return carga_notas_cursada
	 */
	protected function modelo()
	{
		return $this->controlador->modelo();
	}
	
	
	protected function get_encabezado()
	{
		return $this->controlador->get_encabezado();
	}
	
	protected function get_renglones()
	{
		// se pide al controlador para hacer validación con los datos enviados al guardar
		$renglones = $this->controlador->get_renglones();
		return $renglones;
	}
	
    function prepare()
    {
		$this->data = array();
		$this->data['renglones'] = $this->get_renglones();
		$this->data['encabezado'] = $this->get_encabezado();
		
		$this->data['url_generar_pdf'] = kernel::vinculador()->crear('notas_parciales', 'generar_pdf', array('id' => $this->controlador->evaluacion_id));
		$this->data['url_generar_excel'] = kernel::vinculador()->crear('notas_parciales', 'generar_excel', array('id' => $this->controlador->evaluacion_id));

		$this->add_mensaje_js('nota_invalida', kernel::traductor()->trans('nota_invalida'));
		$this->add_mensaje_js('asistencia_invalida', kernel::traductor()->trans('asistencia_invalida'));
		
		
		$notas = $this->controlador->get_escala_js();
		$this->add_var_js('escala', $notas);
    }

}
?>
