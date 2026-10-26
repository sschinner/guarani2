<?php

namespace personalizacionCEMED\operaciones\pasantia;

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

        $this->inscripcion['datosIns'] = $this->getPasantiaIncripto();
        $this->inscripcion['cantRegistros'] = count($this->inscripcion['datosIns']);
        $this->inscripcion['nombreTitulo'] = utf8_decode('Pasantías en la que estoy inscripto');
        $this->inscripcion['url'] = kernel::vinculador()->crear($operacion, 'baja');
        return $this->inscripcion;
    }

    public function getPasantiaIncripto() {

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $u = new unidad_academica(\siu\guarani::get_ua_id());
        $uA = utf8_encode($u->get_id());
        $parametros['_ua'] = $uA;

        $datos = catalogo::consultar('alumno', 'pasantias_inscripto', $parametros);

        return $datos;
    }

    /**
     * Retorna la cantidad de datos
     * @return entero
     */
    protected function get_total_registros() {
        return count($this->get_data_reporte(0, true));
    }

}
