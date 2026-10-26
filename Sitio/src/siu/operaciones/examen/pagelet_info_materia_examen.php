<?php

namespace siu\operaciones\examen;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use \siu\modelo\entidades\parametro;
use \siu\modelo\datos\catalogo;
use \siu\guarani;

class pagelet_info_materia_examen extends pagelet {

    const MATERIA_SELECCIONADA = 'mat_sel';
    const ERROR_MATERIA_SELECCIONADA = 'error_mat_sel';

    function ini() {
        $this->add_mensaje_js('error_subcomision', kernel::traductor()->trans('info_materia.errores.subcomision'));
    }

    function get_nombre() {
        return 'info_materia_examen';
    }

    protected function get_codigo_response() {
        if ($this->estado == self::MATERIA_SELECCIONADA) {
            return 2;
        }

        return parent::get_codigo_response();
    }

    function get_materia() {
        return $this->controlador->get_var('materia');
    }

    function get_materia_nombre($materia) {
        $info = $this->modelo()->info__materia($materia);
        return $info['MATERIA_NOMBRE'];
    }

    function get_nro_transaccion($mesa) {
        $info = $this->modelo()->info__inscripcion($mesa);
        return $info['URL_NRO_TRANSACCION'];
    }

    function get_comision() {
        return $this->controlador->get_var('comision');
    }

    function get_mensajes() {
        return $this->controlador->get_var('mensajes');
    }

    protected function existe_insc_mesa($mesa) {
        $info = $this->modelo()->info__inscripcion($mesa);
        if ($info !== false) {
            return true;
        }
        return false;
    }

    protected function orden_inscripcion($mesa) {
        $info = $this->modelo()->info__inscripcion($mesa);

        if ($info !== false) {
            return $info['ORDEN_INSC'];
        }
        return false;
    }

    protected function existe_insc_examen($materia) {
        // cambiar en existe_inscripcion_a_examen que devuelve un arreglo
        // puede estar inscripto a m'as de una mesa
        return $this->modelo()->existe_inscripcion_a_examen($materia);
    }

    /**
     * Shortcut al modelo
     * @return \siu\modelo\transacciones\inscripcion_examen
     */
    protected function modelo() {
        return $this->controlador->modelo();
    }

    function prepare() {
        $this->data = array();
        $this->add_mensajes_js();
        $this->data['mensajes'] = $this->get_mensajes();
        switch ($this->estado) {
            case 'inicial':
                $this->prepare_inicial();
                break;
            case self::MATERIA_SELECCIONADA:
                $this->prepare_materia_seleccionada();
                break;
        }
		
		$param_insc_exa_baja = parametro::inscripcion_examen_baja() == 'S';
		$this->data['param_insc_exa_baja']	= $param_insc_exa_baja;		
    }

    protected function add_mensajes_js() {
        $this->add_var_js('msg_baja', kernel::traductor()->trans('mensaje_baja_examen'));
        $this->add_var_js('msg_confirmar_baja', kernel::traductor()->trans('mensaje_confirmar_baja'));
        $this->add_var_js('msg_titulo_enviar', kernel::traductor()->trans('titulo_enviar_comprobante'));
        $this->add_var_js('msg_enviar_boton', kernel::traductor()->trans('enviar_por_mail'));
        $this->add_var_js('msg_enviar', kernel::traductor()->trans('enviar_comprobante_examen', array(
                    '%1%' => kernel::persona()->get_mail()
        )));
        $this->add_var_js('msg_falta_mail', kernel::traductor()->trans('mail_no_cargado', array(
                    '%1%' => kernel::vinculador()->crear('configuracion')
        )));

        $this->add_var_js('envio_mail_exitoso', kernel::traductor()->trans('envio_mail_exitoso'));

        $mail = kernel::persona()->get_mail();
        if (empty($mail)) {
            $this->add_var_js('falta_mail', true);
        } else {
            $this->add_var_js('falta_mail', false);
        }
        $this->add_var_js('url_baja_inicial', kernel::vinculador()->crear('examen', 'baja_inicial'));
    }

    function get_desc_condicion($inscribir_como) {
        switch ($inscribir_como) {
            case "L": return "Libre";
                break;
            case "R": return "Regular";
                break;
            case "A": return "Libre o Regular";
                break;
            default:
                break;
        }
    }

    protected function prepare_inicial() {
        $parametros_insc_examen = array();
        $parametros_insc_examen['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();

        // T = Aceptadas/Pedientes/Exceptuadas
        $parametros_insc_examen['estado'] = "T";
        // F = De mesas de examen futuras o de hoy.
        $parametros_insc_examen['alcance'] = "F";

        $carrera = kernel::persona()->get_id_carrera_activa();
        $inscs = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros_insc_examen);
        $inscs_por_carrera = array();

        foreach ($inscs as $insc) {
            if ($insc['carrera'] == $carrera) {
                $inscs_por_carrera[] = $insc;
            }
        }

        $this->add_var_js('msg_mostrar_detalle', kernel::traductor()->trans('mostrar_detalle'));
        $this->add_var_js('msg_ocultar_detalle', kernel::traductor()->trans('ocultar_detalle'));

        $this->data['inscripciones'] = $inscs_por_carrera;
        $this->data['csrf'] = $this->generar_csrf();
    }

    protected function prepare_materia_seleccionada() {
        $materia = $this->get_materia();

        $this->data['llamados'] = $this->modelo()->info__lista_mesas($materia);

        foreach ($this->data['llamados'] as $key => $mesa) {
            if ($mesa['INSCRIBIR_COMO'] == 'T') {
                unset($this->data['llamados'][$key]);
                continue;
            }
            $this->data['llamados'][$key]['MATERIA'] = $materia;
            $this->data['llamados'][$key]['TIPO_INSCRIPCION_DESC'] = $this->get_desc_condicion($mesa['INSCRIBIR_COMO']);
            if ($this->existe_insc_mesa($mesa[catalogo::id])) {
                $this->data['llamados'][$key]['INSCRIPTO'] = true;
                $this->data['llamados'][$key]['ORDEN_INSC'] = $this->orden_inscripcion($mesa[catalogo::id]);
                $transaccion = $this->get_nro_transaccion($mesa[catalogo::id]);
                $this->data['llamados'][$key]['URL_COMP'] = kernel::vinculador()->crear('examen', 'generar_comprobante', array(
                    'materia' => $materia,
                    'transaccion' => $transaccion
                ));

                $this->data['llamados'][$key]['URL_MAIL_COMP'] = kernel::vinculador()->crear('examen', 'enviar_comprobante', array(
                    'materia' => $materia,
                    'transaccion' => $transaccion
                ));
            } else {
                $this->data['llamados'][$key]['INSCRIPTO'] = false;
            }
            $fecha = date_parse_from_format('Y-m-d', $mesa['FECHA_PRESTAMO_AULA']);
            $this->data['llamados'][$key]['FECHA_PRESTAMO_AULA'] = $fecha['day'] . '/' . $fecha['month'] . '/' . $fecha['year'];
        }

        $this->data['materia_nombre'] = $this->get_materia_nombre($materia);
        $this->data['materia'] = $materia;
        $this->data['url_baja'] = kernel::vinculador()->crear('examen', 'baja');
        $this->data['url_alta'] = kernel::vinculador()->crear('examen', 'inscribir');
        $this->data['param_insc_examen_seleccion_auto_tipo_insc'] = parametro::insc_examen_seleccion_auto_tipo_insc();
        $this->data['csrf'] = $this->generar_csrf();
    }

    protected function prepare_error_materia_seleccionada() {
//		$this->data['materia_nombre'] = $this->get_materia_nombre();
        $this->data['mensajes'] = $this->get_mensajes();
    }

    protected function prepare_reinscripcion() {
        
    }

}

?>
