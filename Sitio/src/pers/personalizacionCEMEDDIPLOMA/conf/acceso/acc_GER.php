<?php
return array(
    'id' => 'GER',
    'parametros' => array(
        'index' => 'inicio_gerencial'
    ),
    'operaciones' => array(

        /*************************************
         * NO APARECEN EN EL MENU
         */
        'acceso' => array( 'activa' => true, ),
        'inicio_gerencial' => array( 'activa' => true, ),
        'mensajes' => array( 'activa' => true, ),
	/* Se configura para que el usuario Gerencial tenga acceso) */
        'configuracion' => array( 'activa' => false, ),

        /*************************************
         * SIN SUBMENU
         */
        'ficha_alumno' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),
        'actas' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),
        'planes_estudio' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),
         'redireccion' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'redireccion',
                'visible' => false
            )
        ),
    )
);
