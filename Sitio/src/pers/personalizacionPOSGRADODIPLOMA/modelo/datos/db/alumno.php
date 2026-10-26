<?php

namespace personalizacionPOSGRADODIPLOMA\modelo\datos\db;

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

