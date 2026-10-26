<?php
namespace kernel\util;

class toba_editor_archivos extends toba_editor_texto
{
	/**
	 * Procesa todos las sustituciones ingresadas tomando un archivo de entrada y uno de salida
	 * @param string $archivo Path del archivo de entrada
	 * @param string $archivo_resultado Path del archivo resultante
	 */
	function procesar_archivo( $archivo, $archivo_resultado=null )
	{
		$archivo_resultado = isset($archivo_resultado) ? $archivo_resultado : $archivo;
		$texto = $this->procesar(file_get_contents( $archivo ));
		file_put_contents( $archivo_resultado, $texto );
	}
	
	/**
	 * Procesa las sustituciones en un conjunto de archivos 
	 * @param array $archivos Arreglo de paths de archivos
	 */
	function procesar_archivos( $archivos )
	{
		foreach( $archivos as $archivo ) {
			$this->procesar_archivo( $archivo );
		}
	}
}
?>