<?php
namespace siu\modelo\entidades;

require_once('../casos_test.php');

use kernel\kernel;
use kernel\nucleo\sesion;
use siu\guarani;

class catalogoTest extends \PHPUnit_Framework_TestCase 
{
	protected $alumnos;
	
	protected function setUp() 
	{
		require_once dirname(__FILE__) . '/../../../siu/bootstrap.php';
		\siu\bootstrap::cargar();
		// Abrir sesion
		$alumno = $this->get_datos_alumno();
		//kernel::sesion(sesion::tipo_shell)->abrir($alumno['identificacion'], $alumno['clave']);
		kernel::sesion(sesion::tipo_shell)->abrir($alumno['identificacion'], '123456');
    }

	protected function get_datos_alumno()
	{
		if(!isset($this->alumnos)) {
			$this->alumnos = \test\modelo\casos_test::get_alumnos();
			if(!is_array($this->alumnos) || empty($this->alumnos) ) {
				throw new \Exception('No estan cargados los juegos de datos. Ejecutar: guarani datos_test');
			}
		}
		return array_shift($this->alumnos);
	}

	public function test_crear()
	{
		$nro_inscripcion = $this->alumnos[0]['nro_inscripcion'];
		$persona = new persona($nro_inscripcion);
		
	}
}

?>