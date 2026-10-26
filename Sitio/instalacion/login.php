<?php
return array(
	/**
	 *  Clasico formulario de usuario y contraseña
	 */
	'form'   => array(
		'activo'     => true,
		'clase'      => 'modelo\\autenticacion\\auth_form',
		'parametros' => array(	)
	),

	/**
	 *  Utiliza un sp de onelogin php para conectarse a un idp externo (no provisto por SIU).
	 *  Para el mapeo de usuarios Se ofrece por defecto buscar id_persona, o nro_inscripcion,
	 *  en base al primer componente del atributo 'saml_uid' ($atributos[$saml_uid][0]).
	 *  Es probable que en función de la configuración del idp de la institución se deba personalizar la opearcion.
	 */
	'saml'   => array(
		'activo'     => false,
		'clase'      => 'modelo\\autenticacion\\auth_saml',
		'parametros' => array(
			'settings_file' => \siu\bootstrap::get_dir_instalacion() . '/saml/settings_example.php',
			'saml_uid' => 'uid',// 'urn:oid:0.9.2342.19200300.100.1.1', //se matchea con local_uid
			'local_uid' => 'id' //puede ser 'nro_inscripcion'
		),
	),
	/**
	 * Login con cuentas externas. Se deben crear las mismas en los respectivos proveedores externos y reemplazar las keys.
	 * Se desaconseja utilizar OpenId, que si bien es mas sencillo de utilizar, no garantiza un id unico, lo cual provocrìa
	 * una desasación de las cuentas.
	 */
	'cuenta_ext' => array(
		'activo'     => false,
		'clase'      => 'modelo\\autenticacion\\auth_cuenta_ext',
		'parametros' => array(
			'proveedores' => array(
				'google'   => array( //para cada fuente
					'tipo' => 'oauth2',
					'icono'      => 'img/login/google.jpg',
					'app_key'    => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.apps.googleusercontent.com',
					'app_secret' => 'xxxxxxxxxxxxxxxxxxxxxxx',
					'scope'      => 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',

					'auth_url'   => 'https://accounts.google.com/o/oauth2/auth',
					'acc_url'    => 'https://accounts.google.com/o/oauth2/token',
					'id_url'     => 'https://www.googleapis.com/oauth2/v1/userinfo',

					'id_path'    => 'id', //de que campo saca el id
					'email_path' => 'email', //de que campo saca el mail
				),
				'facebook' => array(
					'tipo' => 'oauth2',
					'icono'       => 'img/login/facebook.jpg',
					'app_key'    => '999999999999999',
					'app_secret' => '99999999999999999999999999999999',
					'scope'      => 'email',

					'auth_url'   => 'https://www.facebook.com/dialog/oauth',
					'acc_url'    => 'https://graph.facebook.com/oauth/access_token',
					'id_url'     => 'https://graph.facebook.com/me',

					'id_path'    => 'id', //de que campo saca el id
					'email_path' => 'email', //de que campo saca el mail
				),
				'google_oid' => array( //para cada fuente
					'tipo' => 'openid',
					'url'   => 'https://www.google.com/accounts/o8/id',
					'icono' => 'img/login/google.jpg',
				),
			)
		),
	),

);