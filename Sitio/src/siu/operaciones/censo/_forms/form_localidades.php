<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\forms;

class form_localidades extends form_comun
{
	protected $form = 'localidades';

	public function init()
	{
		$paises = catalogo::consultar('etiquetas', 'paises');
		$paises  = forms::rs_to_select($paises,'-- SELECCIONE --');

		$label = kernel::traductor()->trans('censo.localidad.pais');
		$pais = new \Zend_Form_Element_Select('pais', array(
			'label' => $label, 
			'multiOptions' => array('Paises' => $paises)
		));
		$pais->setValue('');

		$label = kernel::traductor()->trans('censo.localidad.provincia');
		$provincia = new \Zend_Form_Element_Select('provincia', array(
			'label' => $label
		));
		$provincia->setValue('');
				
		$label = kernel::traductor()->trans('censo.localidad.localidad');
		$localidad = new \Zend_Form_Element_Text('localidad', array(
			'label' => $label
		));
		$localidad->setValue('');

		$label = kernel::traductor()->trans('censo.localidad.buscar');
		$buscar = new \Zend_Form_Element_Submit('buscar', array(
			'label' => $label
		));

		$label = kernel::traductor()->trans('censo.localidad.cancelar');
		$cancelar = new \Zend_Form_Element_Submit('cancelar', array(
			'label' => $label
		));

		$this->setAction(kernel::vinculador()->crear('censo', 'localidades'))
			->setAttrib('id', 'censo_localidades')
			->addElement($pais)
			->addElement($provincia)
			->addElement($localidad)
			->addElement($cancelar)
			->addElement($buscar);
	}
}
?>