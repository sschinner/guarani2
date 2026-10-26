<?php
namespace siu\modelo\transacciones;
use kernel\kernel;
use siu\modelo\entidades\persona;
use siu\modelo\controles\proceso_control;
use siu\guarani;
use siu\errores\error_guarani;

/**
 * Los controles suponen una acumulacion ordenada.
 *
 *	@todo: El dato tiene que manejarse en sesion con una clave de transaccion
 * 
 *	Esta clave es la que se usa en el esquema de controles enfocado en esta
 * transaccion. tambien el control de secuencias (para controlar errores de hilo por navegacion con tabs
 * el espacio necesitaria un finalizar() tanto como iniciar() para manejar el 
 * ciclo de vida de esta info
 */
abstract class transaccion
{
	static protected $controles_activos = true;
	protected $operacion;
	protected $evento;
	protected $datos;
	protected $id;
	protected $nro_inscripcion;
	protected $opciones_request = array();
	
	function __construct($nro_inscripcion) 
	{
		$this->nro_inscripcion = $nro_inscripcion;	
	}

	function nuevo_proceso_control()
	{
		if(!isset($this->operacion)||!isset($this->evento)) {
			throw new error_guarani('CONTROL TRANSACCION: No esta definida la operacion y el evento');
		}
		return new proceso_control($this->operacion, $this->evento);
	}
	
	function control__inicial(){}

	//------------------------------------------------------
	// Helper manejo operaciones
	//------------------------------------------------------
	
	protected function get_opcion_enviada($seleccion, $metodo)
	{
		if (!isset($this->opciones_request[$seleccion])) {
			$opciones = $this->$metodo();
			if (!isset($opciones[$seleccion])) {
				throw new error_guarani('Opcion invalida');
			}	
			$this->opciones_request[$seleccion] = $opciones[$seleccion];
		}
		//kernel::log()->add_debug('OPCION SELECCIONADA', $this->opciones_request[$seleccion]);
		return $this->opciones_request[$seleccion];
	}	
	
}

?>