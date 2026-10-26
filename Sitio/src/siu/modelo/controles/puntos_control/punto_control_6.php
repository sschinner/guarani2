<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_6 extends \siu\modelo\controles\punto_control
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
  4 => 'materia_generica',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '6',
  'NOMBRE' => 'Grabación de una inscripción a cursada',
  'DESCRIPCION' => 'Grabación de una inscripción a cursada',
  'PARAMETROS' => 's,s,s,n,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '6',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '6',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '6',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '6',
    'ORDEN' => '4',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'comision',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '6',
    'ORDEN' => '5',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia_generica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
);
	}

}

?>