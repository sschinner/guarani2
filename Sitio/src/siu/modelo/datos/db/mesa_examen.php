<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;

class mesa_examen
{
 
 	/**
	 * parametros: _ua, materia, anio_academico, turno_examen, mesa_examen, llamado
	 * cache: memoria
	 * filas: n
	 */
	function get_docentes_mesa_examen($parametros)
	{
		// Recupera la lista de docentes asignados a una mesa de examen en un llamado
		$sql = "SELECT 
				sga_personas.unidad_academica as unidad_academica,
				sga_personas.nro_inscripcion as nro_inscripcion,
				sga_personas.apellido as apellido,
				sga_personas.nombres as nombres,
				sga_docentes.legajo as legajo,
				sga_docentes_llama.rol as rol,
				CASE sga_docentes_llama.rol
				   WHEN 'V' THEN 'Vocal'
				   WHEN 'P' THEN 'Presidente'
				   WHEN 'S' THEN 'Suplente'
				   ELSE ''
				END as responsab_desc 
			FROM
				sga_docentes_llama,
				sga_docentes,
				sga_personas
			WHERE sga_docentes_llama.unidad_academica = {$parametros['_ua']} 
			  AND sga_docentes_llama.materia = {$parametros['materia']} 
			  AND sga_docentes_llama.anio_academico = {$parametros['anio_academico']} 
			  AND sga_docentes_llama.turno_examen = {$parametros['turno_examen']} 
			  AND sga_docentes_llama.llamado = {$parametros['llamado']} 
			  AND sga_docentes_llama.mesa_examen = {$parametros['mesa_examen']} 
			  AND sga_docentes.legajo = sga_docentes_llama.legajo
			  AND sga_personas.unidad_academica = sga_docentes.unidad_academica
			  AND sga_personas.nro_inscripcion  = sga_docentes.nro_inscripcion
			ORDER BY  3, 4";

		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;
	}

}
?>