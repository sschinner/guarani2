<?php

namespace siu\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;

class parametro {

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function horas_borrar_antes_examen() {
        $sql = "execute procedure sp_param_sistema('horas_borrar_antes_examen')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function inscripcion_usar_horarios() {
        $sql = "execute procedure sp_param_sistema('usa_asignacion_horaria')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function cierre_parcial_acta_cursados() {
        $sql = "execute procedure sp_param_sistema('cierre_parcial_acta_cursados')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function asentar_notas_actas_regulares() {
        $sql = "execute procedure sp_param_sistema('asentar_notas_actas_regulares')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function cierre_parcial_modifica_notas() {
        $sql = "execute procedure sp_param_sistema('cierre_parcial_modifica_notas')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function insc_examen_seleccion_auto_tipo_insc() {
        $sql = "execute procedure sp_param_sistema('insc_examen_seleccion_auto_tipo_insc')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function filtra_carrera_vocacional() {
        $sql = "execute procedure sp_param_sistema('filtra_carrera_vocacional')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function filtra_carrera_curso_ingreso() {
        $sql = "execute procedure sp_param_sistema('filtra_carrera_curso_ingreso')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function filtrar_inscripciones_por_carrera() {
        $sql = "execute procedure sp_param_sistema('filtrar_inscripciones_por_carrera')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function inscripcion_cursada_calidad() {
        $sql = "execute procedure sp_param_sistema('inscripcion_cursada_calidad')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function recursar_regularizadas() {
        $sql = "execute procedure sp_param_sistema('recursar_regularizadas')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function filtro_materias_con_comision() {
        $sql = "execute procedure sp_param_sistema('filtro_materias_con_comision')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function filtro_materias_con_mesa_exa() {
        $sql = "execute procedure sp_param_sistema('filtro_materias_con_mesa_exa')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     * filas: n
     */
    function max_inscripciones_cursada() {
        $sql = "execute procedure sp_param_sistema('cant_max_insc_curs_por_mat_en_per_lect')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function controla_cupo() {
        $sql = "execute procedure sp_param_sistema('insc_cursada_controla_cupo_comision')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function maneja_sedes() {
        $sql = "execute procedure sp_param_sistema('maneja_sedes')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function reinscripcion_ingresante() {
        $sql = "execute procedure sp_param_sistema('reinscripcion_ingresante')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function banda_horaria_cursado() {
        $sql = "select	min(hs_comienzo_clase) as HMIN,
						max(hs_finaliz_clase) as HMAX
				from	sga_asignaciones";
        $datos = kernel::db()->consultar($sql);
        $m = explode(':', $datos[0]['HMIN']);
        $datos[0]['min'] = $m[0] . ':00:00';
        $m = explode(':', $datos[0]['HMAX']);
        $datos[0]['max'] = ($m[1] + 0 != 0 ? $m[0] + 1 : $m[0]) . ':00:00';
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function orientacion_tipo_eleccion() {
        $sql = "execute procedure sp_param_sistema('orientacion_tipo_eleccion')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function orientacion_cambiar_eleccion() {
        $sql = "execute procedure sp_param_sistema('orientacion_cambiar_eleccion')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function permitir_login_mail() {
        $sql = "execute procedure sp_param_sistema('acceso_web_permitir_login_por_mail')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function registrar_log_ingresos() {
        $sql = "execute procedure sp_param_sistema('registrar_log_ingresos')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function clave_longitud_minima() {
        $sql = "execute procedure sp_param_sistema('clave_longitud_minima')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function rendir_regul_planes_anteriores() {
        $sql = "execute procedure sp_param_sistema('rendir_regul_planes_anteriores')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function rinde_en_cualquier_sede() {
        $sql = "execute procedure sp_param_sistema('rinde_en_cualquier_sede')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function modalidad_de_inscripciones_a_examenes() {
        $sql = "execute procedure sp_param_sistema('modalidad_de_inscripciones_a_examenes')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function asist_porcentaje_inasist_regul() {
        $sql = "execute procedure sp_param_sistema('asist_porcentaje_inasist_regul')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function asist_porcentaje_inasist_promo() {
        $sql = "execute procedure sp_param_sistema('asist_porcentaje_inasist_promo')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function cargar_notas_promocion() {
        $sql = "execute procedure sp_param_sistema('cargar_notas_promocion')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function cantidad_dias_controla_datos_censales() {
        $sql = "execute procedure sp_param_sistema('cantidad_dias_controla_datos_censales')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function inscripcion_cursada_baja() {
        $sql = "execute procedure sp_param_sistema('inscripcion_cursada_baja')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * cache: memoria
     * cache_expiracion: 60
     */
    function inscripcion_examen_baja() {
        $sql = "execute procedure sp_param_sistema('inscripcion_examen_baja')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

}

?>