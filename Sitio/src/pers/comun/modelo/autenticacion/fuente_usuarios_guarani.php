<?php

namespace comun\modelo\autenticacion;

use kernel\util\bcrypt;
use siu\errores\error_guarani_login;

class fuente_usuarios_guarani extends \siu\modelo\autenticacion\fuente_usuarios_guarani {

    public function autenticar_ldap($parametros_conexion, $id, $clave)
    {
        // para auditoria
        $this->identificacion = $id;

        $datos = $this->get_datos_login_ldap($parametros_conexion, $id);

	    if (empty($datos)) {
            $this->throw_error_guarani(error_guarani_login::id_inexistente);
        }

	    $enc = new bcrypt(10);
        $login_ok = ($enc->verify(md5($clave), $datos[1]));
        if ($login_ok===false) {
            $this->throw_error_guarani(error_guarani_login::clave_invalida);
        }

        return $this->validar_persona_logueada($datos[0]);
    }

    /**
     * @param $parametros_conexion
     * @param $id
     * @return array con dos componentes: nro_inscripcion y clave. Si no existe la persona con id $id debe devolver un array vacío
     */
    private function get_datos_login_ldap($parametros_conexion, $id)
    {
        // conectar ldap usando $parametros_conexion, son los que se definen en config/login.php
        // se necesitan recuperar 2 datos de LDAP: nro_inscripcion, clave.


	    //////////////////////
//	    $existe_persona = consultar en ldap
//	    $nro_inscripcion = XX;
//	    $clave = XX;
        /////////////////////////////
	    if ($existe_persona) {
            $rs = array($nro_inscripcion, $clave);
        } else {
            $rs = array();
        }

        return $rs;
    }
} 