<?php
namespace siu\extension_kernel;

use kernel\kernel;
use siu\errores\error_guarani;
use kernel\util\cache\admin_cache;

class log extends \kernel\util\log
{
	const CATALOGO_MEDIO_DB = 'db';
	const CATALOGO_MEDIO_MEMCACHE = 'memoria';
	const CATALOGO_MEDIO_SESSION = 'sesion';
	const CATALOGO_MEDIO_ARCHIVO = 'archivo';
	
	const CATALOGO_ACCION_LEER = 'leer';
	const CATALOGO_ACCION_GUARDAR = 'guardar';
	const CATALOGO_ACCION_INVALIDAR = 'invalidar';
	
	private $info_catalogo = array();
	private $info_controles = array();
	
	function acceso_catalogo($clase, $metodo, $medio, $accion, $tiempo)
	{
		if(($medio != self::CATALOGO_MEDIO_DB) &&
			($medio != self::CATALOGO_MEDIO_MEMCACHE) &&
			($medio != self::CATALOGO_MEDIO_ARCHIVO) &&
			($medio != self::CATALOGO_MEDIO_SESSION)) {
			throw new error_guarani('LOG: medio incorrecto: ' . $medio);
		}
		if(($accion != self::CATALOGO_ACCION_GUARDAR) &&
			($accion != self::CATALOGO_ACCION_LEER) &&
			($accion != self::CATALOGO_ACCION_INVALIDAR)) {
			throw new error_guarani('LOG: accion incorrecta ' . $accion);
		}
		$acceso['clase'] = $clase;
		$acceso['metodo'] = $metodo;
		$acceso['medio'] = $medio;
		$acceso['accion'] = $accion;
		$acceso['tiempo'] = $tiempo;
		$this->info_catalogo[] = $acceso;
	}
	
	function ejecutar_control($punto, $control, $comportamiento, $medio, $resultado, $mensaje, $tiempo)
	{
		$cc['punto'] = $punto;
		$cc['control'] = $control;
		$cc['comportamiento'] = $comportamiento;
		$cc['medio'] = $medio;
		$cc['resultado'] = $resultado;
		$cc['mensaje'] = $mensaje;
		$cc['tiempo'] = $tiempo;
		$this->info_controles[] = $cc;		
	}
	
	function get_medio($tipo_cache)
	{
		switch($tipo_cache) {
			case admin_cache::tipo_memoria :
				return self::CATALOGO_MEDIO_MEMCACHE;
				break;
			case admin_cache::tipo_sesion :
				return self::CATALOGO_MEDIO_SESSION;
				break;
			case admin_cache::tipo_archivo :
				return self::CATALOGO_MEDIO_ARCHIVO;
				break;
			default:
				throw new error_guarani('LOG: medio incorrecto');
		}
	}
	
	function generar_resumen_extendido()
	{
		$salida = "";
		foreach($this->info_catalogo as $acceso){
			$salida .= "--REXCAT_C<{$acceso['clase']}>".
						"MET<{$acceso['metodo']}>".
						"MED<{$acceso['medio']}>".
						"A<{$acceso['accion']}>".
						"T<{$acceso['tiempo']}>--\n";
		}
		foreach($this->info_controles as $control){
			$salida .= "--REXCON_P<{$control['punto']}>".
						"CC<{$control['control']}>".
						"COMP<{$control['comportamiento']}>".
						"MED<{$control['medio']}>".
						"RES<{$control['resultado']}>".
						"TIEMPO<{$control['tiempo']}>".
						"MENS<{$control['mensaje']}>--\n";
		}
		return $salida;
	}
	
	static function get_resumen($id)
	{
		$path = kernel::proyecto()->get_dir_log() . '/' . $id . '.log';
		//$log = mb_convert_encoding(file_get_contents($this->path), 'UTF-8');
		$log = file_get_contents($path);
		$match = array();
		$ereg = "/F<(.*?)>:E<(.*?)>:W<(.*?)>:T<(.*?)>:M<(.*?)>/";
		preg_match_all($ereg, $log, $match,PREG_SET_ORDER);
		if(isset($match[0]) && is_array($match[0]) && isset($match[0][0])) {
			$data = array(	'parse' => true,
							'end'=>$match[0][1],
							'exception'=>$match[0][2],
							'warning'=>$match[0][3],
							'time'=>$match[0][4],
							'memory'=>$match[0][5],
					);
			// CATALOGO
			$match2 = array();
			$ereg = "/REXCAT_C<(.*?)>MET<(.*?)>MED<(.*?)>A<(.*?)>T<(.*?)>/";
			preg_match_all($ereg, $log, $match2,PREG_SET_ORDER);
			$accesos = array();
			foreach($match2 as $acc) {
				$accesos[] = array(	'clase' => $acc[1] ,
									'metodo' => $acc[2],
									'medio' => $acc[3],
									'accion' => $acc[4],
									'tiempo' => $acc[5]);
			}
			$data['catalogo'] = $accesos;
			// CONTROLES
			$match2 = array();
			$ereg = "/REXCON_P<(.*?)>CC<(.*?)>COMP<(.*?)>MED<(.*?)>RES<(.*?)>TIEMPO<(.*?)>MENS<(.*?)>/";
			preg_match_all($ereg, $log, $match2,PREG_SET_ORDER);
			$accesos = array();
			$controles = array();
			foreach($match2 as $acc) {
				$controles[] = array(	'punto' => $acc[1] ,
									'control' => $acc[2],
									'comportamiento' => $acc[3],
									'medio' => $acc[4],
									'resultado' => $acc[5],
									'tiempo' => $acc[6],
									'mensaje' => $acc[7]);
			}
			$data['controles'] = $controles;
		} else {
			$data = array(	'parse'=>false );
		}
		return $data;		
	}	
}


?>