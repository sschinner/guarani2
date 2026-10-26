<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_32 extends \siu\modelo\controles\punto_control
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
  4 => 'subcomision',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '32',
  'NOMBRE' => 'Alumno elige Subcomisión',
  'DESCRIPCION' => 'Elección de subcomisión en Inscripción a Cursadas',
  'PARAMETROS' => 's,s,s,n,n',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '32',
    'ORDEN' => '1',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '32',
    'ORDEN' => '2',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '32',
    'ORDEN' => '3',
    'PARAMETRO' => 'S ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '32',
    'ORDEN' => '4',
    'PARAMETRO' => 'N ',
    'TIPO' => 'integer',
    'NOMBRE' => 'comision',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '32',
    'ORDEN' => '5',
    'PARAMETRO' => 'N ',
    'TIPO' => 'integer',
    'NOMBRE' => 'subcomision',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
);
	}

}

?>