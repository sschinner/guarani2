<?php
namespace siu\modelo\entidades;


use kernel\kernel;
use siu\modelo\datos\cache\admin_cache;

class catalogoTest extends \PHPUnit_Framework_TestCase 
{
	
	protected function setUp() 
	{
		require_once dirname(__FILE__) . '/../../../../../../bootstrap.php';
		\siu\bootstrap::cargar();
    }

    protected function tearDown() 
	{
		kernel::log()->guardar();
    }

	public function test_guardar_existe()
	{
		$cache = admin_cache::instancia('archivo');
		$clase = 'hoy';
		$metodo = 'tambien';
		$parametros = array('uno'=>123,'dos'=>456);
		$datos = array( array(1,2,3,4), array('a','b','c','d'));
		$cache->guardar($clase, $metodo, $parametros, $datos);
		if($cache->existe($clase, $metodo, $parametros)){
			$this->assertTrue(true);
		} else {
			$this->assertTrue(false);
		}
		$datos2 = $cache->buscar($clase, $metodo, $parametros);
		$this->assertEquals(count($datos), count($datos2));
	}
	
}

?>