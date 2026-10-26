<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_11 extends \siu\modelo\controles\punto_control
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
  8 => 'tipo_inscripcion',
  9 => 'materia_generica',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '11',
  'NOMBRE' => 'Grabación de una inscripción a examen',
  'DESCRIPCION' => 'Grabación de una inscripción a examen',
  'PARAMETROS' => 's,s,s,s,n,s,s,n,s,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '5',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'anio_academico',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '6',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'turno_examen',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '20',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '7',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'mesa_examen',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  7 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '8',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'llamado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  8 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '9',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'tipo_inscripcion',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  9 => 
  array (
    'PUNTO_DE_CONTROL' => '11',
    'ORDEN' => '10',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia_generica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '',
  ),
);
	}

}

?>