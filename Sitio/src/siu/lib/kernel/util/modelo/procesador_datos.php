<?php

namespace kernel\util\modelo;
use kernel\acceso\error_kernel_seguridad;
use kernel\kernel;

/**
 * Procesa un resultset, aplicando acciones por medio de decoradores de fila.
 */
class procesador_datos implements \ArrayAccess, \Iterator
{
	/**
	 * @var array
	 */
	protected $decoradores;
	protected $datos;

	protected $dirty; //quedan procesamientos pendientes;

	public function __construct(&$datos)
	{
		$this->datos = $datos;
		$this->decoradores = array();
		$this->dirty = false;
	}

	/**
	 * Agrega un decorados. Se ejecutan en el orden en el que se agregan.
	 * @param \kernel\util\modelo\decorador_fila $decorador
	 */
	public function agregar_decordador(decorador_fila $decorador)
	{
		$this->decoradores[] = $decorador;
		$this->dirty = true;
	}

	/**
	 * Busca en el recordset, una fila que tenga en valor_id en la columna_id.
	 * Antes de ello, se ejecutan los decordadores.
	 * @param string $columna_id
	 * @param string $valor_id
	 * @throws error_kernel_seguridad
	 * @return array
	 */
	public function recuperar_fila($columna_id, $valor_id)
	{
		foreach ($this->datos as &$registro) {
			if ($this->dirty) {
				foreach ($this->decoradores as $dec)
					$dec->procesar_fila($registro);
			}
			if ($registro[$columna_id] == $valor_id) {
				return $registro;
			}
		}
		kernel::log()->add_debug("Opcion invalida - No se encontro la fila $columna_id, $valor_id", $this->datos);
		throw new  error_kernel_seguridad("Opcion invalida");
	}

	public function get_datos()
	{
		$this->procesar();
		return $this->datos;
	}


	/**
	 * Ejecuta todos los decoradores en el orden en que se especifican y los limpia
	 */
	protected function procesar()
	{
		if (!$this->dirty)
			return;
		foreach ($this->datos as &$registro) {
			foreach ($this->decoradores as $dec)
				$dec->procesar_fila($registro);
		}

		$this->decoradores = array();

		$this->dirty = false;
	}

	/**
	 * Ejecuta todos los decoradores sobre una fila y los limpia.
	 * @param $clave string de la fila a procesar
	 */
	protected function procesar_fila($clave)
	{
		if (!$this->dirty)
			return;
		foreach ($this->decoradores as $dec)
			$dec->procesar_fila($this->datos[$clave]);
		$this->decoradores = array();
		$this->dirty = false;
	}


	/*------------------------------------------------------------
	 *
	 * Interface ArrayAcces
	 *
	 *------------------------------------------------------------*/
	public function offsetExists($offset)
	{
		return isset($this->datos[$offset]);
	}

	public function offsetGet($offset)
	{
		if ($this->dirty) { //por si acceden a un componente
			$this->procesar();
		}
		return isset($this->datos[$offset]) ? $this->datos[$offset] : null;
	}

	public function offsetSet($offset, $value)
	{
		if (is_null($offset)) {
			$this->datos[] = $value;
		} else {
			$this->datos[$offset] = $value;
		}
	}

	public function offsetUnset($offset)
	{
		unset($this->datos[$offset]);
	}

	/*------------------------------------------------------------
	 *
	 * Interface Iterator
	 *
	 *------------------------------------------------------------*/
	function rewind()
	{
		if ($this->dirty) { //si acceden con un foreach
			$this->procesar();
		}
		return reset($this->datos);
	}

	function current()
	{
		return current($this->datos);
	}

	function key()
	{
		return key($this->datos);
	}

	function next()
	{
		return next($this->datos);
	}

	function valid()
	{
		return key($this->datos) !== null;
	}


	public function __toString()
	{
		return (string)$this->datos;
	}


}

?>
