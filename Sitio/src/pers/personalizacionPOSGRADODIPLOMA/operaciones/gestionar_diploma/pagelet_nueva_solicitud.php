<?php

namespace personalizacionPOSGRADODIPLOMA\operaciones\gestionar_diploma;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;

require_once '../../../clientes_ws/nuxeo/clientews.php';
require_once '../../../clientes_ws/mediosCobro/clientews.php';
require_once '../../../clientes_ws/digitalizador/clientews.php';

use ClienteDigitalizador;
use ClienteMediosCobro;
use ClienteNuxeo;

class pagelet_nueva_solicitud extends pagelet {

    function get_nombre() {
        return 'nueva_solicitud';
    }

    public function prepare() {
        $this->data = array();

        $wsCobro = new ClienteMediosCobro();

        $operacion = kernel::ruteador()->get_id_operacion();
        $certificado = $this->controlador->get_nroCertificado();
        $this->data['encuestaCompleta'] = $this->controlador->get_encuestaCompleta();

        $this->data['nroDocumento'] = kernel::persona()->get_nro_documento();
        $this->data['nombreApellido'] = kernel::persona()->get_nombre();
        $this->data['sexo'] = kernel::persona()->get_sexo();
        $this->data['email'] = kernel::persona()->get_mail();

        $datosCensales = guarani::datos_censales()->get_datos_censales();

        $this->data['censales'] = $datosCensales;
        $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
        $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
        $this->data['titulos'] = catalogo::consultar('alumno', 'titulos_estado_adelantado', $parametros);

        $this->data['titulosObtenidos'] = catalogo::consultar('alumno', 'titulos_obtenidos_x_carrera', $parametros);


        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros['ua'] = guarani::ua()->get_id();
        
         // limpiar cache
	catalogo::limpiar_cache('alumno', 'datos_personales', $parametros);
        $datos_personales = catalogo::consultar('alumno', 'datos_personales', $parametros);
        $this->data['datos_personales'] = $datos_personales[0];

        foreach ($this->data['titulosObtenidos'] as $value) {
            if ($value['TIPO_DE_CARRERA'] == 'P' || $value['TIPO_DE_CARRERA'] == 'S') {
                $estudios = catalogo::consultar('alumno', 'estudio_superior', $parametros);
                $this->data['estudios_previos'] = $estudios[0]['NOMBRE'];
                $this->data['institucion'] = $estudios[0]['NOMBRE_INSTITUCION'];
            } else if ($value['TIPO_DE_CARRERA'] == 'C' || $value['TIPO_DE_CARRERA'] == 'R') {
                $this->data['estudios_previos'] = $this->data['datos_personales']['titulo_secundario'];
                $this->data['institucion'] = $this->data['datos_personales']['colegio_secundario'];
            } else {
                $this->data['estudios_previos'] = $datosCensales['AUX2_ALU_OTESTSUP_CARR'];
                $this->data['institucion'] = $datosCensales['AUX2_ALU_OTESTSUP_UNI'];
            }
            $tipo_carrera = $value['TIPO_DE_CARRERA'];
        }

        $solicitudYaIniciada = $this->data['inicioSolicitud'] = $this->controlador->get_inicioSolicitud();

        $montoSin = $wsCobro->configApp['wsMediosDeCobro']['monto' . $certificado] + 0;
        $montoCon = $wsCobro->configApp['wsMediosDeCobro']['montoConCarton' . $certificado] + $montoSin;
        $this->data['montoSin'] = $montoSin;
        $this->data['montoCon'] = $montoCon;
        $this->data['montoSinEspecial'] = $wsCobro->configApp['wsMediosDeCobro']['montoEspecial' . $certificado] + 0;
        $this->data['montoConEspecial'] = $wsCobro->configApp['wsMediosDeCobro']['montoConCartonEspecial' . $certificado] + $this->data['montoSinEspecial'];

        if ($this->controlador->get_errorAlSolicitar()) {

            $this->data['error_solicitud'] = true;
        } else {
            if (!$solicitudYaIniciada) {


                $this->data['url_solicitar'] = kernel::vinculador()->crear($operacion, 'nueva_solicitud');
            } else {


                $parametros = array();
                $parametros['tipo_carrera'] = $tipo_carrera;
                $parametros['id_certificado'] = $this->controlador->get_idCertificado();

                $this->data['u820_certif'] = catalogo::consultar('certificados', 'u820_certificado_solicitado', $parametros);
                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                $this->data['u820_diploma'] = catalogo::consultar('certificados', 'u820_certificado_diploma', $parametros);

				$parametros['tipo_tramite'] = $this->data['u820_diploma']['TIPO_TRAMITE'];
				$this->data['requisitosDiploma'] = catalogo::consultar('alumno', 'obtener_requisitos_diploma', $parametros);
                /*  URL MERCURIO */
                    $urlPagar = $wsCobro->configEntorno['wsMediosDeCobro']['urlMediosPago'] . "/" . $this->data['u820_certif']['IDENTIFICADOR_COBRO'];
                    $this->data['urlPagarDiploma'] = $urlPagar;

                /*  URL MESA DE ENTRADA */
                $urlExpediente = $wsCobro->configEntorno['wsExpedientes']['urlConsulta'] . "/expediente/" . $this->data['u820_certif']['EXPEDIENTE'];
                $this->data['urlMesaEntrada'] = $urlExpediente;

                /*  Carga de datos para digitalizador  */
                $datosDigitalizador = $this->cargarDatosWSDigitalizar($parametros['id_certificado'], $datos_personales, $this->data['requisitosDiploma']);
                $prueba = new ClienteDigitalizador();
                /*  llamada a ws digitalizador  */
                $retorno = $prueba->obtenerUrlDigitalizador($datosDigitalizador);

                /* inyecto el nombre del requisito en el retorno del ws para saber que frame es cada uno */
                for ($i = 0; $i < count($retorno); $i++) {
                    if ($retorno[$i]->identificador == $this->data['requisitosCertif'][$i]['HASH_NOTIFICACION']) {
                        $retorno[$i]->nombreRequisito = $this->data['requisitosCertif'][$i]['NOMBRE_REQUISITO'];
                    }
                }
                $this->data['iframes'] = $retorno;
            }
        }
    }

    public function cargarDatosWSDigitalizar($idPedidoCertif, $datos_personales, $datosRequisitos) {
        $param['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $this->data['datosPersonales'] = catalogo::consultar('alumno', 'datos_principales_alumno', $param);


        $parametros['id_certif'] = $idPedidoCertif;
        $this->data['requisitosCertif'] = catalogo::consultar('certificados', 'u820_pedidos_certif_diploma_req', $parametros);

        $digi = new ClienteDigitalizador();

        $path = catalogo::consultar('certificados', 'get_path_nuxeo', ['nro_inscripcion' => kernel::persona()->get_nro_inscripcion()]);
        $nombreDocumentoNuxeo = $path[0]['PATH_NUXEO'];

        $datos = array();
        for ($i = 0; $i < count($this->data['requisitosCertif']); $i++) {
            $datos[$i]["propsPublicador"] = array();
            $datos[$i]["propsPublicador"]["propsDocumento"] = array();
            foreach ($datosRequisitos as $value) {
                if ($value['REQUISITO'] == $this->data['requisitosCertif'][$i]['REQUISITO']) {
                    $datos[$i]["identificador"] = $this->data['requisitosCertif'][$i]['HASH_NOTIFICACION'];
                    $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:descRequisito"] = utf8_encode($value['NOMBRE']);
                    $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:tipoDocu"] = ($value['METADATO_TIPO_DOCUMENTO'] != '') ? utf8_encode($value['METADATO_TIPO_DOCUMENTO']) : 'TIPO_DOCUMENTO SIN NOMBRE';
                    $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:subtipoDocu"] = ($value['METADATO_SUBTIPO_DOCUMENTO'] != '') ? utf8_encode($value['METADATO_SUBTIPO_DOCUMENTO']) : 'Completo';
                    $datos[$i]["cantidadMaxima"] = ($value['METADATO_CANTIDAD_MAXIMA'] != '') ? (int) $value['METADATO_CANTIDAD_MAXIMA'] : 2;
                    $this->data['requisitosCertif'][$i]['NOMBRE_REQUISITO'] = $value['NOMBRE'];
                    $datos[$i]["propsPublicador"]["nombreDocumento"] = $nombreDocumentoNuxeo . "_" . utf8_encode($value['NOMBRE']);
                    $datos[$i]["propsPublicador"]["propsDocumento"]["dc:title"] = $nombreDocumentoNuxeo . "_" . utf8_encode($value['NOMBRE']);
                    if ($value['REQUISITO'] == 'UNL04') {
                        $datos[$i]["extensionesPermitidas"] = array("jpg", "png", "jpeg", "gif");
                    }
                }
            }
            $datos[$i]["urlRespuesta"] = $digi->configEntorno["wsDigitalizador"]["urlRespuesta"];


            $datos[$i]["propsPublicador"]["pubspaceRepo"] = $digi->configApp["wsDigitalizador"]["pubspaceRepo"];
            $datos[$i]["propsPublicador"]["workspaceRepo"] = $digi->configApp["wsDigitalizador"]["workspaceRepo"];
            $datos[$i]["propsPublicador"]["tipoDocumento"] = $digi->configApp["wsDigitalizador"]["tipoDocumento"];
            $datos[$i]["propsPublicador"]["sePublica"] = $digi->configApp["wsDigitalizador"]["sePublica"];
            $datos[$i]["propsPublicador"]["encarpetar"] = $digi->configApp["wsDigitalizador"]["encarpetar"];

            $datos[$i]["propsPublicador"]["nombreCarpeta"] = $nombreDocumentoNuxeo;

            $datos[$i]["propsPublicador"]["propsDocumento"]["canalitico:ApeNombre"] = $this->data['datosPersonales']['APELLIDO'] . ' ' . $this->data['datosPersonales']['NOMBRES'];
            $datos[$i]["propsPublicador"]["propsDocumento"]["canalitico:TipoDocumento"] = $this->data['datos_personales']['documento_tipo'];
            $datos[$i]["propsPublicador"]["propsDocumento"]["canalitico:NroDocumento"] = $this->data['datosPersonales']['NRO_DOCUMENTO'];
            $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:codigoPais"] = $this->data['datosPersonales']['PAIS_DOCUMENTO'];
            $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:cuil"] = (!is_null($this->data['datosPersonales']['NUMERO_CUIL'])) ? $this->data['datosPersonales']['NUMERO_CUIL'] : '';
            $datos[$i]["propsPublicador"]["propsDocumento"]["comunLegajo:descPais"] = $datos_personales[0]['pais_nac'];
        }

        return $datos;
    }

        }
