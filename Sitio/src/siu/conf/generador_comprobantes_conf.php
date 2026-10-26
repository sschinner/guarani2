<?php
namespace siu\conf;

class generador_comprobantes_conf
{
    // cambiar aca
    protected $oopt = array(
        'alto' => 0,
        'ancho' => 0,
        'encabezado' => array(),
        'titulo' => "",
        'subtitulo' => "",
        'tabla' => array(),
        'background_color' => array(255,255,255),
        'fuente_color_defecto' => array(84,84,84),
        'etiqueta_color_defecto' => array(102,102,102),
        'borde' => array('color' => array(190,190,190), 'ancho' => 1),
        'estilos' => array(
            'Nro transacci?n' => array(
                    'color' => array(205,51,51), 
                    'tamanio' => 14
            )),
        'tamano_fuente' => 11,
        'tamano_fuente_titulo' => 13,
        'tamano_fuente_subtitulo' => 12,
        'tamano_fuente_encabezado' => 9,
        'interlineado' => 10,
        'font' => "Courier.afm",
        'fontBold' => "Courier.afm",
        'margen' => 10,
        
        // determina desde que posicion vertical se comienza a renderizar el cuerpo.
        'set_offset_cuerpo' => 100        
    );
    
    
    function set($clave, $valor){
        $this->oopt[$clave] = $valor;
    }
    
    function get($clave)
    {
        // chequear isset(
        if (isset($this->oopt[$clave])){
            return $this->oopt[$clave];
        }
		return array();
    }
}
?>
