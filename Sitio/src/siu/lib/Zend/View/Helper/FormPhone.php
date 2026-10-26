<?php

/**
 * Abstract class for extension
 */
require_once 'Zend/View/Helper/FormElement.php';


/**
 * Helper to generate a "Phone" element
 *
 * This will print 3 text fields for taking seperate parts of phone number
 *
 * @author	Anis uddin Ahmad <anisniit@gmail.com>     
 */
class Zend_View_Helper_FormPhone extends Zend_View_Helper_FormElement
{

    /**
     * Generates a 'phone' element.
     *
     * @access public
     *
     * @param string|array $name If a string, the element name.  If an
     *      array, all other parameters are ignored, and the array elements
     *      are used in place of added parameters.
     * @param mixed $value The element value.
     * @param array $attribs Attributes for the element tag.
     *
     * @return string The element XHTML.
     */
    public function formPhone($name, $value = null, $attribs = null)
    {

        $info = $this->_getInfo($name, $value, $attribs);
        extract($info); // name, value, attribs, options, listsep, disable
        
        // build the element
        $disabled = '';
        if ($disable) {
            // disabled
            $disabled = ' disabled="disabled"';
        }

        $codeLength = $attribs['codeLength'];

        if(isset($attribs['separator_first'])){
            $separator_first = $attribs['separator_first'];
            unset($attribs['separator_first']);

            if($separator_first == ' ') $separator_first = '&nbsp;';
            
        } else {
            $separator_first = '';
        }
		
		if(isset($attribs['separator_second'])){
            $separator_second = $attribs['separator_second'];
            unset($attribs['separator_second']);

            if($separator_second == ' ') $separator = '&nbsp;';
            
        } else {
            $separator_second = '';
        }
        
		
        // XHTML or HTML end tag?
        $endTag = ' />';
        if (($this->view instanceof Zend_View_Abstract) && !$this->view->doctype()->isXhtml()) {
            $endTag= '>';
        }

        // Some attributes should not use as html attr
        unset($attribs['codeLength']);

        $class = $attribs['class'];
        $desepValue = str_replace($separator, '', $this->view->escape($value));

        // Code
		$attribs['value'] = "";
        $attribs['class'] = "telefono codigo";
        $attribs['maxlength'] = $codeLength['codigo'];		

        $xhtml = $separator_first.'<input type="text"'
                . ' name="' . $this->view->escape($name) . '_cod"'
                . ' id="' . $this->view->escape($id) . '_cod" MAXLENGHT=3'
                . ' value="" '
                . $disabled
                . $this->_htmlAttribs($attribs)
                . $endTag . $separator_second;

        // Print the field for Operator code
        $attribs['class'] = "telefono numero";
        $attribs['maxlength'] = $codeLength['numero'];

        $xhtml .= '<input type="text"'
                . ' name="' . $this->view->escape($name) . '_num"'
                . ' id="' . $this->view->escape($id) . '_num" '
                . ' value="" '
                . $disabled
                . $this->_htmlAttribs($attribs)
                . $endTag;

        return $xhtml;
    }
}