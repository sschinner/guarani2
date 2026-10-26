<?php
namespace siu\operaciones\actas\filtro;

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
		// se posteará a la acción index del controlador
		return kernel::vinculador()->crear('actas', 'index');
	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) 
	{
		$elemento = $form->add_elemento($fabrica->elemento_autocompletar('materia',
			array(
				form_elemento_config::label => ucfirst(kernel::traductor()->trans('actas.filtro_materia')),
				form_elemento_config::obligatorio => false,
				form_elemento_config::filtro => validador::TIPO_TEXTO,
				form_elemento_config::valor_default => '',
				form_elemento_config::clase_css => 'filtros_comunes',
			),
			function ($id) {
				if (!$id) { return '-- Todas --'; };
				$materias = catalogo::consultar('unidad_academica', 'materias', array('term' => ""));
                if(!empty($materias)){
                    foreach($materias as $materia){
                        if($materia["id"] == $id){
                            return $materia['label'];
                        }
                    }
                }

			},
			kernel::vinculador()->crear('actas', 'buscar_materia')
		));
		$fabrica->elemento_decorar_boton_limpiar($elemento, 'limpiar_materia');
		
		$form->add_elemento($fabrica->elemento('origen', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_origen')),
				form_elemento_config::filtro			=> validador::TIPO_ALPHA,
				form_elemento_config::obligatorio	=> true,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_origenes(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
			
		)));
				
		$form->add_elemento($fabrica->elemento('anio_academico', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_anio_academico')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> true,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_anios_academicos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('sede', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_sede')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_sedes(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('turno', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_turno')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_turnos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_examenes',
		)));
		
		$form->add_elemento($fabrica->elemento_fecha('desde', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_desde')),
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::placeholder	=> kernel::traductor()->trans('actas.filtro_seleccione'),
				form_elemento_config::clase_css => 'date filtros_examenes',
		)));
		
		$form->add_elemento($fabrica->elemento_fecha('hasta', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_hasta')),
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::placeholder	=> kernel::traductor()->trans('actas.filtro_seleccione'),
				form_elemento_config::clase_css => 'date filtros_examenes',
		)));
		
		$form->add_elemento($fabrica->elemento('periodo', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('actas.filtro_periodos')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_periodos_lectivos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_cursadas',
		)));
		$form->add_accion($fabrica->accion_boton_submit('boton_buscar', ucfirst(kernel::traductor()->trans('actas.filtro_buscar'))));
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
						'materia' => array('span' => 8),
						'origen' => array('span' => 4),
					),
					array(
						'anio_academico' => array('span' => 4),
						'sede' => array('span' => 4),
					),
					array(
						'turno' => array('span' => 4),
						'desde' => array('span' => 4),
						'hasta' => array('span' => 4),
					),
					array(
						'periodo' => array('span' => 12),
					),
				)
			),
		);
	}
	
	/* valores de filtrado */
	function get_origenes()
	{
		return array(
			"E" => ucfirst(kernel::traductor()->trans('actas.filtro_origen.e')),
			"P" => ucfirst(kernel::traductor()->trans('actas.filtro_origen.p')),
			"R" => ucfirst(kernel::traductor()->trans('actas.filtro_origen.r')),
		);
	}
	
	function get_tipos()
	{
		return array(
			0 => ucfirst(kernel::traductor()->trans('actas.filtro_seleccione')),
			1 => ucfirst(kernel::traductor()->trans('actas.filtro_tipo.n')),
			2 => ucfirst(kernel::traductor()->trans('actas.filtro_tipo.r')),
		);
	}
	
	function get_sedes()
	{
		$datos = catalogo::consultar('sistema', 'sedes');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'NOMBRE', true, false, ucfirst(kernel::traductor()->trans('-- Todas --')));
	}
	
	function get_anios_academicos()
	{
		$datos = catalogo::consultar('unidad_academica', 'anios_academicos');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'ANIO_ACADEMICO', false, false, ucfirst(kernel::traductor()->trans('actas.filtro_seleccione')));
	}
	
	function get_turnos()
	{
		return array(""=>  kernel::traductor()->trans('actas.filtro_seleccione'));
	}
	
	function get_periodos_lectivos()
	{
		return array(""=>  kernel::traductor()->trans('actas.filtro_seleccione'));
	}
}