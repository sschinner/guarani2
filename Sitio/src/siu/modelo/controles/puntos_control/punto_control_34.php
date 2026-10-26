<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_34 extends \siu\modelo\controles\punto_control
{
	 function utiliza_unidad_academica()
	{
		return false;
	}

	 function lista_parametros()
	{
		return array (
);
	}

	 function info()
	{
		return array (
  'PUNTO_DE_CONTROL' => '34',
  'NOMBRE' => 'Alumno - Fecha',
  'DESCRIPCION' => 'Verificar situación del alumno a una fecha determinada',
  'PARAMETROS' => 's,s,s,s',
);
	}

	 function info_parametros()
	{
		return array (
);
	}

}

?>