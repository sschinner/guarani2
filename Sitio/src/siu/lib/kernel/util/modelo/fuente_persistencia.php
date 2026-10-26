<?php

namespace kernel\util\modelo;
use kernel\util\intentos_login;

/**
 * Recuperar un recordset en base al nombre y un id que
 * se genera al guardarlo. Esto depende de la implementación de recordsets que se
 * estén usando. En caso de que haya varios, debe resolverse cual es en funcion
 * del id o el nombre.
 */
interface fuente_persistencia
{

	/**
	 * Crea un objeto recordset en base al nombre y un id que
	 * se genera al guardarlo.
	 * @param persistidor_rs $params_pers El objeto de donde salio el recordset
	 * @param string $id  El id que se proveyo al @see persistir_recordset
	 * @return recordset
	 */
	function get_recordset(persistidor_rs $params_pers, $id);


	/**
	 * @param persistidor_rs $p el obj
	 * @return mixed El id para recuperarlo
	 */
	function persistir_recordset(persistidor_rs $p);
}

?>
