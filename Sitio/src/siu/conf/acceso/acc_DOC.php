<?php
return array(
    'id' => 'DOC',
    'parametros' => array(
        'index' => 'inicio_docente'
    ),
    'operaciones' => array(
        /*************************************
         * NO APARECEN EN EL MENU
         */
        'acceso' => array( 'activa' => true, ),
        'inicio_docente' => array( 'activa' => true, ),
        'mensajes' => array( 'activa' => true, ),
        'configuracion' => array( 'activa' => true, ),

        /*************************************
         * CURSADAS
         */
        'resumen_cursada' => array(
            'url' => 'resumen_cursada',
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'resumen_cursada'
            )
        ),
        'notas_cursada' => array(
            'url' => 'cursada',
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'carga_notas_cursada'
            )
        ),
        'agenda_cursadas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'agenda_cursada'
            )
        ),
        'inscriptos_cursadas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'inscriptos_cursada'
            )
        ),
        'acta_cursadas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'actas_regulares'
            )
        ),
        'acta_promociones' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'cursadas',
                'visible' => true,
                'texto' => 'actas_promociones'
            )
        ),
        /*************************************
         * EXAMENES
         */
        'notas_examen' => array(
            'activa' => true,
            'url' => 'examen',
            'menu' => array(
                'submenu' => 'examenes',
                'visible' => true,
                'texto' => 'carga_notas_examen'
            )
        ),
        'agenda_examenes' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'examenes',
                'visible' => true,
                'texto' => 'agenda_examen'
            )
        ),
        'inscriptos_examenes' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'examenes',
                'visible' => true,
                'texto' => 'inscriptos_examen'
            )
        ),
        'acta_examenes' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'examenes',
                'visible' => true,
                'texto' => 'actas_examenes'
            )
        ),
        /*************************************
         * SIN SUBMENU
         */
        'notas_parciales' => array(
            'activa' => true,
            'url' => 'parciales',
            'menu' => array(
                'visible' => true,
            )
        ),
        'asistencias' => array(
            'activa' => true,
            'menu' => array(
                'visible' => true,
            )
        ),

        /*************************************
         * REPORTES
         */
        'encuestas_respondidas' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
            ),
        'encuestas_resultados' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'consultas',
                'visible' => true
            )
            ),
        
        /*************************************
         * TRAMITES
         */
        'censo_docente' => array(
            'activa' => true,
            'menu' => array(
                'submenu' => 'tramites',
                'visible' => true,
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
    )
);