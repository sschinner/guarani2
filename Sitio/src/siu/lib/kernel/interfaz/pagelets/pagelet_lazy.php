<?php
namespace kernel\interfaz\pagelets;
use kernel\interfaz\pagelet;

class pagelet_lazy extends pagelet
{
    protected function init()
    {

    }

    function prepare()
    {
        sleep(1);
        $this->data[] = 'item4';
        $this->data[] = 'item5';
    }

    function get_content()
    {
        if (empty($this->data)) {
            return;
        }
        $rs = '<ul>';

        foreach($this->data as $list_item) {
            $rs .= "<li>$list_item</li>";
        }

        $rs .= '</ul>';

        return $rs;
    }

    public function get_css_files()
    {
        return array('/css_2.6.0/browser.css');
    }

    public function get_js_files()
    {
        return array('/js_pocketband/prueba1.js', '/js_pocketband/prueba2.js');
    }
}
?>
