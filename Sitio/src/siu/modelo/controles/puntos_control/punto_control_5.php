<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_5 extends \siu\modelo\controles\punto_control
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
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '5',
  'NOMBRE' => 'Alumno - Comisión',
  'DESCRIPCION' => 'Un Alumno elige una comisión de una materia para inscribirse a cursarla',
  'PARAMETROS' => 's,s,s,n',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '5',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '5',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '5',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '5',
    'ORDEN' => '4',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'comision',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
);
	}

}

?>