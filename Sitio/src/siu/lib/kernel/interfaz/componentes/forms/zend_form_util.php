<?php
namespace kernel\interfaz\componentes\forms;

use kernel\interfaz\componentes\forms\elementos\form_elemento_fijo;
use kernel\interfaz\componentes\forms\elementos\form_elemento_ml;
use kernel\kernel;

class zend_form_util
{
	function __construct()
	{

	}

	/**
	 * Agrega zend_elements a todos los campos para que posteriormente se puedan
	 * renderizar y validar usando los elementos de zend
	 * @param type $form_id
	 * @param type $campos
	 * @return \Zend_Form
	 */
	function populate_fields($form_id, $campos)
	{
		$zend_form = new \Zend_Form();
		$view = new \Zend_View();
		$view->setEncoding(kernel::proyecto()->get_encoding());
		$zend_form->setView($view);

		foreach ($campos as $nombre => $campo) {
			if ($campo instanceof form_elemento_ml) {
				// los mls crean un zend form aparte xq lo tienen que crear
				// dp que le setean los datos
				continue;
			} else if ($campo instanceof form_elemento_fijo) {
				continue;
			} else {
				$element = $this->crear_elemento($form_id, $campo);
				$element->setView($view);
				$zend_form->addElement($element);
				$campo->set_zend_element($element);
			}
		}
	}

	function crear_elemento($form_id, form_elemento $campo)
	{
		$params_zend = array();
		if ($campo->get_disabled()) {
			$params_zend['disabled'] = true;
		}

		if ($campo->get_readonly()) {
			$params_zend['readonly'] = true;
		}

		if ($campo->get_largo() > 0) {
			$params_zend['maxlength'] = $campo->get_largo();
		}

		if ($campo->get_label() != '') {
			$params_zend['label'] = kernel::traductor()->trans($campo->get_label());
		} else {
			$params_zend['label'] = kernel::traductor()->trans($campo->get_nombre());
		}

		$params_zend['class'] = '';
		if ($campo->get_clase_css() != '') {
			$params_zend['class'] = $campo->get_clase_css();
		}

		// obligatorio
		if ($campo->get_obligatorio()) {
			$params_zend['class'] .= ' require';
			$params_zend['allowEmpty'] = false;
		}

		/**
		 * @var \Zend_Form_Element
		 */
		$zend_element = $this->crear_zend_element($campo, $params_zend);
		$belongs_to = ($campo->get_group() == '') ? $form_id : $form_id . '[' . $campo->get_group() . ']';
		$zend_element->setBelongsTo($belongs_to);

		if ($campo->get_placeholder() != '') {
			$zend_element->setAttrib('placeholder', kernel::traductor()->trans($campo->get_placeholder()));
		}

		if ($campo->get_elemento_html_tipo() == 'select' || $campo instanceof form_elemento_multi) {
			$zend_element->addValidator(new \Zend_Validate_InArray(array_keys($params_zend['multiOptions'])));
		}

		return $zend_element;
	}

	protected function crear_zend_element($campo, &$params_zend, $nombre = null)
	{
		switch ($campo->get_elemento_html_tipo()) {
			case 'text':
				$clase = "\Zend_Form_Element_Text";
				break;
			case 'textarea':
				$clase = "\Zend_Form_Element_Textarea";
				$params_zend['rows'] = $campo->get_rows();
				break;
			case 'button':
				$clase = "\Zend_Form_Element_Button";
				break;
			case 'select':
				$clase = "\Zend_Form_Element_Select";
				$params_zend['multiOptions'] = $campo->get_multi_options();
				break;
			case 'radio':
				$clase = "\Zend_Form_Element_Radio";
				$params_zend['separator'] = '';
				$params_zend['multiOptions'] = $campo->get_multi_options();
				break;
			case 'checkbox':
				$clase = "\Zend_Form_Element_Checkbox";
				$params_zend['CheckedValue'] = $campo->get_checked_value();
				$params_zend['UncheckedValue'] = $campo->get_unchecked_value();
				break;
			case 'hidden':
				$clase = "\Zend_Form_Element_Hidden";
				break;
			case 'password':
				$clase = "\Zend_Form_Element_Password";
				break;
			case 'multicheckbox':
				$clase = "\Zend_Form_Element_MultiCheckbox";
				$params_zend['multiOptions'] = $campo->get_multi_options();
				$params_zend['separator'] = '';
				break;
			default:
				throw new \kernel\error_kernel("no existe el elemento de tipo '{$campo->get_elemento_html_tipo()}'");
				break;
		}

		$nombre_elem = !is_null($nombre) ? $nombre : $campo->get_nombre();
		return new $clase($nombre_elem, $params_zend);
	}

}

?>
