<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\modelo\controles\controles;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_seguridad;
use siu\modelo\controles\proceso_control;
use siu\errores\error_guarani_control;

class orientacion extends transaccion
{
	protected $operacion = 'agcert01';
	protected $evento = '2';
	protected $estrategia_acceso_datos;
	protected $nro_inscripcion;
	protected $lista_orientaciones;
	protected $orientacion_actual;
	protected $carrera;
	protected $legajo;
	protected $titulos_orientacion;

	function __construct($nro_inscripcion)
	{
		$this->nro_inscripcion = $nro_inscripcion;
		parent::__construct($nro_inscripcion);
	}	
	//---------------------------------------------
	//	INFO
	//---------------------------------------------

	function lista_orientaciones()
	{
		$nuevos = array();
		if (!empty($this->lista_orientaciones)){
			$nuevos = $this->lista_orientaciones;
		} else {	
			$datos = array();
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$datos = catalogo::consultar('orientacion', 'lista_orientaciones', $parametros);

			$carrera_activa = kernel::persona()->get_id_carrera_activa();

			$i = 0;
			foreach($datos as $value) {
				if ($value['carrera'] == $carrera_activa){
					$nuevos[$i] = $value;
					$i++;
				}
			}
			$this->lista_orientaciones = $nuevos;
		}
		return $nuevos;
	}

	function lista_orientaciones_titulo($titulo)
	{
		$nuevos = array();

		$datos = array();
		$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		// recupero la lista de orientaciones disponibles
		$datos = catalogo::consultar('orientacion', 'lista_orientaciones', $parametros); 
		// filtro dicha lista para quedarme sólo con las orientaciones del título seleccionado
		$orientaciones_titulo = array();
		foreach($datos as $dato)
		{
			if($dato['titulo_id'] == $titulo)
			{
				$orientaciones_titulo[] = $dato;
			}	
		}	

		$carrera_activa = kernel::persona()->get_id_carrera_activa();
		$orientacion_actual = $this->orientacion_actual_titulo($titulo);

		if (!empty($orientacion_actual) && !empty($orientacion_actual['orientacion'])) {
			$o_actual = $orientacion_actual['orientacion'];
		} else {
			$o_actual = false;
		}

		$i = 0;
		foreach($orientaciones_titulo as $value) {
			if ($value['carrera'] == $carrera_activa && $value['orientacion'] !== $o_actual){
				$nuevos[$i] = $value;
				$i++;
			}
		}
		//$this->lista_orientaciones = $nuevos;
		
		return $nuevos;
	}
	
	function get_orientacion($id){
		$orientaciones = $this->lista_orientaciones();
		
		foreach ($orientaciones as $registro){
			if ($registro['__ID__'] == $id){
				$orientacion = $registro;	
			}
		}
		if(!isset($orientacion)){
			throw new error_guarani_seguridad('No existe la orientación');
		}
		
		return $orientacion;
	}
	
	function orientacion_actual()
	{
		$nuevo = array();
		if (!empty($this->orientacion_actual)){
			$nuevo = $this->orientacion_actual;
		} else {
			$parametros = array();
			$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
			$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();		
			$datos = catalogo::consultar('orientacion', 'orientacion_actual', $parametros);

			foreach($datos as $key => $value){
				$nuevo[$key]['orientacion'] = $value[0];
				$nuevo[$key]['plan'] =  $value[2];
				$nuevo[$key]['titulo'] =  $value[4];
				$nuevo[$key]['nombre'] =  $value[1];
				$nuevo[$key]['titulo_id'] =  $value[3];			
			}
			$this->orientacion_actual = $nuevo;
		}
		return $nuevo;
	}
	
	
	function orientacion_actual_titulo($titulo)
	{
		$nuevo = array();
		
		$parametros = array();
		$parametros['carrera']	= kernel::persona()->get_id_carrera_activa();
		$parametros['legajo']	= kernel::persona()->get_id_legajo_activo();		
		$parametros['titulo']	= $titulo;		
		$datos = catalogo::consultar('orientacion', 'orientacion_actual_titulo', $parametros);

		foreach($datos as $key => $value)
		{
			$nuevo[$key]['orientacion'] = $value[0];
			$nuevo[$key]['plan'] =  $value[2];
			$nuevo[$key]['titulo'] =  $value[4];
			$nuevo[$key]['nombre'] =  $value[1];
			$nuevo[$key]['titulo_id'] =  $value[3];			
		}

		return $nuevo[0];
	}
	
	function titulos_orientacion()
	{
		$nuevo = array();
//		if (!empty($this->titulos_orientacion)){
//			$nuevo = $this->titulos_orientacion;
//		} else {
			$parametros = array();
			$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
			$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();		
			$parametros['plan'] = kernel::persona()->get_id_plan_activo();		
			$datos = catalogo::consultar('orientacion', 'titulos_orientacion', $parametros);

			foreach($datos as $key => $value){
				$nuevo[$key]['titulo'] = $value[0];
				$nuevo[$key]['nombre'] =  $value[1];
				$nuevo[$key]['nivel'] =  $value[2];
				$nuevo[$key]['orient_elegida'] =  $value[3];
				$nuevo[$key]['elige_orient'] =  ucfirst(kernel::traductor()->trans('orientacion_tit_elige_orient_'.$value[4]));
				
				$orientacion_actual = $this->orientacion_actual_titulo($value[0]);
				$nuevo[$key]['orientacion_actual']['orientacion'] = $orientacion_actual['orientacion'];
				$nuevo[$key]['orientacion_actual']['plan'] = $orientacion_actual['plan'];
				$nuevo[$key]['orientacion_actual']['titulo'] = $orientacion_actual['titulo'];
				$nuevo[$key]['orientacion_actual']['nombre'] = $orientacion_actual['nombre'];
				$nuevo[$key]['orientacion_actual']['titulo_id'] = $orientacion_actual['titulo_id'];
				$nuevo[$key]['orientacion_actual']['realizo_materias'] = false;
				if(!empty($orientacion_actual['orientacion']))
				{
					$nuevo[$key]['orientacion_actual']['realizo_materias'] = $this->realizo_mat_orient_actual_titulo($orientacion_actual['orientacion']);
				}
				
				$nuevo[$key]['orientaciones']= $this->lista_orientaciones_titulo($value[0]);
			}
			$this->titulos_orientacion = $nuevo;
//		}
		return $nuevo;
	}
			
	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------
	function evt__solicitar($id, $titulo)
	{
		$this->carrera = kernel::persona()->get_id_carrera_activa();
		$this->legajo = kernel::persona()->get_id_legajo_activo();
				
		$this->control__inicial();
		
		kernel::db()->abrir_transaccion();
		
		$parametros = array();
		$parametros['carrera'] = $this->carrera;
		$parametros['legajo'] = $this->legajo;
		
		$seleccion = $this->get_orientacion($id);
		$o_actual = $this->orientacion_actual_titulo($titulo);
			
		$parametros['plan'] = $seleccion['plan'];
		$parametros['titulo'] = $seleccion['titulo_id'];
		$parametros['orientacion'] = $seleccion['orientacion'];
		$parametros['movimiento'] = "A";
		$parametros['observaciones'] = NULL;
		
		if (!empty($o_actual)){			
			$parametros_actual['carrera'] = $this->carrera;
			$parametros_actual['legajo'] = $this->legajo;
			$parametros_actual['plan'] = $o_actual['plan'];
			$parametros_actual['titulo'] = $o_actual['titulo_id'];
			$parametros_actual['orientacion'] = $o_actual['orientacion'];
			$parametros_actual['movimiento'] = "B";
			$parametros_actual['observaciones'] = NULL;
			
			// elimino la orientación actual
			$ok_actual = catalogo::consultar('orientacion', 'seleccionar_orientacion', $parametros_actual);
		}
		
		$ok = catalogo::consultar('orientacion', 'seleccionar_orientacion', $parametros);
		
		if ($ok[0] >= 0){
			kernel::db()->cerrar_transaccion();
			return true;
		} else {
			kernel::db()->abortar_transaccion();
			throw new error_guarani('Error durante la selección de orientación');
		}
	}
	
	function evt__eliminar($observaciones = null, $titulo)
	{
		if (isset($observaciones)){
//			$parametros = array (	'carrera' => kernel::persona()->get_id_carrera_activa(),
//									'legajo' => kernel::persona()->get_id_legajo_activo()
//					);
			$o_actual = $this->orientacion_actual_titulo($titulo);

			if (!empty($o_actual)){			
				$parametros_actual['carrera'] = kernel::persona()->get_id_carrera_activa();
				$parametros_actual['legajo'] = kernel::persona()->get_id_legajo_activo();
				$parametros_actual['plan'] = $o_actual['plan'];
				$parametros_actual['titulo'] = $o_actual['titulo_id'];
				$parametros_actual['orientacion'] = $o_actual['orientacion'];
				$parametros_actual['movimiento'] = "B";
				$parametros_actual['observaciones'] = $observaciones;

				// elimino la orientación actual
				$ok = catalogo::consultar('orientacion', 'seleccionar_orientacion', $parametros_actual);
			}
		} else {
			throw new error_guarani('Error durante la eliminación debe ingresar un motivo');
		}
	}	
	
	function control__inicial()
	{
		$proceso = $this->nuevo_proceso_control();
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
		$proceso->ejecutar();
	}

    function info__realizo_materias_orientacion()
    {
        $this->orientacion_actual();

        $parametros = array(
            'carrera' => kernel::persona()->get_id_carrera_activa(),
            'legajo' => kernel::persona()->get_id_legajo_activo(),
            'orientacion' => $this->orientacion_actual[0]['orientacion']
        );

        return catalogo::consultar('alumno', 'realizo_materias_de_la_orientacion', $parametros);
    }

    function realizo_mat_orient_actual_titulo($orientacion)
    {
        $parametros = array(
            'carrera' => kernel::persona()->get_id_carrera_activa(),
            'legajo' => kernel::persona()->get_id_legajo_activo(),
            'orientacion' => $orientacion
        );

        return catalogo::consultar('alumno', 'realizo_materias_de_la_orientacion', $parametros);
    }
}
?>