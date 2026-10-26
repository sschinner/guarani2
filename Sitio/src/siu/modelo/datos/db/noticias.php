<?php

namespace siu\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;

class noticias
{

    /**
     * parametros: _ua, nro_inscripcion
     * cache: sesion
     * filas: n
     */
    function noticias_por_persona($parametros)
    {
        $sql = "SELECT not_noticias.html, not_noticias.vigencia_hasta
				FROM not_noticias_pers
				     JOIN not_noticias ON not_noticias.id_noticia = not_noticias_pers.id_noticia
				WHERE not_noticias_pers.unidad_academica = {$parametros['_ua']}
				AND	not_noticias_pers.nro_inscripcion = {$parametros['nro_inscripcion']}
				AND TODAY BETWEEN not_noticias.vigencia_desde AND not_noticias.vigencia_hasta
				ORDER BY not_noticias.vigencia_hasta";
				
 		// manejo de tipo de dato TEXT:
		$con = kernel::db()->conexion();
		$q = $con->prepare($sql);
		$q->execute();
		$q->bindColumn(1, $html, \PDO::PARAM_LOB);
		$datos = array();
		while ($q->fetch()) {
			$datos[]['HTML'] = stream_get_contents($html);
			}
       return $datos;

}

    /**
     * parametros: _ua, nro_inscripcion
     * cache: no
     * filas: 1
     */
    function tiene_noticias_por_persona($parametros)
    {
        $sql = "SELECT 1 AS tiene_noticias
				FROM not_noticias_pers
				     JOIN not_noticias ON (not_noticias.id_noticia = not_noticias_pers.id_noticia)
				WHERE not_noticias_pers.unidad_academica = {$parametros['_ua']}
				AND	not_noticias_pers.nro_inscripcion = {$parametros['nro_inscripcion']}
				AND TODAY BETWEEN not_noticias.vigencia_desde AND not_noticias.vigencia_hasta
				";

        $fila = kernel::db()->consultar_fila($sql);
        return isset($fila['TIENE_NOTICIAS']) ? true : false;
    }
}


