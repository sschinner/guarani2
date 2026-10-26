<?php
namespace siu\operaciones\plan;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\u;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use kernel\util\validador;

class controlador extends controlador_g3w2
{
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
		return guarani::plan_estudios();
	}

	function ini_request()
	{
	}

	function accion__index()
	{
		$plan_historia = $this->modelo()->get_plan_estudio_con_actividad_academica();
		$this->vista()->pagelet('info_plan')->data['plan'] = $plan_historia;
		$this->vista()->pagelet('info_plan')->data['datos_carrera'] = $plan_historia['datos_carrera'];
		$this->vista()->pagelet('info_plan')->data['promedios'] = $plan_historia['promedios'];
	}

	protected function crear_ezpdf(){
		require_once "ezpdf/class.ezpdf.php";
		$instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
		return $instancia;
	}
	
	function accion__correlativas()
	{
		$id = $this->validate_param('id', 'post', validador::TIPO_TEXTO);
		$correlativas = $this->modelo()->get_correlativas($id);
		$resultado = array();
		foreach ($correlativas as $key => $correlativa) {
			if ($correlativa['CONDICION'] == 'cursar') {
				$resultado['correlativas']['cursar'][$key] = $correlativa;
			} else {
				$resultado['correlativas']['aprobar'][$key] = $correlativa;
			}
		}
		$resultado['materia'] = $id;
		$this->render_template('detalle.twig', $resultado);
		
	}

	function accion__verificar_correlativas()
	{
        if(kernel::request()->isPost())
        {
            $hubo_error = false;
            $mensaje_error = "";

            try
			{
                $materia = $this->validate_param('materia', 'post', validador::TIPO_TEXTO);
                $tipo = $this->validate_param('tipo', 'post', validador::TIPO_TEXTO);

                $resultado_correlativas = $this->modelo()->get_resultado_correlativa($materia, $tipo);
                $cumple_regla = false;

				if ($resultado_correlativas['error_consulta'] == false)
                {

                    $mensaje_usuario = $resultado_correlativas['mensaje_usuario'];
                    $cumple_regla = $resultado_correlativas['resultado_consulta'];
				}
                else
                {
                    kernel::renderer()->add_to_ajax_response('hubo_error', $resultado_correlativas['error_consulta']);

				}

                kernel::renderer()->add_to_ajax_response('cumple_regla', $cumple_regla);
                kernel::renderer()->add_to_ajax_response('mensaje_usuario', $mensaje_usuario);

            }
			catch (\Exception $e)
            {
                $hubo_error = true;
                $mensaje_error = $e->getMessage();
            }

            kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
            kernel::renderer()->add_to_ajax_response('mensaje_error', $mensaje_error);

    	}

	}

	function accion__generar_pdf()
	{
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
		$data_bruto = $this->modelo()->get_plan_estudio_con_actividad_academica();
		$data_titulos = $data_bruto['promedios'];
		$data_creditos = $data_bruto['creditos'];
		$data_fin = array();
		foreach($data_bruto['detalle'] as $key => $value){
			$data_fin[$key] = $value;
			if (!empty($value['INFO_ACT_ACAD_MATERIA'])){
			$estado = null;
			if ($value['INFO_ACT_ACAD_MATERIA']['TIPO'] == 'Regularidad' and $value['INFO_ACT_ACAD_MATERIA']['VIGENTE']== 0)
			{
				if($value['INFO_ACT_ACAD_MATERIA']['ORIGEN']== 'Equivalencia')
				{
						$estado = ucfirst($this->trans('plan.equiv_reg_venc'));
				}
				else
				{
					$estado = ucfirst($this->trans('plan.cursada_venc'));
				}
					
			}
			else
			{
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'Aprobacion')
				{
					$estado = $estado . $value['INFO_ACT_ACAD_MATERIA']['ORIGEN']. ' - ';
				}	
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'En Curso')
				{
					$estado = $estado . ucfirst($this->trans('plan.en_curso'));
				}	
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'Regularidad')
				{
					if($value['INFO_ACT_ACAD_MATERIA']['ORIGEN']== 'Equivalencia')
					{
						$estado = $estado . ucfirst($this->trans('plan.equiv_reg')).' - ';
					}
					else
					{
						$estado = $estado . $value['INFO_ACT_ACAD_MATERIA']['ORIGEN'].' - ';
					}
				}
				
				if(!empty($value['INFO_ACT_ACAD_MATERIA']['NOTA']))
				{
					$estado = $estado.$value['INFO_ACT_ACAD_MATERIA']['NOTA'].' ('.$value['INFO_ACT_ACAD_MATERIA']['NOTA_DESCRIPCION'].')';
				}
				else
				{
					if(!empty($value['INFO_ACT_ACAD_MATERIA']['RESULTADO']))
					{
						$estado = $estado.ucfirst($this->trans('plan.sin_nota'));
					}
				}
				
			}				
				$data_fin[$key]['estado'] = $estado;
			}
			else
			{
				$data_fin[$key]['estado'] = "";
			}		
			unset($data_fin['INFO_ACT_ACAD_MATERIA']);
		}
		$plan = $data_bruto['datos_carrera']['plan'];
		$data_bruto = $data_fin;

		$pdf = new generador_pdf($this->crear_ezpdf());

		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 800, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 800));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);


		$alumno = guarani::persona()->get_nombre();
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		$nombre_carrera = "";
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		$legajo = guarani::persona()->get_id_legajo_activo();
		$plan = guarani::persona()->get_id_plan_activo();
		//$pdf->set_encabezado_reporte('Alumno: '.$alumno.PHP_EOL.'Legajo: '.$legajo.PHP_EOL.'Carrera: '.$nombre_carrera.PHP_EOL.'Plan: '.$plan.PHP_EOL);
		
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => 'Alumno: '.$alumno,
												 1 => 'Legajo: '.$legajo,
												 2 => 'Carrera: '.$nombre_carrera,
												 3 => 'Plan: '.$plan
												)
								);
								
		$pdf->set_encabezado_tabla($datos_encabezado);
		
		$this->pdf_encabezado = array($universidad, "<b><u>Plan de estudios</b></u>", 110);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], '100');
//                $pdf->posY(720);
                $pdf->agregar_texto("");
                
		$titulos = array(
						'MATERIA' =>ucfirst($this->trans('plan.materia')),
						'NOMBRE_MATERIA' =>ucfirst($this->trans('plan.nombre_materia')),
						'TIPO_DETALLE' =>ucfirst($this->trans('plan.tipo_materia')),
						'ANIO' =>ucfirst($this->trans('plan.ano_cursada')),
						'PERIODO' =>ucfirst($this->trans('plan.periodo_dictado')),
						'CREDITO' =>ucfirst($this->trans('plan.credito')),
						'estado' =>ucfirst($this->trans('plan.estado'))
					);
//		$info_carrera = kernel::persona()->get_info_carrera_activa();
//		$pdf->agregar_texto(ucfirst($this->trans('nombre_alumno')).": ".kernel::persona()->get_nombre());
//		$pdf->agregar_texto(ucfirst($this->trans('plan.carrera')).": ".$info_carrera["id"]);
//		$pdf->agregar_texto(ucfirst($this->trans('plan.nombre_carrera')).": ".$info_carrera["nombre"]);
//		$pdf->agregar_texto(ucfirst($this->trans('plan.plan')).": ".$plan);
//		$pdf->agregar_texto("");

		$pdf->agregar_tabla($data_bruto, $titulos, '');
		$pdf->agregar_texto("");

		foreach($data_titulos as $titulo){
			$data_promedio_general = number_format($titulo['promedio_general'],2);
			$data_promedio_sin_aplazos = number_format($titulo['promedio_sin_aplazos'],2);		

			$pdf->agregar_texto(ucfirst($this->trans('plan.titulo')).": ".$titulo['nombre']);
			$pdf->agregar_texto(ucfirst($this->trans('plan.promedio_general')).": ".$data_promedio_general);
			$pdf->agregar_texto(ucfirst($this->trans('plan.promedio_sin_aplazos')).": ".$data_promedio_sin_aplazos);
			$pdf->agregar_texto("");		
			};

			$data_cred_materias_aprobadas = number_format($data_creditos['materias_aprobadas'],2);
			$data_cred_cursadas_aprob_vigentes = number_format($data_creditos['cursadas_aprob_vigentes'],2);		

			$pdf->agregar_texto(ucfirst($this->trans('plan.creditos')));
			$pdf->agregar_texto(ucfirst($this->trans('plan.creditos_materias_aprobadas')).": ".$data_cred_materias_aprobadas);
			$pdf->agregar_texto(ucfirst($this->trans('plan.creditos_materias_cur_vigentes')).": ".$data_cred_cursadas_aprob_vigentes);
			$pdf->agregar_texto("");
			
		$pdf->generar();
	}
	
	function accion__generar_excel()
	{
		$data_bruto = $this->modelo()->get_plan_estudio_con_actividad_academica();
		$data_titulos = $data_bruto['promedios'];
		$data_creditos = $data_bruto['creditos'];
		$data_fin = array();
		foreach($data_bruto['detalle'] as $key => $value){
			$data_fin[$key] = $value;
			if (!empty($value['INFO_ACT_ACAD_MATERIA'])){
			$estado = null;
			if ($value['INFO_ACT_ACAD_MATERIA']['TIPO'] == 'Regularidad' and $value['INFO_ACT_ACAD_MATERIA']['VIGENTE']== 0)
			{
				if($value['INFO_ACT_ACAD_MATERIA']['ORIGEN']== 'Equivalencia')
				{
						$estado = ucfirst($this->trans('plan.equiv_reg_venc'));
				}
				else
				{
					$estado = ucfirst($this->trans('plan.cursada_venc'));
				}
					
			}
			else
			{
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'Aprobacion')
				{
					$estado = $estado . $value['INFO_ACT_ACAD_MATERIA']['ORIGEN']. ' - ';
				}	
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'En Curso')
				{
					$estado = $estado . ucfirst($this->trans('plan.en_curso'));
				}	
				if($value['INFO_ACT_ACAD_MATERIA']['TIPO']== 'Regularidad')
				{
					if($value['INFO_ACT_ACAD_MATERIA']['ORIGEN']== 'Equivalencia')
					{
						$estado = $estado . ucfirst($this->trans('plan.equiv_reg')).' - ';
					}
					else
					{
						$estado = $estado . $value['INFO_ACT_ACAD_MATERIA']['ORIGEN'].' - ';
					}
				}
				
				if(!empty($value['INFO_ACT_ACAD_MATERIA']['NOTA']))
				{
					$estado = $estado.$value['INFO_ACT_ACAD_MATERIA']['NOTA'].' ('.$value['INFO_ACT_ACAD_MATERIA']['NOTA_DESCRIPCION'].')';
				}
				else
				{
					if(!empty($value['INFO_ACT_ACAD_MATERIA']['RESULTADO']))
					{
						$estado = $estado.ucfirst($this->trans('plan.sin_nota'));
					}
				}
				
			}				
				$data_fin[$key]['estado'] = $estado;
			}
			else
			{
				$data_fin[$key]['estado'] = "";
			}		
			unset($data_fin['INFO_ACT_ACAD_MATERIA']);
		}
		$plan = $data_bruto['datos_carrera']['plan'];
		$data_bruto = $data_fin;
	
		$xls = new generador_excel();
		$titulos = array(
						'MATERIA' =>ucfirst($this->trans('plan.materia')),
						'NOMBRE_MATERIA' =>ucfirst($this->trans('plan.nombre_materia')),
						'TIPO_DETALLE' =>ucfirst($this->trans('plan.tipo_materia')),
						'ANIO' =>ucfirst($this->trans('plan.ano_cursada')),
						'PERIODO' =>ucfirst($this->trans('plan.periodo_dictado')),
						'CREDITO' =>ucfirst($this->trans('plan.credito')),
						'estado' =>ucfirst($this->trans('plan.estado'))
					);
		$xls->set_nombre_archivo('plan_estudios');

		$alumno = guarani::persona()->get_nombre();
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		$nombre_carrera = "";
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		$legajo = guarani::persona()->get_id_legajo_activo();
		$plan = guarani::persona()->get_id_plan_activo();
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$xls->agregar_texto_sin_enter($institucion,1);
		$xls->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$xls->agregar_texto_estilos('Plan de estudios',1, $estilo_titulo);
		$xls->agregar_texto_sin_enter('Alumno: '.$alumno,1);
		$xls->agregar_texto_sin_enter('Legajo: '.$legajo,1);
		$xls->agregar_texto_sin_enter('Carrera: '.$nombre_carrera,1);
		$xls->agregar_texto_sin_enter('Plan: '.$plan,1);
		$xls->agregar_tabla($data_bruto, $titulos);
		
		$xls->agregar_texto_sin_enter("",1);
		
		$xls->agregar_texto_estilos('Promedios',1, $estilo_titulo);
		foreach($data_titulos as $titulo){
			$data_promedio_general = number_format($titulo['promedio_general'],2);
			$data_promedio_sin_aplazos = number_format($titulo['promedio_sin_aplazos'],2);		
			
			$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.titulo')).": ".$titulo['nombre'], 1);
			$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.promedio_general')).": ".$data_promedio_general, 1);
			$xls->agregar_texto(ucfirst($this->trans('plan.promedio_sin_aplazos')).": ".$data_promedio_sin_aplazos, 1);
			$xls->agregar_texto_sin_enter("",1);
			};
			
		$data_cred_materias_aprobadas = number_format($data_creditos['materias_aprobadas'],2);
		$data_cred_cursadas_aprob_vigentes = number_format($data_creditos['cursadas_aprob_vigentes'],2);		
		$xls->agregar_texto_estilos($this->trans('plan.creditos'),1, $estilo_titulo);
		$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.creditos_materias_aprobadas')).": ".$data_cred_materias_aprobadas, 1);
		$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.creditos_materias_cur_vigentes')).": ".$data_cred_cursadas_aprob_vigentes, 1);
		$xls->agregar_texto_sin_enter("",1);
		
		$xls->generar();
	}
	
}
?>
