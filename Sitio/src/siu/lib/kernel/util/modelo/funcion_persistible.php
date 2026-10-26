<?php
/**
 * Created by IntelliJ IDEA.
 * User: alejandro
 * Date: 7/8/13
 * Time: 10:34 AM
 * To change this template use File | Settings | File Templates.
 */

namespace kernel\util\modelo;


/**
 * Class funcion_persistible - Persiste una funcion a partir de un objeto y un llamado a una funcion con los parametros
 * y argumentos.
 * @package kernel\util\modelo
 */
class funcion_persistible implements persistible {

	protected $funcion;
	protected $args;

	/**
	 * @param $funcion
	 * @param $args
	 * @internal param \kernel\util\modelo\el $objeto objeto sobre el cual se
	 * @internal param $rs
	 */
	function __construct($funcion, $args)
	 {
		$this->funcion = $funcion;
		$this->args = $args;
	}

	function get_id_unico($sal)
	{
		$claves = array(
			$this->funcion,
			serialize($this->args),
			$sal
		);

		$clave = sha1(implode('#', $claves));
		return $clave;
	}

	function get_parametros_para_guardar()
	{
		return array(
			$this->funcion,
			$this->args);
	}

	/**
	 * @param object $objeto objeto que devuelve lo que se guardo
	 * @param array $parametros_guardados
	 * @return mixed
	 */
	static function regenerar_instancia($objeto, $parametros_guardados)
	{
		$funcion = $parametros_guardados[0];
		$args = $parametros_guardados[1];
		$instancia = call_user_func_array(array($objeto, $funcion), $args);
		return $instancia;
	}
}