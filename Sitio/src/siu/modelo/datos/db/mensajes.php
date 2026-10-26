<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;

class mensajes
{
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * cache_expiracion: 120
	 * filas: n
	 */
	function get_mensajes_recibidos_vigentes($parametros) 
	{	
		// Se saco el TRIM(mensaje) porque no funcionan con cadenas de caracteres que superan los 255 caracteres
		// Listado de mensajes recibidos por la persona.
		$sql = "SELECT
				gda_anuncios.anuncio,
				gda_anuncios.tipo_anuncio,
				gda_anuncios.titulo_anuncio,
				gda_anuncios.fecha_desde as fecha_desde_orden,
				to_char(gda_anuncios.fecha_desde, '%d/%m/%Y') as fecha_desde,
				to_char(gda_anuncios.fecha_hasta, '%d/%m/%Y') as fecha_hasta,
				SUBSTR(gda_anuncios.mensaje,1,50) as mensaje_resum,
				gda_anuncios.mensaje as mensaje,
				CASE gda_anuncios.enviado_por_mail 
				   WHEN 'S' THEN 'Si'
				   WHEN 'N' THEN 'No'
				END as enviado_por_mail,
				gda_anuncios.curso,
				to_char(gda_anuncios.fecha_de_registro, '%d/%m/%Y') as fecha_de_registro,
				gda_anuncios.docente_envia as docente_envia,
				to_char(gda_anuncios_log.fecha_lectura, '%d/%m/%Y') as fecha_lectura,
				CASE gda_anuncios.docente_envia
				   WHEN NULL THEN cast('Institución' as varchar(60)) 
				   ELSE (SELECT sga_personas.apellido || ' ' || sga_personas.nombres
				           FROM sga_docentes, sga_personas
				           WHERE sga_docentes.legajo = gda_anuncios.docente_envia
				           AND sga_personas.unidad_academica = sga_docentes.unidad_academica
				           AND sga_personas.nro_inscripcion = sga_docentes.nro_inscripcion)
				END as enviado_por
			FROM 
				gda_anuncios_log,
				gda_anuncios
			WHERE gda_anuncios_log.anuncio = gda_anuncios.anuncio  
			  AND gda_anuncios_log.unidad_academica = {$parametros['_ua']} 
			  AND gda_anuncios_log.nro_inscripcion  = {$parametros['nro_inscripcion']}
			  AND TODAY BETWEEN gda_anuncios.fecha_desde AND gda_anuncios.fecha_hasta 
			ORDER BY 4 desc ";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		if(!empty($datos)){
			foreach ($datos as $key => $dato) {
				$id = catalogo::generar_id($dato['ANUNCIO']);
				$ids[] = $dato['ANUNCIO'];
				$nuevo[$id] = $dato;
				$nuevo[$id][catalogo::id] = $id;
				if(isset($dato['FECHA_LECTURA'])) {
					$nuevo[$id]['LEIDO'] = true;
				} else {
					$nuevo[$id]['LEIDO'] = false;
				}
			}
			// Cargo adjuntos
			$sql = "SELECT anuncio, adjunto, titulo_documento, codigo_documento 
					FROM gda_anuncios_adj 
					WHERE anuncio IN ('".implode("','",$ids)."')
					";
			$datos2 = kernel::db()->consultar($sql);			
			$adjuntos = array();
			foreach($datos2 as $d) {
				$id_anuncio = catalogo::generar_id($d['ADJUNTO']);
				$adjuntos[$d['ANUNCIO']][$id_anuncio] = array(catalogo::id => $id_anuncio,
													'NOMBRE_FS'=>$d['TITULO_DOCUMENTO'],
													'NOMBRE_ORIGINAL'=>$d['CODIGO_DOCUMENTO']);
			}
			//Asocio los adjuntos
			foreach(array_keys($nuevo) as $id) {
				if(isset($adjuntos[$nuevo[$id]['ANUNCIO']])){
					$nuevo[$id]['ADJUNTOS'] = $adjuntos[$nuevo[$id]['ANUNCIO']];
				}
			}
		}
		return $nuevo;				
	}
	
	
	/**
	 * parametros: _ua, legajo
	 * cache: no
	 * cache_expiracion: 120
	 * filas: n
	 */
	function get_mensajes_enviados($parametros)
	{	
		$sql = "SELECT
				gda_anuncios.anuncio as anuncio,
				gda_anuncios.tipo_anuncio as tipo_anuncio,
				gda_anuncios.fecha_desde as fecha_desde_orden,
				to_char(gda_anuncios.fecha_desde, '%d/%m/%Y') as fecha_desde,
				to_char(gda_anuncios.fecha_hasta, '%d/%m/%Y') as fecha_hasta,
				gda_anuncios.titulo_anuncio as titulo_anuncio,
				CASE
				  WHEN gda_anuncios.tipo_anuncio IN ('O','B','X') THEN 'Comision ' || sga_comisiones.nombre
				  WHEN gda_anuncios.tipo_anuncio IN ('M','T','Y') THEN 'Examen del ' || to_char(sga_prestamos.fecha, '%d/%m/%Y')
				  ELSE ''
				END as destino,
				CASE
				  WHEN gda_anuncios.tipo_anuncio IN ('O','B','X') THEN mc.nombre
				  WHEN gda_anuncios.tipo_anuncio IN ('M','T','Y') THEN mm.nombre
				  ELSE ''
				END as materia_nombre,
				CASE 
				  WHEN ((gda_anuncios.tipo_anuncio = 'O' OR gda_anuncios.tipo_anuncio= 'M') AND gda_anuncios.todos_algunos = 'T') THEN 'Todos los alumnos'
				  WHEN ((gda_anuncios.tipo_anuncio = 'O' OR gda_anuncios.tipo_anuncio= 'M') AND gda_anuncios.todos_algunos = 'A') THEN 'Algunos alumnos'
				  WHEN ((gda_anuncios.tipo_anuncio = 'B' OR gda_anuncios.tipo_anuncio= 'T') AND gda_anuncios.todos_algunos = 'T') THEN 'Todos los docentes'
				  WHEN ((gda_anuncios.tipo_anuncio = 'B' OR gda_anuncios.tipo_anuncio= 'T') AND gda_anuncios.todos_algunos = 'A') THEN 'Algunos Docentes'
				  WHEN (gda_anuncios.tipo_anuncio = 'X' OR gda_anuncios.tipo_anuncio= 'Y') THEN 'Alumnos y docentes'
				  ELSE ''
				END as enviado_a,
				SUBSTR(gda_anuncios.mensaje,1,50) || '...' as mensaje_resum,
				gda_anuncios.mensaje as mensaje,
				CASE gda_anuncios.enviado_por_mail 
				   WHEN 'S' THEN 'Si'
				   WHEN 'N' THEN 'No'
				END as enviado_por_mail,
				gda_anuncios.curso as curso,
				to_char(gda_anuncios.fecha_de_registro, '%d/%m/%Y') as fecha_de_registro,
				(SELECT count(*) FROM gda_anuncios_log as d WHERE d.anuncio = gda_anuncios.anuncio) as cant_destinatarios
			FROM
				gda_anuncios,
				OUTER (gda_cursos_com, sga_comisiones, sga_materias as mc),
				OUTER (gda_cursos_mesa, sga_llamados_mesa as llm, sga_prestamos, sga_materias as mm) 
			WHERE gda_anuncios.docente_envia  = {$parametros['legajo']}
			  
			  AND gda_cursos_com.curso = gda_anuncios.curso
			  AND sga_comisiones.comision = gda_cursos_com.comision
			  AND mc.unidad_academica = sga_comisiones.unidad_academica
			  AND mc.materia = sga_comisiones.materia

			  AND gda_cursos_mesa.curso = gda_anuncios.curso
			  AND mm.unidad_academica = gda_cursos_mesa.unidad_academica
			  AND mm.materia = gda_cursos_mesa.materia

			  AND llm.unidad_academica = gda_cursos_mesa.unidad_academica
			  AND llm.materia          = gda_cursos_mesa.materia
			  AND llm.anio_academico   = gda_cursos_mesa.anio_academico
			  AND llm.turno_examen     = gda_cursos_mesa.turno_examen
			  AND llm.llamado          = gda_cursos_mesa.llamado
			  AND llm.mesa_examen      = gda_cursos_mesa.mesa_examen
			  AND sga_prestamos.prestamo = llm.prestamo

			ORDER BY 3 desc";
			
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $key => $dato) {
			$id = catalogo::generar_id($dato['ANUNCIO']);
			$nuevo[$id] = $dato;
			$nuevo[$id]['LEIDO'] = true;
			$nuevo[$id][catalogo::id] = $id;
		}
		return $nuevo;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, anuncio
	 * cache: no
	 * filas: n
	 */
	function leer_mensaje($parametros)
	{
		$sql = "execute procedure sp_u_anuncio_leido(".$parametros["anuncio"].",".
													 $parametros["_ua"].",".
													 $parametros["nro_inscripcion"].")";
		
		$mensaje = current(current(kernel::db()->consultar($sql, db::FETCH_NUM)));
		//$pos = strpos ($mensaje,'                      ');
		//$retorno = array('mensaje' => substr($mensaje, 0, $pos));
		$retorno = array('mensaje' => $mensaje);
		return $retorno;
	}
	
	/**
	 * parametros: _ua, tipo_anuncio, curso, fecha_desde, fecha_hasta, titulo_anuncio, enviado_por_mail, enviado_por_sms, int_gestion, int_autogestion, int_telefono, int_internet, mensaje, legajo, todos_algunos
	 * cache: no
	 * filas: n
	 */
	function guardar_mensaje($parametros) 
	{
		$sql = "EXECUTE PROCEDURE sp_i_anuncio (".$parametros["tipo_anuncio"].",".
												$parametros["_ua"].",".
												"NULL,".
												"NULL,".
													$parametros["curso"].",".
												$parametros["fecha_desde"].",".
												$parametros["fecha_hasta"].",".
												$parametros["titulo_anuncio"].",".
												$parametros["enviado_por_mail"].",".
												$parametros["enviado_por_sms"].",".
												$parametros["int_gestion"].",".
												$parametros["int_autogestion"].",".				
												$parametros["int_telefono"].",".								
												$parametros["int_internet"].",".												
												$parametros["mensaje"].",".												
												$parametros["legajo"].",".
												$parametros["todos_algunos"].",".
												"NULL,".
												"NULL,".
												"NULL,".
												"NULL )";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: mensaje, nombre_original, nombre_fs
	 * cache: no
	 * filas: n
	 */
	function guardar_attachment($parametros) 
	{		
		$sql = "EXECUTE PROCEDURE sp_i_adjs_anuncio(".$parametros['mensaje'].",".
												$parametros['nombre_fs'].",".
												$parametros['nombre_original'].")";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * cache_expiracion: 120
	 * filas: n
	 */	
	function get_cant_mensajes($parametros)
	{
		$sql = "SELECT count(*) as total,
				SUM(CASE WHEN gda_anuncios_log.fecha_lectura IS NULL THEN 0 ELSE 1 END) as leidos
				FROM gda_anuncios, gda_anuncios_log 
				WHERE gda_anuncios_log.anuncio = gda_anuncios.anuncio
				AND gda_anuncios_log.unidad_academica = {$parametros['_ua']}
				AND gda_anuncios_log.nro_inscripcion = {$parametros['nro_inscripcion']}
				AND TODAY BETWEEN gda_anuncios.fecha_desde AND gda_anuncios.fecha_hasta
				";
		 
		return kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
	}
	
	/**
	 * parametros: _ua, materia, anio_academico, turno_examen, mesa_examen, llamado
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */	
	function get_curso_mesa($parametros) 
	{
		$sql = "EXECUTE PROCEDURE sp_cursos_mesa(" .$parametros["_ua"] . "," .
													$parametros["materia"] . "," .
													$parametros["anio_academico"] . "," .
													$parametros["turno_examen"] . "," .
													$parametros["mesa_examen"] . "," .
													$parametros["llamado"] . ");" ;
		
		$datos = kernel::db()->consultar($sql,db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $key => $dato) {
			$nuevo[$key]['ANIO_ACADEMICO'] = $dato[0];
			$nuevo[$key]['TURNO_EXAMEN'] = $dato[1];
			$nuevo[$key]['MESA_EXAMEN'] = $dato[2];
			$nuevo[$key]['LLAMADO'] = $dato[3];
			$nuevo[$key]['MATERIA'] = $dato[4];
			$nuevo[$key]['MATERIA_NOMBRE'] = $dato[5];
			$nuevo[$key]['CURSO'] = $dato[6];
			$nuevo[$key]['CURSO_NOMBRE'] = $dato[7];
			$nuevo[$key]['TIPO_ACCESO'] = $dato[8];
			$nuevo[$key]['TIPO_ACCESO_NOMBRE'] = $dato[9];
			$nuevo[$key]['DESCRIPCION'] = $dato[10];
			$nuevo[$key]['OBJETIVOS'] = $dato[11];
			$nuevo[$key]['HABILITADO'] = $dato[12];
		}
		return $nuevo;
	}
	
	
	/**
	 * parametros: _ua, comision
	 * cache: memoria
	 * cache_expiracion: 600
	 * filas: n
	 */
	function get_curso_comision($parametros) 
	{
		$sql = "EXECUTE PROCEDURE sp_cursos_com(" . $parametros["_ua"] . "," .
													 $parametros["comision"] . ")";
		
		$datos = kernel::db()->consultar($sql,db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $key => $dato) {
			$nuevo[$key]['COMISION'] = $dato[0];
			$nuevo[$key]['COMISION_NOMBRE'] = $dato[1];
			$nuevo[$key]['MATERIA'] = $dato[2];
			$nuevo[$key]['MATERIA_NOMBRE'] = $dato[3];
			$nuevo[$key]['CURSO'] = $dato[4];
			$nuevo[$key]['CURSO_NOMBRE'] = $dato[5];
			$nuevo[$key]['TIPO_ACCESO'] = $dato[6];
			$nuevo[$key]['TIPO_ACCESO_NOMBRE'] = $dato[7];
			$nuevo[$key]['DESCRIPCION'] = $dato[8];
			$nuevo[$key]['OBJETIVOS'] = $dato[9];
			$nuevo[$key]['HABILITADO'] = $dato[10];
		}
		return $nuevo;
	}

	/**
	 * parametros: anuncio
	 * cache: no
	 * filas: n
	 */
    function get_mails_destinatarios_anuncio($parametros)
    {
        // Recupera las direcciones de mails publicadas por los alumnos/docentes.
        // Direcciones de aquellos destinatarios del anuncio y que configuraron la recepcion de mensajes por mail.
        $sql = "SELECT   sga_personas.apellido as apellido,
                         sga_personas.nombres as nombres,   
                         gda_anun_conf_pers.e_mail  as email
                   FROM  gda_anuncios_log,
                         sga_personas,  
                         gda_anun_conf_pers   
                   WHERE gda_anuncios_log.anuncio = {$parametros["anuncio"]}
                     AND sga_personas.unidad_academica = gda_anuncios_log.unidad_academica
                     AND sga_personas.nro_inscripcion = gda_anuncios_log.nro_inscripcion
                     AND gda_anun_conf_pers.unidad_academica = gda_anuncios_log.unidad_academica  
                     AND gda_anun_conf_pers.nro_inscripcion  = gda_anuncios_log.nro_inscripcion
                     AND gda_anun_conf_pers.recibe_mail = 'S'
                     AND gda_anun_conf_pers.e_mail IS NOT NULL
               ";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
        return $datos;
    }
	
	/**
	 * parametros: _ua, nro_inscripcion, anuncio
	 * cache: no
	 * cache_expiracion: 120
	 * filas: n
	 */	
	function guardar_destinatarios($parametros)
	{
		$sql = "INSERT INTO gda_anuncios_log (	anuncio, 
												unidad_academica, 
												nro_inscripcion)
				VALUES ({$parametros['anuncio']}, 
						{$parametros['_ua']},
						{$parametros['nro_inscripcion']})";
		 
		return kernel::db()->ejecutar($sql);
	}	


}
?>