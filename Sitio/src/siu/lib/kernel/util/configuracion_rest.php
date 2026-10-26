<?php

namespace kernel\util;


use kernel\error_kernel;
use kernel\kernel;
use kernel\util\rest\chulupi_lector_recursos;
use kernel\util\rest\chulupi_logger;
use kernel\util\rest\chulupi_rest_usuarios;
use kernel\util\rest\chulupi_rest_usuarios_conf;

use SIUToba\rest\rest;
use SIUToba\rest\seguridad\autenticacion\autenticacion_basic_http;


class configuracion_rest {

	const CARPETA_REST = '/rest';

	protected $configuracion;

	function __construct($conf)
	{
		$this->configuracion = $conf;
	}


	public function instanciar_libreria()
	{
		$app = $this->instanciar_libreria_rest();
		$this->configurar_libreria($app);
		return $app;
	}

	protected function instanciar_libreria_rest()
	{
		$settings_def = $this->get_settings_default();
		$settings = $this->get_settings_iniciales($settings_def);
		return new rest($settings);
	}

	protected function get_settings_default(){
		$es_produccion = (boolean) kernel::proyecto()->get_produccion();
		$path_controladores = $this->get_path_controladores();
		$url_base = $this->url_rest();

		$settings = array(
			'path_controladores' => $path_controladores,
			'url_api'            => $url_base,
			'prefijo_api_docs'   => 'api-docs',
			'debug'              => !$es_produccion,
			'encoding'           => 'latin1'
		);
		return $settings;
	}

	protected function configurar_libreria($app)
	{
		$app->container->singleton('logger', function () {
			return new chulupi_logger(); // toba_rest_logger();
		});

		$app->container->singleton('lector_recursos', function ($c) {
			return new chulupi_lector_recursos(
				$c['settings']['path_controladores'],
				$c['settings']['prefijo_controladores']);
		});

		$autenticador = $this->get_autenticador();
		$app->container->singleton('autenticador', $autenticador );

		$app->container->singleton('db', function () {
			return kernel::db();
		});
	}

	protected function get_settings_iniciales($default_settings){
		$settings = isset($this->configuracion['settings']) ? $this->configuracion['settings'] : array();
		return array_merge($default_settings, $settings);
	}

	protected function get_autenticador(){
		$autenticacion = $this->configuracion['autenticacion'];

		if(isset($autenticacion['clase'])){
			return kernel::localizador()->instanciar($autenticacion['clase'], $autenticacion['parametros']);
		}

		switch ($autenticacion['tipo']) {
			case 'proyecto': return function () {
					$user_passwords = new chulupi_rest_usuarios();
					return new autenticacion_basic_http($user_passwords);
				};
			case 'basic':
				return function () use ($autenticacion) {
					$passwords = new chulupi_rest_usuarios_conf($autenticacion['parametros']);
					return new autenticacion_basic_http($passwords);
				};
			default:
				throw new error_kernel("Debe especificar un tipo de autenticacion valido [proyecto/basic] en el campo 'autenticacion'");
		}

	}


	protected function url_rest()
	{
		return $url = kernel::proyecto()->get_alias() . '/rest/';
	}

	/**
	 * @return string
	 */
	protected function get_path_controladores()
	{
		$path_controladores = \siu\bootstrap::get_dir_siu() . self::CARPETA_REST;
		return $path_controladores;
	}

//    protected function rederigir_a_swagger()
//    {
//        $swagger_ui = toba_recurso::url_toba() . '/swagger/index.html';
//        $proy = toba_rest::url_api_doc();
//        header('Location: ' . $swagger_ui . '?' . $proy);
//    }

} 