<?php

namespace siu\operaciones\encuestas_resultados\filtros;

use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;
use kernel\util\validador;
use \siu\extension_kernel\formularios\builder_formulario;
use \siu\extension_kernel\formularios\fabrica_formularios;
use \siu\extension_kernel\formularios\guarani_form;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\formularios\guarani_form_elemento;

class builder_form_filtro extends builder_formulario {

    function get_id_html() {
        return 'formulario_filtro';
    }

    function get_action() {
        return kernel::vinculador()->crear('encuestas_resultados', 'index');
    }

    protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica) {

        $form->add_elemento($fabrica->elemento('anio_academico', array(
                    form_elemento_config::label => ucfirst(kernel::traductor()->trans('actas.filtro_anio_academico')),
                    form_elemento_config::filtro => validador::TIPO_ALPHANUM,
                    form_elemento_config::obligatorio => true,
                    form_elemento_config::elemento => array('tipo' => 'select'),
                    form_elemento_config::multi_options => self::get_anios_academicos(),
                    form_elemento_config::validar_select => false,
                    form_elemento_config::clase_css => 'filtros_comunes',
        )));
        $form->add_elemento($fabrica->elemento('periodo', array(
                    form_elemento_config::label => ucfirst(kernel::traductor()->trans('actas.filtro_periodos')),
                    form_elemento_config::filtro => validador::TIPO_ALPHANUM,
                    form_elemento_config::obligatorio => false,
                    form_elemento_config::elemento => array('tipo' => 'select'),
                    form_elemento_config::validar_select => false,
                    form_elemento_config::clase_css => 'filtros_cursadas',
        )));

        $form->add_elemento($fabrica->elemento('turno', array(
                    form_elemento_config::label => ucfirst(kernel::traductor()->trans('actas.filtro_turno')),
                    form_elemento_config::filtro => validador::TIPO_ALPHANUM,
                    form_elemento_config::obligatorio => false,
                    form_elemento_config::elemento => array('tipo' => 'select'),
                    form_elemento_config::validar_select => false,
                    form_elemento_config::clase_css => 'filtros_comunes',
        )));

        $materia = $form->add_elemento($fabrica->elemento('materia_descr', array(
                    form_elemento_config::label => kernel::traductor()->trans('encuestas_respondidas.materia'),
                    form_elemento_config::filtro => validador::TIPO_TEXTO,
                    form_elemento_config::obligatorio => false,
                    form_elemento_config::elemento => array('tipo' => 'text'),
                    form_elemento_config::valor_default => '',
                    form_elemento_config::placeholder => kernel::traductor()->trans('encuestas_respondidas.todas'),
        )));
        $fabrica->elemento_decorar_boton_limpiar($materia, 'limpiar_materia');

        $form->add_elemento($fabrica->elemento('materia', array(
                    form_elemento_config::filtro => validador::TIPO_ALPHANUM,
                    form_elemento_config::obligatorio => false,
                    form_elemento_config::elemento => array('tipo' => 'hidden'),
                    form_elemento_config::valor_default => '',
        )));


        $form->add_accion($fabrica->accion_boton_submit('boton_buscar', kernel::traductor()->trans('encuestas_respondidas.filtro_buscar')));
    }

    /**
     * Por defecto los filtros de guarani se basan en el layout grilla. Se debe configurar en este metodo para poder
     * instanciar el mismo
     */
    function get_configuracion_layout_grilla() {
        return array(
            array(
                'grupo' => 'filtros',
                'filas' => array(
                    array(
                        'anio_academico' => array('span' => 6),
                        'materia_descr' => array('span' => 6),
                        'materia' => array('span' => 0),
                    ),
                    array(
                        'periodo' => array('span' => 6),
                        'turno' => array('span' => 6),
                        
                    ),
                )
            ),
        );
    }

    function get_anios_academicos() {
        $datos = catalogo::consultar('unidad_academica', 'anios_academicos_todos');
        return guarani_form_elemento::armar_combo_opciones($datos, '_ID_', 'ANIO_ACADEMICO', false, false, ucfirst(kernel::traductor()->trans('actas.filtro_seleccione')));
    }

}
