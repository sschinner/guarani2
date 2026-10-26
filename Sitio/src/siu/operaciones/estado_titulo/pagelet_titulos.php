<?php
namespace siu\operaciones\estado_titulo;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use kernel\util\u;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class pagelet_titulos extends pagelet
{
    function get_nombre()
    {
        return 'titulos';
    }

    function prepare()
    {
		$this->data['titulos'] = $this->controlador->get_data();
		
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf');
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear($operacion, 'generar_excel');
    }
}
?>