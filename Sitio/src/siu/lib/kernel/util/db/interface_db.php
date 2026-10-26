<?php
namespace kernel\util\db;

interface interface_db
{
	function conectar();
	function desconectar();
	function consultar($sql);
	function consultar_fila($sql);
	function ejecutar($sql);
	function quote($parametro);
	function abrir_transaccion();
	function abortar_transaccion();
	function cerrar_transaccion();
	
	
}

?>