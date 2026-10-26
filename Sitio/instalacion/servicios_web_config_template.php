<?php

return array (
	'ofrecidos' => array(
		//por el momento solo se puede ofrecer 1 solo servicio
		'rest' => array ( //cualquier id
			'activo' => false,
//			'tipo' => 'rest',  //no se usa, son los unicos tipos que se ofrecen
//			'clase' => '\\modelo\\rest\\configuracion_rest', //Si se provee, se usa esta en lugar de la del nucleo (extenderla)
			'parametros' => array(
				'autenticacion' => array( //obtiene los user/pass de un archivo y usa http-basic
					'tipo' =>'basic',
					'parametros' => array( //parametro para el tipo basic
						'archivo_usuarios' => \siu\bootstrap::get_dir_instalacion()."/servicios_web/ofrecidos/usuarios.php"
					)
				),
//				'autenticacion' => array( //para personalizar completamente la autenticacion
//					'clase' => '\\modelo\\rest\\autenticacion',
//					'parametros' => array(	)
//				),
//				'autenticacion' => array( //saca los usuarios de la bd del proyecto. Usa basic-http.
//					'tipo' =>'proyecto',
//					'parametros' => array(
//						'archivo_usuarios' => \siu\bootstrap::get_dir_instalacion()."/servicios_web/ofrecidos/usuarios.php"
//					)
//				),
				'settings' => array('formato_respuesta' => 'json') //settings que se pasan a la libreria
			)
		),
	),


	'consumidos' => array(
		'kolla' => array(
			'tipo' => 'rest',
			'parametros' => array( //usa cliente Guzzle, son opciones en formato guzzle
				'base_url' => "http://localhost/kolla/trunk/rest/",
				'defaults' => array (
					'auth' => array('ue_toba','toba'), //user, password, segun guzzle
					'verify' => false //no verificar cert ssl
				)
			)
		),

		'kolla_old' => array(
			'tipo' => 'soap',
			'url' => "http://localhost/kolla/3.2/servicios.php/habilitaciones",
			'seguro' => true, //usa o no los certificados. Por omision es Verdadero!
			'clave_publica' => \siu\bootstrap::get_dir_instalacion()."/servicios_web/publica.crt", //local
			'clave_privada' => \siu\bootstrap::get_dir_instalacion()."/servicios_web/privada.pkey", //local
			'certificado_servicio' => \siu\bootstrap::get_dir_instalacion()."/servicios_web/consumidos/kolla.crt", //server externo
		),

	)

);


