<?php
return array(
    'id' => 'ALU1',
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
	/* Se configura para que alumnos con este perfil (Atilra) no tengan acceso) */
        'configuracion' => array( 'activa' => false ),

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
         * CONSULTAS
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
        /*************************************
         * TRAMITES
         */
        'censo' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
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
        'impresion_certificados'=> array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
            )
        ),
        'reinscripcion' => array(
            'activa' => false,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => false
            )
        ),
        'orientacion' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true
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
