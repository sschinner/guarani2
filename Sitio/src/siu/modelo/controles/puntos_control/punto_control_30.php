<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_30 extends \siu\modelo\controles\punto_control
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
  3 => 'plan',
  4 => 'version',
  5 => 'titulo',
  6 => 'orientacion',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '30',
  'NOMBRE' => 'Alumno - Elige Orientación',
  'DESCRIPCION' => 'Registrar la eleccion de una Orientación por un Alumno',
  'PARAMETROS' => 's,s,s,s,s,s,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'plan',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '5',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'version',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '6',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'titulo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '30',
    'ORDEN' => '7',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'orientacion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
);
	}

}

?>