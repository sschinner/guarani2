<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase?a invalidas.
  '2': Error de parametros - Algun campo es vacio o erroneo.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
require_once ('Repositorio/Redecode.php');

//require_once("adodb/adodb.inc.php");

Class RetornoIUDatosCensales {
    /* --------- variables datosAcademicosCompletos---------- */

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno = -1;
    public $mensajeRetorno;

    function getCodigoWS() {
        return $this->codigoWS;
    }

    function getCodigoRetorno() {
        return $this->codigoRetorno;
    }

    function setCodigoWS($codigoWS) {
        $this->codigoWS = (int) $codigoWS;
    }

    function setMensajeWS($mensajeWS) {
        $this->mensajeWS = (string) $mensajeWS;
    }

    function setCodigoRetorno($codigoRetorno) {
        $this->codigoRetorno = (int)$codigoRetorno;
    }

    function setMensajeRetorno($mensajeRetorno) {
        $this->mensajeRetorno = (string) $mensajeRetorno;
    }

}

Class RecodeInsertaDatosCensales {

    function recodeSit_laboral($sit_laboral) {

        switch ($sit_laboral) {
            case "1": $resultado = "5";
                break;
            case "2": $resultado = "1";
                break;
            case "4": $resultado = "6";
                break;
            case "5": $resultado = "3";
                break;
            case "6": $resultado = "2";
                break;
            case "7": $resultado = "7";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    function recodeCateg_ocup($categ_ocup) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.jerarquia_ocup_alumno 
        switch ($categ_ocup) {
            case "1": $resultado = "6";
                break;
            case "2": $resultado = "4";
                break;
            case "3": $resultado = "7";
                break;
            case "4": $resultado = "21";
                break;
            case "5": $resultado = "4";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    function recodeAct_econom($act_econom) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.rama_act_eco_alumno
        switch ($act_econom) {
            case "1": $resultado = "1";
                break;
            case "2": $resultado = "3";
                break;
            case "3": $resultado = "2";
                break;
            case "4": $resultado = "18";
                break;
            case "5": $resultado = "13";
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    function recodedet_rama_act($det_rama_act) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.act_economica_alumno
        switch ($det_rama_act) {
            case "1": $resultado = "1";
                break;
            case "2": $resultado = "6";
                break;
            case "3": $resultado = "3";
                break;
            case "4": $resultado = "2";
                break;
            case "5": $resultado = "7";
                break;
            case "6": $resultado = "9";
                break;
            case ($det_rama_act == "NULL" || $det_rama_act == NULL): $resultado = NULL;
                break;
            default: $resultado = NULL;
        }
        return $resultado;
    }

    function recodeHora_sem_trab($cant_horas_sem_trab) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: datos_censales.horas_trabaja_alumno
        //La recodificación para guaraní se toma de la DW d_datos_censales_economicos: hora_sem_trab_alum
        switch ($cant_horas_sem_trab) {
            case ($cant_horas_sem_trab == 'NULL' || $cant_horas_sem_trab == NULL): $resultado = "NULL";
                break;
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

    function recodeUlt_est($ult_est) {
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
            default: $resultado = "13";
        }
        return $resultado;
    }

    function recodeDis_acc($discapacidad_accesibilidad) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: persona.discapacidad_accesibilidad
        switch ($discapacidad_accesibilidad) {
            case ($discapacidad_accesibilidad == 'NULL'): $resultado = "NULL";
                break;
            case "1": $resultado = "S";
                break;
            case "0": $resultado = "N";
                break;
            default: $resultado = "N";
        }
        return $resultado;
    }

    function recodeDis_com($discapacidad_comunicacional) {
        //Recodificación según codigos de Ingreso UNL: atención, este campo debe provenir de la siguiente tabla de Ingreso: persona.discapacidad_comunicacional
        switch ($discapacidad_comunicacional) {
            case ($discapacidad_comunicacional == 'NULL'): $resultado = "NULL";
                break;
            case "0": $resultado = "1";
                break;
            case "1": $resultado = "3";
                break;
            case "2": $resultado = "4";
                break;
            case "3": $resultado = "5";
                break;
            case "4": $resultado = "6";
                break;
            default: $resultado = "2";
        }
        return $resultado;
    }

}

/* ---------------------------------------------------------------------------------------------
  FUNCION PARA LA INSECION O ACTUALIZACION DE LOS DATOS CENSALES DEL ALUMNO
  ---------------------------------------------------------------------------------------------- */

Class IUDatosCensales {

    function setDatosCensales($nroDocumento, $tipoDoc, $paisDoc, $fecha_ingreso_pais, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $nivel_otros_estud, $localidad_nacimiento, $nacionalidad,$colegio_secundario, $credenciales) {
		$instancia = '';
        $datosCenasales = new RetornoIUDatosCensales();
        $dat = new BuildArray();


        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'siguv', 'gea');

        //$aut = Generales::autenticar();
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosCenasales->setCodigoWS(CODIGO_ERROR_AUTENTICACION);
            $datosCenasales->setMensajeWS(MENSAJE_ERROR_AUTENTICACION);
            $retorno = $datosCenasales;
            unset($datosCenasales);
            return $retorno;
        } else {
            if ($tipoDoc == "" || $nroDocumento == "" || $paisDoc == "") {
                $datosCenasales->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $datosCenasales->setMensajeWS(MENSAJE_ERROR_PARAMETROS);
                return $datosCenasales;
            }
           
            if ($fecha_ingreso_pais != NULL && trim($fecha_ingreso_pais) != "''" 
                    && !Generales::validar_formato_fecha($fecha_ingreso_pais) && strtoupper($fecha_ingreso_pais) != "NULL" ){ 
                $datosCenasales->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $datosCenasales->setMensajeWS(utf8_encode('Par�metro inv�lido - Par�metro fecha_ingreso_pais no posee formato correcto'));
                return $datosCenasales;
            }  
            
            if($nacionalidad == "''"){
                $datosCenasales->setCodigoWS(CODIGO_ERROR_PARAMETROS);
                $datosCenasales->setMensajeWS(utf8_encode('Par�metro inv�lido - Par�metro nacionalidad no puede pasar a NULL'));
                return $datosCenasales;
            }
           
            $titulo = '';

            $ua = array('cemed_fadu', 'guarani3_');

            for ($j = 0; $j < count($ua); $j++) {
                $resultado = '';
                $esCemed = explode('_', $ua[$j]);

                if ($esCemed[0] == 'guarani3') {
                    $titulo = '7';

                    $objCC = Generales::conectar($ua[$j]);
                } else {
                    $titulo = '0';

                    $objCC = Generales::conectar($ua[$j]);
                   
                    switch ($estado_civil) {
                        case "1": $estado_civil = "1";
                            break;
                        case "2": $estado_civil = "2";
                            break;
                        case "3": $estado_civil = "5";
                            break;
                        case "4": $estado_civil = "3";
                            break;
                        case "5": $estado_civil = "4";
                            break;
                        case "6": $estado_civil = "6";
                            break;
                        case "''": $estado_civil = '';
                            break;
                        default: $estado_civil = NULL;
                    }
                }

                if ($objCC == 3) {
                    $datosCenasales->setCodigoWS(CODIGO_ERROR_CONEXION);
                    $datosCenasales->setMensajeWS(MENSAJE_ERROR_CONEXION);
		    $datosCenasales->setMensajeRetorno( $ua[$j] . " Problemas para conectar - Consulte con el administrador");
		    return $datosCenasales; 
                } else if ($titulo != '7') {

                    /*
                     * inicializacion del SET
                     */
                    $set_sga_datos_censales = $set_sga_datos_censales_aux = $set_sga_820_datos_censales_aux = $set_sga_personas = " SET ";
                    $longInicial = strlen($set_sga_datos_censales);

                    /* Armado del SET para sga_datos_censales
                     */
                    $sgaDatosCensales = $dat->sgaDatosCensales($estado_civil, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre);
                   
                    foreach ($sgaDatosCensales as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL') {
                            $set_sga_datos_censales .= ($valor != "''")?" $clave = '$valor', ":" $clave = $valor, ";
                        }
                    }

                    if (strlen($set_sga_datos_censales) != $longInicial) {
                        $set_sga_datos_censales = substr($set_sga_datos_censales, 0, -2);
                    } else {
                        $set_sga_datos_censales = '';
                    }
                    //return $set_sga_datos_censales;
                    /* ------------------------------------------------------------- */
                    /*
                     * Armado del SET para sga_datos_censales_aux
                     */
                    $sgaDatosCensalesAux = $dat->sgaDatosCensalesAux($padre_vive, $madre_vive, $sit_laboral_alumno);
                    foreach ($sgaDatosCensalesAux as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL') {
                            $set_sga_datos_censales_aux .=  ($valor != "''")?" $clave = '$valor', ":" $clave = $valor, ";
                        }
                    }

                    if (strlen($set_sga_datos_censales_aux) != $longInicial) {
                        $set_sga_datos_censales_aux = substr($set_sga_datos_censales_aux, 0, -2);
                    } else {
                        $set_sga_datos_censales_aux = '';
                    }
                    /* ------------------------------------------------------------- */
                    /*
                     * Armado del SET para sga_820_datos_censales_aux
                     */
                    $sga820DatosCensalesAux = $dat->sga820DatosCensalesAux($alu_req_acces_fisica, $alu_req_acces_com, $cant_horas_sem_trab_alum);
                    foreach ($sga820DatosCensalesAux as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL') {
                            $set_sga_820_datos_censales_aux .=  ($valor != "''")?" $clave = '$valor', ":" $clave = $valor, ";
                        }
                    }

                    if (strlen($set_sga_820_datos_censales_aux) != $longInicial) {
                        $set_sga_820_datos_censales_aux = substr($set_sga_820_datos_censales_aux, 0, -2);
                    } else {
                        $set_sga_820_datos_censales_aux = '';
                    }
                    /* ------------------------------------------------------------- */
                    /*
                     * 
                     * Armado del SET para sga_personas
                     */
                    $sgaPersonas = $dat->sgaPersonas($apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $fecha_ingreso_pais, $localidad_nacimiento, $nacionalidad,$colegio_secundario);
                    
                    foreach ($sgaPersonas as $clave => $valor) {
                       
                        if (!is_null($valor) && strtoupper($valor) != 'NULL') {
                            $set_sga_personas .=  ($valor != "''")?" $clave = '$valor', ":" $clave = $valor, ";
                        }
                    }

                    if (strlen($set_sga_personas) != $longInicial) {
                        $set_sga_personas = substr($set_sga_personas, 0, -2);
                    } else {
                        $set_sga_personas = '';
                    }
                    /* -------------------------------------** FIN ARMADO DE SET PARA G2 **---------------- */


                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $instancia = 'g2';
                    $strSQL = 'execute procedure dba.sincroniza_datos_censales_alumno("' . $paisDoc . '","' . $tipoDoc . '","' . $nroDocumento . '","' . $set_sga_datos_censales . '","' . $set_sga_datos_censales_aux . '","' . $set_sga_820_datos_censales_aux . '","' . $set_sga_personas . '");';
                 
                    $res = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($res && ($res->RecordCount() > 0)) {
                        $resultado = $res->getRows();                      
                        if ($resultado) {
                            $datosCenasales->setCodigoWS(CODIGO_OK);
                            $datosCenasales->setMensajeWS(MENSAJE_OK);
                            foreach ($resultado as $resu) {
                                if ($datosCenasales->getCodigoRetorno() != 0) {
                                    $datosCenasales->setCodigoRetorno($resu[0]);
                                    $datosCenasales->setMensajeRetorno(trim($resu[1]));
                                }
                            }
                        }
                    }                  
                } else {
                    $instancia = '';

                    $deco = new Redecode();
                    $set_mdp_datos_personales = $set_mdp_datos_economicos = $set_mdp_personas_allegados_madre = $set_mdp_personas_allegados_padre = $set_mdp_personas = " SET ";
                    /*
                     *  Armado del SET para mdpDatosPersonales
                     */
                    $longInicial = strlen($set_mdp_datos_personales);
                    $mdpDatosPersonales = $dat->mdpDatosPersonales($estado_civil, $padre_vive, $madre_vive, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $fecha_ingreso_pais);
                   
                    foreach ($mdpDatosPersonales as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL' && !empty($valor) && $valor != "''") {
                           
                            $set_mdp_datos_personales .= " $clave =  '$valor', ";
                        } else if (!is_null($valor) &&  $valor == "''" ) {
                            
                            $set_mdp_datos_personales .= " $clave = null, ";
                        } 
                    }

                    if (strlen($set_mdp_datos_personales) != $longInicial) {
                        $set_mdp_datos_personales = substr($set_mdp_datos_personales, 0, -2);
                    } else {
                        $set_mdp_datos_personales = '';
                    }
                    
                    /* ------------------------------------------------------------- */

                    /*
                     * Armado del SET para mdpDatosEconomicos
                     */
                    $insert_mdp_datos_economicos = "INSERT INTO mdp_datos_economicos (dato_censal,beca, beca_fuente_universidad, beca_fuente_nacional, beca_fuente_provincial, beca_fuente_municipal, beca_fuente_internacional, beca_fuente_otra, beca_tipo_economica, beca_tipo_servicios, beca_tipo_investigacion, beca_economica_transporte,beca_economica_efectivo, beca_economica_fotocopias,beca_economica_habitacional, beca_economica_comedor ,";
                    $values_mdp_datos_economicos = " 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N' ,";
                    $longInicialInsert = strlen($values_mdp_datos_economicos);
                    $mdpDatosEconomicos = $dat->mdpDatosEconomicos($sit_laboral_alumno, $categ_ocup_alum, $cant_horas_sem_trab_alum, $det_rama_act_alum);
                   
                    foreach ($mdpDatosEconomicos as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL' && !empty($valor)) {

                            $set_mdp_datos_economicos .= " $clave = '$valor', ";

                            $insert_mdp_datos_economicos .= " $clave ,";
                            $values_mdp_datos_economicos .= " '$valor' , ";
                        } else if (!is_null($valor) &&  $valor == "''" ) {
                            $set_mdp_datos_economicos .= " $clave = null, ";

                            $insert_mdp_datos_economicos .= " $clave ,";
                            $values_mdp_datos_economicos .= " null, ";
                        }
                    }

                    if (strlen($set_mdp_datos_economicos) != $longInicial) {
                        $set_mdp_datos_economicos = substr($set_mdp_datos_economicos, 0, -2);
                    } else {
                        $set_mdp_datos_economicos = '';
                    }

                    if (strlen($values_mdp_datos_economicos) != $longInicialInsert) {
                        $insert_mdp_datos_economicos = substr($insert_mdp_datos_economicos, 0, -2) . ")";
                        $values_mdp_datos_economicos = substr($values_mdp_datos_economicos, 0, -2) . ");";
                    }

                    /* ------------------------------------------------------------- */
                    /*
                     *  Armado del SET para mdpPersonasAllegadosPadre
                     */
                    $insert_personas_allegados_padre = "INSERT INTO mdp_personas_allegados(dato_censal, tipo_allegado , ";
                    $values_personas_allegados_padre = ", 'P' ,";
                    $longInicialInsert = strlen($values_personas_allegados_padre);
                    $mdpPersonasAllegadosPadre = $dat->mdpPersonasAllegadosPadre($sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre);

                    foreach ($mdpPersonasAllegadosPadre as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL' && !empty($valor)) {

                            $set_mdp_personas_allegados_padre .= " $clave = '$valor', ";

                            $insert_personas_allegados_padre .= " $clave ,";
                            $values_personas_allegados_padre .= " '$valor' , ";
                        } else if (!is_null($valor) &&  $valor == "''" ) {
                            $set_mdp_personas_allegados_padre .= " $clave = null, ";

                            $insert_personas_allegados_padre .= " $clave ,";
                            $values_personas_allegados_padre .= " null, ";
                        }
                    }

                    if (strlen($set_mdp_personas_allegados_padre) != $longInicial) {
                        $set_mdp_personas_allegados_padre = substr($set_mdp_personas_allegados_padre, 0, -2);
                    } else {
                        $set_mdp_personas_allegados_padre = '';
                    }

                    if (strlen($values_personas_allegados_padre) != $longInicialInsert) {
                        $insert_personas_allegados_padre = substr($insert_personas_allegados_padre, 0, -2) . ")";
                        $values_personas_allegados_padre = substr($values_personas_allegados_padre, 0, -2) . ");";
                    }

                    /* ------------------------------------------------------------- */
                    /*
                     *  Armado del SET para mdpPersonasAllegadosMadre
                     */
                    $insert_personas_allegados_madre = "INSERT INTO mdp_personas_allegados(dato_censal, tipo_allegado , ";
                    $values_personas_allegados_madre = ", 'M' ,";
                    $longInicialInsert = strlen($values_personas_allegados_madre);
                    $mdpPersonasAllegadosMadre = $dat->mdpPersonasAllegadosMadre($sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre);
                    foreach ($mdpPersonasAllegadosMadre as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL' && !empty($valor)) {

                            $set_mdp_personas_allegados_madre .= " $clave = '$valor', ";

                            $insert_personas_allegados_madre .= " $clave ,";
                            $values_personas_allegados_madre .= " '$valor' , ";
                        } else if (!is_null($valor) &&  $valor == "''" ) {
                            $set_mdp_personas_allegados_madre .= " $clave = null, ";

                            $insert_personas_allegados_madre .= " $clave ,";
                            $values_personas_allegados_madre .= " null, ";
                        }
                    }

                    if (strlen($set_mdp_personas_allegados_madre) != $longInicial) {
                        $set_mdp_personas_allegados_madre = substr($set_mdp_personas_allegados_madre, 0, -2);
                    } else {
                        $set_mdp_personas_allegados_madre = '';
                    }

                    if (strlen($values_personas_allegados_madre) != $longInicialInsert) {
                        $insert_personas_allegados_madre = substr($insert_personas_allegados_madre, 0, -2) . ")";
                        $values_personas_allegados_madre = substr($values_personas_allegados_madre, 0, -2) . ");";
                    }
                    /* ------------------------------------------------------------- */
                    /*
                     *  Armado del SET para mdpPersonas
                     */

                    $mdpPersonas = $dat->mdpPersonas($nacionalidad, $localidad_nacimiento);
                    //
                    foreach ($mdpPersonas as $clave => $valor) {
                        if (!is_null($valor) && strtoupper($valor) != 'NULL' && !empty($valor)) {

                            $set_mdp_personas .= " $clave =  '$valor', ";
                        } else if (!is_null($valor) &&  $valor == "''" ) {
                            $set_mdp_personas .= " $clave = null, ";
                        }
                    }

                    if (strlen($set_mdp_personas) != $longInicial) {
                        $set_mdp_personas = substr($set_mdp_personas, 0, -2);
                    } else {
                        $set_mdp_personas = '';
                    }
                    /* ------------------------------------------------------------- */


                    $nivel_otros_estud = (strtoupper($nivel_otros_estud) == 'NULL') ? NULL : $nivel_otros_estud;

                    $te_per_lect = (strtoupper($te_per_lect) == 'NULL') ? NULL : $te_per_lect;
                    $otros_estud_super = is_null($otros_estud_super) ? $otros_estud_super : mb_convert_encoding($otros_estud_super,'UTF-8');
                    $te_proc = (strtoupper($te_proc) == 'NULL') ? NULL : $te_proc;


                    if (strtoupper($fecha_ingreso_pais) == 'NULL' || is_null($fecha_ingreso_pais)){
                            $fecha_ingreso_pais = NULL;
                    }else if ($fecha_ingreso_pais != "''"){
                            $fecha_ingreso_pais = Generales::formato_fecha_g3($fecha_ingreso_pais);
                    }else {
                         $fecha_ingreso_pais = "";
                    }
                    $colegio_secundario = (strtoupper($colegio_secundario) == 'NULL') ? NULL : $colegio_secundario;
                    
                    $datosCenasales->setCodigoWS(CODIGO_OK);
                    $datosCenasales->setMensajeWS(MENSAJE_OK);
                    $rep = new RepositorioWS();
                    $resultado = $rep->actualizaDatosCensales($nroDocumento, $tipoDoc, $paisDoc, $set_mdp_datos_personales, $set_mdp_datos_economicos, $set_mdp_personas_allegados_padre, $set_mdp_personas_allegados_madre, $insert_mdp_datos_economicos, $values_mdp_datos_economicos, $insert_personas_allegados_padre, $values_personas_allegados_padre, $insert_personas_allegados_madre, $values_personas_allegados_madre, $te_per_lect, $te_proc, $deco->recodeDis_acc($alu_req_acces_fisica), $deco->recodeDis_com($alu_req_acces_com), $otros_estud_super, $nivel_otros_estud, $fecha_ingreso_pais, $set_mdp_personas,$colegio_secundario, $objCC);
                    
                    if ($resultado) {
                        foreach ($resultado as $resu) {

                            if ($datosCenasales->getCodigoRetorno() != 0) {
                                $datosCenasales->setCodigoRetorno($resu['istatus']);
                                $datosCenasales->setMensajeRetorno(trim($resu['vcmsg']));
                            }
                        }
                        $retorno = $datosCenasales;
                        unset($datosCenasales);
                        return $retorno;
                    }
                }
            }
        }

        if ($datosCenasales->getCodigoWS() !== 0) {
            $datosCenasales->setCodigoWS(CODIGO_ERROR_PROCEDIMIENTO);
            $datosCenasales->setMensajeWS(MENSAJE_ERROR_PROCEDIMIENTO);

            $retorno = $datosCenasales;
            unset($datosCenasales);
            return $retorno;
        }
    }

}

function insertaDatosCensales(
		$nroDocumento
		, $tipoDoc
		, $paisDoc
		, $fecha_ingreso_pais = NULL
		, $apellido_padre = NULL
		, $apellido_madre = NULL
		, $pais_emisor_pasap = NULL
		, $nro_pasap = NULL
		, $estado_civil = NULL
		, $calle_per_lect = NULL
		, $numero_per_lect = NULL
		, $piso_per_lect = NULL
		, $dpto_per_lect = NULL
		, $unidad_per_lect = NULL
		, $loc_per_lect = NULL
		, $cp_per_lect = NULL
		, $te_per_lect = NULL
		, $calle_proc = NULL
		, $numero_proc = NULL
		, $piso_proc = NULL
		, $dpto_proc = NULL
		, $unidad_proc = NULL
		, $loc_proc = NULL
		, $cp_proc = NULL
		, $te_proc = NULL
		, $otros_estud_super = NULL
		, $padre_vive = NULL
		, $madre_vive = NULL
		, $sit_laboral_alumno = NULL
		, $categ_ocup_alum = NULL
		, $act_econom_alum = NULL
		, $det_rama_act_alum = NULL
		, $cant_horas_sem_trab_alum = NULL
		, $sit_laboral_padre = NULL
		, $ult_est_padre = NULL
		, $act_econom_padre = NULL
		, $det_rama_act_padre = NULL
		, $sit_laboral_madre = NULL
		, $ult_est_madre = NULL
		, $act_econom_madre = NULL
		, $det_rama_act_madre = NULL
		, $alu_req_acces_fisica = NULL
		, $alu_req_acces_com = NULL
		, $nivel_otros_estud = NULL
		, $localidad_nacimiento = NULL
		, $nacionalidad = NULL
		, $colegio_secundario = NULL) { //47 parametros
    $servicio = new IUDatosCensales();
    $credenciales = new Credenciales();

    $fecha_ingreso_pais = ($fecha_ingreso_pais == NULL  ||  strtoupper($fecha_ingreso_pais) == "NULL" ) ? NULL : $fecha_ingreso_pais;
    $apellido_padre = ($apellido_padre == NULL  ||  strtoupper($apellido_padre) == "NULL" ) ? NULL : $apellido_padre;
    $apellido_madre = ($apellido_madre == NULL  ||  strtoupper($apellido_madre) == "NULL" ) ? NULL : $apellido_madre;
    $pais_emisor_pasap = ($pais_emisor_pasap == NULL  ||  strtoupper($pais_emisor_pasap) == "NULL" ) ? NULL : $pais_emisor_pasap;
    $nro_pasap = ($nro_pasap == NULL  ||  strtoupper($nro_pasap) == "NULL" ) ? NULL : $nro_pasap;
    $estado_civil = ($estado_civil == NULL  ||  strtoupper($estado_civil) == "NULL" ) ? NULL : $estado_civil;
    $calle_per_lect = ($calle_per_lect == NULL  ||  strtoupper($calle_per_lect) == "NULL" ) ? NULL : $calle_per_lect;
    $numero_per_lect = ($numero_per_lect == NULL  ||  strtoupper($numero_per_lect) == "NULL" ) ? NULL : $numero_per_lect;
    $piso_per_lect = ($piso_per_lect == NULL  ||  strtoupper($piso_per_lect) == "NULL" ) ? NULL : $piso_per_lect;
    $dpto_per_lect = ($dpto_per_lect == NULL  ||  strtoupper($dpto_per_lect) == "NULL" ) ? NULL : $dpto_per_lect;
    $unidad_per_lect = ($unidad_per_lect == NULL  ||  strtoupper($unidad_per_lect) == "NULL" ) ? NULL : $unidad_per_lect;
    $loc_per_lect = ($loc_per_lect == NULL  ||  strtoupper($loc_per_lect) == "NULL" ) ? NULL : $loc_per_lect;
    $cp_per_lect = ($cp_per_lect == NULL  ||  strtoupper($cp_per_lect) == "NULL" ) ? NULL : $cp_per_lect;
    $te_per_lect = ($te_per_lect == NULL  ||  strtoupper($te_per_lect) == "NULL" ) ? NULL : $te_per_lect;
    $calle_proc = ($calle_proc == NULL  ||  strtoupper($calle_proc) == "NULL" ) ? NULL : $calle_proc;
    $numero_proc = ($numero_proc == NULL  ||  strtoupper($numero_proc) == "NULL" ) ? NULL : $numero_proc;
    $piso_proc = ($piso_proc == NULL  ||  strtoupper($piso_proc) == "NULL" ) ? NULL : $piso_proc;
    $dpto_proc = ($dpto_proc == NULL  ||  strtoupper($dpto_proc) == "NULL" ) ? NULL : $dpto_proc;
    $unidad_proc = ($unidad_proc == NULL  ||  strtoupper($unidad_proc) == "NULL" ) ? NULL : $unidad_proc;
    $loc_proc = ($loc_proc == NULL  ||  strtoupper($loc_proc) == "NULL" ) ? NULL : $loc_proc;
    $cp_proc = ($cp_proc == NULL  ||  strtoupper($cp_proc) == "NULL" ) ? NULL : $cp_proc;
    $te_proc = ($te_proc == NULL  ||  strtoupper($te_proc) == "NULL" ) ? NULL : $te_proc;
    $otros_estud_super = ($otros_estud_super == NULL  ||  strtoupper($otros_estud_super) == "NULL" ) ? NULL : $otros_estud_super;
    $padre_vive = ($padre_vive == NULL  ||  strtoupper($padre_vive) == "NULL" ) ? NULL : $padre_vive;
    $madre_vive = ($madre_vive == NULL  ||  strtoupper($madre_vive) == "NULL" ) ? NULL : $madre_vive;
    $sit_laboral_alumno = ($sit_laboral_alumno == NULL  ||  strtoupper($sit_laboral_alumno) == "NULL" ) ? NULL : $sit_laboral_alumno;
    $categ_ocup_alum = ($categ_ocup_alum == NULL  ||  strtoupper($categ_ocup_alum) == "NULL" ) ? NULL : $categ_ocup_alum;
    $act_econom_alum = ($act_econom_alum == NULL  ||  strtoupper($act_econom_alum) == "NULL" ) ? NULL : $act_econom_alum;
    $det_rama_act_alum = ($det_rama_act_alum == NULL  ||  strtoupper($det_rama_act_alum) == "NULL" ) ? NULL : $det_rama_act_alum;
    $cant_horas_sem_trab_alum = ($cant_horas_sem_trab_alum == NULL  ||  strtoupper($cant_horas_sem_trab_alum) == "NULL" ) ? NULL : $cant_horas_sem_trab_alum;
    $sit_laboral_padre = ($sit_laboral_padre == NULL  ||  strtoupper($sit_laboral_padre) == "NULL" ) ? NULL : $sit_laboral_padre;
    $ult_est_padre = ($ult_est_padre == NULL  ||  strtoupper($ult_est_padre) == "NULL" ) ? NULL : $ult_est_padre;
    $act_econom_padre = ($act_econom_padre == NULL  ||  strtoupper($act_econom_padre) == "NULL" ) ? NULL : $act_econom_padre;
    $det_rama_act_padre = ($det_rama_act_padre == NULL  ||  strtoupper($det_rama_act_padre) == "NULL" ) ? NULL : $det_rama_act_padre;
    $sit_laboral_madre = ($sit_laboral_madre == NULL  ||  strtoupper($sit_laboral_madre) == "NULL" ) ? NULL : $sit_laboral_madre;
    $ult_est_madre = ($ult_est_madre == NULL  ||  strtoupper($ult_est_madre) == "NULL" ) ? NULL : $ult_est_madre;
    $act_econom_madre = ($act_econom_madre == NULL  ||  strtoupper($act_econom_madre) == "NULL" ) ? NULL : $act_econom_madre;
    $det_rama_act_madre = ($det_rama_act_madre == NULL  ||  strtoupper($det_rama_act_madre) == "NULL" ) ? NULL : $det_rama_act_madre;
    $alu_req_acces_fisica = ($alu_req_acces_fisica == NULL  ||  strtoupper($alu_req_acces_fisica) == "NULL" ) ? NULL : $alu_req_acces_fisica;
    $alu_req_acces_com = ($alu_req_acces_com == NULL  ||  strtoupper($alu_req_acces_com) == "NULL" ) ? NULL : $alu_req_acces_com;
    $nivel_otros_estud = ($nivel_otros_estud == NULL  || strtoupper($nivel_otros_estud) == "NULL" ) ? NULL : $nivel_otros_estud;
    $localidad_nacimiento = ($localidad_nacimiento == NULL  ||  strtoupper($localidad_nacimiento) == "NULL" ) ? NULL : $localidad_nacimiento;
    $nacionalidad = ($nacionalidad == NULL  ||  strtoupper($nacionalidad) == "NULL" ) ? NULL : $nacionalidad;
    $colegio_secundario = ($colegio_secundario == NULL  ||  strtoupper($colegio_secundario) == "NULL" ) ? NULL : $colegio_secundario;
    
    $resultado = $servicio->setDatosCensales($nroDocumento, $tipoDoc, $paisDoc, $fecha_ingreso_pais, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $nivel_otros_estud, $localidad_nacimiento, $nacionalidad, $colegio_secundario, $credenciales);
     //    return $resultado;
    return json_encode($resultado);
}

Class BuildArray {

    public function sgaDatosCensales($estado_civil, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre) {

        $convertir = new RecodeInsertaDatosCensales();
        if ($padre_vive != 'NULL' || $madre_vive != 'NULL') {
            $cViven_padres = 'S';
        }
        $datos = array('estado_civil' => $estado_civil,
            'calle_per_lect' =>(is_null($calle_per_lect)? NULL: mb_convert_encoding($calle_per_lect,'ISO-8859-1')), 'numero_per_lect' => $numero_per_lect,
            'piso_per_lect' => $piso_per_lect, 'dpto_per_lect' => $dpto_per_lect, 'unidad_per_lect' => $unidad_per_lect,
            'loc_per_lect' => $loc_per_lect, 'cp_per_lect' => $cp_per_lect, 'te_per_lect' => $te_per_lect,
            'calle_proc' =>(is_null($calle_proc)? NULL: mb_convert_encoding($calle_proc,'ISO-8859-1')), 'numero_proc' => $numero_proc, 'piso_proc' => $piso_proc,
            'dpto_proc' => $dpto_proc, 'unidad_proc' => $unidad_proc, 'loc_proc' => $loc_proc,
            'cp_proc' => $cp_proc, 'te_proc' => $te_proc, 'otros_estud_super' =>(is_null($otros_estud_super)? NULL: mb_convert_encoding($otros_estud_super,'ISO-8859-1')),
            'viven_padres' => $cViven_padres, 'sit_laboral_alu' => $convertir->recodeSit_laboral($sit_laboral_alumno),
            'categ_ocup_alum' => $convertir->recodeCateg_ocup($categ_ocup_alum), 'act_econom_alum' => $convertir->recodeAct_econom($act_econom_alum),
            'det_rama_act_alum' => $convertir->recodedet_rama_act($det_rama_act_alum), 'Hora_sem_trab_alum' => $convertir->recodeHora_sem_trab($cant_horas_sem_trab_alum),
            'sit_laboral_padre' => $convertir->recodeSit_laboral($sit_laboral_padre), 'ult_est_cur_padre' => $convertir->recodeUlt_est($ult_est_padre),
            'act_econom_padre' => $convertir->recodeAct_econom($act_econom_padre), 'det_rama_act_padre' => $convertir->recodedet_rama_act($det_rama_act_padre),
            'sit_laboral_madre' => $convertir->recodeSit_laboral($sit_laboral_madre), 'ult_est_cur_madre' => $convertir->recodeUlt_est($ult_est_madre),
            'act_econom_madre' => $convertir->recodeAct_econom($act_econom_madre), 'det_rama_act_madre' => $convertir->recodedet_rama_act($det_rama_act_madre)
        );

        return $datos;
    }

    public function sgaDatosCensalesAux($padre_vive, $madre_vive, $sit_laboral_alumno) {

        if ($sit_laboral_alumno == 2 || $sit_laboral_alumno == 3) {
            $iExiste_trab_alum = 1;
        } else {
            $iExiste_trab_alum = 3;
        }

        if ($padre_vive == NULL) {
            $padre_vive = 'D';
        }
        if ($madre_vive == NULL) {
            $madre_vive = 'D';
        }

        $datos = array('padre_vive' => $padre_vive, 'madre_vive' => $madre_vive,
            'existe_trab_alum' => $iExiste_trab_alum);

        return $datos;
    }

    public function sga820DatosCensalesAux($alu_req_acces_fisica, $alu_req_acces_com, $cant_horas_sem_trab_alum) {
        $convertir = new RecodeInsertaDatosCensales();

        $datos = array('cant_hora_sem_trab_alum' => $cant_horas_sem_trab_alum, 'alu_req_acces_fisica' => $convertir->recodeDis_acc($alu_req_acces_fisica),
            'alu_req_acces_com' => $convertir->recodeDis_com($alu_req_acces_com));

        return $datos;
    }

    public function sgaPersonas($apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $fecha_ingreso_pais, $localidad_nacimiento, $nacionalidad, $colegio_secunadrio) {
        $fecha_ingreso_pais = ($fecha_ingreso_pais != NULL)?Generales::formato_fecha_g2($fecha_ingreso_pais):NULL;
        
        $datos = array('apellido_padre' =>(is_null($apellido_padre)? NULL: mb_convert_encoding($apellido_padre,'ISO-8859-1')), 'apellido_madre' =>(is_null($apellido_madre)? NULL: mb_convert_encoding($apellido_madre,'ISO-8859-1')),
            'pais_emisor_pasap' => $pais_emisor_pasap, 'nro_pasap' => $nro_pasap,
            'fecha_ingreso_pais' => $fecha_ingreso_pais, 'loc_nacimiento' => $localidad_nacimiento,
            'nacionalidad' => $nacionalidad, 'colegio_secundario' => $colegio_secunadrio);

        return $datos;
    }

    /* ----------------------------------------**  G3  **------------------------------------------------ */

    public function mdpDatosPersonales($estado_civil, $padre_vive, $madre_vive, $calle_per_lect, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc) {

        $deco = new Redecode();
        
        if (!is_null($numero_per_lect)&& $numero_per_lect != 'NULL') {
            $numero_per_lect = (int) $numero_per_lect;
        }

        if (!is_null($loc_per_lect)&& $loc_per_lect != 'NULL') {
            $loc_per_lect = (int) $loc_per_lect;
        }

        if (!is_null($numero_proc)&& $numero_proc != 'NULL') {
            $numero_proc = (int) $numero_proc;
        }

        if (!is_null($loc_proc)&& $loc_proc != 'NULL') {
            $loc_proc = (int) $loc_proc;
        }

        $estado_civil = ($estado_civil != '') ? $deco->recodeEstadoCivil($estado_civil) : '';

        $datos = array('estado_civil' => $estado_civil,
            'situacion_padre' => $deco->recodePadresViven($padre_vive), 'situacion_madre' => $deco->recodePadresViven($madre_vive),
            'periodo_lectivo_calle' => (is_null($calle_per_lect)? NULL:mb_convert_encoding($calle_per_lect,'UTF-8')),
            'periodo_lectivo_numero' => $numero_per_lect, 'periodo_lectivo_piso' => $piso_per_lect,
            'periodo_lectivo_departamento' => $dpto_per_lect, 'periodo_lectivo_unidad' => $unidad_per_lect,
            'periodo_lectivo_localidad' => $loc_per_lect, 'periodo_lectivo_codigo_postal' => $cp_per_lect,
            'procedencia_calle' => (is_null($calle_proc)? NULL:mb_convert_encoding($calle_proc,'UTF-8')), 'procedencia_numero' => $numero_proc,
            'procedencia_piso' => $piso_proc,
            'procedencia_departamento' => $dpto_proc, 'procedencia_unidad' => $unidad_proc,
            'procedencia_localidad' => $loc_proc,
            'procedencia_codigo_postal' => $cp_proc);

        return $datos;
    }

    public function mdpDatosEconomicos($sit_laboral_alumno, $categ_ocup_alum, $cant_horas_sem_trab_alum, $det_rama_act_alum) {	
        $deco = new Redecode();
        if (!is_null($categ_ocup_alum) && strtoupper($categ_ocup_alum) != 'NULL') {
            $categ_ocup_alum = $deco->recodeCateg_ocup($categ_ocup_alum);
        } else {
            $categ_ocup_alum = NULL;
        }
        if (!is_null($cant_horas_sem_trab_alum) && strtoupper($cant_horas_sem_trab_alum) != 'NULL') {
            $cant_horas_sem_trab_alum = $deco->recodeHora_sem_trab($cant_horas_sem_trab_alum);
        } else {
            $cant_horas_sem_trab_alum = NULL;
        }
        if ($det_rama_act_alum != 'NULL' && !is_null($det_rama_act_alum)) {
            $trabajo_tarea_descripcion = 'Rama: ' . $deco->recodedet_rama_act($det_rama_act_alum) . ' - Actividad: ' . $deco->recodeAct_econom($act_econom_alum) ;
        } else {
            $trabajo_tarea_descripcion = NULL;
        }
        $sit_laboral_alumno = ($sit_laboral_alumno != "''") ? $deco->recodeSit_laboral($sit_laboral_alumno) : "''";
        $datos = array('trabajo_existe' => $sit_laboral_alumno, 'trabajo_ocupacion' => $categ_ocup_alum,
            'trabajo_hora_sem' => $cant_horas_sem_trab_alum, 'trabajo_tarea_descripcion' => $trabajo_tarea_descripcion);

        return $datos;
    }

    public function mdpPersonasAllegadosPadre($sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre) {
        $deco = new Redecode();
        if (!is_null($det_rama_act_padre) && strtoupper($det_rama_act_padre) != 'NULL') {
            $trabajo = 'Rama: ' . $deco->recodedet_rama_act($det_rama_act_padre) . ' - Actividad: ' . $deco->recodeAct_econom($act_econom_padre);
        } else {
            $trabajo = NULL;
        }
        $sit_laboral_padre = ($sit_laboral_padre != "''") ? $deco->recodeSit_laboral($sit_laboral_padre) : "''";
        $datos = array('trabajo_existe' => $sit_laboral_padre, 'estudio_alcanzado' => $deco->recodeUlt_est($ult_est_padre),
            'trabajo_ocupacion' => NULL, '$act_econom_padre' => NULL,
            'trabajo_tarea' => $trabajo);

        return $datos;
    }

    public function mdpPersonasAllegadosMadre($sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre) {
        $deco = new Redecode();
        if (!is_null($det_rama_act_madre) && strtoupper($det_rama_act_madre) != 'NULL') {
            $trabajo = 'Rama: ' . $deco->recodedet_rama_act($det_rama_act_madre) . ' - Actividad: ' . $deco->recodeAct_econom($act_econom_madre);
        } else {
            $trabajo = NULL;
        }
        $sit_laboral_madre = ($sit_laboral_madre != "''") ? $deco->recodeSit_laboral($sit_laboral_madre) : "''";
        $datos = array('trabajo_existe' => $sit_laboral_madre, 'estudio_alcanzado' => $deco->recodeUlt_est($ult_est_madre),
            'trabajo_ocupacion' => NULL, '$act_econom_padre' => NULL,
            'trabajo_tarea' => $trabajo);

        return $datos;
    }

    public function mdpPersonas($nacionalidad, $localidad_nacimiento) {
        
        $nacionalidad = (!is_null($nacionalidad) && $nacionalidad !='NULL') ? (int) $nacionalidad : $nacionalidad;           
        
        $datos = array('nacionalidad' => $nacionalidad, 'localidad_nacimiento' => $localidad_nacimiento);

        return $datos;
    }

}

?>
