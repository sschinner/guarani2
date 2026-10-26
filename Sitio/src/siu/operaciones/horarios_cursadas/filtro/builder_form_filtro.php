<?php
namespace siu\operaciones\horarios_cursadas\filtro;

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
		return kernel::vinculador()->crear('horarios_cursadas', 'index');
	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) 
	{
				
		$form->add_elemento($fabrica->elemento('anio_academico', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anio_academico')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> true,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_anios_academicos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('periodo', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_periodos')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_periodos_lectivos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('carrera', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_carrera')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_carreras(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('anio_cursada', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anio_cursada')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_anios_cursada(),
				form_elemento_config::validar_select => false,
		)));
	
//		$elemento = $form->add_elemento($fabrica->elemento_autocompletar('materia',
//			array(
//				form_elemento_config::label => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_materia')),
//				form_elemento_config::obligatorio => false,
//				form_elemento_config::filtro => validador::TIPO_TEXTO,
//				form_elemento_config::valor_default => '',
//				form_elemento_config::clase_css => 'filtros_comunes',
//			),
//			function ($id) {
//				if (!$id) { return '-- Todas --'; };
//				$materias = catalogo::consultar('unidad_academica', 'materias', array('term' => ""));
//                if(!empty($materias)){
//                    foreach($materias as $materia){
//                        if($materia["id"] == $id){
//                            return $materia['label'];
//                        }
//                    }
//                }
//
//			},
//			kernel::vinculador()->crear('horarios_cursadas', 'buscar_materia')
//		));
//		$fabrica->elemento_decorar_boton_limpiar($elemento, 'limpiar_materia');
		 $materia = $form->add_elemento($fabrica->elemento('materia_descr', array(
            form_elemento_config::label => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_materia')),
            form_elemento_config::filtro            => validador::TIPO_TEXTO,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'text'),
            form_elemento_config::valor_default => '',
			 form_elemento_config::clase_css => 'filtros_comunes',
        )));
        $fabrica->elemento_decorar_boton_limpiar($materia, 'limpiar_materia');

        $form->add_elemento($fabrica->elemento('materia', array(
            form_elemento_config::filtro            => validador::TIPO_ALPHANUM,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'hidden'),
            form_elemento_config::valor_default => '',
        )));
		
		$form->add_elemento($fabrica->elemento('sede', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_sede')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_sedes(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));

		$form->add_elemento($fabrica->elemento('dia_semana', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dia_semana')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_dias_semana(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		
		$form->add_elemento($fabrica->elemento('turno', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_turno')),
				form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
				form_elemento_config::obligatorio	=> false,
				form_elemento_config::elemento		=> array('tipo' => 'select'),
				form_elemento_config::multi_options => self::get_turnos(),
				form_elemento_config::validar_select => false,
				form_elemento_config::clase_css => 'filtros_comunes',
		)));
		


		$form->add_accion($fabrica->accion_boton_submit('boton_buscar', ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_buscar'))));
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
						'anio_academico' => array('span' => 4),
						'periodo' => array('span' => 8),
					),
					array(
						'carrera' => array('span' => 8),
						'anio_cursada' => array('span' => 4),
					),
					array(
						'materia_descr' => array('span' => 12),
						'materia' => array('span' => 4),
					),
					array(
						'sede' => array('span' => 4),
						'dia_semana' => array('span' => 4),
						'turno' => array('span' => 4),
					),
				)
			),
		);
	}
	
	/* valores de filtrado */
	function get_dias_semana()
	{
		return array(
			'' => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_seleccione')),
			2 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.lunes')),
			3 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.martes')),
			4 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.miercoles')),
			5 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.jueves')),
			6 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.viernes')),
			7 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.sabado')),
			1 => ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_dias.domingo')),
			
		);
	}
	
	function get_sedes()
	{
		$datos = catalogo::consultar('sistema', 'sedes');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'NOMBRE', true, false, ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_todas')));
	}
	
	function get_anios_academicos()
	{
		$datos = catalogo::consultar('unidad_academica', 'anios_academicos_vigentes');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'ANIO_ACADEMICO', false, false, ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_seleccione')));
	}
	
	function get_turnos()
	{
		return array(""=>  kernel::traductor()->trans('horarios_cursadas.filtro_seleccione'),
					 "M"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_turnos.m')),
					 "T"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_turnos.t')),
					 "N"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_turnos.n'))
				);
	}
	
	function get_anios_cursada()
	{
		return array(""=>  kernel::traductor()->trans('horarios_cursadas.filtro_seleccione'),
					 "1"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.1')),
					 "2"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.2')),
					 "3"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.3')),
					 "4"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.4')),
					 "5"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.5')),
					 "6"=>ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_anios.6')),
				);
	}
	
	function get_periodos_lectivos()
	{
		return array(""=>  kernel::traductor()->trans('horarios_cursadas.filtro_seleccione'));
	}
	
	function get_carreras()
	{
		$datos = catalogo::consultar('plan_estudios', 'carreras');
		return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'CARRERA_NOMBRE', true, false, ucfirst(kernel::traductor()->trans('horarios_cursadas.filtro_todas')));
	}	
}