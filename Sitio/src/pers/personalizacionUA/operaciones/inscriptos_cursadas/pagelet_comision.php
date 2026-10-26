<?php

namespace personalizacionUA\operaciones\inscriptos_cursadas;

class pagelet_comision extends \siu\operaciones\inscriptos_cursadas\pagelet_comision {

    public function get_columnas() {
        $titulo = array();
        $titulo['LEGAJO'] = "Legajo";
        $titulo['ALUMNO'] = "Alumno";
        $titulo['EMAIL'] = "Email"; // Personalizacion UNL
        $titulo['CALIDAD'] = "Calidad";
        $titulo['ESTADO'] = "Estado";
        $titulo['CARRERA'] = "Carrera";

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
    public function get_data_reporte($pagina = 0, $todo = false) {
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();
        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
        $datos = $this->controlador->get_info_comision();

        $i = 0;
        $nuevo = array();
        foreach ($datos as $id => $dato) {
            if ($todo or ( $i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)) {
                $nuevo[$i]['LEGAJO'] = $dato['LEGAJO'];
                $nuevo[$i]['ALUMNO'] = $dato['ALUMNO'];
                $nuevo[$i]['EMAIL'] = $dato['EMAIL'];  // Personalizacion UNL
                $nuevo[$i]['CALIDAD'] = $dato['CALIDAD'];
                $nuevo[$i]['ESTADO'] = $dato['ESTADO'];
                $nuevo[$i]['CARRERA'] = $dato['CARRERA'];
                $nuevo[$i]['MATERIA'] = '(' . $dato['MATERIA_COD'] . ') ' . $dato['MATERIA'];
                //$nuevo[$i]['SEDE'] = '('.$dato['SEDE_COD'].') '.$dato['SEDE'];
                $nuevo[$i]['COMISION'] = $dato['COMISION'];
                $nuevo[$i]['SUBCOMISION'] = $dato['SUBCOMISION_NOMBRE'];
                $nuevo[$i]['CATEDRA'] = $dato['CATEDRA'];
                $nuevo[$i]['ANIO'] = $dato['ANIO'];
                $nuevo[$i]['PER_LEC'] = $dato['PER_LEC'];
                $i++;
            }
        }
        return $nuevo;
    }

}
