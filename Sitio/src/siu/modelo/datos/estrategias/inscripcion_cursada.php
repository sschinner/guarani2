<?php
namespace siu\modelo\datos\estrategias;

use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\parametro;
use kernel\kernel;
use kernel\util\db\db;

/**
 * Integra el cache a archivo y sesion, el estado de inscripciones del alumno
 *	 y el display de cupos y arma las listas de la operacion
 * 
 * select comision, capacidad, cant_inscripciones, cast((cant_inscripciones * 100) / capacidad) as decimal(5,2)) as porc_ocupacion
 from sga_comisionescupo
 where comision in (xxxxx)
O trunc(cant_inscripcionese * 100 / capacidad, 0) as porc_ocupacion

 * 
 */
class inscripcion_cursada
{
	function info__lista_materias($carrera, $legajo, $nro_inscripcion, $plan, $version, $mis_inscripciones = false)
	{
		//-[1]- Elige entre el cache DURO y la base
		$recursar = parametro::recursar_regularizadas();
		$comisiones_actuales = parametro::filtro_materias_con_comision();
		//$recursar = 'S'; $comisiones_actuales = 'S';
                
                // si viene de mis incripciones
                if ($mis_inscripciones){
                        $lista_materias = catalogo::consultar('inscripcion_cursada', 'lista_materias_inscripcion_alumno',
                                                                    array(	'nro_inscripcion' => $nro_inscripcion));
                // si viene de inscripcion a materias        
                } else {
                        $lista_materias = catalogo::consultar('inscripcion_cursada', 
                                                              'lista_materias',
                                                               array('carrera' => $carrera,
                                                                      'legajo' => $legajo,
                                                                      'nro_inscripcion' => $nro_inscripcion,
                                                                      'plan' => $plan,
                                                                      'version' => $version,
                                                                      'recursar' => $recursar,
                                                                      'comisiones_actuales'=> $comisiones_actuales));
                }
		//-[2]- Suma informacion de estado: inscripcines realizadas
		$materias_inscripto = guarani::persona()->cursadas()->get_ids_materias_inscripto($carrera);
		foreach($lista_materias as $id_mat => $materia) {
			$lista_materias[$id_mat]['E_INSCRIPCION'] = 0;
			if(in_array($materia['MATERIA'], $materias_inscripto)){
				$lista_materias[$id_mat]['E_INSCRIPCION'] = 1;
			}
		}
		//kernel::log()->add_debug('LISTA MATERIAS',$lista_materias);
		return $lista_materias;
	}

	function info__lista_comisiones($carrera, $legajo, $materia)
	{
		// Busca info de comisiones (DB o sesion)
		// suma informacion de inscripciones
		// suma informacion de cupos
		$datos = catalogo::consultar('inscripcion_cursada', 'lista_comisiones',
									array('carrera' => $carrera,
										'legajo' => $legajo,
										'materia' => $materia));
		$mat = current(array_keys($datos));
		//kernel::log()->add_debug('MATERIAS LISTA', $mat);
		if (isset($datos[$mat]['COMISION'])) {
			$datos[$mat]['E_INSCRIPCION'] = 1;
			if (isset($datos[$mat]['SUBCOMISIONES'])) {
				foreach(array_keys($datos[$mat]['SUBCOMISIONES']) as $tipo_clase) {
					$datos[$mat]['SUBCOMISIONES'][$tipo_clase][0]['E_INSCRIPCION'] = 1;
				}
			}
		}
		
		return $datos;
	}
	
	function info__lista_comisiones_baja()
	{
		$parametros_cursada = array();
		$parametros_cursada['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		$parametros_cursada['estado'] = "T";
		$parametros_cursada['alcance'] = "A";

		return catalogo::consultar('alumno', 'inscripciones_cursadas', $parametros_cursada);
	}


	function info__comision($id, $carrera, $plan, $version)
	{
		
		//carrera plan version
		$datos = catalogo::consultar('inscripcion_cursada', 'info_comision', array(	'comision'=>$id, 
																					'carrera'=>$carrera						,
																					'plan' => $plan,
																					'version' => $version
																					));
		return $datos;
	}
}
?>