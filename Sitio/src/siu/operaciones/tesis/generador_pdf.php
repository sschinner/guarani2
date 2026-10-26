<?php
namespace siu\operaciones\tesis;

class generador_pdf extends \siu\operaciones\_comun\operaciones\reporte\generador_pdf
{
	public function agregar_tabla($datos = array(), $columnas = array(), $titulo = "")
	{
		foreach($datos as $index => $dato)
		{
			$datos[$index]['titulo'] = $dato['titulo'];
			$datos[$index]['estado'] = strtoupper($dato['estado']);
		}
		parent::agregar_tabla($datos, $columnas, $titulo);
	}
}
?>