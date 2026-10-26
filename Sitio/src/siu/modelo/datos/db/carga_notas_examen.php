<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use siu\modelo\datos\util;
use kernel\kernel;
use kernel\util\db\db;
use siu\operaciones\_comun\util\caracteres_especiales;

class carga_notas_examen
{
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * cache_expiracion: 300
	 * filas: n
	 */
    function lista_actas_abiertas_docente($parametros)
    {
		//execute procedure sp_actasExaDocFol(5','987')
		$sql = "execute procedure sp_actasExaDocente({$parametros['_ua']}, ".
													"{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$id = catalogo::generar_id($dato[1].$dato[2]);
			$nuevo[$id][catalogo::id] = $id;
			$nuevo[$id]['TIPO_ACTA'] = $dato[1];
			$nuevo[$id]['ACTA'] = $dato[2];
			$nuevo[$id]['MATERIA'] = $dato[3];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[4];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[5];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato[6];
			$nuevo[$id]['MESA_EXAMEN'] = $dato[7];
			$nuevo[$id]['LLAMADO'] = $dato[8];
			$nuevo[$id]['DIA'] = $dato[9];
			$nuevo[$id]['HORA'] = $dato[10];
        }
		return $nuevo;	        
    }
	
	/**
	 * parametros: _ua, acta, tipo_acta 
	 * cache: memoria
	 * filas: n
	 */
	
	
	function porcentaje_carga_notas_acta_examen($parametros)
	{
		$sql = "SELECT SUM(CASE resultado WHEN NULL THEN 0 ELSE 1 END) * 100 / COUNT(*) AS porcentaje
				FROM sga_detalle_acta
				WHERE unidad_academica = {$parametros['_ua']}
				AND   acta = {$parametros['acta']}
				AND   tipo_acta = {$parametros['tipo_acta']}";
				
		$porc = current(kernel::db()->consultar_fila($sql, db::FETCH_NUM));
			
		return $porc;
	}

	/**
	 * parametros: _ua, tipo_acta, acta
	 * cache: memoria
	 * filas: 1
	 */
    function acta_cabecera($parametros) 
	{
		$sql = "execute procedure sp_cab_acta_examen({$parametros['_ua']},
													{$parametros['tipo_acta']},
													{$parametros['acta']})";
		$dato = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        $nuevo = array();
        if ($dato) {
			$nuevo[catalogo::id] = catalogo::generar_id($dato[1].$dato[2]);
            $nuevo['TIPO_ACTA'] = $dato[1];
            $nuevo['ACTA'] = $dato[2];
            $nuevo['MATERIA'] = $dato[3];
            $nuevo['MATERIA_NOMBRE'] = $dato[4];
            $nuevo['ANIO_ACADEMICO'] = $dato[5];
            $nuevo['TURNO_EXAMEN'] = $dato[6];
            $nuevo['MESA_EXAMEN'] = $dato[7];
            $nuevo['LLAMADO'] = $dato[8];
            $nuevo['LIBRO'] = $dato[9];
            $nuevo['DIA'] = $dato[10];
            $nuevo['HORA'] = $dato[11];
            $nuevo['ESCALA_NOTAS'] = $dato[14];
            $nuevo['SEDE'] = $dato[17];
            $nuevo['SEDE_NOMBRE'] = $dato[18];
            $nuevo['EDIFICIO_NOMBRE'] = $dato[12];
            $nuevo['AULA_NOMBRE'] = $dato[13];
            $nuevo['OBSERVACIONES'] = $dato[15];
            $nuevo['FOLIOS'] = $dato[16];
            $nuevo['ESTADO'] = $dato[20];
        }
        return $nuevo;
	}

    /**
	 * parametros: _ua, tipo_acta, acta, folio
	 * cache: no
	 * filas: 1
	 */
	function acta_folio($parametros) 
	{
		$sql = "execute procedure sp_detActExaDocFol({$parametros['_ua']}, ".
													"{$parametros['tipo_acta']},".
													"{$parametros['acta']},".
													"{$parametros['folio']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$img_mm = kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
		$nuevo = array();
		foreach($datos as $dato) {
			$renglon = $dato[6];
			$nuevo[$renglon]['TIPO_ACTA'] = $dato[1];
			$nuevo[$renglon]['ACTA'] = $dato[2];
			$nuevo[$renglon]['CARRERA'] = $dato[3];
			$nuevo[$renglon]['LEGAJO'] = $dato[4];
			$nuevo[$renglon]['FOLIO'] = $dato[5];
			$nuevo[$renglon]['RENGLON'] = $dato[6];
			$nuevo[$renglon]['TIPO_INSC'] = ($dato[7] == 'L') ? 'LIBRE' : 'REGULAR';
			$nuevo[$renglon]['FECHA'] = $dato[8];
			$nuevo[$renglon]['RESULTADO'] = $dato[9];
			$nuevo[$renglon]['NOTA'] = $dato[10];
			$nuevo[$renglon]['PLAN'] = $dato[11];
			$nuevo[$renglon]['VERSION'] = $dato[12];
			$nuevo[$renglon]['ESTADO_EXAMEN'] = $dato[13];
			$nuevo[$renglon]['NOTA_DESCRIPION'] = $dato[14];
			$nuevo[$renglon]['NOTA_CONCEPTO'] = $dato[15];
			$nuevo[$renglon]['NOMBRE'] = $dato[16];
			$nuevo[$renglon]['DOCUMENTO'] = $dato[17];
			$nuevo[$renglon]['ID_IMAGEN'] = $dato[18];
			if (!empty($nuevo[$renglon]['ID_IMAGEN'])) {
				$nuevo[$renglon]['URL_IMAGEN'] = \siu\modelo\entidades\alumno_foto::url_imagen($nuevo[$renglon]['ID_IMAGEN']);
			} else {
				$nuevo[$renglon]['URL_IMAGEN'] = $img_mm;
			}
		}
		return $nuevo;					
	}
	
    /**
	 * parametros: _ua, tipo_acta, acta, carrera, legajo, fecha, resultado, nota, nro_inscripcion
	 * param_tipo: str/5, str/20, str/20, str/5,	str/15,	str/20,	str/20, str/5,	str/10
	 * param_null: nota
	 * cache: no
	 * filas: 1
	 */
	function guardar_renglon($parametros) 
	{
		$parametros = util::formato_null($parametros);
        $sql = " EXECUTE PROCEDURE sp_u_examen_net(  {$parametros['_ua']},
													{$parametros['tipo_acta']},
													{$parametros['acta']},
													{$parametros['carrera']},
													{$parametros['legajo']},
                                                    {$parametros['fecha']},
                                                    {$parametros['resultado']},
                                                    {$parametros['nota']},
                                                    {$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;                                                         
    }
    
	/**
	 * parametros: _ua, tipo_acta, acta
	 * cache: no
	 * filas: 1
	 */
	function actualizar_acta($parametros) 
	{
        $sql = " EXECUTE PROCEDURE sp_actual_versacta({$parametros['_ua']},
													{$parametros['tipo_acta']},
													{$parametros['acta']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;  		
    }    
    
	/**
	 * parametros: _ua, acta, term
	 * cache: no
	 * no_quote: term
	 * filas: n
	 */
    function busqueda_alumno($parametros)
    {
        $termino = strtolower($parametros['term']);
		$term = kernel::db()->quote_like($termino, '%', '%');
        $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');
		
		$sql = "
				SELECT
					d.acta, d.folio, d.renglon, p.apellido || ', ' || p.nombres
				FROM 
					sga_detalle_acta as d,
					sga_alumnos as a, 
					sga_personas as p
				WHERE d.unidad_academica  = {$parametros['_ua']}
					AND d.acta = {$parametros['acta']}
					AND a.unidad_academica = d.unidad_academica
					AND a.carrera = d.carrera
					AND a.legajo = d.legajo
					AND p.unidad_academica = a.unidad_academica
					AND p.nro_inscripcion = a.nro_inscripcion
					AND (
                        LOWER(p.apellido) LIKE $term
                        OR LOWER(p.apellido) LIKE $term_sin_car_esp
                        )
		";
		return kernel::db()->consultar($sql, db::FETCH_NUM);
    }
	/*
	 * Busqueda utilizada en operacion actual
	 * 
		EXECUTE PROCEDURE sp_actasExaDocente(5','987')
		EXECUTE PROCEDURE sp_buscaalumnoacta(5',NULL,'6069','E','10827',NULL,'10827','N','A');
		EXECUTE PROCEDURE sp_buscaalumnoacta(5',NULL,'6069','E','10837',NULL,'10837','N','A');
		EXECUTE PROCEDURE sp_buscaalumnoacta(5',NULL,'6069','E','10836',NULL,'10836','N','A');
		EXECUTE PROCEDURE sp_buscaalumnoacta(5',NULL,'6069','E','10835',NULL,'10835','N','A');
	 * 
	 * -- Busca a un Alumno dentro de un Acta 
-- (Examen, Promocion, Cursada) y devuelve el nro de folio, renglon y mensaje.
-- Si el parametro pCarrera es nulo entonces busca para todas las carreras del 
-- alumno.
-- *****************************************************************************
-- DROP PROCEDURE sp_buscaalumnoacta;
CREATE PROCEDURE sp_buscaalumnoacta(pUA LIKE sga_alumnos.unidad_academica,
                                    pCarrera         LIKE sga_alumnos.carrera,
                                    pLegajo          LIKE sga_alumnos.legajo,
                                    pActa            CHAR(1),
                                    pNroActaReg      INTEGER,
                                    pNroActaPromo    INTEGER,
                                    pNroActaEx       VARCHAR(10),
                                    pTipoActa        CHAR(1),
                                    pEstadoActa      CHAR(1))
	 * 
	 */

	/**
	 * parametros: _ua, legajo, carrera
	 * cache: no
	 * filas: 1
	 */
	function get_datos_ficha($parametros)
	{
		$sql = "SELECT sga_personas.apellido || ' ' || sga_personas.nombres as nombre_alumno
				FROM sga_alumnos, sga_personas
				WHERE	sga_alumnos.unidad_academica = {$parametros['_ua']}
					AND sga_alumnos.carrera = {$parametros['carrera']}
					AND sga_alumnos.legajo = {$parametros['legajo']}
					AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
					AND sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion";
		return kernel::db()->consultar_fila($sql);
	}

	/**
	 * parametros: escala_nota, nota
	 * cache: no
	 * filas: 1
	 */
	function get_resultado_nota($parametros)
	{
		$sql = "SELECT resultado
				FROM sga_det_escala
				WHERE	sga_det_escala.escala_notas = {$parametros['escala_nota']}
					AND sga_det_escala.nota = {$parametros['nota']}";
		$dato = kernel::db()->consultar_fila($sql);
		return $dato['RESULTADO'];
	}
}
?>
