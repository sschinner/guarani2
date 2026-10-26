<?php
namespace siu\operaciones\ficha_alumno\filtro;

use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;
use kernel\util\validador;
use \siu\extension_kernel\formularios\builder_formulario;
use \siu\extension_kernel\formularios\fabrica_formularios;
use \siu\extension_kernel\formularios\guarani_form;

class builder_form_filtro extends builder_formulario
{
	function get_id_html() 
	{
		return 'formulario_filtro';
	}

	function get_action() 
	{
		// se posteará a la acción index del controlador
		return kernel::vinculador()->crear('ficha_alumno', 'index');
	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) 
	{
		$form->add_elemento($fabrica->elemento('cuadro_busqueda', array(
				form_elemento_config::filtro            => validador::TIPO_TEXTO,
				form_elemento_config::obligatorio       => true,
				form_elemento_config::elemento          => array('tipo' => 'text'),
				form_elemento_config::largo             => 100,
		)));
	}

	/**
	 * Por defecto los filtros de guarani se basan en el layout grilla. Se debe configurar en este metodo para poder
	 * instanciar el mismo
	 */
	function get_configuracion_layout_grilla()
	{
		return array(
			array(
				'titulo' => ucfirst(kernel::traductor()->trans('ficha_alumno.busqueda_de_alumnos')),
				'grupo' => 'nombres',
				'filas' => array(
					array('cuadro_busqueda' => array('span' => 12)),
				)
			),
		);
	}
}