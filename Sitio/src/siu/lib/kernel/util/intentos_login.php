<?php
namespace kernel\util;
use kernel\kernel;
use kernel\util\cache\admin_cache;

class intentos_login
{
	const prefijo = 'intentos_login__';
	const ventana_errores = 900;	//10 minutos
	static $errores;
	
	static function usar_recaptcha($identificador_usuario)
	{
		if(isset(self::$errores)){
			$err = self::$errores;
		} else {
			$persis = admin_cache::instancia(admin_cache::tipo_memoria);
			$clave = self::prefijo . $identificador_usuario;
			if ($persis->existe($clave)){
				$err = $persis->buscar($clave);
			} else {
				$err = 0;
			}
		}
		$intentos = kernel::proyecto()->get('intentos_login_captcha');
		if ($err >= $intentos) {
			return true;
		}
		return false;
	}
	
	static function controlar_recaptcha($identificador_usuario)
	{
		if(isset(self::$errores)){
			$err = self::$errores;
		} else {
			$persis = admin_cache::instancia(admin_cache::tipo_memoria);
			$clave = self::prefijo . $identificador_usuario;
			if ($persis->existe($clave)){
				$err = $persis->buscar($clave);
			} else {
				$err = 0;
			}
		}
		$intentos = kernel::proyecto()->get('intentos_login_captcha');
        //Si la cantidad de intentos fallidos es igual o mayor la cantidad establecida hay que controlar el captcha
		if ($err >= $intentos) {
			return true;
		}
		return false;
	}
	
	static function error($identificador_usuario)
	{
		$persis = admin_cache::instancia(admin_cache::tipo_memoria);
		$clave = self::prefijo . $identificador_usuario;
		if($persis->existe($clave)){
			$intentos = $persis->buscar($clave);
			$intentos++;
			$persis->guardar($clave, $intentos, self::ventana_errores);
		} else {
			$persis->guardar($clave, 1, self::ventana_errores);
		}
	}
	
	static function eliminar($identificador_usuario)
	{
		$persis = admin_cache::instancia(admin_cache::tipo_memoria);
		$clave = self::prefijo . $identificador_usuario;
		$persis->eliminar($clave);
	}
}

?>
