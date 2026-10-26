<?php

require_once 'Zend/Form/Element/Xhtml.php';

class Zend_Form_Element_Phone extends Zend_Form_Element_Xhtml
{
    /**
     * Default form view helper to use for rendering
     * @var string
     */
    public $helper = 'formPhone';
    
    public $options;

    /**
     * Length of phone number parts
     * 
     * @var array
     */
    public $codeLength = array(
        'codigo' => 3,
        'numero' => 6,
    );

    public function __construct($field_name, $attributes = null, $data_item = null) {
        $this->options = $data_item;

        // Set special attributes for Phone number
        if(!isset($attributes['codeLength'])){
            $attributes['codeLength'] = $this->codeLength;
        }
        parent::__construct($field_name, $attributes);
    }

    /**
     * Validate element value
     *
     * Note: The *filtered* value is validated.
     *
     * @param  mixed $value
     * @param  mixed $context
     * @return boolean
     */
    public function isValid($value, $context = null)
    {
        $attributes = $this->getAttribs();
        
        $name = $this->getName();
        
        $joinedValue = $context[$name . '_cod'] . $context[$name . '_num'];

        return parent::isValid($joinedValue, $context);
    }
}
