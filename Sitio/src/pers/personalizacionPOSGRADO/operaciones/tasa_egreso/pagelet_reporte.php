<?php

namespace personalizacionPOSGRADO\operaciones\tasa_egreso;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {

        protected $datos_consulta;
	protected $nuevo;

        public function get_nombre(){
		return 'reporte';
	}

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());
	
	}

	public function get_columnas(){
		$titulos = array();
		
		return $titulos;
	}

	/**
	 * Recupera los datos
	 * @param entero $pagina
	 * Numero de p�gina que se desea recuperar
	 * @param buleano $todo
	 * Recuperar todos los datos
	 * @return array
	 */
	public function get_data_reporte($pagina = 0, $todo = false){
		$i=0;
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();

		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;
                $operacion = kernel::ruteador()->get_id_operacion();
		$datos = $this->get_data();
              	
                $datosAlu= $this->getDatosAlu();	
		
                $this->nuevo['calidad'] = $datos[0];
                
                $u= new unidad_academica(\siu\guarani::get_ua_id());
                $nombreUA= utf8_encode($u->get_nombre());
                
                $arrCarrera=(kernel::persona()->get_info_carrera_activa());
                $nombreCarrera = utf8_encode($arrCarrera['nombre']);
                $meses = array("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
                
                $this->nuevo['parrafo1'] = utf8_decode(ucwords(strtolower($datosAlu['4'])).', '.ucwords(strtolower($datosAlu['5'])).' '.$datosAlu['2'].': '.$datosAlu['3'].', alumno de la carrera de '.$nombreCarrera.', '.$nombreUA.', Universidad Nacional del Litoral, solicita el pago de la tasa por servicios administrativos para la expedición de diploma de egresado.');
                $this->nuevo['parrafo2'] =utf8_decode('Extendido en la ciudad de Santa Fe, Pcia. de Santa Fe, Argentina, a los '.date('j').' Días del mes de '.$meses[date('n')-1].' de '.date('Y').'.-');
                return $this->nuevo;
	}
        
        public function getDatosAlu(){
                    
                    $parametros['identificacion'] = kernel::persona()->get_identificacion();
                    $u= new unidad_academica(\siu\guarani::get_ua_id());
                    $uA= utf8_encode($u->get_id());
                    $parametros['_ua']=$uA;
                    $datos = catalogo::consultar('alumno', 'datos_alumno_ag', $parametros);
	                
              return $datos[0];
        }

        protected function get_data(){
            //ACA OBTENER SI EL ALUMNO ES EGRESADO O NO!!
		if (!isset($this->datos_consulta)) {
                    $parametros['carrera']=kernel::persona()->get_id_carrera_activa();
                    $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                    $u= new unidad_academica(\siu\guarani::get_ua_id());
                    $uA= utf8_encode($u->get_id());
                    $parametros['_ua']=$uA;
                    $this->datos_consulta = catalogo::consultar('alumno', 'calidad_alumno', $parametros);
		}
                
              return $this->datos_consulta[0];
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}


}
