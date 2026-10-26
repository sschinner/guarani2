<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use \siu\modelo\datos\catalogo;

class matricula
{
	/**
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function periodos_reinscripcion() 
	{
		$sql = "EXECUTE PROCEDURE sp_ult_perins_act('R')";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: periodo_inscripcion
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function anio_academico_reinscripcion($parametros) 
	{
		$sql = "SELECT anio_academico
				FROM sga_periodo_insc
				WHERE periodo_inscripcio = {$parametros['periodo_inscripcion']};";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
	
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function carreras_a_reinscribirse($parametros) 
	{
		$sql = "EXECUTE PROCEDURE sp_r_pers_reins({$parametros["_ua"]}, 
												{$parametros["nro_inscripcion"]})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$nuevo[$dato[1]]['CARRERA'] = $dato[1];
			$nuevo[$dato[1]]['CARRERA_NOMBRE'] = $dato[9];
			$nuevo[$dato[1]]['ESTA_REINSCRIPTO'] = $dato[4];
		}
		return $nuevo;
	}	
	
	/**
	 * parametros: _ua, carrera, legajo
	 * cache: no
	 */
	function reinscripcion($parametros) 
	{
		$sql = "EXECUTE PROCEDURE sp_i_reinscripcion({$parametros["_ua"]},{$parametros["carrera"]},{$parametros["legajo"]},3)";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
	
    /**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function reinscripciones($parametros) 
	{
		$sql = "SELECT
                    sga_reinscripcion.nro_transaccion as nro_trans,
                    sga_reinscripcion.anio_academico as anio_academico,
                    sga_carreras.carrera as carrera,
                    sga_carreras.nombre as carrera_nombre,
                    sga_alumnos.legajo as legajo,
                    sga_reinscripcion.fecha_reinscrip as fecha_reinscrip,
                    to_char(sga_reinscripcion.fecha_reinscrip,'%d/%m/%Y') as sfecha_reinscrip
                FROM sga_alumnos,
                    sga_carreras,
                    sga_reinscripcion
                WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
                    AND sga_alumnos.nro_inscripcion = {$parametros['nro_inscripcion']}
                    AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
                    AND sga_carreras.carrera =  sga_alumnos.carrera
                    AND sga_reinscripcion.unidad_academica = sga_alumnos.unidad_academica
                    AND sga_reinscripcion.carrera =  sga_alumnos.carrera
                    AND sga_reinscripcion.legajo  = sga_alumnos.legajo
                ORDER BY 
                    sga_reinscripcion.fecha_reinscrip DESC, 
                    sga_carreras.nombre
                ";
                    
        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
        
        foreach($datos as $key => $value){
            if (isset($value['NRO_TRANS'])){
                $datos[$key][catalogo::id] = catalogo::generar_id($value['NRO_TRANS'].'-'.$value['CARRERA'].'-'.$value['S_FECHA_REINSC']);
            } else {
                $datos[$key][catalogo::id] = catalogo::generar_id($value['CARRERA'].'-'.$value['S_FECHA_REINSC']);
            }
        }
        return $datos;
	}
    
    /**
	 * parametros: _ua, nro_trans
	 * cache: no
	 */
	function datos_reinscripcion($parametros) 
	{               
        $sql = "SELECT
                    sga_reinscripcion.nro_transaccion as nro_trans,
                    sga_reinscripcion.anio_academico as anio_academico,
                    '(' || sga_carreras.carrera || ') ' || sga_carreras.nombre as carrera_nombre,
                    sga_alumnos.legajo as legajo,
                    sga_personas.apellido || ', ' || sga_personas.nombres as alumno_nombre,
                    DECODE(sga_personas.tipo_documento, 0, 'DNI', 2, 'CI', 18, 'LE', 19, 'LC', 90, 'Pas', 'DNI') || ' ' ||sga_personas.nro_documento as alumno_documento,
                    sga_reinscripcion.fecha_reinscrip as fecha_reinscrip,
                    to_char(sga_reinscripcion.fecha_reinscrip,'%d/%m/%Y') as sfecha_reinscrip,
                    sga_planes.plan || sga_planes.version_actual as plan,
                    sga_sedes.nombre as sede_nombre
                FROM 
                    sga_reinscripcion
                    JOIN sga_alumnos ON (
                        sga_reinscripcion.unidad_academica = sga_alumnos.unidad_academica AND
                        sga_reinscripcion.carrera =  sga_alumnos.carrera AND
                        sga_reinscripcion.legajo  = sga_alumnos.legajo
                        )
                    JOIN sga_sedes ON (sga_sedes.sede = sga_alumnos.sede)
                    JOIN sga_carreras ON (
                        sga_carreras.unidad_academica = sga_alumnos.unidad_academica AND 
                        sga_carreras.carrera =  sga_alumnos.carrera
                        )
                    JOIN sga_personas ON (
                        sga_personas.unidad_academica = sga_alumnos.unidad_academica AND 
                        sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion
                        )
                    JOIN sga_planes ON (
                        sga_planes.unidad_academica = sga_alumnos.unidad_academica  AND 
                        sga_planes.carrera = sga_alumnos.carrera  AND 
                        sga_planes.plan = sga_alumnos.plan 
                        )
                WHERE sga_reinscripcion.nro_transaccion =  {$parametros['nro_trans']}            
                ";
        
        return kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
	}
}
?>