<?php
namespace test\modelo\entidades;

require_once('../casos_test.php');

use kernel\kernel;
use kernel\nucleo\sesion;
use siu\guarani;

class inscripcion_cursadaTest extends \PHPUnit_Framework_TestCase 
{
	protected $alumnos;
	
	protected function setUp() 
	{
		require_once dirname(__FILE__) . '/../../../siu/bootstrap.php';
		\siu\bootstrap::cargar();
		// Abrir sesion
		$alumno = $this->get_datos_alumno();
		//kernel::sesion(sesion::tipo_shell)->abrir($alumno['identificacion'], $alumno['clave']);
		//kernel::sesion(sesion::tipo_shell)->abrir($alumno['identificacion'], '123456');
		kernel::sesion(sesion::tipo_shell)->abrir('01-34375567-07', '123456');
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
	
    protected function tearDown() 
	{
		kernel::log()->guardar();
    }

	//-------------------------------------------------------------------------
	// TEST
	//-------------------------------------------------------------------------
	
	public function _test_ini()
	{
		guarani::cursada()->iniciar();
	}

	public function _test_listar_materias()
	{
		guarani::cursada()->iniciar();
		$materias = guarani::cursada()->info__lista_materias();
		$this->assertTrue(count($materias)>0);
		
	}

	public function _test_seleccionar_materia()
	{
		guarani::cursada()->iniciar();
		$materias = guarani::cursada()->info__lista_materias();
		$id_materia = $materias[0][1];
		guarani::cursada()->evt__elegir_materia($id_materia);
	}

	public function test_seleccionar_comision()
	{
		guarani::cursada()->iniciar();
		$materias = guarani::cursada()->info__lista_materias();
		print_r($materias);
		//$id_materia = $materias[0][1];
		$id_materia = '11201';
		guarani::cursada()->evt__elegir_materia($id_materia);
		$comisiones = guarani::cursada()->info__lista_comisiones();
		print_r($comisiones);
		//$id_comision = $comisiones[0]['COMISION'];
		//$id_comision = 4867;
		//guarani::cursada()->evt__elegir_comision($id_comision);
	}
}

?>