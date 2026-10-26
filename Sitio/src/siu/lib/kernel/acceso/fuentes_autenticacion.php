<?php


namespace kernel\acceso;

use kernel\kernel;

class fuentes_autenticacion
{

	protected $fuentes;

	protected $conf;

	function __construct($conf)
	{
		$this->fuentes = array();
		$this->conf = $conf;
	}

	public function get_fuente($auth_type)
	{
		return $this->instanciar_fuente($auth_type);
	}

	public function get_fuentes_disponibles()
	{
		foreach ($this->conf as $id => $fuente_conf) {
			if (isset($fuente_conf['activo']) && $fuente_conf['activo']){
				$this->instanciar_fuente($id);
			}
		}
		return $this->fuentes;
	}

	public function instanciar_fuente($auth_type = null)
	{
		if($auth_type == null){
			$auth_type = $this->get_id_fuente_default();
		}
		if($auth_type == null){
			return null; //no hay por defecto
		}

		if (!isset($this->fuentes[$auth_type])) {

			$fuente = $this->conf[$auth_type];
			if(!$fuente['activo']){
				return null;
			}

			$clase = $fuente['clase'];
			$parametros = isset($fuente['parametros']) ? $fuente['parametros'] : array();
			$parametros = array($auth_type, $parametros);

			$instancia = kernel::localizador()->instanciar_params_array($clase, $parametros);
			$this->fuentes[$auth_type] = $instancia;
		}
		return $this->fuentes[$auth_type];
	}

	public function get_id_fuente_default()
	{
		//si hay solo una activa, la uso de default
		$fuente_activas = 0;
		$fuente_activa = null;
		foreach ($this->conf as $id => $fuente_conf) {
			if (isset($fuente_conf['activo']) && $fuente_conf['activo']){
				$fuente_activas++;
				$fuente_activa = $id;
			}
		}
		if($fuente_activas == 1){
			return $fuente_activa;
		}
		return null;
	}
} 