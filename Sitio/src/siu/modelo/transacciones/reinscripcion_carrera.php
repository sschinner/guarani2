<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\errores\error_guarani;
use siu\errores\error_guarani_usuario;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\parametro;

class reinscripcion_carrera extends transaccion_alumno
{
	protected $operacion = 'mat00014';
	protected $evento = '18';

    function reinscribir()
    {
        $this->puede_reinscribirse();
        $reinscripcion = catalogo::consultar('matricula', 'reinscripcion',
            array(		'carrera' => $this->carrera,
                'legajo' => $this->legajo));

        $status = $reinscripcion[0];
        $mensaje = $reinscripcion[1];

        kernel::log()->add_debug('REINSCRIPCION', $reinscripcion);
        if($status < 0) {
            $msg = catalogo::consultar('sistema', 'mensaje', array('mensaje' => $mensaje));
            throw new error_guarani('Error durante la inscripcion: ' . $msg[0]);
        }
        else{
            $mensaje_explode = explode(',', $mensaje);
            $nro_transaccion = $mensaje_explode[1];
            return $nro_transaccion;
        }
    }
	
	function es_necesaria_reinscripcion()
	{
		// Carreras a reinscribirse
		$datos = catalogo::consultar('matricula', 'carreras_a_reinscribirse', 
										array('nro_inscripcion'=>$this->nro_inscripcion));		
		
		return isset($datos[$this->carrera]) && $datos[$this->carrera]['ESTA_REINSCRIPTO'] == 'N';
	}
	
	function puede_reinscribirse()
	{
		// Hay periodos de reinscripcion
		$datos = catalogo::consultar('matricula', 'periodos_reinscripcion');
		if( count($datos) < 1 || empty($datos[0]) || empty($datos[0][0])) {
			throw new error_guarani_usuario('No hay períodos de reinscripcion abiertos.');
		}
		if(count($datos)>1) {
			throw new error_guarani_usuario('No se puede identificar el periodo de inscripción activo.');
		}
		$periodo_inscripcion = $datos[0][0];

		// Controlar si es reingresante y tiene que inscribirse
		$es_ingresante = catalogo::consultar('alumno', 'es_reingresante_carrera' ,
											array(	'carrera'=> $this->carrera,
													'legajo' => $this->legajo,
													'periodo_inscripcion' => $periodo_inscripcion));
		$reinscribir_ingresante = (parametro::reinscripcion_ingresante() == 'S');
		if($es_ingresante == 'S' && ! $reinscribir_ingresante){
			throw new error_guarani_usuario('Los ingresantes no necesitan reinscribirse en la carrera');
		}
		// Disparar controles
		$anio_academico = catalogo::consultar('matricula', 'anio_academico_reinscripcion',
												array('periodo_inscripcion' => $periodo_inscripcion));
		return $this->disparar_puntos_de_control($anio_academico);
	}
	
	protected function disparar_puntos_de_control($anio_academico)
	{
		$proceso = $this->nuevo_proceso_control();			
		//(Persona - Operación) - Una Persona elige una operación
		$proceso->agregar_punto(2, array('nro_inscripcion' => $this->nro_inscripcion,
											'operacion' => $this->operacion));
		$proceso->agregar_punto(3, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'operacion' => $this->operacion));
		//(Requisitos) - Requisitos Obligatorios y No Obligatorios de la UA y la Carrera
		$proceso->agregar_punto(24, array(	'nro_inscripcion' => $this->nro_inscripcion,
											'carrera' => $this->carrera));
		$proceso->agregar_punto(33, array(	'nro_inscripcion' => $this->nro_inscripcion,
											'anio_academico' => $anio_academico));			
		return $proceso->ejecutar();		
	}
    
    function reinscripciones()
	{
		// Listado de reinscripciones
		$datos = catalogo::consultar('matricula', 'reinscripciones',
										array('nro_inscripcion'=>$this->nro_inscripcion));
		return $datos;
	}
    
    function datos_comprobante($nro_transaccion)
	{
		// Listado de reinscripciones
		$datos = catalogo::consultar('matricula', 'datos_reinscripcion',
										array('nro_trans'=>$nro_transaccion));
		return $datos;
	}
}
?>