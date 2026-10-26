<?php
namespace siu\operaciones\solicitud_certificado;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;


class pagelet_certificado_evaluacion extends pagelet {

    public function get_nombre(){
        return 'certificado_evaluacion';
    }

    function get_alcance_cursadas()
    {
        return $this->controlador->get_var_default('alcance_cursadas', 'A');
    }

    function get_alcance_examenes()
    {
        return $this->controlador->get_var_default('alcance_examenes', 'A');
    }

    function prepare() {

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros['estado'] = "T";

        if ($this->get_alcance_cursadas() == "T"){
            $parametros['alcance'] = "T";
        } else {
            $parametros['alcance'] = "A";
        }

        $this->data['alcance_cursadas'] = $this->get_alcance_cursadas();
        $this->data['listado_evaluaciones_parciales'] = catalogo::consultar('certificados', 'listado_evaluaciones_parciales', $parametros);

        if ($this->get_alcance_examenes() == "T"){
            $parametros['alcance'] = "T";
        } else {
            $parametros['alcance'] = "A";
        }

        $this->data['alcance_examenes'] = $this->get_alcance_examenes();
        $this->data['listado_evaluaciones_examenes'] = catalogo::consultar('certificados', 'listado_evaluaciones_examenes', $parametros);

        $operacion = kernel::ruteador()->get_id_operacion();
        $this->data['url_pdf_parcial'] = kernel::vinculador()->crear($operacion, 'exportar_pdf_parcial');
        $this->data['url_pdf_examen'] = kernel::vinculador()->crear($operacion, 'exportar_pdf_examen');
    }
}