<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_13 extends \siu\modelo\controles\punto_control
{
	 function utiliza_unidad_academica()
	{
		return true;
	}

	 function lista_parametros()
	{
		return array (
  0 => 'unidad_academica',
  1 => 'nro_inscripcion',
  2 => 'clave_anterior',
  3 => 'clave_nueva',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '13',
  'NOMBRE' => 'Grabación Cambio de Clave',
  'DESCRIPCION' => 'Un usuario de AutoGestión cambia su clave',
  'PARAMETROS' => 's,s,s,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '13',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '13',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nro_inscripcion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '10',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '13',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'clave_anterior',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '20',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '13',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'clave_nueva',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '20',
  ),
);
	}

}

?>