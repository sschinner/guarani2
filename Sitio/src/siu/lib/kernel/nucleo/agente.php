<?php
namespace kernel\nucleo;
use kernel\util\mobile_detect;

class agente
{
	const TIPO_BROWSER = 'browser';
	const TIPO_TABLET  = 'tablet';
	const TIPO_CELULAR = 'celular';
	
	/**
     *
     * @var mobile_detect
     */
    protected $detector_movil;
	protected $tipo;
	
	function __construct()
	{
		$this->detector_movil = new mobile_detect();
		$this->detectar();
	}
	
	protected function detectar()
	{
		if ($this->detector_movil->isTablet()) {
			$this->tipo = self::TIPO_TABLET;
		} else if ($this->detector_movil->isMobile()) {
			$this->tipo = self::TIPO_CELULAR;
		} else {
			$this->tipo = self::TIPO_BROWSER;
		}
	}

	/**
	 *
	 * @param string $tipo una de las constantes agente::TIPO_*
	 */
	function forzar_tipo($tipo)
	{
		$this->tipo = $tipo;
	}
	
	function get_tipo()
	{
		return $this->tipo;
	}
	
    function es_browser()
	{
		return $this->tipo == self::TIPO_BROWSER;
	}
    
	function es_tablet()
	{
		return $this->tipo == self::TIPO_TABLET;
	}
	
    function es_celular()
	{
		return $this->tipo == self::TIPO_CELULAR;
	}
}
?>