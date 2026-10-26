<?php
namespace siu\extension_kernel;

use kernel\kernel;
use kernel\util\u;

class form extends \Zend_Form
{
	protected $_memoria;
	protected $_nombre;
	protected $_csrf_activo;
	
	public function __construct($id, $options = null)
	{
		parent::__construct($options);
		$this->_nombre = $id;
		$this->_memoria = new \kernel\util\memoria\memoria_sesion($this->_nombre);
		$this->activar_csrf();
	}
	
	public function tiene_datos()
	{
		return kernel::request()->isPost();
	}
	
	public function activar_csrf()
	{
		$this->_csrf_activo = true;
	}
	
	public function desactivar_csrf()
	{
		$this->_csrf_activo = false;
	}
	
	public function es_valido()
	{
		if ($this->_csrf_activo) {
			$this->check_csrf(kernel::request()->getPost('csrf'));
		}
		
		return $this->isValid(kernel::request()->getPost());
	}
	
	protected function check_csrf($csrf_token)
	{
		return u::chequear_csrf_token($this->_memoria, $csrf_token);
	}
	
	protected function get_csrf()
	{
		return u::generar_csrf_token($this->_memoria);
	}
	
	public function render(Zend_View_Interface $view = null) {
		if ($this->_csrf_activo) {
			$element = new \Zend_Form_Element_Hidden('csrf');
			$element->setValue($this->get_csrf());
			$this->addElement($element);
		}
		
		return parent::render($view);
	}
}

?>
