<?php
namespace kernel\nucleo;
use kernel\util\vinculador;

class acceso_recurso
{
	static function procesar()
	{
        $var = filter_input(INPUT_SERVER, 'PATH_INFO', FILTER_SANITIZE_STRING);
        
		$dir = pathinfo($var, PATHINFO_DIRNAME);
        $file = pathinfo($var, PATHINFO_FILENAME);
		$file_name = pathinfo($var, PATHINFO_BASENAME);
		$file_type = pathinfo($var, PATHINFO_EXTENSION);
		$pl_nombre = pathinfo($dir, PATHINFO_BASENAME);

		if (strpos($dir, vinculador::PARAM_IGNORED_RECURSOS) !== false) {
			$dir = str_replace('/'.vinculador::PARAM_IGNORED_RECURSOS, '', $dir);
		}

        $ns = isset($_GET['ns']) ? $_GET['ns'] : false;

		if ($file_type == 'js') {
			header('Content-type: application/javascript');
            if (strpos($var, '_comun/pagelets') !== false) {
                $p = recursos::get_pl_js('_comun/pagelets', $pl_nombre, $file);
            } else if ($dir == '/js') { // se está tratando de consumir algo de la carpeta www/js
                $p = recursos::get_path_js("$file.js", $ns);
            }
            else {
				$op_nombre = pathinfo($dir, PATHINFO_DIRNAME);
                $p = recursos::get_pl_js($op_nombre, $pl_nombre, $file);
            }
		} else if ($file_type == 'css') {
			header('Content-type: text/css');
			if (strpos($var, '_comun/pagelets') !== false) {
				$p = recursos::get_pl_css($ns, '_comun/pagelets', $pl_nombre, $file);
            } else if ($dir == '/css') { // se está tratando de consumir algo de la carpeta www/css
				$p = recursos::get_path_css("$file.css", $ns);
			} else {
				$op_nombre = pathinfo($dir, PATHINFO_DIRNAME);
                $p = recursos::get_pl_css($ns, $op_nombre, $pl_nombre, $file);
            }
		} else { // se asume que es una imagen
			// se hace para soportar subcarpetas
			$full_name = implode('/', array_slice(explode('/', $dir), 2)).'/'.$file_name;
			$p = recursos::get_path_img($full_name, $ns);
			$header_type = ($file_type == 'jpg') ? 'image/jpeg' : "image/$file_type";
			header("Content-type: $header_type");
			
		}
        
        /**
         * @todo Agregar a la consola algo así: guarani --invalidar-cache-recursos
         * que haga que el nrito $rnd cambie y así se puedan refrescar los archivos
         * aunque el sistema se encuentre en producción
         * @todo Agregar método para saber si se está o no en producción
         * @todo investigar mecanismo alternativo con IF-MODIFIED-SINCE: 
         * http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html 14.25
         */
        $rnd = 103; // algo así guarani::get_cache_recurso_key()
//        $es_produccion = kernel::proyecto()->;
        $es_produccion = false;
        $etag = md5($p.$rnd);
        
        if ($es_produccion && isset($_SERVER['HTTP_IF_NONE_MATCH']) && 
                trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
            header("HTTP/1.1 304 Not Modified");
        } else {
            header("Etag: $etag");            
            fpassthru(fopen($p, 'r'));
        }
	}
}

?>