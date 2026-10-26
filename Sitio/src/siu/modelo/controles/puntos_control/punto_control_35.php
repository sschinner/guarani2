<?php
namespace siu\modelo\controles\puntos_control;

class punto_control_35 extends \siu\modelo\controles\punto_control
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
  'PUNTO_DE_CONTROL' => '35',
  'NOMBRE' => 'Alumno - Materia (Reválidas)',
  'DESCRIPCION' => 'Verificar el vencimiento de la regularidad de un alumno en una fecha determinada',
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