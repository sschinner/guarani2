<?php

namespace siu\operaciones\notas_parciales;

use siu\guarani;
use kernel\kernel;
use siu\errores\error_guarani_procesar_renglones;
use kernel\util\validador;
use siu\util\generador_escalas;
use siu\modelo\datos\catalogo;
use kernel\nucleo\finalizador_request;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\errores\error_guarani;

class controlador extends \siu\operaciones\_comun\controlador_carga_notas
{
	public $evaluacion_id;
	public $pagina = 1;	
	
	protected $pdf_hoja = "A4";
	protected $pdf_encabezado = array("", "");
	protected $pdf_encabezado_img = array("img" => "", "width" => "");
	protected $pdf_fuente = "Courier.afm";
	protected $pdf_fuente_texto = 10;
	protected $pdf_fuente_titulo = 10;
	protected $pdf_fuente_subtitulo = 12;
	protected $tiene_encabezado = true;
	protected $encabezado_reporte = "";
	
	function get_clase_vista()
	{
		switch ($this->accion) {
			case 'index': 
			case 'borrar_evaluacion': 
			case 'crear_evaluacion':
				return 'vista_materias';
			case 'listar':
				return 'vista_notas';
			default: 
				return 'vista_edicion_notas';
		}
	}
	
    /**
     *
     * @return \siu\modelo\transacciones\carga_evaluaciones_parciales
     */
    function modelo()
    {
        return guarani::carga_evaluaciones_parciales();
    }

    function accion__index()
    {
	}

	function accion__info_escala()
	{
		$escala_id = $this->validate_param(0, 'get', validador::TIPO_INT);
		$escala_notas = $this->modelo()->info__escala_notas($escala_id);
		$this->render_raw_json($escala_notas);
	}
	
	function accion__crear_evaluacion()
	{
		try
		{
			$param_erroneo = 'comision';
			$comision = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM);
			$param_erroneo = 'tipo';
			$tipo	  = $this->validate_param('tipo',     'post', validador::TIPO_INT);
			$param_erroneo = 'escala';
			$escala   = $this->validate_param('escala',   'post', validador::TIPO_INT);
			$param_erroneo = 'fecha';
			$fecha = $this->validate_param('fecha',    'post', validador::TIPO_DATE, array('format' => 'Y-m-d'));
		}
		catch(\kernel\error_kernel_validacion $e) {
			switch($param_erroneo){
				case 'comision': 
					$mensaje = 'Error de validación en la comisión';
					break;
				case 'tipo': 
					$mensaje = 'Debe seleccionar un tipo de parcial';
					break;
				case 'escala': 
					$mensaje = 'Error de validación en la escala de notas';
					break;
				case 'fecha': 
					$mensaje = 'La fecha es inválida. Por favor ingrese una fecha en el formato día/mes/año.';
					break;
			};
			throw new \siu\errores\error_guarani_usuario($mensaje);
		}
		
		//$hora = kernel::request()->getPost('hora').':'.kernel::request()->getPost('minutos').':00';
		$hora = $this->validate_param('hora', 'post', validador::TIPO_INT).':'.$this->validate_param('minutos', 'post', validador::TIPO_INT).':00';
		$this->validate_value($hora, validador::TIPO_TIME, array('format' => 'H:i:s'));

		$msg = $this->modelo()->alta_evaluacion_parcial($comision, $tipo, $escala, $fecha, $hora);
		if ($msg != 'OK')
			$this->render_ajax('', array('success' => false, 'mensaje' => $msg));

		/*$pagelet = $this->vista()->pagelet('lista_materias');
		$pagelet->set_estado_info('crear_parcial');
		kernel::renderer()->add($pagelet);*/
		$evaluaciones = $this->modelo()->info__lista_evaluaciones();
		
		$fecha_hoy = new \DateTime();
		$fecha_hoy->setTime(0, 0, 0);
		
		foreach($evaluaciones as $materia)
		{
			if (	$materia['COMISION_URL'] == $comision
				&&	isset($materia['EVALUACION_COD_TIPO'])
				&&	$materia['EVALUACION_COD_TIPO'] == $tipo	)
			{
				$evaluacion_id = $materia[catalogo::id];
				
				$fecha_evaluacion = \DateTime::createFromFormat('Y-m-d H:i:s', $materia['EVALUACION_FECHA']);
				$fecha_evaluacion->setTime(0, 0, 0);
				
				$puede_cargar_notas = false;
				// Verifica que la fecha en que están cargando sea igual o mayor a la que está asignada en la evaluación parcial
				if ($fecha_hoy >= $fecha_evaluacion) {
					$puede_cargar_notas = true;
				}
				
				$html = kernel::load_template('lista_materias/parcial.twig')->render(array(
					'nombre' => $materia['EVALUACION_NOMBRE'],
					'tipo' => $tipo,
					'porcentaje' => 0,
					'cant_inscriptos' => $materia['CANT_INSCRIPTOS'],
					'url_listar' => kernel::vinculador()->crear('notas_parciales', 'listar', $evaluacion_id),
					'url_editar' => kernel::vinculador()->crear('notas_parciales', 'editar', $evaluacion_id),
					'evaluacion_id' => $evaluacion_id,
					'fecha' => date("d/m/Y H:i", strtotime($materia['EVALUACION_FECHA'])),
					'puede_cargar_notas' => $puede_cargar_notas
				));

				$pagelet = $this->vista()->pagelet('lista_materias');
				$materias = $pagelet->get_lista_materias();

				$completo = false;
				if (isset($materias[$materia['MATERIA']]['COMISIONES'][$materia['COMISION']]['COMPLETA']))
					$completo = $materias[$materia['MATERIA']]['COMISIONES'][$materia['COMISION']]['COMPLETA'];
				$this->render_ajax('', array('success' => true, 'html' => $html, 'completo' => $completo));
			}
		}
	}

	function accion__borrar_evaluacion()
	{
		$evaluacion_id = $this->validate_param('eval',  'post', validador::TIPO_ALPHANUM);
		$this->modelo()->baja_evaluacion_parcial($evaluacion_id);
		$this->render_ajax();
	}
	
	function accion__editar()
	{
		$this->load_params();
		$encabezado = $this->get_encabezado();
		
		$fecha_hoy = new \DateTime();
		$fecha_hoy->setTime(0, 0, 0);
		
		$fecha_evaluacion = \DateTime::createFromFormat('d/m/Y H:i', $encabezado['FECHA_HORA']);
		$fecha_evaluacion->setTime(0, 0, 0);
		
		// Verifica que la fecha en que están cargando sea igual o mayor a la que está asignada en la evaluación parcial
		if ($fecha_hoy < $fecha_evaluacion) {
			throw new error_guarani(kernel::traductor()->trans('fecha_evaluacion_mayor_hoy'));
		}
		
		if (kernel::request()->isPost()) {
			try {
				$this->guardar(kernel::request()->getPost('renglones'));
			} catch (error_guarani_procesar_renglones $e) {
				kernel::log()->add_debug('error al procesar renglones', $e);
				$this->vista()->pagelet('edicion_notas')->set_error_guarani_procesar_renglones($e);
			}
		}
		kernel::renderer()->add($this->vista()->pagelet('edicion_notas'));
	}

	function accion__listar()
	{
		$this->load_params();
	}
	
	
	protected function load_params()
	{
		$this->evaluacion_id = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		
		$this->pagina = (kernel::url()->hay_param(1)) ? $this->validate_param(1, 'get', validador::TIPO_INT) : 1;
	}
	
	protected function get_clave_sesion_parcial()
	{
		return "parcial[$this->evaluacion_id,$this->pagina]";
	}
	
	// MÉTODOS COMUNES PARA QUE ACCEDAN LOS PAGELETS
	
	function get_encabezado()
	{
		return $this->modelo()->info__evaluacion_cabecera($this->evaluacion_id);
	}
	
	function get_renglones()
	{
		$renglones = $this->modelo()->info__evaluacion_detalle($this->evaluacion_id);
		$renglones_numerados = array();
		$i = 1;
		foreach ($renglones as $key=>$renglon) {
			$renglon_numerado = $renglon;
			$renglon_numerado['RENGLON'] = $i;
			$renglones_numerados[$i] = $renglon_numerado;
			$i++;
		}
		// se guardan en sesión las filas para dp actualizar, ver método guardar folio
		kernel::sesion()->set($this->get_clave_sesion_parcial(), $renglones_numerados);
		
		return $renglones_numerados;
	}
	
	protected function guardar($renglones_post)
	{
		kernel::log()->add_debug('renglones_post', $renglones_post);
		$renglones_sesion = kernel::sesion()->get($this->get_clave_sesion_parcial());
		$renglones_modificados = array();
		foreach($renglones_sesion as $id => $fila_s) {
			$renglon = $fila_s['RENGLON'];
			if(isset($renglones_post[$renglon])) {
				if (!isset($renglones_post[$renglon]['OBSERVACIONES'])) $renglones_post[$renglon]['OBSERVACIONES'] = "";
				if (!isset($renglones_post[$renglon]['CORREGIDO_POR'])) $renglones_post[$renglon]['CORREGIDO_POR'] = "";
				if( ($renglones_post[$renglon]['NOTA'] != $fila_s['NOTA'])
					|| ($renglones_post[$renglon]['OBSERVACIONES'] != $fila_s['OBSERVACIONES']) 
					|| ($renglones_post[$renglon]['CORREGIDO_POR'] != $fila_s['CORREGIDO_POR']) 
					) {
					$renglones_modificados[$id] = $fila_s;
					$renglones_modificados[$id]['NOTA'] = $this->vacio_a_null($renglones_post[$renglon]['NOTA']);
					$renglones_modificados[$id]['CORREGIDO_POR'] = $this->vacio_a_null($renglones_post[$renglon]['CORREGIDO_POR']);
					$renglones_modificados[$id]['OBSERVACIONES'] = $this->vacio_a_null($renglones_post[$renglon]['OBSERVACIONES']);
				}
			}
		}
		
		if ($renglones_modificados){
			$this->modelo()->evt__procesar_evaluaciones($this->evaluacion_id, $renglones_modificados);
		}
	}
	
	protected function vacio_a_null($valor)
	{
		if (trim($valor) == '') {
			return null;
		}
		
		return $valor;
	}
	
	/* Exportar notas de parcial */
	function accion__generar_pdf()
	{
		$this->evaluacion_id = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
		
		$pdf = new generador_pdf($this->crear_ezpdf());
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 800, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array('FECHA_DISPLAY'=>array('width'=>75))));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 800));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);
		$pdf->set_nombre_archivo('evaluaciones_parciales');

		$encabezado_acta = $this->get_encabezado();
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => 'Materia: '.$encabezado_acta['MATERIA_NOMBRE']." (".$encabezado_acta['MATERIA'].")",
												 1 => 'Evaluación: '.$encabezado_acta['EVALUACION_DESC'],
												 2 => 'Fecha y hora: '.$encabezado_acta['FECHA_HORA'],
												 3 => 'Escala de notas: '.$encabezado_acta['ESCALA_NOTAS_DESC'],
												 4 => 'Comisión: '.$encabezado_acta['COMISION_NOMBRE'],
												 5 => 'Cátedra: '.$encabezado_acta['CATEDRA']
												)
								);
								
		$pdf->set_encabezado_tabla($datos_encabezado);
	
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		
		$this->pdf_encabezado = array($universidad, '<b><u>Listado de notas de Evaluación Parcial</u></b>', 110);
		$this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
//                $pdf->posY(720);
                $pdf->agregar_texto("");

		$titulos = $this->get_columnas();
		$datos = $this->get_renglones();
//		$pdf->agregar_texto('Alumno: '.$alumno.PHP_EOL.'Legajo: '.$legajo.PHP_EOL.'Carrera: '.$nombre_carrera.PHP_EOL.'Plan: '.$plan.PHP_EOL);
		$pdf->agregar_tabla($datos, $titulos, '');
		$pdf->agregar_texto("");
		
			
		$pdf->generar();		
	}
	
	protected function crear_ezpdf(){
		$instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
		return $instancia;
	}

	function get_columnas()
	{ 
		return array(
			'NOMBRE' => ucfirst(kernel::traductor()->trans('nombre_alumno')),
			'NOTA' => ucfirst(kernel::traductor()->trans('nota')),
			'RESULTADO' => ucfirst(kernel::traductor()->trans('resultado')),
			'CORREGIDO_POR' => ucfirst(kernel::traductor()->trans('corregido_por')),
			'OBSERVACIONES' => ucfirst(kernel::traductor()->trans('observaciones')));
	}
	
	function accion__generar_excel(){
		$this->evaluacion_id = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
		
		$excel = $this->get_generador_excel();

		$titulos = $this->get_columnas();
		$datos = $this->get_renglones();
		
       $institucion = guarani::ua()->get_nombre_institucion();
       $facultad = guarani::ua()->get_nombre();

       $excel->agregar_texto_sin_enter($institucion,1);
       $excel->agregar_texto($facultad,1);
       $estilo_titulo = array(
                        'font' => array('bold' => true),
                );
        $excel->agregar_texto_estilos('Listado de notas de Evaluación Parcial',1, $estilo_titulo);	

		// enacabezado
		$datos_encabezado = $this->get_encabezado();
		$excel->agregar_texto_sin_enter("Materia: ".$datos_encabezado['MATERIA_NOMBRE']." (".$datos_encabezado['MATERIA'].")", 1);
		$excel->agregar_texto_sin_enter("Evaluación: ".$datos_encabezado['EVALUACION_DESC'], 1);
		$excel->agregar_texto_sin_enter("Fecha y hora: ".$datos_encabezado['FECHA_HORA'], 1);
		$excel->agregar_texto_sin_enter("Escala de notas: ".$datos_encabezado['ESCALA_NOTAS_DESC'], 1);
		$excel->agregar_texto_sin_enter("Comisión: ".$datos_encabezado['COMISION_NOMBRE'],1);
		$excel->agregar_texto_sin_enter("Cátedra: ".$datos_encabezado['CATEDRA'],1);

		$excel->agregar_tabla($datos,$titulos);
		$excel->set_nombre_archivo('evaluaciones_parciales');
		$excel->generar();
	}
	
	protected function get_generador_excel()
	{
		require_once (realpath(guarani::dir()."/operaciones/_comun/operaciones/reporte/generador_excel.php"));
		return new \siu\operaciones\_comun\operaciones\reporte\generador_excel();
	}	
	
}
?>