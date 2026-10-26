<?php

namespace personalizacionUNL\operaciones\capic;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\unidad_academica;

class pagelet_reporte4 extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {

    protected $datos_consulta;
    protected $consulta;

    public function get_nombre() {
        return 'reporte3';
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

        $this->consulta['datosComisionDestino'] = $this->getConsultaInscripto();
        $this->consulta['materia'] = kernel::request()->getPost('cod_materia');
        $this->consulta['cantInscripciones']=0;
        $this->consulta['cantInscripciones']=  count( $this->consulta['datosComisionDestino']);
        $this->consulta['nombreTitulo'] = utf8_decode('Inscripto en las comisiones:');
        $this->consulta['url'] = kernel::vinculador()->crear($operacion, 'darBaja');
        return $this->consulta;
    }

    public function getConsultaInscripto() {

        // creo la conexi�n
        $objCon = conectar_postgre();
        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $parametros['_ua'] = $uA;
        // recupero todas las materias en las que est� inscripto
        $strEstado = "T";  // Puede ser: A:Activa, B:Baja, D:Pendiente, T:Todas
        // recupero las materias en las que el alumno est� inscripto
        $strSQL = "select * from sp_inscCursadas('" . $parametros["_ua"] . "', '" . $parametros["nro_inscripcion"] . "', '" . $strEstado . "')";
        
        $rsInscCurs = pg_Exec($objCon, $strSQL);
        $resultado= pg_fetch_all($rsInscCurs);
        $indices=array('unidad_academica','carrera','carrera_nombre','plan','legajo','materia_nombre_reducido','comision','comision_nombre','unidad_academica_destino','carrera_destino',
            'materia_destino','materia_nombre_reducido_destino','calidad_insc','fecha_insc','periodo_lectivo','anio_academico',
            'nro_transaccion','estado','alumno_nombre','interfase');
        $resulConvertido=$this->convertUtf8($resultado, $indices);
        return $resulConvertido;
        //print_r($resulConvertido);die;
    }

    protected function convertUtf8($original, $indices) {
        $arrConvertido = array();
        
        foreach ($original as $key => $value) {
            $arrConvertido[$key][$indices[0]] = $value[$indices[0]];
            $arrConvertido[$key][$indices[1]] = utf8_decode($value[$indices[1]]);
            $arrConvertido[$key][$indices[2]] = utf8_decode($value[$indices[2]]);
            $arrConvertido[$key][$indices[3]] = utf8_decode($value[$indices[3]]);
            $arrConvertido[$key][$indices[4]] = utf8_decode($value[$indices[4]]);
            $arrConvertido[$key][$indices[5]] = utf8_decode($value[$indices[5]]);
            $arrConvertido[$key][$indices[6]] = utf8_decode($value[$indices[6]]);
            $arrConvertido[$key][$indices[7]] = utf8_decode($value[$indices[7]]);
            $arrConvertido[$key][$indices[8]] = utf8_decode($value[$indices[8]]);
            $arrConvertido[$key][$indices[9]] = utf8_decode($value[$indices[9]]);
            $arrConvertido[$key][$indices[10]] = utf8_decode($value[$indices[10]]);
            $arrConvertido[$key][$indices[11]] = utf8_decode($value[$indices[11]]);
            $arrConvertido[$key][$indices[12]] = utf8_decode($value[$indices[12]]);
            $arrConvertido[$key][$indices[13]] = utf8_decode($value[$indices[13]]);
            $arrConvertido[$key][$indices[14]] = utf8_decode($value[$indices[14]]);
            $arrConvertido[$key][$indices[15]] = utf8_decode($value[$indices[15]]);
            $arrConvertido[$key][$indices[16]] = utf8_decode($value[$indices[16]]);
            $arrConvertido[$key][$indices[17]] = utf8_decode($value[$indices[17]]);
            $arrConvertido[$key][$indices[18]] = utf8_decode($value[$indices[18]]);
            $arrConvertido[$key][$indices[19]] = utf8_decode($value[$indices[19]]);
            $arrConvertido[$key][$indices[20]] = utf8_decode($value[$indices[20]]);
           
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
