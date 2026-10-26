<?php
return array (
    'global' =>
        array (
            'produccion' => false,
            'usar_personalizaciones' => true,
            'sesion_timeout' => 600,
            'sesion_maxtime' => 3600,
            'dir_attachment' => '/tmp',
            //'server_name' => '192.168.126.180',
            /*
             * Directorio donde se guardan las fotos de las personas.
             */
            'imagen_alumno_dir' => '/path/to/g3w2/src/siu/www/_comp/_img_alumnos',
            /*
             * URL donde se encuentran las fotos de las personas.
             */
            'imagen_alumno_url' => 'http://localhost/g3w2/_comp/_img_alumnos',
            'url_kolla' => 'http://localhost/kolla/3.4/aplicacion.php',
            'ssl' => array(
                'alcance' => 'none',//'none' | 'all'
                'redirigir_ssl' => true,//true | false
            ),
            // Directorio donde se guardarán los archivos de metadata de operaciones inactivas
            // por defecto se guardan en instalacion/operaciones_inactivas
            // 'dir_ops_inactivas' => '/tmp/ops',
            'salt' => '9bf057558b90263987bd8f99caf2e92f7efc1a13',
            /**
			 * Configuración de reCAPTCHA 2
			 * Para obtener el par de API keys ('site_key' y 'secret_key')
			 * ir a http://www.google.com/recaptcha/admin
			 */
			'captcha' =>
			array(
				'activo' => true,
				'intentos_login' => 3,
				'site_key' => '', //Ej: '6LfeSwgUAAAAAIwfEadYVIsp_-D8xRHi_qTEGS-x'
				'secret_key' => '', //Ej: '6LfeSwgUAAAAABXZhiGF0vmABVgyyUZ7eIgk_vLD'
			),
            'proxy' =>
                array(
                    'activo' => false,
                    'proxy_host' => 'proxy.xxxxxxxxx',
                    'proxy_port' => 8080,
                    'proxy_username' => 'PROXY-USERNAME',
                    'proxy_password' => 'PROXY-PASSWORD'
                ),

            'google_analytics' => array(
                'activo'  => true,
                'account' => 'UA-xxx-y'
            ),

            'log' =>
                array (
                    'activo' => true,
                    'nivel' => 'debug',
                    'barra_dev' => true,
                ),
            'ini_debug' => false,
            /**
             * Indica el manejador de cache a utilizar.
             * NOTA: si utiliza un esquema de servidores distribuidos se recomienda
             * utilizar 'memcached' y configurar uno o más servidores de cache.
             *  - Valores posibles: apc|memcached
             */
            'manejador_cache_memoria' => 'apc',
            /**
             * Configuración de servidores de memcached
             */
            'memcached' =>
                array (
                    'server_1' =>
                        array (
                            'host' => '127.0.0.1',
                            'port' => 11211,
                            'peso' => 1,
                        ),
                ),
            'smtp' =>
                array (
                    'from' => 'admino@gmail.com',
                    'host' => 'smtp.gmail.com',
                    'seguridad' => 'ssl',
                    'auth' => true,
                    'port' => 465,
                    'usuario' => 'admin@gmail.com',
                    'clave' => 'clave',
                    'reply_to' => 'admino@gmail.com'
                ),
            //Cantidad de emails que se desencolaran y enviaran cada vez que se ejecute el cron o tarea programada (0 para ilimitado)
            'cant_emails_a_enviar_por_corrida_cron' => 0,
            
            //Cantidad máxima de destinatarios por email, los emails serán paginados por esta cantidad (0 para ilimitado)
            'cant_max_destinatarios_por_email' => 0,

            //Cantidad máxima de opciones de respuestas devueltas por kolla (0 para ilimitado)
            'encuestas_cantidad_maxima_respuestas_kolla' => 0,
            
            //Evaluacion y eliminacion de rtas de kolla con texto libre que esten incluidas en
            //regex: "/^[\.\-\,\ ]+$/","/no.*tu/i","/no.*ten/i","/no fue mi/i","/no opin/i","/sin coment/i","/^ningun./i","/^sin observ/i","/no hay observ/i","/nada para agregar/i","/nada en especial/i","/sin opini/i","/^sin descripc/i"
            'encuesta_evaluar_rtas_libres_expreg' => false,
            
            'accesos' =>
                array (
                    'des01' =>
                        array (
                            'ua' => 5,
                            'personalizacion' => NULL,
                            'database' =>
                                array (
                                    'vendor' => 'informix',
                                    'database' => 'unlpam',
                                    'host' => '192.168.123.122',
                                    'server' => 'ol_guarani3w2',
                                    'client_locale' => 'en_us.cp1252',
                                    'service' => 1526,
                                    'protocol' => 'olsoctcp',
                                    'LogonID' => NULL,
                                    'pwd' => NULL,
                                    'EnableScrollableCursors' => 1,
                                ),
                        ),
                ),
        ),
);
