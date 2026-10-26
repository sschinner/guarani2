<?php

namespace siu\modelo\autenticacion;

use kernel\acceso\error_kernel_login;
use kernel\error_kernel;
use kernel\kernel;
use kernel\nucleo\nuevo_request;
use kernel\util\servicios_externos;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login;
use siu\errores\error_guarani_login_externo;
use siu\guarani;


class auth_cuenta_ext extends auth_con_sesion{

	protected $error;

	/**
	 * Autentica en base al request, y retorna si tuvo exito o no.
	 * @return boolean
	 */
	public function autenticar()
	{
		$proveedor = $_GET['f'];
		try{
			$url_procesar = $this->get_url_procesar($proveedor);
			$datos = $this->autenticar_proveedor($proveedor, $url_procesar);

			$persona = $this->get_clase_usuarios()->autenticar_login_externo($datos);

			return $persona;

		}catch (error_guarani_login $e){
			kernel::log()->add_error($e);
			if($e->getCode() == -1){
				$this->error = 'login.errores.cuenta_externa_invalida';
			}else {
				$this->error = $e->get_mensaje();
			}
		}
		catch (error_kernel $e){
			kernel::log()->add_error($e);
			$this->error = 'autenticacion.cuenta_externa.error';
		}
		return false;
	}

	public function obtener_datos_cuenta($proveedor, $url_procesar)
	{
		$datos = $this->autenticar_proveedor($proveedor, $url_procesar);
		return $datos;
	}

	public function logout()
	{

	}

	/**
	 * Retorna un arreglo con datos necesarios para renderizar este tipo de autenticacion. Queda a cargo del cliente
	 * la visualizacion
	 * @return array
	 */
	public function get_modelo()
	{
		$modelo = array();

		$modelo['proveedores'] = array();
		foreach ($this->conf['proveedores'] as $proveedor_id => $proveedor) {
			$icono = isset($proveedor['icono'])? $proveedor['icono']: 'img/login/openid.png';
			$datos_proveedor = array(
				'id' => $proveedor_id,
				'url' => $this->get_url_procesar($proveedor_id),
				'icono' => kernel::vinculador()->vinculo_recurso($icono)
			);
			$modelo['proveedores'][] = $datos_proveedor;
		}

		$modelo['error'] = isset($this->error)? $this->error:null;
		return $modelo;
	}


	protected function autenticar_proveedor($proveedor_id, $url_procesar)
	{
		if(!isset($this->conf['proveedores'][$proveedor_id])){
			throw new error_guarani("El servicio $proveedor_id no está configurado como cuenta externa");
		}
		$conf_proveedor = $this->conf['proveedores'][$proveedor_id];

		$se = new servicios_externos();

		if($conf_proveedor['tipo'] == 'openid'){
			$datos = $se->openid_mail($conf_proveedor, $url_procesar);
		}else if ($conf_proveedor['tipo'] == 'oauth2'){
			$datos = $se->oauth2_mail($conf_proveedor, $url_procesar);
		}else{
			throw new error_kernel_login('No se encuentra como manejar al servicio. De que "tipo" es?');
		}
		$datos['proveedor'] = $proveedor_id;
		return $datos;
	}


	/**
	 * @param $proveedor_id
	 * @return string
	 */
	protected function get_url_procesar($proveedor_id)
	{
		return kernel::vinculador()->crear_sin_chequeo('acceso', 'index',  array('auth' => $this->get_id(), 'f' => $proveedor_id)); // . "&auth=openid&f=$proveedor";
	}
}