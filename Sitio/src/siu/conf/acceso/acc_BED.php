<?php
return array(
    'id' => 'BED',
    'parametros' => array(
        'index' => 'inicio_bedelia'
    ),
    'operaciones' => array(
        /*************************************
         * NO APARECEN EN EL MENU
         */
        'acceso' => array( 'activa' => true, ),
        'inicio_bedelia' => array( 'activa' => true, ),
        'mensajes' => array( 'activa' => true, ),
        'configuracion' => array( 'activa' => true, ),

        'asistencias' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true,
            )
        ),
    )
);