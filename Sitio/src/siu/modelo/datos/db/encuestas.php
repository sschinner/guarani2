<?php
namespace siu\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\entidades\alumno_foto;
use siu\modelo\datos\catalogo;

class encuestas
{

	/**
	 * parametros: 
	 * cache: no
	 */
	function get_encuestas_a_asociar_con_kolla()
	{
		// recupero encuestas de Guarani 2 que no tengan asociado el id de encuesta de Kolla.
		// o encuestas que ya tengan el id de encuesta de kolla pero que no esten aun vinculadas
		// es decir que no se hayan creado habilitaciones. Esto por si se quiere modificar la asociacion de encuesta. 
		$sql = "SELECT
					encuesta,
					titulo,
					descripcion,
					kolla_id_encuesta,
			        (SELECT count(*) 
			           FROM gde_encues_alcance as a
			          WHERE a.encuesta = gde_encuestas.encuesta
			        ) as cant_alcances
				FROM gde_encuestas
			    WHERE (kolla_id_encuesta IS NULL OR
			          (SELECT count(*) FROM gde_encues_alcance as a
			           WHERE a.encuesta = gde_encuestas.encuesta
			            AND a.kolla_id_habilitacion IS NOT NULL
			           ) = 0
			         )  
				";
		$filas = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $filas;
	}

	/**
	 * parametros: encuesta, kolla_id_encuesta
	 * cache: no
	 */
	function asociar_kolla_id_encuesta($parametros)
	{
		// Actualiza el dato de ID de Encuesta de Kolla en Guarani
		$sql = "UPDATE gde_encuestas 
		           SET kolla_id_encuesta = {$parametros['kolla_id_encuesta']} 
		         WHERE encuesta = {$parametros['encuesta']}
		       ";
		
		return kernel::db()->ejecutar($sql);
	}



	/**
	 * parametros: alcance
	 * cache: no
	 */
	function get_habilitacion($parametros)
	{
		$sql = "SELECT
					titulo as descripcion,
					fecha_desde,
					fecha_hasta,
					anonima,
					kolla_id_habilitacion,
					kolla_password,
					kolla_sincronizar,
					unidad_academica
				FROM gde_encues_alcance
				WHERE alcance = {$parametros['alcance']}
				";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

		if (!empty($datos)) {
			return array(
				'descripcion'  => $datos[0],
				'fecha_desde'  => $datos[1],
				'fecha_hasta'  => $datos[2],
				'anonima'      => $datos[3],
				'habilitacion' => $datos[4],
				'password'     => $datos[5],
				'sincronizar'  => $datos[6],
//				'unidad_gestion' => $datos[8]
			);
		} else {
			return array();
		}
	}

	/**
	 * parametros: alcance, _ua
	 * cache: no
	 */
	function get_elementos($parametros)
	{
		$sql = "SELECT DISTINCT
					e.elemento,
					e.descripcion,
					CASE
						 WHEN e.legajo_docente IS NOT NULL AND sga_personas_foto.sincronizada = 1 THEN sga_personas.id_imagen
						 WHEN e.legajo_docente IS NOT NULL THEN 'DFLT'
						 ELSE cast(NULL as varchar(255))
					END as url_img,
					e.generado_en_kolla

					FROM
					   gde_formulario as f,
					   gde_formulario_det as fd,
					   gde_elemento as e,
					   OUTER (sga_docentes, sga_personas_foto, sga_personas)
					  WHERE f.alcance = {$parametros['alcance']}
					   AND fd.formulario = f.formulario
					   AND e.elemento = fd.elemento
					   AND sga_docentes.legajo = e.legajo_docente
					   AND sga_personas_foto.unidad_academica = sga_docentes.unidad_academica
					   AND sga_personas_foto.nro_inscripcion  = sga_docentes.nro_inscripcion
					   AND sga_personas.unidad_academica = sga_docentes.unidad_academica
					   AND sga_personas.nro_inscripcion = sga_docentes.nro_inscripcion
				";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$elementos = array();
		if (!empty($datos)) {
			foreach ($datos as $e) {
				$elementos[] = array(
					'id'                => $e[0], //para usarse en el actualizar_elementos
					'elemento'          => $e[0],
					'descripcion'       => $e[1],
					'url_img'           => $e[2],
					'generado_en_kolla' => $e[3],
				);
			}
		}

		//meto esta logica aca porque se supone que el get_elementos devuelva los elementos listos para ir a kolla
		//IMAGENES DOCENTES
		$foto_default = alumno_foto::url_imagen_relativa_kolla(null);

		foreach($elementos as &$elemento){
			$foto = $elemento['url_img'];
			if($foto == 'DFLT'){
				$elemento['url_img'] = $foto_default;
			}else if(empty($foto)){
				$elemento['url_img'] = null;
			}else {
				$elemento['url_img'] = alumno_foto::url_imagen_relativa_kolla($foto);
			}
		}
		return $elementos;
	}

	/**
	 * parametros: alcance, _ua, ids
	 * no_quote: ids
	 * cache: no
	 */
	function actualizar_elementos($parametros)
	{
		if (!empty($parametros['ids'])) {
			$IN = implode(',', $parametros['ids']);
		} else {
			return 0;
		}

		$sql = "UPDATE gde_elemento SET generado_en_kolla = 'S'
					WHERE elemento IN ($IN)
					AND generado_en_kolla = 'N'";

		return kernel::db()->ejecutar($sql);
	}

	/**
	 * parametros: alcance, _ua
	 * cache: no
	 */
	function get_conceptos($parametros)
	{
		$sql = "-- Conceptos usados en una habilitacion
			SELECT DISTINCT
			  c.concepto,
			  c.descripcion,
			  c.generado_en_kolla,  -- S = Si / N = No
			  {$parametros['_ua']} as unidad_gestion
			  FROM
			   gde_formulario as f,
			   gde_concepto as c
			  WHERE f.alcance = {$parametros['alcance']}
			   AND c.concepto = f.concepto";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$elementos = array();
		if (!empty($datos)) {
			foreach ($datos as $e) {
				$elementos[] = array(
					'id'                => $e[0], //para usarse en el actualizar_conceptos
					'concepto'          => $e[0],
					'descripcion'       => $e[1],
					'generado_en_kolla' => $e[2],
				);
			}
		}
		return $elementos;
	}

	/**
	 * parametros: alcance, _ua, ids
	 * no_quote: ids
	 * cache: no
	 */
	function actualizar_conceptos($parametros)
	{
		if (!empty($parametros['ids'])) {
			$IN = implode(',', $parametros['ids']);
		} else {
			return 0;
		}

		$sql = "UPDATE gde_concepto SET generado_en_kolla = 'S'
					WHERE concepto IN ($IN)
					AND generado_en_kolla = 'N'";

		return kernel::db()->ejecutar($sql);
	}


	/**
	 * parametros: alcance, _ua
	 * cache: no
	 */
	function get_formularios($parametros)
	{
		$sql = "SELECT
				 gde_formulario.formulario,
				 gde_formulario.nombre,
				 gde_formulario.concepto,
				 gde_formulario.estado,
				 gde_encuestas.kolla_id_encuesta,
				 gde_formulario_det.elemento,
				 gde_formulario_det.orden,
				 gde_formulario.generado_en_kolla
			 FROM
				  gde_formulario,
				  gde_formulario_det,
				  gde_encuestas
			 WHERE gde_formulario.alcance = {$parametros['alcance']}
				   AND gde_formulario_det.formulario = gde_formulario.formulario
				   AND gde_formulario_det.encuesta = gde_encuestas.encuesta

			 ORDER BY gde_formulario.formulario, 
			          gde_formulario_det.orden
			   ";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$formularios = array();
		if (!empty($datos)) {
			foreach ($datos as $f) {
				if(!isset($formularios[$f[0]])){
					$formularios[$f[0]] = array(
						'id'                => $f[0],
						'formulario'        => $f[0],
						'nombre'           => $f[1],
						'concepto'          => $f[2],
						'generado_en_kolla' => $f[7],
						'detalle'           => array()
					);
				}
				$formularios[$f[0]]['detalle'][] = array(
					'encuesta' => $f[4],
					'elemento' => $f[5],
					'orden'    => $f[6],
				);
			}
		}
		return array_values($formularios);
	}

	/**
	 * parametros: alcance, _ua, ids
	 * no_quote: ids
	 * cache: no
	 */
	function actualizar_formularios($parametros)
	{
		if (!empty($parametros['ids'])) {
			$IN = implode(',', $parametros['ids']);
		} else {
			return 0;
		}

		$sql = "UPDATE gde_formulario SET generado_en_kolla = 'S'
					WHERE formulario IN ($IN)
					AND generado_en_kolla = 'N'";

		return kernel::db()->ejecutar($sql);
	}


	/**
	 * parametros: alcance
	 * cache: no
	 */
	function get_alcance($parametros)
	{
		$sql = "SELECT gde_encuestas.encuesta,
                       gde_encuestas.titulo as encuesta_titulo,
                       gde_encuestas.kolla_id_encuesta,
                       gde_encues_alcance.alcance,
                       gde_encues_alcance.titulo as alcance_titulo,
                       to_char(gde_encues_alcance.fecha_desde, '%d/%m/%Y') as fecha_desde,
                       to_char(gde_encues_alcance.fecha_hasta, '%d/%m/%Y') as fecha_hasta
                FROM gde_encues_alcance JOIN gde_encuestas ON (gde_encuestas.encuesta = gde_encues_alcance.encuesta)
                WHERE gde_encues_alcance.alcance = {$parametros['alcance']}";

		$fila = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
		return $fila;
	}

    /**
     * parametros:
     * cache: no
     */
    function alcances_a_vincular()
    {
        $sql = "SELECT gde_encuestas.encuesta,
                       gde_encuestas.titulo as encuesta_titulo,
                       gde_encuestas.kolla_id_encuesta,
                       gde_encues_alcance.alcance,
                       gde_encues_alcance.titulo as alcance_titulo,
                       to_char(gde_encues_alcance.fecha_desde, '%d/%m/%Y') as fecha_desde,
                       to_char(gde_encues_alcance.fecha_hasta, '%d/%m/%Y') as fecha_hasta
                FROM gde_encues_alcance JOIN gde_encuestas ON (gde_encuestas.encuesta = gde_encues_alcance.encuesta)
                WHERE gde_encues_alcance.kolla_sincronizar = 'S'
                AND gde_encuestas.kolla_id_encuesta IS NOT NULL
                AND gde_encues_alcance.fecha_hasta >= TODAY
                ORDER BY gde_encuestas.encuesta, gde_encues_alcance.alcance";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        return $datos;
    }

    /**
     * parametros: alcance
     * cache: no
     */
    function existe_alcance($parametros)
    {
        $sql = "SELECT COUNT(*)
                FROM gde_encues_alcance JOIN gde_encuestas ON (gde_encuestas.encuesta = gde_encues_alcance.encuesta)
                WHERE gde_encues_alcance.kolla_sincronizar = 'S'
                AND gde_encuestas.kolla_id_encuesta IS NOT NULL
                AND gde_encues_alcance.fecha_hasta >= TODAY
                AND gde_encues_alcance.alcance = {$parametros['alcance']}";

        $dato = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return ($dato[0] == 0)? false : true;
    }

	/**
	 * parametros: alcance, id_habilitacion, password
	 * cache: no
	 */
	function actualizar_alcance_ws($parametros)
	{
		$sql = "UPDATE gde_encues_alcance 
				SET kolla_id_habilitacion = {$parametros['id_habilitacion']},
				    kolla_password = {$parametros['password']}
				WHERE alcance = {$parametros['alcance']}";

		return kernel::db()->ejecutar($sql);
	}

	/**
	 * parametros: alcance
	 * cache: no
	 */
	function actualizar_alcance_sincronizado($parametros)
	{
		// Marca como sincronizado con Kolla un alcance, solo cuando ya se le vinculó la habilitacion
		// y ademas no le quedan formularios sin sincronizar.
		$sql = "UPDATE gde_encues_alcance 
			   	   SET kolla_sincronizar = 'N'
				 WHERE alcance = {$parametros['alcance']}
				   AND kolla_id_habilitacion IS NOT NULL
				   AND NOT EXISTS (SELECT 1 FROM gde_formulario as f 
				                    WHERE f.alcance = {$parametros['alcance']}
				                      AND f.generado_en_kolla = 'N')
			   ";

		return kernel::db()->ejecutar($sql);
	}


	/**
	 * parametros: respuesta, _ua, nro_inscripcion, fecha_respuesta
     * param_null: fecha_respuesta
     * cache: no
	 */
	function marcar_respondida($parametros)
	{
        $fecha_respuesta = ($parametros['fecha_respuesta'] == "''")? 'current' : "TO_DATE({$parametros['fecha_respuesta']}, '%Y-%m-%d')";

        $sql = "UPDATE gde_encues_persona
			SET fecha_respuesta = $fecha_respuesta
			WHERE respuesta = {$parametros['respuesta']}
			and  unidad_academica = {$parametros['_ua']}
			and  nro_inscripcion = {$parametros['nro_inscripcion']}
			AND fecha_respuesta IS NULL";

		return kernel::db()->ejecutar($sql);
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 */
	function encuestas_pendientes($parametros)
	{ // Visualiza encuestas pendientes de responder y respondidas de la comision para un alumno o encuestas genericas...

		// Se debe agrupar las encuestas por el campo "id_grupo"
		// En el listado que se despliega se debe mostrar el campo "formulario_titulo"
		// Si desplegar_encuestas:
		//               1 = Se deberá tener la opcion de desplegar las encuestas asociadas con la materia
		//               0 = Se deberá mostrar directamente el link de la encuesta ya que es una encuesta genérica
		kernel::log()->add_debug('parametros encuesta un alumno y materia', $parametros);
		$sql = "SELECT 
				ea.kolla_id_habilitacion,
				ea.kolla_password,
				p.respuesta as id, 
                CASE
				  WHEN gde_concepto.tipo_concepto = 5 THEN sga_materias.nombre  
				  ELSE cast(null as varchar(255)) 
				END as titulo_grupo,
				CASE
				  WHEN gde_concepto.tipo_concepto = 5 THEN '---' || sga_comisiones.comision || '---'  -- Agrega las lineas para que no haya duplicados
				  ELSE  cast(p.respuesta as varchar(30))
				END as id_grupo,
				CASE
				  WHEN gde_concepto.tipo_concepto = 5 THEN 1  -- Comision
				  ELSE  0
				END as desplegar_encuestas,
				f.formulario as formulario,    -- ex item
				p.respuesta as respuesta,
				e.titulo as encuesta_titulo,
				f.nombre as formulario_titulo, -- ex item_titulo
				(CASE WHEN p.fecha_respuesta IS NOT NULL THEN 1 ELSE 0 END) as encuesta_respondida,
				ea.titulo as alcance_titulo,
				to_char(ea.fecha_hasta,'%d/%m/%Y') as vencimiento
				FROM 
				    gde_encues_persona as p,
					sga_personas as dp,
					gde_formulario as f,
					OUTER (gde_concepto, sga_comisiones, sga_materias, sga_materias as sga_materias2),
					gde_encues_alcance as ea,
					gde_encuestas as e
				WHERE p.unidad_academica = {$parametros['_ua']}
				AND p.nro_inscripcion  = {$parametros['nro_inscripcion']}
				AND dp.unidad_academica = p.unidad_academica
				AND dp.nro_inscripcion = p.nro_inscripcion
				AND f.formulario = p.formulario
				AND f.estado = 'A'                   -- Formularios activos
				AND f.generado_en_kolla = 'S'        -- Formularios generados en Kolla
				AND gde_concepto.concepto = f.concepto
				
				-- El concepto corresponde a una comision
				AND sga_comisiones.comision = gde_concepto.comision
				AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
				AND sga_materias.materia          = sga_comisiones.materia 
				
				-- El concepto corresponde a una materia
				AND sga_materias2.unidad_academica = gde_concepto.unidad_academica  
				AND sga_materias2.materia          = gde_concepto.materia 
				
				AND ea.alcance = f.alcance
				AND e.encuesta = ea.encuesta
				AND (gde_concepto.tipo_concepto = 5 OR                               -- encuestas sobre las comisiones (materia o actuacion docente)
				     (f.concepto IS NULL OR (gde_concepto.tipo_concepto <> 5 AND p.fecha_respuesta IS NULL)) -- Encuestas genericas sin contestar
				    )
				AND TODAY BETWEEN ea.fecha_desde AND ea.fecha_hasta
				AND ea.kolla_id_habilitacion IS NOT NULL
		        AND p.fecha_respuesta IS NULL
				-- AND ea.kolla_sincronizar = 'S'    -- Ya estoy recuperando solo formularios que ya estan en kolla...
				ORDER BY 3, 4";

		// AND ea.activo  = 'S'

		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

		kernel::log()->add_debug('datos', $datos);
		return $datos;
	}


    /**
     * parametros: _ua, nro_inscripcion, fecha_desde, fecha_hasta, legajo_docente, materia
     * param_null: fecha_desde, fecha_hasta, legajo_docente, materia
     * cache: no
     */
	function encuestas_respondidas($parametros)
	{ // Visualiza el listado de encuestas respondidas por el alumno/docente

        $filtro_fecha_desde = "";
        $filtro_fecha_hasta = "";
        $filtro_materia = "";
        $from_materia = "";
        $filtro_docente = "";

		if($parametros['fecha_desde'] != "''") $filtro_fecha_desde = " AND date(p.fecha_respuesta) >= to_date({$parametros['fecha_desde']}, '%d/%m/%Y') ";
        if($parametros['fecha_hasta'] != "''") $filtro_fecha_hasta = " AND date(p.fecha_respuesta) <= to_date({$parametros['fecha_hasta']}, '%d/%m/%Y') ";

        if($parametros['materia'] != "''") {
        	 $from_materia   = ", gde_concepto as concepto_filtro ";
        	 $filtro_materia = " AND (concepto_filtro.concepto = f.concepto AND concepto_filtro.tipo_concepto IN (3,5,6,8) AND concepto_filtro.materia = {$parametros['materia']} )";
        }	 

        if($parametros['legajo_docente'] != "''") $filtro_docente = " AND EXISTS (SELECT 1 FROM gde_formulario_det as fd, gde_elemento as ele
                                            WHERE fd.formulario = f.formulario
                                              AND ele.elemento = fd.elemento
                                              AND ele.tipo_elemento = 4 -- Docente
                                              AND ele.legajo_docente = {$parametros['legajo_docente']})";
		
		$sql = "SELECT 
				p.respuesta as respuesta,
				p.fecha_respuesta as fecha_respuesta,
				to_char(p.fecha_respuesta,'%d/%m/%Y %H:%M:%S') as sfecha_respuesta,
				e.kolla_id_encuesta as kolla_id_encuesta,
				ea.kolla_id_habilitacion as kolla_id_habilitacion,
				ea.kolla_password as kolla_password,
				ea.anonima as anonima,
				ea.anio_academico as anio_academico,
				ea.periodo_lectivo as periodo_lectivo,
				ea.turno_examen as turno_examen,
				f.formulario as formulario,
				e.titulo as encuesta_titulo,
				f.nombre as formulario_titulo, 
				ea.titulo as alcance_titulo,
                CASE
				  WHEN gde_concepto.tipo_concepto = 3 THEN sga_materias.nombre  
				  WHEN gde_concepto.tipo_concepto = 5 THEN sga_materias.nombre  
				  WHEN gde_concepto.tipo_concepto = 6 THEN sga_materias.nombre  
				  WHEN gde_concepto.tipo_concepto = 8 THEN sga_materias.nombre  
				  ELSE cast(null as varchar(255)) 
				END as materia_nombre
				FROM 
				    gde_encues_persona as p,
					sga_personas as dp,
					gde_formulario as f,
					OUTER (gde_concepto, sga_materias),
					gde_encues_alcance as ea,
					gde_encuestas as e
					$from_materia
				WHERE p.unidad_academica = {$parametros['_ua']}
				AND p.nro_inscripcion  = {$parametros['nro_inscripcion']}
				AND p.fecha_respuesta IS NOT NULL
				$filtro_fecha_desde
				$filtro_fecha_hasta
				AND dp.unidad_academica = p.unidad_academica
				AND dp.nro_inscripcion = p.nro_inscripcion
				AND f.formulario = p.formulario
				AND f.estado = 'A'                   -- Formularios activos
				AND f.generado_en_kolla = 'S'        -- Formularios generados en Kolla
				
				-- El concepto corresponde a una materia, comision o mesa de examen
				AND gde_concepto.concepto = f.concepto
				AND sga_materias.unidad_academica = gde_concepto.unidad_academica  
				AND sga_materias.materia          = gde_concepto.materia 
				
				AND ea.alcance = f.alcance
				AND e.encuesta = ea.encuesta
				AND ea.kolla_id_habilitacion IS NOT NULL

				$filtro_materia
				$filtro_docente

				ORDER BY fecha_respuesta DESC, encuesta_titulo, formulario_titulo";

        return kernel::db()->consultar($sql, db::FETCH_ASSOC);
	}

	/**
	 * parametros: habilitacion
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: 1
	 */
	function password_habilitacion($parametros)
	{
		$sql = "SELECT	kolla_password
				  FROM gde_encues_alcance
				 WHERE kolla_id_habilitacion = {$parametros['habilitacion']}";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}

    /**
     * parametros:
     * cache: no
     */
    function encuestas_alcances_con_habilitaciones($parametros)
    {
        //Recupera encuestas con Habilitaciones vigentes, futuras o que finalizaron en estos ultimos 15 dias...

        $sql = "SELECT
                   gde_encuestas.encuesta,
                   gde_encuestas.titulo as encuesta_titulo,
                   gde_encuestas.kolla_id_encuesta,
                   gde_encues_alcance.alcance,
                   gde_encues_alcance.titulo as alcance_titulo,
                   to_char(gde_encues_alcance.fecha_desde, '%d/%m/%Y') as fecha_desde,
                   to_char(gde_encues_alcance.fecha_hasta, '%d/%m/%Y') as fecha_hasta,
                   gde_encues_alcance.anio_academico,
                   gde_encues_alcance.periodo_lectivo,
                   /*(SELECT COUNT(*)
                      FROM gde_encues_persona, gde_items
                     WHERE gde_encues_persona.item = gde_items.item
                       AND alcance = gde_items.alcance
                       AND fecha_respuesta IS NOT NULL
                   ) as cant_encuestas_respondidas,
                   (SELECT COUNT(*)
                      FROM gde_encues_persona, gde_items
                     WHERE gde_encues_persona.item = gde_items.item
                       AND alcance = gde_items.alcance
                       AND fecha_respuesta IS NULL
                   ) as cant_encuestas_sin_responder,*/
                   gde_encues_alcance.kolla_id_habilitacion,
                   gde_encues_alcance.kolla_password,
                   gde_encues_alcance.fecha_desde as fecha_desde_orden
                FROM gde_encuestas
                     JOIN gde_encues_alcance ON (gde_encues_alcance.encuesta = gde_encuestas.encuesta)
                WHERE gde_encues_alcance.fecha_hasta >= (TODAY - 15)
                  AND gde_encues_alcance.kolla_id_habilitacion IS NOT NULL
                ORDER BY gde_encuestas.encuesta, gde_encues_alcance.fecha_desde
                ";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        return $datos;
    }

    /**
     * parametros: alcance
     * cache: no
     */
    function get_alcance_by_id($parametros)
    {
        $sql = "SELECT
                   gde_encues_alcance.alcance,
                   gde_encues_alcance.titulo as alcance_titulo,
                   to_char(gde_encues_alcance.fecha_desde, '%d/%m/%Y') as fecha_desde,
                   to_char(gde_encues_alcance.fecha_hasta, '%d/%m/%Y') as fecha_hasta,
                   gde_encues_alcance.anio_academico,
                   gde_encues_alcance.periodo_lectivo,
                   gde_encues_alcance.kolla_id_habilitacion,
                   gde_encues_alcance.kolla_password
                FROM gde_encues_alcance
                WHERE gde_encues_alcance.alcance = {$parametros['alcance']}
                AND gde_encues_alcance.fecha_hasta >= (TODAY - 15)
                AND gde_encues_alcance.kolla_id_habilitacion IS NOT NULL";

        $fila = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);

        return $fila;
    }

    /**
     * parametros: alcance, fecha_desde, fecha_hasta
     * param_null: fecha_desde, fecha_hasta
     * no_quote: alcance, fecha_desde, fecha_hasta
     * cache: no
     */
    function actualizar_fechas_alcance($parametros)
    {
        if($parametros['fecha_desde'] && $parametros['fecha_hasta']){
            $sql = "UPDATE gde_encues_alcance SET gde_encues_alcance.fecha_desde = to_date('{$parametros['fecha_desde']}', '%Y-%m-%d'), gde_encues_alcance.fecha_hasta = to_date('{$parametros['fecha_hasta']}', '%Y-%m-%d') WHERE gde_encues_alcance.alcance = {$parametros['alcance']}";
        }
        elseif($parametros['fecha_desde']){
            $sql = "UPDATE gde_encues_alcance SET gde_encues_alcance.fecha_desde = to_date('{$parametros['fecha_desde']}', '%Y-%m-%d') WHERE gde_encues_alcance.alcance = {$parametros['alcance']}";
        }
        elseif($parametros['fecha_hasta']){
            $sql = "UPDATE gde_encues_alcance SET gde_encues_alcance.fecha_hasta = to_date('{$parametros['fecha_hasta']}', '%Y-%m-%d') WHERE gde_encues_alcance.alcance = {$parametros['alcance']}";
        }

        return kernel::db()->ejecutar($sql);
    }

	/**
	 * parametros: anio_academico, periodo_lectivo, turno_examen, materia, legajo_docente
	 * param_null: periodo_lectivo, turno_examen, materia
	 * cache: no
	 */
	function reporte_encuestas_actuacion_docente($parametros)
	{ // Visualiza el listado de encuestas donde el docente forma parte del objeto de la encuesta.
		// Usado en la oepracion de ver resultados de las encuestas

		$from_turno_examen = "";
		$filtro_turno_examen = "";
		$from_periodo_lectivo = "";
		$filtro_periodo_lectivo = "";
		$filtro_materia = "";
		$sql_todos = "";
		$sql_perlect = "";
		$sql_turnoex = "";

		if($parametros['turno_examen'] != "''") {
			$filtro_turno_examen  = " AND sga_llamados_mesa.anio_academico = {$parametros['anio_academico']} 
                                      AND sga_llamados_mesa.turno_examen = {$parametros['turno_examen']} ";
		}
		if($parametros['periodo_lectivo'] != "''") {
			$filtro_periodo_lectivo   = " AND sga_comisiones.anio_academico = {$parametros['anio_academico']} 
                                          AND sga_comisiones.periodo_lectivo = {$parametros['periodo_lectivo']} ";
		}

		if($parametros['materia'] != "''") {
			$filtro_materia   = " AND c.materia = {$parametros['materia']} ";
		}

		// Recupera las encuestas segun filtro ingresado y donde el docente es objeto de la encuesta
		$sql_todos = "SELECT 
                e.encuesta as encuesta,
                e.titulo as encuesta_titulo,
                ea.alcance as alcance, 
                ea.titulo as alcance_titulo,
                f.formulario as formulario,
                f.nombre as formulario_titulo, 
                ele.elemento as elemento_externo,
                e.kolla_id_encuesta as kolla_id_encuesta,
                ea.kolla_id_habilitacion as kolla_id_habilitacion,
                ea.kolla_password as kolla_password,
                ea.alcance || '-' || f.formulario as id_form_alc,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario) as cant_encuestados,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario AND ep.fecha_respuesta IS NOT NULL) as cant_respondidas,
                CASE
                   WHEN c.tipo_concepto = 3 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 5 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 6 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 8 THEN sga_materias.nombre  
                   ELSE cast(null as varchar(255)) 
                END as materia_nombre,
                CASE ea.generar
                   WHEN 'D' THEN sga_comisiones.periodo_lectivo   
                   WHEN 'X' THEN sga_comisiones.periodo_lectivo
                   WHEN 'E' THEN to_char(sga_prestamos.fecha, '%d/%m/%Y')
                END as per_lect_examen,
				'D' as tipo_encuesta
                
                FROM
                    gde_encuestas as e,
                    gde_encues_alcance as ea,
                    gde_concepto as c,
                    OUTER sga_materias,
                    gde_formulario as f,
                    gde_formulario_det as fd,
                    gde_elemento as ele,
                    OUTER sga_comisiones,
                    OUTER (sga_llamados_mesa, sga_prestamos)
                WHERE ea.encuesta = e.encuesta
                  AND ea.anio_academico = {$parametros['anio_academico']}
                  AND ea.kolla_id_habilitacion IS NOT NULL
                  AND ea.generar IN ('E','D','X')     --  Actuacion academica de los docentes en Comisiones y Mesas de Examen
                  AND f.alcance = ea.alcance
                  AND f.estado = 'A'              -- Formularios activos
                  AND f.generado_en_kolla = 'S'   -- Formularios generados en Kolla
                  AND c.concepto = f.concepto
                  $filtro_materia
                  
                  AND sga_materias.unidad_academica = c.unidad_academica
                  AND sga_materias.materia = c.materia
                  
                  AND sga_comisiones.comision = c.comision 
                  $filtro_periodo_lectivo
                  
                  AND sga_llamados_mesa.id_llamado_mesa = c.id_llamado_mesa
                  AND sga_prestamos.prestamo = sga_llamados_mesa.prestamo
                  $filtro_turno_examen
                 
                  -- formularios que tengan como elemento al docente
                  AND fd.formulario = f.formulario 
                  AND ele.elemento = fd.elemento
                  AND ele.tipo_elemento = 4 
                  AND ele.legajo_docente = {$parametros['legajo_docente']}

			  UNION ALL

			  -- Cursadas - Encuestas sobre la materia donde esta asignado el docente
			  SELECT 
                e.encuesta as encuesta,
                e.titulo as encuesta_titulo,
                ea.alcance as alcance, 
                ea.titulo as alcance_titulo,
                f.formulario as formulario,
                f.nombre as formulario_titulo, 
                ele.elemento as elemento_externo,
                e.kolla_id_encuesta as kolla_id_encuesta,
                ea.kolla_id_habilitacion as kolla_id_habilitacion,
                ea.kolla_password as kolla_password,
                ea.alcance || '-' || f.formulario as id_form_alc,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario) as cant_encuestados,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario AND ep.fecha_respuesta IS NOT NULL) as cant_respondidas,
                CASE
                   WHEN c.tipo_concepto = 3 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 5 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 6 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 8 THEN sga_materias.nombre  
                   ELSE cast(null as varchar(255)) 
                END as materia_nombre,
                  sga_comisiones.periodo_lectivo  as per_lect_examen,
				 'C' as tipo_encuesta
                
                FROM
                    gde_encuestas as e,
                    gde_encues_alcance as ea,
                    gde_concepto as c,
                    OUTER sga_materias,
                    gde_formulario as f,
                    gde_formulario_det as fd,
                    gde_elemento as ele,
                    sga_comisiones,
					sga_docentes_com
                WHERE ea.encuesta = e.encuesta
                  AND ea.anio_academico = {$parametros['anio_academico']}
                  AND ea.kolla_id_habilitacion IS NOT NULL
                  AND ea.generar = 'I'            --  Una encuesta por cada materia cursada de un período lectivo
                  AND f.alcance = ea.alcance
                  AND f.estado = 'A'              -- Formularios activos
                  AND f.generado_en_kolla = 'S'   -- Formularios generados en Kolla
                  AND c.concepto = f.concepto
                  $filtro_materia
                  
                  AND sga_materias.unidad_academica = c.unidad_academica
                  AND sga_materias.materia = c.materia
                  
                  AND sga_comisiones.comision = c.comision 
                  $filtro_periodo_lectivo
                  
				  -- El docente pertenece a la comision
				  AND sga_docentes_com.comision = sga_comisiones.comision
				  AND sga_docentes_com.legajo = {$parametros['legajo_docente']}
				  
                  -- formularios que tengan como elemento a la materia de la comision. Estas encuestas solo tienen un elemento.
                  AND fd.formulario = f.formulario 
                  AND ele.elemento = fd.elemento
                  AND ele.tipo_elemento = 3  -- Materia 
				
                 ";

		// Solo periodos lectivos
		if ($parametros['periodo_lectivo'] != "''") {
			$sql_perlect = "SELECT 
                e.encuesta as encuesta,
                e.titulo as encuesta_titulo,
                ea.alcance as alcance, 
                ea.titulo as alcance_titulo,
                f.formulario as formulario,
                f.nombre as formulario_titulo, 
                ele.elemento as elemento_externo,
                e.kolla_id_encuesta as kolla_id_encuesta,
                ea.kolla_id_habilitacion as kolla_id_habilitacion,
                ea.kolla_password as kolla_password,
                ea.alcance || '-' || f.formulario as id_form_alc,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario) as cant_encuestados,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario AND ep.fecha_respuesta IS NOT NULL) as cant_respondidas,
                CASE
                   WHEN c.tipo_concepto = 3 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 5 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 6 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 8 THEN sga_materias.nombre  
                   ELSE cast(null as varchar(255)) 
                END as materia_nombre,
                 sga_comisiones.periodo_lectivo  as per_lect_examen,
				 'D' as tipo_encuesta
                
                FROM
                    gde_encuestas as e,
                    gde_encues_alcance as ea,
                    gde_concepto as c,
                    OUTER sga_materias,
                    gde_formulario as f,
                    gde_formulario_det as fd,
                    gde_elemento as ele,
                    sga_comisiones
                WHERE ea.encuesta = e.encuesta
                  AND ea.anio_academico = {$parametros['anio_academico']}
                  AND ea.kolla_id_habilitacion IS NOT NULL
                  AND ea.generar IN ('D','X')     --  Actuacion academica de los docentes en Comisiones
                  AND f.alcance = ea.alcance
                  AND f.estado = 'A'              -- Formularios activos
                  AND f.generado_en_kolla = 'S'   -- Formularios generados en Kolla
                  AND c.concepto = f.concepto
                  $filtro_materia
                  
                  AND sga_materias.unidad_academica = c.unidad_academica
                  AND sga_materias.materia = c.materia
                  
                  AND sga_comisiones.comision = c.comision 
                  $filtro_periodo_lectivo
                  
                  -- formularios que tengan como elemento al docente
                  AND fd.formulario = f.formulario 
                  AND ele.elemento = fd.elemento
                  AND ele.tipo_elemento = 4 
                  AND ele.legajo_docente = {$parametros['legajo_docente']}
				  
				  UNION ALL 
				  
			  -- Cursada - Encuestas sobre la materia donde esta asignado el docente
			  SELECT 
                e.encuesta as encuesta,
                e.titulo as encuesta_titulo,
                ea.alcance as alcance, 
                ea.titulo as alcance_titulo,
                f.formulario as formulario,
                f.nombre as formulario_titulo, 
                ele.elemento as elemento_externo,
                e.kolla_id_encuesta as kolla_id_encuesta,
                ea.kolla_id_habilitacion as kolla_id_habilitacion,
                ea.kolla_password as kolla_password,
                ea.alcance || '-' || f.formulario as id_form_alc,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario) as cant_encuestados,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario AND ep.fecha_respuesta IS NOT NULL) as cant_respondidas,
                CASE
                   WHEN c.tipo_concepto = 3 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 5 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 6 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 8 THEN sga_materias.nombre  
                   ELSE cast(null as varchar(255)) 
                END as materia_nombre,
                 '(' || sga_comisiones.anio_academico  || ') ' || sga_comisiones.periodo_lectivo  as per_lect_examen,
				 'C' as tipo_encuesta
                
                FROM
                    gde_encuestas as e,
                    gde_encues_alcance as ea,
                    gde_concepto as c,
                    OUTER sga_materias,
                    gde_formulario as f,
                    gde_formulario_det as fd,
                    gde_elemento as ele,
                    sga_comisiones,
					sga_docentes_com
                WHERE ea.encuesta = e.encuesta
                  AND ea.anio_academico = {$parametros['anio_academico']}
                  AND ea.kolla_id_habilitacion IS NOT NULL
                  AND ea.generar = 'I'            --  Una encuesta por cada materia cursada de un período lectivo
                  AND f.alcance = ea.alcance
                  AND f.estado = 'A'              -- Formularios activos
                  AND f.generado_en_kolla = 'S'   -- Formularios generados en Kolla
                  AND c.concepto = f.concepto
                  $filtro_materia
                  
                  AND sga_materias.unidad_academica = c.unidad_academica
                  AND sga_materias.materia = c.materia
                  
                  AND sga_comisiones.comision = c.comision 
                  $filtro_periodo_lectivo
                  
				  -- El docente pertenece a la comision
				  AND sga_docentes_com.comision = sga_comisiones.comision
				  AND sga_docentes_com.legajo = {$parametros['legajo_docente']}
				  
                  -- formularios que tengan como elemento a la materia de la comision. Estas encuestas solo tienen un elemento.
                  AND fd.formulario = f.formulario 
                  AND ele.elemento = fd.elemento
                  AND ele.tipo_elemento = 3  -- Materia 
                  
                ";
		}


		// Solo de Turnos de Examen
		if ($parametros['turno_examen'] != "''") {
			$sql_turnoex = "SELECT 
                e.encuesta as encuesta,
                e.titulo as encuesta_titulo,
                ea.alcance as alcance, 
                ea.titulo as alcance_titulo,
                f.formulario as formulario,
                f.nombre as formulario_titulo, 
                ele.elemento as elemento_externo,
                e.kolla_id_encuesta as kolla_id_encuesta,
                ea.kolla_id_habilitacion as kolla_id_habilitacion,
                ea.kolla_password as kolla_password,
                ea.alcance || '-' || f.formulario as id_form_alc,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario) as cant_encuestados,
                (SELECT COUNT(*) FROM gde_encues_persona as ep WHERE ep.formulario = f.formulario AND ep.fecha_respuesta IS NOT NULL) as cant_respondidas,
                CASE
                   WHEN c.tipo_concepto = 3 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 5 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 6 THEN sga_materias.nombre  
                   WHEN c.tipo_concepto = 8 THEN sga_materias.nombre  
                   ELSE cast(null as varchar(255)) 
                END as materia_nombre,
                to_char(sga_prestamos.fecha, '%d/%m/%Y') as per_lect_examen,
				'D' as tipo_encuesta  -- Actuacion Docente en Examenes
                
                FROM
                    gde_encuestas as e,
                    gde_encues_alcance as ea,
                    gde_concepto as c,
                    OUTER sga_materias,
                    gde_formulario as f,
                    gde_formulario_det as fd,
                    gde_elemento as ele,
                    sga_llamados_mesa, 
                    sga_prestamos
                WHERE ea.encuesta = e.encuesta
                  AND ea.anio_academico = {$parametros['anio_academico']}
                  AND ea.kolla_id_habilitacion IS NOT NULL
                  AND ea.generar = 'E'     --  Actuacion academica de los docentes en Mesas de Examen
                  AND f.alcance = ea.alcance
                  AND f.estado = 'A'              -- Formularios activos
                  AND f.generado_en_kolla = 'S'   -- Formularios generados en Kolla
                  AND c.concepto = f.concepto
                  $filtro_materia
                  
                  AND sga_materias.unidad_academica = c.unidad_academica
                  AND sga_materias.materia = c.materia
                  
                  AND sga_llamados_mesa.id_llamado_mesa = c.id_llamado_mesa
                  AND sga_prestamos.prestamo = sga_llamados_mesa.prestamo
                  $filtro_turno_examen
                 
                  -- formularios que tengan como elemento al docente
                  AND fd.formulario = f.formulario 
                  AND ele.elemento = fd.elemento
                  AND ele.tipo_elemento = 4 
				  AND ele.legajo_docente = {$parametros['legajo_docente']}
		 
				  ";
		}
		// Si ingreso filtro de turno y de periodo lectivo
		if(($parametros['turno_examen'] != "''") && ($parametros['periodo_lectivo'] != "''")) {
			$sql = $sql_turnoex . ' UNION ' . $sql_perlect;
		}
		// Si ingreso no ingreso filtro de turno ni de periodo lectivo
		if(($parametros['turno_examen'] == "''") && ($parametros['periodo_lectivo'] == "''")) {
			$sql = $sql_todos;
		}
		// Si ingreso filtro de turno y no de periodo lectivo
		if(($parametros['turno_examen'] != "''") && ($parametros['periodo_lectivo'] == "''")) {
			$sql = $sql_turnoex;
		}
		// Si ingreso filtro de periodo lectivo y no de turno
		if(($parametros['turno_examen'] == "''") && ($parametros['periodo_lectivo'] != "''")) {
			$sql = $sql_perlect;
		}
		// Agrego el ORDER BY
		$sql = $sql . " ORDER BY 1";

		$encuestas = kernel::db()->consultar($sql, db::FETCH_ASSOC);

		foreach ($encuestas as $key => $encuesta){

			$encuestas[$key]['KOLLA_ID_ENCUESTA_HASH'] = catalogo::generar_id($encuesta['KOLLA_ID_ENCUESTA']);
			$encuestas[$key]['ELEMENTO_EXTERNO_HASH'] = catalogo::generar_id($encuesta['ELEMENTO_EXTERNO']);
			$encuestas[$key]['FORMULARIO_HASH'] = catalogo::generar_id($encuesta['FORMULARIO']);
			$encuestas[$key]['KOLLA_ID_HABILITACION_HASH'] = catalogo::generar_id($encuesta['KOLLA_ID_HABILITACION']);
		}

		return $encuestas;
	}

     
      /**
     * parametros: 
     * param_null: 
     * cache: no
     */
     //Devuelve todos los id de kolla y agrega un campo con el hash de los mismos. 
     function get_id_kolla_encuestas()
     {
         $sql = "SELECT gde_encuestas.kolla_id_encuesta 
                    FROM gde_encuestas";
         $encuestas = kernel::db()->consultar($sql, db::FETCH_ASSOC);
         foreach ($encuestas as $key => $encuesta){
             $encuestas[$key][catalogo::id] = catalogo::generar_id($encuesta['KOLLA_ID_ENCUESTA']); 
             
         }
         return $encuestas;
         
     }
     
      /**
     * parametros: 
     * param_null: 
     * cache: no
     */
     //Devuelve todos los id de los elementos encuestados y agrega un campo con el hash de los mismos. 
     function get_id_elementos()
     {
         $sql = "SELECT elemento 
                    FROM gde_elemento";
         $elementos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
         foreach ($elementos as $key => $elemento){
             $elementos[$key][catalogo::id] = catalogo::generar_id($elemento['ELEMENTO']); 
             
         }
         return $elementos;
     }
     
      /**
     * parametros: 
     * param_null: 
     * cache: no
     */
     //Devuelve todos los id de los formularios y agrega un campo con el hash de los mismos. 
     function get_id_formularios()
     {
         $sql = "SELECT formulario 
                    FROM gde_formulario";
         $formularios = kernel::db()->consultar($sql, db::FETCH_ASSOC);
         foreach ($formularios as $key => $formulario){
             $formularios[$key][catalogo::id] = catalogo::generar_id($formulario['FORMULARIO']); 
         }
         return $formularios;
     }
     
      /**
     * parametros: 
     * param_null: 
     * cache: no
     */
     //Devuelve todos los id de los alcances y agrega un campo con el hash de los mismos. 
     function get_id_alcances()
     {
         $sql = "SELECT kolla_id_habilitacion 
                    FROM gde_encues_alcance";
         $alcances = kernel::db()->consultar($sql, db::FETCH_ASSOC);
         foreach ($alcances as $key => $alcance){
             $alcances[$key][catalogo::id] = catalogo::generar_id($alcance['KOLLA_ID_HABILITACION']); 
         }
         return $alcances;
     }

}

?>
