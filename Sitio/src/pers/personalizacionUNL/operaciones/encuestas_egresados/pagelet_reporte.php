<?php

namespace personalizacionUNL\operaciones\encuestas_egresados;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {

    protected $datos_consulta;
    protected $nuevo;

    public function get_nombre() {
        return 'reporte';
    }

    function configurar() {
        $this->set_rpp(15);
        $this->set_columnas_reporte($this->get_columnas());
    }

    public function get_columnas() {
        $titulos = array();

        return $titulos;
    }
    
    public function prepare() {
		$pagina = $this->get_pagina();
		
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['url_atributos'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina));
		
		$rpp = $this->get_rpp();
		$columnas = $this->get_columnas();
		
		$atributos = array();
		$res = array();
		foreach ($columnas as $col => $val){
			if (is_array($val)){
				$res[$col] = $val[0];
				if (isset($val[1]) && isset($val[1]['ordenable'])){
					$atributos[$col]['asc'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina, 'col' => $col,'ord' =>'asc'));
					$atributos[$col]['desc'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina, 'col' => $col,'ord' =>'desc'));
				}
			} else {
				$res[$col] = $val;
			}
		}
		$this->data['atributos_titulos'] = $atributos;
		$columnas = $res;
		unset($res);

		$corte = $this->get_corte();
		if (isset($corte)){
			$corte_campo = $corte['campo'];
		} else {
			$corte_campo = false;
		}

		if ($corte_campo)
		{
			$this->data['corte']['campo'] = $corte_campo;
			$this->data['datos_corte'] = $this->corte_de_control($this->get_data_reporte(0, true));
			$this->data['cantidad_columnas'] = count($columnas) -1;
			$this->data['titulos'] = $columnas;
		}
		else
		{
			$this->data['corte']['campo'] = false;
			$this->data['datos'] = $this->get_data_reporte($pagina);
			$this->data['titulos'] = $columnas;
			$this->data['cantidad_columnas'] = count($columnas);
		}

		// Callback pie de reporte
		$datos_tmp = $this->get_data_reporte(0, true);
		foreach ($this->funciones_pie_reporte as $funcion)
		{
			$datos_parametro[0] = $datos_tmp;
			$parametros = array_merge($datos_parametro, $funcion['parametros']);
			$this->data['funciones_pie_reporte'][] = call_user_func($funcion['funcion'], $parametros);
			unset($parametros);
		}

		foreach ($this->mensaje_pie_reporte as $funcion)
		{
			$datos_parametro[0] = $datos_tmp;
			$this->data['mensaje_pie_reporte'][] = call_user_func($funcion['funcion'], $datos_parametro[0]);						
		}
		unset($datos_tmp);

		$operacion = kernel::ruteador()->get_id_operacion();
                $this->data['mensajes'] = $this->controlador->get_var('mensajes');
		$this->data['pagina'] = $pagina;
		$this->data['url']['guardar'] = kernel::vinculador()->crear($operacion, 'guardar');
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear($operacion, 'generar_excel');
		$this->data['url']['index'] = kernel::vinculador()->crear($operacion, 'index');		
		$this->data['cant_por_pagina'] = $rpp;
	}


    /**
     * Recupera los datos
     * @param entero $pagina
     * Numero de p�gina que se desea recuperar
     * @param buleano $todo
     * Recuperar todos los datos
     * @return array
     */
    public function get_data_reporte($pagina = 0, $todo = false) {
        $i = 0;
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();

        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
        $operacion = kernel::ruteador()->get_id_operacion();
        $datos = $this->get_data();

        $this->nuevo['datosAlu'] = $this->getDatosAlu();
        $this->nuevo['calidad'] = $datos[0];
        $this->nuevo['nombreTitulo'] = utf8_decode('Encuesta Graduados');
        return $this->nuevo;
    }

    public function getDatosAlu() {

        $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
        $parametros['plan'] = kernel::persona()->get_id_plan_activo();
        $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $parametros['_ua'] = $uA;
        $datos = catalogo::consultar('alumno', 'datos_principales', $parametros);
        
        return $datos[0];
    }

    protected function get_data() {
        //ACA OBTENER SI EL ALUMNO ES EGRESADO O NO!!
        if (!isset($this->datos_consulta)) {
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $parametros['_ua'] = $uA;
            $this->datos_consulta = catalogo::consultar('alumno', 'calidad_alumno', $parametros);
        }

        return $this->datos_consulta[0];
    }

    /**
     * Retorna la cantidad de datos
     * @return entero
     */
    protected function get_total_registros() {
        return count($this->get_data_reporte(0, true));
    }

}
