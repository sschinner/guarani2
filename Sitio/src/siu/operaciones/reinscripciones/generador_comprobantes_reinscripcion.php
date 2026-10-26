<?php
namespace siu\operaciones\reinscripciones;
use siu\operaciones\_comun\comprobantes\generador_comprobantes;
use siu\errores\error_guarani;
use kernel\kernel;
use siu\guarani;

/**
 * Description of generador_comprobantes_reinscripcion
 *
 */
class generador_comprobantes_reinscripcion {
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
		$encabezado_institucion = array(
									'institucion' => guarani::ua()->get_nombre_institucion(),
									'ua' => guarani::ua()->get_nombre()
								 );
		$this->generador->set_institucion_enzabezado($encabezado_institucion);
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

    protected function get_nombre_archivo($nombre)
    {
        return "reinscripcion_".$nombre.".png";
    }

    function generar_comprobante($datos)
    {
        $tabla = array(
            'alumno_nombre' => $datos['ALUMNO_NOMBRE'],
            'identificacion' => $datos['ALUMNO_DOCUMENTO'],
            'legajo' => (!empty($datos['LEGAJO'])) ? $datos['LEGAJO'] : '-',
            'carrera_nombre' => $datos['CARRERA_NOMBRE'],
            'plan' => $datos['PLAN'],
            'sede' => $datos['SEDE_NOMBRE'],
            'nro_transaccion' => $datos['NRO_TRANS'],
            'anio_academico' => $datos['ANIO_ACADEMICO'],
            'fecha' => $datos['SFECHA_REINSCRIP'],
            'importante' => kernel::traductor()->trans("comprobante_aviso")
        );
        
        $tabla['nro_transaccion'] = $datos['NRO_TRANS'];
		$subtitulo = kernel::traductor()->trans('comprobante_reinscripcion');
		$this->generador->agregar_subtitulo($subtitulo, "i");
		$this->generador->agregar_tabla($tabla);
		$this->nombre_archivo = $this->get_nombre_archivo($datos['NRO_TRANS']);
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
