<?php

namespace personalizacionPROCAP\operaciones\acta_examenes;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
//use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\acta_examenes\controlador {

    private function buscar_acta($hash_acta) {
        $parametros = array(
            'nro_inscripcion' => kernel::persona()->get_nro_inscripcion(),
            'anio_academico' => null,
            'turno' => null,
            'nombre' => null,
        );
        $datos = catalogo::consultar('docente', 'acta_examenes', $parametros);
        foreach ($datos as $dato) {
            if ($dato['URL_ACTA'] == $hash_acta) {
                return $dato['ACTA'];
            }
        }
        return false;
    }

    public function accion__generar_pdf_acta() {
        $hash_acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
        $this->acta = $this->buscar_acta($hash_acta);
        $this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);
        $data = $this->get_info_acta();
        $nombreLogueado=kernel::persona()->get_nombre();
        $pdf = new \personalizacionPROCAP\operaciones\_comun\operaciones\reporte\generador_pdf_ActaExamen('P', 'mm', 'A4', true, 'UTF-8', false);
        $pdf->imprimir($data,$nombreLogueado);
        ob_flush();
    }

}

?>