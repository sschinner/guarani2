<?php
namespace siu\errores;

class error_guarani_login extends error_guarani
{
    const conexion_ok		= 0;
	const clave_invalida	= -1;
	const id_inexistente	= -2;
	const clave_expiro		= -3;
	const codigo_incorrecto = -4;
	//const no_tiene_carreras = -5;
	const no_tiene_perfiles = -6;
	const cuenta_externa_invalida = -7;

	protected $error_code;
	
	function __construct($error_code)
    {
        $this->error_code = $error_code;
    }
    
    function get_mensaje()
    {
		// ver db\ale\v270\Nuevo\sp_login.sql
        switch ($this->error_code) {
			//case self::no_tiene_carreras: return 'login.errores.no_tiene_carreras';
			case self::codigo_incorrecto: return 'login.errores.codigo_incorrecto';
            case self::clave_expiro		: return 'login.errores.clave_expiro';
            case self::id_inexistente	: return 'login.errores.id_inexistente';
            case self::clave_invalida	: return 'login.errores.clave_invalida';
			case self::no_tiene_perfiles: return 'login.errores.no_tiene_perfiles';				
			case self::cuenta_externa_invalida: return 'login.errores.cuenta_externa_invalida';
        }
    }
    
    function clave_expiro()
    {
        return $this->error_code == -3;
    }
}

?>
