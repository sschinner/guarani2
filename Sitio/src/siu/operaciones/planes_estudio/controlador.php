<?php
namespace siu\operaciones\planes_estudio;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\guarani;
use kernel\util\u;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;

class controlador extends controlador_g3w2
{
	protected $pdf_hoja = "A4";
	protected $pdf_encabezado = array("", "");
	protected $pdf_encabezado_img = array("img" => "", "width" => "");
	protected $pdf_fuente = "Courier.afm";
	protected $pdf_fuente_texto = 10;
	protected $pdf_fuente_titulo = 10;
	protected $pdf_fuente_subtitulo = 10;
	
	function modelo()
	{
		return guarani::plan_estudios();
	}
	
	function accion__index()
	{
		$clase = 'operaciones\planes_estudio\pagelet_filtro';
		$pl = kernel::localizador()->instanciar($clase, 'filtro');
		$this->vista()->add_pagelet($pl);
		
		$datos = array('detalle' => array());
		$clase = 'operaciones\planes_estudio\pagelet_info_plan';
		$pl = kernel::localizador()->instanciar($clase, 'info_plan');
		$pl->data['plan'] = $datos;
		$this->vista()->add_pagelet($pl);
	}
	
	function accion__cargar_plan_estudio(){
		
		$carrera_hash = $this->validate_param('carrera', 'post', validador::TIPO_ALPHANUM);
		$plan_hash = $this->validate_param('plan', 'post', validador::TIPO_ALPHANUM);
		$version_hash = $this->validate_param('version', 'post', validador::TIPO_ALPHANUM);

        list($carrera, $carrera_nombre) = $this->decodificar_carrera($carrera_hash);
        $plan = $this->decodificar_plan($plan_hash, $carrera);
        $version = $this->decodificar_version_plan($version_hash, $carrera, $plan);

		$datos = array('detalle' => array());
		
		$clase = 'operaciones\planes_estudio\pagelet_info_plan';
		$pl = kernel::localizador()->instanciar($clase, 'info_plan');
		
			
		if(!is_null($carrera) && !is_null($plan) && !is_null($version)){
			
			/*$pl->add_var_js('carrera', $carrera);
			$pl->add_var_js('plan', $plan);
			$pl->add_var_js('version', $version);*/
			$pl->data['nro_carrera'] = $carrera;
			$pl->data['nombre_carrera'] = $carrera_nombre;
			$pl->data['nro_plan'] = $plan;
			$pl->data['nro_version'] = $version;
			
			$datos = catalogo::consultar('plan_estudios', 'get_detalle_plan_estudios',
									array	(	'carrera' => $carrera,
												'plan' => $plan,
												'version' => $version
											)
									);
			
		}
		
		$pl->data['plan'] = $datos;
		$this->vista()->add_pagelet($pl);
		//kernel::renderer()->reset();
		kernel::renderer()->add($pl);
		
	}
	
	protected function crear_ezpdf(){
		require_once "ezpdf/class.ezpdf.php";
		$instancia = new \Cezpdf($this->pdf_hoja);
		return $instancia;
	}
	
	function accion__correlativas()
	{
        $carrera_hash = $this->validate_param('carrera', 'post', validador::TIPO_ALPHANUM);
        $plan_hash = $this->validate_param('plan', 'post', validador::TIPO_ALPHANUM);
        $version_hash = $this->validate_param('version', 'post', validador::TIPO_ALPHANUM);
		$materia = $this->validate_param('id', 'post', validador::TIPO_TEXTO);

        list($carrera, $carrera_nombre) = $this->decodificar_carrera($carrera_hash);
        $plan = $this->decodificar_plan($plan_hash, $carrera);
        $version = $this->decodificar_version_plan($version_hash, $carrera, $plan);

		$correlativas = catalogo::consultar('alumno', 'get_correlativas',
								array	(	'carrera' => $carrera,
											'plan' => $plan,
											'version' => $version,
											'materia' => $materia
										)
									);
		$resultado = array();
		foreach ($correlativas as $key => $correlativa) {
			if ($correlativa['CONDICION'] == 'cursar') {
				$resultado['correlativas']['cursar'][$key] = $correlativa;
			} else {
				$resultado['correlativas']['aprobar'][$key] = $correlativa;
			}
		}
		$this->render_template('detalle.twig', $resultado);
		
	}

	function accion__generar_pdf()
	{
		$universidad = guarani::ua()->get_nombre_institucion().' - '.guarani::ua()->get_nombre();
        $carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM);
        $plan_hash = $this->validate_param('plan', 'get', validador::TIPO_ALPHANUM);
        $version_hash = $this->validate_param('version', 'get', validador::TIPO_ALPHANUM);

        list($carrera, $nombre_carrera) = $this->decodificar_carrera($carrera_hash);
        $plan = $this->decodificar_plan($plan_hash, $carrera);
        $version = $this->decodificar_version_plan($version_hash, $carrera, $plan);

		$data_bruto = $datos = catalogo::consultar('plan_estudios', 'get_detalle_plan_estudios',
								array	(	'carrera' => $carrera,
											'plan' => $plan,
											'version' => $version
										)
								);

		$pdf = new generador_pdf($this->crear_ezpdf());

		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 500, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 500, 'width' => 500));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);

		$this->pdf_encabezado = array($universidad, "Plan de estudio", "100");
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], '100');

		$titulos = array(
						'MATERIA' =>ucfirst($this->trans('plan.materia')),
						'NOMBRE_MATERIA' =>ucfirst($this->trans('plan.nombre_materia')),
						'TIPO_DETALLE' =>ucfirst($this->trans('plan.tipo_materia')),
						'ANIO' =>ucfirst($this->trans('plan.ano_cursada')),
						'PERIODO' =>ucfirst($this->trans('plan.periodo_dictado')),
						'CREDITO' =>ucfirst($this->trans('plan.credito'))
					);
		
		$pdf->agregar_texto(ucfirst($this->trans('plan.ua')).": ".guarani::ua()->get_nombre());
		$pdf->agregar_texto(ucfirst($this->trans('plan.carrera')).": ".$carrera);
		$pdf->agregar_texto(ucfirst($this->trans('plan.nombre_carrera')).": ".$nombre_carrera);
		$pdf->agregar_texto(ucfirst($this->trans('plan.plan')).": ".$plan);
		$pdf->agregar_texto(ucfirst($this->trans('plan.version')).": ".$version);
		$pdf->agregar_texto("");

		$pdf->agregar_tabla($data_bruto['detalle'], $titulos, '');
		$pdf->generar();
	}

    function decodificar_carrera($carrera_hash) {
        $datos = catalogo::consultar('plan_estudios', 'carreras');
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $carrera_hash){
                    return array($value['CARRERA'], $value['NOMBRE']);
                }
            }
        }
        return null;
    }

    function decodificar_plan($plan_hash, $carrera) {
        $datos = catalogo::consultar('plan_estudios', 'planes', array('carrera' => $carrera));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $plan_hash){
                    return $value['PLAN'];
                }
            }
        }
        return null;
    }

    function decodificar_version_plan($version_plan_hash, $carrera, $plan) {
        $datos = catalogo::consultar('plan_estudios', 'versiones_de_plan', array('carrera' => $carrera, 'plan' => $plan));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $version_plan_hash){
                    return $value['VERSION'];
                }
            }
        }
        return null;
    }

	function accion__buscar_planes() {
		$carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM);
        list($carrera, $carrera_nombre) = $this->decodificar_carrera($carrera_hash);
		$datos = array();
		if (!is_null($carrera)){
			$datos['planes'] = catalogo::consultar('plan_estudios', 'planes', array('carrera' => $carrera));
			$plan_vigente = $datos['planes'][0];
			$datos['versiones'] = catalogo::consultar('plan_estudios', 'versiones_de_plan', array('carrera' => $carrera, 'plan' => $plan_vigente['PLAN']));
		}
		$this->render_raw_json($datos);
	}
	
	function accion__buscar_versiones() {
		$carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM);
        list($carrera, $carrera_nombre) = $this->decodificar_carrera($carrera_hash);
		$plan_hash = $this->validate_param('plan', 'get', validador::TIPO_ALPHANUM);
        $plan = $this->decodificar_plan($plan_hash, $carrera);
		$datos = array();
		if (!is_null($plan)){
			$datos = catalogo::consultar('plan_estudios', 'versiones_de_plan', array('carrera' => $carrera, 'plan' => $plan));
		}
		$this->render_raw_json($datos);
	}
	
}
?>