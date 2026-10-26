<?php

return array(
    'id' => 'ALU',
    'parametros' => array(
        'index' => 'inicio_alumno'
    ),
    'operaciones' => array(
        
        'encuestas_egresados' => array(
            'activa' => TRUE,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),
   
        'tasa_egreso' => array(
            'activa' => false,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),
        'pasantia' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'impresion_certificados'=> array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
       /* 'pasantia' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),*/
	'electivas_cronograma' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'electivas',
                'visible' => true
            )
        ),
	'capic' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'movilidad',
                'visible' => true
            )
        ),
        'gestionar_diploma'=> array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),
    )
);
