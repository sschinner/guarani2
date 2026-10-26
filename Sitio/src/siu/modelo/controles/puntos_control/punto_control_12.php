<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_12 extends \siu\modelo\controles\punto_control
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
  4 => 'anio_academico',
  5 => 'turno_examen',
  6 => 'mesa_examen',
  7 => 'llamado',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '12',
  'NOMBRE' => 'Anulación de una inscripción a examen',
  'DESCRIPCION' => 'Anulación de una inscripción a examen',
  'PARAMETROS' => 'S,S,S,S,S,N,N,S',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '1',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '2',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '3',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '4',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '5',
    'PARAMETRO' => 'N ',
    'TIPO' => 'integer',
    'NOMBRE' => 'anio_academico',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '6',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'turno_examen',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '20',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '7',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'mesa_examen',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  7 => 
  array (
    'PUNTO_DE_CONTROL' => '12',
    'ORDEN' => '8',
    'PARAMETRO' => 'N ',
    'TIPO' => 'integer',
    'NOMBRE' => 'llamado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
);
	}

}

?>