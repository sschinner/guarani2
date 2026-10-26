<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_37 extends \siu\modelo\controles\punto_control
{
	 function utiliza_unidad_academica()
	{
		return true;
	}

	 function lista_parametros()
	{
		return array (
  0 => 'unidad_academica',
  1 => 'carrera',
  2 => 'legajo',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '37',
  'NOMBRE' => 'Alumno - Egresado',
  'DESCRIPCION' => 'Controles sobre el alumno egresado',
  'PARAMETROS' => 'S,S,S',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '37',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '37',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '37',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
);
	}

}

?>