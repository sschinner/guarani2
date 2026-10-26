<?php
namespace siu\operaciones\_comun\comprobantes;
use siu\conf\generador_comprobantes_conf;
use kernel\kernel;

class generador_comprobantes
{
	protected $conf;
	protected $institucion_encabezado ;

	function __construct($ancho, $alto = "", $opciones = array())
	{
		$this->conf = new generador_comprobantes_conf();
		foreach ($opciones as $clave => $valor){
			$this->set_conf($clave, $valor);
		}
		$this->set_conf('ancho', $ancho);
		$this->set_conf('alto', $alto);
	}

	function set_conf($clave, $valor)
	{
		$this->conf->set($clave, $valor);
	}

	function set_institucion_enzabezado($institucion)
	{
		$this->institucion_encabezado = $institucion;
	}

	function agregar_imagen($path, $x, $y)
	{
		$encabezado = $this->conf->get('encabezado');
		$i = count($encabezado);
		$encabezado[$i]['path'] = $path;
		$encabezado[$i]['x'] = $x;
		$encabezado[$i]['y'] = $y;
		$encabezado[$i]['es_resource'] = !is_string($path);
		$this->set_conf('encabezado', $encabezado);
	}

	function agregar_QR($text, $x, $y)
	{
		include(\siu\guarani::dir().'/lib/phpqrcode/qrlib.php');
		$this->agregar_imagen(\QRcode::resource($text), $x, $y);
	}

	function agregar_titulo($texto = "", $alineacion = "c", $padding_izquierda = 0, $padding_derecha = 0)
	{
		$titulo['texto'] = $texto;
		$titulo['x'] = $this->alineacion($alineacion, $texto, $this->conf->get('fontBold'), $this->conf->get('tamano_fuente_titulo'), $padding_izquierda, $padding_derecha);
		$this->set_conf('titulo', $titulo);
	}

	function agregar_subtitulo($texto = "", $alineacion = "c", $padding_izquierda = 0, $padding_derecha = 0)
	{
		$subtitulo['texto'] = $texto;
		$subtitulo['x'] = $this->alineacion($alineacion, $texto, $this->conf->get('fontBold'), $this->conf->get('tamano_fuente_subtitulo'), $padding_izquierda, $padding_derecha);
		$this->set_conf('subtitulo', $subtitulo);
	}

	protected function alineacion($alineacion, $texto, $fuente, $tfuente, $padding_izquierda = 0, $padding_derecha = 0){
		$padding_izquierda = (int)($padding_izquierda);
		$padding_derecha = (int) ($padding_derecha);

		$bbox = imagettfbbox($tfuente, 0, $fuente, $texto);
		switch ($alineacion){
			case "c":
				return  (intval(($this->conf->get('ancho') - $padding_izquierda - $padding_derecha) /2) - intval($bbox[2] /2) + $padding_izquierda);
				break;
			case "d":
				return  $this->conf->get('ancho') - $this->conf->get('margen') - $bbox[2] - $padding_derecha;
				break;
			case "i":
				return  $this->conf->get('margen') + $padding_derecha;
				break;
			default :
				return $this->conf->get('margen')+ $padding_derecha;
		}
	}

	function agregar_tabla($tablas)
	{
		$tabla = $this->conf->get('tabla');
		$i = count($tabla);
		foreach ($tablas as $key => $texto){
			$etiqueta = ucfirst(kernel::traductor()->trans(strtolower($key)));
			$bbox = imagettfbbox($this->conf->get('tamano_fuente'), 0, $this->conf->get('fontBold'), $etiqueta);
			$bbox1 = imagettfbbox($this->conf->get('tamano_fuente'), 0, $this->conf->get('font'), $texto);
			if ($bbox[2] + $this->conf->get('margen') *2  + $bbox1[2] > $this->ancho_viewport()){
				// ancho disponible para el texto
				$ancho = $this->conf->get('ancho') - $this->conf->get('margen') * 2  - $bbox[2];
				$tabla[$i]['texto'] = $this->separar_en_filas($texto, $ancho);
				$tabla[$i]['x'] = $bbox[2] + $this->conf->get('margen') + $this->conf->get('margen');
			}
			else
			{
				$tabla[$i]['texto'] = $texto;
				$tabla[$i]['x'] = $bbox[2] + $this->conf->get('margen') + $this->conf->get('margen');
			}
			$tabla[$i]['etiqueta'] = $etiqueta;
			$i++;
		}
		$this->set_conf('tabla', $tabla);
	}

	protected function ancho_viewport(){
		return $this->conf->get('ancho') - ($this->conf->get('margen') * 2);
	}

	protected function separar_en_filas($texto, $ancho)
	{
		// $ancho = ancho disponible para el texto. solo para la primer linea
		// array imagettfbbox ( float $size , float $angle , string $fontfile , string $text )
		// devuelve un array con las filas
		$atexto = explode(" ", $texto);
		$total_palabras = count($atexto);
		if ($total_palabras > 0){
			$linea = $atexto[0];
			for($i=1; $i < $total_palabras; $i++){
				$bbox = imagettfbbox($this->conf->get('tamano_fuente'), 0, $this->conf->get('font'), $linea ." ".$atexto[$i]);
				if ($bbox[2] > $ancho){
					$atexto_r[] = $linea;
					$linea = $atexto[$i]. " ";
					$ancho = $this->conf->get('ancho');
				}
				else {
					$linea .= $atexto[$i]. " ";
				}
			}
			$atexto_r[] = $linea;
		}
		return $atexto_r;
	}

	function calcular_alto(){
		$alto_total = $this->conf->get('set_offset_cuerpo');

		// TITULO
		$titulo = $this->conf->get('titulo');
		if (!empty($titulo)){
			$alto_total += $this->conf->get('tamano_fuente_titulo') + $this->conf->get('interlineado') + 20;
		}

		// SUBTITULO
		$subtitulo = $this->conf->get('subtitulo');
		if (!empty($subtitulo)){
			$alto_total += $this->conf->get('tamano_fuente_subtitulo') + $this->conf->get('interlineado') + 10;
		}

		// TEXTO
		if (!empty($this->tabla)){
			foreach ($this->tabla as $key => $texto){
				if (is_array($texto['texto'])){
					foreach($texto['texto'] as $key => $value){
						$alto_total += $this->conf->get('tamano_fuente') + $this->conf->get('interlineado');
					}
				}
				else
				{
					$alto_total += $this->conf->get('tamano_fuente') + $this->conf->get('interlineado');
				}
			}
		}

		return $alto_total;
	}

	function dibujarBorde(&$img, &$color, $thickness = 1)
	{
		$x1 = 0;
		$y1 = 0;
		$x2 = ImageSX($img) - 1;
		$y2 = ImageSY($img) - 1;

		for($i = 0; $i < $thickness; $i++)
		{
			ImageRectangle($img, $x1++, $y1++, $x2--, $y2--, $color);
		}
	}

	function agregar_linea($x1, $y1, $x2, $y2, $color)
	{
		$lineas = $this->conf->get('lineas');
		$i = count($lineas);
		$lineas[$i]['x1'] = $x1;
		$lineas[$i]['y1'] = $y1;
		$lineas[$i]['x2'] = $x2;
		$lineas[$i]['y2'] = $y2;
		$lineas[$i]['color'] = $color;
		$this->conf->set('lineas', $lineas);

	}

	function generar()
	{
		$alto = $this->conf->get('alto');

		if (empty($alto)){
			$this->set_conf('alto', $this->calcular_alto());
		}

		$im = imagecreatetruecolor($this->conf->get('ancho'), $this->conf->get('alto'));
		imagealphablending($im, true);
		$background_color = $this->conf->get('background_color');

		$background = imagecolorallocate($im, $background_color[0], $background_color[1], $background_color[2]);
		$fuente_color_defecto = $this->conf->get('fuente_color_defecto');
		$fuente_color = imagecolorallocate($im, $fuente_color_defecto[0], $fuente_color_defecto[1], $fuente_color_defecto[2]);
		$etiqueta_color_defecto = $this->conf->get('etiqueta_color_defecto');
		// ENCABEZADO
		$encabezados = $this->conf->get('encabezado');
		if (!empty($encabezados)){
			foreach($this->conf->get('encabezado') as $encabezado)
			{
				if ($encabezado['es_resource']) {
					$img_header = $encabezado['path'];
				} else {
					$img_header = imagecreatefrompng($encabezado['path']);
				}
				imagealphablending($img_header, true);
				imagefill($img_header, 0, 0, $background);
				imagecopy($im, $img_header, $encabezado['x'], $encabezado['y'], -5, -5, $this->conf->get('ancho'), $this->conf->get('alto'));
			}
		}
		imagefill($im, 0, 0, $background);

		$borde = $this->conf->get('borde');
		if (!empty($borde)){			
			$borde_color = imagecolorallocate($im, $borde['color'][0], $borde['color'][1], $borde['color'][2]);
			$this->dibujarBorde($im, $borde_color, $borde['ancho']);
		}
		
		// Encabezado con nombre de institución y unidad académica
		if (isset($this->institucion_encabezado)){
			$renglones_institucion = $this->separar_en_filas($this->institucion_encabezado['institucion'], ($this->conf->get('ancho') - 10));
			$renglones_ua = $this->separar_en_filas($this->institucion_encabezado['ua'], ($this->conf->get('ancho') - 10));
			$renglones = array_merge($renglones_institucion, $renglones_ua);
			$cant_renglones = sizeof($renglones);
			
			if ($cant_renglones > 2)
			{
				for ($x = 0; $x <= $cant_renglones; $x++){
					imagettftext($im, $this->conf->get('tamano_fuente_encabezado'), 0, ($encabezado['x'] + 195), ($encabezado['y'] + 10) + (15 * $x), $fuente_color, $this->conf->get('fontBold'), $renglones[$x]);
				}
				
			}else {			
				imagettftext($im, $this->conf->get('tamano_fuente_encabezado'), 0, ($encabezado['x'] + 200), $encabezado['y'] + 30, $fuente_color, $this->conf->get('fontBold'), $this->institucion_encabezado['institucion']);
				imagettftext($im, $this->conf->get('tamano_fuente_encabezado'), 0, ($encabezado['x'] + 200), $encabezado['y'] + 50, $fuente_color, $this->conf->get('fontBold'), $this->institucion_encabezado['ua']);
			}

		}

		// LINEAS
		$lineas = $this->conf->get('lineas');
		if (!empty($lineas)){
			foreach($lineas as $linea){
				imageline($im, $linea['x1'] , $linea['y1'] , $linea['x2'] , $linea['y2'], $borde_color );
			}
		}

		// TITULO
		$titulo = $this->conf->get('titulo');
		if (!empty($titulo)){
			imagettftext($im, $this->conf->get('tamano_fuente_titulo'), 0, $titulo['x'], $this->conf->get('set_offset_cuerpo'), $fuente_color, $this->conf->get('fontBold'), $titulo['texto']);
			$valor_offset = $this->conf->get('set_offset_cuerpo') + $this->conf->get('tamano_fuente_titulo') + $this->conf->get('interlineado') + 5;
			$this->set_conf('set_offset_cuerpo', $valor_offset);
		}

		// SUBTITULO
		$subtitulo = $this->conf->get('subtitulo');
		if (!empty($subtitulo)){
			imagettftext($im, $this->conf->get('tamano_fuente_subtitulo'), 0, $subtitulo['x'], $this->conf->get('set_offset_cuerpo'), $fuente_color, $this->conf->get('fontBold'), $subtitulo['texto']);
			$valor_offset = $this->conf->get('set_offset_cuerpo') + $this->conf->get('tamano_fuente_subtitulo') + $this->conf->get('interlineado') + 10;
			$this->set_conf('set_offset_cuerpo', $valor_offset);
		}

		// TEXTO
		$tabla = $this->conf->get('tabla');
		$estilos = $this->conf->get('estilos');
		$tamanio_fuente = $this->conf->get('tamano_fuente');

		if (!empty($tabla)){
			foreach ($tabla as $key => $texto){
				$etiqueta_color = imagecolorallocate($im, $etiqueta_color_defecto[0], $etiqueta_color_defecto[1], $etiqueta_color_defecto[2]);
				//$etiqueta = ucfirst(kernel::traductor()->trans(strtolower($texto['etiqueta'])));
				imagettftext($im, $tamanio_fuente, 0, $this->conf->get('margen'), $this->conf->get('set_offset_cuerpo'), $etiqueta_color, $this->conf->get('font'), $texto['etiqueta'].":  ");

				if (array_key_exists($texto['etiqueta'], $estilos)){
					$tamanio_fuente_activa = $estilos[$texto['etiqueta']]['tamanio'];
					$fuente_color_activo = imagecolorallocate($im, $estilos[$texto['etiqueta']]['color'][0], $estilos[$texto['etiqueta']]['color'][1], $estilos[$texto['etiqueta']]['color'][2]);
				}
				else
				{
					$tamanio_fuente_activa = $tamanio_fuente;
					$fuente_color_activo = $fuente_color;
				}

				if (is_array($texto['texto'])){
					$x = $texto['x'];
					foreach($texto['texto'] as $key => $value){
						imagettftext($im, $tamanio_fuente_activa, 0, $x, $this->conf->get('set_offset_cuerpo'), $fuente_color_activo, $this->conf->get('fontBold'), $value);
						if ($key == 0)
							$x = $this->conf->get('margen');
						$valor_offset = $this->conf->get('set_offset_cuerpo') + $tamanio_fuente_activa + $this->conf->get('interlineado');
						$this->set_conf('set_offset_cuerpo', $valor_offset);
					}
				}
				else
				{
					imagettftext($im, $tamanio_fuente_activa, 0, $texto['x'], $this->conf->get('set_offset_cuerpo'), $fuente_color_activo, $this->conf->get('fontBold'), $texto['texto']);
					$valor_offset = $this->conf->get('set_offset_cuerpo') + $tamanio_fuente_activa + $this->conf->get('interlineado');
					$this->set_conf('set_offset_cuerpo', $valor_offset);
				}
			}
		}
		
		return $im;
	}
}
?>