<?php
namespace kernel\nucleo;

use kernel\kernel;
use kernel\error_kernel;
use kernel\interfaz\renderer;
use kernel\util\u;

set_time_limit(15);
register_shutdown_function(array('\kernel\nucleo\acceso_web', 'shutdown'));
set_error_handler(array('\kernel\nucleo\acceso_web', 'custom_error_handler'));

class acceso_web
{
    static protected $controlador;
	// Cuando se envía una respuesta rápida (en gral un arreglo json) se da
	// por finalizado el request cambiando este flag a true
	static protected $request_finalizado = false;
	static protected $redireccionando = false;
	
    static function procesar()
    {
		try{
			try {
				self::check_ssl();
				self::procesar_request();
				kernel::log()->cronometro()->marcar('fin request');
				self::procesar_response();
				kernel::log()->cronometro()->marcar('fin response');
			} catch (\kernel\acceso\error_kernel_seguridad $e) {
				kernel::log()->add_error($e, false);
				kernel::renderer()->set_error($e, -1);
				self::procesar_response();
			} catch (\kernel\error_kernel_notificaciones $e) {
				kernel::log()->add_error($e, false);
				kernel::renderer()->set_error($e, -4);
				self::procesar_response();
			} catch (\kernel\error_kernel_usuario $e) {
				kernel::log()->add_error($e, false);
				kernel::renderer()->set_error($e, $e->get_codigo_response());
				self::procesar_response();
			} catch (error_kernel $e) {
				kernel::log()->add_error($e, false);
				if (kernel::proyecto()->get_produccion()) {
					$et = new error_kernel(kernel::traductor()->trans('error_indefinido'));
					kernel::renderer()->set_error($et, -1);
				} else {
					kernel::renderer()->set_error($e, -1);
				}
				self::procesar_response();
			} catch (\Exception $e) {
				kernel::log()->add_error($e, false);
			}
		} catch (\Exception $e) {
			kernel::log()->add_error($e, false);
		}
		kernel::log()->fin();
		kernel::log()->guardar();
	}

	static function check_ssl()
	{
		if ((kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_NONE) || (!kernel::proyecto()->get_ssl_redirigir_ssl())) {
			return;
		}
		
		if (!isset($_SERVER['HTTPS']) || $_SERVER["HTTPS"] != "on") {
			kernel::log()->add_info('REDIRECCIÓN SSL', array());
			kernel::log()->cronometro()->marcar('fin response');
			kernel::log()->fin();
			kernel::log()->guardar();
			// se intentó acceder a un servicio ajax sin usar https
			if (! kernel::request()->isXmlHttpRequest()) {
				header("Location: ".kernel::url()->self(true));
			}
			
			die;
		}
	}
	
    /*
     *  throw new nuevo_request('index');
     * 		redireccion de login
     * 		redireccion de error_seguridad
     */

    static function procesar_request()
    {
        try {
			// convertir encoding si el request es ajax y el encoding del proyecto
			// es latin1
			$proy_latin1 = strtolower(kernel::proyecto()->get_encoding()) == 'iso-8859-1';
			$content_type_utf8 = isset($_SERVER['CONTENT_TYPE']) && strpos($_SERVER['CONTENT_TYPE'], 'UTF-8') !== false;
			$es_ajax = kernel::request()->isXmlHttpRequest();
			 if ($proy_latin1 && ($content_type_utf8 || $es_ajax)) {
				 $_POST = self::array_a_latin1($_POST);
			 }

			//autenticacion
	        kernel::login_manager()->autenticar();
	        //setea kernel::persona()

	        // autorizacion
	        //estaria bueno algo asi
	        //

	        self::$controlador = kernel::ruteador()->get_controlador();
            self::$controlador->procesar_accion();
        } catch (nuevo_request $e) {
            try {
				self::$redireccionando = true;
                kernel::log()->add_info('REDIRECCIÓN', $e->get_url());
				$url = $e->get_url();
				if (kernel::request()->isXmlHttpRequest()) {
					kernel::renderer()->set_redireccion($e);
				} else {
					kernel::log()->cronometro()->marcar('fin response');
					kernel::log()->fin();
					kernel::log()->guardar();
					header("Location: $url");
					exit();            
				}
            } catch (nuevo_request $e) {
				self::$redireccionando = false;
                $operacion2 = $e->get_operacion();
                $accion2 = $e->get_accion();
                throw new \Exception("Error: se dispararon dos nuevo_request. 1: ($operacion>$accion) - 2: ($operacion2>$accion2)");
            }
        } catch (finalizador_request $e) {
			self::$request_finalizado = true;
		}
    }

    static function procesar_response()
    {
		if (! self::$request_finalizado) {
			kernel::renderer()->procesar();
		}
    }

	static function array_a_latin1($arreglo)
	{
		$salida = array();
		foreach ($arreglo as $clave => $valor) {
			if (is_array($valor)) {
				$salida[$clave] = self::array_a_latin1($valor);
			} elseif (is_string($valor)) {
				$salida[$clave] = utf8_decode($valor);
			} else {
				$salida[$clave] = $valor;
			}
		}		
		return $salida;
	}
	
	//--------------------------------------------------------
	// Manejo de errores
	//--------------------------------------------------------

	static function shutdown()
	{
	// Hay que agregar esto para separar timeout de fatal error
		// se agrega el flag redireccionando para el caso de que se haga una 
		// redirección y que no se llegue a guardar el log
		if ( !self::$redireccionando && !kernel::log()->esta_guardado()) {
			kernel::log()->add_error(new error_kernel('SHUTDOWN'));
			kernel::log()->guardar();
		}
	}

	static function custom_error_handler($errno, $errstr, $errfile, $errline)
	{
		$errortype = array (
					E_ERROR              => 'Error',
					E_WARNING            => 'Warning',
					E_PARSE              => 'Parsing Error',
					E_NOTICE             => 'Notice',
					E_CORE_ERROR         => 'Core Error',
					E_CORE_WARNING       => 'Core Warning',
					E_COMPILE_ERROR      => 'Compile Error',
					E_COMPILE_WARNING    => 'Compile Warning',
					E_USER_ERROR         => 'User Error',
					E_USER_WARNING       => 'User Warning',
					E_USER_NOTICE        => 'User Notice',
					E_STRICT             => 'Runtime Notice',
					E_RECOVERABLE_ERROR  => 'Catchable Fatal Error',
					//E_DEPRECATED		 => 'Deprecated'
			);
		if($errno==E_STRICT){
			return true;
		}

		// Log guardo en el LOG
		$tipo= isset($errortype[$errno]) ? strtoupper ($errortype[$errno]) : 'Unkown error';
		$msg = "$tipo\nArchivo: $errfile\nLinea: $errline\n$errstr";
		if (kernel::log()->esta_activo()) {
			kernel::log()->add_php_warning($msg);
			if (ini_get("display_errors")) {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
}
?>