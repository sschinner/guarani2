<?php
namespace kernel\interfaz\componentes\forms\elementos;

use kernel\error_kernel;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\zend_form_util;
use Zend_Form;

define('analisis_columna', '__analisis__');
define('info_analisis_columna', '__info_analisis__');
define('analisis_alta', 'A');
define('analisis_baja', 'B');
define('analisis_modificacion', 'M');
define('analisis_sin_cambios', 'S');

define('ml_fila__columna_disabled', 'ml_col_disabled');

class form_elemento_ml_fila
{
	const NRO_FILA_TEMPLATE = "__NUM_FILA_ML__";
	protected $es_template = false;
	protected $columnas;
	
	/**
	 * @var Zend_Form
	 */
	protected $zend_form;

	/**
	 * @var zend_form_util
	 */
	protected $zend_form_util;
	protected $id_form;
	protected $nombre_ml;
	protected $nro;
	protected $columna_clave;
	protected $analisis = null;
	protected $info_analisis = null;
	protected $titulo = null;

	/**
	 * Necesita un zend form para agregar los elementos de las columnas
	 * @param Zend_Form $zend_form
	 */
	function __construct($id_form, Zend_Form $zend_form, $nombre_ml, $nro_fila)
	{
		$this->zend_form = $zend_form;
		$this->zend_form_util = new zend_form_util();
		$this->id_form = $id_form;
		$this->nombre_ml = $nombre_ml;
		$this->nro = $nro_fila;
	}

	function set_valor_analisis($analisis)
	{
		$this->analisis = $analisis;
	}
	
	function set_valor_info_analisis($info_analisis)
	{
		$this->info_analisis = $info_analisis;
	}
	
	function get_numero()
	{
		return $this->nro;
	}

	function set_columnas($columnas)
	{
		foreach ($columnas as $col) {
			$this->columnas[$col->get_nombre()] = clone $col;
			if ($col instanceof form_elemento_fijo) {
				continue;
			}
			$zend_element = $this->crear_zend_element($this->columnas[$col->get_nombre()]);
			$zend_element->setView($this->zend_form->getView());
			$this->zend_form->addElement($zend_element);
			$this->columnas[$col->get_nombre()]->set_zend_element($zend_element);
		}
	}

	function set_columna_clave($columna)
	{
		if (!empty($columna) && !isset($this->columnas[$columna])) {
			throw new error_kernel("La columna '$columna' no puede ser clave ya que no fue creada");
		}
		$this->columna_clave = $columna;
	}

	function get_valor_columna($columna)
	{
		if (!isset($this->columnas[$columna])) {
			throw new error_kernel("La columna '$columna' no existe");
		}
		return $this->columnas[$columna]->get_valor();
	}

	function set_valor_elementos_fijos($elementos)
	{
		foreach ($this->columnas as $col) {
			if ($col instanceof form_elemento_fijo) {
				$col->set_valor($elementos[$col->get_nombre()]);
			}
		}
	}

	protected function crear_zend_element(form_elemento $elemento)
	{
		/* @var $zend_element \Zend_Form_Element */
		$zend_element = $this->zend_form_util->crear_elemento($this->id_form, $elemento);
		$belongs_to = $zend_element->getBelongsTo();
		$numero_fila = $this->nro;
		if ($this->es_template) {
			$numero_fila = self::NRO_FILA_TEMPLATE;
		}
		$zend_element->setBelongsTo($belongs_to . "[$this->nombre_ml][$numero_fila]");
		return $zend_element;
	}

	function set_es_template($es_template)
	{
		$this->es_template = $es_template;
	}

	function es_template()
	{
		return $this->es_template;
	}

	/**
	 * @return form_elemento[]
	 */
	function get_columnas()
	{
		return $this->columnas;
	}

	function set_valor($fila)
	{
		foreach ($this->columnas as $col) {
			if (isset($fila[$col->get_nombre()])) {
				$col->set_valor($fila[$col->get_nombre()]);
			}
		}
	}

	function set_valor_desde_post($fila)
	{
		foreach ($this->columnas as $col) {
			if ($col instanceof form_elemento_fijo) {
				continue; // nunca hay que setear un elemento fijo desde el post
			}
			if (isset($fila[$col->get_nombre()])) {
				$col->set_valor_desde_post($fila[$col->get_nombre()]);
			}
		}
	}

	function validar()
	{
		$valido = true;

		if ($this->es_template()) {
			return true;
		}
		
		if ($this->analisis == analisis_baja) {
			return true;
		}

		foreach ($this->columnas as $col) {
			if (!$col->validar()) {
				$valido = false;
				\kernel\kernel::log()->add_debug("Falla validando columna {$col->get_nombre()}", $col->get_valor());
			}
		}

		return $valido;
	}

	function get_valor()
	{
		$valores = array();
		foreach ($this->columnas as $col) {
			$valores[$col->get_nombre()] = $col->get_valor();
		}
		if ($this->analisis != null) {
			$valores[analisis_columna] = $this->analisis;
		}
		if ($this->info_analisis != null) {
			$valores[info_analisis_columna] = $this->info_analisis;
		}
		
		return $valores;
	}
	
	/**
	 * Devuelve la data que se tiene que persistir en sesion.
	 */
	function get_data_sesion()
	{
		$fijos = array();
		$clave = array();
		$original = $this->get_valor();
		foreach ($this->columnas as $col) {
			$original[ml_fila__columna_disabled][$col->get_nombre()] = $col->get_disabled();
			
			if ($col instanceof form_elemento_fijo) {
				// se guardan los elementos fijos para luego restaurarlos sin
				// necesidad de hacer una consulta
				$fijos[$col->get_nombre()] = $col->get_valor();
			} else if ($col->get_nombre() == $this->columna_clave) {
				$clave[$col->get_nombre()] = $col->get_valor();
			}
		}

		return array(
			'clave' => $clave,
			'fijos' => $fijos,
			'original' => $original
		);
	}
	
	function tiene_titulo()
	{
		if (!empty($this->titulo)){
			return true;
		}
		return false;
	}
	
	function set_titulo($titulo)
	{
		$this->titulo = $titulo;
	}

	function get_titulo()
	{
		return $this->titulo;
	}
}

?>
