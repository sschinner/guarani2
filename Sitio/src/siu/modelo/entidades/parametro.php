<?php
namespace siu\modelo\entidades;
use siu\modelo\datos\catalogo;
use kernel\kernel;

class parametro
{
	
	static protected $usa_asignacion_horaria;
	static protected $inscripcion_cursada_calidad;
	static protected $recursar_regularizadas;
	static protected $filtro_materias_con_mesa_exa;
	static protected $filtrar_inscripciones_por_carrera;
	static protected $filtra_carrera_curso_ingreso;
	static protected $filtra_carrera_vocacional;
	static protected $insc_examen_seleccion_auto_tipo_insc;
	static protected $rinde_en_cualquier_sede;
	static protected $rendir_regul_planes_anteriores;
	static protected $modalidad_de_inscripciones_a_examenes;
	static protected $cierre_parcial_acta_cursados;
	static protected $cierre_parcial_modifica_notas;
	static protected $asentar_notas_actas_regulares;
	static protected $horas_borrar_antes_examen;
	static protected $asist_porcentaje_inasist_regul;
	static protected $asist_porcentaje_inasist_promo;
    static protected $orientacion_cambiar_eleccion;
    static protected $cargar_notas_promocion;
    static protected $cantidad_dias_controla_datos_censales;
    static protected $inscripcion_cursada_baja;
    static protected $inscripcion_examen_baja;

	static function usa_asignacion_horaria() 
	{
		if (isset(self::$usa_asignacion_horaria)) return self::$usa_asignacion_horaria;
		$datos = catalogo::consultar('parametro','inscripcion_usar_horarios');
		return $datos[0];
	}	
		
	static function set__usa_asignacion_horaria($valor)
	{
		self::$usa_asignacion_horaria = $valor;
	
		
	}
	static function set__cierre_parcial_acta_cursados($valor)
	{
		self::$cierre_parcial_acta_cursados = $valor;
	}
	
	static function cierre_parcial_acta_cursados() 
	{
		if (isset(self::$cierre_parcial_acta_cursados)) return self::$cierre_parcial_acta_cursados;
		$datos = catalogo::consultar('parametro','cierre_parcial_acta_cursados');
		return $datos[0];
	}	
	
	static function set__asentar_notas_actas_regulares($valor)
	{
		self::$asentar_notas_actas_regulares = $valor;
	}
	
	static function asentar_notas_actas_regulares() 
	{
		if (isset(self::$asentar_notas_actas_regulares)) return self::$asentar_notas_actas_regulares;
		$datos = catalogo::consultar('parametro','asentar_notas_actas_regulares');
		return $datos[0];
	}	
	
	static function set__cargar_notas_promocion($valor)
	{
		self::$cargar_notas_promocion = $valor;
	}
	
	static function cargar_notas_promocion() 
	{
		if (isset(self::$cargar_notas_promocion)) return self::$cargar_notas_promocion;
		$datos = catalogo::consultar('parametro','cargar_notas_promocion');
		return $datos[0];
	}	

	
	static function set__cierre_parcial_modifica_notas($valor)
	{
		self::$cierre_parcial_modifica_notas = $valor;
	}
	
	static function cierre_parcial_modifica_notas() 
	{
		if (isset(self::$cierre_parcial_modifica_notas)) return self::$cierre_parcial_modifica_notas;
		$datos = catalogo::consultar('parametro','cierre_parcial_modifica_notas');
		return $datos[0];
	}		
	//----------------------------------------------------------

	static function insc_examen_seleccion_auto_tipo_insc() 
	{
		if (isset(self::$insc_examen_seleccion_auto_tipo_insc)) return self::$insc_examen_seleccion_auto_tipo_insc;
		$datos = catalogo::consultar('parametro','insc_examen_seleccion_auto_tipo_insc');
		return $datos[0];				
	}
	
	static function set__insc_examen_seleccion_auto_tipo_insc($valor)
	{
		self::$insc_examen_seleccion_auto_tipo_insc = $valor;
	}

	//----------------------------------------------------------

	static function rinde_en_cualquier_sede() 
	{
		if (isset(self::$rinde_en_cualquier_sede)) return self::$rinde_en_cualquier_sede;
		$datos = catalogo::consultar('parametro','rinde_en_cualquier_sede');
		return $datos[0];				
	}
	
	static function set__rinde_en_cualquier_sede($valor)
	{
		self::$rinde_en_cualquier_sede = $valor;
	}
	
	
	//----------------------------------------------------------

	static function modalidad_de_inscripciones_a_examenes() 
	{
		if (isset(self::$modalidad_de_inscripciones_a_examenes)) return self::$modalidad_de_inscripciones_a_examenes;
		$datos = catalogo::consultar('parametro','modalidad_de_inscripciones_a_examenes');
		return $datos[0];				
	}
	
	static function set__modalidad_de_inscripciones_a_examenes($valor)
	{
		self::$modalidad_de_inscripciones_a_examenes = $valor;
	}
	
	
	//----------------------------------------------------------

	static function inscripcion_cursada_calidad() 
	{
		if (isset(self::$inscripcion_cursada_calidad)) return self::$inscripcion_cursada_calidad;
		$datos = catalogo::consultar('parametro','inscripcion_cursada_calidad');
		return $datos[0];				
	}
	
	static function set__inscripcion_cursada_calidad($valor)
	{
		self::$inscripcion_cursada_calidad = $valor;
	}
	
	//----------------------------------------------------------

	static function filtra_carrera_curso_ingreso() 
	{
		if (isset(self::$filtra_carrera_curso_ingreso)) return self::$filtra_carrera_curso_ingreso;
		$datos = catalogo::consultar('parametro','filtra_carrera_curso_ingreso');
		return $datos[0];				
	}
	
	static function set__filtra_carrera_curso_ingreso($valor)
	{
		self::$filtra_carrera_curso_ingreso = $valor;
	}
	
	//----------------------------------------------------------

	static function filtra_carrera_vocacional() 
	{
		if (isset(self::$filtra_carrera_vocacional)) return self::$filtra_carrera_vocacional;
		$datos = catalogo::consultar('parametro','filtra_carrera_vocacional');
		return $datos[0];				
	}
	
	static function set__filtra_carrera_vocacional($valor)
	{
		self::$filtra_carrera_vocacional = $valor;
	}

	//----------------------------------------------------------

	static function filtrar_inscripciones_por_carrera() 
	{
		if (isset(self::$filtrar_inscripciones_por_carrera)) return self::$filtrar_inscripciones_por_carrera;
		$datos = catalogo::consultar('parametro','filtrar_inscripciones_por_carrera');
		return $datos[0];				
	}	
	
	static function set__filtrar_inscripciones_por_carrera($valor)
	{
		self::$filtrar_inscripciones_por_carrera = $valor;
	}

	//----------------------------------------------------------
	
	static function recursar_regularizadas() 
	{
		if (isset(self::$recursar_regularizadas)) return self::$recursar_regularizadas;
		$datos = catalogo::consultar('parametro','recursar_regularizadas');
		return $datos[0];				
	}	
	
	static function set__recursar_regularizadas($valor)
	{
		self::$recursar_regularizadas = $valor;
	}
	
	//----------------------------------------------------------
	
	static function filtro_materias_con_comision() 
	{
		if (isset(self::$filtro_materias_con_comision)) return self::$filtro_materias_con_comision;
		$datos = catalogo::consultar('parametro','filtro_materias_con_comision');
		return $datos[0];				
	}

	
	static function set__filtro_materias_con_comision($valor)
	{
		self::$filtro_materias_con_comision = $valor;
	}

	//----------------------------------------------------------
	
	static function filtro_materias_con_mesa_exa() 
	{
		if (isset(self::$filtro_materias_con_mesa_exa)) return self::$filtro_materias_con_mesa_exa;
		$datos = catalogo::consultar('parametro','filtro_materias_con_mesa_exa');
		return $datos[0];				
	}
	
	static function set__filtro_materias_con_mesa_exa($valor)
	{
		self::$filtro_materias_con_mesa_exa = $valor;
	}
		
	
	//----------------------------------------------------------
	
	static function max_inscripciones_cursada() 
	{
		$datos = catalogo::consultar('parametro','max_inscripciones_cursada');
		return $datos[0];				
	}
		
	function controla_cupo() 
	{
		$datos = catalogo::consultar('parametro','controla_cupo');
		return $datos[0];				
	}		
	
	static function maneja_sedes() 
	{
		$datos = catalogo::consultar('parametro','maneja_sedes');
		return $datos[0];
	}		
	
	static function reinscripcion_ingresante()
	{
		$datos = catalogo::consultar('parametro','reinscripcion_ingresante');
		return $datos[0];				
	}
	
	static function banda_horaria_cursado() 
	{
		$datos = catalogo::consultar('parametro', 'banda_horaria_cursado');
		return $datos[0];
	}
	
	static function permitir_login_mail() 
	{
		$datos = catalogo::consultar('parametro', 'permitir_login_mail');
		return $datos[0];
	}
	
	static function registrar_log_ingresos()
	{
		$datos = catalogo::consultar('parametro', 'registrar_log_ingresos');
		return $datos[0];
	}
	
	static function clave_longitud_minima()
	{
		$datos = catalogo::consultar('parametro', 'clave_longitud_minima');
		return $datos[0];
	}
	
	static function horas_borrar_antes_examen() 
	{
		if (isset(self::$horas_borrar_antes_examen)) return self::$horas_borrar_antes_examen;
		$datos = catalogo::consultar('parametro','horas_borrar_antes_examen');
		return $datos[0];
	}

	//----------------------------------------------------------

	static function rendir_regul_planes_anteriores() 
	{
		if (isset(self::$rendir_regul_planes_anteriores)) return self::$rendir_regul_planes_anteriores;
		$datos = catalogo::consultar('parametro','rendir_regul_planes_anteriores');
		return $datos[0];
	}

	//----------------------------------------------------------

	static function asist_porcentaje_inasist_regul() 
	{
		if (isset(self::$asist_porcentaje_inasist_regul)) return self::$asist_porcentaje_inasist_regul;
		$datos = catalogo::consultar('parametro','asist_porcentaje_inasist_regul');
		return $datos[0];
	}

	//----------------------------------------------------------

	static function asist_porcentaje_inasist_promo() 
	{
		if (isset(self::$asist_porcentaje_inasist_promo)) return self::$asist_porcentaje_inasist_promo;
		$datos = catalogo::consultar('parametro','asist_porcentaje_inasist_promo');
		return $datos[0];
	}

	//----------------------------------------------------------

    static function orientacion_cambiar_eleccion()
    {
        if (isset(self::$orientacion_cambiar_eleccion)) return self::$orientacion_cambiar_eleccion;
        $datos = catalogo::consultar('parametro', 'orientacion_cambiar_eleccion');
        return $datos[0];
    }

    //----------------------------------------------------------

    static function cantidad_dias_controla_datos_censales()
    {
        if (isset(self::$cantidad_dias_controla_datos_censales)) return self::$cantidad_dias_controla_datos_censales;
        $datos = catalogo::consultar('parametro', 'cantidad_dias_controla_datos_censales');
        return $datos[0];
    }

    //----------------------------------------------------------

    static function inscripcion_cursada_baja()
    {
        if (isset(self::$inscripcion_cursada_baja)) return self::$inscripcion_cursada_baja;
        $datos = catalogo::consultar('parametro', 'inscripcion_cursada_baja');
        return $datos[0];
    }

    //----------------------------------------------------------

    static function inscripcion_examen_baja()
    {
        if (isset(self::$inscripcion_examen_baja)) return self::$inscripcion_examen_baja;
        $datos = catalogo::consultar('parametro', 'inscripcion_examen_baja');
        return $datos[0];
    }

    //----------------------------------------------------------
}
?>