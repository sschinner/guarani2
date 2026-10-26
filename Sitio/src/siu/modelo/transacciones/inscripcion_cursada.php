<?php
namespace siu\modelo\transacciones;

use kernel\kernel;

use siu\guarani;
use siu\errores\error_guarani;
use siu\errores\error_guarani_usuario;
use siu\errores\error_guarani_seguridad;
use \siu\modelo\datos\util;
use siu\modelo\datos\estrategias;
use siu\modelo\datos\catalogo;
use siu\modelo\interfaces\lista_materias;
use siu\modelo\entidades\parametro;
use siu\modelo\controles\proceso_control;

class inscripcion_cursada extends transaccion_alumno implements lista_materias
{
	protected $operacion = 'cur00003';
	protected $operacion_baja = 'cur00015';
	protected $evento = '2';
	protected $evento_baja = '3';
	protected $estrategia_acceso_datos;
	// Cache request
	protected $lista_materias;			// Evaluar si tiene sentido
	protected $opcion_materia = array();
	protected $opcion_comision = array();
	protected $opcion_comision_baja = array();
	protected $opcion_subcomision = array();
	protected $opcion_nro_transaccion = array();

	function datos()
	{
		if(!isset($this->estrategia_acceso_datos)){
			$this->estrategia_acceso_datos = new estrategias\inscripcion_cursada();
		}
		return $this->estrategia_acceso_datos;
	}

	//---------------------------------------------
	//	INFO
	//---------------------------------------------

	function info__hay_periodo_inscripcion_vigente()
	{
		$cant = catalogo::consultar('inscripcion_cursada', 'cantidad_periodos_inscripcion_vigentes',
							array('carrera' => $this->carrera));
		
		return $cant > 0;
	}
	
	function info__lista_materias($mis_inscripciones = false)
	{
		if(!isset($this->lista_materias)) {
			$this->lista_materias = $this->datos()->info__lista_materias($this->carrera, 
                                                                                     $this->legajo,
                                                                                     $this->nro_inscripcion,
                                                                                     $this->plan,
                                                                                     $this->version,
                                                                                     $mis_inscripciones);
//			$this->registrar_opcion_enviada(array(
//				'id_col' => array(
//					
//				), 
//				'metodo',
//				'id_hash' => __ID__,
//				'paso_anterior'
//			));
		}
		return $this->lista_materias;
	}
	
	function info__lista_comisiones_baja()
	{
		return $this->datos()->info__lista_comisiones_baja();
	}

	function info__lista_comisiones($url_materia)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia);		
		return $this->datos()->info__lista_comisiones(	$this->carrera,
														$this->legajo,
														$materia);
	}

	function existe_inscripcion_materia($url_materia)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia);
		return guarani::persona()->cursadas()->existe_inscripcion_materia($materia);
	}
	
	function info__inscripciones_materia($url_materia, $mis_inscripciones = false)
	{
		$materia = $this->get_opcion_enviada_materia($url_materia, $mis_inscripciones);
		return guarani::persona()->cursadas()->get_inscripciones_materia($materia);		
	}

	function info__inscripcion($url_materia, $url_comision)
	{
		$comision = $this->get_opcion_enviada_comision($url_materia, $url_comision);
		return guarani::persona()->cursadas()->info__inscripcion($comision);
	}

	function info__comprobante($url_materia, $url_transaccion, $mis_inscripciones = false)
	{
		$transaccion = $this->get_opcion_enviada_nro_transaccion($url_materia, $url_transaccion, $mis_inscripciones);
		return catalogo::consultar('inscripcion_cursada', 'info_comprobante_inscripcion',
							array('transaccion'=>$transaccion));		
	}
        function info__comprobante_historico($url_transaccion)
	{
		$transaccion = $this->get_nro_transaccion($url_transaccion);
		return catalogo::consultar('inscripcion_cursada', 'info_comprobante_inscripcion',
							array('transaccion'=>$transaccion));
	}
	
	function info__comprobante_baja($url_comision)
	{
		$transaccion = $this->get_opcion_enviada_cert_baja($url_comision);
		return catalogo::consultar('inscripcion_cursada', 'info_comprobante_baja',
							array('transaccion'=>$transaccion));
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
	
    function info__horarios($url_materia, $url_comision, $url_subcomision){
        if (!empty($url_subcomision)){
            $comision = $this->get_opcion_enviada_comision($url_materia, $url_comision);
            $subcomision = $this->get_opcion_enviada_subcomision($url_materia, $comision, $url_subcomision);
            
            return catalogo::consultar('inscripcion_cursada', 'asignacion_horaria_subcomision', array('comision'=>$comision, 'subcomision'=> $subcomision));
        } else {
            $comision = $this->get_opcion_enviada_comision($url_materia, $url_comision);
            return catalogo::consultar('inscripcion_cursada', 'asignacion_horaria_comision', array('comision'=>$comision));
        }
        
        return false;
    }
    
	//---------------------------------------------
	//	CONTROL ENVIO PARAMETROS
	//---------------------------------------------
	
	function get_opcion_enviada_materia($url_materia, $mis_inscripciones = false)
	{
		if (!isset($this->opcion_materia[$url_materia])) {
			$materia = null;
			$materias = $this->info__lista_materias($mis_inscripciones);
			foreach($materias as $mat) {
				if($mat[catalogo::id] == $url_materia){
					$materia = $mat['MATERIA'];
				}
			}
			if(!isset($materia)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la materia');
			}
			$this->opcion_materia[$url_materia] = $materia;
		}
		return $this->opcion_materia[$url_materia];
	}
        
        function get_nro_transaccion($url_transaccion)
        {
            $nro_transacciones_inscripciones_historicas = catalogo::consultar('inscripcion_cursada', 'info_nro_transacciones_inscripciones_historicas',
							array('nro_inscripcion'=>  $this->nro_inscripcion));
            
            foreach ($nro_transacciones_inscripciones_historicas as $nro_transaccion_inscripciones_historicas){
                
                if($nro_transaccion_inscripciones_historicas['URL_NRO_TRANSACCION'] == $url_transaccion){
                    return $nro_transaccion_inscripciones_historicas['NRO_TRANSACCION'];
                }
            }
            throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe el nro de transacción');
        }
	
	function get_opcion_enviada_comision($url_materia, $url_comision)
	{
		if (!isset($this->opcion_comision[$url_comision])) {
			$comision = null;
			$comisiones = $this->info__lista_comisiones($url_materia);
			
			foreach($comisiones as $com) {
				if($com[catalogo::id] == $url_comision){
					$comision = $com['COMISION'];
				}
			}
			if(!isset($comision)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la comision');
			}
			$this->opcion_comision[$url_comision] = $comision;
		}
		return $this->opcion_comision[$url_comision];
	}
	
	
	function get_opciones_enviada_subcomision($url_materia, $comision, $url_subcomisiones)
	{
		$subcom_ok = array();
		$comisiones = $this->info__lista_comisiones($url_materia);
		if (!isset($comisiones[$comision]['SUBCOMISIONES'])) {
			throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existen subcomisiones para la comision ' . $comision);						
		}
		foreach($url_subcomisiones as $tipo_clase => $url_subcom){
			$encontrada = false;
			$subs = $comisiones[$comision]['SUBCOMISIONES'][$tipo_clase];
			foreach($subs as $sub) {
				if($sub[catalogo::id] == $url_subcom){
					$subcom_ok[$tipo_clase] = $sub['SUBCOMISION'];
					$encontrada = true;
					break;
				}
			}
			if (!$encontrada) {
				throw new error_guarani_seguridad("OPCIONES ENVIADAS existe COM: $comision - SUBCOM: $tipo_clase / $url_subcom");
			}
		}
		return $subcom_ok;
	}
	
	function get_opcion_enviada_subcomision($url_materia, $comision, $url_subcomision)
	{
		$comisiones = $this->info__lista_comisiones($url_materia);
        
		if (!isset($comisiones[$comision]['SUBCOMISIONES'])) {
			throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existen subcomisiones para la comision ' . $comision);						
		}
        $subcomison = null;
        foreach($comisiones[$comision]['SUBCOMISIONES'] as $tipos){
            foreach($tipos as $sub){
                if ($sub["__ID__"] == $url_subcomision){
                    $subcomison = $sub['SUBCOMISION'];
                }
            }
        }
		
        if (!isset($subcomison)){
            throw new error_guarani_seguridad("OPCIONES ENVIADAS NO EXISTE SUBCOM: $subcomison");
        }
        
        return $subcomison;
	}
	
	/**
	 * Se usa para la lista del medio, hay que obtener la comisión desde otro 
	 * listado. Las materias pueden tener un período de baja distinto del de alta
	 * @param type $url_comision 
	 */
	function get_opcion_enviada_comision_baja($url_comision)
	{
		if (!isset($this->opcion_comision_baja[$url_comision])) {
			$comision = null;
			$comisiones = $this->info__lista_comisiones_baja();
			foreach($comisiones as $com) {
				if($com['url_comision'] == $url_comision) {
					$comision = $com['id_comision'];
				}
			}
			if(!isset($comision)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la comision para dar de baja');
			}
			$this->opcion_comision_baja[$url_comision] = $comision;
		}
		return $this->opcion_comision_baja[$url_comision];
	}
	
	function get_opcion_enviada_nro_transaccion($url_materia, $url_transaccion, $mis_inscripciones = false)
	{
		if (!isset($this->opcion_nro_transaccion[$url_transaccion])) {
			$inscripciones = $this->info__inscripciones_materia($url_materia, $mis_inscripciones);
			foreach ($inscripciones as $insc) {
				if ($insc['URL_NRO_TRANSACCION'] == $url_transaccion) {
					$transaccion = $insc['NRO_TRANSACCION'];
				}
			}
			if(!isset($transaccion)) {
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe el nro de transacción');
			}
			
			$this->opcion_nro_transaccion[$url_transaccion] = $transaccion;
		}
		
		return $this->opcion_nro_transaccion[$url_transaccion];
	}
	
	function get_opcion_enviada_cert_baja($url_comision)
	{ 
		$clave = "id_cert_baja_$url_comision"; 
		if (! kernel::sesion()->esta_seteada($clave)) { 
				throw new error_guarani_seguridad('el id de baja no existe'); 
		} 
		return kernel::sesion()->get($clave); 
	}
	
	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------

	function evt__inscripcion($url_materia, $url_comision, $url_subcomisiones)
	{
		// Validacion seguridad
		$comision = $this->get_opcion_enviada_comision($url_materia, $url_comision);
		$hay_subcomisiones = (is_array($url_subcomisiones) && count($url_subcomisiones) > 0);
		if ($hay_subcomisiones) {
			$subcomisiones = $this->get_opciones_enviada_subcomision($url_materia, $comision, $url_subcomisiones);
			$str_subcomisiones = implode(',',$subcomisiones) . ',';
		} else {
			$subcomisiones = array();
			$str_subcomisiones = '';
		}		

		kernel::log()->add_debug('SUBCOMISIONES',$subcomisiones);
		
		// Ejecuto controles
		list($msg, $hubo_advertencias) = $this->control__inscripcion($comision, $subcomisiones);
		// Estado de la inscripcion
		$estado = $hubo_advertencias ? 'P' : 'A';
		$info_comision = $this->datos()->info__comision($comision, $this->carrera, $this->plan, $this->version );
		$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
		// Ejecutar DB
		$ok = catalogo::consultar('inscripcion_cursada', 'inscripcion_comision',
							array(		'carrera' => $this->carrera,
										'legajo' => $this->legajo,
										'nro_inscripcion' => $nro_inscripcion,
										'comision' => $comision,
										'subcomisiones' => $str_subcomisiones,
										'materia_generica' => '',
										'plan' => $this->plan,
										'version' => $this->version,
										'calidad' => parametro::inscripcion_cursada_calidad(),
										'estado' => $estado,
										'max_insc_cursada' => parametro::max_inscripciones_cursada(),
										'controla_cupo' => parametro::controla_cupo(),
										'materia' => $info_comision['MATERIA'],
										'nombre_comision' => $info_comision['NOMBRE']));
		kernel::log()->add_debug('RESULTADO INSCRIPCION -- COM: ' . $comision . 
								' - SUBCOM: '  . $str_subcomisiones .
								' - STATUS: ' . $estado, $ok);
		if(($ok[0]>0)) {
			// exito
			$temp = explode(',',$ok[1]);
			$transaccion = $temp[1];
			guarani::persona()->cursadas()->reset();
			return array($msg, $transaccion);
		} else {
			$mensaje = util::mensaje($ok[1]);
			throw new error_guarani_usuario($mensaje);
		}
	}

	function evt__eliminar_inscripcion($url_materia, $url_comision)
	{
		$comision = $this->get_opcion_enviada_comision($url_materia, $url_comision);
		return $this->eliminar_inscripcion($comision);
	}

	/**
	 * Elimina una inscripción a una cursada aunque no tenga un período de alta
	 * activo. Tiene que tener activo el período de baja.
	 */
	function evt__eliminar_inscripcion_periodo_alta_cerrado($url_comision)
	{
		$comision = $this->get_opcion_enviada_comision_baja($url_comision);
		return $this->eliminar_inscripcion($comision);
	}
	
	protected function eliminar_inscripcion($comision)
	{
		kernel::log()->add_debug('ELIMINAR INSCRIPCION', $comision);
		$msg = $this->control__eliminar_inscripcion($comision);
		$info_comision = $this->datos()->info__comision($comision, $this->carrera, $this->plan, $this->version );
		$ok = catalogo::consultar('inscripcion_cursada', 'eliminar_inscripcion_comision',
							array(		'carrera' => $this->carrera,
										'legajo' => $this->legajo,
										'comision' => $comision,
										'controla_cupo' => parametro::controla_cupo(),
										'anio_academico' => $info_comision['ANIO_ACADEMICO'],
										'periodo_lectivo' => $info_comision['PERIODO_LECTIVO']));
		if(($ok[0]>0)) {
			$temp = explode(',',$ok[1]);
			$transaccion = $temp[1];
			kernel::log()->add_debug('TRANSACCION', $transaccion);
			guarani::persona()->cursadas()->reset();
			return array($msg, $transaccion);
		} else {
			$msg = util::mensaje($ok[1]);
			throw new error_guarani_usuario($msg);
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

	protected function control__inscripcion($comision, $subcomisiones)
	{
		$info_comision = $this->datos()->info__comision($comision, $this->carrera, $this->plan, $this->version );
		// 1) Se repiten controles anteriores por seguridad y para conocer las advertencias
		// (No hay ninguna primitiva del kernel que garantice la secuencia de requests para
		// permitir multiples hilos paralelos), por eso esto es necesario.
		// el costo es minimo porque esta todo en el cache
		$proceso = $this->nuevo_proceso_control();		
		$this->agregar_puntos_iniciales($proceso);
		$this->agregar_puntos_materia($proceso, $info_comision['MATERIA']);
		$proceso->ejecutar(); //Los mensajes no importan, ya se mostraron antes
		$advertencias = $proceso->hay_advertencias();
		
		// 2) Control comisiones/subcomisiones
		$proceso2 = $this->nuevo_proceso_control();		
		$this->agregar_puntos_comision($proceso2, $info_comision);
		$hay_subcomisiones = (is_array($subcomisiones) && count($subcomisiones) > 0);
		if($hay_subcomisiones) {
			$this->agregar_puntos_subcomision($proceso2, $comision, $subcomisiones);
		}
		$msg = $proceso2->ejecutar();
		$advertencias = $advertencias || $proceso2->hay_advertencias();
		
		return array($msg, $advertencias);
	}
	
	protected function control__eliminar_inscripcion($comision)
	{
		// faltan repetir los controles anteriores
		$proceso = new proceso_control($this->operacion_baja, $this->evento_baja);
		$proceso->agregar_punto(2, array(
			'nro_inscripcion'=> $this->nro_inscripcion,
			'operacion' => $this->operacion_baja
		));
		
		$proceso->agregar_punto(3, array(
			'carrera' => $this->carrera,
			'legajo' => $this->legajo,
			'operacion' => $this->operacion_baja
		));
		
		$proceso->agregar_punto(7, array(
			'carrera' => $this->carrera,
			'legajo' => $this->legajo,
			'comision' => $comision
		));
		
		$msg = $proceso->ejecutar();
		return $msg;
	}
	
	//---------------------------------------------

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
		$proceso->agregar_punto(4, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'materia' => $materia));
		$proceso->agregar_punto(36, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'materia' => $materia,
											'fecha' => catalogo::fecha_actual()));
	}

	protected function agregar_puntos_comision($proceso, $info_comision)
	{
		$proceso->agregar_punto(5, array(	'carrera' => $this->carrera,
										'legajo' => $this->legajo,
										'comision' => $info_comision['COMISION']));
		$proceso->agregar_punto(6, array(	'carrera' => $this->carrera,
										'legajo' => $this->legajo,
										'comision' => $info_comision['COMISION'],
										'materia_generica' => ''));	
		$proceso->agregar_punto(33, array(	'nro_inscripcion' => $this->nro_inscripcion,
										'anio_academico' => $info_comision['ANIO_ACADEMICO']));		
	}
	
	protected function agregar_puntos_subcomision($proceso, $comision, $subcomisiones)
	{
		foreach($subcomisiones as $subcomision) {
			$proceso->agregar_punto(32, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'comision' => $comision,
											'subcomision' => $subcomision));
		}
	}
}

?>