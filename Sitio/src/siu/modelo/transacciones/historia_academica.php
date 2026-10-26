<?php

namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\modelo\datos\catalogo;

class historia_academica extends transaccion_alumno
{
	
	protected $operacion = 'mat000xxxx';
	protected $evento = '2';
	protected $actividad_academica;

	function ordenar_materia($datos)
	{
		$materia_nombre = array();
		foreach ($datos as $key => $fila) {
			$materia_nombre[$key]  = $fila['MATERIA_NOMBRE'];
		}
		array_multisort($materia_nombre, SORT_DESC, $datos);
		return $datos;  
	}
	
	/**
	 * Retorna la historia acad?mica del alumno (aprobaciones, regularidades y en curso) 
	 *
	 * @param type $orden por defecto '' ordena por anio del resultado, pasando como parametro el string 
	 *					  'materia' ordena por nombre de materia
	 * @return type 
	 */
	function get_actividad_academica($orden = '')
	{        
		if (!isset($this->actividad_academica)) {
			$this->actividad_academica = catalogo::consultar('alumno',
															'get_actividad_academica',
															array('carrera'=>kernel::persona()->get_id_carrera_activa(),
																  'legajo' => $this->legajo	)
															);
		}
		
		$datos = $this->actividad_academica;
		
		switch ($orden) {
			case 'materia':
			   $datos = $this->ordenar_materia($datos);
			   break;
	    }
		return $datos;
	}
		
	
	/**
	 *  Dada una materia retrona el resultado aprobado más reciente de esa materia en la historia acad?mica del alumno, ya sean cursadas o exámenes
	 *  
	 * @param type $materia
	 * @return type 
	 * 
	 */
	function get_info_actividad_academica($materia)
	{
		
		$actividad_academica = $this->get_actividad_academica();
		$datos_materia = array();
		
		//los datos vienen ordenados por fecha en forma descendente, cuando encuentra la materia sale.
		foreach ($actividad_academica as $actividad) {

				
				if ($materia == $actividad['MATERIA']) {
					
					// Datos que van para cualquier tipo
					
					$datos_comunes= array();
					$datos_comunes['TIPO']					= $actividad['TIPO'];
					$datos_comunes['ANIO']					= $actividad['ANIO'];
					$datos_comunes['MATERIA_NOMBRE_RED']	= $actividad['MATERIA_NOMBRE_RED'];
					$datos_comunes['ORIGEN']				= $actividad['ORIGEN'];
					$datos_comunes['PLAN']					= $actividad['PLAN'];
					$datos_comunes['VERSION']				= $actividad['VERSION'];
					$datos_comunes['ANIO_ACADEMICO']		= $actividad['ANIO_ACADEMICO'];
					$datos_comunes['CATEDRA']				= $actividad['CATEDRA'];
					
					if ($actividad['TIPO'] == 'Aprobacion')  { 
						if ($actividad['RESULTADO'] == 'A') {
							$datos_materia = $datos_comunes;
							$datos_materia['FECHA_DISPLAY']			= $actividad['FECHA_DISPLAY'];
							$datos_materia['FECHA_ORDEN']			= $actividad['FECHA_ORDEN'];
							$datos_materia['NOTA']					= $actividad['NOTA'];
							$datos_materia['NOTA_DESCRIPCION']		= $actividad['NOTA_DESCRIPCION'];
							$datos_materia['NOTA_CONCEPTO']			= $actividad['NOTA_CONCEPTO'];
							$datos_materia['RESULTADO']				= $actividad['RESULTADO'];
							$datos_materia['RESULTADO_DESCRIPCION']	= $actividad['RESULTADO_DESCRIPCION'];
							$datos_materia['ACTA_RESOLUCION']		= $actividad['ACTA_RESOLUCION'];
							$datos_materia['EQUIVALENCIA']			= $actividad['EQUIVALENCIA'];
							
							if ($datos_materia['ORIGEN'] == 'Promoci?n') {
								$datos_materia['COMISION']				= $actividad['COMISION']; 
								$datos_materia['COMISION_NOMBRE']		= $actividad['COMISION_NOMBRE']; 
								$datos_materia['PERIODO_LECTIVO']		= $actividad['PERIODO_LECTIVO'];
							}
							
							break; //encontre aprobacion, salgo
						} else {
							continue; // no aprobado
						}
						
					}
		
					if ($actividad['TIPO'] == 'Regularidad'){ 
						if ($actividad['RESULTADO'] == 'A') {
							
							$datos_a_setear = $datos_comunes;
							$datos_a_setear['FECHA_DISPLAY']		= $actividad['FECHA_DISPLAY'];
							$datos_a_setear['FECHA_ORDEN']			= $actividad['FECHA_ORDEN'];
							$datos_a_setear['NOTA']					= $actividad['NOTA'];
							$datos_a_setear['NOTA_DESCRIPCION']		= $actividad['NOTA_DESCRIPCION'];
							$datos_a_setear['NOTA_CONCEPTO']		= $actividad['NOTA_CONCEPTO'];
							$datos_a_setear['RESULTADO']			= $actividad['RESULTADO'];
							$datos_a_setear['RESULTADO_DESCRIPCION']= $actividad['RESULTADO_DESCRIPCION'];
							$datos_a_setear['ACTA_RESOLUCION']		= $actividad['ACTA_RESOLUCION'];
							$datos_a_setear['EQUIVALENCIA']			= $actividad['EQUIVALENCIA'];
							$datos_a_setear['COMISION']				= $actividad['COMISION']; 
							$datos_a_setear['COMISION_NOMBRE']		= $actividad['COMISION_NOMBRE']; 
							$datos_a_setear['PERIODO_LECTIVO']		= $actividad['PERIODO_LECTIVO']; 
							$datos_a_setear['VIGENTE']				= $actividad['VIGENTE']; 
							$datos_a_setear['COND_REGULARIDAD']		= $actividad['COND_REGULARIDAD'];
                            $datos_a_setear['FECHA_FIN_VIGENCIA']	= $actividad['FECHA_FIN_VIGENCIA'];
							$datos_a_setear['TURNO_CURSADA']		= $actividad['TURNO_CURSADA'];

							if (! isset($datos_materia['MATERIA'])) { //si pasa por primera vez, setea
								$datos_materia = $datos_a_setear;
							} else {
								if ($datos_materia['TIPO'] != 'En Curso') { //viene de una cursada anterior finalizada
									if ($datos_materia['FECHA_ORDEN'] < $actividad['FECHA_ORDEN'] ) {
										$datos_materia = $datos_a_setear;
									}	
								} 
							}
							continue; //sigo buscando aprobación					
						}
							
						}
					// si esta en curso piso la cursada
					if ($actividad['TIPO'] == 'En Curso') {
						$datos_materia = $datos_comunes;
						$datos_materia['CALIDAD_INSC']		= $actividad['CALIDAD_INSC']; 
						$datos_materia['ESTADO_INSC']		= $actividad['ESTADO_INSC']; 
					}
				
			} //fin materia
		} //fin foreach 
		
		return $datos_materia;
		
	}
	
	
	
	function get_detalle_materia_aprobada($acta)
	{
		$datos = catalogo::consultar('alumno','get_detalle_aprobada',
									array('carrera'=>kernel::persona()->get_id_carrera_activa(),
								          'legajo' => $this->legajo,
										  'acta' => $acta)
				                   );
		return $datos;
		
	}
	
	function get_detalle_materia_en_curso($comision)
	{
		$datos = catalogo::consultar('alumno','get_detalle_en_curso',
									array('carrera'=>kernel::persona()->get_id_carrera_activa(),
								          'legajo' => $this->legajo,
										  'comision' => $comision)
				                   );
		return $datos;
		
	}
	
	
	function get_detalle_materia_cursada($acta)
	{
		
		$datos = catalogo::consultar('alumno','get_detalle_cursada',
									array('carrera'=>kernel::persona()->get_id_carrera_activa(),
								          'legajo' => $this->legajo,
										  'acta' => $acta)
				                   );
				
		return $datos;
	}
	
	
	function get_detalle_materia_promocionada($acta)
	{
		$datos = catalogo::consultar('alumno','get_detalle_promo',
									array('carrera'	=> kernel::persona()->get_id_carrera_activa(),
								          'legajo'	=> $this->legajo,
										  'acta'	=> $acta)
				                   );
		return $datos;
	}
	
	
	function get_detalle_equivalencia($equivalencia)
	{	
		$datos = catalogo::consultar('alumno','get_detalle_equiv',
									array('carrera'=>kernel::persona()->get_id_carrera_activa(),
								          'legajo' => $this->legajo,
										  'equivalencia' => $equivalencia)
				                   );
		return $datos;
	}
	
	
	
	function get_resultado_generica($materia_generica, $titulo)
	{
		$datos = catalogo::consultar('alumno', 'get_resultado_generica',
									array('carrera'=>kernel::persona()->get_id_carrera_activa(),
								          'legajo' => $this->legajo,
										  'plan'   => $this->plan,
										  'titulo' => $titulo,
										  'materia' => $materia_generica)
				                   );
		return $datos;
	}
	
		
	function get_detalles_generica($materia_generica)
	{
		$ret = array();
		$ret['titulo'] = $this->get_info_titulo();
		$ret['resultado'] = $this->get_resultado_generica($materia_generica, $ret['titulo']['TITULO']);
		$ret['optativas'] = $this->get_optativas_generica($materia_generica);
		
		return $ret;
	}
	
	function get_promedios_por_titulo($nro_inscripcion, $carrera, $legajo){
		$promedios = catalogo::consultar('alumno','get_promedios_por_titulo',
					array	(	'nro_inscripcion' => $nro_inscripcion,
								'carrera'=>$carrera,
								'legajo' => $legajo
							)
					);
		return $promedios;
	}
	
	function get_porcentaje_aprobacion($nro_inscripcion, $carrera){
		$porcentaje = catalogo::consultar('alumno','porcentaje_aprobacion',
					array	(	'nro_inscripcion' => $nro_inscripcion
							)
					);
		$datos = array();
		for($i = 0; $i < sizeof($porcentaje); $i++){
			if ($porcentaje[$i]['carrera'] == $carrera){
				$datos[$i] = $porcentaje[$i];
			}
		}
		$corte = array();
		foreach ($datos as $dato){
				$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
				$corte[$dato['carrera']]['titulo_nombre'] = $dato['titulo_nombre'];

				$orientacion['orientacion'] = $dato['orientacion'];
				$orientacion['orientacion_nombre'] = $dato['orientacion_nombre'];
				$orientacion['porcentaje_aprobacion_orientacion'] = $dato['porcentaje_aprobacion_orientacion'];
				$orientacion['porcentaje_aprobacion_titulo'] = $dato['porcentaje_aprobacion_titulo'];

				$corte[$dato['carrera']]['orientaciones'][] = $orientacion;
			unset($orientacion);
			}
		
		return $corte;
	}
}
?>
