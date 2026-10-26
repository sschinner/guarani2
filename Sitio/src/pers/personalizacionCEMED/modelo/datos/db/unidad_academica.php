<?php

namespace personalizacionCEMED\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\caracteres_especiales;

class unidad_academica extends \siu\modelo\datos\db\unidad_academica
{
	
	/**
	 * parametros: _ua
	 * cache: no
	 * filas: n
	 */
	function datos_unidad_academica($parametros)
	{
		

        $sql = "SELECT * FROM sga_unidades_acad
                        WHERE unidad_academica = {$parametros['_ua']}";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
      
		return $datos;		
	}
}

