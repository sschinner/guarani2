<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use siu\modelo\datos\util;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\entidades\alumno_foto;
use siu\operaciones\_comun\util\caracteres_especiales;

class carga_notas_cursada
{
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * cache_expiracion: 300
	 * filas: n
	 */
    function lista_actas_abiertas_docente($parametros)
    {
		$sql = "execute procedure sp_actasCurDocente({$parametros['_ua']}, ".
													"{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$id = catalogo::generar_id($dato[1]);
			$nuevo[$id][catalogo::id] = $id;			
			$nuevo[$id]['ACTA_REG'] = $dato[1];
			$nuevo[$id]['ACTA_PRO'] = $dato[2];
			$nuevo[$id]['COMISION'] = $dato[3];
			$nuevo[$id]['COMISION_NOMBRE'] = $dato[4];
			$nuevo[$id]['MATERIA'] = $dato[5];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[6];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[7];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato[8];
			$nuevo[$id]['ESCALA_NOTAS'] = $dato[9];
	//		$nuevo[$id]['FOLIO'] = $dato[10];
	//		$nuevo[$id]['PORCENTAJE'] = $dato[11];
        }
		return $nuevo;	        
    }
	
	/**
	 * parametros: _ua, comision
	 * cache: memoria
	 * filas: n
	 */
	
	function porcentaje_carga_notas_comision($parametros)
	{
		$sql = "SELECT SUM(CASE resultado WHEN NULL THEN 0 ELSE 1 END) * 100 / COUNT(*) AS porcentaje
				FROM sga_curs_pendiente
				WHERE comision = {$parametros['comision']}";
		
		$porc = current(kernel::db()->consultar_fila($sql, db::FETCH_NUM));
		kernel::log()->add_debug('retorno porcentaje', $porc);
		
		return $porc;
	}
	

	/**
	 * parametros: _ua, acta
	 * cache: no
	 * filas: 1
	 */
    function acta_cabecera($parametros) 
	{
		$sql = "execute procedure sp_cab_actacursado({$parametros['_ua']}, {$parametros['acta']})";
		$dato = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        $nuevo = array();
        if ($dato) {
			$nuevo[catalogo::id] = catalogo::generar_id($dato[1]);
            $nuevo['ACTA_REG'] = $dato[1];
            $nuevo['ACTA_PRO'] = $dato[2];
            $nuevo['LIBRO'] = $dato[3];
            $nuevo['COMISION'] = $dato[4];
            $nuevo['URL_COMISION'] = catalogo::generar_id($dato[4]);
            $nuevo['COMISION_NOMBRE'] = $dato[5];
            $nuevo['MATERIA'] = $dato[6];
            $nuevo['MATERIA_NOMBRE'] = $dato[7];
            $nuevo['ANIO_ACADEMICO'] = $dato[8];
            $nuevo['PERIODO_LECTIVO'] = $dato[9];
            $nuevo['ESCALA_NOTAS'] = $dato[10];
            $nuevo['FECHA_INICIO'] = $dato[11];
            $nuevo['FECHA_FIN'] = $dato[12];
            $nuevo['ESTADO'] = $dato[20];
            $nuevo['FOLIOS'] = $dato[17];
			$nuevo['PROM_ABIERTA'] = !empty($nuevo['ACTA_PRO']) && $dato[13] == 'A';
			//$det_escala = $this->escala_notas(array('escala_notas'=>$nuevo['ESCALA_NOTAS']));
			//$nuevo['ESCALA_NOTAS_DETALLE'] = $det_escala;
        }
        return $nuevo;
	}

	/**
	 * parametros: _ua, acta
	 * cache: no
	 * filas: 1
	 */
	function acta_regular_estado($parametros){
		$sql = "SELECT estado FROM sga_actas_cursado WHERE sga_actas_cursado.unidad_academica = {$parametros['_ua']} AND sga_actas_cursado.acta = {$parametros['acta']}";
		$dato = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		if (isset($dato[0])){
			return $dato[0];
		}
		return false;
	}
	
    /**
	 * parametros: _ua, acta, folio
	 * cache: no
	 * filas: 1
	 */
	function acta_folio($parametros) 
	{
		$sql = "execute procedure sp_detActCurDocFol({$parametros['_ua']}, ".
													"{$parametros['acta']},".
													"{$parametros['folio']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $dato) {
			$renglon = $dato[13];
			$nuevo[$renglon][catalogo::id] = catalogo::generar_id($dato[1].$dato[2].$dato[3]);
			$nuevo[$renglon]['CARRERA'] = $dato[1];
			$nuevo[$renglon]['LEGAJO'] = $dato[2];
			$nuevo[$renglon]['COMISION'] = $dato[3];
			$nuevo[$renglon]['FECHA'] = $dato[6];
			$nuevo[$renglon]['CONDICION'] = $dato[7];
			$nuevo[$renglon]['RESULTADO'] = $dato[8];
			$nuevo[$renglon]['NOTA'] = $dato[9];
			$nuevo[$renglon]['ASISTENCIA'] = $dato[10];
			$nuevo[$renglon]['ACTA_REG'] = $dato[11];
			$nuevo[$renglon]['FOLIO'] = $dato[12];
			$nuevo[$renglon]['RENGLON'] = $dato[13];
			$nuevo[$renglon]['PROMOCIONAL'] = $dato[14];
			$nuevo[$renglon]['APELLIDO'] = $dato[15];
			$nuevo[$renglon]['NOMBRE'] = $dato[16];
			$nuevo[$renglon]['AGREGADO_A_ACTA'] = $dato[17];
			$nuevo[$renglon]['TIENE_NOTA'] = $dato[18];
			$nuevo[$renglon]['ID_IMAGEN'] = $dato[19];
			if (!empty($nuevo[$renglon]['ID_IMAGEN'])) {
				$nuevo[$renglon]['URL_IMAGEN'] = alumno_foto::url_imagen($nuevo[$renglon]['ID_IMAGEN']);
				$nuevo[$renglon]['URL_IMAGEN_GRANDE'] = alumno_foto::url_imagen($nuevo[$renglon]['ID_IMAGEN'], alumno_foto::TAMANIO_GRANDE);
			} else {
				$nuevo[$renglon]['URL_IMAGEN'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
				$nuevo[$renglon]['URL_IMAGEN_GRANDE'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm_grande.png');
			}
		}
		return $nuevo;					
	}
    
    /**
	 * parametros: _ua, carrera, legajo, comision, folio, renglon, fecha, condicion, nota, asistencia, promocional, fecha_inicio, nro_inscripcion_docente
	 * param_null: fecha, condicion, nota, asistencia
	 * param_tipo: str/5, str/5, str/10, int, int, int, str/15, int, str/5, int, int, str/15, str/10	
	 * cache: no
	 * filas: 1
	 */
	function guardar_renglon($parametros) 
	{
		$parametros = util::formato_null($parametros);
        $tipo_carga = 'MT';
        $sql = " EXECUTE PROCEDURE sp_u_regul_net(  
						{$parametros['_ua']},
						{$parametros['carrera']},
						{$parametros['legajo']},
						{$parametros['comision']},
						{$parametros['folio']},
						{$parametros['renglon']},
						{$parametros['fecha']},
						{$parametros['condicion']},
						{$parametros['nota']},
						{$parametros['asistencia']},
						{$parametros['promocional']},
						'$tipo_carga',
						{$parametros['fecha_inicio']},
						{$parametros['nro_inscripcion_docente']}) ";						
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;                                                         
    }
    
    /**
	 * parametros: comision
	 * cache: no
	 * filas: 1
	 */
	function actualizar_acta($parametros) 
	{
        $sql = " EXECUTE PROCEDURE sp_u_versactacur(  {$parametros['comision']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;  		
    }    
    
	/**
	 * cache: memoria
	 * filas: n
	 * --EXECUTE PROCEDURE sp_cond_reg_net(3')
	 */
	function condiciones_regularidad()
	{
		$sql ="SELECT cond_regularidad, descripcion, resultado, result_defecto	
		         FROM sga_cond_regular 
		         ORDER BY sga_cond_regular.resultado, sga_cond_regular.result_defecto";
		$datos = kernel::db()->consultar($sql);
		foreach(array_keys($datos) as $id) {
			$datos[$id]['DESCRIPCION'] = trim($datos[$id]['DESCRIPCION']);
		}
		return $datos;
	}
	
	/**
	 * parametros: comision, term
	 * no_quote: term
	 * cache: no
	 * filas: n
	 */
    function busqueda_alumno($parametros)
    {
        $termino = strtolower($parametros['term']);
		$term = kernel::db()->quote_like($termino, '%', '%');
        $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');
		
		$sql = "
			SELECT 
				c.acta_regular, c.folio_regular, c.renglon_regular, p.apellido || ', ' || p.nombres
			FROM 
				sga_curs_pendiente as c,
				sga_alumnos as a, 
				sga_personas as p
			WHERE c.comision = {$parametros['comision']}
					AND a.unidad_academica = c.unidad_academica
					AND a.carrera = c.carrera
					AND a.legajo = c.legajo
					AND p.unidad_academica = a.unidad_academica
					AND p.nro_inscripcion = a.nro_inscripcion
					AND (
                        LOWER(p.apellido) LIKE $term
                        OR LOWER(p.apellido) LIKE $term_sin_car_esp
                        )
		";
		return kernel::db()->consultar($sql, db::FETCH_NUM);
    }
	
	/**
	 * parametros: _ua, legajo, carrera, comision
	 * cache: no
	 * filas: n
	 */
	function get_datos_parciales($parametros)
	{
		$sql = "SELECT	sga_atr_eval_parc.evaluacion as evaluacion,
						sga_eval_parc.descripcion as evaluacion_desc,
						sga_tipo_eval_parc.descripcion as tipo_evaluacion,
						sga_eval_parc_alum.fecha_hora as fecha_hora_parcial,
						to_char(sga_eval_parc_alum.fecha_hora, '%d/%m/%Y') as sfecha,
						to_char(sga_eval_parc_alum.fecha_hora, '%Y%m%d') as sfecha_orden,
						sga_eval_parc_alum.nota as nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						sga_eval_parc_alum.resultado as resultado,
						DECODE( sga_eval_parc_alum.resultado, 'A', 'Aprobado' , 'R', 'Reprobado' , 'U', 'Ausente' , 'P', 'Promocionado' ) as resultado_desc,
						sga_eval_parc_alum.corregido_por as corregido_por,
						sga_eval_parc_alum.observaciones as observaciones
			      FROM 	sga_atr_eval_parc,
						sga_eval_parc,
						sga_tipo_eval_parc,
						sga_eval_parc_alum,
						OUTER sga_det_escala 

				WHERE	sga_eval_parc.evaluacion = sga_atr_eval_parc.evaluacion

				AND		sga_tipo_eval_parc.tipo_evaluac_parc = sga_eval_parc.tipo_evaluac_parc
				AND		sga_tipo_eval_parc.visible_al_alumno = 'S'

				AND		sga_eval_parc_alum.comision         = sga_atr_eval_parc.comision
				AND		sga_eval_parc_alum.evaluacion      = sga_atr_eval_parc.evaluacion

				AND		sga_det_escala.escala_notas = sga_atr_eval_parc.escala_notas
				AND		sga_det_escala.nota               = sga_eval_parc_alum.nota
       
				AND		sga_atr_eval_parc.comision			= {$parametros['comision']}
				AND		sga_eval_parc_alum.unidad_academica = {$parametros['_ua']}
				AND		sga_eval_parc_alum.carrera          = {$parametros['carrera']}
				AND		sga_eval_parc_alum.legajo           = {$parametros['legajo']}

       
				ORDER BY sga_eval_parc_alum.fecha_hora, sga_atr_eval_parc.evaluacion
     
				";
			return kernel::db()->consultar($sql);
	}	
	/**
	 * parametros: _ua, legajo, carrera
	 * cache: no
	 * filas: 1
	 */
	function get_datos_ficha($parametros)
	{
		$sql = "SELECT sga_personas.apellido || ' ' || sga_personas.nombres as nombre_alumno
                  FROM sga_alumnos, 
		               sga_personas
		         WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
				   AND sga_alumnos.carrera          = {$parametros['carrera']}
				   AND sga_alumnos.legajo           = {$parametros['legajo']}
				   AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
				   AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
				";
			return kernel::db()->consultar_fila($sql);
	}	
	/**
	 * parametros: condicion
	 * cache: no
	 * filas: 1
	 */
	function get_resultado_condicion($parametros)
	{
		$sql = "SELECT resultado
                  FROM sga_cond_regular
		         WHERE cond_regularidad = {$parametros['condicion']}";
			$datos = kernel::db()->consultar_fila($sql);
			return $datos['RESULTADO'];
	}	
	
}
?>
