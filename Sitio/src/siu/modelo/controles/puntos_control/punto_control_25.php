<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_25 extends \siu\modelo\controles\punto_control
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
  2 => 'certificado',
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '25',
  'NOMBRE' => 'Persona/Certificado',
  'DESCRIPCION' => 'Una Persona solicita un Certificado.',
  'PARAMETROS' => 's,s,n',
);
	}

	 function info_parametros()
	{
		return array (
  0 => 
  array (
    'PUNTO_DE_CONTROL' => '25',
    'ORDEN' => '1',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'unidad_academica',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '5',
  ),
  1 => 
  array (
    'PUNTO_DE_CONTROL' => '25',
    'ORDEN' => '2',
    'PARAMETRO' => 's ',
    'TIPO' => 'varchar',
    'NOMBRE' => 'nro_inscripcion',
    'ORIGEN_PARAM_WEB' => 'Q',
    'LARGO' => '10',
  ),
  2 => 
  array (
    'PUNTO_DE_CONTROL' => '25',
    'ORDEN' => '3',
    'PARAMETRO' => 'n ',
    'TIPO' => 'integer',
    'NOMBRE' => 'certificado',
    'ORIGEN_PARAM_WEB' => 'Q',
  ),
);
	}

}

?>