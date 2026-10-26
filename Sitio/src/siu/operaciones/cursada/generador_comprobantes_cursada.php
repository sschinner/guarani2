<?php
namespace siu\operaciones\cursada;
use siu\operaciones\_comun\comprobantes\generador_comprobantes;
use siu\errores\error_guarani;
use kernel\kernel;
use siu\guarani;
/**
 * Description of generador_comprobantes_cursada
 *
 * @author andres
 */
class generador_comprobantes_cursada {
	const TIPO_BAJA = 'baja';
	const TIPO_ALTA = 'alta';

	const TIPO_GENERACION_ARCHIVO = 'archivo';
	const TIPO_GENERACION_DESCARGA  = 'descarga';
	const TIPO_GENERACION_STREAM = 'stream';

	protected $tipo_generacion;
	protected $nombre_archivo;
	protected $path_destino;
	protected $opciones;
	protected $generador;

	function __construct()
	{
		$this->generador =	new generador_comprobantes($this->get_ancho(), $this->get_alto(), $this->get_opciones());
		$logo = $this->get_logo();
		$this->generador->agregar_imagen($logo, 5, 5);
		$this->generador->agregar_linea(10, 80, 410, 80, '');
	}

	protected function get_opciones()
	{
		$font = guarani::dir_fonts() . '/Ubuntu-R.ttf';
		$font_bold = guarani::dir_fonts() . '/Ubuntu-B.ttf';
		return array(
			'tamano_fuente' => 10,
			'tamano_fuente_titulo' => 14,
			'tamano_fuente_subtitulo' => 12,
			'interlineado' => 10,
			'font' => $font,
			'fontBold' => $font_bold,
			'margen' => 10,
			'set_offset_cuerpo' => 110
		);
	}

	protected function get_ancho()
	{
		return 420;
	}
	
	protected function get_alto()
	{
		return 510;
	}
	
	protected function get_logo()
	{
		return kernel::localizador()->path_recurso('/www/img/logo.png');
	}
	
	function set_tipo_generacion($tipo_generacion) 
	{
		$this->tipo_generacion = $tipo_generacion;
	}
	
	function set_path_destino($path)
	{
		$this->path_destino = $path;
	}
	
	protected function get_nombre_archivo_alta($datos)
	{
		return "Comprobante alta - {$datos['MATERIA']}.png";
	}
	
	protected function get_nombre_archivo_baja($datos)
	{
		return "Comprobante baja - {$datos['MATERIA']}.png";
	}
	
	function generar_comp_alta($datos)
	{
		$tabla = array (
			'nombre_carrera' => '('.$datos['CARRERA'].') '.$datos['NOMBRE_CARRERA'],
			'nombre_alumno' => $datos['NOMBRE_ALUMNO'],
			'legajo' => $datos['LEGAJO'],
			'plan' => $datos['PLAN'],
			'nombre_materia' => "(".$datos['MATERIA'].") ".$datos['NOMBRE_RED_MATERIA'],
			'nombre_comision' => $datos['NOMBRE_COMISION'],
			'anio_academico' => $datos['ANIO_ACADEMICO'],
			'periodo_lectivo' => $datos['PERIODO_LECTIVO'],
			'turno_cursada' => $datos['TURNO_CURSADA'] ? $datos['TURNO_CURSADA']: kernel::traductor()->trans("sin_definir"),
			'fecha_inscripcion' => $datos['FECHA_INSCRIPCION'],
			'calidad' => $datos['CALIDAD'],
			'estado_inscripcion' => $datos['ESTADO_INSCRIPCION'],
			'nombre_sede' => $datos['NOMBRE_SEDE'],
			'catedra' => $datos['CATEDRA'] ? $datos['CATEDRA']: kernel::traductor()->trans("sin_definir"),
			'nro_transaccion' => $datos['NRO_TRANSACCION'],
			'importante' => kernel::traductor()->trans("comprobante_aviso")
		);

		$subtitulo = kernel::traductor()->trans("comprobante_inscripcion_cursada_alta");
		$this->generador->agregar_subtitulo($subtitulo, "i");
		$this->generador->agregar_tabla($tabla);
		$this->nombre_archivo = $this->get_nombre_archivo_alta($datos);
		$this->output($this->generador->generar());
	}
	
	function generar_comp_baja($datos)
	{
		$tabla = array (
			'nombre_carrera' => '('.$datos['CARRERA'].') '.$datos['NOMBRE_CARRERA'],
			'nombre_alumno' => $datos['NOMBRE_ALUMNO'],
			'legajo' => $datos['LEGAJO'],
			'plan' => $datos['PLAN'],
			'materia' => "(".$datos['MATERIA'].") ".$datos['NOMBRE_RED_MATERIA'],
			'nombre_comision' => "(".$datos['COMISION'].") ".$datos['NOMBRE_COMISION'],
			'anio_academico' => $datos['ANIO_ACADEMICO'],
			'periodo_lectivo' => $datos['PERIODO_LECTIVO'],
			'turno_cursada' => $datos['TURNO_CURSADA'],
			'fecha_inscripcion' => $datos['FECHA_INSCRIPCION'],
			'calidad' => $datos['CALIDAD'],
			'nombre_sede' => $datos['NOMBRE_SEDE'],
			'catedra' => $datos['CATEDRA'],
			'nro_transaccion' => $datos['NRO_TRANS_BAJA'],
			'importante' => kernel::traductor()->trans("comprobante_aviso")
		);
		$subtitulo = kernel::traductor()->trans("comprobante_inscripcion_cursada_baja");
		$this->generador->agregar_subtitulo($subtitulo, "i");
		$this->generador->agregar_tabla($tabla);
		$this->nombre_archivo = $this->get_nombre_archivo_baja($datos);
		$this->output($this->generador->generar());
	}

	protected function output($imagen)
	{
		switch ($this->tipo_generacion) {
			case self::TIPO_GENERACION_DESCARGA:
				header("Content-Type: image/png");
				header("Content-Disposition: attachment; filename=\"$this->nombre_archivo\"");
				imagepng($imagen);
				break;
			case self::TIPO_GENERACION_STREAM:
				header("Content-Type: image/png");
				imagepng($imagen);
				break;
			case self::TIPO_GENERACION_ARCHIVO:
				if (! isset($this->path_destino)) {
					throw new error_guarani("para guardar el comprobante debe setear el path_destino con set_path_destino");
				}
				imagepng($imagen, $this->path_destino);
				break;
		}
	}
}
?>