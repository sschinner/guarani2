<?php

namespace siu\operaciones\modificar_periodo_alcance;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_encuestas extends pagelet
{
    function get_nombre()
    {
        return 'encuestas';
    }

    function get_js_files()
    {
        $archivos = parent::get_js_files();
        $archivos[] = kernel::vinculador()->vinculo_recurso("js/date-es-AR.js");
        return $archivos;
    }

    function get_encuestas_alcances_con_habilitaciones(){
        return catalogo::consultar('encuestas', 'encuestas_alcances_con_habilitaciones');
    }

    function prepare()
    {
        $encuestas_alcances_con_habilitaciones = $this->get_encuestas_alcances_con_habilitaciones();
        $datetime_fecha_actual = new \DateTime('today');

        $encuestas_alcances = array();
        //Hago corte de control por encuesta...
        foreach($encuestas_alcances_con_habilitaciones as $alcance){
            $encuestas_alcances[$alcance['ENCUESTA']]['titulo'] = $alcance['ENCUESTA_TITULO'];
            $encuestas_alcances[$alcance['ENCUESTA']]['kolla_id_encuesta'] = $alcance['KOLLA_ID_ENCUESTA'];

            $datetime_fecha_desde = \DateTime::createFromFormat('!d/m/Y', $alcance['FECHA_DESDE']);
            $datetime_fecha_hasta = \DateTime::createFromFormat('!d/m/Y', $alcance['FECHA_HASTA']);
            $modificar_fecha_desde = false;

            if($datetime_fecha_desde > $datetime_fecha_actual){
                $modificar_fecha_desde = true;
            }

            $encuestas_alcances[$alcance['ENCUESTA']]['alcances'][$alcance['ALCANCE']] = array(
                'titulo' => $alcance['ALCANCE_TITULO'],
                'fecha_desde' => $alcance['FECHA_DESDE'],
                'fecha_hasta' => $alcance['FECHA_HASTA'],
                'anio_academico' => $alcance['ANIO_ACADEMICO'],
                'periodo_lectivo' => $alcance['PERIODO_LECTIVO'],
                //'cant_encuestas_respondidas' => $alcance['CANT_ENCUESTAS_RESPONDIDAS'],
                //'cant_encuestas_sin_responder' => $alcance['CANT_ENCUESTAS_SIN_RESPONDER'],
                'kolla_id_habilitacion' => $alcance['KOLLA_ID_HABILITACION'],
                'kolla_password' => $alcance['KOLLA_PASSWORD'],
                'modificar_fecha_desde' => $modificar_fecha_desde
            );
        }
        $this->data['encuestas_alcances'] = $encuestas_alcances;

        $url_guardar = kernel::vinculador()->crear('modificar_periodo_alcance', 'guardar');
        $this->add_var_js('url_guardar', $url_guardar);
        $this->add_var_js('fecha_actual', $datetime_fecha_actual->format("d/m/Y"));
    }
}
?>
