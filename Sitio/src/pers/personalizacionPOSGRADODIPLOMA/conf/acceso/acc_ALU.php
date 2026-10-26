<?php

return array(
    'id' => 'ALU',
    'parametros' => array(
        'index' => 'inicio_alumno'
    ),
    'operaciones' => array(
        
        'encuestas_egresados' => array(
            'activa' => false,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),
        
        'impresion_certificados'=> array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
   
        'tasa_egreso' => array(
            'activa' => false,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),       
        'gestionar_diploma'=> array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
    )
);
