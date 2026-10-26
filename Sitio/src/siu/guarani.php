<?php
namespace siu;
use siu\modelo\entidades\persona;
use siu\modelo\entidades\unidad_academica;
use siu\modelo\transacciones\inscripcion_cursada;
use siu\modelo\transacciones\inscripcion_examen;
use siu\modelo\transacciones\datos_censales;
use siu\modelo\transacciones\historia_academica;
use siu\modelo\transacciones\plan_estudios;
use siu\modelo\transacciones\carga_evaluaciones_parciales;
use siu\modelo\transacciones\carga_notas_cursada;
use siu\modelo\transacciones\carga_notas_examen;
use siu\modelo\transacciones\carga_asistencias;
use siu\modelo\transacciones\mensajes;
use siu\modelo\transacciones\solicitud_certificados;
use siu\modelo\transacciones\reinscripcion_carrera;
use siu\modelo\transacciones\orientacion;

use siu\modelo\controles\validador_puntos_de_control;
use siu\modelo\datos\catalogo;

use kernel\kernel;
use siu\errores\error_guarani;
use siu\guarani;
use kernel\util\bcrypt;
use siu\modelo\entidades\parametro;


class guarani
{
	const interfaz = 3; //WEB
	static protected $ua;
	static protected $ua_id;
	static protected $inscripcion_cursada;
	static protected $inscripcion_examen;
	static protected $datos_censales;
	static protected $historia_academica;
	static protected $plan_estudios;
	static protected $carga_notas_cursada;
	static protected $carga_notas_examen;
	static protected $carga_evaluaciones_parciales;
	static protected $carga_asistencias;
	static protected $mensajes;
	static protected $solicitud_certificados;
	static protected $reinscripcion_carrera;
	static protected $orientacion;
	static protected $encuestas;

	static protected $fabrica_formularios;
	
	static function set_ua_id($id)
	{
		self::$ua_id = $id;
	}
	
	static function get_ua_id()
	{
		return self::$ua_id;
	}

	static function dir()
	{
		return \realpath(\dirname(__FILE__));
	}

	//----------------------------------------------------------------------
	// Entidades
	//----------------------------------------------------------------------

	/**
	 *
	 * @return \siu\modelo\entidades\persona
	 */
	static function persona()
	{
        return kernel::persona();
	}

	/**
	 *
	 * @return \siu\modelo\entidades\unidad_academica
	 */
	static function ua()
	{
		if(!isset(self::$ua)) {
			if (!isset(self::$ua_id)) {
				throw new error_guarani("No esta definida la unidad academica");
			}
			self::$ua = kernel::localizador()->instanciar("modelo\\entidades\\unidad_academica", self::$ua_id);
		}
		return self::$ua;
	}
	
	static function lista_sedes()
	{
		return catalogo::consultar('sistema','sedes');
	}

	//----------------------------------------------------------------------
	// Transacciones
	//----------------------------------------------------------------------

	/**
	 * @return \siu\modelo\transacciones\inscripcion_cursada
	 */
	static function cursada()
	{
		if (!self::$inscripcion_cursada) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			$carrera			= guarani::persona()->get_id_carrera_activa();
			$legajo				= guarani::persona()->get_id_legajo_activo();			
			$plan				= guarani::persona()->get_id_plan_activo();			
			$version			= guarani::persona()->get_id_plan_version_activo();			
			self::$inscripcion_cursada = kernel::localizador()->instanciar_params_array("modelo\\transacciones\\inscripcion_cursada", array(
				$nro_inscripcion, $carrera, $legajo, $plan, $version
			));
		}
		return self::$inscripcion_cursada;
	}

	/**
	 * @return \siu\modelo\transacciones\reinscripcion_carrera
	 */
	static function reinscripcion_carerra()
	{
		if (!self::$reinscripcion_carrera) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			$carrera			= guarani::persona()->get_id_carrera_activa();
			$legajo				= guarani::persona()->get_id_legajo_activo();			
			$plan				= guarani::persona()->get_id_plan_activo();			
			$version			= guarani::persona()->get_id_plan_version_activo();			
			self::$reinscripcion_carrera = kernel::localizador()->instanciar_params_array("modelo\\transacciones\\reinscripcion_carrera", array(
				$nro_inscripcion, $carrera, $legajo, $plan, $version
			));
		}
		return self::$reinscripcion_carrera;
	}
	
	/**
	 *
	 * @return \siu\modelo\transacciones\inscripcion_examen
	 */
	static function examen()
	{
		if (!self::$inscripcion_examen) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			$carrera			= guarani::persona()->get_id_carrera_activa();
			$legajo				= guarani::persona()->get_id_legajo_activo();			
			$plan				= guarani::persona()->get_id_plan_activo();			
			$version			= guarani::persona()->get_id_plan_version_activo();		
			self::$inscripcion_examen = kernel::localizador()->instanciar_params_array("modelo\\transacciones\\inscripcion_examen", array(
				$nro_inscripcion, $carrera, $legajo, $plan, $version
			));
		}
		return self::$inscripcion_examen;
	}
	
	
	static function datos_censales()
	{
		if (!self::$datos_censales) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			self::$datos_censales = kernel::localizador()->instanciar("modelo\\transacciones\\datos_censales", $nro_inscripcion);
		}
		return self::$datos_censales;
	}
	
	static function historia_academica()
	{
		if (!self::$historia_academica) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			$carrera			= guarani::persona()->get_id_carrera_activa();
			$legajo				= guarani::persona()->get_id_legajo_activo();
			$plan				= guarani::persona()->get_id_plan_activo();
			$version			= guarani::persona()->get_id_plan_version_activo();
			self::$historia_academica = kernel::localizador()->instanciar_params_array("modelo\\transacciones\\historia_academica", array(
				$nro_inscripcion, $carrera, $legajo, $plan, $version
			));
		}
		return self::$historia_academica;
	}
	
	static function plan_estudios()
	{
		if (!self::$plan_estudios) {
			$nro_inscripcion	= guarani::persona()->get_nro_inscripcion();	
			$carrera			= guarani::persona()->get_id_carrera_activa();
			$legajo				= guarani::persona()->get_id_legajo_activo();
			$plan				= guarani::persona()->get_id_plan_activo();
			$version			= guarani::persona()->get_id_plan_version_activo();
			self::$plan_estudios= kernel::localizador()->instanciar_params_array("modelo\\transacciones\\plan_estudios", array(
				$nro_inscripcion, $carrera, $legajo, $plan, $version
			));
		}
		return self::$plan_estudios;
	}
	
	static function carga_notas_cursada()
	{
		if (! self::$carga_notas_cursada) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$carga_notas_cursada = kernel::localizador()->instanciar("modelo\\transacciones\\carga_notas_cursada", $nro_inscripcion);
		}
		
		return self::$carga_notas_cursada;
	}
	
	static function carga_notas_examen()
	{
		if (! self::$carga_notas_examen) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$carga_notas_examen = kernel::localizador()->instanciar("modelo\\transacciones\\carga_notas_examen", $nro_inscripcion);
		}
		return self::$carga_notas_examen;
	}
	
	static function carga_evaluaciones_parciales()
	{
		if (! self::$carga_evaluaciones_parciales) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$carga_evaluaciones_parciales = kernel::localizador()->instanciar("modelo\\transacciones\\carga_evaluaciones_parciales", $nro_inscripcion);
		}
		
		return self::$carga_evaluaciones_parciales;
	}

	static function carga_asistencias()
	{
		if (! self::$carga_asistencias) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$carga_asistencias = kernel::localizador()->instanciar("modelo\\transacciones\\carga_asistencias", $nro_inscripcion);
		}

		return self::$carga_asistencias;
	}

	static function encuestas()
	{
		if (! self::$encuestas) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$encuestas = kernel::localizador()->instanciar("modelo\\transacciones\\encuestas", $nro_inscripcion);
		}

		return self::$encuestas;
	}
	
	static function mensajes()
	{
		if (! self::$mensajes) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$mensajes = kernel::localizador()->instanciar("modelo\\transacciones\\mensajes", $nro_inscripcion);
		}

		return self::$mensajes;
	}
	
	static function solicitud_certificados()
	{
		if (! self::$solicitud_certificados) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			$carrera		 = guarani::persona()->get_id_carrera_activa();
			$legajo			 = guarani::persona()->get_id_legajo_activo();
			self::$solicitud_certificados = kernel::localizador()->instanciar_params_array("modelo\\transacciones\\solicitud_certificados", array(
				$nro_inscripcion, $carrera, $legajo
			));
		}
		return self::$solicitud_certificados;
	}
	
	static function orientacion()
	{
		if (! self::$orientacion) {
			$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
			self::$orientacion = kernel::localizador()->instanciar("modelo\\transacciones\\orientacion", $nro_inscripcion);
		}

		return self::$orientacion;
	}
	
	//----------------------------------------------------------------------
	// Derechos
	//----------------------------------------------------------------------
	static $derechos = array();
	
	static function derechos($nombre)
	{
		if (! isset(self::$derechos[$nombre])) {
			self::$derechos[$nombre] = kernel::localizador()->instanciar("modelo\\derechos\\$nombre");
		}
		
		return self::$derechos[$nombre];
	}
	
	//----------------------------------------------------------------------
	// Componentes interfaz
	//----------------------------------------------------------------------
	/**
	 * @return fabrica_formularios
	 */
	static function formularios()
	{
		if (!self::$fabrica_formularios)
			self::$fabrica_formularios = kernel::localizador()->instanciar('extension_kernel\\formularios\\fabrica_formularios');
		return self::$fabrica_formularios;
	}
	
	//----------------------------------------------------------------------
	// Paths comunes
	//----------------------------------------------------------------------
	
	static function dir_fonts()
	{
		return self::dir().'/lib/ezpdf/fonts';
	}
	
//	static function path_escalas_js()
	static function path_escalas()
	{
		//return \siu\bootstrap::get_dir_siu().'/escalas/ua_'.self::$ua_id;
		return kernel::proyecto()->get_dir_temp().'/escalas/'.kernel::proyecto()->get_bloque_acceso(); 
//		return \siu\bootstrap::get_dir_siu().'/www/js/escalas/'.self::$ua_id;
	}
	
	static function path_condiciones_js()
	{
		return \siu\bootstrap::get_dir_siu().'/www/js/escalas/'.kernel::proyecto()->get_bloque_acceso();
	}
	
	/**
	 * Mapeo de letra => resultado. 
	 * @return array el mapeo de resultados
	 */
	static function mapeo_resultados()
	{
		return array(
			"A" => "Aprobado",
            "P" => "Promocionado",
            "U" => "Ausente",
            "R" => "Desaprobado"
		);
	}

	/**
	 * Mapeo de letra => resultado. 
	 * @return array el mapeo de resultados
	 */
	static function mapeo_estado_actas()
	{
		return array(
			"A" => "Abierta",
            "C" => "Cerrada",
            "I" => "Impresa sin notas",
            "N" => "Impresa con notas",
            "B" => "Anulada"
		);
	}

	static function mapeo_tipo_actas()
	{
		return array(
			"N" => "Normal",
            "R" => "Rectificativa",
		);
	}
	
	static function encriptar($texto)
	{
		$enc = new bcrypt(10);
		return $enc->hash(md5($texto));	
	}
	
	static function get_password_regexp_without_slashes()
	{
		//si me modifica esta Regular Expression cambiar el mensaje "info_clave_fuerte".
		$minima_cantidad_caracteres_password = parametro::clave_longitud_minima();
		
		//return '^(?!.*(.)\1{1})((?=.*[^\w\d\s])(?=.*\w)|(?=.*[\d])(?=.*\w)).{'.$minima_cantidad_caracteres_password.',}$';
		return '(?=^.{'.$minima_cantidad_caracteres_password.',}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$';
	}
	
	static function get_password_regexp()
	{
		return '/'.self::get_password_regexp_without_slashes().'/';
	}
	
}
?>