<?php

namespace personalizacionUNL\operaciones\capic;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

class pagelet_reporte2 extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {

    protected $datos_consulta;
    protected $inscripcion;

    public function get_nombre() {
        return 'reporte2';
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
    public function get_data_reporte($pagina = 0, $todo = false) {
        $i = 0;
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();

        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
        $operacion = kernel::ruteador()->get_id_operacion();

        $this->inscripcion['datosComision'] = $this->getDatosComision();
        $this->inscripcion['materia'] = kernel::request()->getPost('cod_materia');
        $this->inscripcion['nombreTitulo'] = utf8_decode('Comisiones habilitadas');
        $this->inscripcion['url'] = kernel::vinculador()->crear($operacion, 'inscribir');
        return $this->inscripcion;
    }

    public function getDatosComision() {

        $materia= kernel::request()->getPost('cod_materia');
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $legajo = kernel::persona()->get_id_legajo_activo();
        $plan = kernel::persona()->get_id_plan_activo();
        $carrera = kernel::persona()->get_id_carrera_activa();
        $objCon = conectar_postgre();
        $statement = pg_prepare($objCon, "sp820_comisionesmat", 'select * from sp_comisionesmat($1,$2,$3,$4,$5)');
        $rsMatInscCursada = pg_execute($objCon,"sp820_comisionesmat",array($uA,$carrera,$plan,$legajo,$materia));
        $arrRegistros =pg_fetch_all($rsMatInscCursada);
        $indices=array('comision','nombre','periodo_lectivo','docente','unidad_academica_destino','nombre_materia_destino','nombre_carrera_destino');
        $arrConvertido=$this->convertUtf8($arrRegistros, $indices);
       
        return $arrConvertido;
    }
    
    protected function convertUtf8($original,$indices ){
        $arrConvertido=array();
        foreach ($original as $key => $value) {
            $arrConvertido[$key][$indices[0]]=$value[$indices[0]];
            $arrConvertido[$key][$indices[1]]= utf8_decode($value[$indices[1]]);
            $arrConvertido[$key][$indices[2]]= utf8_decode($value[$indices[2]]);
            $arrConvertido[$key][$indices[3]]= utf8_decode($value[$indices[3]]);
            $arrConvertido[$key][$indices[4]]= utf8_decode($value[$indices[4]]);
            $arrConvertido[$key][$indices[5]]= utf8_decode($value[$indices[5]]);
            $arrConvertido[$key][$indices[6]]= utf8_decode($value[$indices[6]]);
        }
        return $arrConvertido;
        
    }

    /**
     * Retorna la cantidad de datos
     * @return entero
     */
    protected function get_total_registros() {
        return count($this->get_data_reporte(0, true));
    }

}
