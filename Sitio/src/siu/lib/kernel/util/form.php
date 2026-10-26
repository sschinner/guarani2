<?php
namespace kernel\util;

use kernel\kernel;
use kernel\error_kernel;

abstract class form 
{
	const filtro		= 'filtro';
	const filtro_params	= 'filtro_params';
	const largo			= 'largo';
	const obligatorio	= 'obligatorio';
	const label			= 'label';
	const clase_css		= 'clase_css';
	const elemento		= 'elemento_html';
	const sub_form		= 'subform';
	const disabled		= 'disabled';
	const readonly		= 'readonly';
	const multi_options	= 'multiOptions';
        const rows		= 'rows';
	const validar_select = 'validar_select';
	const tipo			= 'tipo';
	const valor_default = 'default';
	const placeholder = 'placeholder';
	const group = 'group';
	const ayuda = 'ayuda';
	const checked_value = 'checked_value';
	const unchecked_value = 'unchecked_value';
	
	protected $campos  = array();
	protected $datos = array();
	protected $errores = array();
	protected $csrf = false;
	protected $csrf_key = false;
	protected $desactivados = array();
	
	/**
	 * @var \Zend_Form
	 */
	protected $zend_form;
	
	function __construct()
	{
	}
	
	abstract function get_id_html();
	abstract function get_action();	
	protected abstract function generar_definicion();
	
	protected function set_campo($nombre, $def)
	{
		$this->campos[$nombre] = $def;
	}
	
	function get_campos()
	{
		return array_keys($this->campos);
	}
	
	function inicializar()
	{		
		$this->generar_definicion();
		$this->init_zend_form();
	}
	
	function procesar()
	{
		$this->inicializar();
		$this->set_datos_desde_post();
		return $this->validar();
	}
	
	/**
	 * 
	 * @param array $datos arreglo asociativo donde la clave es el nombre del campo
	 * y el valor es el valor que aparecerá en el elemento
	 */
	function set_datos($datos)
	{
		foreach (array_keys($this->campos) as $nombre) {
			$grupo = $this->get_group($nombre);
			$dato = '';
			if ($grupo != '') {
				if (isset($datos[$grupo]) && isset($datos[$grupo][$nombre])) {
					$dato = $datos[$grupo][$nombre];
				}
			} else {
				if (isset($datos[$nombre])) {
					$dato = $datos[$nombre];
				}
			}
			
			$this->set_dato($nombre, $dato);
		}
	}
	
	function set_datos_desde_post()
	{
		$id_form = $this->get_id_html();
		if (! isset($_POST[$id_form])) {
			throw new error_kernel("No existe el formulario '$id_form' en el post");
		}
		
		foreach (array_keys($this->campos) as $nombre) {
			$grupo = $this->get_group($nombre);
			$dato = '';
			if ($grupo != '') {
				if (isset($_POST[$id_form][$grupo]) && isset($_POST[$id_form][$grupo][$nombre])) {
					$dato = $_POST[$id_form][$grupo][$nombre];
				}
			} else {
				if (isset($_POST[$id_form][$nombre])) {
					$dato = $_POST[$id_form][$nombre];
				}
			}
			
			$this->set_dato($nombre, $dato);
		}
	}
	
	function validar()
	{
		$form_valido = true;
		foreach (array_keys($this->campos) as $nombre) {
			list($valido, $msg) = $this->validar_campo($nombre, $this->get_dato($nombre));
			if (! $valido) {
				$form_valido = false;
				$this->agregar_error($nombre, $msg);
			}
		}
		return $form_valido;
	}
	
	function desactivar_campo($nombre)
	{
		if (isset($this->campos[$nombre])) {
			$grupo = $this->get_group($nombre);
			if ($grupo != '') {
				unset($this->datos[$grupo][$nombre]);
			} else {
				unset($this->datos[$nombre]);
			}
			unset($this->campos[$nombre]);
		}
		
		$this->desactivados[$nombre] = true;
	}
	
	function tiene_datos()
	{
		return isset($this->datos) && !empty($this->datos);
	}
	
	function get_datos()
	{
		return $this->datos;
	}
	
	protected function set_dato($nombre, $dato)
	{
		$grupo = $this->get_group($nombre);
		if ($grupo != '') {
			$this->datos[$grupo][$nombre] = $dato;
		} else {
			$this->datos[$nombre] = $dato;
		}
		
		$this->get_zend_form()->getElement($nombre)->setValue($dato);
		$this->get_zend_form()->getElement($nombre)->setAttrib('data-prev-value', $dato);
	}
	
	function get_dato($nombre, $default = '')
	{
		$grupo = $this->get_group($nombre);
		if ($grupo != '') {
			if (isset($this->datos[$grupo][$nombre])) {
				return $this->datos[$grupo][$nombre];
			}	
		} else {
			if (isset($this->datos[$nombre])) {
				return $this->datos[$nombre];
			}			
		}
		
		if (isset($this->campos[$nombre][form::valor_default])) {
			return $this->campos[$nombre][form::valor_default];
		}
		
		return $default;
	}
	
	function get_campos_grupo($grupo)
	{
		$campos = $this->get_campos();
		$campos_grupo = array();
		foreach ($campos as $campo) {
			if ($this->get_group($campo) == $grupo) {
				$campos_grupo[] = $campo;
			}
		}
		
		return $campos_grupo;
	}
	
	function tiene_error($nombre)
	{
		return isset($this->errores[$nombre]);
	}
	
	function tiene_errores()
	{
		return ! empty($this->errores);
	}

	function get_errores()
	{
		return $this->errores;
	}
	
	function activar_csrf($key)
	{
		$this->csrf = true;
		$this->csrf_key = $key;
	}
	
	function desactivar_csrf()
	{
		$this->csrf = false;
	}
	
	/**
	 *
	 * @param type $nombre
	 * @param type $msg 
	 */
	function agregar_error($nombre, $msg)
	{
		$this->errores[$nombre] = $msg;
	}
	
	/*************************************************************************/
	// GENERACIÓN HTML PARA EL TWIG
	/*************************************************************************/
		
	function encabezado()
	{
		$this->init_zend_form();
		$html = "<form id='{$this->get_id_html()}' action='{$this->get_action()}' method='post'>";
		if ($this->csrf) {
			$nombre_csrf = \kernel\nucleo\controlador::CSRF_KEY;
			$html .= "<input type='hidden' name='$nombre_csrf' value='$this->csrf_key'>";			
		}
		
		return $html;
	}
	
	function elemento($nombre)
	{
		if (!$this->check_activo($nombre)) {return '';}
		return $this->zend_form->getElement($nombre)->renderViewHelper();
	}
	
	function raw_label($nombre)
	{
		return $this->get_label($nombre);
	}
	
	function label($nombre)
	{
		if (!$this->check_activo($nombre)) {return '';}
		return $this->zend_form->getElement($nombre)->renderLabel();
	}
	
	function ayuda($nombre)
	{
		if (!$this->check_activo($nombre)) {return '';}
		$ayuda = $this->get_ayuda($nombre);
		if ($ayuda != '') {
			return "<span class='form-ayuda' title='$ayuda'><i class='icon-question-sign'></i></span>";
		}
		
		return '';
	}
	
	function error($nombre)
	{
		if (!$this->check_activo($nombre)) {return '';}
		if ($this->tiene_error($nombre)) {
			return kernel::traductor()->trans($this->errores[$nombre]);
		}
		
		return '';
	}
	
	function control_group($nombre, $clase_control_group = '')
	{
		if (!$this->check_activo($nombre)) {return '';}
		if ($this->get_elemento_html_tipo($nombre) == 'hidden') {
			return $this->elemento($nombre);
		}
		$label = $this->label($nombre);
		
		if (!$this->get_obligatorio($nombre)) {
			$label = '<span class="label-no-obligatorio">'.$label.'</span>';
		}
		$elemento = $this->elemento($nombre);
		$tiene_error = $this->tiene_error($nombre);
		$clase_error = ($tiene_error) ? 'error' : '';
		
		$html  = "<div class='control-group $clase_control_group $clase_error'>";
		$html .= $label;
		$html .= $elemento;
		$html .= $this->ayuda($nombre);
		if ($tiene_error) {
			$html .= "<span class='help-inline'>{$this->error($nombre)}</span>";
		}
		$html .= "</div>";
		
		return $html;
	}
	
	function checkbox($nombre)
	{
		if (!$this->check_activo($nombre)) {return '';}
		$id = $this->zend_form->getElement($nombre)->getId();
		$html  = "<label for='$id' class='optional checkbox'>";
		
		$label = kernel::traductor()->trans($this->raw_label($nombre));
		$ayuda = $this->ayuda($nombre);
		if (!$this->get_obligatorio($nombre)) {
			$label = '<span class="label-no-obligatorio">'.$label.'</span>';
		}
		$label .= $ayuda;
		$html .= $label.$this->elemento($nombre);
		$html .= "</label>";
		return $html;
	}
	
	function submit_button($nombre, $valor)
	{
		if (!$this->check_activo($nombre)) {return '';}
		$valor = kernel::traductor()->trans($valor);
		$html = "<button id='$nombre' name='$nombre' type='submit' class='btn btn-info'>$valor</button>";
		
		return $html;
	}
	
	protected function check_activo($nombre)
	{
		return !isset($this->desactivados[$nombre]) || !$this->desactivados[$nombre];
	}
	
	// VARIOS
	
	protected function get_full_def_campo($nombre)
	{
		if (!isset($this->campos[$nombre])) {
			throw new error_kernel("El campo '$nombre' no existe en el formulario");
		}
		return $this->campos[$nombre];
	}

	/**
	 *
	 * @return \Zend_Form
	 * @throws error_kernel 
	 */
	protected function get_zend_form()
	{
		if (!isset($this->zend_form)) {
			throw new error_kernel('El formulario no fue inicializado');
		}
		return $this->zend_form;
	}
	
	protected function init_zend_form($force = false)
	{
		if (isset($this->zend_form) && !$force) {
			return;
		}
		
		$this->zend_form = new \Zend_Form();
		$view = new \Zend_View();
		$view->setEncoding(kernel::proyecto()->get_encoding());
		$this->zend_form->setView($view);
		
		foreach (array_keys($this->campos) as $nombre) {
			$element = $this->crear_zend_element($nombre);
			$element->setView($view);
			$this->zend_form->addElement($element);
		}
	}
	
	protected function crear_zend_element($nombre)
	{
		$def = $this->get_full_def_campo($nombre);
		
		$params_zend = array();
		if (isset($def[self::disabled]) && $def[self::disabled]) {
			$params_zend['disabled'] = true;
		}
		
		if (isset($def[self::readonly]) && $def[self::readonly]) {
			$params_zend['readonly'] = true;
		}
		
		if (isset($def['largo'])) {
			$params_zend['maxlength'] = $def['largo'];
		}
		
		if (isset($def['label'])) {
			$params_zend['label'] = kernel::traductor()->trans($def['label']);
		} else {
			$params_zend['label'] = kernel::traductor()->trans("censo.$campo_nombre");
		}

		$params_zend['class'] = '';
		if (isset($def['clase_css'])) {
			$params_zend['class'] = $def['clase_css'];
		}

		// obligatorio
		if (isset($def['obligatorio']) && $def['obligatorio']) {
			$params_zend['class'] .= ' require';
			$params_zend['allowEmpty'] = false;
		}
		
		// readonly
		if (isset($def['elemento_html']['readonly']) && $def['elemento_html']['readonly']) {
			$params_zend['readonly'] = 'readonly';
		}


		switch ($def['elemento_html']['tipo']) {
			case 'text':
				$clase = "\Zend_Form_Element_Text";
				break;
			case 'textarea':
				$clase = "\Zend_Form_Element_Textarea";
				$params_zend['rows'] = $def[form::rows];
				break;
			case 'select':
				$clase = "\Zend_Form_Element_Select";
				$params_zend['multiOptions'] = $def[form::multi_options];
				break;
			case 'radio':
				$clase = "\Zend_Form_Element_Radio";
				$params_zend['separator'] = '';
				$params_zend['multiOptions'] = $def[form::multi_options];
				break;
			case 'checkbox':
				$clase = "\Zend_Form_Element_Checkbox";
				$params_zend['CheckedValue'] = (isset($def[self::checked_value])) ? $def[self::checked_value] : '1';
				$params_zend['UncheckedValue'] = (isset($def[self::unchecked_value])) ? $def[self::unchecked_value] : '0';
				break;
			case 'hidden':
				$clase = "\Zend_Form_Element_Hidden";
				break;
			case 'password':
				$clase = "\Zend_Form_Element_Password";
				break;

			default:
				break;
		}

		$zend_element = new $clase($nombre, $params_zend);
		$belongs_to = ($this->get_group($nombre) == '') ? $this->get_id_html() : $this->get_id_html().'['.$this->get_group($nombre).']';
		$zend_element->setBelongsTo($belongs_to);
	
		if (isset($def[form::placeholder])) {
			$zend_element->setAttrib('placeholder', kernel::traductor()->trans($def[form::placeholder]));
		}
		
		if ($def['elemento_html']['tipo'] == 'select') {
			$zend_element->addValidator(new \Zend_Validate_InArray(array_keys($params_zend['multiOptions'])));
		}
		
		return $zend_element;
	}
	
	protected function validar_campo($nombre, $valor)
	{
		// http://framework.zend.com/manual/en/zend.form.elements.html#zend.form.elements.validators
		$filtro		 = $this->get_filtro($nombre);
		$filtro_params = $this->get_filtro_params($nombre);
		$obligatorio = $this->check_activo($nombre) && $this->get_obligatorio($nombre);
		$largo		 = $this->get_largo($nombre);
		
		$error_filtro = ! validador::es_valido($valor, $filtro, $filtro_params);
		$error_largo  = ($largo > 0) && mb_strlen($valor) > $largo;
		
		$error_vacio  = $obligatorio && (empty($valor) && $valor !== '0' && $valor !== 0);
		$error_select = false;
		if ($this->get_elemento_html_tipo($nombre) == 'select' && $this->get_validar_select($nombre)) {
			// se hace el chequeo del validador inarray
			$error_select = ! $this->zend_form->getElement($nombre)->isValid($valor);
		}
		
		$es_valido = ! $error_filtro && ! $error_largo && ! $error_vacio && ! $error_select;
		$msg = '';
		
		if (! $es_valido) {
			$msg = 'form_validacion_error.';
			if ($error_filtro) {
				$msg .= "filtro_$filtro";
			} elseif ($error_largo) {
				$msg .= 'largo';
			} elseif ($error_vacio) {
				$msg .= 'vacio';
			} elseif ($error_select) {
				$msg .= 'select';
			}
		}
		if (!$es_valido) {
			\klog("error validacion. $nombre:$msg");
		}
		return array($es_valido, $msg);
	}	
	
	protected function cargar_datos_post()
	{
		$this->datos = kernel::request()->getPost($this->get_id_html(), array());
	}
	
	// ACCESO DEFINCIÓN DE CAMPOS
		
	protected function get_campo_def($nombre, $campo, $default = null)
	{
		$def = $this->get_full_def_campo($nombre);
		if (!isset($def[$campo]) && is_null($default)) {
			throw new \kernel\error_kernel("el campo '$campo' es obligatorio en la definición de un form");
		}
		
		return (isset($def[$campo])) ? $def[$campo] : $default;
	}
		
	protected function get_group($nombre)
	{
		$group = $this->get_campo_def($nombre, form::group, '');
		
		return $group;
	}

	protected function get_filtro($nombre)
	{
		return $this->get_campo_def($nombre, form::filtro);
	}
	
	protected function get_ayuda($nombre)
	{
		return $this->get_campo_def($nombre, form::ayuda, '');
	}
	
	protected function get_filtro_params($nombre)
	{
		return $this->get_campo_def($nombre, form::filtro_params, array());
	}

	protected function get_elemento_html($nombre)
	{
		return $this->get_campo_def($nombre, form::elemento);
	}

	protected function get_elemento_html_tipo($nombre)
	{
		$elem = $this->get_campo_def($nombre, form::elemento);
		return $elem['tipo'];
	}
	
	protected function get_label($nombre)
	{
		return $this->get_campo_def($nombre, form::label, '');
	}

	protected function get_clase_css($nombre)
	{
		return $this->get_campo_def($nombre, form::clase_css, '');
	}
	
	protected function get_largo($nombre)
	{
		return $this->get_campo_def($nombre, form::largo, 0);
	}
	
	protected function get_validar_select($nombre)
	{
		return $this->get_campo_def($nombre, form::validar_select, true);
	}
	
	protected function get_obligatorio($nombre)
	{
		return $this->get_campo_def($nombre, form::obligatorio, false);
	}
}

?>
