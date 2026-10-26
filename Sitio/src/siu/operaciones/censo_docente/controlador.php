<?php
namespace siu\operaciones\censo_docente;

use siu\guarani;
use kernel\kernel;
use siu\errores\error_guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;

class controlador extends controlador_g3w2
{
    function ini()
	{		
        $this->controlar_csrf_accion('guardar');
    }

    function modelo()
    {
		return guarani::datos_censales();
    }

    function accion__index()
    {
        $datos = $this->modelo()->get_datos_censales();
		$this->vista()->mostrar('principales', $datos);
		kernel::renderer()->add($this->vista()->pagelet('formulario'));
    }
	
	function accion__guardar()
	{
		if (kernel::request()->isPost()) {
			try {
				$respuesta = $this->modelo()->grabar_datos_censales($_POST);
				$respuesta['cont'] = "Guardado";
			} catch (\siu\errores\error_procesar_datos_censales $e) {
				kernel::renderer()->add_csrf($this->generar_csrf());
				throw $e;
			}
			//$this->render_ajax($respuesta['cont'], $respuesta);
			$datos = $this->modelo()->get_datos_censales();
			$this->vista()->mostrar('principales', $datos);
			kernel::renderer()->add($this->vista()->pagelet('formulario'));
		}
	}
	
	function accion__provincias()
	{
		$pais = $this->get_param('pais', 'post');
		
		$provincias = catalogo::consultar('etiquetas', 
										'provincias', 
										array('pais' => $pais)
										);
//		foreach ($provincias as $id => $provincia){
//			
//			$provincias[$provincia['ID']] = utf8_encode($provincia['DESC']);
//		}
		
		$this->render_raw_json($provincias);
	}
	
	function accion__localidades()
	{
		$provincia = $this->get_param('provincia', 'post');
		$localidad = $this->get_param('localidad', 'post');
		
		$parametros = array('provincia_id' => $provincia, 'localidad' => $localidad);
		
		$localidades = catalogo::consultar('etiquetas', 'localidades', $parametros);
		$this->render_raw_json($localidades);
	}
}
?>