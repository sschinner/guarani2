<?php

class Redecode {

    public function recodeSit_laboral($sit_laboral) { //Verificado
        switch ($sit_laboral) {
            case "1": $resultado = "3";
                break;
            case "2": $resultado = "2";
                break;
            case "3": $resultado = "4";
                break;
            case "4": $resultado = "3";
                break;
            case "5": $resultado = "1";
                break;
            case "6": $resultado = "1";
                break;
            case "7": $resultado = "4";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodeEstadoCivil($estadoCivil) {  //Verificado
        switch ($estadoCivil) {
            case "1": $resultado = (int) "1";
                break;
            case "2": $resultado = (int) "2";
                break;
            case "3": $resultado = (int) "5";
                break;
            case "4": $resultado = (int) "3";
                break;
            case "5": $resultado = (int) "4";
                break;
            case "6": $resultado = (int) "6";
                break;
            case "''": $resultado = "''";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodeCateg_ocup($categ_ocup) { //Verificado
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.jerarquia_ocup_alumno
        switch ($categ_ocup) {
			case "1": $resultado = "1";
				break;
            case "2": $resultado = "1";
				break;
			case "3": $resultado = "2";
				break;
            case "4": $resultado = "2";
				break;
            case "5": $resultado = "3";
				break;
			case NULL: $resultado = NULL;
				break;
            default: $resultado = "3";
		}
        return $resultado;
    }

    public function recodeAct_econom($act_econom) {
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.rama_act_eco_alumno

        switch ($act_econom) {
            case "1": $resultado = "Agricultura, Ganadería y Minería";
                break;
            case "2": $resultado = "Comercio";
                break;
            case "3": $resultado = "Industria y Construcción";
                break;
            case "4": $resultado = "Servicios sociales y de salud";
                break;
            case "5": $resultado = "Ocupaciones varias";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodedet_rama_act($det_rama_act) {
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.act_economica_alumno

        switch ($det_rama_act) {
            case "1": $resultado = "Administrativas, en planificación o informática";
                break;
            case "2": $resultado = "Agropecuario, forestales, pesca y caza";
                break;
            case "3": $resultado = "Comerciales, de transporte, almacenaje o telecomunicaciones";
                break;
            case "4": $resultado = "Contables, financieras o presupuestarias";
                break;
            case "5": $resultado = "En producción de energia, agua potable, gas, extracción de minerales, construcción o infraestructura";
                break;
            case "6": $resultado = "Otras";
                break;
            case NULL: $resultado = NULL;
                break;
            default: $resultado = "Indeterminado";
        }
        return $resultado;
    }

    public function recodeHora_sem_trab($cant_horas_sem_trab) {
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.horas_trabaja_alumno
//La recodificación para guaraní se toma de la DW d_datos_censales_economicos: hora_sem_trab_alum

        switch ($cant_horas_sem_trab) {
            case ($cant_horas_sem_trab <= 10): $resultado = "1";
                break;
            case ($cant_horas_sem_trab > 10 && $cant_horas_sem_trab <= 20): $resultado = "2";
                break;
            case ($cant_horas_sem_trab > 20 && $cant_horas_sem_trab < 35): $resultado = "3";
                break;
            case ($cant_horas_sem_trab >= 35): $resultado = "4";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodeUlt_est($ult_est) {

        switch ($ult_est) {
            case "1": $resultado = "1";
                break;
            case "2": $resultado = "2";
                break;
            case "3": $resultado = "3";
                break;
            case "4": $resultado = "4";
                break;
            case "5": $resultado = "5";
                break;
            case "6": $resultado = "10";
                break;
            case "7": $resultado = "11";
                break;
            case "8": $resultado = "12";
                break;
            case "9": $resultado = "14";
                break;
            case "10": $resultado = "13";
                break;
            case "11": $resultado = "15";
                break;
            case "NULL": $resultado = NULL;
                break;
            default: $resultado = "13";
        }
        return $resultado;
    }

    public function recodeDis_acc($discapacidad_accesibilidad) {
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: persona.discapacidad_accesibilidad

        switch ($discapacidad_accesibilidad) {
            case "1": $resultado = "3";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodeDis_com($discapacidad_comunicacional) {
//Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: persona.discapacidad_comunicacional

        switch ($discapacidad_comunicacional) {
            case "0": $resultado = NULL;
                break;
            case "1": $resultado = "8";
                break;
            case "2": $resultado = "8";
                break;
            case "3": $resultado = "6";
                break;
            case "4": $resultado = "11";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    public function recodeNacionalidad($nacionalidad) {

        switch ($nacionalidad) {
            case "54": $resultado = '1';
                break;
            default: $resultado = '2';
        }
        return $resultado;
    }

    public function recodePadresViven($padres_viven) {

        switch ($padres_viven) {
            case "S": $resultado = 'V';
                break;
            case "N": $resultado = 'N';
                break;
            default: $resultado = 'D';
        }
        return $resultado;
    }

    public function recodeColeSecundario($colegio) {

        if (trim($colegio) == "") {
            $colegio = NULL;
        }
        return $colegio;
    }

    public function recodeCUILExt($nroDocumento, $pais, $cuil) {

        if ($pais != 54) {
            $cuil = $nroDocumento;
        }
        return $cuil;
    }

}
