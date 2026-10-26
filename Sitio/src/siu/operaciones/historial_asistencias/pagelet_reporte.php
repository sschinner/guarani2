<?php
namespace siu\operaciones\historial_asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;
			
	function get_nombre()
	{
		return 'reporte';
	}

	function configurar()
	{
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());

		// Configuracion pdf
		$this->set_pdf_encabezado("Historial de Asistencias", "", 112);
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(13);
		$this->set_pdf_fuente_subtitulo(11);
		$this->set_pdf_hoja("a4");
	}

	public function get_columnas()
	{
		$titulo = array();
		$titulo['materia'] = kernel::traductor()->trans('historial_asistencia.materia');
		$titulo['comision'] = kernel::traductor()->trans('historial_asistencia.comision');
		$titulo['subcomision'] = kernel::traductor()->trans('historial_asistencia.subcomision');
		$titulo['per_lec'] = kernel::traductor()->trans('historial_asistencia.periodo_lectivo');
		return $titulo;
	}

	/**
	 * Recupera los datos
	 * @param entero $pagina
	 * Numero de página que se desea recuperar
	 * @param buleano $todo
	 * Recuperar todos los datos
	 * @return array 
	 */
	public function get_data_reporte($pagina = 0, $todo = false)
	{
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();

		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;

		$datos = $this->get_data();
		
		$nuevo = array();
		$i = 0; $j = 0;
		foreach($datos as $id => $dato) {
			$linea = array();
			
			if ($todo or ($i <= $reg_por_pagina && $j >= $minimo && $j < $maximo)){
				$linea['materia'] = $dato[17]." (".$dato[5].")";
				$linea['comision'] = $dato[12];
				if(!is_null($dato[19]))
				{
					$linea['subcomisión'] = $dato[20];
				}else
				{
					$linea['subcomisión'] = "";
				};
				$linea['per_lec'] = $dato[8];
				$linea['URL_LINEA'] = kernel::vinculador()->crear('historial_asistencias', 'asistencias', array('hash'=>$id));
				$i++;
			}
			$nuevo[$id] = $linea;
			$j++;
		}
		return $nuevo;
	}

	protected function get_data()
	{
		if (!isset($this->datos_consulta)) {
			$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
			$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
			$this->datos_consulta = catalogo::consultar('alumno', 'comisiones_subcomisiones_inscripto', $parametros);
		}
		return $this->datos_consulta;
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros()
	{
		 return count($this->get_data_reporte(0, true));
	}

	public function get_nombre_archivo()
	{
		return "historial_asistencias";
	}
}
?>