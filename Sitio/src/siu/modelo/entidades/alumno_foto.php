<?php
namespace siu\modelo\entidades;
use siu\modelo\datos\catalogo;
use kernel\kernel;
use siu\errores\error_guarani;
use siu\guarani;
use kernel\util\manejador_archivos;
use kernel\util\img;
class alumno_foto
{
	const TAMANIO_CHICA = 'chica';
	const TAMANIO_MEDIANA = 'mediana';
	const TAMANIO_GRANDE = 'grande';
	const NUM_CARPETAS = 1000;

	static function importar_foto($nro_inscripcion, $path)
	{
		$id = self::generar_id();
		
		
		$sizes = array(
			'chica'  => array('dim' => 35, 'directorio' => 'chica'),
			'mediana'  => array('dim' => 90, 'directorio' => 'mediana'),
			'grande' => array('dim' => 150, 'directorio' => 'grande'),
		);
		$carpeta = self::generar_carpeta($nro_inscripcion);
		$ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
		$id_imagen = $carpeta . '_' . $id.".$ext";
		
		foreach ($sizes as $size) {
			$dir = kernel::proyecto()->get('imagen_alumno_dir'). '/' . $size['directorio']. '/' . $carpeta;
			manejador_archivos::crear_arbol_directorios($dir);
			$img = img::resize($path, $size['dim']);
			$path_resized = $dir.'/'.$id_imagen;
			img::guardar($img, $path_resized);
		}
		
		self::asociar_imagen($nro_inscripcion, $id_imagen);
	}
	
	static function importar_foto_blob($punto_acceso, $ua, $nro_inscripcion, $blob, $ext)
	{
		$id = self::generar_id();
		
		$sizes = array(
			'chica'  => array('dim' => 35, 'directorio' => 'chica'),
			'mediana'  => array('dim' => 90, 'directorio' => 'mediana'),
			'grande' => array('dim' => 150, 'directorio' => 'grande'),
		);
		$carpeta = self::generar_carpeta($nro_inscripcion);
		$id_imagen = $carpeta . '_' . $id.".$ext";
		$res_blob = img::get_resource_blob($blob, $ext);
		
		
		foreach ($sizes as $size) {
			$dir = kernel::proyecto()->get('imagen_alumno_dir'). '/' . $punto_acceso. '/'. $size['directorio']. '/' . $carpeta;
			manejador_archivos::crear_arbol_directorios($dir);
			img::resize_resource($res_blob['img'], $res_blob['width'], $res_blob['height'], $size['dim']);
			$path_resized = $dir.'/'.$id_imagen;
			img::guardar($res_blob['img'], $path_resized);
		}
		
		self::asociar_imagen($ua, $nro_inscripcion, $id_imagen);
	}
	
	protected static function generar_id()
	{
		return sha1(uniqid(rand(0,100),true));		
	}
	
	protected static function generar_carpeta($nro_inscripcion)
	{
		return md5($nro_inscripcion % self::NUM_CARPETAS);
	}
	
	protected static function asociar_imagen($ua, $nro_inscripcion, $id_imagen)
	{
		$parametros = array();
		$parametros['ua'] = $ua;
		$parametros['nro_inscripcion'] = $nro_inscripcion;
		$parametros['id_imagen'] = $id_imagen;
		catalogo::consultar('persona', 'asociar_foto', $parametros);
	}
	
	static function url_imagen($id_imagen, $tamanio = self::TAMANIO_CHICA)
	{
		if (empty($id_imagen)) {
			switch ($tamanio) {
				case self::TAMANIO_CHICA:
					return kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
				case self::TAMANIO_MEDIANA:
					return kernel::vinculador()->vinculo_recurso('img/iconos/mm_medio.png');
				default:
					return kernel::vinculador()->vinculo_recurso('img/iconos/mm_grande.png');
			}
		} else {
			$punto_acceso = \siu\bootstrap::instancia()->get_id_bloque_acceso();
			$carpeta = substr($id_imagen, 0, 32);
			return kernel::proyecto()->get('imagen_alumno_url')."/$punto_acceso/$tamanio/$carpeta/$id_imagen";	
		}
	}
	/**
	 * Para mandar a Kolla - NO usar ya que la ruta relativa no funcionara si cambia la
	 * url base del alumno.
	 */
	static function url_imagen_relativa_kolla($id_imagen)
	{
//		$punto_acceso = \siu\bootstrap::instancia()->get_id_bloque_acceso();

		if(empty($id_imagen)){
			return 'mm_medio.png';
		}
		$tamanio = self::TAMANIO_MEDIANA;
		$carpeta = substr($id_imagen, 0, 32);
		return "$tamanio/$carpeta/$id_imagen";
	}
}

?>