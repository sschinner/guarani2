<?php

namespace personalizacionUNL\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;

class alumno extends \siu\modelo\datos\db\alumno {

    /**
     * parametros: _ua, carrera, nro_inscripcion
     * cache: no
     * filas: n
     */
    function calidad_alumno($parametros) {
        $sql = "EXECUTE PROCEDURE sp820_calidad_alumno({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['nro_inscripcion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, carrera, nro_inscripcion
     * cache: memoria
     * filas: n
     */
    function calidad_alumno_grado($parametros) {
        $sql = "EXECUTE PROCEDURE sp820_calidad_alumno_grado({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['nro_inscripcion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, identificacion
     * cache: memoria
     * filas: n
     */
    function datos_alumno_ag($parametros) {
        $sql = "EXECUTE PROCEDURE sp_datosPersUsrAG({$parametros['_ua']}" . "," . $parametros['identificacion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, legajo, carrera, plan
     * cache: no
     * filas: n
     */
    function datos_principales($parametros) {
        $sql = "EXECUTE PROCEDURE sp820_carga_datos_principales({$parametros['_ua']}" . "," . $parametros['legajo'] . "," . $parametros['carrera'] . "," . $parametros['plan'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, apellido, nombre, email, tipo, nro, sexo, fecha
     * cache: no
     * filas: n
     */
    function graba_datos_para_kolla($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_graba_datos_principales({$parametros['_ua']}" . "," . $parametros['apellido'] . "," . $parametros['nombre'] . "," . $parametros['email'] . "," . $parametros['tipo'] . "," . $parametros['nro'] . "," . $parametros['sexo'] . "," . $parametros['fecha'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        //   print_r($datos);die;
        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion
     * cache: no
     * filas: n
     */
    function datos_pasantias($parametros) {
        $sql = "EXECUTE PROCEDURE sp820_pasvig({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion
     * cache: no
     * filas: n
     */
    function pasantias_inscripto($parametros) {
        $sql = "EXECUTE PROCEDURE sp820_inscpas({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion, legajo, carrera, plan, id_pasantia, interface
     * cache: no
     * filas: n
     */
    function pasantias_procesa_ins($parametros) {
        // print_r($parametros);die;
        $sql = "EXECUTE PROCEDURE sp820_i_inscpasantias({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . "," . $parametros['legajo'] . "," . $parametros['carrera'] . "," . $parametros['plan'] . "," . $parametros['id_pasantia'] . "," . $parametros['interface'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion, id_pasantia, interface
     * cache: no
     * filas: n
     */
    function pasantias_procesa_baja($parametros) {
        // print_r($parametros);die;
        $sql = "EXECUTE PROCEDURE sp820_d_inscpas({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . "," . $parametros['id_pasantia'] . "," . $parametros['interface'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion, legajo, carrera, plan, id_pasantia, interface
     * cache: no
     * filas: n
     */
    function pasantias_control_ins($parametros) {
        // print_r($parametros);die;
        $sql = "EXECUTE PROCEDURE ctr_cond_pas({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . "," . $parametros['legajo'] . "," . $parametros['carrera'] . "," . $parametros['plan'] . "," . $parametros['id_pasantia'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        //print_r($datos);die;
        return $datos;
    }

    /**
     * parametros: nro_inscripcion, carrera
     * cache: no
     * filas: n
     */
    function datos_para_electivas($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_can_apro_sci(" . $parametros['nro_inscripcion'] . "," . $parametros['carrera'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        // print_r($datos);die;
        return $datos;
    }

    /**
     * parametros: _ua, carrera, legajo, anio
     * cache: no
     * filas: n
     */
    function control_para_electivas($parametros) {

        $sql = "EXECUTE PROCEDURE ctr820_reinscrAlumno({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . "," . $parametros['anio'] . ",'')";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua, carrera, nro_inscripcion
     * cache: no
     * filas: n
     */
    function calidad_activo_regular($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_calidad_activo_regular({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['nro_inscripcion'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros: legajo, documento, carrera
     * cache: no
     * filas: n
     */
    function nombre_titulo($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_sexo_titulo({$parametros['legajo']}" . "," . $parametros['documento'] . "," . $parametros['carrera'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion, carrera
     * cache: no
     * filas: n
     */
    function datos_Alumno_Capic($parametros) {

        $sql = "EXECUTE PROCEDURE sp_datosAlumnoCapic({$parametros['_ua']}" . "," . $parametros['nro_inscripcion'] . "," . $parametros['carrera'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function ranking_Cursadas_Capic($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_ga({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function promedio_Alumno($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_pa({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua, carrera, legajo, materia
     * cache: no
     * filas: n
     */
    function cursada_Ingreso_Capic($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_eac({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . "," . $parametros["materia"] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: _ua,  carrera, plan, version, materia
     * cache: memoria
     * filas: n
     */
    function get_optativas_generica($parametros) {
        $sql = "SELECT  sga_mat_genericas.materia_optativa,
						sga_atrib_mat_plan.nombre_materia,
						sga_atrib_mat_plan.nombre_reducido,
                                                sga_mat_genericas.valor_materia
				FROM 	sga_mat_genericas,
						sga_atrib_mat_plan
				WHERE 	sga_mat_genericas.unidad_academica = sga_atrib_mat_plan.unidad_academica
				AND		sga_mat_genericas.materia_optativa = sga_atrib_mat_plan.materia
				
				AND		sga_mat_genericas.unidad_academica	= '" . $parametros['_ua'] . "'
				AND 	sga_atrib_mat_plan.carrera			= '" . $parametros['carrera'] . "'
				AND 	sga_atrib_mat_plan.plan 			= '" . $parametros['plan'] . "'
				AND 	sga_atrib_mat_plan.version 			= '" . $parametros['version'] . "' 
				AND     sga_mat_genericas.materia_generica	= '" . $parametros["materia"] . "' 
				order by 1,2";

        return kernel::db()->consultar($sql);
    }

    /**
     * parametros: _ua, carrera, plan, version
     * cache: memoria
     * filas: n
     */
   /* function get_detalle_plan_estudios($parametros) {
        $ret = array();
        //$sql = "execute procedure sp_planDeEstudios(" . $parametros["_ua"] . ", " . $parametros["carrera"] .",".$parametros['plan'] .",".$parametros['version'].")";
        $sql = "SELECT 
					sga_atrib_mat_plan.nombre_materia,
					sga_atrib_mat_plan.materia,
					sga_atrib_mat_plan.anio_de_cursada,
					sga_atrib_mat_plan.periodo_dictado,
					DECODE(sga_atrib_mat_plan.tipo_materia, 'G', 'Gen?rica', 'N', 'Normal', 'O', 'Optativa') as tipo_materia,
					sga_atrib_mat_plan.credito,
					sga_atrib_mat_plan.obligatoria,
					sga_atrib_mat_plan.tipo_materia as tipo_inicial,
					NVL(sga_atrib_mat_plan.anio_de_cursada,0) as anio_cursada_orden,
					NVL(sga_atrib_mat_plan.periodo_dictado,'') as per_dictado_orden
					     
				FROM sga_atrib_mat_plan
				WHERE sga_atrib_mat_plan.unidad_academica = {$parametros["_ua"]}
				AND sga_atrib_mat_plan.carrera = {$parametros["carrera"]}
				AND sga_atrib_mat_plan.plan = {$parametros["plan"]}
				AND sga_atrib_mat_plan.version = {$parametros["version"]}
				ORDER BY 9,
					     10,
					     sga_atrib_mat_plan.nombre_materia
				";
        $detalle_plan = kernel::db()->consultar($sql, db::FETCH_NUM);
        $genericas = $this->get_materias_genericas_alumno($parametros);

        foreach ($detalle_plan as $key => $materia) {
            $ret[$key]['MATERIA'] = $materia[1];
            $ret[$key]['NOMBRE_MATERIA'] = $materia[0];
            $ret[$key]['TIPO'] = $materia[7];
            $ret[$key]['TIPO_DETALLE'] = kernel::traductor()->trans("plan.estado." . trim($materia[7]));
            $ret[$key]['ANIO'] = $materia[2];
            $ret[$key]['PERIODO'] = $materia[3];
            $ret[$key]['CREDITO'] = $materia[5];
            if ($materia[7] == 'G') {
                $ret[$key]['OPTATIVAS'] = $genericas[$detalle_plan[$key][1]];
            }
        }
        $ret_final = array();
        $ret_final['detalle'] = $ret;
        return $ret_final;
    }
*/
    /**
     * parametros: _ua, legajo, carrera, plan, version
     * cache: memoria
     * filas: n
     */
  /*  function get_materias_genericas_alumno($parametros) {
        $datos = array();
        $sql = "SELECT	sga_mat_genericas.materia_generica,
						sga_mat_genericas.materia_optativa,
						sga_materias.nombre,
                                                sga_mat_genericas.valor_materia,
                                                sga_atrib_mat_plan.credito as credito_opt
				FROM	sga_opt_generica,
						sga_mat_genericas,
						sga_materias,
                                                sga_atrib_mat_plan
                                                
				WHERE	sga_opt_generica.unidad_academica	= {$parametros["_ua"]}
				AND		sga_opt_generica.carrera			= {$parametros["carrera"]}
				AND		sga_opt_generica.plan				= {$parametros["plan"]} 
				AND		sga_opt_generica.version			= {$parametros["version"]} 
                                AND		sga_atrib_mat_plan.carrera			= {$parametros["carrera"]}
				AND		sga_atrib_mat_plan.plan				= {$parametros["plan"]} 
				AND		sga_atrib_mat_plan.version			= {$parametros["version"]}
                                AND		sga_materias.materia				=  sga_atrib_mat_plan.materia     
				AND		sga_mat_genericas.unidad_academica	= sga_opt_generica.unidad_academica
				AND		sga_mat_genericas.materia_generica	= sga_opt_generica.materia_generica
				AND		sga_mat_genericas.materia_optativa	= sga_opt_generica.materia_optativa
				AND		sga_materias.unidad_academica		= sga_opt_generica.unidad_academica
				AND		sga_materias.materia				= sga_opt_generica.materia_optativa
				AND		NOT EXISTS (
									SELECT	op_alu3.materia_optativa
									FROM	sga_opt_gen_alumno as op_alu3
									WHERE	op_alu3.unidad_academica	= sga_opt_generica.unidad_academica
									AND		op_alu3.carrera				= sga_opt_generica.carrera
									AND		op_alu3.legajo				=  {$parametros["legajo"]}
									AND		op_alu3.materia_optativa	= sga_opt_generica.materia_optativa
									)
				UNION ALL
				SELECT	sga_mat_genericas.materia_generica,
						sga_mat_genericas.materia_optativa,
						sga_materias.nombre,
                                                sga_mat_genericas.valor_materia,
                                                sga_atrib_mat_plan.credito as credito_opt
				FROM	sga_opt_gen_alumno,
						sga_mat_genericas,
						sga_materias,
                                                sga_atrib_mat_plan
				WHERE	sga_opt_gen_alumno.unidad_academica	= {$parametros["_ua"]}
				AND		sga_opt_gen_alumno.carrera			= {$parametros["carrera"]}
				AND		sga_opt_gen_alumno.plan				= {$parametros["plan"]} 
				AND		sga_opt_gen_alumno.version			= {$parametros["version"]}
                                AND		sga_atrib_mat_plan.carrera			= {$parametros["carrera"]}
				AND		sga_atrib_mat_plan.plan				= {$parametros["plan"]} 
				AND		sga_atrib_mat_plan.version			= {$parametros["version"]}
                                AND		sga_materias.materia				=  sga_atrib_mat_plan.materia       
				AND		sga_mat_genericas.unidad_academica = sga_opt_gen_alumno.unidad_academica
				AND		sga_mat_genericas.materia_generica = sga_opt_gen_alumno.materia_generica
				AND		sga_mat_genericas.materia_optativa = sga_opt_gen_alumno.materia_optativa
				AND		sga_materias.unidad_academica		= sga_opt_gen_alumno.unidad_academica
				AND		sga_materias.materia				= sga_opt_gen_alumno.materia_optativa
				ORDER BY 1,2,3;
				";

        $genericas = kernel::db()->consultar($sql);

        $datos = array();
        foreach ($genericas as $key => $generica) {
            $insertar['MATERIA_OPTATIVA'] = $generica['MATERIA_OPTATIVA'];
            $insertar['NOMBRE'] = $generica['NOMBRE'];
            $insertar['VALOR_MATERIA'] = $generica['VALOR_MATERIA'];
            $insertar['CREDITO_OPT'] = $generica['CREDITO_OPT'];
            $datos[$generica['MATERIA_GENERICA']][] = $insertar;
        }
        return $datos;
    }*/

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function historia_academica($parametros) {
        //  print_r($parametros);die;
        $sql = "EXECUTE PROCEDURE sp820_histAluReg({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . ")";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        return $datos;
    }

    /**
     * parametros: anio
     * cache: no
     * filas: n
     */
    function vigencia_cert_alu_regular($parametros) {

        $sql = "SELECT fecha_fin FROM sga_anio_academico
                        WHERE anio_academico = {$parametros["anio"]} ";

        $fecha = kernel::db()->consultar($sql);
        return $fecha;
    }

    /**
     * parametros: _ua, carrera, legajo, materia
     * cache: no
     * filas: 1
     */
    function get_datos_ultima_cursada_materia($parametros) {
        $sql = "SELECT FIRST 1
					sga_comisiones.anio_academico as anio_academico,
					sga_comisiones.periodo_lectivo as periodo_lectivo,
					to_char(sga_cursadas.fecha_regularidad, '%d/%m/%Y')  as sfecha_regularidad,
					NVL(to_char(sga_cursadas.fin_vigencia_regul, '%d/%m/%Y'), 'Sin Vencimiento') as sfecha_fin_vigencia,
					CASE 
						WHEN sga_cursadas.fin_vigencia_regul IS NULL THEN 1
						WHEN sga_cursadas.fin_vigencia_regul IS NOT NULL AND sga_cursadas.fin_vigencia_regul >= TODAY THEN 1
						ELSE 0
					END as es_vigente,
					sga_cursadas.comision,
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.catedra as catedra,
					sga_cursadas.nota,
					sga_det_escala.descripcion as nota_descripcion,
					sga_det_escala.concepto as nota_concepto,
					-- ********************************************************************
					-- U820 Se decodifica el resultado aprobado de la cursada como Regular
					--DECODE(sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre') as resultado_desc,

					DECODE(sga_cursadas.resultado, 'P', 'Aprobado', 'A','Regular', 'R', 'Reprobado', 'U','Libre') as 
resultado_desc,
					-- ********************************************************************
					DECODE(sga_cursadas.origen, 'P', 'Promoci?n', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equivalencia en otra Carrera', 'CE', 'Cursada en otra Carrera' ) as origen,
					sga_cursadas.plan as plan,
					sga_cursadas.fecha_regularidad as fecha_regularidad
				FROM	sga_cursadas
						LEFT JOIN sga_comisiones ON sga_comisiones.comision = sga_cursadas.comision
						LEFT JOIN sga_det_escala ON (sga_det_escala.escala_notas = sga_cursadas.escala_notas AND sga_det_escala.nota = sga_cursadas.nota)
				WHERE	sga_cursadas.unidad_academica = {$parametros['_ua']}
					AND	sga_cursadas.carrera = {$parametros['carrera']}
					AND	sga_cursadas.legajo  = {$parametros['legajo']}
					AND	sga_cursadas.materia = {$parametros['materia']}
				ORDER BY sga_cursadas.fecha_regularidad desc";
        return kernel::db()->consultar_fila($sql);
    }

    /**
     * parametros: _ua, legajo, carrera
     * cache: no
     * filas: n
     */
    function get_actividad_academica($parametros) {
        $promo = utf8_decode('Promoción'); //se codifica porque hay problemas con el acento.
        $promoOtraC = utf8_decode('Promoción en otra carrera');

        if ($parametros['_ua'] == "'FCJS'") {

            $sql = "SELECT	cast('Aprobacion' as varchar(11)) as tipo, -- Historia Academica - Aprobaciones
						sga_atrib_mat_plan.anio_de_cursada, -- A?o de cursada definido en el plan
						sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
						year(vw_hist_academica.fecha) as anio,
						vw_hist_academica.materia,
						--sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                                (select nombre_materia from sga_atrib_mat_plan 
                                                    where carrera = {$parametros['carrera']}
                                                    and plan = (select plan 
                                                                        from sga_alumnos
                                                                        where carrera = {$parametros['carrera']}
                                                                            and legajo = {$parametros['legajo']}) 
                                                    and version = (select version_actual 
                                                                        from sga_planes
                                                                        where carrera = {$parametros['carrera']}
                                                                                and plan = (select plan 
                                                                                            from sga_alumnos
                                                                                            where carrera = {$parametros['carrera']}
                                                                                                and legajo = {$parametros['legajo']})) 
                                                    and materia = vw_hist_academica.materia)
                                                    as materia_nombre,
						--sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
						(select nombre_reducido from sga_atrib_mat_plan 
                                                    where carrera = {$parametros['carrera']}
                                                    and plan = (select plan 
                                                                        from sga_alumnos
                                                                        where carrera = {$parametros['carrera']}
                                                                            and legajo = {$parametros['legajo']}) 
                                                    and version = (select version_actual 
                                                                        from sga_planes
                                                                        where carrera = {$parametros['carrera']}
                                                                                and plan = (select plan 
                                                                                            from sga_alumnos
                                                                                            where carrera = {$parametros['carrera']}
                                                                                                and legajo = {$parametros['legajo']})) 
                                                    and materia = vw_hist_academica.materia)
                                                    as materia_nombre_red,
                                                to_char(vw_hist_academica.fecha, '%d/%m/%Y') as fecha_display,
						to_char(vw_hist_academica.fecha, '%Y%m%d') as fecha_orden,
						cast(null as integer) as comision, -- comision en cursadas
						vw_hist_academica.escala_notas,
						vw_hist_academica.nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						vw_hist_academica.resultado as resultado,
						DECODE(vw_hist_academica.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promocion', 'U', 'Ausente', '') as resultado_descripcion,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('Examen' as varchar(12))
							WHEN 'Examen equivalente'			THEN cast('Examen' as varchar(12))
							WHEN '{$promo}'					THEN cast('Promocion' as varchar(12))
                                                        WHEN '{$promoOtraC}'	THEN cast('Promocion' as varchar(12))
							WHEN 'Homologada'					THEN cast('Homologada' as varchar(12))
							WHEN 'Equivalencia'					THEN 'Equivalencia'
							WHEN 'Equivalencia equivalente'		THEN 'Equivalencia'
							WHEN 'Otras'						THEN cast('Otras'  as varchar(12))
						END as origen,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('examen' as varchar(40))
							WHEN 'Examen equivalente'			THEN cast('examen' as varchar(40))
							WHEN '{$promo}'					THEN cast('promocion' as varchar(40))
							WHEN '{$promoOtraC}'	THEN cast('promocion' as varchar(40))
							WHEN 'Homologada'					THEN cast('homologada' as varchar(40))
							WHEN 'Equivalencia'					THEN cast('equivalencia_total' as varchar(40))
							WHEN 'Equivalencia equivalente'		THEN cast('equivalencia_total_equivalente' as varchar(40))
							WHEN 'Otras'						THEN cast('otras'  as varchar(40))
						END as origen_desc,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen equivalente'			THEN 1
							WHEN '{$promoOtraC}'	THEN 1
							WHEN 'Equivalencia equivalente'		THEN 1
							ELSE 0
						END as origen_otra_carrera,
						1 as vigente, 		   -- vigente en cursadas
						cast(null as integer) as cond_regularidad, -- condicion de regularidad en cursadas
						sga_atrib_mat_plan.credito,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen' 						THEN vw_hist_academica.acta
							WHEN 'Examen equivalente' 			THEN vw_hist_academica.acta
							WHEN '{$promo}' 					THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN '{$promoOtraC}'	THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN 'Homologada' 					THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia' 				THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia equivalente' 	THEN vw_hist_academica.nro_resolucion
							ELSE '' 
						END as acta_resolucion,
						vw_hist_academica.plan,
						vw_hist_academica.version,
						vw_hist_academica.equivalencia,
						cast(null as char(10)) as fecha_fin_vigencia,
						cast(null as varchar(15))	as comision_nombre, 
						cast(null as integer)		as anio_academico, 
						cast(null as varchar(20))	as periodo_lectivo, 
						cast(null as varchar(10))	as turno_cursada, 
						cast(null as varchar(15))	as catedra, 
						cast(null as varchar(15))	as calidad_insc, 
						cast(null as varchar(10))	as estado_insc, 
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Equivalencia'  THEN 'ET' 
							WHEN 'Equivalencia equivalente' THEN 'ET'
							ELSE cast(null as char(2))
						END as equivalencia_tipo
			FROM	vw_hist_academica,
			OUTER	sga_det_escala, 
					sga_atrib_mat_plan
			WHERE	vw_hist_academica.unidad_academica		= sga_atrib_mat_plan.unidad_academica
			AND		vw_hist_academica.carrera				= sga_atrib_mat_plan.carrera
			AND		vw_hist_academica.plan					= sga_atrib_mat_plan.plan
			AND		vw_hist_academica.version				= sga_atrib_mat_plan.version
			AND		vw_hist_academica.materia				= sga_atrib_mat_plan.materia
			AND		vw_hist_academica.unidad_academica		= {$parametros['_ua']}
			AND		vw_hist_academica.carrera				= {$parametros['carrera']}
			AND		vw_hist_academica.legajo				= {$parametros['legajo']}
			AND		vw_hist_academica.forma_aprobacion		<> 'Homologada'
			AND		sga_det_escala.escala_notas	= vw_hist_academica.escala_notas 
			AND		sga_det_escala.nota			= vw_hist_academica.nota
			UNION ALL
			SELECT	cast('Regularidad' as varchar(11)) as tipo, -- Regularidades 
					sga_atrib_mat_plan.anio_de_cursada, -- A�o de cursada definido en el plan
					sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
					year(sga_cursadas.fecha_regularidad) as anio,
					sga_cursadas.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                        sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
                                        to_char(sga_cursadas.fecha_regularidad, '%d/%m/%Y') as fecha_display,
					to_char(sga_cursadas.fecha_regularidad, '%Y%m%d') as fecha_orden,
					sga_cursadas.comision,
					sga_cursadas.escala_notas,
					sga_cursadas.nota,
					sga_det_escala.descripcion as nota_descripcion,
					sga_det_escala.concepto as nota_concepto,
					sga_cursadas.resultado as resultado,
					-- ********************************************************************
					-- U820 Se decodifica el resultado aprobado de la cursada como Regular
					--DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Regular', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					-- ********************************************************************
					--	DECODE( sga_cursadas.origen, 'P', 'Promoci?n', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equiv. Equivalente', 'CE', 'Cursada Equiv.' ) as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('Promocion' as varchar(12))
						WHEN 'C' THEN cast('Cursada' as varchar(12)) 
						WHEN 'E' THEN 'Equivalencia'
						WHEN 'EE' THEN 'Equivalencia'
						WHEN 'CE' THEN cast('Cursada' as varchar(12))
					END as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('promocion' as varchar(40))
						WHEN 'C' THEN cast('cursada' as varchar(40))
						WHEN 'E' THEN cast('equivalencia_parcial' as varchar(40))
						WHEN 'EE' THEN cast('equivalencia_parcial_equivalente' as varchar(40))
						WHEN 'CE' THEN cast('cursada' as varchar(40))
					END as origen_desc,
					CASE sga_cursadas.origen
						WHEN 'EE' THEN 1
						WHEN 'CE' THEN 1
						ELSE 0
					END as origen_otra_carrera,
					CASE 
						WHEN sga_cursadas.fin_vigencia_regul IS NULL THEN 1
						WHEN sga_cursadas.fin_vigencia_regul IS NOT NULL AND sga_cursadas.fin_vigencia_regul >= TODAY THEN 1
					ELSE 0
					END as vigente,
					sga_cursadas.cond_regularidad,
					sga_atrib_mat_plan.credito,
					CASE sga_cursadas.origen
						WHEN 'P'		THEN cast(sga_cursadas.acta_promocion as varchar(15))
						WHEN 'C' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'CE' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'E'		THEN sga_cursadas.nro_resolucion
						WHEN 'EE'   	THEN sga_cursadas.nro_resolucion 
						ELSE '' 
					END as acta_resolucion,
					sga_cursadas.plan,
					sga_cursadas.version,
					sga_cursadas.equivalencia,
					to_char(sga_cursadas.fin_vigencia_regul, '%d/%m/%Y') as fecha_fin_vigencia,
					cast(null as varchar(15))	as comision_nombre, 
					cast(null as integer)		as anio_academico, 
					cast(null as varchar(20))	as periodo_lectivo, 
					cast(null as varchar(10))	as turno_cursada, 
					cast(null as varchar(15))	as catedra, 
					cast(null as varchar(15))	as calidad_insc, 
					cast(null as varchar(10))	as estado_insc, 
					CASE sga_cursadas.origen
						WHEN 'E' THEN 'EP'
						WHEN 'EE' THEN 'EP'
						ELSE cast(null as char(2))
					END as equivalencia_tipo
			FROM	sga_cursadas,
					OUTER sga_det_escala,
					sga_atrib_mat_plan
			WHERE	sga_atrib_mat_plan.unidad_academica = sga_cursadas.unidad_academica 
			AND		sga_atrib_mat_plan.carrera          = sga_cursadas.carrera 
			AND		sga_atrib_mat_plan.plan             = sga_cursadas.plan 
			AND		sga_atrib_mat_plan.version          = sga_cursadas.version
			AND		sga_atrib_mat_plan.materia          = sga_cursadas.materia
			AND		sga_cursadas.origen		<> 'P' -- Las promociones las obtengo por la vista vw-hist_academica
			AND		sga_cursadas.unidad_academica		= {$parametros['_ua']}
			AND		sga_cursadas.carrera				= {$parametros['carrera']}
			AND		sga_cursadas.legajo					= {$parametros['legajo']}
			AND		sga_det_escala.escala_notas = sga_cursadas.escala_notas 
			AND		sga_det_escala.nota = sga_cursadas.nota
			UNION ALL
			SELECT	cast('En Curso' as varchar(11)) as tipo, -- En Curso
					sga_atrib_mat_plan.anio_de_cursada, 
					sga_atrib_mat_plan.periodo_dictado, 
					sga_comisiones.anio_academico as anio, 
					sga_comisiones.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                        sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
                                        to_char(sga_periodos_lect.fecha_inicio , '%d/%m/%Y') as fecha_display,
					to_char(sga_periodos_lect.fecha_inicio, '%Y%m%d') as fecha_orden,
					sga_insc_cursadas.comision,
					cast(null as int) as escala_notas, 
					cast(null as varchar(5)) as nota, 
					cast(null as varchar(50)) as nota_descripcion, 
					cast(null as varchar(15)) as nota_concepto, 
					cast(null as char(1)) as resultado, 
					cast(null as varchar(10)) as resultado_descripcion, 
					cast('EnCurso' as varchar(12)) as origen,
					cast('en_curso' as varchar(40)) as origen_desc,
					0 as origen_otra_carrera,
					cast(null as int) as vigente, 
					cast(null as int) as cond_regularidad, 
					cast(null as int) as credito, 
					cast(null as varchar(15)) as acta_resolucion,						
					sga_insc_cursadas.plan,
					sga_insc_cursadas.version,
					cast(null as int) as equivalencia,			-- no se usa
					cast(null as char(10)) as fecha_fin_vigencia,	 -- no se usa
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.anio_academico,
					sga_comisiones.periodo_lectivo,
					DECODE(sga_comisiones.turno, 'M', 'Ma?ana', 'T', 'Tarde','N', 'Noche', '') as turno_cursada,
					NVL(sga_comisiones.catedra, '') as catedra,
					DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional') as calidad_insc,
					DECODE(sga_insc_cursadas.estado, 'A', 'Aceptada', 'P', 'Pendiente', 'E', 'Exceptuada') as estado_insc,
					cast(null as char(2)) as equivalencia_tipo
			FROM	sga_insc_cursadas,
					sga_comisiones,
					sga_periodos_lect,
					sga_atrib_mat_plan
			WHERE	sga_insc_cursadas.comision = sga_comisiones.comision
			AND		sga_atrib_mat_plan.unidad_academica  = sga_insc_cursadas.unidad_academica
			AND		sga_atrib_mat_plan.carrera           = sga_insc_cursadas.carrera
			AND		sga_atrib_mat_plan.plan              = sga_insc_cursadas.plan
			AND		sga_atrib_mat_plan.version           = sga_insc_cursadas.version
			AND		sga_atrib_mat_plan.materia           = sga_comisiones.materia
			AND		sga_periodos_lect.anio_academico	 = sga_comisiones.anio_academico
			AND		sga_periodos_lect.periodo_lectivo	 = sga_comisiones.periodo_lectivo
			AND		sga_periodos_lect.fecha_fin >= TODAY  -- Vigente
			-- El alumno no esta en un acta de cursada cerrada
			AND NOT EXISTS (Select 1 FROM sga_actas_cursado WHERE sga_actas_cursado.comision = sga_comisiones.comision AND sga_actas_cursado.estado = 'C')
			-- El alumno no haya promocionado la materia
			AND NOT EXISTS (SELECT 1 
							FROM sga_actas_promo as a, sga_det_acta_promo as b
							WHERE a.comision = sga_comisiones.comision
							AND a.estado = 'C'
							AND b.unidad_academica = sga_insc_cursadas.unidad_academica 
							AND b.carrera  = sga_insc_cursadas.carrera
							AND b.legajo   = sga_insc_cursadas.legajo
							AND b.acta     = a.acta
							AND b.estado    = 'A'
							AND b.resultado = 'P' -- Promocionado
							AND b.rectificado = 'N')
			AND	 sga_insc_cursadas.unidad_academica   =  {$parametros['_ua']}
			AND	 sga_insc_cursadas.carrera            =	{$parametros['carrera']}
			AND	 sga_insc_cursadas.legajo             =	{$parametros['legajo']}
			ORDER BY 9 DESC
		";
        } else {
            $sql = "SELECT	cast('Aprobacion' as varchar(11)) as tipo, -- Historia Academica - Aprobaciones
						sga_atrib_mat_plan.anio_de_cursada, -- A?o de cursada definido en el plan
						sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
						year(vw_hist_academica.fecha) as anio,
						vw_hist_academica.materia,
						sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                                sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
						to_char(vw_hist_academica.fecha, '%d/%m/%Y') as fecha_display,
						to_char(vw_hist_academica.fecha, '%Y%m%d') as fecha_orden,
						cast(null as integer) as comision, -- comision en cursadas
						vw_hist_academica.escala_notas,
						vw_hist_academica.nota,
						sga_det_escala.descripcion as nota_descripcion,
						sga_det_escala.concepto as nota_concepto,
						vw_hist_academica.resultado as resultado,
						DECODE(vw_hist_academica.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promocion', 'U', 'Ausente', '') as resultado_descripcion,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('Examen' as varchar(12))
							WHEN 'Examen equivalente'			THEN cast('Examen' as varchar(12))
							WHEN '{$promo}'					THEN cast('Promocion' as varchar(12))
                                                        WHEN '{$promoOtraC}'	THEN cast('Promocion' as varchar(12))
							WHEN 'Homologada'					THEN cast('Homologada' as varchar(12))
							WHEN 'Equivalencia'					THEN 'Equivalencia'
							WHEN 'Equivalencia equivalente'		THEN 'Equivalencia'
							WHEN 'Otras'						THEN cast('Otras'  as varchar(12))
						END as origen,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen'						THEN cast('examen' as varchar(40))
							WHEN 'Examen equivalente'			THEN cast('examen' as varchar(40))
							WHEN '{$promo}'					THEN cast('promocion' as varchar(40))
							WHEN '{$promoOtraC}'	THEN cast('promocion' as varchar(40))
							WHEN 'Homologada'					THEN cast('homologada' as varchar(40))
							WHEN 'Equivalencia'					THEN cast('equivalencia_total' as varchar(40))
							WHEN 'Equivalencia equivalente'		THEN cast('equivalencia_total_equivalente' as varchar(40))
							WHEN 'Otras'						THEN cast('otras'  as varchar(40))
						END as origen_desc,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen equivalente'			THEN 1
							WHEN '{$promoOtraC}'	THEN 1
							WHEN 'Equivalencia equivalente'		THEN 1
							ELSE 0
						END as origen_otra_carrera,
						1 as vigente, 		   -- vigente en cursadas
						cast(null as integer) as cond_regularidad, -- condicion de regularidad en cursadas
						sga_atrib_mat_plan.credito,
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Examen' 						THEN vw_hist_academica.acta
							WHEN 'Examen equivalente' 			THEN vw_hist_academica.acta
							WHEN '{$promo}' 					THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN '{$promoOtraC}'	THEN cast(vw_hist_academica.acta_promocion as varchar(15))
							WHEN 'Homologada' 					THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia' 				THEN vw_hist_academica.nro_resolucion
							WHEN 'Equivalencia equivalente' 	THEN vw_hist_academica.nro_resolucion
							ELSE '' 
						END as acta_resolucion,
						vw_hist_academica.plan,
						vw_hist_academica.version,
						vw_hist_academica.equivalencia,
						cast(null as char(10)) as fecha_fin_vigencia,
						cast(null as varchar(15))	as comision_nombre, 
						cast(null as integer)		as anio_academico, 
						cast(null as varchar(20))	as periodo_lectivo, 
						cast(null as varchar(10))	as turno_cursada, 
						cast(null as varchar(15))	as catedra, 
						cast(null as varchar(15))	as calidad_insc, 
						cast(null as varchar(10))	as estado_insc, 
						CASE vw_hist_academica.forma_aprobacion
							WHEN 'Equivalencia'  THEN 'ET' 
							WHEN 'Equivalencia equivalente' THEN 'ET'
							ELSE cast(null as char(2))
						END as equivalencia_tipo
			FROM	vw_hist_academica,
			OUTER	sga_det_escala, 
					sga_atrib_mat_plan
			WHERE	vw_hist_academica.unidad_academica		= sga_atrib_mat_plan.unidad_academica
			AND		vw_hist_academica.carrera				= sga_atrib_mat_plan.carrera
			AND		vw_hist_academica.plan					= sga_atrib_mat_plan.plan
			AND		vw_hist_academica.version				= sga_atrib_mat_plan.version
			AND		vw_hist_academica.materia				= sga_atrib_mat_plan.materia
			AND		vw_hist_academica.unidad_academica		= {$parametros['_ua']}
			AND		vw_hist_academica.carrera				= {$parametros['carrera']}
			AND		vw_hist_academica.legajo				= {$parametros['legajo']}
			AND		vw_hist_academica.forma_aprobacion		<> 'Homologada'
			AND		sga_det_escala.escala_notas	= vw_hist_academica.escala_notas 
			AND		sga_det_escala.nota			= vw_hist_academica.nota
			UNION ALL
			SELECT	cast('Regularidad' as varchar(11)) as tipo, -- Regularidades 
					sga_atrib_mat_plan.anio_de_cursada, -- A�o de cursada definido en el plan
					sga_atrib_mat_plan.periodo_dictado, -- Periodo lectivo de Cursada definido en el plan 
					year(sga_cursadas.fecha_regularidad) as anio,
					sga_cursadas.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                        sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
                                        to_char(sga_cursadas.fecha_regularidad, '%d/%m/%Y') as fecha_display,
					to_char(sga_cursadas.fecha_regularidad, '%Y%m%d') as fecha_orden,
					sga_cursadas.comision,
					sga_cursadas.escala_notas,
					sga_cursadas.nota,
					sga_det_escala.descripcion as nota_descripcion,
					sga_det_escala.concepto as nota_concepto,
					sga_cursadas.resultado as resultado,
					-- ********************************************************************
					-- U820 Se decodifica el resultado aprobado de la cursada como Regular
					--DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Regular', 'R', 'Reprobado', 'U','Libre') as resultado_descripcion,
					-- ********************************************************************
					--	DECODE( sga_cursadas.origen, 'P', 'Promoci?n', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equiv. Equivalente', 'CE', 'Cursada Equiv.' ) as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('Promocion' as varchar(12))
						WHEN 'C' THEN cast('Cursada' as varchar(12)) 
						WHEN 'E' THEN 'Equivalencia'
						WHEN 'EE' THEN 'Equivalencia'
						WHEN 'CE' THEN cast('Cursada' as varchar(12))
					END as origen,
					CASE sga_cursadas.origen
						WHEN 'P' THEN cast('promocion' as varchar(40))
						WHEN 'C' THEN cast('cursada' as varchar(40))
						WHEN 'E' THEN cast('equivalencia_parcial' as varchar(40))
						WHEN 'EE' THEN cast('equivalencia_parcial_equivalente' as varchar(40))
						WHEN 'CE' THEN cast('cursada' as varchar(40))
					END as origen_desc,
					CASE sga_cursadas.origen
						WHEN 'EE' THEN 1
						WHEN 'CE' THEN 1
						ELSE 0
					END as origen_otra_carrera,
					CASE 
						WHEN sga_cursadas.fin_vigencia_regul IS NULL THEN 1
						WHEN sga_cursadas.fin_vigencia_regul IS NOT NULL AND sga_cursadas.fin_vigencia_regul >= TODAY THEN 1
					ELSE 0
					END as vigente,
					sga_cursadas.cond_regularidad,
					sga_atrib_mat_plan.credito,
					CASE sga_cursadas.origen
						WHEN 'P'		THEN cast(sga_cursadas.acta_promocion as varchar(15))
						WHEN 'C' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'CE' 		THEN cast(sga_cursadas.acta_regular as varchar(15))
						WHEN 'E'		THEN sga_cursadas.nro_resolucion
						WHEN 'EE'   	THEN sga_cursadas.nro_resolucion 
						ELSE '' 
					END as acta_resolucion,
					sga_cursadas.plan,
					sga_cursadas.version,
					sga_cursadas.equivalencia,
					to_char(sga_cursadas.fin_vigencia_regul, '%d/%m/%Y') as fecha_fin_vigencia,
					cast(null as varchar(15))	as comision_nombre, 
					cast(null as integer)		as anio_academico, 
					cast(null as varchar(20))	as periodo_lectivo, 
					cast(null as varchar(10))	as turno_cursada, 
					cast(null as varchar(15))	as catedra, 
					cast(null as varchar(15))	as calidad_insc, 
					cast(null as varchar(10))	as estado_insc, 
					CASE sga_cursadas.origen
						WHEN 'E' THEN 'EP'
						WHEN 'EE' THEN 'EP'
						ELSE cast(null as char(2))
					END as equivalencia_tipo
			FROM	sga_cursadas,
					OUTER sga_det_escala,
					sga_atrib_mat_plan
			WHERE	sga_atrib_mat_plan.unidad_academica = sga_cursadas.unidad_academica 
			AND		sga_atrib_mat_plan.carrera          = sga_cursadas.carrera 
			AND		sga_atrib_mat_plan.plan             = sga_cursadas.plan 
			AND		sga_atrib_mat_plan.version          = sga_cursadas.version
			AND		sga_atrib_mat_plan.materia          = sga_cursadas.materia
			AND		sga_cursadas.origen		<> 'P' -- Las promociones las obtengo por la vista vw-hist_academica
			AND		sga_cursadas.unidad_academica		= {$parametros['_ua']}
			AND		sga_cursadas.carrera				= {$parametros['carrera']}
			AND		sga_cursadas.legajo					= {$parametros['legajo']}
			AND		sga_det_escala.escala_notas = sga_cursadas.escala_notas 
			AND		sga_det_escala.nota = sga_cursadas.nota
			UNION ALL
			SELECT	cast('En Curso' as varchar(11)) as tipo, -- En Curso
					sga_atrib_mat_plan.anio_de_cursada, 
					sga_atrib_mat_plan.periodo_dictado, 
					sga_comisiones.anio_academico as anio, 
					sga_comisiones.materia,
					sga_atrib_mat_plan.nombre_materia as materia_nombre,
                                        sga_atrib_mat_plan.nombre_reducido as materia_nombre_red,
                                        to_char(sga_periodos_lect.fecha_inicio , '%d/%m/%Y') as fecha_display,
					to_char(sga_periodos_lect.fecha_inicio, '%Y%m%d') as fecha_orden,
					sga_insc_cursadas.comision,
					cast(null as int) as escala_notas, 
					cast(null as varchar(5)) as nota, 
					cast(null as varchar(50)) as nota_descripcion, 
					cast(null as varchar(15)) as nota_concepto, 
					cast(null as char(1)) as resultado, 
					cast(null as varchar(10)) as resultado_descripcion, 
					cast('EnCurso' as varchar(12)) as origen,
					cast('en_curso' as varchar(40)) as origen_desc,
					0 as origen_otra_carrera,
					cast(null as int) as vigente, 
					cast(null as int) as cond_regularidad, 
					cast(null as int) as credito, 
					cast(null as varchar(15)) as acta_resolucion,						
					sga_insc_cursadas.plan,
					sga_insc_cursadas.version,
					cast(null as int) as equivalencia,			-- no se usa
					cast(null as char(10)) as fecha_fin_vigencia,	 -- no se usa
					sga_comisiones.nombre as comision_nombre,
					sga_comisiones.anio_academico,
					sga_comisiones.periodo_lectivo,
					DECODE(sga_comisiones.turno, 'M', 'Ma?ana', 'T', 'Tarde','N', 'Noche', '') as turno_cursada,
					NVL(sga_comisiones.catedra, '') as catedra,
					DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional') as calidad_insc,
					DECODE(sga_insc_cursadas.estado, 'A', 'Aceptada', 'P', 'Pendiente', 'E', 'Exceptuada') as estado_insc,
					cast(null as char(2)) as equivalencia_tipo
			FROM	sga_insc_cursadas,
					sga_comisiones,
					sga_periodos_lect,
					sga_atrib_mat_plan
			WHERE	sga_insc_cursadas.comision = sga_comisiones.comision
			AND		sga_atrib_mat_plan.unidad_academica  = sga_insc_cursadas.unidad_academica
			AND		sga_atrib_mat_plan.carrera           = sga_insc_cursadas.carrera
			AND		sga_atrib_mat_plan.plan              = sga_insc_cursadas.plan
			AND		sga_atrib_mat_plan.version           = sga_insc_cursadas.version
			AND		sga_atrib_mat_plan.materia           = sga_comisiones.materia
			AND		sga_periodos_lect.anio_academico	 = sga_comisiones.anio_academico
			AND		sga_periodos_lect.periodo_lectivo	 = sga_comisiones.periodo_lectivo
			AND		sga_periodos_lect.fecha_fin >= TODAY  -- Vigente
			-- El alumno no esta en un acta de cursada cerrada
			AND NOT EXISTS (Select 1 FROM sga_actas_cursado WHERE sga_actas_cursado.comision = sga_comisiones.comision AND sga_actas_cursado.estado = 'C')
			-- El alumno no haya promocionado la materia
			AND NOT EXISTS (SELECT 1 
							FROM sga_actas_promo as a, sga_det_acta_promo as b
							WHERE a.comision = sga_comisiones.comision
							AND a.estado = 'C'
							AND b.unidad_academica = sga_insc_cursadas.unidad_academica 
							AND b.carrera  = sga_insc_cursadas.carrera
							AND b.legajo   = sga_insc_cursadas.legajo
							AND b.acta     = a.acta
							AND b.estado    = 'A'
							AND b.resultado = 'P' -- Promocionado
							AND b.rectificado = 'N')
			AND	 sga_insc_cursadas.unidad_academica   =  {$parametros['_ua']}
			AND	 sga_insc_cursadas.carrera            =	{$parametros['carrera']}
			AND	 sga_insc_cursadas.legajo             =	{$parametros['legajo']}
			ORDER BY 9 DESC
		";
        }

        $datos = kernel::db()->consultar($sql);

        return $datos;
    }

    /**
     * parametros: _ua, nro_inscripcion
     * cache: no
     * filas: n
     */
    function ficha_alumno_regularidades($parametros) {
        $sql = "EXECUTE PROCEDURE sp_fichaluregular ({$parametros['_ua']},{$parametros['nro_inscripcion']})";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        $datos_con_key = array();
        foreach ($datos as $dato) {

            $vacio = true;
            for ($i = 4; $i < count($dato); $i++) {
                $vacio &= ($dato[$i] == "" || $dato[$i] == "N");
            }

            if ($vacio) {
                continue;
            }

            $dato_con_key = array(
                'vc_UA' => $dato[0],
                'vc_NroInscripcion' => $dato[1],
                'vc_Apellido' => $dato[2],
                'vc_Nombres' => $dato[3],
                'vc_Carrera' => $dato[4],
                'vc_CarreraNombre' => $dato[5],
                'vc_Legajo' => $dato[6],
                'vc_Materia' => $dato[7],
                'vc_MateriaNombre' => $dato[8],
                'vc_Anio' => $dato[9],
                'vc_PerLect' => $dato[10],
                //U820 ************************
                'vc_Resultado' => $dato[12],
                'vc_ResultadoDesc' => $dato[11],
                //U820 ************************
                'vc_Origen' => $dato[13],
                'vd_FinVigencia' => $dato[14],
                'vd_Regularidad' => $dato[15],
                'vc_CondRegular' => $dato[16],
                'vc_PlanReg' => $dato[17],
                'regularidad_vigente_o_no_vigente' => $dato[18],
                'nota' => $dato[19],
                'nro_acta_regulares' => $dato[20],
                'materia_aprobada' => $dato[21],
                'nro_resolucion_equivalencia' => $dato[23],
                'vc_ComNombre' => $dato[23]
            );
            $datos_con_key[] = $dato_con_key;
        }
        return $datos_con_key;
    }

    /**
     * parametros: legajo, carrera, nro_inscripcion
     * cache: no
     * filas: n
     */
    function tipo_titulo($parametros) {
        $sql = "SELECT t.titulo, t.nombre, t.tipo_de_titulo  FROM sga_titulos_otorg as to
                                INNER JOIN sga_titulos as t ON (t.titulo = to.titulo)
                        WHERE legajo = {$parametros['legajo']}  
                         AND carrera =   {$parametros['carrera']}";   
                       // --AND fecha_egreso = (Select max(fecha_egreso) From sga_titulos_otorg Where legajo = {$parametros['legajo']} 
                       //-- AND carrera =   {$parametros['carrera']})";

        return kernel::db()->consultar($sql);
    }

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function promedio_general($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_prom_alu_res({$parametros['unidad_academica']}, {$parametros['carrera']}, {$parametros['legajo']},'S')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos[0];
    }

    /**
     * parametros:  _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function promedio_sin_aplazos($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_prom_alu_res({$parametros['unidad_academica']}, {$parametros['carrera']}, {$parametros['legajo']},'N')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos[0];
    }
    
    
    /**
     * parametros:  nro_inscripcion, carrera
     * cache: no
     * filas: n
     */
    function es_egresado_titulo_final($parametros) {

        $sql = "SELECT a.legajo FROM sga_alumnos a 
                                INNER JOIN sga_titulos_otorg t 
                                    ON (a.legajo = t.legajo AND a.carrera = t.carrera)
                                INNER JOIN sga_titulos 
                                    ON (sga_titulos.titulo = t.titulo and sga_titulos.nivel = 'GRADO')
                WHERE   a.nro_inscripcion = {$parametros['nro_inscripcion']}
		AND a.carrera = {$parametros['carrera']}";
                
        $datos = kernel::db()->consultar($sql);

        return $datos;        
    }
    
    /**
     * parametros: legajo, carrera
     * cache: no
     * filas: n
     */
    function titulos_estado_adelantado($parametros) {
        $sql = "SELECT t.titulo, 
                    CASE WHEN p.sexo = 1 THEN t.nombre 
                        ELSE t.nombre_femenino END as nombre, 
                    t.tipo_de_titulo, to.carrera, to.fecha_egreso, 
                    to.estado, c.tipo_de_carrera  
                    FROM sga_titulos_otorg as to
                    INNER JOIN sga_titulos as t ON (t.titulo = to.titulo)
                    INNER JOIN sga_carreras c ON (c.carrera = to.carrera)
                    JOIN sga_alumnos alu ON alu.legajo = to.legajo AND alu.carrera = to.carrera
                    JOIN sga_personas p ON p.nro_inscripcion = alu.nro_inscripcion
                    WHERE to.legajo = {$parametros['legajo']} 
                    AND to.carrera =   {$parametros['carrera']}
                    AND to.estado in ('A','-', 'X')
                    AND t.nivel IN ('GRADO', 'INTERMEDIO') 
                    AND t.tipo_de_titulo IN ('G', 'D', 'M', 'E', 'P', 'S') 
                    AND to.titulo NOT IN (SELECT DISTINCT PA.titulo
                                            FROM u820_pedidos_certif_diploma PA 
                                            JOIN sga_certif_pedidos CP ON PA.id_certif_pedido = CP.certif_pedido 
                                            JOIN sga_alumnos A ON A.nro_inscripcion = CP.nro_inscripcion
                                            WHERE certificado = 102 AND A.legajo = {$parametros['legajo']} )
                    ";

        return kernel::db()->consultar($sql);
    }    
    
    
    /**
     * parametros: legajo, carrera
     * cache: no
     * filas: n
     */
    function titulos_obtenidos_x_carrera($parametros) {
        $sql = "SELECT t.titulo, 
                        CASE WHEN p.sexo = 1 THEN t.nombre 
                        ELSE t.nombre_femenino END as nombre,
                        t.tipo_de_titulo, to.carrera, to.fecha_egreso, to.estado, c.tipo_de_carrera  
                        FROM sga_titulos_otorg as to
                                INNER JOIN sga_titulos as t ON (t.titulo = to.titulo)
                                INNER JOIN sga_carreras c ON (c.carrera = to.carrera)
                                JOIN sga_alumnos alu ON alu.legajo = to.legajo AND alu.carrera = to.carrera
                                JOIN sga_personas p ON p.nro_inscripcion = alu.nro_inscripcion
                        WHERE to.legajo = {$parametros['legajo']} 
                        AND to.carrera =   {$parametros['carrera']}";
                       

        return kernel::db()->consultar($sql);
    }    
    
    /**
     * parametros: ua, nro_inscripcion
     * cache: no
     * filas: n
     */
    function estudio_superior($parametros) {
        $sql = "SELECT super.nombre, inst.nombre as nombre_institucion
			FROM sga_personas per
			join sga_formacion_acad acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
			join sga_titulos_super super
			on acad.titulo_superior = super.titulo_superior
                        join sga_instituciones inst ON (inst.institucion = acad.institucion)
		WHERE per.unidad_academica = {$parametros['ua']}
			AND per.nro_inscripcion = {$parametros['nro_inscripcion']}
			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
						from  sga_formacion_acad acad1
						where acad1.unidad_academica = {$parametros['ua']}
						and acad1.nro_inscripcion = {$parametros['nro_inscripcion']}); ";

        return kernel::db()->consultar($sql);
    }
    
    /**
     * parametros: tipo_carrera, tipo_tramite
     * cache: no
     * filas: n
     */
    function obtener_requisitos_diploma($parametros) {
        $sql = "SELECT r.nombre, r.requisito, 
                        d.metadato_tipo_documento, d.metadato_subtipo_documento,
                        d.metadato_cantidad_maxima FROM u820_requisitos_diploma d, sga_requisitos r
                    WHERE d.tipo_de_carrera = {$parametros['tipo_carrera']} 
                    AND d.modalidad = 'P'
                    AND r.requisito = d.requisito
					AND d.tipo_tramite = 'N'";

		if ($parametros['tipo_tramite'] == "'E'") {

			$sql .= "UNION 
						SELECT r.nombre, r.requisito, d.metadato_tipo_documento, d.metadato_subtipo_documento, d.metadato_cantidad_maxima
						FROM u820_requisitos_diploma d, sga_requisitos r
						WHERE d.tipo_de_carrera = {$parametros['tipo_carrera']} 
						AND d.modalidad = 'P'
						AND r.requisito = d.requisito						
						AND d.tipo_tramite = 'X'";
		}
        return kernel::db()->consultar($sql);
    }  
    
    
    
    /**
     * parametros: nro_inscripcion, email, telefono
     * cache: no
     * filas: n
     */
    function actualizar_datos_censales($parametros) {
        $sql = "UPDATE sga_datos_censales
                    SET e_mail= {$parametros['email']}, te_per_lect = {$parametros['telefono']}
                        WHERE nro_inscripcion = {$parametros['nro_inscripcion']} 
                        AND fecha_relevamiento = (Select max(fecha_relevamiento) from sga_datos_censales WHERE nro_inscripcion = {$parametros['nro_inscripcion']}) ";

        kernel::db()->ejecutar($sql);
        
        $sql = "UPDATE sga_datos_cen_aux
                    SET celular_numero = {$parametros['telefono']}
                        WHERE nro_inscripcion = {$parametros['nro_inscripcion']} 
                        AND fecha_relevamiento = (Select max(fecha_relevamiento) from sga_datos_censales WHERE nro_inscripcion = {$parametros['nro_inscripcion']}) ";

        return kernel::db()->ejecutar($sql);
    }
    
    /**
     * parametros: nro_inscripcion, titulo, carrera
     * cache: no
     * filas: n
     */
    function actualizar_titulos_otorg($parametros) {
        $sql = "UPDATE sga_titulos_otorg
                    SET estado= 'M'
                        WHERE nro_inscripcion = {$parametros['nro_inscripcion']} 
                        AND titulo = {$parametros['titulo']}
                        AND carrera = {$parametros['carrera']} ";

        return kernel::db()->ejecutar($sql);
    }
    
    /**
     * parametros: ua, nro_inscripcion
     * cache: no
     * filas: n
     */
    function control_encuesta_completa($parametros) {
        $sql = " execute PROCEDURE ctr_encCompPers({$parametros['ua']} , {$parametros['nro_inscripcion']} , '') ;";

        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        
        return $datos;
    }
    
    /**
     * parametros: nro_inscripcion
     * cache: no
     * filas: n
     */
    function datos_principales_alumno($parametros){
        
        $sql = "SELECT * FROM sga_personas WHERE nro_inscripcion = {$parametros['nro_inscripcion']};";
        
        $datos = kernel::db()->consultar_fila($sql);
        
        return $datos;
    }
    
    /**
     * parametros: titulo
     * cache: no
     * filas: n
     */
    function nombre_de_titulo($parametros) {
        $sql = "SELECT t.titulo, t.nombre, t.tipo_de_titulo  FROM sga_titulos as t 
                        WHERE  t.titulo = {$parametros['titulo']}  ";   
                       
                        
        return kernel::db()->consultar_fila($sql);
    }
    
    
    /**
     * parametros: carrera
     * cache: no
     * filas: n
     */
    function tipo_de_carrera($parametros) {
        $sql = "SELECT tipo_de_carrera FROM sga_carreras
                        WHERE  carrera = {$parametros['carrera']}  ";   
                       
        return kernel::db()->consultar_fila($sql);
    }
	
	/**
	 * parametros: alumno, titulo
	 * cache: no
	 * filas: 1
	 */
	function estado_titulo_alumno($parametros) {

		$sql = "SELECT estado FROM sga_titulos_otorg WHERE nro_inscripcion = {$parametros['alumno']} AND titulo = {$parametros['titulo']}";

		$rs = kernel::db()->consultar_fila($sql);
		return $rs['ESTADO'];
	}
}
?>

