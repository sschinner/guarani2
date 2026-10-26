<?php

namespace personalizacionUA\operaciones\solicitud_certificado;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;

require_once '../../../clientes_ws/mediosCobro/clientews.php';

use ClienteMediosCobro;

class pagelet_formulario extends \siu\operaciones\solicitud_certificado\pagelet_formulario {

    public function get_nombre() {
        return 'formulario';
    }

    function prepare() {
        $this->add_var_js('url_carga_form', kernel::vinculador()->crear('solicitud_certificado', 'cargar_form'));
        $this->data['url_form'] = kernel::vinculador()->crear('solicitud_certificado', 'solicitar');
        $id_form = $certificado = $this->controlador->get_id_certificado();
        $solicitud = $this->controlador->get_retornoOk();
        $this->data['retornoWS'] = $solicitud;
        $this->data['DNGyFU']= utf8_decode('La DNGyFU rechaza la intervención de documentos expedidos a presentar ANTE QUIEN CORRESPONDA, por ello, debe indicar efectivamente un Organismo/Institución/País, entre otros, en este campo.');
        $this->data['yaSolicitado'] = $this->controlador->get_inicioSolicitud();
        $this->data['nroCertificado'] = $this->controlador->get_nroCertificado();
        //$certificado = $this->controlador->get_certificado();
        if (!empty($id_form)) {
            $this->data['id_form'] = $id_form;
            $argumentos = $this->controlador->modelo()->argumentos_certificado($id_form);
            $this->data['form_argumentos'] = $argumentos;
            $wsCobro = new ClienteMediosCobro();
            $montoSin = $wsCobro->configApp['wsMediosDeCobro']['monto' . $certificado] + 0;
            $montoCon = $wsCobro->configApp['wsMediosDeCobro']['montoMinisterio' . $certificado] + $montoSin;
            $this->data['montoSin'] = $montoSin;
            $this->data['montoCon'] = $montoCon;
            if ($solicitud === 1) {
                $this->data['debePagar'] = true;
                $urlPagar = $wsCobro->configEntorno['wsMediosDeCobro']['urlMediosPago'] . "/" . $this->controlador->get_identificadorCobro();

                $this->data['urlPagar'] = $urlPagar;
                $this->data['texto1'] = utf8_decode(' Se ha registrado su solicitud de Certificado satisfactoriamente');
                $this->data['texto2'] = utf8_decode('Paso a seguir:');
                $this->data['texto3'] = utf8_decode('1- Abonar el importe de $' . $this->controlador->get_montoCetificado() . ' (según resolución de Tasas) a través de alguno de los medios de pago que se presentan en el siguiente enlace:');
                $this->data['texto4'] = utf8_decode('La fecha de vencimiento de pago es ' . $this->controlador->get_fechaVencimiento() . '.');
                $this->data['texto5'] = utf8_decode('2- Se le notificará por e-mail, cuando el pago se haya acreditado correctamente.');
                $this->data['texto6'] = utf8_decode('3- Recibirá un segundo e-mail, notificando que su trámite ha ingresado por Mesa de Entrada y obtendrá el número de expediente del mismo para realizar el seguimiento interno.');
                if ($this->controlador->get_ministerial() === 'N') {
                    $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificado" ');
                } else {
                    $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados ". En caso de haber solicitado la Certificación Ministerial, además deberá acercarse a la facultad para retirar el mismo. ');
                }
                $this->data['texto8'] = utf8_decode('OBSERVACIÓN: Verificar su dirección de correo electrónico dentro de su área de "Configuración", para que las notificaciones lleguen correctamente a su destino.');
            } else if ($solicitud === 2) {
                $u = new unidad_academica(\siu\guarani::get_ua_id());
                $uA = utf8_encode($u->get_id());
                $parametro['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();
                $parametro['ua'] = $uA;
                $parametro['nro_certificado'] = $this->data['nroCertificado'];
                $parametro['carrera'] = guarani::persona()->get_id_carrera_activa();

                $data = catalogo::consultar('certificados', 'obtener_fecha_vence', $parametro);

                if (isset($data[4])) {
                    $monto = ($data[4]['ARGUMENTO'] === 'S') ? $montoCon : $montoSin;
                    if ($data[4]['ARGUMENTO'] === 'S') {
                        $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados". En caso de haber solicitado la Certificación Ministerial, además deberá acercarse a la facultad para retirar el mismo. ');
                    } else {
                        $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados" ');
                    }
                } else {
                    $monto = $montoSin;
                    $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados" ');
                }
                $fecha = $data[0]['FECHA_VENCIMIENTO_PAGO'];
                $identificadorCobro = $data[0]['IDENTIFICADOR_COBRO'];

                $this->data['debePagar'] = true;
                $this->data['urlPagar'] = $wsCobro->configEntorno['wsMediosDeCobro']['urlMediosPago'] . "/" . $identificadorCobro;
                $this->data['texto1'] = utf8_decode(' Su solicitud de Certificado esta en proceso');
                $this->data['texto2'] = utf8_decode('Recuerde seguir los siguientes pasos:');
                $this->data['texto3'] = utf8_decode('1- Abonar el importe de $' . $monto . ' (según resolución de Tasas) a través de alguno de los medios de pago que se presentan en el siguiente enlace:');
                $this->data['texto4'] = utf8_decode('La fecha de vencimiento de pago es ' . $fecha . '.');
                $this->data['texto5'] = utf8_decode('2- Se le notificará por e-mail, cuando el pago se haya acreditado correctamente.');
                $this->data['texto6'] = utf8_decode('3- Recibirá un segundo e-mail, notificando que su trámite ha ingresado por Mesa de Entrada y obtendrá el número de expediente del mismo para realizar el seguimiento interno.');


                $this->data['texto8'] = utf8_decode('OBSERVACIÓN: Verificar su dirección de correo electrónico dentro de su área de "Configuración", para que las notificaciones lleguen correctamente a su destino.');
            } else if ($solicitud === 3) {
                $nroExpediente = $this->controlador->get_nroExpediente();
                $this->data['texto1'] = utf8_decode(' Su solicitud de Certificado ya se encuentra en proceso');
                $this->data['texto2'] = utf8_decode("Ud. puede consultar online el seguimiento del trámite iniciado, por medio del sistema Mesa de Entradas - Seguimiento de Expedientes: ".$nroExpediente);
             
            }else if ($solicitud === 4) {
                
                $this->data['debePagar'] = true;
                $this->data['texto1'] = utf8_decode(' Su Certificado ya se encuentra disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados"');
                $this->data['texto2'] = utf8_decode("OBSERVACIÓN: Ud. puede descargar las veces que sea necesario el certificado");
            }else if ($solicitud === 5) {
                 $ministerio = $this->controlador->get_ministerial();
                 if (isset($ministerio)) {
                    $monto = ($ministerio=== 'S') ? $montoCon : $montoSin;
                    if ($ministerio === 'S') {
                        $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados". En caso de haber solicitado la Certificación Ministerial, además deberá acercarse a la facultad para retirar el mismo. ');
                    } else {
                        $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados" ');
                    }
                } else {
                    $monto = $montoSin;
                    $this->data['texto7'] = utf8_decode('4- Una vez concluído todo el proceso, se le notificará que el Certificado estará disponible para su descarga por medio de la operación "Trámites" --> "Descarga de Certificados" ');
                }
                $fecha = $this->controlador->get_fechaVencimiento();
                $identificadorCobro = $this->controlador->get_identificadorCobro();

                $this->data['debePagar'] = true;
                $this->data['urlPagar'] = $wsCobro->configEntorno['wsMediosDeCobro']['urlMediosPago'] . "/" . $identificadorCobro;
                $this->data['texto1'] = utf8_decode(' Su solicitud de Certificado esta en proceso');
                $this->data['texto2'] = utf8_decode('Recuerde seguir los siguientes pasos:');
                $this->data['texto3'] = utf8_decode('1- Abonar el importe de $' . $monto . ' (según resolución de Tasas) a través de alguno de los medios de pago que se presentan en el siguiente enlace:');
                $this->data['texto4'] = utf8_decode('La fecha de vencimiento de pago es ' . $fecha . '.');
                $this->data['texto5'] = utf8_decode('2- Se le notificará por e-mail, cuando el pago se haya acreditado correctamente.');
                $this->data['texto6'] = utf8_decode('3- Recibirá un segundo e-mail, notificando que su trámite ha ingresado por Mesa de Entrada y obtendrá el número de expediente del mismo para realizar el seguimiento interno.');


                $this->data['texto8'] = utf8_decode('OBSERVACIÓN: Verificar su dirección de correo electrónico dentro de su área de "Configuración", para que las notificaciones lleguen correctamente a su destino.');
                
            }
            else if ($solicitud == 500) {

                 $this->data['debePagar'] = true;

        }
    }
    }

}

?>
