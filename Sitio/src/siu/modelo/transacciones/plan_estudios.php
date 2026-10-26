<?php

namespace siu\modelo\transacciones;

use kernel\error_kernel_db;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\datos\util;

class plan_estudios extends transaccion_alumno
{
	protected $operacion = 'mat000xxxx';
	protected $evento = '2';
	protected $detalle_plan;

	const TIPO_CORRELATIVA_APROBACION = 'A';
	const TIPO_CORRELATIVA_CURSADA = 'C';
    const TIPO_MATERIA_GENERICA = 'G';
	const TIPO_MATERIA_REGULARIZADA = 'R';

	/**
	 * Retorna la composición del plan de estudios 
	 *
	 * @return type 
	 */
	function get_detalle_plan_estudios()
	{
		if (!isset($this->detalle_plan)) {

		    $parametros_datos = array('carrera'=>kernel::persona()->get_id_carrera_activa(),
                                      'plan' => $this->plan,
                                      'version' => $this->version
                                     );

			$datos = catalogo::consultar('alumno','get_detalle_plan_estudios', $parametros_datos);
			$this->cargar_mat_genericas_y_puntajes($parametros_datos, $datos);

			$promedios = catalogo::consultar('alumno','get_promedios_por_titulo',
								array	(	'nro_inscripcion' => $this->nro_inscripcion,
											'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'legajo' => $this->legajo
										)
								);
			$creditos = catalogo::consultar('alumno','get_creditos_materias_aprobadas',
								array	(	'nro_inscripcion' => $this->nro_inscripcion,
											'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'legajo' => $this->legajo,
											'plan' => $this->plan,
											'version' => $this->version,
											'tipo'=> ""	
										)
								);
			$this->detalle_plan['detalle'] = $datos['detalle'];
			$this->detalle_plan['datos_carrera']['plan'] = $this->plan;
			$this->detalle_plan['promedios'] = $promedios;
			$this->detalle_plan['creditos'] = $creditos;
			return $this->detalle_plan;
	    }
    }

    /**
     * Agrega al detalle del palan de estudio las materias genericas y optativas.
     * Agrega tambienla suma de puntajes de optativas regulares y aprobadas.
     */
    function cargar_mat_genericas_y_puntajes ($parametros, &$datos)
    {
        $parametros['legajo'] = $this->legajo;
        $puntajes_optativas = catalogo::consultar('plan_estudios', 'get_resultado_puntaje_optativas', $parametros);
        $genericas = catalogo::consultar('plan_estudios', 'get_materias_genericas', $parametros);

        foreach ($datos['detalle'] as $key => $dato)
        {
            if ($dato['TIPO'] == static::TIPO_MATERIA_GENERICA)
            {
                $datos['detalle'][$key]['PUNTAJES']  = $puntajes_optativas[$dato['MATERIA']];
                $datos['detalle'][$key]['OPTATIVAS'] = $genericas[$dato['MATERIA']];
            }
        }
    }

	/**
	 * Retorna la composición del plan de estudios con información adicional de la historia academica de cada materia del plan
	 * en la columna 'INFO_ACT_ACAD_MATERIA'
	 * 
	 * @return type 
	 * 
	 */
	function get_plan_estudio_con_actividad_academica()
	{
		$historia_academica = guarani::historia_academica();
		$detalle_plan = $this->get_detalle_plan_estudios();
		foreach ($detalle_plan['detalle'] as $key => $dato) {
			if ($dato['TIPO'] == 'G') {
				foreach ($dato['OPTATIVAS'] as $key_optativa => $optativa) {
					$detalle_plan['detalle'][$key]['OPTATIVAS'][$key_optativa]['INFO_ACT_ACAD_MATERIA'] = $historia_academica->get_info_actividad_academica($optativa['MATERIA_OPTATIVA']);
				}
			} else {
				$detalle_plan['detalle'][$key]['INFO_ACT_ACAD_MATERIA'] = $historia_academica->get_info_actividad_academica($dato['MATERIA']);
			}
		}
		return $detalle_plan;
	}

	function get_correlativas($materia)
	{
		$datos = catalogo::consultar('alumno', 'get_correlativas',
								array	(	'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'plan' => $this->plan,
											'version' => $this->version,
											'materia' => $materia
										)
									);
		return $datos;
	}

	function get_optativas_generica($materia_generica)
	{
		$datos = catalogo::consultar('alumno', 'get_optativas_generica',
									array	(
											'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'plan' => $this->plan,
											'version' => $this->version,
											'materia' => $materia_generica
											)
									);
		return $datos;
	}

	function get_info_titulo()
	{
		$datos_titulo = catalogo::consultar('alumno', 'get_titulo_grado',
									array	(
											'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'plan'   => $this->plan
											)
									);
		return $datos_titulo;
    }

    function get_resultado_correlativa($materia, $tipo)
    {
        $parametros = array('carrera' => kernel::persona()->get_id_carrera_activa(),
                            'legajo' => kernel::persona()->get_id_legajo_activo(),
                            'materia' => $materia,
                            'tipo' => $tipo
                            );

        try
        {
            $datos = catalogo::consultar('alumno', 'get_resultado_correlativa', $parametros);
        }
        catch (error_kernel_db $e)
        {
            $resultado['mensaje_usuario'] = $e;
            $resultado['error_consulta'] = true;
        }

        // El procedure siempre devuelve al menos un resultado.
        // En este caso las materias correlativas estan aprobadas.
        if ($datos[0][0] == 1)
        {
            $resultado = array('resultado_consulta' => true, 'mensaje_usuario' => kernel::traductor()->trans('plan_de_estudio.mensaje_cumple_corr'));
        }
        else
        {
            //En caso de que no cumpla con la/s correlatividades puede tener mas de un mensaje.
            $mensaje_usuario = kernel::traductor()->trans('plan_de_estudio.mensaje_no_cumple_corr');
            foreach ($datos as $dato)
            {
                $mensaje_usuario .= util::mensaje($dato[1]).' ';
            }
            $resultado = array('resultado_consulta' => false, 'mensaje_usuario' => $mensaje_usuario);
        }

        return $resultado;

    }
}
?>