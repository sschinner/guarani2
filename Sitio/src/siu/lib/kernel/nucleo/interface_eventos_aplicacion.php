<?php
namespace kernel\nucleo;

interface interface_eventos_aplicacion
{
	function ini();
	function fin();

	function ini__conexion($db);
	function fin__conexion($db);

	function fin__request();
	function fin__response();

}
?>