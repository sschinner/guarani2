<?php
namespace siu\operaciones\tesis;

use kernel\kernel;

class generador_excel extends \siu\operaciones\_comun\operaciones\reporte\generador_excel
{
	public function agregar_tabla($datos = array(), $columnas = array(), $titulo = "Tesis")
	{
		$this ->agregar_texto("",1);
		$columnas['titulo'] = 'Título de la tesis';
		$columnas['fecha_alta'] = 'Fecha de alta';
		$columnas['fecha_vencimiento'] = 'Fecha de vencimiento';
		$columnas['fecha_aprobacion'] = 'Fecha de aprobación';
		$columnas['estado'] = 'Estado';

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
			foreach($datos as $linea)
			{
				$col_actual = 0;
				foreach($linea as $col_name => $col_dato)
				{
					if ($col_name == 'estado')
					{
						$hoja->setCellValueByColumnAndRow($col_actual, $this->linea, strtoupper($col_dato));
						$hoja->getStyleByColumnAndRow($col_actual, $this->linea)->applyFromArray($estilo_titulos);
					}
					else
					{
						$hoja->setCellValueByColumnAndRow($col_actual, $this->linea, $col_dato);
						$hoja->getStyleByColumnAndRow($col_actual, $this->linea)->applyFromArray($estilo_datos);
					}
					$col_actual++;
				}
				$this->linea++;
			}
		} else {
			$hoja->setCellValueByColumnAndRow(0, $this->linea, ucfirst(kernel::traductor()->trans('no_hay_renglones')));
		}
	}
}
?>