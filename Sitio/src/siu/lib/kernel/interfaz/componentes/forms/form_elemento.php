<?php
namespace kernel\interfaz\componentes\forms;

use kernel\error_kernel;
use kernel\kernel;
use kernel\util\validador;

class form_elemento
{
	protected $nombre;
	protected $def;
	protected $zend_element;
	protected $activo = true;
	protected $error = '';
	protected $valor;
	protected $id_form;
	protected $validacion_desactivada = false;

	/**
	 * @var vista_elemento
	 */
	protected $vista_elemento = null;


	function __construct($nombre, $def)
	{
		$this->nombre = $nombre;
		$this->def = $def;
	}

	function get_nombre()
	{
		return $this->nombre;
	}

	/**
	 * Se invoca esta función cuando el elemento se agrega a un form
	 */
	function added_to_form($id_form)
	{
		$this->id_form = $id_form;
	}

	function set_activo($activo)
	{
		$this->activo = $activo;
	}

	function get_activo()
	{
		return $this->activo;
	}

	function tiene_error()
	{
		return $this->error != '';
	}

	function set_zend_element(\Zend_Form_Element $e)
	{
		$this->zend_element = $e;
		if (isset($this->def[form_elemento_config::valor_default])) {
			$this->set_valor_zend_element($this->def[form_elemento_config::valor_default]);
		}
	}

	/**
	 * @return \Zend_Form_Element
	 */
	function get_zend_element()
	{
		return $this->zend_element;
	}

	function set_valor($valor)
	{
		$this->valor = $valor;
		$this->set_valor_zend_element($valor);
	}

	function set_valor_desde_post($valor)
	{
		$this->set_valor($valor);
	}

	function get_valor()
	{
		if (isset($this->valor)) {
			return $this->valor;
		}

		return $this->get_valor_default();
	}

	/**
	 * En algunos casos es necesario desactivar la validación. Por ejemplo un
	 * autocomplete que sólo se utiliza para cargar datos en un ML; otro caso es
	 * un botón. En el resto de los casos esta función NO SE DEBERÍA INVOCAR
	 */
	function desactivar_validacion()
	{
		$this->validacion_desactivada = true;
	}

	/**
	 * @return null|vista_elemento
	 */
	function get_vista_helper()
	{
		return $this->vista_elemento;
	}

	function set_vista_helper(vista_elemento $vista)
	{
		$this->vista_elemento = $vista;
		return $vista;
	}

	protected function set_valor_zend_element($valor)
	{
		$this->zend_element->setValue($valor);
		$this->zend_element->setAttrib('data-prev-value', $valor);
	}

	function set_data_html5($key, $valor)
	{
		$this->zend_element->setAttrib("data-$key", $valor);
	}

	protected function get_campo_def($campo, $default = null)
	{
		if (!isset($this->def[$campo]) && is_null($default)) {
			throw new error_kernel("el campo '$campo' es obligatorio en la definición de un form - Elemento:" . $this->get_id_html());
		}

		return (isset($this->def[$campo])) ? $this->def[$campo] : $default;
	}

	function get_id_html()
	{
		if ($this->tiene_group()) {
			return $this->id_form . '-' . $this->get_group() . '-' . $this->get_nombre();
		} else {
			return $this->id_form . '-' . $this->get_nombre();
		}
	}

	function get_group()
	{
		$group = $this->get_campo_def(form_elemento_config::group, '');
		return $group;
	}

	function tiene_group()
	{
		return $this->get_group() != '';
	}

	function get_disabled()
	{
		return $this->get_campo_def(form_elemento_config::disabled, false);
	}

	function set_disabled($disabled)
	{
		$this->def[form_elemento_config::disabled] = $disabled;
		$this->zend_element->setAttrib('disabled', $disabled ? 'disabled' : null);
	}

	function get_readonly()
	{
		return $this->get_campo_def(form_elemento_config::readonly, false);
	}

	function get_filtro()
	{
		return $this->get_campo_def(form_elemento_config::filtro);
	}

	function get_ayuda()
	{
		return $this->get_campo_def(form_elemento_config::ayuda, '');
	}

	function get_filtro_params()
	{
		return $this->get_campo_def(form_elemento_config::filtro_params, array());
	}

	function get_elemento_html()
	{
		return $this->get_campo_def(form_elemento_config::elemento);
	}

	function get_elemento_html_tipo()
	{
		$elem = $this->get_campo_def(form_elemento_config::elemento);
		return $elem['tipo'];
	}

	function get_label()
	{
		return kernel::traductor()->trans($this->get_campo_def(form_elemento_config::label, ''));
	}

	function get_clase_css()
	{
		return $this->get_campo_def(form_elemento_config::clase_css, '');
	}

	function get_largo()
	{
		return $this->get_campo_def(form_elemento_config::largo, 0);
	}

	function get_rows()
	{
		return $this->get_campo_def(form_elemento_config::rows, 0);
	}

	function get_checked_value()
	{
		return $this->get_campo_def(form_elemento_config::checked_value, '1');
	}

	function get_unchecked_value()
	{
		return $this->get_campo_def(form_elemento_config::unchecked_value, '0');
	}

	// solo campos de texto
	function get_placeholder()
	{
		return $this->get_campo_def(form_elemento_config::placeholder, '');
	}

	// refactor a clase form_campo_select
	function get_validar_select()
	{
		return $this->get_campo_def(form_elemento_config::validar_select, true);
	}

	function get_multi_options()
	{
		return $this->get_campo_def(form_elemento_config::multi_options, array());
	}

	function get_obligatorio()
	{
		return $this->get_campo_def(form_elemento_config::obligatorio, false);
	}

	function get_valor_default()
	{
		return $this->get_campo_def(form_elemento_config::valor_default, '');
	}


	function validar()
	{
		if ($this->validacion_desactivada) {
			return true;
		}

		$filtro = $this->get_filtro();
		$filtro_params = $this->get_filtro_params();
		$obligatorio = $this->get_activo() && $this->get_obligatorio();
		if (!$obligatorio) {
			$filtro_params['allowempty'] = true;
		}
		$largo = $this->get_largo();
		$valor = $this->get_valor();


		$error_filtro = !validador::es_valido($valor, $filtro, $filtro_params);
		$error_largo = ($largo > 0) && mb_strlen($valor) > $largo;

		$error_vacio = $obligatorio && (empty($valor) && $valor !== '0' && $valor !== 0);
		$error_select = false;
		if ($this->get_elemento_html_tipo() == 'select' && $this->get_validar_select()) {
			// se hace el chequeo del validador inarray
			$error_select = !$this->zend_element->isValid($valor);
		}

		$es_valido = !$error_filtro && !$error_largo && !$error_vacio && !$error_select;
		$msg = '';

		if (!$es_valido) {
			$msg = 'form_validacion_error.';
			if ($error_vacio) {
				$msg .= 'vacio';
			} elseif ($error_filtro) {
				$msg .= "filtro_$filtro";
			} elseif ($error_largo) {
				$msg .= 'largo';
			} elseif ($error_select) {
				$msg .= 'select';
			} else {
				$msg = '';
			}
		}

		if (!$es_valido) {
			$this->set_error($msg);
			\klog("error validacion. {$this->zend_element->getFullyQualifiedName()}:$msg. Valor provisto: '{$this->get_valor()}'");
			\klog($filtro_params);
		}

		return $es_valido;
	}

	public function set_error($msg)
	{
		$this->error = $msg;
	}

	function get_error()
	{
		return kernel::traductor()->trans($this->error);
	}

	function evt_pre_render()
	{
	}

	function set_hubo_error_form($hubo_error)
	{
	}
}

?>
