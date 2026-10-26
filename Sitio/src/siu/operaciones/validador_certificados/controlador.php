<?php
namespace siu\operaciones\validador_certificados;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use kernel\util\url;
use siu\modelo\guarani_notificacion;
use siu\guarani;
use kernel\util\u;
use kernel\error_kernel_db;
use siu\errores\error_guarani_usuario;


class controlador extends controlador_g3w2 
{
	/**
     * @return null
     */
    function modelo()
    {
        return null;
    }

    function accion__index()
    {
        try{
            $this->vista()->pagelet('validador')->data['codigo_validacion'] = null;
            $this->vista()->pagelet('validador')->data['codigo_validacion_disabled'] = false;
            $this->vista()->pagelet('validador')->add_var_js('codigo_validacion_focus', true);

            $codigo_validacion = $this->validate_param(0, 'get', validador::TIPO_INT, array(
                'allowempty' => true,
                'default' => null
            ));

            if($codigo_validacion){
                $this->vista()->pagelet('validador')->data['codigo_validacion'] = $codigo_validacion;
                $this->vista()->pagelet('validador')->data['codigo_validacion_disabled'] = true;
                $this->vista()->pagelet('validador')->add_var_js('codigo_validacion_focus', false);
            }
        }
        catch(\Exception $e){

        }

    }

    function accion__validar()
    {
    	
    	if (kernel::request()->isPost()) {

    		$codigo_validador = kernel::request()->getPost('codigo_valid');
    		$parametros['codigo_validador'] = $codigo_validador;

    		try {
                $captcha_ok = static::check_recaptcha2();
    			if(!$captcha_ok) {//Si falla captcha...
    		        throw new error_guarani_usuario(kernel::traductor()->trans('error_recaptcha'));
    			}

                if($codigo_validador == ''){//Si codigo validador vacio...
                    $this->vista()->set_pagelet('validador');
                    $pagelet = $this->vista()->pagelet('validador');
                    $pagelet->add_var_js('codigo_validacion_focus', true);
                    $pagelet->data['error_codigo_validador'] = true;
                    $pagelet->data['error_codigo_validador_msj'] = kernel::traductor()->trans('validador_certificados.error_debe_ingresar_codigo_validacion');
                    $pagelet->data['codigo_validacion'] = $codigo_validador;
                    $pagelet->data['codigo_validacion_disabled'] = false;
                }
                elseif(!preg_match('/^[0-9]{14}$/', $codigo_validador)){//Si codigo validador invalido...
                    $this->vista()->set_pagelet('validador');
                    $pagelet = $this->vista()->pagelet('validador');
                    $pagelet->add_var_js('codigo_validacion_focus', true);
                    $pagelet->data['error_codigo_validador'] = true;
                    $pagelet->data['error_codigo_validador_msj'] = kernel::traductor()->trans('validador_certificados.error_codigo_validacion_invalido');
                    $pagelet->data['codigo_validacion'] = $codigo_validador;
                    $pagelet->data['codigo_validacion_disabled'] = false;
                }
                else{
                    $certificado = catalogo::consultar('certificados', 'recuperar_certificado_web', $parametros);
                    $this->vista()->set_pagelet('confirmacion');
                    $pagelet = $this->vista()->pagelet('validador');

                    if($certificado){
                        $parametros = $certificado['PARAMETROS'];
                        $pagelet->data['certificado_valido'] = true;

                        switch ($certificado['TIPO_CERTIFICADO']) {
                            case 1://Si es Certificado de Alumno Regular
                                $pagelet->data['tipo_certificado'] = $certificado['TIPO_CERTIFICADO'];
                                $pagelet->data['titulo'] = kernel::traductor()->trans('validador_cert_alu_regu.el_alumno_es_regular', array(
                                    '%articulo%' => ucfirst($parametros['articulo']),
                                    '%genero%' => $parametros['genero']
                                ));
                                $pagelet->data['descripcion'] = kernel::traductor()->trans('form.cert_alu_regular.primera_parte', array(
                                    '%facultad%' => $parametros['nombre_facultad'],
                                    '%genero%' => "{$parametros['articulo']} {$parametros['genero']}",
                                    '%alumno%' => $parametros['nom_ape_alumno'],
                                    '%legajo%' => $parametros['legajo'],
                                    '%tipo_doc%' => $parametros['desc_tipo_docum'],
                                    '%nro_doc%' => $parametros['nro_documento'],
                                    '%origen%' => $parametros['nacionalidad'],
                                    '%carrera%' => $parametros['carrera_nombre'],
                                    '%plan%' => $parametros['plan'],
                                    '%anio_ingreso%' => $parametros['anio_ingreso']
                                ));
                                break;
                        }

                    }
                    else{
                        $pagelet->data['certificado_valido'] = false;
                    }
                }

    		} catch (error_guarani_usuario $e) {
    			$this->vista()->set_pagelet('validador');
                $pagelet = $this->vista()->pagelet('validador');
                $pagelet->add_var_js('codigo_validacion_focus', false);
                $pagelet->data['codigo_validacion'] = $codigo_validador;
                $pagelet->data['codigo_validacion_disabled'] = true;
    			$mensajes[] = new guarani_notificacion(guarani_notificacion::error, $e->get_mensaje());
    			$this->add_var('mensajes', $mensajes);
    			kernel::log()->add_error($e);
    		}
    	}
    }

}