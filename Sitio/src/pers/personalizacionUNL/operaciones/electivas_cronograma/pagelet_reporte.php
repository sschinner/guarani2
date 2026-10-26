<?php

namespace personalizacionUNL\operaciones\electivas_cronograma;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

require_once '../../../clientes_ws/electivas/clientews.php';

use ClienteElectivas;

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

    /**
     * Recupera los datos
     * @param entero $pagina
     * Numero de p�gina que se desea recuperar
     * @param buleano $todo
     * Recuperar todos los datos
     * @return array
     */
    public function prepare() {
        $pagina = $this->get_pagina();

        $operacion = kernel::ruteador()->get_id_operacion();
        $this->data['url_atributos'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina' => $pagina));


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
      
    }

    
    public function getDatos(){
        
        $operacion = kernel::ruteador()->get_id_operacion();
        $datos = $this->get_data();
        $control = $this->get_control_reinscripcion();
        $this->nuevo['datosAlu'] = $this->getDatosAluElectiva();
        $datosWS = $this->cargarDatosWSElectivas($this->nuevo['datosAlu']);
       
        $this->nuevo['control'] = $control[0];
        $this->nuevo['calidad'] = $datos[0];
        $claseElectivas = new ClienteElectivas();
        
        $resultado = $claseElectivas->getToken($datosWS);
       
        $this->nuevo['url_electivas_cronograma'] = $claseElectivas->getUrlConsulta().$resultado;
        $this->nuevo['url_electivas_inscripcion'] = $claseElectivas->getUrlInscripcion().$resultado;
        $this->nuevo['url_electivas_consultar'] = $claseElectivas->getUrlConsultaInscripto().$resultado;
        $this->nuevo['nombreTitulo'] = utf8_decode('Electivas: oferta de asignaturas electivas');
       
        return $this->nuevo;
        
    }

    public function getDatosAluElectiva() {

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
        
        $datos = catalogo::consultar('alumno', 'datos_para_electivas', $parametros);

        return $datos[0];
    }

    protected function get_data() {
        //ACA OBTENER SI EL ALUMNO ES Activo O NO!!
        if (!isset($this->datos_consulta)) {
            $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
            $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $parametros['_ua'] = $uA;
            $this->datos_consulta = catalogo::consultar('alumno', 'calidad_activo_regular', $parametros);
        }

        return $this->datos_consulta[0];
    }

    protected function get_control_reinscripcion() {
        $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $parametros['_ua'] = $uA;
        $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
        $parametros['anio'] = date('Y');
        $datos = catalogo::consultar('alumno', 'control_para_electivas', $parametros);

        return $datos[0];
    }

    /**
     * Retorna la cantidad de datos
     * @return entero
     */
    protected function get_total_registros() {
        return count($this->get_data_reporte(0, true));
    }

    public function cargarDatosWSElectivas($datos) {
      
        $datosWs = new \StdClass();
        $datosWs->materiasCarrera = $datos[4];
        $datosWs->materiasAprobadas = $datos[5];
        $datosWs->avanceCarrera = bcdiv(($datos[5] / $datos[4])*100,'1',2);
        $datosWs->nombre = utf8_encode($datos[7]);
        $datosWs->apellido = utf8_encode($datos[6]);
        $datosWs->tipoDocumento = $datos[0];
        $datosWs->paisDocumento = $datos[8];
        $datosWs->numeroDocumento = $datos[1];
        $datosWs->unidadAcademica = guarani::ua()->get_id();
        $datosWs->carrera = $datos[9];
        return $datosWs;
    }

    
/* Casos de prueba fich
43633097
40826625
42871224
38819193
43164897
43425159
32140810
43958914
41733379
     *      */
}
