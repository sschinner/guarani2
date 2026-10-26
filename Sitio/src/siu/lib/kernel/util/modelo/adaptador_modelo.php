<?php

namespace kernel\util\modelo;

use kernel\error_kernel;
use kernel\kernel;

/**
 * Capa que controla las dependencias entre metodos, y los derechos de entidades
 */
class adaptador_modelo
{
	//Configuraciones---------------
	protected $modelo;
	/**
	 * @var fuente_persistencia
	 */
	protected $fuente_recordsets;
	/**
	 * @var bool
	 */
	protected $controlar_entidades;
	//------------------------------

	//Estado actual-----------------
	/**
	 * @var string
	 */
	protected $operacion_actual;
	/**
	 * @var string
	 */
	protected $accion_actual;
	//------------------------------

	//Otros ------------------------
	protected $tag = "Adaptador Modelo -";
	protected $cache_fila_modelo;

	//------------------------------

	function __construct($objeto, fuente_persistencia $fuente_persistencia,
	                     $operacion_actual, $accion_actual)
	{
		$this->modelo = $objeto;
		$this->fuente_recordsets = $fuente_persistencia;
		$this->operacion_actual = $operacion_actual;
		$this->accion_actual = $accion_actual;

		$this->cache_fila_modelo = array();
	}

	/**
	 * Actualiza la operacion accion actuales en caso de un "redirect" interno.
	 * @param string $operacion_actual
	 * @param string $accion_actual
	 */
	function set_operacion_y_accion($operacion_actual, $accion_actual)
	{
		$this->operacion_actual = $operacion_actual;
		$this->accion_actual = $accion_actual;
	}

	/**
	 * Habilita el control de parametros de tipo entidad en el modelo y vista.
	 */
	function habilitar_control_entidades()
	{
		$this->controlar_entidades = true;
	}

	/**
	 * Recupera la fila codificada
	 * @param string $fila_codificada
	 * @param null $destino Para que operación debe ser el parametro -
	 * si el destino es * se aceptan todos. Por defecto es la accion actual. Puede ser un arreglo
	 * @return array
	 */
	function decodificar_fila($fila_codificada, $destino = null)
	{
		if ($destino === '*') {
			//
		} else if ($destino === null) {
			$destino = array($this->accion_actual);
		} else if (!is_array($destino)) {
			$destino = array($destino);
		}

		if (isset($this->cache_fila_modelo[$fila_codificada])) {
			kernel::log()->add_debug("{$this->tag} Recuperar datos [cache] para '" . print_r($destino, true) . "'", $fila_codificada);
			return $this->cache_fila_modelo[$fila_codificada];
		}
		$datos = $this->decodificar_fila__($fila_codificada, $destino);
		kernel::log()->add_debug("{$this->tag} Recuperar datos para '" . print_r($destino, true) . "' - $fila_codificada ", $datos);
		$this->cache_fila_modelo[$fila_codificada] = $datos;
		return $datos;
	}

	/**
	 * Wrappea el resultado en un procesador_vista con la configuracion establecida - Para generar links,
	 * chequear derechos.
	 * @param string $name
	 * @param array $arguments
	 * @throws \kernel\error_kernel
	 * @return procesador_vista
	 */
	public function __call($name, $arguments)
	{
		kernel::log()->add_debug("{$this->tag} Invocando $name", $arguments);

		$datos = call_user_func_array(array($this->modelo, $name), $arguments);

		if ($datos instanceof recordset) {

			$p = new persistidor_rs($this->fuente_recordsets);
			$p->fuente_objeto = $this->modelo;
			$p->fuente_funcion = $name;
			$p->fuente_argumentos = $arguments;
			$p->recordset = $datos;

			$v = $this->instanciar_procesador_vista($p);
			kernel::log()->add_debug("{$this->tag} Resultado es un recordset", (array)$v);
			return $v;
		} else {
			$error = new error_kernel("{$this->tag} Se requiere un resultado de tipo recordset para poder procesarlo con el Adaptador");
			kernel::log()->add_error($error);
			throw $error;
		}
	}

	/**
	 * @param string $fila_codificada el hash de la fila
	 * @param string $destino el metodo para el cual se realizo la consulta
	 * @return array
	 */
	protected function decodificar_fila__($fila_codificada, $destino)
	{
		$gen_id = $this->instanciar_generador_ids();

		list($id_fila, $id_recordset) = $gen_id->descomponer_id_fila($fila_codificada);

		//se chequea que la fila sea para $destino_clase::destino_funcion
		$p = new persistidor_rs($this->fuente_recordsets);
		$p->fuente_objeto = $this->modelo;
		$p->destino_clase = $this->operacion_actual;
		$p->destino_funcion = $destino;

		$rs = $p->recuperar($id_recordset);

		$procesador = $this->instanciar_procesador_modelo($rs, $id_recordset);
		$datos = $procesador->recuperar_fila($gen_id->get_nombre_columna_generada(), $fila_codificada);
		return $datos;
	}

	/**
	 * @return \kernel\util\modelo\decorador_ids
	 */
	protected function instanciar_generador_ids()
	{
		$generador_id = new decorador_ids();
		return $generador_id;
	}

	/**
	 * @param \kernel\util\modelo\recordset $rs
	 * @param string $id_consulta
	 * @return \kernel\util\modelo\procesador_modelo
	 */
	protected function instanciar_procesador_modelo(recordset $rs, $id_consulta)
	{
		$generador_id = $this->instanciar_generador_ids();
		$generador_id->set_columna_id($rs->get_columna_id());
		$generador_id->generar_ids_compuestos($id_consulta);

		$proc = new procesador_modelo($rs, $generador_id);

		if ($this->controlar_entidades) {
			$proc->habilitar_control_entidades($this->operacion_actual, $this->accion_actual);
		}
		return $proc;
	}


	/**
	 * @param persistidor_rs $persistidor
	 * @internal param \kernel\util\modelo\recordset $rs
	 * @return \kernel\util\modelo\procesador_vista
	 */
	protected function instanciar_procesador_vista(persistidor_rs $persistidor)
	{
		$rs = $persistidor->recordset;
		$generador_id = $this->instanciar_generador_ids();
		$generador_id->set_columna_id($rs->get_columna_id());

		$proc = new procesador_vista($generador_id, $persistidor);
		if ($this->controlar_entidades) {
			$proc->habilitar_control_entidades();
		}
		return $proc;
	}

}

?>
