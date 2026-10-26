<?php
namespace kernel\nucleo;
use kernel\kernel;

/**
 * Carga recursos WWW
 */
class recursos
{
    /**
     * Dirección relativa de las operaciones dentro de un proyecto
     */
    const DIR_OPERACIONES = 'operaciones';
	const DIR_IMG = 'www/img';
	const DIR_CSS = 'www/css';
	const DIR_JS = 'www/js';
    /**
     *
     * @param string $path_relativo path relativo a la carpeta que corresponde a
     * un punto de montaje.
     */
    static function get_full_path($path_relativo, $ns = false)
    {
		return kernel::localizador()->path_recurso($path_relativo, $ns);
    }

	static function get_dir_proyecto_templates()
	{
		return self::DIR_OPERACIONES."/_comun/templates";
	}
	
    static function get_proyecto_template($nombre_tp)
    {
        $path_relativo = self::get_dir_proyecto_templates()."/$nombre_tp";
        $path_completo = self::get_full_path($path_relativo);

        return $path_completo;
    }

	static function get_dir_op($id_op)
	{
		return self::DIR_OPERACIONES."/$id_op";
	}
	
	static function get_dir_img()
	{
		return self::DIR_IMG;
	}
	
	static function get_dir_css()
	{
		return self::DIR_CSS;
	}
	
    static function get_op_template($id_op, $nombre_tp = false)
    {
        $nombre_tp = ($nombre_tp === false) ? 'template.twig' : $nombre_tp;
        $path_relativo = self::DIR_OPERACIONES."/$id_op/$nombre_tp";
        $path_completo = self::get_full_path($path_relativo);

        return $path_completo;
    }

	static function get_dir_pagelet($id_op, $id_pl)
	{
		return self::get_dir_op($id_op)."/$id_pl";
	}
	
    /**
     * Devuelve la ruta completa de un template de un pagelet que se encuentra
     * en una operación
     * @param string $id_op
     * @param string $id_pl
     * @param string $nombre_tp
     * @return string 
     */
    static function get_pl_template($id_op, $id_pl, $nombre_tp)
    {
        $path_relativo = self::get_dir_pagelet($id_op, $id_pl)."/$nombre_tp";
        $path_completo = self::get_full_path($path_relativo);

        return $path_completo;
    }

    static function get_comun_js($id_js)
    {
        $path_relativo = self::DIR_OPERACIONES."/_comun/js/$id_js.js";
        $path_completo = self::get_full_path($path_relativo);
        
        return $path_completo;
    }
    
    static function get_pl_js($id_op, $id_pl, $id_js)
    {
        $path_relativo = self::DIR_OPERACIONES."/$id_op/$id_pl/$id_js.js";
        $path_completo = self::get_full_path($path_relativo);

        return $path_completo;
    }

    static function get_comun_css($id_css)
    {
        $path_relativo = self::DIR_OPERACIONES."/_comun/css/$id_css.css";
        $path_completo = self::get_full_path($path_relativo);
        
        return $path_completo;
    }
    
    static function get_pl_css($id_ns, $id_op, $id_pl, $id_css)
    {
        $path_relativo = self::DIR_OPERACIONES."/$id_op/$id_pl/$id_css.css";
        $path_completo = self::get_full_path($path_relativo, $id_ns);

        return $path_completo;
    }
	
	static function get_path_css($nombre, $ns = false)
	{
		$path_relativo = self::DIR_CSS."/$nombre";
		$path_completo = self::get_full_path($path_relativo, $ns);
		return $path_completo; 
	}
	
	static function get_path_js($nombre, $ns = false)
	{
		$path_relativo = self::DIR_JS."/$nombre";
		$path_completo = self::get_full_path($path_relativo, $ns);
		return $path_completo; 
	}
	
	static function get_path_img($nombre, $ns = false)
	{
		$path_relativo = self::DIR_IMG."/$nombre";
		$path_completo = self::get_full_path($path_relativo, $ns);
		return $path_completo; 
	}
}
?>
