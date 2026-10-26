<?php


namespace siu\modelo\entidades;


///////////////////////////////////////////////////////////////////
/////// FUNCIONES EXTRAIDAS DE KOLLA KOLLA::url_encuestas.php //////
///////////////////////////////////////////////////////////////////
class url_encuestas
{
	const param_habilitacion = 'h';
	const param_token = 't';
	const param_op_toba = 'ai=kolla||40000112&tm=1';

	////////////////////PARA LAS URLS/////////////////////////

    /**
     * @param type $password el password provisto en la habilitacion
     * @param type $id_hab el id de la habilitacion
     * @param type $id_form el formulario a responder
     * @param type $cod_externo identificación del encuestado
     * @param type $accion 'ver_respuestas' para ver las respuestas de una encuesta ya respondida
     * @param type $cod_recuperacion si la encuesta es anonima es requerido para recuperarla
     * @param type $hash_validacion si la encuesta es anonima es requerido para recuperarla
     * @return type el token para concatener a la direccion base provista en la habilitacion.
     */
    static function get_token_seguridad($password, $id_hab, $id_form, $cod_externo, $accion=null, $cod_recuperacion=null, $hash_validacion=null)
    {
        $s = "$id_hab|$id_form|$cod_externo";
        if ( isset($accion) ) {
            $s .= "|$accion";
        }
        if ( isset($cod_recuperacion) ) {
            $s .= "|$cod_recuperacion";
        }
        if ( isset($hash_validacion) ) {
            $s .= "|$hash_validacion";
        }
        $t = self::encriptar_kolla($s, $password);
        return urlencode($t);
    }

    static function decodificar_token_seguridad($token, $password)
    {
        $key = $password;
        $t = $token;
        $s = self::desencriptar_kolla($t, $key);

        $datos = explode('|', $s);
        $res = array();
        if (count($datos) < 3) { // Mínimo deben ser estos 3 parámetros
            $res['habilitacion']     = -1;
            $res['formulario']       = -1;
            $res['codigo_externo']   = '';
        } else {
            $res['habilitacion']        = $datos[0];
            $res['formulario']          = $datos[1];
            $res['codigo_externo']      = $datos[2];
            $res['accion']              = isset($datos[3]) ? $datos[3] : null;
            $res['codigo_recuperacion'] = isset($datos[4]) ? $datos[4] : null;
            $res['hash_validacion'] = isset($datos[5]) ? $datos[5] : null;
        }
        return $res;
    }
	////////////////////PARA LAS RESPUESTAS///////////////////////

	static function get_token_callback_js($id_hab, $cui, $item, $password){
		$s = "$id_hab|$item|$cui";
		$t = self::encriptar_kolla($s, $password);
		return utf8_encode($t);

	}

	static function decodificar_token_callback_js($token, $password){
		$token = utf8_decode($token);
		$string = self::desencriptar_kolla($token, $password);
		$datos = explode('|', $string);
		$res = array();
		if (count($datos) != 3) {//hago que no falle nunca
			$res['habilitacion'] = -1;
			$res['formulario'] = -1;
			$res['codigo_externo'] = '';
		} else {
			$res['habilitacion'] = $datos[0];
			$res['formulario'] = $datos[1];
			$res['codigo_externo'] = $datos[2];
		}
		return $res;
	}

	/////////////////////// AUXILIARES //////////////////////

	/**
	 *
	 * @param string $punto_acceso por ejemplo: http:localhost/kolla/3.3/aplicacion.php
	 * @param int $habilitacion id_habilitacion
	 * @param string $token_seguridad los parametros hasheados
	 */
	static function gen_url($punto_acceso, $habilitacion, $token_seguridad){

		$url = $punto_acceso;
		$url .= '?'.self::param_op_toba;
		$url .= '&'.self::param_habilitacion.'='.$habilitacion;
		$url .= '&'.self::param_token.'='.$token_seguridad;
		return $url;
	}



	private static function desencriptar_kolla($encoded, $key)
	{
		$decoded = base64_decode($encoded);
		$decrypted = rtrim(mcrypt_decrypt(MCRYPT_RIJNDAEL_256, md5($key), $decoded, MCRYPT_MODE_CBC, md5(md5($key))),
			"\0");
		//IMPORTANTE!!!! No cambiar "\0" por '\0' ya que no son equivalentes.
		return $decrypted;
	}

	private static function encriptar_kolla($string, $key)
	{
		$encrypted = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, md5($key), $string, MCRYPT_MODE_CBC, md5(md5($key)));
		$encoded = base64_encode($encrypted);
		return $encoded;
	}

}
