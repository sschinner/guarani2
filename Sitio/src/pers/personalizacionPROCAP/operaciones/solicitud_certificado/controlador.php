<?php

namespace personalizacionPROCAP\operaciones\solicitud_certificado;

use kernel\error_kernel;
use kernel\kernel;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\manejador_archivos;
use kernel\util\u;
use kernel\util\validador;
use siu\extension_kernel\controlador_errores_control;
use siu\extension_kernel\controlador_g3w2;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;
use siu\modelo\guarani_notificacion;

require_once '../../../clientes_ws/mediosCobro/clientews.php';

use ClienteMediosCobro;

//use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
//use Zend_Barcode;
//define('NRO_CERTIFICADO', 100);

class controlador extends \siu\operaciones\solicitud_certificado\controlador {

    public $inicioSolicitud = false;
    public $retornoOk = '';
    public $nroCertificado;
    public $fechaVencimiento = '';
    public $identificadorCobro = '';
    public $montoCetificado = '';
    public $ministerial = 'N';
    public $certificadosArancelados = array();
    public $estadoPago = 'P';
    public $nroExpediente = '';

    function accion__generar_cert_alumno_reg() {

        //Ejecuto puntos de control 2 y 3...
        $hubo_error = $this->exec_fn_modelo('control__inicial');
        if ($hubo_error) {//Si fallaron los puntos de control...
            $mensajes = $this->get_var('mensajes');
            if (!empty($mensajes)) {
                $this->vista()->set_hay_mensajes(true);
            }
            $this->vista()->set_error($hubo_error);
            $pagelet = $this->vista()->pagelet('formulario');
            kernel::renderer()->add($pagelet);
            return false;
        }


        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());

        $parametros = array();
        $parametros['carrera'] = guarani::persona()->get_id_carrera_activa();
        $parametros['legajo'] = guarani::persona()->get_id_legajo_activo();

        $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = false;
        $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = false;

        //Controlo si el alumno es regular a la carrera...
        $ctr_alu_reg_carrera = catalogo::consultar('certificados', 'ctr_alumno_regular_carrera', $parametros);
        $es_regular_a_carrera = ($ctr_alu_reg_carrera["estado"] == 1) ? true : false;

        $param = array();
        $param['_ua'] = $uA;
        $param['carrera'] = guarani::persona()->get_id_carrera_activa();
        $param['legajo'] = guarani::persona()->get_id_legajo_activo();
        $param['anio'] = DATE('Y');

        //Controlo si el alumno esta reinscripto en la carrera...
        $ctr_alu_reins_carrera = catalogo::consultar('certificados', 'ctr_alumno_reinscripcion', $param);

        $verifica_es_ingresante = catalogo::consultar('certificados', 'es_ingresante', $param);

        $esta_reinsc_a_carrera = ($ctr_alu_reins_carrera["estado"] == 1) ? true : false;

        if ($es_regular_a_carrera && $esta_reinsc_a_carrera) {//Si es regular y esta reinscripto ...
            $path_temp_car = kernel::proyecto()->get_dir_temp() . "/cert_alum_reg";
            manejador_archivos::crear_arbol_directorios($path_temp_car);


            $pd = new \personalizacionPROCAP\operaciones\_comun\operaciones\reporte\generador_TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);
            $pd->SetAutoPageBreak(false, 0);
            $pd->SetMargins(40, 10, 40);
            $pd->setPrintFooter(false);
            $pd->setPrintHeader(false);
            $pd->SetFont('times', '', 10);
            $pd->SetFillColor(0, 0, 0, 100);
            $pd->SetTextColor(0, 0, 0, 100);
            $pd->SetDrawColor(0, 0, 0, 100);
            $pd->SetTextColorArray(0, 0, 0, 100);
            $pd->SetFontSubsetting(false);
            $pd->setJPEGQuality(100);
            $pd->AddPage();

            ob_clean();

            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $paramet['_ua'] = $uA;

            $facultad = guarani::ua()->get_nombre();
            $ubicacion = guarani::ua()->get_localidad_institucion();

            $datosUA = catalogo::consultar('unidad_academica', 'datos_unidad_academica', $paramet);

            $pd->SetFont('times', 'B', 9);
            $pd->Text(10, 12, 'Universidad Nacional del Litoral');
            $pd->SetXY(10, 19);
            $pd->MultiCell(80, 15, utf8_encode($facultad), 0, 'L', 0, 0, '', '', true, 0, false, true, 0);
            $pd->SetFont('times', '', 9);
            //Se comenta 23/05/16
            //$pd->Text(10, 28, 'Departamento Alumnado');
            $logo = kernel::localizador()->encontrar_img('www/img', 'unl.JPG');
            $pd->SetXY(160, 12);
            $pd->Cell(40, 8, 'CP: (' . $datosUA['CODIGO_POSTAL'] . ') ' . $ubicacion, 0, 0, 'R');
            $pd->SetXY(160, 18);
            $pd->Cell(40, 8, 'TE: ' . $datosUA['TE'], 0, 0, 'R');
            $pd->SetXY(160, 28);
            //Se comenta 23/05/16
            //$pd->Cell(40, 8, $datosUA['CALLE'], 0, 0, 'R');


            $pd->Image($logo['path'], 95, 10, 20, 20, 'JPG', '', '', true, 300, '', false, false, 0, false, false, false);
            $pd->SetFont('Helvetica', 'BU', 13);
            $pd->Line(10, 35, 200, 35);
            $pd->SetXY(95, 40);

            $pd->Cell(20, 4, 'CERTIFICADO DE ALUMNO REGULAR', 0, 0, 'C', false, '', 0, false, 'T', 'C');

            $sexo = guarani::persona()->get_sexo();
            $parametros['parametros']['nom_ape_alumno'] = guarani::persona()->get_nombre();

            if ($sexo == 1) {//Masculino
                $parametros['parametros']['articulo'] = kernel::traductor()->trans('form.cert_alu_regular.el');
                $parametros['parametros']['genero'] = kernel::traductor()->trans('form.cert_alu_regular.alumno');
            } else {//Femenino
                $parametros['parametros']['articulo'] = kernel::traductor()->trans('form.cert_alu_regular.la');
                $parametros['parametros']['genero'] = kernel::traductor()->trans('form.cert_alu_regular.alumna');
            }

            $fecha = new \DateTime();
            $dia = $fecha->format('j');
            $mes = $fecha->format('n');
            $anio = $fecha->format('Y');

            $parametros['parametros']['nombre_facultad'] = guarani::ua()->get_nombre();
            $parametros['parametros']['legajo'] = guarani::persona()->get_id_legajo_activo();
            $parametros['parametros']['desc_tipo_docum'] = guarani::persona()->get_tipo_documento_desc_abreviada();
            $parametros['parametros']['nro_documento'] = guarani::persona()->get_nro_documento();
            $parametros['parametros']['nacionalidad'] = guarani::persona()->get_nacionalidad_descripcion();
            $carrera_activa = guarani::persona()->get_info_carrera_activa();
            $parametros['parametros']['carrera_nombre'] = $carrera_activa['nombre'];
            $parametros['parametros']['plan'] = guarani::persona()->get_id_plan_activo();
            $parametros['parametros']['anio_ingreso'] = guarani::persona()->get_alumno_anio_ingreso();
            $parametros['parametros']['fecha'] = $fecha->format('Y-m-d');

            //Armo el texto
            $texto = kernel::traductor()->trans('form.cert_alu_regular.primera_parte', array(
                '%facultad%' => $parametros['parametros']['nombre_facultad'],
                //'%genero%' => "{$parametros['parametros']['articulo']} {$parametros['parametros']['genero']}",
                '%genero%' => "{$parametros['parametros']['genero']}",
                '%alumno%' => $parametros['parametros']['nom_ape_alumno'],
                '%legajo%' => $parametros['parametros']['legajo'],
                '%tipo_doc%' => $parametros['parametros']['desc_tipo_docum'],
                '%nro_doc%' => $parametros['parametros']['nro_documento'],
                '%origen%' => $parametros['parametros']['nacionalidad'],
                '%carrera%' => $parametros['parametros']['carrera_nombre'],
                '%plan%' => $parametros['parametros']['plan'],
                '%anio_ingreso%' => $parametros['parametros']['anio_ingreso']
            ));
            $pd->SetFont('Helvetica', '', 12);
            $pd->SetXY(15, 55);
            $pd->MultiCell(180, 30, utf8_encode($texto), 0, 'L');

            $parametros['parametros']['localidad'] = guarani::ua()->get_localidad_institucion();
            $texto = kernel::traductor()->trans('form.cert_alu_regular.segunda_parte', array(
                '%ciudad%' => $parametros['parametros']['localidad'],
                '%dia%' => $dia,
                '%mes%' => kernel::traductor()->trans('mes.' . $mes),
                '%anio%' => $anio
            ));

            //Materias rendidas
            $ejeY = $pd->GetY();
            $pd->SetFont('Helvetica', '', 12);
            $pd->SetXY(15, $ejeY - 15);
            $pd->MultiCell(180, 25, utf8_encode($texto), 0, 'L');
//            $pd->SetFont('Helvetica', 'b', 11);
//            $pd->Text(15, $pd->GetY(), 'Ultimas Asignaturas aprobadas por examen:');
//
//            //Obtengo las materias rendidas
//            
//            $carrera = guarani::persona()->get_info_carrera_activa();
//            $paramet['carrera'] = $carrera['id'];
//            $paramet['legajo'] = guarani::persona()->get_id_legajo_activo();
//
//            $arrMaterias = catalogo::consultar('alumno', 'historia_academica', $paramet);
//            $pd->SetFont('Helvetica', 'b', 9);
//            
//            $c = 0;
//                for ($j = 0; $j < count($arrMaterias); $j++) {
//                    
//                    if($c > 1)
//                        break;
//                    if(($arrMaterias[$j][5] == 'Examen' || $arrMaterias[$j][6] == 'P') && ($arrMaterias[$j][3] == 'Aprobado')){
//                        $fe = explode('-', $arrMaterias[$j][2]);
//                        $fechaExa = $fe[2] . "/" . $fe[1] . "/" . $fe[0];
//                        $pd->Text(20, $pd->GetY() + (10 - (4 * $c )) ,utf8_encode($arrMaterias[$j][1]));
//                        $pd->Text(120, $pd->GetY() , utf8_encode($arrMaterias[$j][17]) . " - " . $arrMaterias[$j][4]." ".utf8_encode($arrMaterias[$j][16]) . " - ". $fechaExa);
//                        $c++;
//                    }
//                }
//                if($c == 0)
//                    $pd->Text(20, $pd->GetY() + 10, 'NO POSEE MATERIAS APROBADAS');


            $pd->SetXY(60, $pd->GetY() + 40);


            //El codigo validador esta formado por la fecha actual (ymdHis) mas un numero random de 2 digitos.
            $parametros['codigo_validador'] = $fecha->format('ymdHis') . str_pad(rand(0, 99), 2, '0', STR_PAD_LEFT);
            $texto = kernel::traductor()->trans('form.cert_alu_regular.codigo_validacion');

            $pd->SetFont('Helvetica', '', 10);
            $pd->Text(65, $pd->GetY(), utf8_encode($texto));


            //Genero el codigo de barras.
            $barcodeOptions = array('text' => $parametros['codigo_validador']);
            $rendererOptions = array('imageType' => 'png');
            $style = array(
                'position' => '',
                'align' => 'C',
                'stretch' => false,
                'fitwidth' => true,
                'cellfitalign' => '',
                'border' => false,
                'hpadding' => 'auto',
                'vpadding' => 'auto',
                'fgcolor' => array(0, 0, 0),
                'bgcolor' => false, //array(255,255,255),
                'text' => true,
                'font' => 'helvetica',
                'fontsize' => 8,
                'stretchtext' => 4
            );

            $pd->SetXY(60, $pd->GetY() + 5);
            $pd->write1DBarcode($parametros['codigo_validador'], 'C39', '', '', '', 27, 0.3, $style, 'N');

            $parametro['anio'] = date('Y');
            $fechaValido = catalogo::consultar('alumno', 'vigencia_cert_alu_regular', $parametro);

            // Personalizado  para fechas menores del 31/05
            $mesActual = date('m');
            if ($verifica_es_ingresante === 'S') {
                if ($mesActual < '06') {
                    $dias = '31';
                    $meses = '5';
                    $anios = $parametro['anio'];
                    $fechaValido[0]['FECHA_FIN'] = $anios . '-05-31';
                } else {
                    $separa = explode('-', $fechaValido[0]['FECHA_FIN']);
                    $dias = $separa[2];
                    $meses = str_replace('0', '', $separa[1]);
                    $anios = $separa[0];
                }
            } else {
                $separa = explode('-', $fechaValido[0]['FECHA_FIN']);
                $dias = $separa[2];
                $meses = str_replace('0', '', $separa[1]);
                $anios = $separa[0];
            }



            $texto = kernel::traductor()->trans('form.cert_alu_regular.leyenda_qr', array(
                '%url_qr%' => kernel::vinculador()->crear('validador_certificados', 'index')
            ));
            $pd->SetFont('Helvetica', '', 10);

            $pd->writeHTMLCell(135, 20, 60, $pd->GetY() + 15, utf8_encode($texto), 0, 0, false, true, 'L');


            $parametros['parametros']['cat_dias_vigencia'] = $this->get_cat_dias_vigencia_cert_alumno_reg();
            $fecha_expiracion = $fecha->add(new \DateInterval('P' . $parametros['parametros']['cat_dias_vigencia'] . 'D'));
            $parametros['fecha_expiracion'] = $fechaValido[0]['FECHA_FIN']; //$fecha_expiracion->format('Y-m-d');
            //$dia = utf8_decode("día");
            //$dias = utf8_decode("días");
            //$cat_dias_vigencia_text = ($parametros['parametros']['cat_dias_vigencia'] == 1) ? "{$parametros['parametros']['cat_dias_vigencia']} $dia" : "{$parametros['parametros']['cat_dias_vigencia']} $dias";
            $texto = kernel::traductor()->trans('form.cert_alu_regular.qr_vigencia', array(
                '%vigencia%' => $cat_dias_vigencia_text,
                '%dias%' => $dias,
                '%mes%' => kernel::traductor()->trans('mes.' . $meses),
                '%anios%' => $anios
            ));

            $pd->Text(60, $pd->GetY() + 20, utf8_encode($texto));


            $url_validador = kernel::vinculador()->crear('validador_certificados', 'index', $parametros['codigo_validador']);

            //Genero el codigo QR.
            $path_qr = $path_temp_car . "/qrcode_car.png";
            \QRcode::png($url_validador, $path_qr);

            $pd->Image($path_qr, 25, $pd->GetY() - 22, 30, 30, 'png', '', '', true, 300, '', false, false, 0, false, false, false);

            unlink($path_qr);

            $parametros['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
            $parametros['certificado'] = 1;
            //print_r($path_temp_car);die;
            //Guardo el certificado en la DB.
            $ok = catalogo::consultar('certificados', 'guardar_certificado_web', $parametros);

            if ($ok) {
                $pdf = "certificado_alumno_regular.pdf";
                $path_nombre = $path_temp_car . "/CAR_{$parametros['codigo_validador']}.pdf";
                $pd->Output($pdf, 'D');
                $pd->Output($path_nombre, 'F');
                // $pdf_aux = $pd->Output($pdf, 'D');
                //file_put_contents($path_nombre, $pdf_aux);
                try {
                    $this->enviar_mail_cert($path_nombre, 'certificado_alumno_regular.pdf');
                    $this->descargar_archivo($path_nombre, 'certificado_alumno_regular');
                } catch (error_kernel $e) {
                    $this->id_certificado = 1;
                    $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = true;
                }
            } else {
                $this->id_certificado = 1;
                $this->vista()->pagelet('formulario')->data['mostrar_error_al_generar_certificado'] = true;
            }
        } else if (!$es_regular_a_carrera) {

            $this->id_certificado = 1;
            $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = true;
        } else {
            $this->id_certificado = 1;
            $this->vista()->pagelet('formulario')->data['mostrar_error_no_reinscripto'] = true;
        }
    }

    function accion__elegir_certificado() {
        $certificado = $this->id_certificado = $this->validate_param(0, 'get', validador::TIPO_INT, array('allowempty' => true, 'default' => false));

        if ($certificado == 1) {
            $this->vista()->pagelet('formulario')->data['mostrar_error_no_regular'] = false;
        }

        $certificadosArancelados = $this->get_listaCertificados();

        /*         * *  Determino si Certificado es Arancelado ** */
        if (in_array($certificado, $certificadosArancelados)) {

            $this->nroCertificado = $certificado;


            openlog("Seleccionar Certificado " . $certificado, LOG_PID, LOG_LOCAL0);
            $hubo_error = $this->exec_fn_modelo('control__seleccion_certificado', $certificado);

            /*             * * Punto de Control al momento de elegir el certificado ** */

            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $carrera_activa = kernel::persona()->get_info_carrera_activa();
            $params['legajo'] = kernel::persona()->get_id_legajo_activo();
            $params['carrera'] = $carrera_activa['id'];
            $params['_ua'] = $uA;
            $params['certif'] = $this->id_certificado;
            syslog(LOG_INFO, "Usuario " . $params['legajo'] . " elige solicitud certificado " . $certificado);
            $controlaSiYaPidio = catalogo::consultar('certificados', 'controla_si_esta_pedido', $params);


            if ($this->nroCertificado == 100) {

                $this->inicioSolicitud = false;
                $this->retornoOk = '';
                $this->elegir_certificado($certificado);
                $pagelet = $this->vista()->pagelet('formulario');
                $this->vista()->set_pagelet_segunda_columna('formulario');
                kernel::renderer()->add($pagelet);

                //$certifAnalitico = catalogo::consultar('certificados', 'controla_cert_analitico', $parameters);
                
            } else {
                /*                 * * Si ya esta solicitado ** */
                if ($hubo_error || $controlaSiYaPidio === '-1') {
                    $controlaSiPago = $this->obtieneIdCertifPedido($certificado, $uA);
                    if ($controlaSiPago[1] === $this->estadoPago && empty($controlaSiPago[7])) {
                        syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                        closelog();
                        $this->inicioSolicitud = true;
                        $this->retornoOk = 3;
                        $this->nroExpediente = $controlaSiPago[6];
                        $pagelet = $this->vista()->mostarUrl();
                        $this->vista()->get_pagelet_segunda_columna();
                        $this->add_var('formulario', $pagelet);
                        kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                        kernel::renderer()->add($this->vista()->pagelet('formulario'));
                    } else {
                        // Si no tiene identificador de cobro (por cualquier motivo)
                        if (is_null($controlaSiPago[5])) {

                            $solicitud['identificador_deuda'] = $controlaSiPago[9];
                            $solicitud['certif_pedido'] = $controlaSiPago[0];                   
                            $argumentos[3] = guarani::persona()->get_id_legajo_activo();                        
                            $argumentos[5] = catalogo::consultar('certificados', 'argumento_orden_5_cert_pedido', $solicitud)[0]['ARGUMENTO']; 
                            
                            $datosWS = $this->cargarDatosWSCobros($controlaSiPago[4], $argumentos, $solicitud['identificador_deuda'], $certificado);
                            
                            $solicitud['id_certif_pedido'] = $solicitud['certif_pedido'];
                            
                            
                            $error = $this->modelo()->asignar_identificador_cobro($solicitud, $datosWS);
                            
                            if (!$error) {
                                
                        syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                        closelog();
                        $this->inicioSolicitud = true;
                        $this->retornoOk = 2;
                        $pagelet = $this->vista()->mostarUrl();
                        $this->vista()->get_pagelet_segunda_columna();
                        $this->add_var('formulario', $pagelet);
                        kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                        kernel::renderer()->add($this->vista()->pagelet('formulario'));
                            }else { 

                                /*             * * Si hay error o problemas con el wsCobro  ** */
                                syslog(LOG_WARNING, "ERROR de comunicacion con WS de Medios de Cobro para Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $controlaSiPago[9] . " para el certificado " . $certificado);
                                closelog();
                                $this->inicioSolicitud = true;
                                $this->retornoOk = 500;
                                $pagelet = $this->vista()->mostarUrl();
                                $this->vista()->get_pagelet_segunda_columna();
                                $this->add_var('formulario', $pagelet);
                                kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                kernel::renderer()->add($this->vista()->pagelet('formulario'));
                    }
                        }
                        else {     
                            syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                            closelog();
                            $this->inicioSolicitud = true;
                            $this->retornoOk = 2;
                            $pagelet = $this->vista()->mostarUrl();
                            $this->vista()->get_pagelet_segunda_columna();
                            $this->add_var('formulario', $pagelet);
                            kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                            kernel::renderer()->add($this->vista()->pagelet('formulario'));
                        }
                    } 
                } 
                else {
                    /*                     * * Si no fue solicitado aun ** */
                    closelog();
                    $this->elegir_certificado($certificado);
                    $pagelet = $this->vista()->pagelet('formulario');
                    $this->vista()->set_pagelet_segunda_columna('formulario');

                    kernel::renderer()->add($pagelet);
                }
            }
        } else {
            /*             * * Cualquier otro certificado ** */
            $this->elegir_certificado($certificado);
            $pagelet = $this->vista()->pagelet('formulario');
            $this->vista()->set_pagelet_segunda_columna('formulario');

            kernel::renderer()->add($pagelet);
        }
    }

    function accion__solicitar() {

        if (kernel::request()->isPost()) {
            $certificado = $this->nroCertificado = $this->id_certificado = $this->validate_param('nro_certificado', 'post', validador::TIPO_INT);
            $cantidad_copias = $this->validate_param('cantidad', 'post', validador::TIPO_INT);
            $argumentos = $this->validate_param('args', 'post', validador::TIPO_ARRAY_TEXTO);

            $hubo_error = $this->exec_fn_modelo('validar_solicitud', array($certificado, $cantidad_copias));

            $certificadosArancelados = $this->get_listaCertificados();
            if ($this->id_certificado != 100) {
                if (!$hubo_error) {
                    $hubo_error = $this->exec_fn_modelo('control__solicitud_certificado', array($certificado));

                    if (!$hubo_error && !in_array($certificado, $certificadosArancelados)) {
                        $hubo_error = $this->exec_fn_modelo('evt__solicitar', array($certificado, $cantidad_copias, $argumentos));
                    }
                }

                $mensajes = $this->get_var('mensajes');

                if (!empty($mensajes)) {
                    $this->vista()->set_hay_mensajes(true);
                }
                $this->vista()->set_error($hubo_error);

                kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);

                /*                 * * Si el certificado es arancelado y no hubo error ** */

                if (in_array($certificado, $certificadosArancelados) && !$hubo_error) {
                    openlog("Solicitud Certificado " . $certificado, LOG_PID, LOG_LOCAL0);
                    syslog(LOG_INFO, "Usuario " . kernel::persona()->get_id_legajo_activo() . "  solicita certificado " . $certificado);
                    closelog();
                    $this->solicitarPago($certificado, $cantidad_copias, $argumentos);
                } else if (in_array($certificado, $certificadosArancelados) && $hubo_error) {
                    openlog("Solicitud Certificado " . $certificado, LOG_PID, LOG_LOCAL0);
                    syslog(LOG_WARNING, "Usuario " . kernel::persona()->get_id_legajo_activo() . "  solicita certificado " . $certificado . " pero hubo un error, se descarta la solicitud");
                    closelog();
                } else {
                    if (!$hubo_error) {
                        $params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
                        $params['certificado'] = $certificado;
                        $nro_solicitud_certificado = catalogo::consultar('certificados', 'nro_solicitud_certificado', $params);
                        $mensaje = kernel::traductor()->trans('solicitud_certificado.mensaje_exito');
                        $mensaje = str_replace("%nro_trans%", $nro_solicitud_certificado, $mensaje);
                        kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                    }
                }
            } else {
                $controlaEgresadoTituloFinal = '';
                $u = new unidad_academica(\siu\guarani::get_ua_id());
                $uA = utf8_encode($u->get_id());
                $params['_ua'] = $uA;
                $carrera_activa = kernel::persona()->get_info_carrera_activa();
                $params['carrera'] = $carrera_activa['id'];
                $params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
                $controlaEgresadoTituloFinal = catalogo::consultar('alumno', 'calidad_alumno', $params);

                if ($controlaEgresadoTituloFinal[0][0] == '-1') {
                    $hubo_error = $this->exec_fn_modelo('control__solicitud_certificado', array($certificado));

                if ($hubo_error) {//controla que quien lo solicita sea egresado
                    $mensajes = $this->get_var('mensajes');

                    if (!empty($mensajes)) {
                        $this->vista()->set_hay_mensajes(true);
                    }
                    $this->vista()->set_error($hubo_error);
                    kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
                    }
                } else {
                    $carrera_activa = kernel::persona()->get_info_carrera_activa();
                    $params['legajo'] = kernel::persona()->get_id_legajo_activo();
                    $params['carrera'] = $carrera_activa['id'];
                    $params['certif'] = $this->id_certificado;
                    $params['ministerial'] = $argumentos[5];
                    $params['titulo'] = $argumentos[3];
                    $certifAnalitico = catalogo::consultar('certificados', 'controla_cert_analitico', $params);

                    if (!empty($certifAnalitico)) {//Verifico si solicito alguna vez

                        foreach ($certifAnalitico as $fila) {
                            // recorro lo que ya solicito alguna vez con lo que esta solicitando y determino la accion a seguir
                            if ($fila[12] == $argumentos[5] && $fila[1] != 'V') {

                                if (!empty($fila[7])) {
                                    $this->inicioSolicitud = true;
                                    $this->retornoOk = 4;

                                    $pagelet = $this->vista()->mostarUrl();
                                    $this->vista()->get_pagelet_segunda_columna();
                                    $this->add_var('formulario', $pagelet);
                                    kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                    kernel::renderer()->add($this->vista()->pagelet('formulario'));
                                } else {

                                    if ($fila[1] === $this->estadoPago && empty($fila[7])) {
                                        syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                                        closelog();
                                        $this->inicioSolicitud = true;
                                        $this->retornoOk = 3;
                                        $this->nroExpediente = $fila[6];
                                        $this->identificadorCobro = $fila[5];
                                        $pagelet = $this->vista()->mostarUrl();
                                        $this->vista()->get_pagelet_segunda_columna();
                                        $this->add_var('formulario', $pagelet);
                                        kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                        kernel::renderer()->add($this->vista()->pagelet('formulario'));
                                    } else {
//                                      // Si no tiene identificador de cobro (por cualquier motivo)

                                        if (is_null($fila[5])) {                                         
                                            $solicitud['identificador_deuda'] = $fila[9];
                                            $solicitud['certif_pedido'] = $fila[0];                   
                                            $argumentos[3] = guarani::persona()->get_id_legajo_activo();                        
                                            
                                            $datosWS = $this->cargarDatosWSCobros($fila[4], $argumentos, $solicitud['identificador_deuda'], $certificado);

                                            $solicitud['id_certif_pedido'] = $solicitud['certif_pedido'];

                                            $error = $this->modelo()->asignar_identificador_cobro($solicitud, $datosWS);
                                            
                                            if ($error) { 

                                                /*             * * Si hay error o problemas con el wsCobro  ** */
                                                syslog(LOG_WARNING, "ERROR de comunicacion con WS de Medios de Cobro para Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $controlaSiPago[9] . " para el certificado " . $certificado);
                                                closelog();
                                                $this->inicioSolicitud = true;
                                                $this->retornoOk = 500;
                                                $pagelet = $this->vista()->mostarUrl();
                                                $this->vista()->get_pagelet_segunda_columna();
                                                $this->add_var('formulario', $pagelet);
                                                kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                                kernel::renderer()->add($this->vista()->pagelet('formulario'));
                                            }
                                            else {
                                                $params['id_certificado']= $solicitud['id_certif_pedido'];                                      
                                                $datos_certif = catalogo::consultar('certificados', 'u820_certificado_solicitado', $params);                                                                                               
                                                                                                
                                        syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                                        closelog();
                                        $this->inicioSolicitud = true;
                                        $this->retornoOk = 5;
                                                $this->identificadorCobro = $datos_certif['IDENTIFICADOR_COBRO'];
                                                $this->ministerial = $fila[12];
                                                $this->fechaVencimiento = $fila[3];
                                                $pagelet = $this->vista()->mostarUrl();
                                                $this->vista()->get_pagelet_segunda_columna();
                                                $this->add_var('formulario', $pagelet);
                                                kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                                kernel::renderer()->add($this->vista()->pagelet('formulario'));
                                            }
                                        }
                                        else {
                                            syslog(LOG_NOTICE, "Usuario " . $params['legajo'] . " ya tiene en proceso la solicitud del certificado " . $certificado);
                                            closelog();
                                            $this->inicioSolicitud = true;
                                            $this->retornoOk = 5;
                                            $this->identificadorCobro = $fila[5];
                                            $this->ministerial = $fila[12];
                                            $this->fechaVencimiento = $fila[3];
                                            $pagelet = $this->vista()->mostarUrl();
                                            $this->vista()->get_pagelet_segunda_columna();
                                            $this->add_var('formulario', $pagelet);
                                            kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                                            kernel::renderer()->add($this->vista()->pagelet('formulario'));
                                        }
                                        
                                        
                                }
                                }
                            } else if (($fila[12] == $argumentos[5] && $fila[1] == 'V') /* || (!$fueSolicitado) */) {
                                $this->solicitarPago($certificado, $cantidad_copias, $argumentos);
                            }
                        }
                    } else {
                        $this->solicitarPago($certificado, $cantidad_copias, $argumentos);
                    }
                }
            }
        }
    }

    public function solicitarPago($certificado, $cantidad_copias, $argumentos) {

        /*         * *  Carga de valores para el ws ** */
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $hash = md5(guarani::persona()->get_nro_documento() . date("Y-m-d H:i:s") . $uA);

        $identificadorDeuda = $uA . guarani::persona()->get_id_carrera_activa() . date("YmdHis");
        $datosWS = $this->cargarDatosWSCobros($hash, $argumentos, $identificadorDeuda, $certificado);

        openlog("Solicitud Pago Certificado " . $certificado, LOG_PID, LOG_LOCAL0);
        syslog(LOG_INFO, "Usuario " . kernel::persona()->get_id_legajo_activo() . " genera el identificador de deuda " . $identificadorDeuda);

            /*             * * Solicitud certificado a guarani ** */
            $hubo_error = $this->exec_fn_modelo('evt__solicitar', array($certificado, $cantidad_copias, $argumentos));

            /*             * *  Si no hay error al querer solicitarlo ** */
            if (!$hubo_error) {
                syslog(LOG_INFO, "No hay error en la solicitud para el Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda . " e identificador de cobro " . $resultado["return"]["codigo"] . " para el certificado " . $certificado);
                $fecha = date_create();
              
                date_add($fecha, date_interval_create_from_date_string($datosWS->vigencia . ' days'));
                $fecha_vence = date_format($fecha, 'd-m-Y');

                $this->fechaVencimiento = $fecha_vence;

                $params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
                $params['certificado'] = $certificado;

                /*                 * * Consulto el id de certificado pedido ** */
                $nro_solicitud_certificado = catalogo::consultar('certificados', 'nro_solicitud_certificado', $params);
                $parametro['ua'] = $uA;
                $parametro['nro_solicitud'] = $nro_solicitud_certificado;
                $parametro['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                $parametro['nro_certificado'] = $certificado;
                $nro_id_certif = catalogo::consultar('certificados', 'obtiene_idCertif', $parametro);

                $mensaje = kernel::traductor()->trans('solicitud_certificado.mensaje_exito');
                $mensaje = str_replace("%nro_trans%", $nro_solicitud_certificado, $mensaje);

                /*                 * * Insertar u820_pedidos_certif ** */
                $parametros['id_certif_pedido'] = $nro_id_certif[0]['ID'];
                $parametros['fecha_vencimiento_pago'] = $fecha_vence;
                $parametros['hash_pago'] = $hash; // el que genere en la url
                $parametros['identificador_deuda'] = $identificadorDeuda; //viene de vuelta en el ws
                
                /*
                 * Consulta si existe un path nuxeo para la persona
                 */
                $path = catalogo::consultar('certificados', 'get_path_nuxeo', ['nro_inscripcion' => kernel::persona()->get_nro_inscripcion()]);
                $path = $path[0]['PATH_NUXEO'];

                /*
                 * Si no existe, lo genero
                 */
                if (empty($path)) {
                    $p = catalogo::consultar('certificados', 'get_pais_tipo_nro_doc', $parametro);
                    $path = "{$p[0]['PAIS_DOCUMENTO']}_{$p[0]['TIPO_DOCUMENTO']}_{$p[0]['NRO_DOCUMENTO']}";
                }

                $parametros['path_nuxeo'] = $path;                
                
                $ok = catalogo::consultar('certificados', 'guardar_certificado_arancelado', $parametros);
                syslog(LOG_INFO, "Se inserta el registro en u820_pedidos_certif para el Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda . " e identificador de cobro " . $parametros['identificador_cobro']);
                closelog();
                
                syslog(LOG_INFO, "Se hace la llamada al Web service notifica nueva deuda para Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda . " certificado " . $certificado);
                $error = $this->asignar_identificador_cobro(array(0 => $parametros['id_certif_pedido'], 9 => $identificadorDeuda), $datosWS);
                
                /*         * * Si el ws no devuelve faultcode solicito efectivamente certificado a guarani ** */
                if (!$error) {
                    syslog(LOG_INFO, " Web service notifica nueva deuda al Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda);

                /*                 * * Muestro la vista ** */
                $this->retornoOk = 1;
                $this->nroCertificado = $certificado;

                $pagelet = $this->vista()->mostarUrl();
                $this->vista()->get_pagelet_segunda_columna();
                $this->add_var('formulario', $pagelet);
                kernel::renderer()->add_to_ajax_response('nro_solicitud_certificado', $mensaje);
                kernel::renderer()->add($this->vista()->pagelet('formulario'));

            } else {
                    /*             * * Si hay error o problemas con el wsCobro  ** */
                    syslog(LOG_WARNING, "ERROR en el Web service de notificar nuevo cobro al Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda . " para el certificado " . $certificado);
                    closelog();
                    $pagelet = $this->vista()->mostarError();
                    $this->add_var('errorws', $pagelet);
                    kernel::renderer()->add_to_ajax_response('hubo_error', 'Disculpe las molestias');
                    kernel::renderer()->add($this->vista()->pagelet('errorws'));
                }
                
                
            } else {
                /*                 * * Si hay error al solicitar ** */
                syslog(LOG_WARNING, " Hay error en la solicitud para el Usuario " . kernel::persona()->get_id_legajo_activo() . "  con el identificador de deuda " . $identificadorDeuda . " certificado " . $certificado);
                closelog();
                $mensajes = $this->get_var('mensajes');
                if (!empty($mensajes)) {
                    $this->vista()->set_hay_mensajes(true);
                }
                $this->vista()->set_error($hubo_error);
                kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
            }

        
        }

    public function cargarDatosWSCobros($hash, $argumentos, $identificadorDeuda, $certificado) {

        $mdC = new ClienteMediosCobro();

        $url = $mdC->configEntorno['wsMediosDeCobro']['urlNotificacion'] . $hash;
        $urlTramite = $url;

        $datosWs = new \StdClass();
        $datosWs->apellido = guarani::persona()->get_solo_apellido();
        $datosWs->nombre = guarani::persona()->get_solo_nombre();
        $datosWs->nroDoc = guarani::persona()->get_nro_documento();
        $datosWs->url = $urlTramite; // urlBase/tramites/cambiarEstadoPago.php?hc=nroDoc+fecha+ua
        $datosWs->tipoDoc = 1;
        $datosWs->paisDoc = 54;
        $datosWs->email = guarani::persona()->get_mail();
        $datosWs->vigencia = $mdC->configApp['wsMediosDeCobro']['diasVence' . $certificado];
        $datosWs->identificadorDeuda = $identificadorDeuda;

        if (isset($argumentos[5]) && $argumentos[5] === 'S') {

            $this->ministerial = 'S';
            $validacion_detalle = ' CON VALIDACION MINISTERIAL';
            $this->montoCetificado = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado] + $mdC->configApp['wsMediosDeCobro']['montoMinisterio' . $certificado];
            $datosWs->monto = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado] + $mdC->configApp['wsMediosDeCobro']['montoMinisterio' . $certificado];
            $datosWs->entidad = $mdC->configApp['wsMediosDeCobro']['entidadMinisterio'];
            $datosWs->idServicio = $mdC->configApp['wsMediosDeCobro']['idServicioMinisterio' . $certificado];
        } else {
            $this->ministerial = 'N';
            $validacion_detalle = ' ';
            $this->montoCetificado = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado];
            $datosWs->monto = $mdC->configApp['wsMediosDeCobro']['monto' . $certificado];
            $datosWs->entidad = $mdC->configApp['wsMediosDeCobro']['entidad'];
            $datosWs->idServicio = $mdC->configApp['wsMediosDeCobro']['idServicio' . $certificado];
        }
        $datosWs->cuotas = $mdC->configApp['wsMediosDeCobro']['cuotas'];
        $periodo = (string) date("m/Y");
        $datosWs->periodo = $periodo;
        $params['titulo'] = $argumentos[3];
        $nombreTitulo = catalogo::consultar('alumno', 'nombre_de_titulo', $params);
      
        $carrera = guarani::persona()->get_info_carrera_activa();
        $datosWs->detalle = $mdC->configApp['wsMediosDeCobro']['detalle' . $certificado] .$validacion_detalle. " - " . $argumentos[1] . " - " . $nombreTitulo['NOMBRE'];//$carrera["nombre"];
        $medioPago = explode(',', $mdC->configApp['wsMediosDeCobro']['medioPago']);
        $datosWs->medioPago = ($medioPago[0] == "") ? array() : $medioPago;

        return $datosWs;
    }

    public function get_listaCertificados() {

        $this->certificadosArancelados = catalogo::consultar('certificados', 'listado_arancelados', array());
        return $this->certificadosArancelados;
    }

    public function get_inicioSolicitud() {
        return $this->inicioSolicitud;
    }

    public function get_retornoOk() {
        return $this->retornoOk;
    }

    public function get_nroCertificado() {
        return $this->nroCertificado;
    }

    public function get_fechaVencimiento() {
        return $this->fechaVencimiento;
    }

    public function get_identificadorCobro() {
        return $this->identificadorCobro;
    }

    public function get_montoCetificado() {
        return $this->montoCetificado;
    }

    public function get_ministerial() {
        return $this->ministerial;
    }

    public function get_nroExpediente() {
        return $this->nroExpediente;
    }

    private function obtieneIdCertifPedido($certificado, $uA) {

        $params['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
        $params['certificado'] = $certificado;
        $nro_solicitud_certificado = catalogo::consultar('certificados', 'nro_solicitud_certificado', $params);



        $parametro['ua'] = $uA;
        $parametro['nro_solicitud'] = $nro_solicitud_certificado;
        $parametro['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametro['nro_certificado'] = $certificado;
        $nro_id_certif = catalogo::consultar('certificados', 'obtiene_idCertif', $parametro);
        $parametros['id_certif_pedido'] = $nro_id_certif[0]['ID'];

        $datos = catalogo::consultar('certificados', 'controla_si_pago', $parametros);



        return $datos;
    }

    function asignar_identificador_cobro($diplomaSolicitado, $datosWS) {
        
        $error = false;
        
        $claseMdC = new ClienteMediosCobro();     
        $resp1 = $claseMdC->consultarIdentificadorCobro($diplomaSolicitado[9]);    
        
        // Comunicacion exitosa SIN resultado (string vacio). No existe deuda.
        if (!isset($resp1['faultcode']) && (empty($resp1)) && ($resp1 !== false)) {           
            $resp2 = $claseMdC->notificarNuevoCobro($datosWS);
            
            if (!isset($resp2['faultcode']) && (!empty($resp2)) && ( $resp2 !== false)) {
                $this->identificadorCobro = $identificadorCobro = $resp2["return"]["codigo"];
}
            
            // Falla WS [notificarNuevoCobro]
            elseif (isset($resp2['faultcode']) || ( $resp2 === false)) {
                $error = true;
            }
        }
        
        // Comunicacion exitosa CON resultado. Ya existe deuda.
        elseif (!isset($resp1['faultcode']) && (!empty($resp1)) && ($resp1 !== false)) {           
            $this->identificadorCobro = $identificadorCobro = $resp1["return"]["codigo"];
        }
                  
        // Falla WS [consultarIdentificadorCobro]
        elseif (isset($resp1['faultcode']) || ( $resp1 === false)) {
            $error = true;
        }
        
        if (!$error) {
            catalogo::consultar('certificados', 'guardar_identificador_cobro', array(
                'id_certif_pedido'             => $diplomaSolicitado[0],
                'identificador_cobro'   => $identificadorCobro
                )); 
        }
        
        return $error;
                    
    }
    
    // test dos titulos 30787004

}
