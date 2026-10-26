<?php

namespace Symfony\Component\Translation\Loader;

use Symfony\Component\Translation\MessageCatalogue;
use Symfony\Component\Config\Resource\FileResource;

class AndroidXMLFileLoader extends ArrayLoader implements LoaderInterface
{
    /**
     * {@inheritdoc}
     *
     * @api
     */
    public function load($resource, $locale, $domain = 'messages')
    {
        $messages = $this->parse($resource);
        
        $catalogue = parent::load($messages, $locale, $domain);
        $catalogue->addResource(new FileResource($resource));

        return $catalogue;
    }
    
    private function unquote($string)
    {
        return str_replace("\\'", "'", $string);
    }
    
    private function parse(& $resource)
    {
        $reader = new \XMLReader();
        $reader->XML($resource);
        $mensajes = array();
        $attr_name = null;
        while ($reader->read()) {
            if ($reader->nodeType == \XMLReader::ELEMENT) {
                if ($reader->name == 'string') {
                    $inner = $reader->readInnerXML();
                    if ($inner != '') {
                        $mensajes[$reader->getAttribute('name')] = $this->unquote($inner);
                    }
                }

                if ($reader->name == 'string-array') {
                    $attr_name = $reader->getAttribute('name');
                    self::$strings[$attr_name] = array();
                }
                if ($attr_name != null && $reader->name == 'item') {
                    self::$strings[$attr_name][] = self::unquote($reader->readInnerXML());
                }
            }
        }
        
        return $mensajes;
    }

}

?>