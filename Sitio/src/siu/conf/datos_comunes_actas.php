<?php
namespace siu\conf;

use kernel\kernel;

class datos_comunes_actas
{
	static function get_estado_acta($estado)
	{
		if ($estado == 'A' || $estado == 'C' || $estado == 'B' || $estado == 'I' || $estado == 'N'){
			return kernel::traductor()->trans('actas.estado_acta.'.$estado);
		} else {
			return kernel::traductor()->trans($estado);
		}
	}

	static function get_fecha($fecha)
	{
		if ($fecha == 'I' || $fecha == 'N' || $fecha == 'B'){
			return kernel::traductor()->trans('actas.fecha.'.$fecha);
		} else {
			if (!empty($fecha)){
				return date("d/m/Y", strtotime($fecha));
			}
		}
	}

	static function get_resultado($resultado)
	{
		if ($resultado == 'P' || $resultado == 'A' || $resultado == 'R' || $resultado == 'U'){
			return kernel::traductor()->trans('actas.resultado.'.$resultado);
		} else {
			return kernel::traductor()->trans('actas.resultado.');
		}
	}

	static function get_tipo_acta($tipo)
	{
		if ($tipo == 'N'){
			return kernel::traductor()->trans('actas.tipo_acta.'.$tipo);
		} else {
			return kernel::traductor()->trans('actas.tipo_acta.');
		}
	}

	static function get_rol_docente($rol)
	{
		if ($rol == 'P' || $rol == 'V' || $rol == 'S'){
			return kernel::traductor()->trans('actas.rol_docente.'.$rol);
		} else {
			return kernel::traductor()->trans('actas.rol_docente.');
		}
	}

	static function get_condicion($condicion)
	{
		if ($condicion == 'L' || $condicion == 'R' || $condicion == 'T'){
			return kernel::traductor()->trans('actas.condicion.'.$condicion);
		} else {
			return $condicion;
		}
	}
}
?>