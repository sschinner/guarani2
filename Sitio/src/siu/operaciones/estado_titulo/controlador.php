<?php
namespace siu\operaciones\estado_titulo;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\modelo\datos\catalogo;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
	protected $datos_consulta;
	protected $pdf_hoja = "A4";
	protected $pdf_encabezado = array("", "");
	protected $pdf_encabezado_img = array("img" => "", "width" => "");
	protected $pdf_fuente = "Courier.afm";
	protected $pdf_fuente_texto = 10;
	protected $pdf_fuente_titulo = 10;
	protected $pdf_fuente_subtitulo = 12;
	protected $tiene_encabezado = true;
	protected $encabezado_reporte = "";	
	
    function modelo()
    {
        return null;
    }

    function accion__index()
    {
    }
	
	function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$datos_consulta = catalogo::consultar('alumno', 'estado_titulo', $parametros);
		}
		$corte = array();
		if (!empty($datos_consulta)){
			foreach ($datos_consulta as $dato){
				$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
				$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
				$corte[$dato['carrera']]['plan'] = $dato['plan'];
				$corte[$dato['carrera']]['titulo'] = $dato['titulo'];
				$corte[$dato['carrera']]['fecha_egreso'] = $dato['fecha_egreso'];
				$corte[$dato['carrera']]['fecha_jura'] = $dato['fecha_jura'];

				$tramite['fecha'] = $dato['fecha'];
				$tramite['expediente'] = $dato['expediente'];
				$tramite['estado'] = $dato['estado'];
				$tramite['promedio_c_aplazos'] = $dato['prom_c_aplazos'];
				$tramite['promedio_s_aplazos'] = $dato['prom_s_aplazos'];

				$corte[$dato['carrera']]['tramites'][] = $tramite;
			unset($tramite);
			}
		}
		$this->datos_consulta = $corte;
		return $this->datos_consulta;
	}
	
	public function accion__generar_pdf(){
		$data = $this->get_data();

		$pdf = new generador_pdf($this->crear_ezpdf());
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 500, 'width' => 500));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);
		
		$alumno = guarani::persona()->get_nombre();

		$this->pdf_encabezado = array($universidad, '<b><u>'.kernel::traductor()->trans('header.menu.estado_titulo').'</b></u>', 110);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		$pdf->set_encabezado_reporte("\n\n".' Alumno: '.$alumno);
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], '100');

		$titulos = $this->titulos_tabla();


		foreach ($data as $titulo){
			$pdf->agregar_texto(ucfirst($this->trans('carrera')).": ".$titulo['carrera']);
			$pdf->agregar_texto(ucfirst($this->trans('legajo')).": ".$titulo['legajo']);
			$pdf->agregar_texto(ucfirst($this->trans('plan')).": ".$titulo['plan']);
			$pdf->agregar_texto(ucfirst($this->trans('titulo')).": ".$titulo['titulo']);
			$pdf->agregar_texto(ucfirst($this->trans('fecha_egreso')).": ".$titulo['fecha_egreso']);
			$pdf->agregar_texto(ucfirst($this->trans('fecha_jura')).": ".$titulo['fecha_jura']);
			$pdf->agregar_texto('');
			$pdf->agregar_tabla($titulo['tramites'], $titulos, '');
			$pdf->agregar_texto('');
			$pdf->agregar_texto('');
		}
		
		
		$pdf->set_nombre_archivo('estado_titulo');
		$pdf->generar();
	}

	protected function get_generador_excel()
	{
		return new \siu\operaciones\_comun\operaciones\reporte\generador_excel();
	}
	
	public function accion__generar_excel(){
		$excel = $this->get_generador_excel();
		
		//var_dump($excel);
		$data = $this->get_data();

		$alumno = guarani::persona()->get_nombre();
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$excel->agregar_texto_sin_enter($institucion,1);
		$excel->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos('Estado de Solicitud de Títulos',1, $estilo_titulo);
		
		$excel->agregar_texto("Alumno: ".$alumno,1);
		
		$titulos = $this->titulos_tabla();
		foreach ($data as $titulo){
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('carrera')).": ".$titulo['carrera'],1);
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('legajo')).": ".$titulo['legajo'],1);
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('plan')).": ".$titulo['plan'],1);
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('titulo')).": ".$titulo['titulo'],1);
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('fecha_egreso')).": ".$titulo['fecha_egreso'],1);
			$excel->agregar_texto_sin_enter(ucfirst($this->trans('fecha_jura')).": ".$titulo['fecha_jura'],1);
			$excel->agregar_tabla($titulo['tramites'], $titulos, '');
			$excel->agregar_texto("", 1);
		}		

		$excel->set_nombre_archivo($this->trans('estado_titulo'));
		$excel->generar();
	}
	
	protected function crear_ezpdf(){
		require_once "ezpdf/class.ezpdf.php";
		$instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
		return $instancia;
	}
	
	protected function titulos_tabla(){
		$titulo = array();
		$titulo['fecha'] = "Fecha";
		$titulo['expediente'] = "Expediente";
		$titulo['estado'] = "Estado del trámite";
		$titulo['promedio_c_aplazos'] = "Promedio con aplazos";
		$titulo['promedio_s_aplazos'] = "Promedio sin aplazos";
		return $titulo;
	}
}
?>