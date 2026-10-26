<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_19 extends \siu\modelo\controles\punto_control
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
  3 => 'comision',
  4 => 'materia',
  5 => 'fecha_regularidad',
  6 => 'cond_regularidad',
  7 => 'resultado',
  8 => 'nota',
  9 => 'asistencia',
  10 => 'plan',
  11 => 'version',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '19',
  'NOMBRE' => 'Registrar el resultado de una promoción',
  'DESCRIPCION' => 'Registrar el resultado de una promoción',
  'PARAMETROS' => 'S,S,S,N,S,S,N,S,S,N,S,S',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '4',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'comision',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '5',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '6',
    'PARAMETRO' => 'd ',
    'TIPO' => 'date',
    'NOMBRE' => 'fecha_regularidad',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '7',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'cond_regularidad',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  7 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '8',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'resultado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  8 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '9',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nota',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  9 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '10',
    'PARAMETRO' => 'n ',
    'TIPO' => 'decimal',
    'NOMBRE' => 'asistencia',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  10 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '11',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'plan',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  11 => 
  array (
    'PUNTO_DE_CONTROL' => '19',
    'ORDEN' => '12',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'version',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
);
	}

}

?>