<?php

namespace siu\operaciones\notas_examen;

use siu\guarani;
use siu\operaciones\_comun\controlador_carga_notas;
use siu\modelo\entidades\alumno_foto;

use kernel\kernel;
use kernel\error_kernel;
use siu\errores\error_guarani_procesar_renglones;
use kernel\util\validador;

class controlador extends controlador_carga_notas
{
	public $acta, $folio;
	
	function get_clase_vista()
	{
		if ($this->accion == 'index') { // se muestra la lista de actas
			return 'vista_actas';
		} else {
			return 'vista_folio';
		}
	}
	
    /**
     * @return siu\modelo\transacciones\carga_notas_examen
     */
    function modelo()
    {
        return guarani::carga_notas_examen();
    }

    function accion__index()
    {
    }

	function accion__ficha_alumno()
	{
		$materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO);
		$carrera = $this->validate_param('carrera', 'get', validador::TIPO_TEXTO);
		$legajo = $this->validate_param('legajo', 'get', validador::TIPO_TEXTO);
		$id = $this->validate_param('id', 'get', validador::TIPO_TEXTO);

		$pagelet = kernel::localizador()->instanciar('operaciones\notas_examen\pagelet_ficha_alumno', 'ficha_alumno');
		$pagelet->set_data($this->modelo()->info__examenes($materia, $carrera, $legajo));
		$pagelet->set_url_imagen(alumno_foto::url_imagen($id, alumno_foto::TAMANIO_GRANDE));
		kernel::renderer()->add($pagelet);
	}

	function accion__edicion()
	{
		$this->load_params();

		$renglon = $this->validate_param('renglon', 'get', validador::TIPO_INT, array('default' => ''));
		$this->vista()->pagelet('renglones')->set_highlight($renglon);
	}
	
	function accion__info_escala()
	{
		$escala_id = $this->validate_param(0, 'get', validador::TIPO_INT);
		$escala_notas = $this->modelo()->info__escala_notas($escala_id);
		$this->render_raw_json($escala_notas);
	}
	
	function accion__guardar()
	{
		try {
			$this->load_params();
			$this->guardar_folio(kernel::request()->getPost('renglones'));
		} catch (error_guarani_procesar_renglones $e) {
			kernel::log()->add_debug('error al procesar renglones', $e);
			$this->vista()->pagelet('renglones')->set_error_guarani_procesar_renglones($e);
		}
		
		// Se indica que cuando llegue el pedido ajax a esta acción la respuesta
		// debe ser sólamente el contenido del pagelet renglones, no toda la operación
		kernel::renderer()->add($this->vista()->pagelet('renglones'));
		$this->accion__edicion();
	}
	
	/**
	 * Autocompletado de alumno 
	 */
	function accion__auto_alumno()
	{
		$acta = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);

		if (empty($term)) {
			$this->render_raw_json(array());
			return;
		}

		$alumnos = $this->modelo()->info__busqueda_alumno($acta, $term);

		$data = array();
		foreach ($alumnos as $alumno) {
			$data[] = array(
				'id' => kernel::vinculador()->crear('notas_examen', 'edicion', array(
					0 => $acta, // acta
					1 => $alumno[1], // folio
					'renglon' => $alumno[2] // renglón
				)),
				'label' => $alumno[3]
			);
		}

		$this->render_raw_json($data);
	}

	/***********************************************************************/
	// UTIL guardado y validación de renglones de folio
	/***********************************************************************/
	
	/**
	 * Busca en el get el acta y el folio
	 */
	protected function load_params()
	{
		$this->acta  = $this->validate_param(0, 'get', validador::TIPO_TEXTO);
		$this->folio = $this->validate_param(1, 'get', validador::TIPO_INT, array('default' => 1));
	}
	
	protected function get_clave_sesion_folio()
	{
		return "folio[$this->acta,$this->folio]";
	}
	
	function get_encabezado()
	{
		return $this->modelo()->info__acta_cabecera($this->acta);
	}
	
	
	function get_folio()
	{
		$renglones = $this->modelo()->info__acta_folio($this->acta, $this->folio);
		// se guardan en sesión las filas para dp actualizar, ver método guardar folio
		kernel::sesion()->set($this->get_clave_sesion_folio(), $renglones);
		
		return $renglones;
	}
	
	protected function vacio_a_null($valor)
	{
		if (trim($valor) == '') {
			return null;
		}
		
		return $valor;
	}
	
	protected function guardar_folio($renglones_post)
	{
		$renglones_sesion = kernel::sesion()->get($this->get_clave_sesion_folio());
		$renglones_modificados = array();
		
		foreach($renglones_sesion as $id => $fila_s) {
			$renglon = $fila_s['RENGLON'];
			if(isset($renglones_post[$renglon])) {
				if( ($renglones_post[$renglon]['nota'] != $fila_s['NOTA']) 
					 || ($renglones_post[$renglon]['fecha'] != $fila_s['FECHA']) 
					 || ($renglones_post[$renglon]['resultado'] != $fila_s['RESULTADO']) 
					) {
					$renglones_modificados[$id] = $fila_s;
					$renglones_modificados[$id]['NOTA'] = $this->vacio_a_null($renglones_post[$renglon]['nota']);
					$renglones_modificados[$id]['FECHA'] = $this->vacio_a_null($renglones_post[$renglon]['fecha']);
					$renglones_modificados[$id]['RESULTADO'] = $this->vacio_a_null($renglones_post[$renglon]['resultado']);
				}
			}
		}
		
		if ($renglones_modificados){
			kernel::log()->add_debug('filas__',$renglones_modificados);
			$this->modelo()->evt__procesar_folio($this->acta, $renglones_modificados);
		}
	}
}

?>