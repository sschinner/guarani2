<?php
return array(
    'id' => 'ADM',
    'parametros' => array(
        'index' => 'inicio_administrativo'
    ),
    'operaciones' => array(

        'acceso' => array('activa' => true),
        'inicio_administrativo' => array('activa' => true),
        'mensajes' => array('activa' => true),
        'configuracion' => array('activa' => true),

        'admin_operaciones' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),

        'vincular_encuestas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'encuestas_admin',
                'visible' => true
            )
        ),

        'gestion_encuestas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'encuestas_admin',
                'visible' => true
            )
        ),

        'modificar_periodo_alcance' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'encuestas_admin',
                'visible' => true
            )
        ),

    )
);