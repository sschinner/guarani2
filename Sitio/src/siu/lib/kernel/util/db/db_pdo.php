<?php
namespace kernel\util\db;

use kernel\kernel;
use kernel\error_kernel_db;

class db_pdo implements interface_db
{
    /**
     *
     * @var \PDO
     */
    protected $conexion;
	protected $schema;
	protected $parametros;

	const VENDOR_INFORMIX = 'informix';
	const VENDOR_POSTGRES = 'pgsql';

    function __construct($params)
    {
        $this->parametros = $params;
        try {
            $this->conectar();
			if (isset($this->parametros['dbname'])) {
				 $this->parametros['database'] = $this->parametros['dbname'];
			}
            $this->conexion->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
        } catch (\PDOException $e) {
            $msg = "ERROR conectandose al motor [" . $e->getCode() . "] - " . $e->getMessage();
			$ex = new error_kernel_db("SQL CONNECTION ERROR: " . $msg);
			if ($this->parametros['vendor'] != 'informix') {
				$ex->set_sqlstate($this->conexion->errorCode());
			}
			throw $ex;
        }
    }

	function conexion()
	{
		return $this->conexion;
	}
	
    function conectar()
    {
        try {
            $dsn = array();
            
            if (isset($this->parametros['pdo_user'])) {
                $user = $this->parametros['pdo_user'];
                $pass = $this->parametros['pdo_passwd'];
            }
			
            foreach ($this->parametros as $k => $p) {
                if (!in_array($k, array('vendor', 'user', 'passwd', 'pdo_user', 'pdo_passwd', 'schema'))) {
                    $dsn[] = $k . '=' . $p;
                }
            }
            if (isset($user)) {
                $this->conexion = new \PDO($this->parametros['vendor'] . ':' . implode(';', $dsn), $user, $pass);
            } else {
                $this->conexion = new \PDO($this->parametros['vendor'] . ':' . implode(';', $dsn));
            }
			if ($this->parametros['vendor'] == 'pgsql') {
				$this->set_encoding(kernel::proyecto()->get_encoding());
				if (isset($this->parametros['schema'])) {
					$this->set_schema($this->parametros['schema']);
				}
			}

        } catch (\PDOException $e) {
            $msg = "ERROR conectandose al motor - " . $e->getMessage();
            $msg .= "\n\nPor favor, verifique sus parámetros de conexión:\n" . implode("\n", $dsn);
			$ex = new error_kernel_db("DB CONNECTION ERROR: " . $msg);
			throw $ex;
        }
    }
	
	function get_parametros()
	{
		return $this->parametros;
	}

    function desconectar()
    {
        unset($this->conexion);
    }

	function set_encoding($encoding)
	{
		$sql = "SET CLIENT_ENCODING TO '$encoding';";
		$this->ejecutar($sql);     
	}
	
	function set_schema($schema)
	{
		$this->schema = $schema;
		$this->ejecutar("SET search_path TO $schema");
	}
	
	function get_schema()
	{
		return $this->schema;
	}

    //------------------------------------------------------------------
    // Acceso a datos
    //------------------------------------------------------------------

    protected function get_tipo_fetch($fetch)
    {
        switch ($fetch) {
            case db::FETCH_ASSOC:
                $f = \PDO::FETCH_ASSOC;
                break;
            case db::FETCH_NUM:
                $f = \PDO::FETCH_NUM;
                break;
            default:
                throw new error_kernel_db("DB: El medoto de FETCH seleccionado es incorrecto: $fetch");
        }
        return $f;
    }

    function consultar($sql, $fetch=db::FETCH_ASSOC)
    {
        kernel::log()->add_debug('SQL', $sql);
        $fetch = $this->get_tipo_fetch($fetch);
        try {
			$statement = $this->conexion->query($sql);
            $datos = $statement->fetchAll($fetch);
			
			return $datos;
        } catch (\PDOException $e) {
			$ex = new error_kernel_db("SQL ERROR: " . $e->getMessage() . "\n$sql");
			if ($this->parametros['vendor'] != 'informix') {
				$ex->set_sqlstate($this->conexion->errorCode());
			}
			throw $ex;
        }
    }

    function consultar_fila($sql, $fetch=db::FETCH_ASSOC)
    {
        $data = $this->consultar($sql, $fetch);
        if ($data && isset($data[0]))
            return $data[0];
        return array();
    }

    function ejecutar($sql)
    {
		kernel::log()->add_debug('sql', $sql);
        try {
			return $this->conexion->exec($sql);
        } catch (\PDOException $e) {
            $ex = new error_kernel_db("SQL ERROR: " . $e->getMessage() . "\n$sql");
			if ($this->parametros['vendor'] != 'informix') {
				$ex->set_sqlstate($this->conexion->errorCode());
			}
			throw $ex;
        }
    }
	
    //------------------------------------------------------------------
    // Con statements
    //------------------------------------------------------------------
	
	function sentencia_consultar($sql, $parametros=null, $fetch=null)
	{
		try {
			kernel::log()->add_debug('sql', $sql);			
			kernel::log()->add_debug('parametros', var_export($parametros, true));			
			$stm = $this->conexion->prepare($sql);
			$stm->execute($parametros);
            $datos = $stm->fetchAll($fetch);
            return $datos;
		} catch (\PDOException $e) {
			$ex = new error_kernel_db("SQL ERROR: " . $e->getMessage() . "\n$sql");
			if ($this->parametros['vendor'] != 'informix') {
				$ex->set_sqlstate($this->conexion->errorCode());
			}
			throw $ex;
        }
	}
	
    function sentencia_consultar_fila($sql, $parametros=null, $fetch=null)
    {
        $data = $this->sentencia_consultar($sql, $parametros, $fetch);
        if ($data && isset($data[0]))
            return $data[0];
        return array();
    }	

	function sentencia_ejecutar($sql, $parametros=null, $fetch=null)
	{
		$afectados = 0;
		try {
			kernel::log()->add_debug('sql', $sql);			
			$stm = $this->conexion->prepare($sql);
			$stm->execute($parametros);
			$afectados += $stm->rowCount();
		} catch (\PDOException $e) {
            $ex = new error_kernel_db("SQL ERROR: " . $e->getMessage() . "\n$sql");
			if ($this->parametros['vendor'] != 'informix') {
				$ex->set_sqlstate($this->conexion->errorCode());
			}
			throw $ex;
        }
		return $afectados;
	}	

    function quote($parametro)
    {
		if ($this->parametros['vendor'] == 'informix') {
			return $this->quote_ifx($parametro);
		}
		
		return $this->conexion->quote($parametro);
    }
	
	protected function quote_ifx($parametro)
	{
		
		$search  = array("'");
		$replace = array("''");
		$quoted  = str_replace($search, $replace, $parametro);

		return "'".$quoted."'";
	}

	
	//------------------------------------------------------------------------
	//------------ TRANSACCIONES ---------------------------------------------
	//------------------------------------------------------------------------
	
	/**
	 * Ejecuta un BEGIN TRANSACTION en la conexión
	 */
	
	
	function abrir_transaccion()
	{
		$this->ejecutar('BEGIN WORK');
		//$this->conexion->beginTransaction();
		kernel::log()->add_debug("ABRIR transaccion", "base: ". $this->parametros['database']);
	}

	/**
	 * Ejecuta un ROLLBACK en la conexión
	 */	
	function abortar_transaccion($msj='')
	{
		$this->ejecutar('ROLLBACK WORK');
		//$this->conexion->rollBack();
		kernel::log()->add_debug("ABORTAR transaccion: " . $msj,"base: ". $this->parametros['database']);
	}
	
	/**
	 * Ejecuta un COMMIT en la conexión
	 */		
	function cerrar_transaccion()
	{
		$this->ejecutar('COMMIT WORK');		
		//$this->conexion->commit();
		kernel::log()->add_debug("CERRAR transaccion", "base: ". $this->parametros['database']);
	}

//------------------------------------------------------------------------
	function quote_like($str, $prepend = '', $append = '')
	{
		$str = $this->quote($str);
		$str = substr($str, 1, -1);
		$str = str_replace(array('%', '_'), array('\%', '\_'), $str);
		$str = $prepend.$str.$append;
		return "'$str'";
	}

    /**
     *	Recupera el valor actual de una secuencia
     *	@param string $secuencia Nombre de la secuencia
     *	@return string Siguiente numero de la secuencia
     */
    function recuperar_secuencia($secuencia, $ejecutar=true)
    {
        $sql = "SELECT currval('$secuencia') as seq;";
        if (! $ejecutar) { return $sql; }
        $datos = $this->consultar_fila($sql);
        return $datos['seq'];
    }
}

?>
