<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_14 extends \siu\modelo\controles\punto_control
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
  4 => 'fecha',
  5 => 'alcance',
  6 => 'equivalencia',
  7 => 'operacion_equiv',
  8 => 'nota',
  9 => 'resultado',
  10 => 'escala_notas',
  11 => 'vencimiento',
  12 => 'temas_a_rendir',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '14',
  'NOMBRE' => 'Grabar equivalencia',
  'DESCRIPCION' => 'Se registra la asignación de una equivalencia a un alumno, antes de autorizarla',
  'PARAMETROS' => 'S,S,S,S,S,S,N,N,S,S,N,S,S',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '5',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'fecha',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '10',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '6',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'alcance',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '7',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'equivalencia',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  7 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '8',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'operacion_equiv',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  8 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '9',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nota',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  9 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '10',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'resultado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  10 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '11',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'escala_notas',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  11 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '12',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'vencimiento',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '10',
  ),
  12 => 
  array (
    'PUNTO_DE_CONTROL' => '14',
    'ORDEN' => '13',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'temas_a_rendir',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '255',
  ),
);
	}

}

?>