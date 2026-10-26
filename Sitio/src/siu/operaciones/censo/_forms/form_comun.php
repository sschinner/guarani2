<?php
namespace siu\operaciones\censo\_forms;
use siu\extension_kernel\form as form_base;
use kernel\kernel;
use siu\operaciones\censo\modelo;
use siu\modelo\datos\catalogo;
use siu\conf\definicion_datos_censales;
use siu\conf\datos_comunes;

abstract class form_comun extends form_base
{
	protected $modelo;
	protected $form='comun';
	protected $datos;

	function __construct($params)
	{
		$id = $params['id'];
		if (isset($params['datos'])) {
			$this->datos = $params['datos'];
		}
		kernel::log()->add_debug('datos censales datos', $this->datos);

		parent::__construct($id, $params);
	}
	
	public function get_template()
	{
		return $this->form;
	}

	public function get_idhtml() 
	{
		return $this->form;
	}

	protected function crear_elementos()
	{
		$datos = $this->datos;
		$form_id = new \Zend_Form_Element_Hidden('form_id');
		$form_id->setValue($this->get_idhtml());

		$this->setAction(kernel::vinculador()->crear('censo', $this->form));
		$this->setAttrib('id', "censo_$this->form");
		$this->addElement($form_id);

		$campos = definicion_datos_censales::get_campos($this->form);
		kernel::log()->add_debug('campos', $campos);
		foreach ($campos as $campo_nombre) {
			
			$campo = definicion_datos_censales::get_campo($campo_nombre);
			$definicion = array ();
			if (isset($campo['largo'])) {
				$definicion['maxlength'] = $campo['largo'];
			}
			// label
			if (isset($campo['label'])) {
				$definicion['label'] = $campo['label'];
			} else {
				$definicion['label'] =  kernel::traductor()->trans("censo.$this->form.$campo_nombre");
			}

			if (isset($campo['clase_css'])) {
				$definicion['class'] = $campo['clase_css'];
			} 

			// obligatorio
			if(isset ($campo['obligatorio']) && $campo['obligatorio']) {
				$definicion['class'] .= ' require obligatorio';
				$definicion['allowEmpty'] = false;
			}
			// readonly

			if (isset ($campo['elemento_html']['readonly']) && $campo['elemento_html']['readonly']) {
				$definicion['readonly'] = 'readonly';
			}

			switch ($campo['elemento_html']['nombre']) {
				case 'text':
					$clase = "\Zend_Form_Element_Text";
					break;
				case 'select':
					$clase = "\Zend_Form_Element_Select";
					$definicion['multiOptions'] = datos_comunes::get($campo_nombre);
					break;
				case 'radio':
					$clase = "\Zend_Form_Element_Radio";
					$definicion['separator'] = '';
					$definicion['multiOptions'] = datos_comunes::get($campo_nombre);
					break;
				case 'checkbox':
					$clase = "\Zend_Form_Element_Checkbox";
					$definicion['CheckedValue'] = 'S';
					$definicion['UncheckedValue'] = 'N';
					break;
				case 'hidden':
					$clase = "\Zend_Form_Element_Hidden";
					break;

				default:
					break;
			}

			$elemento = new $clase($campo_nombre, $definicion);
			$elemento->setValue($datos[$campo_nombre]);

			if ($campo['elemento_html']['nombre'] == 'select') {
				$elemento->addValidator(new \Zend_Validate_InArray(array_keys($definicion['multiOptions'])));
			}

			$this->addElement($elemento);
		}
	}

	public function setView(\Zend_View_Interface $view)
	{
		$view->setEncoding('ISO-8859-1');
		parent::setView($view);
		foreach ($this as $item){
			$item->setView($view);
		}
		return $this;
	}

	function modelo()
	{
		if (!isset($this->modelo)) {
			$this->modelo = new modelo();
		}
		return $this->modelo;
	}

	function get_datos()
	{
		if (! kernel::sesion()->esta_seteada('form_datos_censales') )
		{
			$nro_inscripcion = kernel::persona()->get_nro_inscripcion();
			$datos = catalogo::consultar('datos_censales', 'get_datos',
									array('nro_inscripcion'=>$nro_inscripcion));
			kernel::sesion()->set('form_datos_censales', $datos);
		}
		else
		{
			$datos = kernel::sesion()->get('form_datos_censales');
		}
		return $datos;
	}

	function render(Zend_View_Interface $view = null)
	{
		return parent::render($view);
	}
}
?>