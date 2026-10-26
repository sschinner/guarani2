<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;

class certificados
{
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function certificados_habilitados($parametros)
	{
		$sql = "execute procedure sp_certif_habilit ({$parametros['_ua']}, {$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: nro_certificado
	 * cache: no
	 * cache_expiracion: 300
	 * filas: n
	 */
	function certificados_argumentos($parametros)
	{
		$sql = "execute procedure sp_certif_argum ({$parametros['nro_certificado']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: _ua, certificado, nro_inscripcion, cantidad_copias
	 * cache: no
	 * filas: n
	 */
	function certificados_solicitar($parametros)
	{
		$sql = "execute procedure sp_i_CertifPedidos ({$parametros['certificado']}, {$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['cantidad_copias']},3)";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}
	
	/**
	 * parametros: indice_certificado, orden, valor
	 * cache: no
	 * filas: n
	 */
	function guardar_argumentos($parametros)
	{
		$sql = "execute procedure sp_i_certifpedarg ({$parametros['indice_certificado']}, {$parametros['orden']}, {$parametros['valor']})";
		kernel::db()->ejecutar($sql, db::FETCH_NUM);
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, certificado
	 * cache: no
	 * filas: n
	 */
	function nro_solicitud_certificado($parametros)
	{
        $sql = "SELECT FIRST 1 nro_transaccion, fecha_de_pedido
                FROM sga_certif_pedidos
                WHERE nro_inscripcion = {$parametros['nro_inscripcion']} AND unidad_academica = {$parametros['_ua']} AND certificado= {$parametros['certificado']}
                ORDER BY fecha_de_pedido DESC";

		$fila = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $fila[0];
	}

	// ##############################################################################################
	//                     CERTIFICADOS ON-LINE PARA SER IMPRESOS POR EL ALUMNO
	// ##############################################################################################
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	// Ticket https://repositorio.siu.edu.ar/trac/g3w2/ticket/789 
	function listado_evaluaciones_parciales_examenes($parametros)
	{
		// 1. Examenes de turnos de examenes vigentes en los que esta inscripto el alumno. 
		// 2. Evaluaciones parciales de las cursadas vigentes. Evaluaciones en las que esta el alumno.
		$sql = "SELECT 
		           'Examenes' as tipo,
		           sga_materias.nombre || ' (' || sga_materias.codigo || ')' as materia_desc,
                   sga_insc_examen.mesa_examen  || ' - ' || DECODE(sga_insc_examen,'L','Libre','R','Regular','') as descripcion, 
		           sga_prestamos.fecha as dfecha_evaluacion,
		           to_date(sga_prestamos.fecha, '%d/%m/%Y') as fecha_evaluacion,
		           
		          FROM sga_alumnos,
		               sga_insc_examen,
		               sga_materias,
		               sga_llamados_mesa,
		               sga_turnos_examen
		        WHERE sga_alumnos.unidad_academica =  {$parametros['_ua']}
		          AND sga_alumnos.nro_inscripcion =  {$parametros['nro_inscripcion']}
		          
		          AND sga_insc_examen.unidad_academica = sga_alumnos.unidad_academica
		          AND sga_insc_examen.carrera = sga_alumnos.carrera
		          AND sga_insc_examen.legajo  = sga_alumnos.legajo

		          AND sga_materias.unidad_academica = sga_insc_examen.unidad_academica
		          AND sga_materias.materia          = sga_insc_examen.materia

		          AND sga_llamados_mesa.unidad_academica = sga_insc_examen.unidad_academica
		          AND sga_llamados_mesa.materia          = sga_insc_examen.materia
		          AND sga_llamados_mesa.anio_academico   = sga_insc_examen.anio_academico
		          AND sga_llamados_mesa.turno_examen     = sga_insc_examen.turno_examen
		          AND sga_llamados_mesa.mesa_examen      = sga_insc_examen.mesa_examen
		          AND sga_llamados_mesa.llamado          = sga_insc_examen.llamado

                  AND sga_prestamos.prestamo = sga_llamados_mesa.prestamo

		          AND sga_turnos_examen.anio_academico   = sga_insc_examen.anio_academico
		          AND sga_turnos_examen.turno_examen     = sga_insc_examen.turno_examen
                  AND sga_turnos_examen.fecha_fin >= TODAY
		           
		        UNION ALL

		        SELECT
		           'Evaluaciones Parciales' as tipo,
		           sga_materias.nombre || ' (' || sga_materias.codigo || ')' as materia_desc,
		           sga_eval_parc.descripcion || ' (' || sga_tipo_eval_parc.descripcion || ')' as descripcion
		           date(sga_cron_eval_parc.fecha_hora) as dfecha_evaluacion 
		           to_char(sga_cron_eval_parc.fecha_hora, '%d/%m/%Y') as fecha_evaluacion,
		           
		          FROM sga_alumnos,
		               sga_insc_cursadas,
	                   sga_comisiones,
		               sga_materias,
		               sga_periodos_lectivos,
		               sga_eval_parc_alum,
		               sga_eval_parc,
		               sga_cron_eval_parc,
		               sga_tipo_eval_parc
		               
		        WHERE sga_alumnos.unidad_academica =  {$parametros['_ua']}
		          AND sga_alumnos.nro_inscripcion =  {$parametros['nro_inscripcion']}
		          
		          AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
		          AND sga_insc_cursadas.carrera = sga_alumnos.carrera
		          AND sga_insc_cursadas.legajo  = sga_alumnos.legajo
		          
		          AND sga_comisiones.comision = sga_insc_cursadas.comision
		          
		          AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
		          AND sga_materias.materia          = sga_comisiones.materia
		          
		          AND sga_periodos_lectivos.periodo_lectivo = sga_comisiones.comision
		          AND sga_periodos_lectivos,.fecha_fin >= TODAY  
		          
		          AND sga_cron_eval_parc.comision   = sga_comisiones.comision
		          AND sga_cron_eval_parc.evaluacion = sga_eval_parc_alum.evaluacion
		          
		          AND sga_eval_parc_alum.comision   = sga_cron_eval_parc.comision
		          AND sga_eval_parc_alum.evaluacion = sga_cron_eval_parc.evaluacion
		          AND sga_eval_parc_alum.unidad_academica = sga_alumnos.unidad_academica
		          AND sga_eval_parc_alum.carrera    = sga_alumnos.carrera
		          AND sga_eval_parc_alum.legajo     = sga_alumnos.legajo
		          
		          AND sga_eval_parc.evaluacion = sga_eval_parc_alum.evaluacion
		         
		          AND sga_tipo_eval_parc.tipo_evaluac_par = sga_eval_parc.tipo_evaluac_par
		      ORDER BY 1, 4 desc     
		     ";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		return $datos;
	}


    /**
     * parametros: _ua, nro_inscripcion, estado, alcance
     * cache: no
     * filas: n
     */
    function listado_evaluaciones_parciales($parametros)
    {
        $sql = "execute procedure sp_inscCursadas({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['estado']}, {$parametros['alcance']})";

        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        $nuevo = array();
        $i = 0;
        foreach($datos as $dato){

            $nuevo[$i]['anio_academico'] = $dato[9];
            $nuevo[$i]['periodo_lectivo'] = $dato[8];
            $nuevo[$i]['turno_comision'] = $dato[18];
            $nuevo[$i]['nombre_reducido_materia'] = $dato[20];
            $nuevo[$i]['nombre_sede'] = $dato[22];
            $nuevo[$i]['comision_nombre'] = $dato[12];
            $nuevo[$i]['catedra_nombre'] = $dato[13];
            $nuevo[$i]['estado'] = $dato[11];

            $i++;
        }

        //Es como hacer ORDER BY anio_academico DESC, periodo_lectivo DESC, turno_comision DESC
        usort($nuevo, function($a, $b){
            $cmp_anio_academico = strcasecmp($b["anio_academico"], $a["anio_academico"]);
            $cmp_periodo_lectivo = strcasecmp($b["periodo_lectivo"], $a["periodo_lectivo"]);
            $cmp_turno_comision = strcasecmp($b["turno_comision"], $a["turno_comision"]);

            if($cmp_anio_academico == 0){

                if($cmp_periodo_lectivo == 0){
                    return $cmp_turno_comision;
                }
                else{
                    return $cmp_periodo_lectivo;
                }

            }
            else{
                return $cmp_anio_academico;
            }
        });

        return $nuevo;
    }


    /**
     * parametros: _ua, nro_inscripcion, estado, alcance
     * cache: no
     * filas: n
     */
    function listado_evaluaciones_examenes($parametros)
    {
        $sql = "execute procedure sp_inscExam({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['estado']}, {$parametros['alcance']})";

        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        $nuevo = array();
        $i = 0;
        foreach($datos as $dato){

            $nuevo[$i]['anio_academico'] = $dato[5];
            $nuevo[$i]['turno_examen'] = $dato[6];
            $nuevo[$i]['dia_prestamo_aula'] = $dato[16];
            $nuevo[$i]['fecha_hora_insc'] = $dato[4];
            $nuevo[$i]['materia_nombre_reducido'] = $dato[19];
            $nuevo[$i]['mesa_examen'] = $dato[8];
            $nuevo[$i]['hora_prestamo_aula'] = $dato[17];
            $nuevo[$i]['nombre_sede'] = $dato[27];
            $nuevo[$i]['tipo_insc_nombre'] = $dato[20];
            $nuevo[$i]['estado'] = $dato[10];
            $nuevo[$i]['estado_nombre'] = $dato[21];

            $i++;
        }

        //Es como hacer ORDER BY anio_academico DESC, turno_examen DESC, dia_prestamo_aula DESC, fecha_hora_insc DESC
        usort($nuevo, function($a, $b){
            $cmp_anio_academico = strcasecmp($b["anio_academico"], $a["anio_academico"]);
            $cmp_turno_examen = strcasecmp($b["turno_examen"], $a["turno_examen"]);

            $dia_prestamo_aula_a = \DateTime::createFromFormat('d/m/Y', $a["dia_prestamo_aula"]);
            $dia_prestamo_aula_b = \DateTime::createFromFormat('d/m/Y', $b["dia_prestamo_aula"]);
            if($dia_prestamo_aula_a == $dia_prestamo_aula_b){
                $cmp_dia_prestamo_aula = 0;
            }
            else{
                $cmp_dia_prestamo_aula = ($dia_prestamo_aula_a > $dia_prestamo_aula_b)? -1 : 1;
            }

            $fecha_hora_insc_a = \DateTime::createFromFormat('d/m/Y H:i', $a["fecha_hora_insc"]);
            $fecha_hora_insc_b = \DateTime::createFromFormat('d/m/Y H:i', $b["fecha_hora_insc"]);
            if($fecha_hora_insc_a == $fecha_hora_insc_b){
                $cmp_fecha_hora_insc = 0;
            }
            else{
                $cmp_fecha_hora_insc = ($fecha_hora_insc_a > $fecha_hora_insc_b)? -1 : 1;
            }

            if($cmp_anio_academico == 0){

                if($cmp_turno_examen == 0){

                    if($cmp_dia_prestamo_aula == 0){
                        return $cmp_fecha_hora_insc;
                    }
                    else{
                        return $cmp_dia_prestamo_aula;
                    }

                }
                else{
                    return $cmp_turno_examen;
                }

            }
            else{
                return $cmp_anio_academico;
            }
        });

        return $nuevo;
    }

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function ctr_alumno_regular_carrera($parametros)
    {
        $sql = "execute procedure ctr_regularcarrera({$parametros['_ua']}, {$parametros['carrera']}, {$parametros['legajo']}, null)";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return array(
            "estado" => $datos[0],
            "mensaje" => $datos[1]
        );

    }

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function ctr_alumno_activo_carrera($parametros)
    {
        $sql = "execute procedure ctr_esAluActivoCar({$parametros['_ua']}, {$parametros['carrera']}, {$parametros['legajo']}, null)";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return array(
            "estado" => $datos[0],
            "mensaje" => $datos[1]
        );

    }

    /**
     * parametros: _ua, codigo_validador, carrera, legajo, nro_inscripcion, certificado, fecha_expiracion, parametros
     * no_quote: parametros
     * cache: no
     */
    function guardar_certificado_web($parametros)
    {
        $parametros_serialize = kernel::db()->quote(serialize($parametros['parametros']));
        $sql = "
                INSERT INTO sga_certif_web (
                        CODIGO_VALIDACION,
                        UNIDAD_ACADEMICA,
                        CARRERA,
                        LEGAJO,
                        NRO_INSCRIPCION,
                        CERTIFICADO,
                        FECHA_EXPIRACION,
                        PARAMETROS
                        )
                VALUES (
                        {$parametros['codigo_validador']},
                        {$parametros['_ua']},
                        {$parametros['carrera']},
                        {$parametros['legajo']},
                        {$parametros['nro_inscripcion']},
                        {$parametros['certificado']},
                        TO_DATE({$parametros['fecha_expiracion']}, '%Y-%m-%d'),
                        {$parametros_serialize}
                )
		";

        return kernel::db()->ejecutar($sql);
    }

    /**
     * parametros: _ua, codigo_validador
     * cache: no
     */
    function recuperar_certificado_web($parametros)
    {
        $sql = "
                SELECT  carrera,
                        legajo,
                        nro_inscripcion,
                        certificado AS tipo_certificado,
                        fecha_alta,
                        fecha_expiracion,
                        parametros
                FROM sga_certif_web
                WHERE codigo_validacion = {$parametros['codigo_validador']}
                AND unidad_academica = {$parametros['_ua']}
                AND fecha_expiracion >= TODAY
		";
        $result = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
        if($result){
            $result['PARAMETROS'] = unserialize($result['PARAMETROS']);
        }
        return $result;
    }
}
?>
