<?php
namespace kernel\util\db;

use kernel\kernel;
use kernel\error_kernel_db;

class dba
{
    /**
     * @return \kernel\util\db\interface_db
	 * 
	 * @todo: hay que probar que todas las conexiones funcionan igual
	 *			(incluir pruebas sobre windows y linux)
	 *			alcance: resultset, excepciones, locale
     */	
	static function conectar($params)
	{
        kernel::proyecto()->pre_conexion();
		kernel::log()->cronometro()->marcar('pre conexion');

		switch ($params['vendor']) {
			case 'informix_nativo':
				$db = new db_informix($params);
				break;
			case 'informix_nativo_persistente':
				$db = new db_informix($params, true);
				break;
			case 'odbc':
				$db = new db_pdo_odbc($params);
				break;
			case 'pgsql':
			case 'informix':
				$db = new db_pdo($params);
				break;
/*			case 'informix_odbc':
				$db = new db_pdo_informix_odbc($params);
				break;*/
			default:
				throw new error_kernel_db('Error en la configuracion de la base: motor incorrecto');
		}
		kernel::log()->cronometro()->marcar('conexion');
		$db_params = kernel::proyecto()->get_parametros_db();
		unset($db_params['pwd']);
		unset($db_params['pdo_passwd']);
		kernel::log()->add_debug('CONECTAR DB', $db_params);

        kernel::proyecto()->pos_conexion($db);
        kernel::log()->cronometro()->marcar('pos conexion');

		return $db;
	}
}
?>
