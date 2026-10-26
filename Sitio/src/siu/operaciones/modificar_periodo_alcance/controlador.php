<?php
namespace siu\operaciones\modificar_periodo_alcance;

use kernel\error_kernel_validacion;
use kernel\kernel;
use kernel\util\validador;
use siu\extension_kernel\controlador_g3w2;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\transacciones\encuestas;

class controlador extends controlador_g3w2
{

    /**
     * @return encuestas
     */
    function modelo()
    {
        return guarani::encuestas();
    }

    function accion__index()
    {

    }

    function get_alcance_by_id($alcance_id){
        return catalogo::consultar('encuestas', 'get_alcance_by_id', array('alcance' => $alcance_id));
    }

    function accion__guardar()
    {

        try{

            try{
                $parametro = "alcance";
                $alcance_id = $this->validate_param('alcance', 'post', validador::TIPO_INT);
                $parametro = "fecha desde";
                $nueva_fecha_desde = $this->validate_param('fecha_desde', 'post', validador::TIPO_DATE, array('format' => 'd/m/Y'));
                $parametro = "fecha hasta";
                $nueva_fecha_hasta = $this->validate_param('fecha_hasta', 'post', validador::TIPO_DATE, array('format' => 'd/m/Y'));
                $parametro = "";
            }
            catch(\Exception $e){
                throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.error_en_el_parametro', array("%parametro%" => $parametro)));
            }

            $alcance = $this->get_alcance_by_id($alcance_id);

            if($alcance){//Si el alcance existe...

                $datetime_fecha_desde = \DateTime::createFromFormat('!d/m/Y', $alcance['FECHA_DESDE']);
                $datetime_fecha_hasta = \DateTime::createFromFormat('!d/m/Y', $alcance['FECHA_HASTA']);
                $datetime_fecha_actual = new \DateTime('today');
                $fecha_hasta_editable = false;
                $fecha_desde_editable = false;

                $datetime_nueva_fecha_desde = \DateTime::createFromFormat('!d/m/Y', $nueva_fecha_desde);
                $datetime_nueva_fecha_hasta = \DateTime::createFromFormat('!d/m/Y', $nueva_fecha_hasta);

                if($datetime_nueva_fecha_hasta >= $datetime_fecha_actual){
                    $fecha_hasta_editable = true;
                }

                if($datetime_fecha_desde > $datetime_fecha_actual){
                    $fecha_desde_editable = true;
                }

                if($fecha_desde_editable || $fecha_hasta_editable){//si alguna de las dos fechas es editable...

                    if($datetime_nueva_fecha_desde >= $datetime_nueva_fecha_hasta){
                        throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.fecha_desde_mayor_igual_fecha_hasta'));
                    }

                    $cambio_fecha_desde = false;
                    if($fecha_desde_editable){

                        if($datetime_nueva_fecha_desde < $datetime_fecha_actual){
                            throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.fecha_desde_menor_fecha_actual'));
                        }

                        if($datetime_nueva_fecha_desde != $datetime_fecha_desde){//Si la fecha_desde cambio...
                            $cambio_fecha_desde = true;
                            $datetime_fecha_desde = $datetime_nueva_fecha_desde;
                        }
                    }

                    $cambio_fecha_hasta = false;
                    if($fecha_hasta_editable){

                        if($datetime_nueva_fecha_hasta < $datetime_fecha_actual){
                            throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.fecha_hasta_menor_fecha_actual'));
                        }

                        if($datetime_nueva_fecha_hasta != $datetime_fecha_hasta){//Si la fecha_hasta cambio...
                            $cambio_fecha_hasta = true;
                            $datetime_fecha_hasta = $datetime_nueva_fecha_hasta;
                        }
                    }

                    if($cambio_fecha_desde || $cambio_fecha_hasta){//Si hubo cambios en las fechas...

                        $fecha_desde = ($cambio_fecha_desde)? $datetime_fecha_desde->format('Y-m-d') : null;
                        $fecha_hasta = ($cambio_fecha_hasta)? $datetime_fecha_hasta->format('Y-m-d') : null;

                        $this->modelo()->actualizar_fechas_alcance($alcance['ALCANCE'], $fecha_desde, $fecha_hasta, $alcance['KOLLA_ID_HABILITACION']);

                        kernel::renderer()->add_to_ajax_response('hubo_error', false);
                        kernel::renderer()->add_to_ajax_response('mensaje', kernel::traductor()->trans('modificar_periodo_alcance.se_guardo_con_exito'));

                    }
                    else{
                        throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.no_hubo_cambios_fechas'));
                    }

                }
                else{
                    throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.fecha_hasta_menor_fecha_actual'));
                }

            }
            else{//Si el alcance no existe...
                throw new \Exception(kernel::traductor()->trans('modificar_periodo_alcance.el_alcance_no_existe', array("%alcance%" => $alcance_id)));
            }

        }
        catch(\Exception $e){
            kernel::renderer()->add_to_ajax_response('hubo_error', true);
            kernel::renderer()->add_to_ajax_response('mensaje', $e->getMessage());
            kernel::renderer()->add_to_ajax_response('parametro_con_error', $parametro);
        }



    }

}