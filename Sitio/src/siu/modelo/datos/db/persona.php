<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use kernel\error_kernel_db;
use siu\modelo\datos\catalogo;

class persona
{

	/**
	 * parametros: _ua, id
	 * cache: no
	 * filas: 1
	 */
	function buscar_clave($parametros)
	{
		$sql = "SELECT	clave, 
						nro_inscripcion
                FROM	aca_usuarios_ag 
                WHERE	aca_usuarios_ag.unidad_academica	= {$parametros['_ua']}
				AND		aca_usuarios_ag.identificacion		= {$parametros['id']} ";
				
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}

	/**
	 * parametros: _ua, id
	 * cache: no
	 * filas: 1
	 */
	function saml_buscar_por_id($parametros)
	{
		$rs = $this->buscar_clave($parametros);
		if(!empty($rs)) return array($rs[0][1]);
		return array();
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: 1
	 */
	function saml_buscar_por_nro_inscripcion($parametros)
	{
		$sql = "SELECT	nro_inscripcion
                FROM	aca_usuarios_ag
                WHERE	aca_usuarios_ag.unidad_academica	= {$parametros['_ua']}
				AND		aca_usuarios_ag.nro_inscripcion		= {$parametros['nro_inscripcion']} ";

		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
	}


	/**
	 * parametros:  _ua, id, nro_inscripcion, status, mensaje, interfaz, origen_login, registrar, ip
	 * no_quote: registrar
	 * param_null: nro_inscripcion
	 * cache: no
	 * filas: 1
	 */
	function insertar_registro_logueo($parametros)
	{
		$datos = array();
		if  ($parametros['registrar'] == 'S') {
			$sql = "INSERT INTO
						aud_log_ingresos (
							unidad_academica,
						    nro_inscripcion,
						    identificacion,
						    codigo_retorno,
						    mensaje_retorno,
						    origen_login,
						    interfaz,
							ip
						)
					VALUES (
							{$parametros['_ua']},
							{$parametros['nro_inscripcion']},
							{$parametros['id']},
							{$parametros['status']},
							{$parametros['mensaje']},
							{$parametros['origen_login']},
							{$parametros['interfaz']},
							{$parametros['ip']}
					)";
			$datos = kernel::db()->ejecutar($sql);
			
			if($datos==1 and $parametros['status']==0)
			{
				$sql = "SELECT	max(log_ingreso) as log_ingreso 
						FROM	aud_log_ingresos
						WHERE	unidad_academica	=	{$parametros['_ua']}
						AND		nro_inscripcion		=	{$parametros['nro_inscripcion']}
						AND		identificacion		=	{$parametros['id']}";
				$dato_aud = kernel::db()->consultar_fila($sql);
				kernel::sesion()->set('log_ingreso', $dato_aud['LOG_INGRESO']);
			}
			
		}
		return $datos;
	}

	/**
	 * parametros:  log_ingreso
	 * cache: no
	 * filas: 1
	 */
	function registrar_logout($parametros)
	{
		$sql = "UPDATE aud_log_ingresos
				SET fecha_hora_logout = CURRENT
				WHERE log_ingreso = {$parametros['log_ingreso']}";
		$datos = kernel::db()->ejecutar($sql);
		return $datos;
	}
	
	/**
	 * parametros: _ua, proveedor, id, mail
	 * cache: no
	 * 
	 * filas: 1
	 */
	function login_externo($parametros)
	{
		$sql = "SELECT nro_inscripcion
				FROM acc_login_externos
				WHERE proveedor =  {$parametros['proveedor']}
				 AND id_externo = {$parametros['id']}
				 AND unidad_academica = {$parametros['_ua']}";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;

	}	
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function get_login_externos($parametros)
	{
		$sql = "
			SELECT	proveedor, id_externo, descripcion
			FROM	acc_login_externos
			WHERE	nro_inscripcion = {$parametros['nro_inscripcion']}
			AND unidad_academica = {$parametros['_ua']}";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$assoc = array();
		foreach ($datos as $d) {
			$assoc[] = array('proveedor' => $d[0], 'id_externo' => $d[1], 'descripcion'=> $d[2]);
		}

		return $assoc;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, id, mail, proveedor
	 * cache: no
	 * filas: 1
	 */
	function vincular_login_externo($parametros)
	{
		 $sql = "SELECT proveedor, nro_inscripcion
		        FROM acc_login_externos
				WHERE proveedor =  {$parametros['proveedor']}
				AND nro_inscripcion = {$parametros['nro_inscripcion']}
				AND unidad_academica = {$parametros['_ua']}"
		 ;
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		if(isset($datos[0])){
			$sql =	"UPDATE acc_login_externos
					   SET  id_externo={$parametros['id']}
					       ,descripcion={$parametros['mail']}
					 WHERE proveedor =  {$parametros['proveedor']}
					    AND nro_inscripcion = {$parametros['nro_inscripcion']}
						AND unidad_academica = {$parametros['_ua']}
					";
		}else{

			$sql =	"INSERT INTO acc_login_externos(
					id_externo,
					proveedor,
					nro_inscripcion,
					unidad_academica
					, descripcion
					)
	                VALUES ({$parametros['id']}, {$parametros['proveedor']},{$parametros['nro_inscripcion']}, {$parametros['_ua']}, {$parametros['mail']})";

		}
		return $datos = kernel::db()->ejecutar($sql) > 0;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, proveedor
	 * cache: no
	 * filas: 1
	 */
	function desvincular_login_externo($parametros)
	{
		$sql = "DELETE FROM acc_login_externos
						WHERE nro_inscripcion   = {$parametros['nro_inscripcion']}
						  AND unidad_academica = {$parametros['_ua']}
						  AND proveedor = {$parametros['proveedor']}
						";
		$datos = kernel::db()->ejecutar($sql);
		return $datos > 0;
	}
	
	/**
	 * parametros: _ua, id
	 * cache: no
	 * filas: 1
	 */
	function login_usuario_nro_inscripcion($parametros)
	{
		$sql = "SELECT nro_inscripcion FROM aca_usuarios_ag 
				WHERE unidad_academica = {$parametros['_ua']} 
				AND identificacion = {$parametros['id']}";
		$datos = kernel::db()->consultar_fila($sql);
		return $datos;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: sesion
	 * filas: 1
	 */
	function datos_basicos($parametros)
	{
		$sql = "SELECT
                    p.unidad_academica,
					p.nro_inscripcion,
					DECODE(p.tipo_documento, 0, 'DNI', 2, 'CI', 18, 'LE', 19, 'LC', 90, 'Pas', 'DNI'),
					p.nro_documento,
					p.apellido,
					p.nombres,
					u.tipo_usuar_inicial as perfil_inicial,
					u.identificacion as identificacion,
					d.legajo as legajo_docente,
					CASE
					   WHEN ger.tipo_usuario IS NOT NULL THEN 'S'
					   ELSE 'N'
					END as es_usuario_gerencial,
					p.sexo,
					td.descripcion as tipo_documento_descripcion,
					td.desc_abreviada as tipo_documento_desc_abreviada,
					p.nacionalidad,
					nac.descripcion as nacionalidad_descripcion,
					p.id_imagen as id_imagen
				FROM
					sga_personas as p,
					aca_usuarios_ag as u,
					OUTER sga_docentes as d,
					OUTER aca_tipos_usuar_ag as ger,
					OUTER mdp_tipo_documento as td,
					OUTER mdp_nacionalidades as nac
				WHERE p.nro_inscripcion = {$parametros['nro_inscripcion']}
				AND p.unidad_academica = {$parametros['_ua']}
				AND p.nro_inscripcion = u.nro_inscripcion 
				AND p.unidad_academica = u.unidad_academica
				AND d.unidad_academica = u.unidad_academica  
				AND d.nro_inscripcion = u.nro_inscripcion
				AND ger.unidad_academica = u.unidad_academica  
				AND ger.nro_inscripcion = u.nro_inscripcion 
				AND ger.tipo_usuario = 'GER'
				AND td.tipo_documento = p.tipo_documento
				AND nac.nacionalidad = p.nacionalidad
				";

		$datos = kernel::db()->consultar_fila($sql);
		return $datos;		
	}


	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: sesion
	 * filas: n
	 */
	function perfiles($parametros)
	{
		$sql = "SELECT tipo_usuario FROM aca_tipos_usuar_ag
				WHERE nro_inscripcion = {$parametros['nro_inscripcion']}
				AND unidad_academica = {$parametros['_ua']}";
		$datos = kernel::db()->consultar($sql);
		$perfiles = array();
		foreach($datos as $dato) {
			$perfiles[] = $dato['TIPO_USUARIO'];
		}
		return $perfiles;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: sesion
	 * filas: n
	 */
	function get_estado_perfil($parametros)
	{
		$sql = "SELECT tipo_usuario, estado FROM aca_tipos_usuar_ag
				WHERE nro_inscripcion = {$parametros['nro_inscripcion']}
				AND unidad_academica = {$parametros['_ua']}";
		$datos = kernel::db()->consultar($sql);
		$perfiles = array();
		foreach($datos as $dato) {
			$perfil = array('tipo_usuario' => $dato['TIPO_USUARIO'],'estado' => $dato['ESTADO']);
			//$perfiles = array_merge($perfiles, $perfil);
			$perfiles[] = $perfil;
		}
		return $perfiles;
	}
	
	
	/**
	 * parametros: _ua, nro_inscripcion, filtra_carrera_vocacional, filtra_carrera_curso_ingreso
	 * cache: sesion
	 * no_quote: filtra_carrera_vocacional, filtra_carrera_curso_ingreso
	 * filas: n
	 */
	function carreras($parametros)
	{
		$sql = "
			SELECT sga_alumnos.unidad_academica,
				sga_alumnos.carrera,
				sga_alumnos.legajo,
				sga_alumnos.plan,
				sga_planes.version_actual as version,
				sga_alumnos.regular,
				DECODE(sga_alumnos.regular, 'S', 'Regular', 'N', 'No Regular','') as regular_nombre,
				sga_alumnos.calidad,
				sga_planes.version_actual as version,
				DECODE(sga_alumnos.calidad, 'A', 'Alumno Activo', 'P', 'Alumno Pasivo', 'N', 'Abandonó', 'E', 'Egresado','') as calidad_nombre,
				sga_carreras.tipo_de_carrera,
				sga_carreras.nombre,
				sga_carreras.nombre_reducido,
				sga_carrera_aspira.periodo_inscripcio as periodo_inscripcio,
				sga_periodo_insc.anio_academico as anio_academico,
				sga_carrera_aspira.situacion_asp as situacion_asp,
				sga_situacion_asp.resultado_asp as resultado_asp
			FROM sga_alumnos,
				 sga_carreras,
				 sga_planes,
				 sga_carrera_aspira,
				 sga_situacion_asp,
				 sga_periodo_insc				
			WHERE sga_alumnos.unidad_academica = {$parametros['_ua']}
			AND sga_alumnos.nro_inscripcion  = {$parametros['nro_inscripcion']}
			--AND sga_alumnos.calidad = 'A'  -- Por ahora solo alumnos activos
			AND sga_alumnos.calidad IN ('A', 'P', 'E')
			AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
			AND sga_carreras.carrera		= sga_alumnos.carrera
			AND sga_planes.unidad_academica = sga_alumnos.unidad_academica
			AND sga_planes.carrera	= sga_alumnos.carrera
			AND sga_planes.plan	= sga_alumnos.plan
			AND sga_carrera_aspira.unidad_academica = sga_alumnos.unidad_academica
			AND sga_carrera_aspira.carrera = sga_alumnos.carrera
			AND sga_carrera_aspira.nro_inscripcion = sga_alumnos.nro_inscripcion
			AND sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
			AND sga_situacion_asp.resultado_asp IN ('A','I') 
			AND sga_periodo_insc.periodo_inscripcio = sga_carrera_aspira.periodo_inscripcio
		";

		if ($parametros['filtra_carrera_vocacional'] == "S"){
			//  -- E = extracurricular, V = vocacional
			$sql .= " AND sga_carreras.tipo_de_carrera NOT IN ('E','V')";
		}
		if ($parametros['filtra_carrera_curso_ingreso'] == "S"){
		    // I = Curso de ingreso	 
			$sql .= " AND sga_carreras.tipo_de_carrera <> 'I'"; 
		}
		$datos = kernel::db()->consultar($sql);

        $nuevo = array();
        foreach($datos as $key => $carrera){
            $nuevo[$key] = $carrera;
            $nuevo[$key][catalogo::id] = catalogo::generar_id($carrera['CARRERA']);
        }
		return $nuevo;
	}

	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: n
	 */
	function configuracion($parametros)
	{
		$sql = "EXECUTE PROCEDURE sp_r_conf_anun_per({$parametros['_ua']},{$parametros['nro_inscripcion']})";
		$datos = kernel::db()->consultar($sql,db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $key => $dato) {
			$nuevo[$key]['E_MAIL']				= $dato[0];
			$nuevo[$key]['RECIBE_MAIL']			= $dato[2];
		}
		return $nuevo[0];
	}

	/**
	 * parametros: _ua, nro_inscripcion, recibe_mail, mail
	 * cache: no
	 * param_null: mail
	 * filas: n
	 */
  function actualizar_configuracion($parametros)
	{
		$sql =  "UPDATE gda_anun_conf_pers 
				SET RECIBE_MAIL = {$parametros['recibe_mail']}";
		if (!empty($parametros['mail'])){
			$sql .= ", E_MAIL = {$parametros['mail']}";
		}
		$sql .= " WHERE NRO_INSCRIPCION = {$parametros['nro_inscripcion']} AND UNIDAD_ACADEMICA = {$parametros['_ua']}";
		kernel::db()->abrir_transaccion();
		$datos = kernel::db()->ejecutar($sql);

//   *** Agregar la actualizacion del mail en datos censales si no fallo el update anterior con:
		if (!empty($parametros['mail'])){
			$sql = "EXECUTE PROCEDURE sp_u_email({$parametros['_ua']}, {$parametros['nro_inscripcion']}, {$parametros['mail']})";
		    $datos_mail = kernel::db()->ejecutar($sql);
		}
		//return $datos;
		kernel::db()->cerrar_transaccion();

	}
	
	/**
	 * parametros: _ua, usuario, actual_pass, nuevo_pass
	 * cache: no
	 * filas: 1
	 */
	function actualizar_password($parametros)
	{
		$sql = "execute procedure sp_cambiarClaveAG({$parametros["_ua"]}, {$parametros["usuario"]}, {$parametros["actual_pass"]}, {$parametros["nuevo_pass"]},3)";
		$respuesta = kernel::db()->consultar_fila($sql,db::FETCH_NUM);
		return $respuesta;
	}

	/**
	 * parametros: _ua, pais, tipo_doc, doc
	 * cache: no
	 * filas: 1
	 */
	function data_recuperar_pass($parametros)
	{
		$sql = "execute procedure sp_r_email({$parametros["_ua"]}, {$parametros["pais"]}, {$parametros["tipo_doc"]}, {$parametros["doc"]})";
		$respuesta = kernel::db()->consultar_fila($sql,db::FETCH_NUM);

		return $respuesta;
	}
	
	/**
	 * parametros: _ua, nro_inscripcion, token
	 * cache: no
	 * filas: 1
	 */
	function update_token($parametros)
	{
		$sql = "execute procedure sp_u_tokenusuarios({$parametros["_ua"]}, {$parametros["nro_inscripcion"]}, {$parametros["token"]}, {$parametros["email"]})";
		kernel::db()->ejecutar($sql,db::FETCH_NUM);
	}
	
	/**
	 * parametros: token
	 * cache: no
	 * filas: 1
	 */
	function buscar_por_token($parametros)
	{
		$sql = "SELECT nro_inscripcion FROM aca_usuarios_token WHERE token={$parametros["token"]}";
		$respuesta = kernel::db()->consultar_fila($sql,db::FETCH_NUM);
		
		return $respuesta[0];
	}

	/**
	 * parametros: token
	 * cache: no
	 * filas: 1
	 */
	function buscar_mail_token($parametros)
	{
		$where = array();
		if(isset($parametros['token']) && $parametros['token'] && $parametros['token']!="''") {
			$where[] = "token={$parametros["token"]}";
		}
		if(isset($parametros['nro_inscripcion']) && $parametros['nro_inscripcion'] && $parametros['nro_inscripcion']!="''") {
			$where[] = "nro_inscripcion={$parametros["nro_inscripcion"]}";
		}
		$sql = "SELECT email_nuevo FROM aca_usuarios_token WHERE ".implode(' and ', $where);
		$respuesta = kernel::db()->consultar_fila($sql,db::FETCH_NUM);
		
		return isset($respuesta[0])?$respuesta[0]:null;
	}
	
	/**
	 * parametros: token, nro_inscripcion
	 * param_null: token, nro_inscripcion
	 * cache: no
	 * filas: 1
	 */
	function eliminar_token($parametros)
	{
                                    $sql = "delete from aca_usuarios_token where token ={$parametros["token"]} or nro_inscripcion ={$parametros["nro_inscripcion"]}";
                                    kernel::db()->ejecutar($sql);
	}
	/**
	 * parametros: _ua, nro_inscripcion, password
	 * cache: no
	 * filas: 1
	 */
	function reset_password($parametros)
	{
		$sql = "
			UPDATE aca_usuarios_ag SET
				clave = {$parametros["password"]}, 
				intentos_fallidos = 0,
				fec_ult_actualiz  = current year to second 
			WHERE	unidad_academica = {$parametros["_ua"]} 
			AND		nro_inscripcion  = {$parametros["nro_inscripcion"]}";
		kernel::db()->ejecutar($sql);
	}

	/**
	 * parametros: ua, nro_inscripcion, id_imagen
	 * cache: no
	 * filas: 1
	 */
	function asociar_foto($parametros)
	{
		try {
			kernel::db()->abrir_transaccion();
			$sql_sinc = "
				UPDATE sga_personas_foto SET 
					sincronizada = 1
				WHERE unidad_academica = {$parametros["ua"]} 
				AND nro_inscripcion = {$parametros["nro_inscripcion"]}";

			$sql_img = "
				UPDATE sga_personas SET
					id_imagen = {$parametros["id_imagen"]} 
				WHERE	unidad_academica = {$parametros["ua"]} 
				AND		nro_inscripcion  = {$parametros["nro_inscripcion"]}";						
			
			kernel::db()->ejecutar($sql_sinc);
			kernel::db()->ejecutar($sql_img);
			kernel::db()->cerrar_transaccion();
		} catch (error_kernel_db $e) {
			$msj = "Error asociando la foto al nro_inscripcion '{$parametros["nro_inscripcion"]}' ";
			kernel::db()->abortar_transaccion($msj);
		}
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: no
	 * filas: 1
	 */
	function get_dir_mail($parametros)
	{
		$sql = "
			SELECT	e_mail
			FROM	gda_anun_conf_pers
			WHERE	unidad_academica = {$parametros["_ua"]} 
			AND		nro_inscripcion  = {$parametros["nro_inscripcion"]}
			AND		recibe_mail = 'S'";
		$datos = kernel::db()->consultar_fila($sql,db::FETCH_NUM);
		return $datos[0];
	}
	
	/**
	 * parametros: _ua, nro_inscripcion
	 * cache: memoria
	 * filas: 1
	 */
	function get_imagen_persona($parametros)
	{
		$sql = "SELECT id_imagen 
				FROM sga_personas
				WHERE	unidad_academica = {$parametros["_ua"]} 
				AND		nro_inscripcion  = {$parametros["nro_inscripcion"]}";
		$datos = kernel::db()->consultar_fila($sql,db::FETCH_NUM);
		return $datos[0];		
	}	
	
}
?>