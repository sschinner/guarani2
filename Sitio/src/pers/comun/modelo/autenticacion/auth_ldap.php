<?php
namespace comun\modelo\autenticacion;


use kernel\util\intentos_login;
use siu\modelo\autenticacion\auth_form;

class auth_ldap extends auth_form {

    protected function validar_user_pass($usuario, $password)
    {
        $parametros_conexion = $this->get_parametros();
        $id_persona = $this->get_clase_usuarios()->autenticar_ldap($parametros_conexion, $usuario, $password);
        intentos_login::eliminar($usuario);
        return $id_persona;
    }
}