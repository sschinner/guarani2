<?php
namespace siu\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;

class plan_estudios
{
	/**
	 * parametros: _ua, carrera, plan, version
	 * cache: memoria
	 * filas: n
	 */
	function get_detalle_plan_estudios($parametros)
	{
		$ret = array();
		$sql = "SELECT 
					sga_atrib_mat_plan.nombre_materia,
					sga_atrib_mat_plan.materia,
					sga_atrib_mat_plan.anio_de_cursada,
					sga_atrib_mat_plan.periodo_dictado,
					DECODE(sga_atrib_mat_plan.tipo_materia, 'G', 'Genérica', 'N', 'Normal', 'O', 'Optativa') as tipo_materia,
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
		$genericas = $this->get_materias_genericas($parametros);

		foreach ($detalle_plan as $key => $materia) {
			$ret[$key]['MATERIA']			= $materia[1];
			$ret[$key]['NOMBRE_MATERIA']	= $materia[0];
			$ret[$key]['TIPO']				= $materia[7];
			$ret[$key]['TIPO_DETALLE']		= kernel::traductor()->trans("plan.estado.".trim($materia[7]));
			$ret[$key]['ANIO']				= $materia[2];
			$ret[$key]['PERIODO']			= $materia[3];
			$ret[$key]['CREDITO']			= $materia[5];
			if ($materia[7] == 'G') {
				$ret[$key]['OPTATIVAS'] = $genericas[$detalle_plan[$key][1]];
			}
		}
		$ret_final = array();
		$ret_final['detalle'] = $ret;
		return  $ret_final; 
	}
	
	
	/**
	 * parametros: _ua,  carrera, plan, version
	 * cache: memoria
	 * filas: n
	 */
	function get_materias_genericas($parametros)
	{
		$datos = array();
		$sql = "SELECT	sga_mat_genericas.materia_generica,
						sga_mat_genericas.materia_optativa,
						sga_materias.nombre,
						sga_mat_genericas.valor_materia
				FROM	sga_atrib_mat_plan,
						sga_mat_genericas,
						sga_materias
				WHERE	sga_atrib_mat_plan.unidad_academica = {$parametros["_ua"]}
				AND		sga_atrib_mat_plan.carrera			= {$parametros["carrera"]}
				AND		sga_atrib_mat_plan.plan				= {$parametros["plan"]} 
				AND		sga_atrib_mat_plan.version			= {$parametros["version"]} 
				AND		sga_mat_genericas.unidad_academica	= sga_atrib_mat_plan.unidad_academica
				AND		sga_mat_genericas.materia_generica	= sga_atrib_mat_plan.materia
				AND		sga_materias.unidad_academica		= sga_mat_genericas.unidad_academica
				AND		sga_materias.materia				= sga_mat_genericas.materia_optativa
				AND		sga_atrib_mat_plan.tipo_materia     = 'G'
				ORDER BY 3";

		$genericas = kernel::db()->consultar($sql);

		$datos = array();
		foreach ($genericas as $key => $generica) {
			$insertar['MATERIA_OPTATIVA']	= $generica['MATERIA_OPTATIVA'];
			$insertar['NOMBRE']				= $generica['NOMBRE'];
			$insertar['VALOR_MATERIA']				= $generica['VALOR_MATERIA'];
			$datos[$generica['MATERIA_GENERICA']][] = $insertar;
		}
		return $datos;
	}

    /**
     * parametros:  _ua
     * cache: memoria
     * filas: n
     */
    function carreras($parametros)
    {
        $sql = "SELECT DISTINCT sga_carreras.carrera, sga_carreras.nombre
                FROM sga_carreras
                     JOIN sga_planes ON (sga_carreras.unidad_academica = sga_planes.unidad_academica AND sga_carreras.carrera = sga_planes.carrera)
                WHERE sga_carreras.unidad_academica  =  {$parametros['_ua']}
                  AND sga_carreras.estado <> 'B'
                  --AND c.estado        <> 'S'
                  AND sga_planes.estado <> 'N'
                ORDER BY sga_carreras.nombre
				";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        $nuevo = array();
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['CARRERA_NOMBRE'] = "({$dato['CARRERA']}) {$dato['NOMBRE']}";
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['CARRERA']);
        }
        return $nuevo;
    }
	
	
	/**
	 * parametros:  _ua, carrera
	 * cache: memoria
	 * filas: n
	 */
	function planes($parametros)
	{
		$sql = "SELECT	sga_planes.plan, sga_planes.version_actual, sga_planes.fecha_ent_vigencia
				FROM	sga_planes
				WHERE	sga_planes.unidad_academica = {$parametros['_ua']}
				AND		sga_planes.carrera = {$parametros['carrera']}
				AND     sga_planes.estado IN ('A','V')
				ORDER BY sga_planes.fecha_ent_vigencia DESC
				";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        $nuevo = array();
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['PLAN']);
        }
        return $nuevo;
	}
	
	/**
	 * parametros:  _ua, carrera, plan
	 * cache: memoria
	 * filas: n
	 */
	function versiones_de_plan($parametros)
	{
		$sql = "SELECT	sga_versiones_plan.version, sga_versiones_plan.fecha_ent_vigencia
				FROM	sga_versiones_plan
				WHERE	sga_versiones_plan.unidad_academica = {$parametros['_ua']}
				AND		sga_versiones_plan.carrera = {$parametros['carrera']}
				AND		sga_versiones_plan.plan = {$parametros['plan']}
				ORDER BY sga_versiones_plan.fecha_ent_vigencia DESC
				";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        $nuevo = array();
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['VERSION']);
        }
        return $nuevo;
	}

    /**
     * parametros: _ua, carrera, legajo
     * cache: no
     * filas: n
     */
    function get_resultado_puntaje_optativas($parametros)
    {
        /*
        -- DESCRIPCION DEL RETURN
        -- ls_materia_opt,
        -- ls_mat_opt_nombre,
        -- ls_result,
        -- li_valor_materia,
        -- ls_materia_gen,
        -- ls_mat_gen_nombre,
        -- li_requerido,
        -- li_puntaje_apr,
        -- li_puntaje_reg,
        -- ls_plan: plan actual
        -- ls_version: version actual del plan del alumno
        -- ls_nombre,
        -- ls_apellido,
        -- ls_nom_carrera,
        -- pCarrera,
        -- pLegajo;
        */

        $sql = "EXECUTE PROCEDURE sp_opt_gen_puntaje({$parametros['_ua']},{$parametros['carrera']},{$parametros['legajo']})";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        $materia_generica = '';
        $resultado = array();

        foreach ($datos as $key => $dato)
        {
            if ($materia_generica == $dato[4])
            {
                $this->sumar_puntajes_mat_opt($dato, $resultado, $materia_generica);
            }else
            {
                $materia_generica = $dato[4];
                $resultado[$materia_generica]['ptaje_aprob'] = 0;
                $resultado[$materia_generica]['ptaje_cur'] = 0;
                $resultado[$materia_generica]['ptaje_requerido'] = $dato[3];
                $this->sumar_puntajes_mat_opt($dato, $resultado, $materia_generica);
            }
        }
        return $resultado;
    }

    protected function sumar_puntajes_mat_opt ($dato, &$resultado, $materia_generica)
    {
        if ($dato[2] == \siu\modelo\transacciones\plan_estudios::TIPO_CORRELATIVA_APROBACION)
        {
            $resultado[$materia_generica]['ptaje_aprob'] += $dato[3];
            $resultado[$materia_generica]['ptaje_cur'] += $dato[3];

        }elseif ($dato[2] == \siu\modelo\transacciones\plan_estudios::TIPO_MATERIA_REGULARIZADA)
        {
            $resultado[$materia_generica]['ptaje_cur'] += $dato[3];
        }
    }
	
}

?>
