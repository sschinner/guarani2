<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_8 extends \siu\modelo\controles\punto_control
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
  3 => 'materia',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '8',
  'NOMBRE' => 'Alumno - Materia (Exámenes)',
  'DESCRIPCION' => 'Un Alumno elige una materia para inscribirse para cursarla',
  'PARAMETROS' => 's,s,s,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '8',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '8',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '8',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '8',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
);
	}

}

?>