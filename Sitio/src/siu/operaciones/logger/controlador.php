<?php
namespace siu\operaciones\logger;
use kernel\kernel;
use kernel\util\manejador_archivos;
use siu\extension_kernel\log;

class controlador extends \siu\extension_kernel\controlador_g3w2
{
    function modelo()
    {
        return null;
    }
    
    function ini()
    {
		if (kernel::proyecto()->get_produccion()) {
			die();
		}
        kernel::log()->set_activo(false);
    }
    
    function accion__index()
    {
    }
    
    function accion__ajax_info_log()
    {
        $id = kernel::url()->get_param(0);
		$data = log::get_resumen($id);
		$data['ua'] = \siu\guarani::get_ua_id();
		$data['usuario'] = kernel::sesion()->get_id_login();
		$this->render_raw_json($data);
    }
    
    function accion__limpiar_logs()
    {
        $path = kernel::proyecto()->get_dir_log();
        manejador_archivos::eliminar_directorio($path, false, true);
        $this->nuevo_request('logger', 'index');
    }
    
    function accion__elegir_log()
    {
		$archivo_log = kernel::url()->get_param(0);
        $pagelet = $this->vista()->pagelet('info_log');
        $pagelet->set_estado_info('log_seleccionado');
		
		$dir_log = kernel::proyecto()->get_dir_log();
        $path = $dir_log.'/'.$archivo_log.'.log';
        $pagelet->set_archivo_log($path);
		
        kernel::renderer()->add($pagelet);
    }
	
	function accion__ajax_elegir_log()
	{
		$archivo_log = kernel::url()->get_param(0);
		$dir_log = kernel::proyecto()->get_dir_log();
        $path = $dir_log.'/'.$archivo_log.'.log';
		$data = array('content' => mb_convert_encoding(file_get_contents($path), 'UTF-8'));
		$this->render_raw_json($data);
	}
}

?>
