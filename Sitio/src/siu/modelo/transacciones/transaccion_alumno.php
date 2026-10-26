<?php
namespace siu\modelo\transacciones;

use siu\modelo\entidades\persona;
use siu\modelo\controles\controles;

use siu\guarani;

abstract class transaccion_alumno extends transaccion
{
	protected $carrera;
	protected $legajo;
	protected $plan;
	protected $version;
	
	function __construct($nro_inscripcion, $carrera, $legajo, $plan, $version) 
	{
		$this->nro_inscripcion = $nro_inscripcion;	
		$this->carrera = $carrera;
		$this->legajo = $legajo;
		$this->plan = $plan;
		$this->version = $version;
		parent::__construct($nro_inscripcion);
	}
}

?>