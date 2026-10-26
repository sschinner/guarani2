<?php
namespace siu\operaciones\orientacion;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\parametro;
use siu\modelo\transacciones\orientacion;

class controlador extends controlador_g3w2
{

    protected $permite_baja_cambio_orientacion = false;
    protected $realizo_materias_orientacion = false;

    function __construct(){
        parent::__construct();

        $orientaciones = $this->modelo()->lista_orientaciones();
        klog2('orientaciones', $orientaciones);

        if(!empty($orientaciones)){//Si tiene orientaciones...

            $orientacion_cambiar_eleccion = parametro::orientacion_cambiar_eleccion();
            klog2('orientacion_cambiar_eleccion', $orientacion_cambiar_eleccion);

            //Permite la baja o cambio de orientación del alumno
            if($orientacion_cambiar_eleccion == "S"){
                $this->permite_baja_cambio_orientacion = true;

                $orientacion_actual = $this->modelo()->orientacion_actual();
                klog2('orientacion_actual', $orientacion_actual);

                if(!empty($orientacion_actual)){//Si tiene una orientacion asignada...
                    $this->realizo_materias_orientacion = $this->modelo()->info__realizo_materias_orientacion();
                    klog2('realizo_materias_orientacion', $this->realizo_materias_orientacion);
                }

            }
            else{//no permite
                $this->permite_baja_cambio_orientacion = false;
            }

        }

    }

    /**
     * @return orientacion
     */
	function modelo()
	{
		return guarani::orientacion();
	}
	
	function accion__index()
	{
		$this->add_var('mens_actualizacion', false);
		if (kernel::sesion()->esta_seteada('mens_actualizacion')){
			$this->add_var('mens_actualizacion', kernel::sesion()->get('mens_actualizacion'));
			kernel::sesion()->borrar('mens_actualizacion');
		}

        $pagelet_formulario = $this->vista()->pagelet('formulario');
        $pagelet_formulario->data['permite_baja_cambio_orientacion'] = $this->permite_baja_cambio_orientacion;
        $pagelet_formulario->data['realizo_materias_orientacion'] = $this->realizo_materias_orientacion;
	}
	
	function accion__seleccionar()
	{
        //Si no permite cambiar de orientación o realizo materias en la orientación...
        if((!$this->permite_baja_cambio_orientacion))// || $this->realizo_materias_orientacion) VER COMO HACER EL TEMA DE LAS MATERIAS 
		{
            return false;
        }

		if (kernel::request()->isPost()) {
            $orientacion = $this->validate_param('id_orientacion', 'post', validador::TIPO_ALPHANUM);
            $titulo = $this->validate_param('id_titulo', 'post', validador::TIPO_ALPHANUM);
		
			$this->modelo()->evt__solicitar($orientacion, $titulo);
			kernel::sesion()->set('mens_actualizacion', true);
			$this->nuevo_request('orientacion');
		}
	}
	
	function accion__eliminar_orientacion()
	{
        //Si no permite cambiar de orientación o realizo materias en la orientación...
        if((!$this->permite_baja_cambio_orientacion) || $this->realizo_materias_orientacion){
            return false;
        }

		if (kernel::request()->isPost()) {
			$motivo = $this->validate_param('motivo', 'post', validador::TIPO_TEXTO);
			$titulo = $this->validate_param('titulo', 'post', validador::TIPO_TEXTO);
			$this->modelo()->evt__eliminar($motivo, $titulo);
			$this->nuevo_request('orientacion');
		}
		}
	}
?>