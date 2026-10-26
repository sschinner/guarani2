<?php

namespace kernel\interfaz\componentes\forms\elementos;


use kernel\error_kernel;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\util\validador;

class form_elemento_autocomplete extends form_elemento
{
	protected $fn_autocomplete;
	// existe el valor seteado con set_valor en la lista de autocomplete
	protected $existe_valor = false;
	protected $texto;

	function __construct($nombre, $def)
	{
		$conf_base = array(
			form_elemento_config::filtro		=>  validador::TIPO_INT,
			form_elemento_config::elemento      =>  array('tipo' => 'text')
		);
		$def = array_merge($conf_base, $def);
		parent::__construct($nombre, $def);
		//$this->def[form_elemento_config::filtro] = array('tipo' => 'text')
	}

	function set_fn_autocomplete($fn_autocomplete)
	{
		$this->fn_autocomplete = $fn_autocomplete;
		$this->update_texto_autocomplete();
		return $this;
	}

	protected function set_valor_zend_element($valor)
	{
		parent::set_valor_zend_element($valor);
		$texto = ($this->existe_valor) ? $this->texto : '';
		$this->zend_element->setAttrib('data-texto', $texto);
	}

	function set_valor($valor)
	{
		$this->valor = $valor;
		if (parent::validar()) {
			// se actualiza sólo si es válido. Sino se puede invocar la consulta
			// con una inyección
			$this->update_texto_autocomplete();
		}
		$this->set_valor_zend_element($valor);
	}

	protected function update_texto_autocomplete()
	{
		if (!isset($this->fn_autocomplete)) {
			throw new error_kernel('Se debe setear una función para el elemento autocomplete con el método set_fn_autocomplete');
		}
		$valor = $this->get_valor();
		$fn = $this->fn_autocomplete;
		$resultado = $fn($valor);
		if(is_array($resultado)) {
			list($this->texto, $data_html5) = $resultado;
			foreach ($data_html5 as $key => $val) {
				$this->set_data_html5($key, $val);
			}
		} else {
			$this->texto = $resultado;
		}
		$this->existe_valor = $this->texto !== false;
	}


	function validar()
	{
		if ($this->validacion_desactivada) {
			return true;
		}

		$es_valido = parent::validar();
		if (!$this->existe_valor) {
			$es_valido = false;
		}
		return $es_valido;
	}

}

?>
