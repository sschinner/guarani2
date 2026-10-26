<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada o en el llamado a la función.
  ------------------------------------------------------------------------------------------ */
require_once ('bcrypt.php');
require_once ('Repositorio/RepositorioWS.php');

Class DatosAltaAspiranteWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;

    // Variables Locales del procedimiento
}

Class RecodeAltaAspiranteWS {

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
            default: $resultado = "";
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
            default: $resultado = "";
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
            default: $resultado = "";
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
            default: $resultado = "";
        }
        return $resultado;
    }

    function recodeHora_sem_trab($cant_horas_sem_trab) {
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
            default: $resultado = "";
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

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN ALUMNO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  Se debe calcular la clave por default a setear y pasar como parámetro.
  ------------------------------------------------------------------------------------------------------------------- */

Class IngresoAltaAspiranteWS {

    function insertar($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $numero_cuil, $fecha_nacimiento, $sexo, $loc_nacimiento, $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $nacionalidad, $fecha_ingreso_pais, $credenciales) {

        $aspirante = new DatosAltaAspiranteWS();
        $convertir = new RecodeAltaAspiranteWS();

        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        // PASO 1: Autentico el usuario y password de webservices
        // $aut = Generales::autenticar();
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $aspirante->codigoWS = (string) CODIGO_ERROR_AUTENTICACION;
            $aspirante->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $aspirante;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {
            if ($ua == "" || $tipotitulo == "" || $anio_acad == "" || $carrera == "" || $tipo_ingreso == "" || $fecha_insc == "" || $apellido == "" || $nombres == "" ||
                    $tipo_doc == "" || $nro_doc == "" || $sexo == "" || $pais_documento == "" || $numero_cuil == "" || $fecha_nacimiento == "" || $eMail == "" || $nacionalidad == "") {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
                $aspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                return $aspirante;
            }

            // CUE Colegio Secundario
            if ($colegio_secundario == "0000000") {
                $colegio_secundario = "";
            }

            // Estado Civil
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
                default: $estado_civil = "";
            }
        } else {
            if ($ua == "" || $tipotitulo == "" || $anio_acad == "" || $carrera == "" || $tipo_ingreso == "" ||
                    $fecha_insc == "" || $apellido == "" || $nombres == "" || $tipo_doc == "" || $nro_doc == "" ||
                    $sexo == "" || $pais_documento == "" || $numero_cuil == "" || $fecha_nacimiento == "" ||
                    $eMail == "" || $loc_proc == "" || $nacionalidad == "") {

                //|| $colegio_secundario == "" SE QUITA LA OBLIGATORIEDAD, ESTA HABLADO CON JUAN MG
                $aspirante->codigoWS = (string) CODIGO_ERROR_PARAMETROS;
                $aspirante->mensajeWS = MENSAJE_ERROR_PARAMETROS;
                return $aspirante;
            }
        }

        // Colegio Secundario Dependencia // Se mapea a NULL ya que la dependencia del colegio secundario en G2 esta asociada al mismo colegio. Este parámetro se sigue usando como NULL  
        $colegio_secundario_dependencia = null;

        // PASO 3: Conexion a DB
        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $aspirante->codigoWS = (string) CODIGO_ERROR_CONEXION;
            $aspirante->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $aspirante;
        }


        // PASO 4: Desarrollo la funcion que necesito
        // Realiza la recodificación de datos de Ingreso UNL
        // Obtengo la clave por defecto y la codifico
        $enc = new bcrypt(10);
        $claveNueva = $enc->hash(md5(substr($nro_doc, 0, 5)));
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {

            //Sexo - conversion solo para G2
            if ($sexo == "M") {
                $sexo = "1";
            } else {
                $sexo = "2";
            }


            $apellido = mb_convert_encoding($apellido, 'ISO-8859-1');
            $nombres = mb_convert_encoding($nombres, 'ISO-8859-1');
            $apellido_padre = mb_convert_encoding($apellido_padre, 'ISO-8859-1');
            $apellido_madre = mb_convert_encoding($apellido_madre, 'ISO-8859-1');
            $calle_per_lec = mb_convert_encoding($calle_per_lec, 'ISO-8859-1');
            $calle_proc = mb_convert_encoding($calle_proc, 'ISO-8859-1');

            $strSQL = 'EXECUTE PROCEDURE "dba".web_ser_insc_asp("' . $ua . '","' . $anio_acad . '","'
                            . $carrera . '","' . $sede . '","' . $tipo_ingreso . '","'
                            . $fecha_insc  . '","' . $apellido . '","'
                            . $nombres . '","' . $pais_documento . '","'
                            . $tipo_doc . '","' . $nro_doc . '","' . $numero_cuil . '","' 
                            . $fecha_nacimiento . '","' . $sexo . '","' . $claveNueva . '","' 
                            . $nacionalidad . '","' . $loc_nacimiento . '","' . $colegio_secundario  
                            . '","' . $colegio_secundario_dependencia . '","' . $anio_egreso_sec 
                            . '","' . $grupo_sanguineo . '","' . $factor_sanguineo . '","'
                            . $apellido_padre . '","' 
                            . $apellido_madre . '","' 
                            . $pais_emisor_pasap . '","' . $nro_pasap . '","' . $estado_civil . '","' 
                            . $eMail . '","' . $calle_per_lec . '","' 
                    . $numero_per_lect . '","' . $piso_per_lect . '","' . $dpto_per_lect . '","' 
                    .$unidad_per_lect . '","' . $loc_per_lect . '","' . $cp_per_lect . '","' 
                    . $te_per_lect  . '","' . $calle_proc . '","' 
                    .$numero_proc . '","' . $piso_proc . '","' . $dpto_proc . '","' . $unidad_proc . '","' 
                    . $loc_proc . '","' . $cp_proc . '","' .                    $te_proc . '","' 
                    . $otros_estud_super . '","' . $padre_vive . '","' . $madre_vive . '","' 
                    . $convertir->recodeSit_laboral($sit_laboral_alumno) . '","' 
                    . $convertir->recodeCateg_ocup($categ_ocup_alum) . '","' 
                    . $convertir->recodeAct_econom($act_econom_alum) . '","' 
                    . $convertir->recodedet_rama_act($det_rama_act_alum) . '","' 
                    . $cant_horas_sem_trab_alum . '","' 
                    . $convertir->recodeHora_sem_trab($cant_horas_sem_trab_alum) . '","' 
                    . $convertir->recodeSit_laboral($sit_laboral_padre) . '","' 
                    . $convertir->recodeUlt_est($ult_est_padre) . '","' 
                    . $convertir->recodeAct_econom($act_econom_padre) . '","' 
                    . $convertir->recodedet_rama_act($det_rama_act_padre) . '","' 
                    . $convertir->recodeSit_laboral($sit_laboral_madre) . '","' 
                    . $convertir->recodeUlt_est($ult_est_madre) . '","' 
                    . $convertir->recodeAct_econom($act_econom_madre) . '","' 
                    . $convertir->recodedet_rama_act($det_rama_act_madre) . '","' 
                    . $convertir->recodeDis_acc($alu_req_acces_fisica) . '","' 
                    . $convertir->recodeDis_com($alu_req_acces_com). '","' 
                    . $fecha_ingreso_pais . '");';

            // $strSQL = "EXECUTE PROCEDURE 'dba'.web_ser_insc_asp('ESS', '2019', '07011', '00000', '1', '10/09/2019','Garc�a','Mart�n','54','0','50000000','20500000008','21/05/1987','1','$2a$10$1vhtiNxwz4eq8XsFnTLXKOigOTceF8i3DNYn7v6MPwAQb5r/1mStK','1', '2310', '','', '', '', '', '','', '', '', '', 'asnhdc@gmails.com', '', '', '', '', '', '', '', '','','', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '1', '', '13', '', '', '', '13', '', '', 'N', '2', '');";

            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $aspirante->codigoWS = (string) CODIGO_OK;
                $aspirante->mensajeWS = MENSAJE_OK;
                $aspirante->codigoRetorno = $datosproc[0][0];
                $aspirante->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $aspirante;
            } else {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PROCEDIMIENTO;
                $aspirante->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $aspirante;
            }
        } else {
            /**
             *  Realizo la insercion en Postgres 
             */
            $rep = new RepositorioWS();

            $resul = $rep->insertarAspirante($ua, $anio_acad, $carrera, $sede, $tipo_ingreso,
                    $fecha_insc, mb_convert_encoding($apellido, 'UTF-8'), mb_convert_encoding($nombres, 'UTF-8'), $tipo_doc, $nro_doc, $pais_documento,
                    $numero_cuil, $fecha_nacimiento, $sexo, $loc_nacimiento,
                    $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec,
                    $grupo_sanguineo, $factor_sanguineo, mb_convert_encoding($apellido_padre, 'UTF-8'), mb_convert_encoding($apellido_madre, 'UTF-8'),
                    $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, mb_convert_encoding($calle_per_lec, 'UTF-8'),
                    $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect,
                    $loc_per_lect, $cp_per_lect, $te_per_lect, mb_convert_encoding($calle_proc, 'UTF-8'), $numero_proc,
                    $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc,
                    mb_convert_encoding($otros_estud_super, 'UTF-8'), $padre_vive, $madre_vive, $sit_laboral_alumno,
                    $categ_ocup_alum, ($act_econom_alum), ($det_rama_act_alum),
                    $cant_horas_sem_trab_alum, ($sit_laboral_padre), ($ult_est_padre),
                    $act_econom_padre, $det_rama_act_padre, ($sit_laboral_madre),
                    ($ult_est_madre), ($act_econom_madre), $det_rama_act_madre,
                    $alu_req_acces_fisica, $alu_req_acces_com, $objCC, $claveNueva, $nacionalidad, $fecha_ingreso_pais);


            if (!empty($resul)) {
                $aspirante->codigoWS = (string) CODIGO_OK;
                $aspirante->mensajeWS = MENSAJE_OK;
                $aspirante->codigoRetorno = (string) $resul[0][0];
                $aspirante->mensajeRetorno = $resul[0][1];
                return $aspirante;
            } else {
                $aspirante->codigoWS = (string) CODIGO_ERROR_PROCEDIMIENTO;
                $aspirante->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $aspirante;
            }
        }
    }

}

function altaAspirante($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $numero_cuil, $fecha_nacimiento, $sexo, $loc_nacimiento, $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $nacionalidad, $fecha_ingreso_pais) {

    $servicio = new IngresoAltaAspiranteWS();
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'anio_acad'=> $anio_acad, 
        'carrera' =>$carrera  , 'sede' =>$sede,'tipo_ingreso' =>$tipo_ingreso, 
        'fecha_insc' =>$fecha_insc ,'apellido' =>$apellido  ,'nombres' =>$nombres  ,
        'tipo_doc' =>$tipo_doc,'nro_doc' =>$nro_doc  ,'pais_documento' =>$pais_documento  ,
        'numero_cuil' =>$numero_cuil  ,'fecha_nacimiento' =>$fecha_nacimiento   ,'sexo' =>$sexo  ,
        'loc_nacimiento' =>$loc_nacimiento  ,'colegio_secundario' =>$colegio_secundario   ,
        'colegio_secundario_dependencia' =>$colegio_secundario_dependencia  ,
        'anio_egreso_sec' =>$anio_egreso_sec  , 'grupo_sanguineo' =>$grupo_sanguineo  , 
        'factor_sanguineo' =>$factor_sanguineo  , 'apellido_padre' =>$apellido_padre  , 
        'apellido_madre' =>$apellido_madre  , 'pais_emisor_pasap' =>$pais_emisor_pasap  ,
        'nro_pasap' =>$nro_pasap  , 'estado_civil' =>$estado_civil  , 'eMail' =>$eMail  , 
        'calle_per_lec' =>$calle_per_lec  , 'numero_per_lect' =>$numero_per_lect  ,'piso_per_lect' =>$piso_per_lect  ,
        'dpto_per_lect' =>$dpto_per_lect, 'unidad_per_lect' =>$unidad_per_lect  ,'loc_per_lect' =>$loc_per_lect  ,
        'cp_per_lect' =>$cp_per_lect  ,'te_per_lect' =>$te_per_lect   ,'calle_proc' =>$calle_proc  ,
        'numero_proc' =>$numero_proc  ,'piso_proc' =>$piso_proc  ,'dpto_proc' =>$dpto_proc  ,
        'unidad_proc' =>$unidad_proc  ,'loc_proc' =>$loc_proc  ,'cp_proc' =>$cp_proc  ,'te_proc' =>$te_proc  ,
        'otros_estud_super' =>$otros_estud_super  ,'padre_vive' =>$padre_vive  ,'madre_vive' =>$madre_vive  ,
        'sit_laboral_alumno' =>$sit_laboral_alumno  ,'categ_ocup_alum' =>$categ_ocup_alum  , 
        'act_econom_alum' =>$act_econom_alum  ,'det_rama_act_alum' =>$det_rama_act_alum  ,
        'cant_horas_sem_trab_alum' =>$cant_horas_sem_trab_alum  , 'sit_laboral_padre' =>$sit_laboral_padre  ,
        'ult_est_padre' =>$ult_est_padre  ,'act_econom_padre' =>$act_econom_padre  ,
        'det_rama_act_padre' =>$det_rama_act_padre  , 'sit_laboral_madre' =>$sit_laboral_madre  , 
        'ult_est_madre' =>$ult_est_madre  ,'act_econom_madre' =>$act_econom_madre   ,'det_rama_act_madre' =>$det_rama_act_madre  ,
        'alu_req_acces_fisica' =>$alu_req_acces_fisica  , 'alu_req_acces_com' =>$alu_req_acces_com  ,
        'nacionalidad' =>$nacionalidad  , 'fecha_ingreso_pais' =>$fecha_ingreso_pais  );
    Generales::logLlamada('altaAspirante', $parametros, false);
    $credenciales = new Credenciales();
    $resultado = $servicio->insertar($ua, $tipotitulo, $anio_acad, $carrera, $sede, $tipo_ingreso, $fecha_insc, $apellido, $nombres, $tipo_doc, $nro_doc, $pais_documento, $numero_cuil, $fecha_nacimiento, $sexo, $loc_nacimiento, $colegio_secundario, $colegio_secundario_dependencia, $anio_egreso_sec, $grupo_sanguineo, $factor_sanguineo, $apellido_padre, $apellido_madre, $pais_emisor_pasap, $nro_pasap, $estado_civil, $eMail, $calle_per_lec, $numero_per_lect, $piso_per_lect, $dpto_per_lect, $unidad_per_lect, $loc_per_lect, $cp_per_lect, $te_per_lect, $calle_proc, $numero_proc, $piso_proc, $dpto_proc, $unidad_proc, $loc_proc, $cp_proc, $te_proc, $otros_estud_super, $padre_vive, $madre_vive, $sit_laboral_alumno, $categ_ocup_alum, $act_econom_alum, $det_rama_act_alum, $cant_horas_sem_trab_alum, $sit_laboral_padre, $ult_est_padre, $act_econom_padre, $det_rama_act_padre, $sit_laboral_madre, $ult_est_madre, $act_econom_madre, $det_rama_act_madre, $alu_req_acces_fisica, $alu_req_acces_com, $nacionalidad, $fecha_ingreso_pais, $credenciales);
    return json_encode($resultado);
}

?>
