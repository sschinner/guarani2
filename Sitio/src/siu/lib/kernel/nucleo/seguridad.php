<?php
namespace kernel\nucleo;

require_once("class.inputfilter.php");

//Ver http://donnierock.com/2013/01/04/evitar-ataques-xss-con-php-input-filter/
class seguridad {

    public function sanitizeXSS($input, $tags_permitidos = array(), $atributos_permitidos = array()){
        //Por ejemplo:
        //$tags_permitidos = array('p', 'strong', 'em', 'u', 'span', 'ol', 'ul', 'li', 'br');
        //$atributos_permitidos = array('style');
        $filter = new \InputFilter($tags_permitidos, $atributos_permitidos);
        return $filter->process($input);
    }

}