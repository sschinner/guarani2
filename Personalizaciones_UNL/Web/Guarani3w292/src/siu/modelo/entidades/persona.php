<?php

namespace siu\modelo\entidades;

use siu\modelo\datos\catalogo;
use siu\modelo\entidades\encuestas_kolla;
use siu\errores\error_guarani;
use siu\errores\error_guarani_procesar_renglones;
use kernel\kernel;
use siu\errores\error_guarani_usuario;
use kernel\acceso\persona_con_derechos;
use kernel\acceso\factory_perfil;
use \kernel\util\cache\admin_cache;
use \siu\guarani;
use kernel\util\bcrypt;

class persona extends persona_con_derechos
{
	const REFRESCO_BUZON_MENSAJES = 60; //1 Minuto
	protected $nro_inscripcion;
	protected $datos_basicos=array();
	protected $datos_carreras=array();
	protected $datos_perfiles=array();
	protected $datos_configuracion=array();
	protected $datos_personales_alumno = array();

	protected $perfil;
    protected $id_perfil_activo;
	protected $id_carrera_activa;

	protected $estado_cursadas;
	protected $estado_examenes;

    function __construct($nro_inscripcion)
    {
		$this->nro_inscripcion = $nro_inscripcion;
		$parametros = array('nro_inscripcion' => $this->nro_inscripcion);
		$this->datos_basicos = catalogo::consultar('persona', 'datos_basicos', $parametros);
		$perfiles_validos = self::get_perfiles_validos($nro_inscripcion);
		$this->datos_perfiles = $perfiles_validos;
		$perfil_default = $this->get_id_perfil_activo();	
		if (isset($perfiles_validos[$perfil_default])) {
			$perfil = $perfil_default;
		} else {
			$perfil = current($perfiles_validos);;
		}
		
		// U820 - Nuevo perfil para manejo de alumnos ATILRA
		// *************************************************
		//if ($perfil == 'ALU') {
		if(in_array($perfil, array("ALU", "ALU1"))) {
		// *************************************************
			$this->datos_carreras = self::get_carreras_perfil($nro_inscripcion);
			$this->set_carrera_activa($this->get_id_carrera_activa());
            $datos_personales_alumno = catalogo::consultar('alumno', 'datos_personales', $parametros);
            $this->datos_personales_alumno = $datos_personales_alumno[0];
		}
			$this->set_configuracion();
			
			$this->set_perfil_activo($perfil);

			kernel::log()->add_debug('cargar PERSONA', $this->nro_inscripcion);
		//}
		
		/*
		$filtrar_vocacional = catalogo::consultar('sistema','parametro',
										array('parametro'=>'filtra_carrera_vocacional'));
		
		$filtra_carrera_curso_ingreso = catalogo::consultar('sistema','parametro',
										array('parametro'=>'filtra_carrera_curso_ingreso'));
		
		$parametros = array_merge($parametros, array('filtra_carrera_vocacional' => $filtrar_vocacional[0], 'filtra_carrera_curso_ingreso' => $filtra_carrera_curso_ingreso[0]));
		
		$this->datos_carreras = catalogo::consultar('persona', 'carreras', $parametros);*/
		
		//$cache_config = array();
		//$cache_config[catalogo::cache_config_tipo] = \kernel\util\cache\admin_cache::tipo_memoria;
		//$cache_config[catalogo::cache_config_expiracion] = self::REFRESCO_BUZON_MENSAJES;
		//$this->datos_configuracion = catalogo::consultar('persona', 'get_configuracion', $parametros, $cache_config);
    }
	
	function set_configuracion()
	{
		$parametros = array('nro_inscripcion' => $this->nro_inscripcion);
		$this->datos_configuracion = catalogo::consultar('persona', 'configuracion', $parametros);
	}
	
	function get_nro_inscripcion()
	{
		return $this->nro_inscripcion;
	}

    function get_nombre()
    {
        return $this->datos_basicos['NOMBRES'].' '.$this->datos_basicos['APELLIDO'];
    }

    function get_identificacion()
    {
        return $this->datos_basicos['IDENTIFICACION'];
    }

    function get_sexo()
    {
        return $this->datos_basicos['SEXO'];
    }

    function get_tipo_documento_descripcion()
    {
        return $this->datos_basicos['TIPO_DOCUMENTO_DESCRIPCION'];
    }

    function get_tipo_documento_desc_abreviada()
    {
        return $this->datos_basicos['TIPO_DOCUMENTO_DESC_ABREVIADA'];
    }

    function get_nro_documento()
    {
        return $this->datos_basicos['NRO_DOCUMENTO'];
    }

    function get_nacionalidad()
    {
        return $this->datos_basicos['NACIONALIDAD'];
    }

    function get_nacionalidad_descripcion()
    {
        return $this->datos_basicos['NACIONALIDAD_DESCRIPCION'];
    }

    function get_alumno_anio_ingreso()
    {
        return $this->datos_personales_alumno['anio_ingreso'];
    }
	
	function get_mail()
	{
		return $this->datos_configuracion['E_MAIL'];
	}
	
	function get_configuracion()
	{
		return $this->datos_configuracion;
	}

	function get_id_imagen()
	{
		return $this->datos_basicos['ID_IMAGEN'];
	}
	
	//--------------------------------------------------------
	// ENUESTAS
	//--------------------------------------------------------
	
	function get_encuestas_pendientes()
	{
		return encuestas_kolla::get_encuestas_pendientes($this->nro_inscripcion);
	}
	
	function set_encuestas_respondidas($hab, $token, $fecha_respuesta){
		return encuestas_kolla::set_encuestas_respondidas($this->nro_inscripcion, $hab, $token, $fecha_respuesta);
	}

    function get_encuestas_respondidas($fecha_desde, $fecha_hasta, $legajo_docente, $materia)
    {
        return encuestas_kolla::get_encuestas_respondidas($this->nro_inscripcion, $fecha_desde, $fecha_hasta, $legajo_docente, $materia);
    }


	//--------------------------------------------------------
	// PERFILES
	//--------------------------------------------------------
	
	
	static function get_perfiles_validos($nro_inscripcion) 
	{	
		$param = array('nro_inscripcion' => $nro_inscripcion);
		$return	= array();
		$perfiles =  catalogo::consultar('persona', 'get_estado_perfil', $param);
		foreach ($perfiles as $perfil) { 
			////foreach ($perfiles as $key => $perfil) {
			if($perfil['estado'] == 'A'){
				// U820 - Nuevo perfil para manejo de alumnos ATILRA
				// *************************************************
				//if($perfil['tipo_usuario'] == 'ALU'){
				if(in_array($perfil['tipo_usuario'], array("ALU", "ALU1"))){
				// *************************************************
					$cant_carreras = count(self::get_carreras_perfil($nro_inscripcion));
					if ($cant_carreras != 0) {
						//$return[$perfil['tipo_usuario']]  = array('tipo_usuario' =>$perfil['tipo_usuario']);
						$return[$perfil['tipo_usuario']]  = $perfil['tipo_usuario'];
					}
				} else {
					// docente o gerencial
					//$return[$perfil['tipo_usuario']] = array('tipo_usuario' =>$perfil['tipo_usuario']);
					$return[$perfil['tipo_usuario']] = $perfil['tipo_usuario'];
				}
			}
		}
		return $return;
	}
	
	static function get_carreras_perfil($nro_inscripcion)
	{
		$filtrar_vocacional = catalogo::consultar('sistema','parametro',
										array('parametro'=>'filtra_carrera_vocacional'));
		
		$filtra_carrera_curso_ingreso = catalogo::consultar('sistema','parametro',
										array('parametro'=>'filtra_carrera_curso_ingreso'));
		
		$parametros = array('nro_inscripcion' => $nro_inscripcion,
			'filtra_carrera_vocacional' => $filtrar_vocacional[0],
			'filtra_carrera_curso_ingreso' => $filtra_carrera_curso_ingreso[0]
		);
		
		$carreras = catalogo::consultar('persona', 'carreras', $parametros);

		return $carreras;
	}
	
    function perfil()
    {
        return $this->perfil;
    }

	function set_perfil_activo($id)
	{
		if (!in_array($id, $this->get_perfiles())) {
			throw new \Exception("PERSONA: Error interno '$id'");
		}
		$this->perfil = factory_perfil::instancia()->construir($id, kernel::proyecto()->get('bloque_acceso'));
		kernel::sesion()->set('__persona_perfil', $id);
	}

	function get_perfiles()
    {
		return $this->datos_perfiles;		
    }

    function get_id_perfil_activo()
    {
        if (kernel::sesion()->esta_seteada('__persona_perfil')) {
            return kernel::sesion()->get('__persona_perfil');
        }
        return $this->get_perfil_defecto();
    }

    protected function get_perfil_defecto()
    {
        return $this->datos_basicos['PERFIL_INICIAL'];
    }
	
	function get_count_perfiles()
	{
		return count($this->datos_perfiles);
	}

	function es_perfil_docente()
	{
		return $this->es_docente() && ($this->get_id_perfil_activo() == 'DOC');
	}
	
	//--------------------------------------------------------
	// DOCENTE
	//--------------------------------------------------------	

    function es_docente()
    {
        return (in_array('DOC', $this->get_perfiles()) && isset($this->datos_basicos['LEGAJO_DOCENTE']));
    }	
	
	function get_legajo_docente()
	{
		if ($this->es_docente()) {
			return $this->datos_basicos['LEGAJO_DOCENTE'];
		} else {
			throw new error_guarani('La persona no es docente');
		}
	}
		
	//--------------------------------------------------------
	// ALUMNO
	//--------------------------------------------------------

    function es_alumno()
    {
	// U820 - Nuevo perfil para manejo de alumnos ATILRA
	// *************************************************        
	//return in_array('ALU', $this->get_perfiles());
        return in_array('ALU', $this->get_perfiles()) || in_array('ALU1', $this->get_perfiles());
	// *************************************************        
    }	
	
	function tiene_carreras()
	{
		return (count($this->datos_carreras)>0);
	}
	
	function set_carrera_activa($id)
    {
        if (!in_array($id, $this->get_carreras())) {
            throw new \Exception("PERSONA: Error interno. La carrera activa: $id no esta entre las carreras del alumno");
        }
        kernel::sesion()->set('__persona_carrera', $id);
    }

//    function get_info_carreras()
//    {
//        return $this->datos_carreras;
//    }
    
	function get_carreras()
    {
		if(!isset($this->id_carreras)){
			foreach($this->datos_carreras as $carrera) {
				$this->id_carreras[] = $carrera['CARRERA'];
			}
		}
        return $this->id_carreras;
    }
    
	function get_lista_carreras()
    {
		$carreras = array();
		foreach($this->datos_carreras as $id => $carrera) {
			$carreras[$id]['id'] = $carrera[catalogo::id];
			$carreras[$id]['carrera'] = $carrera['CARRERA'];
			$carreras[$id]['nombre'] = $carrera['NOMBRE'];
		}
		return $carreras;
    }

    function get_id_carrera_activa()
    {
        if (kernel::sesion()->esta_seteada('__persona_carrera')) {
            return kernel::sesion()->get('__persona_carrera');
        }
        return $this->get_carrera_defecto();
    }
    
    function get_info_carrera_activa()
    {
        $id = $this->get_id_carrera_activa();
		foreach($this->datos_carreras as $carrera) {
			if($carrera['CARRERA']==$id) {
				return array(
					'id' => $carrera['CARRERA'],
					'nombre' => $carrera['NOMBRE']
				);
			}
		}		
    }

    protected function get_carrera_defecto()
    {
        $carreras = $this->get_carreras();
		if(!isset($carreras[0])) {
			throw new error_guarani('No existen carreras');
		}
        return $carreras[0];
    }

	function get_id_legajo_activo()
	{
		$id = $this->get_id_carrera_activa();
		foreach($this->datos_carreras as $carrera) {
			if($carrera['CARRERA']==$id) {
				return $carrera['LEGAJO'];
			}
		}		
	}

	function get_id_plan_activo()
	{
		$id = $this->get_id_carrera_activa();
		foreach($this->datos_carreras as $carrera) {
			if($carrera['CARRERA']==$id) {
				return $carrera['PLAN'];
			}
		}		
	}

	function get_id_plan_version_activo()
	{
		$id = $this->get_id_carrera_activa();
		foreach($this->datos_carreras as $carrera) {
			if($carrera['CARRERA']==$id) {
				return $carrera['VERSION'];
			}
		}		
	}
	
	function get_periodo_inscripcion_activo()
	{
		$id = $this->get_id_carrera_activa();
		foreach($this->datos_carreras as $carrera) {
			if($carrera['CARRERA']==$id) {
				return $carrera['PERIODO_INSCRIPCIO'];
			}
		}		
	}

    function get_anio_ingreso_carrera_activa()
    {
    	// Recupera el anio de ingreso en la carrera que esta activa. Año académico segun periodo de inscripción en la carrera 
        $id = $this->get_id_carrera_activa();
        foreach($this->datos_carreras as $carrera) {
            if($carrera['CARRERA']==$id) {
                return $carrera['ANIO_ACADEMICO'];
            }
        }
    }
	
//--------------------------------------------------------
	// MENSAJES
	//--------------------------------------------------------
	
	function get_cantidad_mensajes()
	{
		$param = array('nro_inscripcion' => $this->nro_inscripcion);
		return catalogo::consultar('mensajes', 'get_cant_mensajes', $param);
	}

	//--------------------------------------------------------
	// ESTADO INSCRIPCIONES CURSADA
	//--------------------------------------------------------

	/**
	 *
	 * @return \siu\modelo\entidades\alumno_estado_insc_cursada
	 */
	function cursadas()
	{
		if (!isset($this->estado_cursadas)) {
			$this->estado_cursadas = new alumno_estado_insc_cursada($this->nro_inscripcion);
		}
		return $this->estado_cursadas;
	}
	
	
	//--------------------------------------------------------
	// ESTADO INSCRIPCIONES EXAMENES
	//--------------------------------------------------------
	
	/**
	 *
	 * @return \siu\modelo\entidades\alumno_estado_insc_examen
	 */
	function examenes()
	{
		if (!isset($this->estado_examenes)) {
			$this->estado_examenes = new alumno_estado_insc_examen($this->nro_inscripcion);
		}
		return $this->estado_examenes;
	}
	
	
	
	//--------------------------------------------------------
	
    function get_locale()
    {
        return 'es_AR';
//        return 'en_US';
    }

	protected function get_mem_key($seed)
	{
		$nro = $this->get_nro_inscripcion();
		return "userdata[$nro]".md5("$nro$seed");
	}
	
	/**
	 * 
	 * @param string $key
	 * @return mixed Si la clave existe devuelve el valor asociado. Sino devuelve FALSE
	 */
	function get_user_data($key)
	{
		$mem_key = $this->get_mem_key($key);
		$cache = admin_cache::instancia(admin_cache::tipo_memoria);
		if ($cache->existe($mem_key)) {
			return $cache->buscar($mem_key);
		}
		
		return false;
	}
	/**
	 *
	 * @param string $key
	 * @param mixed $value
	 * @param int $expiration Tiempo de expiración, defaults a 0 (sin expiración). 
	 * Más info en: http://www.php.net/manual/en/memcached.expiration.php
	 * @return boolean TRUE si se escribió correctamente y FALSE en caso contrario 
	 */
	function set_user_data($key, $value, $expiration = 60)
	{
		if ($expiration === false) {
			$expiration = 0; // no hay tiempo de expiración
		}
		
		$mem_key = $this->get_mem_key($key);
		$cache = admin_cache::instancia(admin_cache::tipo_memoria);
		$cache->guardar($mem_key, $value, $expiration);
		return true;
	}
    
	/**
	 *
	 * @param integer $pais
	 * @param integer $tipo_doc
	 * @param integer $doc
	 * @return array list($mail, $nro_inscripcion)
	 * @throws error_guarani_usuario 
	 */
	static function get_data_recuperar_pass($pais, $tipo_doc, $doc)
	{
		$param = array(
			'pais' => $pais,
			'tipo_doc' => $tipo_doc,
			'doc' => $doc
		);
		$res = catalogo::consultar('persona', 'data_recuperar_pass', $param);
		
		if ($res[0] == -1) {
			throw new error_guarani_usuario($res[1]);
		}
		
		return array($res[2], $res[3], $res[4]);
	}

	static function update_token($nro_inscripcion, $token, $email=false)
	{
		$param = array(
			'nro_inscripcion' => $nro_inscripcion,
			'token' => $token,
			'email' => $email?$email:''
		);
		catalogo::consultar('persona', 'update_token', $param);
	}
	
	static function generar_token()
	{
		return sha1(uniqid(rand(0,100)));
	}
	
	static function get_nro_inscripcion_from_token($token)
	{
		$param = array(
			'token' => $token
		);
		
		$res = catalogo::consultar('persona', 'buscar_por_token', $param);
		if (empty($res)) {
			throw new error_guarani('no hay una persona asociada a este token');
		}
		
		return $res;
	}
	
	static function get_mail_from_token($token=false, $nro_inscripcion=false)
	{
		$param = array(
			'token' => $token,
			'nro_inscripcion' => $nro_inscripcion
		);
		
		$res = catalogo::consultar('persona', 'buscar_mail_token', $param);
		if ($token && empty($res)) {
			throw new error_guarani('no hay una persona asociada a este token');
		}
		
		return $res;
	}
	
	static function eliminar_token($token=null, $nro_inscripcion=null)
	{
		$param = array(
			'token' => $token,
			'nro_inscripcion' => $nro_inscripcion
		);
		catalogo::consultar('persona', 'eliminar_token', $param);
	}
	
	static function reset_password($nro_inscripcion, $password)
	{
		persona::controlar_password($password);
		$param = array(
			'nro_inscripcion' => $nro_inscripcion,
			'password' => guarani::encriptar($password)
		);
		
		catalogo::consultar('persona', 'reset_password', $param);
	}
	
    static function actualizar_configuracion($nro_inscripcion, $recibe_mail, $mail)
	{
        $parametros = array();
        $parametros['nro_inscripcion'] = $nro_inscripcion;
        $parametros['recibe_mail'] = $recibe_mail;
        $parametros['mail'] = $mail;
        
        catalogo::consultar('persona', 'actualizar_configuracion', $parametros);
    }
    
    static function actualizar_password($usuario, $actual_pass, $nuevo_pass)
    {
		$parametros = array();
		$parametros['id'] = $usuario;
		//$respuesta = catalogo::consultar('persona', 'actualizar_password', $parametros);
		
		$enc = new bcrypt(10);
		$datos_clave = catalogo::consultar('persona', 'buscar_clave', $parametros);
		$actual_pass_ok = ($enc->verify(md5($actual_pass), current($datos_clave)));
		$resultado = array();
		
		if($actual_pass_ok){//si el password actual es valido
			
				$pattern = guarani::get_password_regexp();
				
				if(!$nuevo_pass){//si el password nuevo es vacio
					$resultado['cod'] = -1;
					$resultado['cont'] = ucfirst(kernel::traductor()->trans('configuracion.label.password_nuevo_obligatorio'));
					$resultado['which'] = '#password';
				}
				elseif(!preg_match($pattern, $nuevo_pass)){////si el password nuevo es debil
					$resultado['cod'] = -1;
					$resultado['cont'] = ucfirst(kernel::traductor()->trans('configuracion.label.password_nuevo_debil'));
					$resultado['which'] = '#password';
				}
				else{//si todo bien
					$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
					persona::reset_password($nro_inscripcion, $nuevo_pass);
					$resultado['cod'] = 1;
					$resultado['cont'] = ucfirst(kernel::traductor()->trans('censo.guardado'));
				}
		}
		else{//si el password actual es invalido
			$resultado['cod'] = -1;
			$resultado['cont'] = ucfirst(kernel::traductor()->trans('el password actual es incorrecto'));
			$resultado['which'] = '#password_actual';
		}
		
		return $resultado;
    }
	
	static function controlar_password($password)
	{
		$error = new error_guarani_procesar_renglones('Contraseña invalida');
		$error_nro_linea = 0;
		
		// control de longitud
		$parametro = catalogo::consultar('sistema','parametro',
										array('parametro'=>'clave_longitud_minima'));
		$longitud_minima = $parametro[0];
		$longitud = strlen($password);
		
		if ($longitud < $longitud_minima){
			$error->add_renglon($error_nro_linea, kernel::traductor()->trans("clave_longitud_minima", array('%1%' => $longitud_minima)));
			$error_nro_linea++;
		}
		
		// control de clave numerica
//		catalogo::consultar('parametro','clave_solo_numeros');
//		$parametro = catalogo::consultar('sistema','parametro',
//										array('parametro'=>'clave_solo_numeros'));
//		$clave_solo_numeros = $parametro[0];
//		
//		if ($clave_solo_numeros == "S" && !is_numeric($password)){
//			$error->add_renglon($error_nro_linea, kernel::traductor()->trans("clave_solo_numeros"));
//			$error_nro_linea++;
//		} else if ($clave_solo_numeros == "N" && is_numeric($password)){
//			$error->add_renglon($error_nro_linea, kernel::traductor()->trans("clave_sin_letras"));
//			$error_nro_linea++;
//		}
		
		if($error->hay_renglones()) {
			throw $error;
		}
	}
}
?>
