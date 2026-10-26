<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_29 extends \siu\modelo\controles\punto_control
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
  2 => 'periodo_inscripcion',
  3 => 'carrera',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '29',
  'NOMBRE' => 'Persona - Matriculación',
  'DESCRIPCION' => 'Registrar la Matriculación de una Persona a una Carrera.',
  'PARAMETROS' => 's,s,s,s',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '29',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '29',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nro_inscripcion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '10',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '29',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'periodo_inscripcion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '20',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '29',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
);
	}

}

?>