<?php
namespace kernel\util\db;

use kernel\kernel;
use kernel\error_kernel_db;

class db_pdo_odbc extends db_pdo
{
	function conectar()
	{
		$database = (isset($this->parametros['database']))? $this->parametros['database'] : $this->parametros['dbname'];
		$dsn = "odbc:$database";
		$this->conexion = new \PDO($dsn);
	}
	
	/**
	 *
	 * @param type $sql
	 * @param type $fetch
	 * @return type 
	 * 
	 * Llevar columnas a uppercase
	 */
	function consultar($sql, $fetch=db::FETCH_ASSOC)
	{
		kernel::log()->add_debug('sql',$sql);
		//kernel::log()->add_sql($sql);
		try {
		 	$statement = $this->conexion->query($sql);
			$f = $this->get_tipo_fetch($fetch);
			$datos = $statement->fetchAll($f);
			if ($fetch == db::FETCH_ASSOC) {
				for($a=0;$a<count($datos);$a++) {
					foreach(array_keys($datos[$a]) as $col) {
						$datos[$a][strtoupper($col)] = $datos[$a][$col];
						if($col != strtoupper($col)) unset($datos[$a][$col]);
					}
				}
			} else {
				for($a=0;$a<count($datos);$a++) {
					foreach(array_keys($datos[$a]) as $col) {
						$datos[$a][$col] = $datos[$a][$col];
					}
				}
			}
			return $datos;
		} catch (\PDOException $e) {
			throw new error_kernel_db("SQL ERROR: " . $e->getMessage() . "\n$sql");
		}
	}
	
	/**
	 *
	 * @param type $parametro
	 * @return type 
	 * @todo: hay que hacer un quote para este driver
	 */
	function quote($parametro)
	{
		return "'$parametro'";
	}
}
?>
