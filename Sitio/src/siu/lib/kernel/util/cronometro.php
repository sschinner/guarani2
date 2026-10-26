<?php
namespace kernel\util;

class cronometro
{
	protected $marcas;
	protected $indice = 0;
	
	function __construct()
	{
		$this->marcar("Inicio medición");
	}
	
	/**
	 * Guarda una marca en la l�nea de tiempo
	 */
	function marcar($nombre){
		$microtime = explode(' ', microtime());
		$this->marcas[$this->indice]["t"] =  $microtime[1] . substr($microtime[0], 1);
		$this->marcas[$this->indice]["n"] = $nombre;
		$this->indice++;
	}

	/**
	 * Calcula el tiempo enntre la primer y �ltima marca registrada
	 * @return float
	 */
    function tiempo_acumulado() {
		$ultimo = (count($this->marcas)-1);
		return (($this->marcas[$ultimo]['t']) - ($this->marcas[0]['t']));
    }

	/**
	 * Calcula el tiempo enntre la anteultima y ultima marca
	 * @return float
	 */
    function tiempo_ultima_marca() {
		if (count($this->marcas)<2) throw new error('Solo hay una marca');
		$ultimo = (count($this->marcas)-1);
		$anteultimo = $ultimo -1;
		$tiempo = (($this->marcas[$ultimo]['t']) - ($this->marcas[$anteultimo]['t']));
		return number_format($tiempo, 3, '.','');
    }

    /**
     * Retorna la marcas en un arreglo
     */
	function get_marcas()
	{
		$marcas = array();
		$marca_anterior = $this->marcas[0]['t'];
		for($f=0;$f<count($this->marcas);$f++)
		{
			$marca_actual = $this->marcas[$f]['t'];
			$marcas[$f]['texto'] = $this->marcas[$f]['n'];
			$marcas[$f]['tiempo'] = number_format(($marca_actual - $marca_anterior),3,'.','');
			$marca_anterior = $marca_actual;
		}
		return $marcas;
	}
}
?>