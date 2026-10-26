<?php

namespace siu\operaciones\examen;

use kernel\kernel;
use kernel\util\mail;
use siu\guarani;
use siu\extension_kernel\controlador_errores_control;
use kernel\util\validador;
use siu\operaciones\_comun\comprobantes\generador_comprobantes;
use siu\modelo\datos\catalogo;

class controlador extends controlador_errores_control {

    /**
     * @return \siu\modelo\transacciones\inscripcion_examen
     */
    function modelo() {
        return guarani::examen();
    }

    function ini() {
        $this->controlar_csrf_accion('inscribir');
        $this->controlar_csrf_accion('baja');
    }

    function accion__index() {
        $hubo_error = $this->exec_fn_modelo('control__inicial');
        $mensajes = $this->get_var('mensajes');
        if (!empty($mensajes)) {
            $this->vista()->set_hay_mensajes(true);
        }

        $this->vista()->set_error($hubo_error);
    }

    function accion__elegir_materia() {
        $materia = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
        
        $pagelet = $this->vista()->pagelet('info_materia_examen');

        $this->elegir_materia($materia);

        $this->add_var('materia', $materia);
        kernel::renderer()->add($pagelet);
    }

    protected function elegir_materia($materia) {
        $pagelet = $this->vista()->pagelet('info_materia_examen');

        $hubo_error = $this->exec_fn_modelo('control__seleccion_materia', $materia);

        if ($hubo_error) {
            $pagelet->set_estado_info(pagelet_info_materia_examen::ERROR_MATERIA_SELECCIONADA);
        } else {
            $pagelet->set_estado_info(pagelet_info_materia_examen::MATERIA_SELECCIONADA);
        }
    }

    function accion__inscribir() {
        $materia = $this->validate_param('materia', 'post', validador::TIPO_ALPHANUM);
        $mesa = $this->validate_param('mesa', 'post', validador::TIPO_ALPHANUM);
        $tipo_insc = $this->validate_param('tipo_insc', 'post', validador::TIPO_ALPHA, array(
            'allowempty' => true
        ));
        // se controla que venga una L o una R. Cualquier otro valor es inválido
        // y se asume por defecto R
        $tipo_insc = ($tipo_insc != 'L' && $tipo_insc != 'R') ? 'R' : $tipo_insc;
        $hubo_error = $this->exec_fn_modelo('evt__inscripcion', array($materia, $mesa, $tipo_insc));

        if ($hubo_error) {
            // Se genera un nuevo csrf xq el anterior ya se consumió
            kernel::renderer()->add_csrf($this->generar_csrf());
            // esta llamada finaliza el request
            $this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_insc_examen'), $this->get_var('mensajes'));
        }

        $this->elegir_materia($materia);
        $this->add_pagelet_vars($materia, $mesa);
        /* nuevo */
        $this->agregar_mensaje_alta_mesa($materia, $mesa);
        /* */
        kernel::renderer()->add($this->vista()->pagelet('info_materia_examen'));
    }

    function accion__baja() {
        $materia = $this->validate_param('materia', 'post', validador::TIPO_ALPHANUM);
        $mesa = $this->validate_param('mesa', 'post', validador::TIPO_ALPHANUM);

        $hubo_error = $this->exec_fn_modelo('evt__eliminar_inscripcion', array($materia, $mesa));

        if ($hubo_error) {
            kernel::renderer()->add_csrf($this->generar_csrf());
            $this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_baja_cursada'), $this->get_var('mensajes'));
        }

        $this->elegir_materia($materia);
        $this->add_pagelet_vars($materia, $mesa);
        kernel::renderer()->add($this->vista()->pagelet('info_materia_examen'));
    }

    /**
     * Acción baja que se ejecuta desde el estado inicial del pagelet 
     */
    function accion__baja_inicial() {
        $materia = $this->validate_param('materia', 'post', validador::TIPO_ALPHANUM);
        $mesa = $this->validate_param('mesa', 'post', validador::TIPO_ALPHANUM);

        $hubo_error = $this->exec_fn_modelo('evt__eliminar_inscripcion_inicial', array($materia, $mesa));

        if ($hubo_error) {
            kernel::renderer()->add_csrf($this->generar_csrf());
            $this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_baja_cursada'), $this->get_var('mensajes'));
        }

        kernel::renderer()->add($this->vista()->pagelet('info_materia_examen'));
    }

    function accion__info_notificaciones() {
        $parametros_insc_examen = array();
        $parametros_insc_examen['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros_insc_examen['estado'] = "T";
        $parametros_insc_examen['alcance'] = "A";

        $carrera = kernel::persona()->get_id_carrera_activa();
        $inscs = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros_insc_examen);
        $inscs_por_carrera = array();

        foreach ($inscs as $insc) {
                if ($insc['carrera'] == $carrera) {
                        $inscs_por_carrera[] = $insc;
                }
        }

        $this->render_raw_json($inscs_por_carrera);
    }

    function accion__enviar_comprobante() {
        $dir_mail = kernel::persona()->get_mail();

        if (empty($dir_mail)) {
            $this->finalizar_request();
        }
        $url_materia = $this->validate_param('materia', 'get', validador::TIPO_ALPHANUM);
        $url_transaccion = $this->validate_param('transaccion', 'get', validador::TIPO_ALPHANUM);
        $accion = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
        $datos = $this->modelo()->info__comprobante($url_materia, $url_transaccion);

        $asunto = kernel::traductor()->trans('asunto_mail_alta_certificado_examen', array(
            '%1%' => $datos['FECHA_INSCRIPCION'],
            '%2%' => $datos['NOMBRE_MATERIA']
        ));
        $tpl = kernel::load_template('info_materia_examen/mail_alta_certificado.twig');
        $cuerpo = $tpl->render(array());

        $path_archivo = kernel::proyecto()->get_dir_temp() . '/' . uniqid() . '.png';
        $this->generar_comprobante($accion, $datos, $path_archivo);
        $mail = new mail($dir_mail, $asunto, $cuerpo);
        $mail->agregar_adjunto('comprobante.png', $path_archivo);
        $mail->set_html(true);

        $mail->enviar();
        //Una vez enviado el email elimino el comprobante.
        unlink($path_archivo);
        $this->render_ajax();
    }

    function accion__generar_comprobante() {
        $url_materia = $this->validate_param('materia', 'get', validador::TIPO_ALPHANUM);
        $url_transaccion = $this->validate_param('transaccion', 'get', validador::TIPO_ALPHANUM);
        $accion = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));

        $datos = $this->modelo()->info__comprobante($url_materia, $url_transaccion);

        $this->generar_comprobante($accion, $datos);
        $this->finalizar_request();
    }

    static function generar_comprobante($accion, $datos, $path = false) {
        $font = guarani::dir_fonts() . '/Ubuntu-R.ttf';
        $font_bold = guarani::dir_fonts() . '/Ubuntu-B.ttf';
        ob_clean();
        $logo = kernel::localizador()->encontrar_img('www/img', 'logo.png');

        $subtitulo = "";
        if ($accion && $accion == 'baja') {
            $subtitulo = kernel::traductor()->trans("comprobante_inscripcion_examen_baja");
        } else {
            $subtitulo = kernel::traductor()->trans("comprobante_inscripcion_examen_alta");
        }
        $opciones = array(
            'tamano_fuente' => 10,
            'tamano_fuente_titulo' => 14,
            'tamano_fuente_subtitulo' => 12,
            'interlineado' => 10,
            'font' => $font,
            'fontBold' => $font_bold,
            'margen' => 10,
            'set_offset_cuerpo' => 110
        );
        $img = new generador_comprobantes(420, 510, $opciones);
        $img->agregar_imagen($logo['path'], 5, 5);
        //agregar linea
        $img->agregar_linea(10, 80, 410, 80, 'sfasf');
        
        $tabla = array(
            'legajo' => $datos['LEGAJO'],
            'nombre_alumno' => $datos['NOMBRE_ALUMNO'],
            'nombre_carrera' => $datos['NOMBRE_CARRERA'] . ' (' . $datos['CARRERA'] . ')',
            'fecha_inscripcion' => $datos['FECHA_INSCRIPCION'],
            'nombre_materia' => $datos['NOMBRE_MATERIA'],
            'anio_academico' => $datos['ANIO_ACADEMICO'],
            'catedra' => $datos['CATEDRA'],
            'tipo_inscripcion' => $datos['TIPO_INSC_DESC'],
            'turno_cursada' => $datos['TURNO_EXAMEN'],
            'mesa_examen' => $datos['MESA_EXAMEN'],
            'estado_inscripcion' => $datos['ESTADO_INSCRIPCION'],
            'orden_inscripcion' => $datos['ORDEN_INSC'],
            'nro_transaccion' => $datos['NRO_TRANSACCION'],
            'importante' => kernel::traductor()->trans("comprobante_aviso")
        );
        $img->agregar_subtitulo($subtitulo, "i");
        $img->agregar_tabla($tabla);

        $im = $img->generar();
        if ($path !== false) {
            imagepng($im, $path);
            imagedestroy($im);
        } else {
            header("Content-Type: image/png");
            imagepng($im);
        }
    }

    protected function add_pagelet_vars($materia, $mesa) {
        $this->add_var('materia', $materia);
        $this->add_var('mesa', $mesa);
    }

    /*     * *********************************************************************** */

    // FUNCIONES DE ACCESO AL MODELO
    /*     * *********************************************************************** */

    protected function modelo__control__inicial() {
        $mensajes = $this->modelo()->control__inicial();
        $this->acum_mensajes($mensajes);
    }

    protected function modelo__control__seleccion_materia($materia) {
        $mensajes = $this->modelo()->control__seleccion_materia($materia);
        $this->acum_mensajes($mensajes);
    }

    protected function modelo__evt__inscripcion($materia, $mesa, $tipo_insc) {
        list($mensajes, $transaccion) = $this->modelo()->evt__inscripcion($materia, $mesa, $tipo_insc);
        $this->add_var('transaccion', $transaccion);
        $this->acum_mensajes($mensajes);
    }

    protected function modelo__evt__eliminar_inscripcion($materia, $comision) {
        list($mensajes, $transaccion) = $this->modelo()->evt__eliminar_inscripcion($materia, $comision);
        $this->add_var('transaccion', $transaccion);
        $this->acum_mensajes($mensajes);
    }

    protected function modelo__evt__eliminar_inscripcion_inicial($materia, $mesa) {
        list($mensajes, $transaccion) = $this->modelo()->evt__eliminar_inscripcion_por_mesa($materia, $mesa);
        $this->add_var('transaccion', $transaccion);
        $this->acum_mensajes($mensajes);
    }

    /* nuevo */

    function agregar_mensaje_alta_mesa($materia, $mesa) {

        $url_transaccion = pagelet_info_materia_examen::get_nro_transaccion($mesa);

        $info = $this->modelo()->info__inscripcion($mesa);
        
        $estado = $info['ESTADO'];
        //$url_transaccion = $info['URL_NRO_TRANSACCION'];

        if ($estado == 'A' or $estado == 'E') {
            $mensaje = kernel::traductor()->trans('mensaje_alta_examen_comprobante', array(
                '%1%' => kernel::vinculador()->crear('examen', 'generar_comprobante', array(
                    'materia' => $materia,
                    'transaccion' => $url_transaccion
                ))
            ));
        }

        if ($estado == 'P') {
            $mensaje = kernel::traductor()->trans('mensaje_alta_examen_comprobante_pendiente', array(
                '%1%' => kernel::vinculador()->crear('examen', 'generar_comprobante', array(
                    'materia' => $materia,
                    'transaccion' => $url_transaccion
                ))
            ));
        }


        kernel::renderer()->add_to_ajax_response('mensaje_mesa_alta', $mensaje);
    }

    /* */
}

?>
