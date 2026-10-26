<?php
namespace siu\operaciones\asistencias\planilla;

use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;
use kernel\util\validador;
use \siu\extension_kernel\formularios\builder_formulario;
use \siu\extension_kernel\formularios\fabrica_formularios;
use \siu\extension_kernel\formularios\guarani_form;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\formularios\guarani_form_elemento;
use siu\operaciones\asistencias\controlador;

class builder_form_filtro extends builder_formulario
{

    protected $controlador;

    /**
     * @return controlador
     */
    function get_controlador(){
        if (! isset($this->controlador)) {
            $this->controlador = kernel::localizador()->instanciar('operaciones\asistencias\controlador');
        }

        return $this->controlador;
    }

	function get_id_html() 
	{
		return 'formulario_filtro';
	}

	function get_action() 
	{
		return kernel::vinculador()->crear('asistencias','planilla');
	}

	protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) 
	{
		$form->add_elemento($fabrica->elemento('cantidad', array(
                        form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('asistencias.planilla.cantidad')),
                        form_elemento_config::filtro			=>  validador::TIPO_ALPHANUM,
                        form_elemento_config::obligatorio	=> false,
                        form_elemento_config::elemento		=> array('tipo' => 'select'),
                        form_elemento_config::multi_options => self::get_cantidades(),
                        form_elemento_config::clase_css		=> 'input-small',			
                        form_elemento_config::validar_select => true,
		)));
                
                $form->add_elemento($fabrica->elemento('tipo_clase', array(
                        form_elemento_config::label => ucfirst(kernel::traductor()->trans('asistencias.planilla.tipo.clase')),
                        form_elemento_config::filtro =>  validador::TIPO_TEXTO,
                        form_elemento_config::obligatorio => false,
                        form_elemento_config::elemento => array('tipo' => 'select'),
                        form_elemento_config::multi_options => self::get_clases(),
                        form_elemento_config::clase_css	=> 'input-medium',			
                        form_elemento_config::validar_select => true,
		)));
		
		$form->add_elemento($fabrica->elemento('tipo', array(
				form_elemento_config::label			=> ucfirst(kernel::traductor()->trans('asistencias.planilla.estado')),
			form_elemento_config::filtro			=> validador::TIPO_TEXTO,
			form_elemento_config::obligatorio		=> false,
			form_elemento_config::elemento			=> array('tipo' => 'checkbox'),
			form_elemento_config::largo				=> 1,
			form_elemento_config::checked_value		=> 'T', // Imprime planilla con Todos los alumnos, incluyendo los Libres
			form_elemento_config::unchecked_value	=> 'L', //Imprime planilla sin incluir alumnos Libres
		)));

                $form->add_elemento($fabrica->elemento_fecha('fecha', array(
                        form_elemento_config::label => ucfirst(kernel::traductor()->trans("asistencias.planilla.fecha")),
                        form_elemento_config::filtro => validador::TIPO_DATE,
                        form_elemento_config::obligatorio => true,
                        form_elemento_config::filtro_params => array('format' => 'd/m/Y', 'allowempty' => false),
                        form_elemento_config::clase_css		=> 'date input-small',                
                        form_elemento_config::placeholder	=> kernel::traductor()->trans('asistencias.planilla.filtro_seleccione'),
                )));
            
                $form->add_accion($fabrica->accion_boton_submit('boton_buscar', ucfirst(kernel::traductor()->trans('fecha_examen.filtro_buscar'))));
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
                            'cantidad' => array('span' => 3),                        
                            'fecha' => array('span' => 3),
                            'tipo' => array('span' => 3),
                            'tipo_clase' => array('span' => 3),
                        ),
                    )
                ),
            );
	}
	
	function get_cantidades()
	{
		$datos = array(1=> 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5);
		//return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'NOMBRE', true, false, ucfirst(kernel::traductor()->trans('fecha_examen.filtro_todas')));
		return $datos;
	}
        
	function get_fecha()
	{
		return new \DateTime('today');
	}
        
        function get_clases ()
        {
            return $this->get_controlador()->get_tipos_clase_comision();
        }
}