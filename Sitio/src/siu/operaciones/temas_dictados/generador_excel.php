<?php
namespace siu\operaciones\temas_dictados;

require_once "phpExcel/PHPExcel.php";

use kernel\kernel;
use siu\guarani;
use kernel\util\u;

class generador_excel {
	protected $planilla;
	protected $linea = 1;
	protected $nombre_archivo = "archivo";

	function __construct(){
		$this->planilla = new \PHPExcel();
	}

	public function agregar_tabla($datos = array(), $columnas = array(), $titulo = "Reporte"){
		$hoja = $this->planilla->getActiveSheet();
		$hoja->setTitle($titulo);

		$borde = array('style' => \PHPExcel_Style_Border::BORDER_THIN  );

		$estilo_titulos = array(
 			'font' => array('bold' => true),
 			'borders' => array('bottom' => $borde, 'top' => $borde, 'left' => $borde, 'right' => $borde),
 			'fill' => array(
					'type' => \PHPExcel_Style_Fill::FILL_SOLID,
					'rotation'   => 0,
					'startcolor' => array('rgb' => 'E6E6E6')
			)
 		);

		$estilo_datos = array(
 			'borders' => array('bottom' => $borde, 'top' => $borde, 'left' => $borde, 'right' => $borde),
			'fill' => array(
					'type' => \PHPExcel_Style_Fill::FILL_SOLID ,
					'rotation'   => 0,
					'startcolor' => array('rgb' => 'FFFFFF')
				)
 		);

		$col_actual = 0;
		foreach($columnas as $columna){
			$hoja->setCellValueByColumnAndRow($col_actual, $this->linea, $columna);
			$hoja->getStyleByColumnAndRow($col_actual, $this->linea)->applyFromArray($estilo_titulos);
			$col_actual++;
		}
		$this->linea++;

		if (!empty($datos)){
			foreach($datos as $linea){
				$col_actual = 0;
				foreach($linea as $col_dato){
					$hoja->setCellValueByColumnAndRow($col_actual, $this->linea, $col_dato);
					$hoja->getStyleByColumnAndRow($col_actual, $this->linea)->applyFromArray($estilo_datos);
					$col_actual++;
				}
				$this->linea++;
			}
		} else {
			$hoja->setCellValueByColumnAndRow(0, $this->linea, ucfirst(kernel::traductor()->trans('no_hay_renglones')));
		}
	}

	public function agregar_texto($title = "", $cant_titulos = 0){
		$this->planilla->getActiveSheet()->setCellValueByColumnAndRow(0, $this->linea, $title);
		$this->planilla->getActiveSheet()->mergeCellsByColumnAndRow(0, $this->linea, $cant_titulos-1, $this->linea);
		$this->linea++;
		$this->linea++;
	}

	public function set_nombre_archivo($nombre) {
		$this->nombre_archivo = $nombre;
	}

	function generar(){
		$objWriter = new \PHPExcel_Writer_Excel5($this->planilla);
		$nombre = $this->nombre_archivo.".xls";
		
		$path_nombre = kernel::proyecto()->get_dir_temp() ."/". $nombre;
		$objWriter->save($path_nombre);
		$contenido = file_get_contents($path_nombre);
		$longitud = filesize($path_nombre);
		unlink($path_nombre);

		header("Cache-Control: private",false);
  		header("Content-type: application/vnd.ms-excel");
  		header("Content-Length: ".$longitud);
   		header("Content-Disposition: attachment; filename=".$nombre);
		header("Content-Transfer-Encoding: binary");
  		header("Pragma: no-cache");
		header("Expires: 0");
		echo $contenido;
	}
}
?>