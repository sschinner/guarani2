<?php
namespace kernel\nucleo;

interface interface_proyecto
{
	function get_alias();
	function get_parametros_db();

	function get_dir_log();
	function get_dir_cache();

	function get_dir_perfiles();

	function get_clase_persona();

	function get_login_config();

	function get_fuente_usuarios();


}
?>
