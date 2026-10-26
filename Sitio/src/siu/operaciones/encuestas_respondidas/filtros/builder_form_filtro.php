<?php
namespace siu\operaciones\encuestas_respondidas\filtros;

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
        return kernel::vinculador()->crear('encuestas_respondidas', 'index');
    }

    protected function generar_definicion(guarani_form $form, fabrica_formularios $fabrica)
    {

        $materia = $form->add_elemento($fabrica->elemento('materia_descr', array(
            form_elemento_config::label => kernel::traductor()->trans('encuestas_respondidas.materia'),
            form_elemento_config::filtro            => validador::TIPO_TEXTO,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'text'),
            form_elemento_config::valor_default => '',
            form_elemento_config::placeholder => kernel::traductor()->trans('encuestas_respondidas.todas'),
        )));
        $fabrica->elemento_decorar_boton_limpiar($materia, 'limpiar_materia');

        $form->add_elemento($fabrica->elemento('materia', array(
            form_elemento_config::filtro            => validador::TIPO_ALPHANUM,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'hidden'),
            form_elemento_config::valor_default => '',
        )));

        $docente = $form->add_elemento($fabrica->elemento('docente_descr', array(
            form_elemento_config::label => ucfirst(kernel::traductor()->trans('encuestas_respondidas.docente')),
            form_elemento_config::filtro            => validador::TIPO_TEXTO,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'text'),
            form_elemento_config::valor_default => '',
            form_elemento_config::placeholder => kernel::traductor()->trans('encuestas_respondidas.todos'),
        )));
        $fabrica->elemento_decorar_boton_limpiar($docente, 'limpiar_docente');

        $form->add_elemento($fabrica->elemento('docente', array(
            form_elemento_config::filtro            => validador::TIPO_ALPHANUM,
            form_elemento_config::obligatorio       => false,
            form_elemento_config::elemento          => array('tipo' => 'hidden'),
            form_elemento_config::valor_default => '',
        )));

        $fecha_desde = $form->add_elemento($fabrica->elemento_fecha('fecha_desde', array(
            form_elemento_config::label			=> kernel::traductor()->trans('encuestas_respondidas.fecha_desde'),
            form_elemento_config::obligatorio	=> false,
            form_elemento_config::placeholder	=> kernel::traductor()->trans('encuestas_respondidas.filtro_seleccione'),
            form_elemento_config::clase_css => 'date',
            form_elemento_config::readonly => true,
        )));
        $fabrica->elemento_decorar_boton_limpiar($fecha_desde, 'limpiar_fecha_desde');

        $fecha_hasta = $form->add_elemento($fabrica->elemento_fecha('fecha_hasta', array(
            form_elemento_config::label			=> kernel::traductor()->trans('encuestas_respondidas.fecha_hasta'),
            form_elemento_config::obligatorio	=> false,
            form_elemento_config::placeholder	=> kernel::traductor()->trans('encuestas_respondidas.filtro_seleccione'),
            form_elemento_config::clase_css => 'date',
            form_elemento_config::readonly => true,
        )));
        $fabrica->elemento_decorar_boton_limpiar($fecha_hasta, 'limpiar_fecha_hasta');

        $form->add_accion($fabrica->accion_boton_submit('boton_buscar', kernel::traductor()->trans('encuestas_respondidas.filtro_buscar')));
    }

    /**
     * Por defecto los filtros de guarani se basan en el layout grilla. Se debe configurar en este metodo para poder
     * instanciar el mismo
     */
    function get_configuracion_layout_grilla()
    {
        $id_perfil_activo = kernel::persona()->get_id_perfil_activo();

        $grilla = array(
            array(
                'grupo' => 'filtros',
                'filas' => array(
                    array(
                        'materia_descr' => array('span' => 12),
                        'materia' => array('span' => 0),
                    ),
                    array(
                        'docente_descr' => array('span' => 12),
                        'docente' => array('span' => 0),
                    ),
                    array(
                        'fecha_desde' => array('span' => 3),
                        'fecha_hasta' => array('span' => 3),
                    ),
                )
            ),
        );

        if ($id_perfil_activo == "DOC") {
            unset($grilla[0]['filas'][1]);
            $grilla[0]['filas'] = array_values($grilla[0]['filas']);
        }

        return $grilla;

    }
}