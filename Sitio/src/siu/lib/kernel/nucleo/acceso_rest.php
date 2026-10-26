<?php
namespace kernel\nucleo;

use kernel\error_kernel;
use kernel\kernel;
use kernel\util\configuracion_rest;

set_time_limit(15);
register_shutdown_function(array('\kernel\nucleo\acceso_web', 'shutdown')); //por ahora reutilizo
set_error_handler(array('\kernel\nucleo\acceso_web', 'custom_error_handler'));

class acceso_rest
{
	const CARPETA_REST = '/rest';

	function procesar()
	{
		acceso_web::check_ssl();
		$app = $this->get_libreria_rest();
		$app->procesar();

		kernel::log()->cronometro()->marcar('fin response');
		kernel::log()->fin();
		kernel::log()->guardar();
	}


	public function get_libreria_rest()
	{
		$config = $this->get_configuracion();
		if(isset($config['clase'])){
			kernel::log()->add_debug('REST', 'instanciando a traves de ' . $config['clase']);
			$libreria = kernel::localizador()->instanciar($config['clase'], $config['parametros']);
		}else {
			$libreria = new configuracion_rest($config['parametros']);
		}
		return $libreria->instanciar_libreria();
	}

	protected function get_configuracion()
	{
		$config = kernel::proyecto()->get_ws_config();
		if(!isset($config['ofrecidos']) || !isset($config['ofrecidos']['rest'])){
			throw new error_kernel('No existe la configuracion de servicios web - "servicios_web_config"');
		}
		$servicio = $config['ofrecidos']['rest'];
		if(!$servicio['activo']){
			throw new error_kernel('El servicio REST no se encuentra activo');
		}
		return $servicio;
	}

}
