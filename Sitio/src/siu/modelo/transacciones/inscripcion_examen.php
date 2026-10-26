<?php
namespace siu\modelo\transacciones;

use kernel\kernel;

use siu\guarani;
use siu\errores\error_guarani;
use siu\errores\error_guarani_seguridad;
use siu\errores\error_guarani_usuario;
use \siu\modelo\datos\util;
use siu\modelo\datos\estrategias;
use siu\modelo\datos\catalogo;
use siu\modelo\interfaces\lista_materias;
use siu\modelo\entidades\parametro;
use siu\modelo\controles\proceso_control;

class inscripcion_examen extends transaccion_alumno implements lista_materias 
{
	protected $operacion		= 'exa00006';
	protected $operacion_baja	= 'exa00030';
	protected $evento			= '4';
	protected $evento_baja		= '5';
	protected $estrategia_acceso_datos;
	protected $opcion_materia = array();
	protected $opcion_datos_materia = array();
	protected $opcion_mesa = array();
	protected $opcion_mesa_baja_inicial = array();
	protected $opcion_nro_transaccion = array();
	
	function datos()
	{
		if(!isset($this->estrategia_acceso_datos)){
			$this->estrategia_acceso_datos = new estrategias\inscripcion_examen();
		}
		return $this->estrategia_acceso_datos;
	}
	
	//---------------------------------------------
	//	INFO
	//---------------------------------------------

	function info__lista_materias()
	{
		$filtro_materias_con_mesa_exa = parametro::filtro_materias_con_mesa_exa();
                                    $filtro_rendir_regul_planes_anteriores = parametro::rendir_regul_planes_anteriores();
		return $this->datos()->info__lista_materias(	$this->carrera, 
														$this->legajo,
														$this->nro_inscripcion,
														$this->plan,
														$this->version,
														$filtro_materias_con_mesa_exa,
                                                                                                                                                                                                                                                            $filtro_rendir_regul_planes_anteriores
													 );
	}
	
	function info__lista_mesas($url_materia)
	{
		$materia = $this->get_opcion_enviada_datos_materia($url_materia);
		// Parámetros del sistema que recibe el proceso que recupera las mesas de examen para la inscripción.
		$insc_examen_seleccion_auto_tipo_insc  = parametro::insc_examen_seleccion_auto_tipo_insc();
		$rinde_en_cualquier_sede = parametro::rinde_en_cualquier_sede();
		$modalidad_de_inscripciones_a_examenes = parametro::modalidad_de_inscripciones_a_examenes();
		return $this->datos()->info__lista_mesas(	$materia['CARRERA'],
                                                            $this->legajo,
                                                            $materia['PLAN'],
                                                            $materia['VERSION'],
                                                            $materia['PLAN_ACTUAL'],
                                                            $materia['MATERIA'],
                                                            $insc_examen_seleccion_auto_tipo_insc,
                                                            $rinde_en_cualquier_sede,
                                                            $modalidad_de_inscripciones_a_examenes
							);
	}
	
	function info__lista_mesas_baja_inicial()
	{
		return $this->datos()->info__lista_mesas_baja_inicial();
	}
	
	function info__materia($url_materia)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia);		
		$materias = $this->info__lista_materias();
		foreach($materias as $m) {
			if ($m['MATERIA'] == $materia) return $m;
		}
		throw new error_guarani('Materia inexistente');
	}
	
	function existe_inscripcion_a_examen($url_materia)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia);
		return guarani::persona()->examenes()->existe_inscripcion_a_examen(	$materia, $this->legajo);
	}
	
	function info__inscripcion($mesa)
	{
		return guarani::persona()->examenes()->info__inscripcion($mesa);
	}

	function info__comprobante($url_materia, $url_transaccion)
	{
		$transaccion = $this->get_opcion_enviada_nro_transaccion($url_materia, $url_transaccion);
		return catalogo::consultar('inscripcion_examen', 'info_comprobante_inscripcion',
							array('transaccion'=>$transaccion));
	}
    
	function info__comprobante_baja($url_transaccion)
	{
		$transaccion = $this->get_nro_transaccion_baja($url_transaccion);
		return catalogo::consultar('inscripcion_examen', 'info_comprobante_baja', array(
			'transaccion' => $transaccion
		));
	}
	
    function info__comprobante_historico($url_transaccion)
	{
		$transaccion = $this->get_nro_transaccion($url_transaccion);
		return catalogo::consultar('inscripcion_examen', 'info_comprobante_inscripcion',
							array('transaccion'=>$transaccion));
	}
	
	//---------------------------------------------
	//	CONTROL ENVIO PARAMETROS
	//---------------------------------------------
	
	function get_opcion_enviada_nro_transaccion($url_materia, $url_transaccion)
	{
		if (!isset($this->opcion_nro_transaccion[$url_transaccion])) {
			$lista_mesas = $this->info__lista_mesas($url_materia);
			foreach ($lista_mesas as $mesa) {
				$info_mesa = $this->info__inscripcion($mesa[catalogo::id]);
				if ($info_mesa !== false) {
					if ($info_mesa['URL_NRO_TRANSACCION'] == $url_transaccion) {
						$transaccion = $info_mesa['NRO_TRANSACCION'];	
					}
				}
			}
			
			if(!isset($transaccion)) {
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe el nro de transacción');
			}
			
			$this->opcion_nro_transaccion[$url_transaccion] = $transaccion;
		}
		
		return $this->opcion_nro_transaccion[$url_transaccion];
	}
        
	function get_nro_transaccion($url_transaccion) {
		$nro_transacciones_inscripciones_historicas = catalogo::consultar('inscripcion_examen', 'info_nro_transacciones_inscripciones_historicas', array('nro_inscripcion' => $this->nro_inscripcion));

		foreach ($nro_transacciones_inscripciones_historicas as $nro_transaccion_inscripciones_historicas) {

			if ($nro_transaccion_inscripciones_historicas['URL_NRO_TRANSACCION'] == $url_transaccion) {
				return $nro_transaccion_inscripciones_historicas['NRO_TRANSACCION'];
			}
		}
		throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe el nro de transacción');
	}

	function get_nro_transaccion_baja($url_transaccion) {
		
		$nro_transacciones_bajas = catalogo::consultar('inscripcion_examen', 'info_nro_transacciones_bajas', array('nro_inscripcion' => $this->nro_inscripcion));

		foreach ($nro_transacciones_bajas as $nro_transaccion_baja) {

			if ($nro_transaccion_baja['URL_NRO_TRANSACCION_BAJA'] == $url_transaccion) {
				return $nro_transaccion_baja['NRO_TRANSACCION_BAJA'];
			}
		}
		throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe el nro de transacción de la baja');
	}

	function get_opcion_enviada_datos_materia($url_materia)
	{
		if (!isset($this->opcion_materia[$url_materia])){
			$materia = null;
			$materias = $this->info__lista_materias();
			foreach($materias as $mat) {
				if($mat[catalogo::id] == $url_materia){
					$materia = $mat;
				}
			}
			if(!isset($materia)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la materia');
			}
			$this->opcion_datos_materia[$url_materia] = $materia;
		}
		return $this->opcion_datos_materia[$url_materia];
	}
        
	function get_opcion_enviada_materia($url_materia)
	{
		if (!isset($this->opcion_materia[$url_materia])){
			$datos_materia = $this->get_opcion_enviada_datos_materia($url_materia);                                                      
			$this->opcion_materia[$url_materia] = $datos_materia['MATERIA'];
		}
		return $this->opcion_materia[$url_materia];
	}
	
	function get_opcion_enviada_mesa($url_materia, $url_mesa)
	{
		if (!isset($this->opcion_mesa[$url_mesa])) {
			$mesas = $this->info__lista_mesas($url_materia);
			if(isset($mesas[$url_mesa])) {
				$mesa = $mesas[$url_mesa];
			} else {
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la mesa');
			}
			$this->opcion_mesa[$url_mesa] = $mesa;
		}
		return $this->opcion_mesa[$url_mesa];
	}	
	
	function get_opcion_enviada_mesa_baja_inicial($url_materia, $url_mesa)
	{
		if (!isset($this->opcion_mesa_baja_inicial[$url_mesa])) {
			$mesa = null;
			$mesas = $this->info__lista_mesas_baja_inicial();
			
			foreach($mesas as $m) {
				if($m['url_mesa'] == $url_mesa && $m['url_materia'] == $url_materia) {
					$mesa = $m;
				}
			}
			if(!isset($mesa)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la mesa para dar de baja');
			}
			$this->opcion_mesa_baja_inicial[$url_mesa] = $mesa;
		}
		return $this->opcion_mesa_baja_inicial[$url_mesa];
	}
	
	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------
	
	function evt__inscripcion($url_materia, $url_mesa, $tipo_inscripcion_usuario)
	{
		//throw new error_guarani('Error en la inscripcion');
		$mesa = $this->get_opcion_enviada_mesa($url_materia, $url_mesa);
                                    
		//if (parametro::insc_examen_seleccion_auto_tipo_insc() == 'N' && $mesa['INSCRIBIR_COMO'] == 'A') {
		if (parametro::insc_examen_seleccion_auto_tipo_insc() == 'N') {
			$tipo_inscripcion = $tipo_inscripcion_usuario;
		} else {
			$tipo_inscripcion = $mesa['INSCRIBIR_COMO'];
		}

		// se pisa para que se pase el valor correcto a los controles
		$mesa['INSCRIBIR_COMO'] = $tipo_inscripcion;
	
		list($msg, $hubo_advertencias) = $this->control__inscripcion($mesa);
		// Estado de la inscripcion
		$estado = $hubo_advertencias ? 'P' : 'A';
		
                                    // usa el plan y versión de la materia y no de transaccion_alumno 
                                    // para poder inscribir a materias de otro plan
                                    $materia = $this->get_opcion_enviada_datos_materia($url_materia);

  		$ok = catalogo::consultar('inscripcion_examen', 'inscripcion_mesa_examen',
							array(		'carrera'			=> $materia['CARRERA'],
										'plan'				=> $materia['PLAN'],
										'version'			=> $materia['VERSION'],
										'legajo'			=> $this->legajo,
										'nro_inscripcion'	=> $this->nro_inscripcion,
										'mesa_examen'		=> $mesa['MESA_EXAMEN'],
										'materia'			=> $mesa['MATERIA'],
										'anio_academico'	=> $mesa['ANIO_ACADEMICO'],
										'turno_examen'		=> $mesa['TURNO_EXAMEN'],
										'llamado'			=> $mesa['LLAMADO'],
										'tipo_inscripcion'	=> $tipo_inscripcion,
										'estado_controles'  => $estado,
								 )	
							);
                                    
		guarani::persona()->examenes()->reset();
		if(($ok[0]>0)) {
			$temp = explode(',',$ok[1]);
			$transaccion = $temp[1];
			return array($msg, $transaccion);
		} else {
			$mensaje = util::mensaje($ok[1]);
			throw new error_guarani_usuario($mensaje);
		}
	}
	
	function evt__eliminar_inscripcion($url_materia, $url_mesa)
	{
		$mesa = $this->get_opcion_enviada_mesa($url_materia, $url_mesa);
		return $this->eliminar_inscripcion($mesa);
	}
	
	function evt__eliminar_inscripcion_por_mesa($url_materia, $url_mesa)
	{
		$mesa = $this->get_opcion_enviada_mesa_baja_inicial($url_materia, $url_mesa);
		return $this->eliminar_inscripcion($mesa);
	}
	
	protected function eliminar_inscripcion($mesa)
	{
		kernel::log()->add_debug('ELIMINAR INSCRIPCION - MESA: ', $mesa);
		
		list($msg, $hubo_advertencias) = $this->control__eliminar_inscripcion($mesa);
		
		$ok = catalogo::consultar('inscripcion_examen', 'eliminar_inscripcion_mesa',
							array(		'carrera'			=> $this->carrera,
										'legajo'			=> $this->legajo,
										'materia'			=> $mesa['MATERIA'],
										'anio_academico'	=> $mesa['ANIO_ACADEMICO'],
										'turno_examen'		=> $mesa['TURNO_EXAMEN'],
										'mesa_examen'		=> $mesa['MESA_EXAMEN'],
										'llamado'			=> $mesa['LLAMADO'],
								));
		guarani::persona()->examenes()->reset();
		if(($ok[0]>0)) {
			$temp = explode(',',$ok[1]);
			$transaccion = $temp[1];
			kernel::log()->add_debug('TRANSACCION', $transaccion);
			return array($msg, $transaccion);
		} else {
			$mensaje = util::mensaje($ok[1]);
			throw new error_guarani_usuario($mensaje);
		}
	}
	
	//---------------------------------------------
	//	CONTROLES
	//---------------------------------------------

	function control__inicial()
	{
		$proceso = $this->nuevo_proceso_control();		
		$this->agregar_puntos_iniciales($proceso);
		return $proceso->ejecutar();		
	}

	function control__seleccion_materia($url_materia)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia);
		$proceso = $this->nuevo_proceso_control();
		$this->agregar_puntos_materia($proceso, $materia);
		return $proceso->ejecutar();
	}

	protected function control__inscripcion($info_mesa)
	{
		// 1) Se repiten controles anteriores por seguridad y para conocer las advertencias
		// (No hay ninguna primitiva del kernel que garantice la secuencia de requests para
		// permitir multiples hilos paralelos), por eso esto es necesario.
		// el costo es minimo porque esta todo en el cache

		$proceso = $this->nuevo_proceso_control();
		$this->agregar_puntos_iniciales($proceso);
		$this->agregar_puntos_materia($proceso, $info_mesa['MATERIA']);
		$proceso->ejecutar(); //Los mensajes estos no importan, ya se mostraron antes
		$advertencias = $proceso->hay_advertencias();
		// 2) Control mesa
		$proceso2 = $this->nuevo_proceso_control();		
		$this->agregar_puntos_mesa($proceso2, $info_mesa);
		$msg = $proceso2->ejecutar();
		$advertencias = $advertencias || $proceso2->hay_advertencias();
		return array($msg, $advertencias);
	}
	
	protected function control__eliminar_inscripcion($info_mesa)
	{
		// 1) Se repiten controles anteriores por seguridad y para conocer las advertencias
		// (No hay ninguna primitiva del kernel que garantice la secuencia de requests para
		// permitir multiples hilos paralelos), por eso esto es necesario.
		// el costo es minimo porque esta todo en el cache
		$proceso = $this->nuevo_proceso_control();		
		$this->agregar_puntos_iniciales($proceso);
		$this->agregar_puntos_materia($proceso, $info_mesa['MATERIA']);
		$proceso->ejecutar(); //Los mensajes estos no importan, ya se mostraron antes
		$advertencias = $proceso->hay_advertencias();

		// 2) Control baja mesa
		$proceso2 = new proceso_control($this->operacion_baja, $this->evento_baja);
		$this->agregar_puntos_mesa_baja($proceso2, $info_mesa);
		$msg = $proceso2->ejecutar();
		$advertencias = $advertencias || $proceso2->hay_advertencias();

		return array($msg, $advertencias);
	}
	
	protected function agregar_puntos_iniciales($proceso)
	{
		//(Persona - Operación) - Una Persona elige una operación
		$proceso->agregar_punto(2, array('nro_inscripcion' => $this->nro_inscripcion,
											'operacion' => $this->operacion));
		//(Alumno - Operación) - Un Alumno elige una operación
		$proceso->agregar_punto(3, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'operacion' => $this->operacion));
		//(Requisitos) - Requisitos Obligatorios y No Obligatorios de la UA y la Carrera
		$proceso->agregar_punto(24, array(	'nro_inscripcion' => $this->nro_inscripcion,
											'carrera' => $this->carrera));
	}
	
	protected function agregar_puntos_materia($proceso, $materia)
	{
		$proceso->agregar_punto(8, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'materia' => $materia));
		$proceso->agregar_punto(36, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'materia' => $materia,
											'fecha' => catalogo::fecha_actual()));
	}
	
	protected function agregar_puntos_mesa($proceso, $info_mesa)
	{
		//(Alumno - Llamado Mesa de Examen) Un Alumno elige un llamado de una mesa de examen de una materia para rendir
		$proceso->agregar_punto(10, array(	'carrera'		=> $this->carrera,
										'legajo'			=> $this->legajo,
										'materia'			=> $info_mesa['MATERIA'],
										'anio_academico'	=> $info_mesa['ANIO_ACADEMICO'],
										'turno_examen'		=> $info_mesa['TURNO_EXAMEN'],
										'mesa_examen'		=> $info_mesa['MESA_EXAMEN'],
										'llamado'			=> $info_mesa['LLAMADO'],
										'tipo_inscripcion'  => $info_mesa['INSCRIBIR_COMO']
										)
				);
		//(Grabación de una inscripción a examen) Grabación de una inscripción a examen								
		$proceso->agregar_punto(11, array(	'carrera'		=> $this->carrera,
										'legajo'			=> $this->legajo,
										'materia'			=> $info_mesa['MATERIA'],
										'anio_academico'	=> $info_mesa['ANIO_ACADEMICO'],
										'turno_examen'		=> $info_mesa['TURNO_EXAMEN'],
										'mesa_examen'		=> $info_mesa['MESA_EXAMEN'],
										'llamado'			=> $info_mesa['LLAMADO'],
										'tipo_inscripcion'  => $info_mesa['INSCRIBIR_COMO'],
										'materia_generica'  => ''
										));	
		
		//(Reinscripcion) Control de resinscripcion
		$proceso->agregar_punto(33, array(	'nro_inscripcion' => $this->nro_inscripcion,
										'anio_academico' => $info_mesa['ANIO_ACADEMICO']));	
	}
	
	protected function agregar_puntos_mesa_baja($proceso, $info_mesa)
	{
		$proceso->agregar_punto(2, array(
			'nro_inscripcion'=> $this->nro_inscripcion,
			'operacion' => $this->operacion_baja
		));
		
		$proceso->agregar_punto(3, array(
			'carrera' => $this->carrera,
			'legajo' => $this->legajo,
			'operacion' => $this->operacion_baja
		));
		
		$proceso->agregar_punto(12, array(
			'carrera'			=> $this->carrera,
			'legajo'			=> $this->legajo,
			'materia'			=> $info_mesa['MATERIA'],
			'anio_academico'	=> $info_mesa['ANIO_ACADEMICO'],
			'turno_examen'		=> $info_mesa['TURNO_EXAMEN'],
			'mesa_examen'		=> $info_mesa['MESA_EXAMEN'],
			'llamado'			=> $info_mesa['LLAMADO']
		));
	}
}

?>