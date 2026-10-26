<?php
namespace siu\operaciones\planes_estudio\filtro;

use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;
use kernel\util\validador;
use \siu\extension_kernel\formularios\builder_formulario;
use \siu\extension_kernel\formularios\fabrica_formularios;
use \siu\extension_kernel\formularios\guarani_form;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\formularios\guarani_form_elemento;

class builder_form_filtro extends builder_formulario
{
	function get_id_html() 
	{
		return 'formulario_filtro';
	}

	function get_action() 
	{
		// se posteará a la acción cargar_plan_estudio del controlador
		return kernel::vinculador()->crear('planes_estudio', 'cargar_plan_estudio');
	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) 
	{
		$form->add_elemento($fabrica->elemento('carreras', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('planes_estudio.carreras')),
				form_elemento_config::filtro			=> validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_carreras(),
				form_elemento_config::validar_select => false,
			
		)));
		
		$form->add_elemento($fabrica->elemento('planes', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('planes_estudio.planes')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::validar_select => false,
		)));
		
		$form->add_elemento($fabrica->elemento('versiones', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('planes_estudio.versiones')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::validar_select => false,
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
				'grupo' => 'filtros',
				'filas' => array(
					array(
						'carreras' => array('span' => 4),
						'planes' => array('span' => 4),
						'versiones' => array('span' => 4),
					),
				)
			),
		);
	}
	
	/* valores de filtrado */
	function get_carreras()
	{ 
		$datos = catalogo::consultar('plan_estudios', 'carreras');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'CARRERA_NOMBRE', true, true, kernel::traductor()->trans('planes_estudio.filtro_seleccione_carrera'));
	}
	
}