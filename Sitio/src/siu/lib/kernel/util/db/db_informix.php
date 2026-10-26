<?php
namespace kernel\util\db;

use kernel\kernel;
use kernel\error_kernel_db;

/** 
 * @todo: Hay que analizar si la transformacion posterior al query impacta en la performance
 * 
 */
class db_informix implements interface_db
{
	protected $parametros;
	protected $conexion;
	protected $persistente;

	function __construct($params, $persistente=false)
	{
		$this->parametros = $params;
		$this->persistente = $persistente;
		$this->conectar($params);
	}
	
	function conectar()
	{
		//$host = $this->parametros['host'];
		$server = $this->parametros['server'];
		$database = $this->parametros['database'];
		//$port = $this->parametros['port'];
		//$client_locale = $this->parametros['client_locale'];
		$user = $this->parametros['user'];
		$pass = $this->parametros['passwd'];
		if ($this->persistente) {
			$this->conexion = @ifx_pconnect("$database@$server", $user, $pass);
		} else {
			$this->conexion = @ifx_connect("$database@$server", $user, $pass);
		}
		if ($this->conexion === false) {
			$msg = "ERROR conectandose al motor [".ifx_error()."] - ".ifx_errormsg();
			$msg .= "\n\nPor favor, verifique sus parámetros de conexión:\n";
			$msg .= "database: $database\n";
			$msg .= "server: $server\n";
//			$msg .= "user: $user\n";
//			$msg .= "passwd: $passwd\n";

			throw new error_kernel_db($msg);
		}		
	}

	function desconectar()
	{
        ifx_close($this->conexion);
	}

	function consultar($sql, $fetch=db::FETCH_ASSOC)
	{
		kernel::log()->add_debug('sql',$sql);
		//kernel::log()->add_sql($sql);
		if(($fetch != db::FETCH_ASSOC) && ($fetch != db::FETCH_NUM)) {
			throw new error_kernel_db("DB: El medoto de FETCH seleccionado es incorrecto: $fetch");	
		}
		$temp = array();
		$res = @ifx_query($sql, $this->conexion);
		// Si falla tiene que tirar la misma excepcion que PDO
		// @todo: adaptar el sqlstate
		if ($res === false) {
			$msg = "ERROR ejecutando consulta [".ifx_error()."] - ".ifx_errormsg();
			throw new error_kernel_db($msg);
		}
		if ($fetch == db::FETCH_ASSOC) {
			// FETCH asociativo: convertir a UPPERCASE (en linux-pdo es asi por defecto)
			$row = ifx_fetch_row($res);
			while (is_array($row)) {
				foreach(array_keys($row) as $row_id) {
					$temp_row[strtoupper($row_id)] = $row[$row_id];
				}
				$temp[] = $temp_row;
				$row = ifx_fetch_row($res);
			}		
		} else {
			// FETCH numerico: la base devuelve [Expr_1]... [Expr_x], se pasa a indice
			$row = ifx_fetch_row($res);
			while (is_array($row)) {
				foreach(array_keys($row) as $id => $row_id) {
					$temp_row[$id] = $row[$row_id];
				}
				$temp[] = $temp_row;
				$row = ifx_fetch_row($res);
			}		
		}
		ifx_free_result($res);
		return $temp;
	}

	function consultar_fila($sql, $fetch=null)
	{
		$data = $this->consultar($sql, $fetch);
		if ($data && isset($data[0])) return $data[0];
		return array();
	}	
	
	function ejecutar($sql)
	{
		$res = @ifx_query($sql, $this->conexion);
		// Si falla tiene que tirar la misma excepcion que PDO
		// @todo: adaptar el sqlstate
		if ($res === false) {
			$msg = "ERROR ejecutando consulta [".ifx_error()."] - ".ifx_errormsg();
			throw new error_kernel_db($msg);
		}
		return $res;
	}
	
	/**
	 *
	 * @param type $parametro
	 * @return type 
	 * @todo: hay que hacer un quote para este driver
	 */
	function quote($parametro)
	{
		return $parametro;
	}
	
	//------------------------------------------------------------------------
	//------------ TRANSACCIONES ---------------------------------------------
	//------------------------------------------------------------------------
	
	/**
	 * Ejecuta un BEGIN TRANSACTION en la conexión
	 */
	
	function abrir_transaccion()
	{
		
		
		
		kernel::log()->add_debug("ABRIR transaccion", $this->parametros['database']);
	}

	/**
	 * Ejecuta un ROLLBACK en la conexión
	 */	
	function abortar_transaccion()
	{
		
		
		
		
		kernel::log()->add_debug("ABORTAR transaccion", $this->parametros['database']);
	}
	
	/**
	 * Ejecuta un COMMIT en la conexión
	 */		
	function cerrar_transaccion()
	{
		
		
		
		
		kernel::log()->add_debug("CERRAR transaccion", $this->parametros['database']);
	}
	
}
?>
