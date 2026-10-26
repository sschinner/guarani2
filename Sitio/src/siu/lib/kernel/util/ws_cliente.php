<?php
namespace kernel\util;

use kernel\kernel;
use kernel\error_kernel;

/**
 *Basado en toba_servicio_web_cliente de toba.
 */
class ws_cliente
{
	protected $wsf;
	protected $opciones_conf;
	protected $id_servicio;

	
	function __construct($id_servicio, $opciones) 
	{
		$this->opciones_conf = $opciones;
		$this->id_servicio = $id_servicio;
	}
	
	function configurar($opciones_runtime = array()){
		$opciones = array_merge($this->opciones_conf, $opciones_runtime);

		//--2- Arma el servicio indicando certificado del server y clave privada del cliente
		$security_token = self::get_ws_token($opciones);
		if (isset($security_token)) {
			$seguridad = array(
					"sign" => true,
					"encrypt" => true,
					"algorithmSuite" => "Basic256Rsa15",
					"securityTokenReference" => "IssuerSerial");
			
			$policy = new \WSPolicy(array("security" => $seguridad));
			$opciones['policy'] = $policy;
			$opciones['securityToken'] = $security_token;
		}

		//-- Mezcla con las opciones recibidas y crea el objeto
		if (! isset($opciones['url'])) {
			throw new toba_error_def("Debe indicar la URL destino en el campo 'url'");			
		}else{
			$opciones['to'] = $opciones['url'];
			unset($opciones['url']);
		}

		kernel::log()->add_info("Servicio web","Configurando servicio $this->id_servicio. Opciones:<br>". var_export($opciones, true));
		$this->wsf = new \WSClient($opciones);
	}
	
	/**
	 * @return WSClient
	 */
	function wsf()
	{
		return $this->wsf;	
	}
	
	/**
	 * Envia un mensaje al servicio web y espera la respuesta
	 * @param toba_servicio_web_mensaje $mensaje
	 * @return toba_servicio_web_mensaje
	 */
	function request(ws_mensaje $mensaje)
	{
		try {
			$message = $this->wsf->request($mensaje->wsf());
			return new ws_mensaje($message);
		} catch (\WSFault $e) {
				throw new error_kernel("Soap Fault: ". $e->Reason . " Detail: ". $e->Detail);
		} catch (\Exception $e) {
				throw new error_kernel($e->getMessage(). " Opciones: " . $this->opciones_conf . " Respuesta: " . $this->wsf->getLastResponseHeaders());
		}
	}

	/**
	 *Envio de mensaje asinc.
	 * @param \ws_mensaje $mensaje
	 * @throws error_kernel 
	 */
	function send(\ws_mensaje $mensaje)
	{
		try {
			$this->wsf->send($mensaje->wsf());
		} catch (\WSFault $e) {
				throw new error_kernel("Soap Fault: ". $e->Reason . " Detail: ". $e->Detail);
		} catch (\Exception $e) {
				throw new error_kernel($e->getMessage(). " Opciones: " . $this->opciones . " Respuesta: " . $this->wsf->getLastResponseHeaders());
		}
	}
	

	 /**
	 * Devuelve un objeto WSF con la configuracion de certificados ssl existente o null
	 * @param array $opciones de seguridad
	 * @return WSSecurityToken 
	 */
	protected static function get_ws_token($opciones)
	{
		if(!isset($opciones['seguro']) || $opciones['seguro']){
			if(!(isset($opciones['clave_publica']) && isset($opciones['clave_privada'])&& isset($opciones['certificado_servicio']))){
				throw new error_kernel("Error configuracion servicios web: El servicio esta configurado para incluir firma (explicitamente o por omision), pero no se especifcan los certificados");
			}
		}else {
			kernel::log()->add_info('Opciones ws', 'Seguridad deshabilitada');
			return null;
		}

		$security_token = null;
		$dir_instalacion = "";// \siu\bootstrap::get_dir_instalacion();
		$mi_cert = $dir_instalacion.$opciones['clave_publica'];
		$mi_clave = $dir_instalacion.$opciones['clave_privada'];
		$cert_servicio = $dir_instalacion. $opciones['certificado_servicio'];

		//Cargo las claves y armo el objeto WSF
		if (! file_exists($mi_clave)) {
			throw new error_kernel("El archivo $mi_clave no existe");
		}			
		$clave_cliente = ws_get_key_from_file($mi_clave);

		if (! file_exists($mi_cert)) {
			throw new error_kernel("El archivo $mi_cert no existe");
		}			
		$cert_cliente = ws_get_cert_from_file($mi_cert);

		if (! file_exists($cert_servicio)) {
			throw new error_kernel("El archivo $cert_servicio no existe");
		}			
		$cert_server = ws_get_cert_from_file($cert_servicio);
		$security_token = new \WSSecurityToken(array("privateKey" => $clave_cliente,		
											"receiverCertificate" => $cert_server,	
											"certificate" 		=> $cert_cliente	
											)
					);	
		return $security_token;
	}
	
}
?>