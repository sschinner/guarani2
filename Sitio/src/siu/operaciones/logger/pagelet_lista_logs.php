<?php
namespace siu\operaciones\logger;

use kernel\kernel;
use \kernel\interfaz\pagelet;
use kernel\util\manejador_archivos;
use kernel\util\vinculador;

/** 
 * 
 */
class pagelet_lista_logs extends pagelet
{
    public function get_nombre()
    {
        return 'lista_logs';
    }
    
    public function get_js_files()
    {
        $url = kernel::vinculador()->vinculo_recurso("js/filtro_lista.js");
        return array_merge(array($url), parent::get_js_files());
    }
    
    public function prepare()
    {
        $dir_log = kernel::proyecto()->get_dir_log();
        $archivos = manejador_archivos::get_archivos_directorio($dir_log);
		rsort($archivos);
        $this->data = array();
        foreach ($archivos as $archivo) {
			$base = basename($archivo, '.log');
			$mes = substr($base, 0, 4) . '/' . substr($base, 4, 2) . '/' . substr($base, 6, 2);
			$hora = substr($base, 9, 2) . ':' . substr($base, 11, 2) . ':' . substr($base, 13, 2);
			$nombre = "$mes - $hora";
			$archivo = str_replace('/', vinculador::TRANSFORMADOR_BARRA, $archivo);
			$archivo = str_replace('\\', vinculador::TRANSFORMADOR_BARRA, $archivo);
			$this->data[] = array(
                'url' => kernel::vinculador()->crear_sin_chequeo("logger/elegir_log/$base"),
                'nombre' => $nombre
            );
        }
    }
}

?>
