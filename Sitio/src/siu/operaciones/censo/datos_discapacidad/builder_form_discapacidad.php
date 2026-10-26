<?php
namespace siu\operaciones\censo\datos_discapacidad;

use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;
use kernel\util\validador;
use siu\extension_kernel\formularios\builder_formulario;
use siu\extension_kernel\formularios\fabrica_formularios;
use siu\extension_kernel\formularios\guarani_form;
use siu\operaciones\_comun\util\forms;
//use siu\extension_kernel\formularios\guarani_form_elemento;
//use siu\guarani;
use siu\modelo\datos\catalogo;
//use siu\modelo\entidades\parametro;
//use siu\modelo\_comun\comunes;

class builder_form_discapacidad extends builder_formulario
{
	protected $data;

	function get_id_html()
	{
		return 'form_datos_discapacidad';
	}

	function get_action()
	{
		return kernel::vinculador()->crear('censo', 'discapacidad_agregar');
	}

	/**
	 * El pl le envia data para configurarlo.
	 * @param $data
	 */
	function set_data($data)
	{
		$this->data = $data;

	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica)
	{
        $form->add_accion($fabrica->accion_boton_submit('btn_guardar', 'Guardar'));
        
        $form->add_elemento($fabrica->elemento(catalogo::id, array(
			form_elemento_config::label			=> 'id',
			form_elemento_config::filtro		=> validador::TIPO_TEXTO,
			form_elemento_config::obligatorio	=> false,
			form_elemento_config::elemento		=> array('tipo' => 'hidden'),
			form_elemento_config::valor_default => ''
		)));
		
		$form->add_elemento($fabrica->elemento_select('TIPO', $this->get_tipos_discapacidad(), array(
			form_elemento_config::label			=> 'discapacidad.tipo',
			form_elemento_config::obligatorio	=> true,
			form_elemento_config::filtro		=> validador::TIPO_TEXTO,
			form_elemento_config::elemento		=> array('tipo' => 'select'),
			form_elemento_config::validar_select => true,
			form_elemento_config::clase_css		=> 'editable',
		)));
		
		$form->add_elemento($fabrica->elemento_select('GRADO', $this->get_tipos_grado(), array(
			form_elemento_config::label			=> 'discapacidad.grado',
			form_elemento_config::obligatorio	=> true,
			form_elemento_config::filtro		=> validador::TIPO_TEXTO,
			form_elemento_config::elemento		=> array('tipo' => 'select'),
			form_elemento_config::validar_select => true,
			form_elemento_config::clase_css		=> 'editable',
		)));
		
		$form->add_elemento($fabrica->elemento_select('CARACTER', $this->get_tipos_caracter(), array(
			form_elemento_config::label			=> 'discapacidad.caracter',
			form_elemento_config::obligatorio	=> true,
			form_elemento_config::filtro		=> validador::TIPO_TEXTO,
			form_elemento_config::elemento		=> array('tipo' => 'select'),
			form_elemento_config::validar_select => true,
			form_elemento_config::clase_css		=> 'editable',
		)));
		
		$form->add_elemento($fabrica->elemento('COBERTURA_SALUD', array(
			form_elemento_config::label				=> 'discapacidad.tiene_cobertura_salud',
			form_elemento_config::filtro			=> validador::TIPO_TEXTO,
			form_elemento_config::obligatorio		=> true,
			form_elemento_config::elemento			=> array('tipo' => 'checkbox'),
			form_elemento_config::largo				=> 1,
			form_elemento_config::checked_value		=> 'S',
			form_elemento_config::unchecked_value	=> 'N',
			form_elemento_config::clase_css		=> 'editable',
		)));
		
		$form->add_elemento($fabrica->elemento_fecha('FECHA_DESDE', array(
			form_elemento_config::label			=> 'discapacidad.fecha_desde',
			form_elemento_config::filtro		=> validador::TIPO_DATE,
			form_elemento_config::filtro_params => array('format' => 'd/m/Y', 
										 'allowempty' => true),
			form_elemento_config::clase_css		=> 'editable date input-small',
			form_elemento_config::obligatorio	=> true,
			form_elemento_config::elemento		=> array('tipo' => 'text'),
            form_elemento_config::placeholder   => "dd/mm/aaaa",
		)));
		
		$form->add_elemento($fabrica->elemento_fecha('FECHA_HASTA', array(
			form_elemento_config::label			=> 'discapacidad.fecha_hasta',
			form_elemento_config::filtro		=> validador::TIPO_DATE,
			form_elemento_config::filtro_params => array('format' => 'd/m/Y', 
										 'allowempty' => true),
			form_elemento_config::clase_css		=> 'editable date input-small',
			form_elemento_config::obligatorio	=> false,
			form_elemento_config::elemento		=> array('tipo' => 'text'),
            form_elemento_config::placeholder   => "dd/mm/aaaa",
		)));
		
		$form->add_elemento($fabrica->elemento_textarea('OBSERVACIONES', array(
			form_elemento_config::label			=> 'discapacidad.observaciones',
			form_elemento_config::filtro		=> validador::TIPO_TEXTO,
			form_elemento_config::obligatorio	=> false,
			form_elemento_config::elemento		=> array('tipo' => 'text'),
			form_elemento_config::clase_css		=> 'input_largo',
			form_elemento_config::largo			=> 255,
			form_elemento_config::clase_css		=> 'editable',
		)));

	}

	function get_configuracion_layout_grilla()
	{

		// ------------------------   DATOS ACTA   ---------------------------
		return array(
			array(
				//'titulo' => ucfirst(kernel::traductor()->trans('discapacidad')),
				'filas' => array(
					1 => array('TIPO' => array('span' => 6), 'GRADO' => array('span' => 6)),
                    2 => array('CARACTER' => array('span' => 12)),
                    3 => array('FECHA_DESDE' => array('span' => 6), 'FECHA_HASTA' => array('span' => 6)),
                    4 => array('COBERTURA_SALUD' => array('span' => 12)),
                    5 => array('OBSERVACIONES' => array('span' => 12)),
                    6 => array('__ID__' => array('span' => 12)),
				),
			),

		);


	}
    
    function get_tipos_discapacidad(){
        $datos = catalogo::consultar('etiquetas', 'tipos_discapacidad');
        return forms::rs_to_select($datos,'-- SELECCIONE --');
    }
    
    function get_tipos_caracter(){
        $datos = catalogo::consultar('etiquetas', 'tipos_caracter');
        return forms::rs_to_select($datos,'-- SELECCIONE --');
    }
    
    function get_tipos_grado(){
        $datos = catalogo::consultar('etiquetas', 'tipos_grado');
        return forms::rs_to_select($datos,'-- SELECCIONE --');
    }
}