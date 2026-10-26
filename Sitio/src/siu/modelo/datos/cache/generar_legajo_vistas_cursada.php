<?php
namespace siu\modelo\datos\cache;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\modelo\controles\controles;
use siu\errores\error_guarani_control;

use kernel\util\db\db;
use kernel\util\manejador_archivos;
use kernel\util\clase_datos;

class generar_legajo_vistas_cursada
{
	protected $operacion = 'cur00003';
	protected $evento = '2';
	
	protected $carrera;
	protected $legajo;
	protected $nro_inscripcion;
	protected $plan;
	protected $version;
	protected $dir;
	protected $base_clases;

	protected $lista_materias = array();
	protected $lista_materias_excluidas = array();
	protected $lista_comisiones = array();
	protected $lista_comisiones_excluidas = array();
	
	function __construct($carrera, $legajo, $nro_inscripcion, $plan, $version, $dir, $base_clases) 
	{
		$this->carrera = $carrera;
		$this->legajo = $legajo;
		$this->nro_inscripcion = $nro_inscripcion;
		$this->plan = $plan;
		$this->version = $version;		
		$this->dir = $dir ;			
		$this->base_clases = $base_clases;
	}
	
	function procesar()
	{
		$this->generar_lista_materias();
		//print_r($this->lista_materias);
		//print_r($this->lista_materias_excluidas);
		//$this->generar_lista_comisiones();
		//print_r($this->lista_comisiones);
		//print_r($this->lista_comisiones_excluidas);
		$this->guardar_cache();
	}
	
	//---------------------------------------------------------------
	// INSCRIPCION a CURSADAS
	//---------------------------------------------------------------
	
	function generar_lista_materias()
	{
		// obtengo materias
		//$recursar = catalogo::parametro('recursar_regularizadas');
		//$comisiones_actuales = catalogo::parametro('recursar_regularizadas');
		$recursar = 'N';
		$comisiones_actuales = 'S';
		$this->lista_materias = catalogo::consultar('inscripcion_cursada', 'lista_materias2', 
								array(	'carrera' => $this->carrera,
										'legajo' => $this->legajo,
										'nro_inscripcion' => $this->nro_inscripcion,
										'plan' => $this->plan,
										'version' => $this->version,
 										'recursar' => $recursar,
										'comisiones_actuales'=>$comisiones_actuales));
		//return;
		// ejecuto los controles
		foreach($this->lista_materias as $id => $materia) {
			if($materia['TIPO']=='O') continue;
			try {
				$this->punto_control(4, array(	'carrera' => $this->carrera,
												'legajo' => $this->legajo,
												'materia' => $id));
				$this->punto_control(36, array(	'carrera' => $this->carrera,
												'legajo' => $this->legajo,
												'materia' => $id,
												'fecha' => catalogo::fecha_actual()));
			} catch (error_guarani_control $e) {
				// la materia no paso algun control
				$this->lista_materias_excluidas[] = $id;
				unset($this->lista_materias[$id]);
			}
		}
	}
	
	function generar_lista_comisiones()
	{
		foreach($this->lista_materias as $id_materia => $materia) {
			$this->lista_comisiones[$id_materia] = catalogo::consultar('inscripcion_cursada', 'lista_comisiones',
												array(	'carrera' => $this->carrera,
														'legajo' => $this->legajo,
														'materia' => $id_materia));
			//continue;
			// ejecuto los controles
			foreach($this->lista_comisiones[$id_materia] as $id_comision => $comision) {
				try {
					$this->punto_control(5, array(	'carrera' => $this->carrera,
													'legajo' => $this->legajo,
													'comision' => $id_comision));
					$this->punto_control(6, array(	'carrera' => $this->carrera,
													'legajo' => $this->legajo,
													'comision' => $id_comision,
													'materia_generica' => ''));		
					$this->punto_control(33, array(	'nro_inscripcion' => $this->nro_inscripcion,
													'anio_academico' => $comision['ANIO_ACADEMICO']));		
				} catch (error_guarani_control $e) {
					// la materia no paso algun control
					$this->lista_comisiones_excluidas[$id_materia][] = $id;
					unset($this->lista_comisiones[$id_materia][$id]);
				}
			}
			
		}
	}
	
	function punto_control($punto, $parametros)
	{
		controles::ejecutar($punto, $parametros, $this->operacion, $this->evento);
	}	

	function guardar_cache()
	{
		if (empty($this->lista_materias)) return;
		
		//-- materias ------
		if(!is_dir($this->dir)){
			manejador_archivos::crear_arbol_directorios($this->dir);
		}		
		$clase = $this->base_clases . '_materias';
		$path =  $this->dir .  "/{$clase}.php";
		$clase = new clase_datos($clase, null, 'cache\siu\personas');
		$clase->agregar_metodo_datos('get_lista_materias', $this->lista_materias);
		$clase->guardar($path);	
		//-- comisiones -----
		foreach($this->lista_comisiones as $materia => $comisiones) {
			$clase = $this->base_clases . '_materia_' . $materia;
			$path =  $this->dir .  "/{$clase}.php";
			$clase = new clase_datos($clase, null, 'cache\siu\personas');
			$clase->agregar_metodo_datos('get_lista_comisiones', $comisiones);
			$clase->guardar($path);	
		}
	}
}
?>