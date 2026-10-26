<?php
namespace kernel\util;

/**
 * Permite hacer reemplazos masivos en una cadena de texto
 * @package Varios
 */
class toba_editor_texto
{
	protected $sustituciones;
	protected $id_sustitucion;
	
	/**
	 * Ingresa criterios de reemplazo
	 * @param string $texto_buscado Exp. regular
	 * @param string $texto_reemplazo
	 */
	function agregar_sustitucion( $texto_buscado, $texto_reemplazo )
	{
		$this->sustituciones[ $this->id_sustitucion ]['buscado'] = $texto_buscado;
		$this->sustituciones[ $this->id_sustitucion ]['reemplazo'] = $texto_reemplazo;
		$this->id_sustitucion++;
	}	

	/**
	 * Procesa todos las sustituciones ingresadas
	 * @param string $texto
	 * @return string texto resultante
	 */
	function procesar($texto)
	{
		foreach( $this->sustituciones as $sustitucion ) {
			$texto = preg_replace( $sustitucion['buscado'], $sustitucion['reemplazo'], $texto );
		}
		return $texto;
	}
}
?>