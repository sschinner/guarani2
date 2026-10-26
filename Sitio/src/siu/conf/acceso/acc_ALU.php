<?php
return array(
    'id' => 'ALU',
    'parametros' => array(
        'index' => 'inicio_alumno'
    ),
    'operaciones' => array(
        /*************************************
         * NO APARECEN EN EL MENU
         */
        'acceso' => array( 'activa' => true, ),
        'inicio_alumno' => array( 'activa' => true, ),
        'mensajes' => array( 'activa' => true, ),
        'configuracion' => array( 'activa' => true, ),
        'validador_certificados' => array( 'activa' => true ),
//        'requisitos_ingreso' => array( 'activa' => true ),

        /*************************************
         * SIN SUBMENU
         */
        'cursada' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),
        'examen' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true
            )
        ),

        /*************************************
         * REPORTES
         */
        'historia_academica' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'plan' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'actuacion_provisoria_cursada' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'actuacion_provisoria_examen' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'aulas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'tesis' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'regularidades' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'creditos' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'temas_dictados' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'estado_titulo' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'inscripciones' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'reinscripciones' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'historial_asistencias' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'encuestas_respondidas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
        ),
        'requisitos_ingreso' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
    ),
        /*************************************
         * TRAMITES
         */
        'censo' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'encuestas_kolla' => array(
            'url' => 'encuestas',
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'solicitud_certificado' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'reinscripcion' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'orientacion' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
    )
);
