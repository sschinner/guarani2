<?php
namespace siu\modelo\datos\estrategias;

use siu\guarani;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use kernel\util\db\db;

/**
 * Integra el cache a archivo y sesion, el estado de inscripciones del alumno
 *	 y el display de cupos y arma las listas de la operacion
 */
class inscripcion_examen
{
	function info__lista_materias($carrera, $legajo, $nro_inscripcion, $plan, $version, $filtro_materias_con_mesa_exa, $filtro_rendir_regul_planes_anteriores)
	{
		//-[1]- Elige entre el cache DURO y la base
		$lista_materias = catalogo::consultar('inscripcion_examen', 'lista_materias',
									array(	'carrera' => $carrera,
											'legajo' => $legajo,
											'nro_inscripcion' => $nro_inscripcion,
											'plan' => $plan,
											'version' => $version,
											'filtro_materias_con_mesa_exa' => $filtro_materias_con_mesa_exa,
                                                                                                                                                                                                      'filtro_rendir_regul_planes_anteriores' => $filtro_rendir_regul_planes_anteriores
											));
		
		
		//-[2]- Suma informacion de estado: inscripcines realizadas
		$materias_inscripto = guarani::persona()->examenes()->get_ids_materias_inscripto();
		
		foreach($lista_materias as $id_mat => $materia) {
			$lista_materias[$id_mat]['E_INSCRIPCION'] = 0;
			if(in_array($materia['MATERIA'], $materias_inscripto)){
				$lista_materias[$id_mat]['E_INSCRIPCION'] = 1;
			}
		}
		return $lista_materias;
	}
	
	function info__lista_mesas($carrera, $legajo, $plan, $version, $es_plan_actual, $materia, $insc_examen_seleccion_auto_tipo_insc, $rinde_en_cualquier_sede, $modalidad_de_inscripciones_a_examenes)
	{
		///$es_regular_a_la_materia
		
		$datos = catalogo::consultar('inscripcion_examen', 'lista_mesas',
									array(	'carrera'	=> $carrera,
											'legajo'	=> $legajo,
											'plan'		=> $plan,
											'version'	=> $version,
                                                                                                                                                                                                      'es_plan_actual' => $es_plan_actual,
											'materia'	=> $materia,
											'param_exa_tipo_insc'	=> $insc_examen_seleccion_auto_tipo_insc,	
											'param_exa_sede'	=> $rinde_en_cualquier_sede, 
											'param_exa_modalidad'	=> $modalidad_de_inscripciones_a_examenes
										 )
									);
		
		$mesas_inscripto =	guarani::persona()->examenes()->info__inscripciones();

		foreach ($datos as $key => $dato) {
			foreach ($mesas_inscripto as $mesa_inscripto) {
				if ($dato['UNIDAD_ACADEMICA']	== $mesa_inscripto['UNIDAD_ACADEMICA']
						&& $dato['MATERIA']			== $mesa_inscripto['MATERIA']
						&& $dato['ANIO_ACADEMICO']	== $mesa_inscripto['ANIO_ACADEMICO']
						&& $dato['TURNO_EXAMEN']	== $mesa_inscripto['TURNO_EXAMEN']
						&& $dato['LLAMADO']			== $mesa_inscripto['LLAMADO']
						&& $dato['MESA_EXAMEN']		== $mesa_inscripto['MESA_EXAMEN']
					) {
					$datos[$key]['ESTADO_INSCRIPCION']	= 'I';
					$datos[$key]['TIPO_INSCRIPCION']	= $mesa_inscripto['TIPO_INSCRIPCION'];
					$datos[$key]['CARRERA_INSCRIPTO']	= $mesa_inscripto['CARRERA'];
					$datos[$key]['LEGAJO_INSCRIPTO']	= $mesa_inscripto['LEGAJO'];
				}
			}
		}
		
//		kernel::log()->add_debug('mesas_inscripto' . __FILE__ . ' - ' . __LINE__, $datos);
//		kernel::log()->add_debug('mesas_inscripto' . __FILE__ . ' - ' . __LINE__, $mesas_inscripto);
		
		return $datos;
	}
	
	function info__lista_mesas_baja_inicial()
	{
		$parametros_insc_examen = array();
		$parametros_insc_examen['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		$parametros_insc_examen['estado'] = "T";
		$parametros_insc_examen['alcance'] = "A";

		return catalogo::consultar('alumno', 'inscripciones_examenes', $parametros_insc_examen);
	}
	
	function info__mesa($id)
	{
		$datos = catalogo::consultar('inscripcion_examen', 'info_mesa', array('mesa'=>$id));
		return $datos;
	}
}
?>