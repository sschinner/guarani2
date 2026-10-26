<?php

namespace kernel\util\modelo;
use kernel\error_kernel;

/**
 * Procesa el resultset, con una api orientada a usarse en la vista/controladores.
 */
class procesador_vista extends procesador_datos
{

	/*Pide que el decordador de derechos traiga todos los derechos en una consulta*/
	protected $batchear_derechos = true;

	/**
	 * @var decorador_ids
	 */
	protected $generador_id;
	/**
	 * @var recordset
	 */
	protected $recordset;
	/**
	 * @var persistidor_rs
	 */
	protected $persistidor;
	protected $controlar_entidades = false;


	public function __construct(decorador_ids $generador_ids, persistidor_rs $p)
	{

		$rs = $p->recordset;
		$datos = & $rs->get_datos(); //doy la ref para evitar copia on write.
		parent::__construct($datos);

		$this->persistidor = $p;
		$this->generador_id = $generador_ids;
		$this->recordset = $rs;
	}


	/**
	 * No es reversible, si se habilita, no puede deshabilitarse posteriormente.
	 * Es un mecanismo para centralizar este control.
	 */
	public function habilitar_control_entidades()
	{
		$this->controlar_entidades = true;
	}

	/**
	 * Genera un link listo para escribir en la columna $nombre_col.
	 * @param string $nombre_col
	 * @param string $controlador
	 * @param string $accion
	 * @param array $otros_params fijos para todas las columnas. Ej $pagina
	 * @param array $otras_columnas parametros que toman el valor de otra columna.
	 * @throws error_kernel
	 */
	public function link($nombre_col, $controlador, $accion, $otros_params = array(), $otras_columnas = array())
	{
		$this->__link($nombre_col, $controlador, $accion, $otros_params, $otras_columnas);
		$this->procesar();
	}

	/**
	 * Genera un link listo para escribir en la columna $nombre_col - LO aplica solo sobre la fila $clave_fila_rs (para
	 * usar por motivos de eficiencia).
	 * @param $clave_fila_rs
	 * @param string $nombre_col
	 * @param string $controlador
	 * @param string $accion
	 * @param array $otros_params fijos para todas las columnas. Ej $pagina
	 * @param array $otras_columnas parametros que toman el valor de otra columna.
	 */
	public function link_fila($clave_fila_rs, $nombre_col, $controlador, $accion, $otros_params = array(), $otras_columnas = array())
	{
		$this->__link($nombre_col, $controlador, $accion, $otros_params, $otras_columnas);
		$this->procesar_fila($clave_fila_rs);
	}


	/**
	 * @param string $controlador
	 * @param string $accion
	 * @param string $columna_a_borrar
	 */
	protected function agregar_control_entidad($controlador, $accion, $columna_a_borrar)
	{
		$dec = new decorador_entidad($controlador, $accion, false);
		$dec->set_entidades($this->recordset->get_entidades());
		if ($this->batchear_derechos) {
			$dec->batchear_derechos($this->recordset);
		}
		$dec->borrar_columna_on_deny($columna_a_borrar);
		$this->agregar_decordador($dec);
	}

	/**
	 * @param $nombre_col
	 * @param $controlador
	 * @param $accion
	 * @param $otros_params
	 * @param $otras_columnas
	 * @throws \kernel\error_kernel
	 */
	protected function __link($nombre_col, $controlador, $accion, $otros_params, $otras_columnas)
	{
		$columna_id = $this->generador_id->get_nombre_columna_generada();

		if (!$columna_id) {
			throw new error_kernel("No se puede generar un link sobre un recordset sin columna id");
		}

		$this->persistidor->destino_clase = $controlador;
		$this->persistidor->destino_funcion = $accion;
		$id_consulta = $this->persistidor->persitir();
		$this->generador_id->generar_ids_compuestos($id_consulta);

		$dec = new decorador_vinculo();
		$dec->set_datos_vinculo($columna_id, $nombre_col, $controlador, $accion);
		$dec->agregar_parametros_al_vinculo($otros_params);

		foreach ($otras_columnas as $nombre => $col) {
			$dec->agregar_columna_al_vinculo($nombre, $col);
		}

		$this->agregar_decordador($this->generador_id);
		$this->agregar_decordador($dec);

		if ($this->controlar_entidades) {
			$this->agregar_control_entidad($controlador, $accion, $nombre_col);
		}
	}

	public function get_id_fila($clave)
	{
		return $this->datos[$clave][$this->recordset->get_columna_id()];
	}

	public function get_id_fila_hasheado($clave)
	{
		$col = $this->generador_id->get_nombre_columna_generada();
		return $this->datos[$clave][$col];
	}


}

?>
