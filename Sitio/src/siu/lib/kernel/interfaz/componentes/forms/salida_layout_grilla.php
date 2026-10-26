<?php
namespace kernel\interfaz\componentes\forms;


interface salida_layout_grilla
{
	/**
	 * Crea el encabezado del formulario
	 * @param string $id_html id del form
	 * @param string $action_url url de post
	 */
	public function crear_encabezado($id_html, $action_url);

	public function crear_csrf($csrf_key, $csrf_nombre);

	/**
	 * Cierra los tags que abrio crear_encabezado
	 */
	public function crear_cierre();


	/**
	 * Crea el encabezado de un grupo del formulario
	 * @param string $grupo id del grupo
	 * @param string $titulo titulo del grupo
	 */
	public function crear_encabezado_grupo($grupo, $titulo);


	/**
	 * Cierra los tags que abrio crear_encabezado_grupo
	 */
	public function crear_cierre_grupo();

	/**
	 * Abre una fila
	 */
	public function crear_encabezado_fila();

	/**
	 * Cierra los tags que abrio crear_encabezado_fila
	 */
	public function crear_cierre_fila();

	/**
	 * Crea el contenedor de un elemento con las dimensiones indicadas
	 * @param int $span la extension en columnas que ocupa el elmento
	 * @param int $offset cuantas columnas de espacio debe dejar
	 * @param boolean $tiene_error si el elemento va a mostrar un error
	 */
	public function crear_encabezado_elemento($span, $offset, $tiene_error);

	/**
	 * Dibuja el elemento. Si el mismo incluye una vista especial, se envia como segundo parametro.
	 * Se debe tener en cuenta si el elemento es obligatorio, si tiene error, si tiene texto de ayuda y si
	 * tiene una vista especial.
	 * @param form_elemento $elemento
	 * @param vista_elemento $vista_elemento
	 */
	public function crear_elemento(form_elemento $elemento, vista_elemento $vista_elemento = null);

	/**
	 * Cierra los tags abiertos por crear_encabezado_elemento
	 */
	public function crear_cierre_elemento();

	/**
	 * Genera un elemento no visible (solo util en html?). Estos componentes se dibujan directo, sin
	 * encabezado ni cierre
	 * @param form_elemento $campo
	 * @return mixed
	 */
	public function crear_elemento_plano(form_elemento $campo);


	public function crear_accion(form_accion $vista_accion);

}