<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_27 extends \siu\modelo\controles\punto_control
{
	 function utiliza_unidad_academica()
	{
		return false;
	}

	 function lista_parametros()
	{
		return array (
  0 => 'temp_equiv_parcial',
  1 => 'carrera',
  2 => 'legajo',
  3 => 'materia',
  4 => 'fecha',
  5 => 'equiv_parcial',
  6 => 'origen',
  7 => 'nro_resolucion',
  8 => 'operacion_equiv',
  9 => 'escala_notas',
  10 => 'nota',
  11 => 'resultado',
  12 => 'fin_de_vigencia',
  13 => 'temas_pendientes',
  14 => 'estado',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '27',
  'NOMBRE' => 'Grabar Equivalencia Parcial',
  'DESCRIPCION' => 'Grabar una equivalencia parcial otorgada.',
  'PARAMETROS' => 'N,S,S,S,D,N,S,N,N,S,S,S,D,S,S',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '1',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'temp_equiv_parcial',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'carrera',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '3',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'legajo',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  3 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '4',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'materia',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  4 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '5',
    'PARAMETRO' => 'd ',
    'TIPO' => 'datetime',
    'NOMBRE' => 'fecha',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  5 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '6',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'equiv_parcial',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  6 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '7',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'origen',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  7 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '8',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nro_resolucion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '15',
  ),
  8 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '9',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'operacion_equiv',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  9 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '10',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'escala_notas',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  10 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '11',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nota',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  11 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '12',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'resultado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  12 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '13',
    'PARAMETRO' => 'd ',
    'TIPO' => 'datetime',
    'NOMBRE' => 'fin_de_vigencia',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
  13 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '14',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'temas_pendientes',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '255',
  ),
  14 => 
  array (
    'PUNTO_DE_CONTROL' => '27',
    'ORDEN' => '15',
    'PARAMETRO' => 's ',
    'TIPO' => 'char(1)',
    'NOMBRE' => 'estado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
);
	}

}

?>