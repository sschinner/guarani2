<?php
namespace siu\operaciones\inscripciones;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_examenes extends pagelet {

    function ini() {
        
    }

    function get_nombre() {
        return 'examenes';
    }

    function get_alcance() {
        return $this->controlador->get_var('alcance_examenes', 'A');
    }

    function datos() {
        // parametros
        $parametros_examen = array();
        $parametros_examen['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros_examen['estado'] = "T";

        if ($this->get_alcance() == "T") {
            $parametros_examen['alcance'] = "T";
            $historico = true;
        } else {
            $parametros_examen['alcance'] = "A";
            $historico = false;
        }

        // datos
        $inscripciones_examen_rechazadas = $this->datos_consulta = catalogo::consultar('alumno', 'inscripciones_examen_rechazadas', $parametros_examen);
        $inscripciones_examenes = $this->datos_consulta = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros_examen);
        $examenes = array_merge($inscripciones_examen_rechazadas, $inscripciones_examenes);

        foreach ($examenes as $key => $examen) {
            if ($examen['estado'] != 'Rechazado') {
                $examenes[$key]['fecha_inscr'] = substr($examen['fecha_inscr'], 0, 10);
                $examenes[$key]['url_comp'] = kernel::vinculador()->crear('inscripciones', 'generar_comprobante_examen', array('materia' => $examen['url_materia'],
                    'transaccion' => $examen['url_nro_transaccion'],
                    'historico' => $historico)
                );
            } else {
                unset($examenes[$key]['url_comp']);
            }
        }

        self::ordenar_desc($examenes);
        return $examenes;
    }

    static function ordenar_desc(&$lista) {
        uasort($lista, function($a, $b) {
            return strcasecmp($b['orden'], $a['orden']);
        });
    }

    function prepare() {
        $operacion = kernel::ruteador()->get_id_operacion();
        $this->add_var_js('url_examenes', kernel::vinculador()->crear($operacion, 'examenes'));
        $this->data['examenes'] = $this->datos();
        $this->data['alcance_examenes'] = $this->get_alcance();
        $this->data['url_pdf_examen'] = kernel::vinculador()->crear('solicitud_certificado', 'exportar_pdf_examen');
        $this->data['pdf_lista'] = kernel::vinculador()->crear($operacion, 'generar_pdf', array('examen', $this->get_alcance()));
        $this->data['xls_lista'] = kernel::vinculador()->crear($operacion, 'generar_xls', array('examen', $this->get_alcance()));
    }

}

?>