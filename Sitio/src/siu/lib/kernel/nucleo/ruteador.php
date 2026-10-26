<?php

namespace kernel\nucleo;

use kernel\kernel;
use kernel\error_kernel;
use kernel\acceso\error_kernel_seguridad;
use kernel\util\u;
/**
 * Determina cual es la operacion / accion a procesar
 *
 * @todo control seguridad entrada
 */
class ruteador
{
    const MAX_LENGHT_OPERACION = 30;
    const MAX_LENGHT_ACCION = 30;

    const SSL_ALCANCE_ALL = 'all';
    const SSL_ALCANCE_NONE = 'none';

    protected $operacion;
    protected $accion;

    /**
     *
     * @return \kernel\nucleo\controlador
     */
    function get_controlador($operacion = false, $accion = false)
    {
        $this->operacion = $this->resolver_operacion($operacion);
        if (! $this->tiene_permiso_acceso($this->operacion)) {
			$this->operacion_invalida();
		}
		
        $clase_control = "operaciones\\{$this->operacion}\\controlador";
		/* @var $controlador \kernel\nucleo\controlador */
        $controlador = kernel::localizador()->instanciar($clase_control);
        $this->resolver_accion($accion);
        $controlador->set_accion($this->accion);
		
		$clase_vista = $controlador->get_clase_vista();
        $vista = kernel::localizador()->instanciar("operaciones\\{$this->operacion}\\$clase_vista");

        $controlador->configurar($vista);
        return $controlador;
    }

    protected function puede_acceder($operacion)
    {
        return 
            kernel::persona()->perfil()->existe_operacion($operacion) || $operacion == 'logger';
    }
	
	protected function existe_operacion($operacion)
	{
		$existe = kernel::persona()->perfil()->existe_operacion($operacion);
		$es_logger = $operacion == 'logger';
		
		return $existe || $es_logger;
	}
	
	protected function tiene_permiso_acceso($operacion)
	{
		$es_logger = $operacion == 'logger';
		if ($es_logger) {
			return true;
		}
        return kernel::persona()->perfil()->get_operacion_activa($operacion);
	}
    
	protected function redirigir_home()
	{
		$perfil = kernel::persona()->perfil();
		$op_x_defecto = $perfil->get_parametro('index');
		throw new nuevo_request($op_x_defecto, 'index');
	}
	
	function redirigir_login()
	{
		$url = kernel::url()->self();
		$op_login = kernel::persona()->perfil()->get_parametro('login');
		$vinculo = kernel::vinculador()->crear($op_login, 'login',
            array('ref' => $url),
            array(
		        'ssl' => (kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_ALL)
            )
        );
		
		$req = new nuevo_request();
		$req->set_url($vinculo);
		throw $req;
	}
	
    protected function resolver_operacion($operacion)
    {
        if ($operacion !== false) {
            return $operacion;
        } else {
            if (empty($_GET['__o'])) {
                return kernel::persona()->perfil()->get_parametro('index');
            } else {
                $url = u::sanitize($_GET['__o'], 'php', self::MAX_LENGHT_OPERACION);
                
				try {
					return kernel::persona()->perfil()->get_id_operacion_from_url($url);
				} catch (\Exception $e) {
					kernel::log()->add_info($e->getMessage(), $url);
					$this->operacion_invalida();
					
				}
            }
        }
    }
	
	protected function operacion_invalida()
	{
		if (! kernel::sesion()->abierta()) {
			$this->redirigir_login();
		} else {
			$this->redirigir_home();
		}	
	}

    protected function resolver_accion($accion)
    {
        if ($accion !== false) {
            $this->accion = $accion;
        } else {
            if (!isset($_GET['__a'])) {
                $this->accion = 'index';
            } else {
                $this->accion = u::sanitize($_GET['__a'], 'php', self::MAX_LENGHT_ACCION);
            }
        }
    }

    function get_id_operacion()
    {
        return (string)$this->operacion;
    }
    
    function get_accion()
    {
        return $this->accion;
    }
        
}

?>
