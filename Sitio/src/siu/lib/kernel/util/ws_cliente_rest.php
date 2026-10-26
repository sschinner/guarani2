<?php
namespace kernel\util;



class ws_cliente_rest
{
	protected $guzzle;
	protected $opciones_conf;
	protected $id_servicio;

	function __construct($opciones)
	{
		$this->opciones_conf = $opciones;
	}

	/**
	 * @param array $opciones_runtime
	 * @return \GuzzleHttp\Client()
	 */
	function guzzle($opciones_runtime = array())
	{

		if (! isset($this->guzzle)) {
			$opciones = array_merge($this->opciones_conf, $opciones_runtime);

			$this->guzzle = new \GuzzleHttp\Client($opciones);

		}
		return $this->guzzle;	
	}
	/**
	 * Uso ejemplo
	 *
	 * $client = kernel::proyecto()->get_ws_cliente('test');
	 * $res = $client->get('personas');
	 * echo $res->getStatusCode();           // 200
	 * echo $res->getHeader('content-type'); // 'application/json; charset=utf8'
	 * echo $res->getBody();
	 */

}
