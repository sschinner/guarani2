<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente. Y realizó la operación deseada por el cliente.
  '1': Error de autenticacion - Credenciales invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion. Implica alguna condición de error del lenguaje, que no es gestionada o en el llamado a la función.
  ------------------------------------------------------------------------------------------ */

Class DatosAltaRequisitoWS {

    // Variables Generales
    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;

    // Variables Locales del procedimiento
}

Class RecodeAltaRequisitoWS {

    function recodeRequisito($requisito, $forma_cumpli) {

        switch ($requisito) {
            case "1": if ($forma_cumpli == "1") {
                    $resultado = "UNL10";
                } elseif ($forma_cumpli == "2") {
                    $resultado = "UNL01";
                } elseif ($forma_cumpli == "3") {
                    $resultado = "UNL11";
                } elseif ($forma_cumpli == "4") {
                    $resultado = "UNL12";
                } else {
                    $resultado = "1-ING";
                }

                break; // DNI

            case "2": $resultado = "UNL02";
                break; // Partida de nacimiento

            case "3": if ($forma_cumpli == "1") {
                    $resultado = "UNL13";
                } elseif ($forma_cumpli == "2") {
                    $resultado = "UNL07";
                } elseif ($forma_cumpli == "3") {
                    $resultado = "UNL14";
                } elseif ($forma_cumpli == "4") {
                    $resultado = "UNL03";
                } elseif ($forma_cumpli == "5") {
                    $resultado = "UNL15";
                } elseif ($forma_cumpli == "6") {
                    $resultado = "UNL16";
                } elseif ($forma_cumpli == "7") {
                    $resultado = "UNL17";
                } elseif ($forma_cumpli == "8") {
                    $resultado = "UNL18";
                } elseif ($forma_cumpli == "9") {
                    $resultado = "UNL19";
                } else {
                    $resultado = "3-ING";
                }

                break; // Titulo secundario

            case "4": $resultado = "UNL04";
                break; // Foto
            case "5": $resultado = "UNL05";
                break; // Grupo y factor sanguineo
            case "6": $resultado = "UNL09";
                break; // Ficha datos personales
            case "7": $resultado = "UNL08";
                break; // CUIT/CUIL

            case "10": if ($forma_cumpli == "1") {
                    $resultado = "POS01";
                } elseif ($forma_cumpli == "2") {
                    $resultado = "POS02";
                }elseif ($forma_cumpli == "3") {
                    $resultado = "POS08";
                }
                break; // Titulo Universitario

            case "11": $resultado = "UNL06";
                break; // CUIT/CUIL
			case "15": 
				if ($forma_cumpli == "20") {
                    $resultado = "UNL20";
                } elseif ($forma_cumpli == "21") {
                    $resultado = "UNL21";
                } elseif ($forma_cumpli == "22") {
                    $resultado = "UNL22";
                }
                break; // Titulo Terciario

            default: $resultado = "";
        }
        return $resultado;
    }

    function recodeObligatorio($requisito, $forma_cumpli) {
         
        if (    ($requisito == "7") 
            || ( $requisito == "3" and $forma_cumpli = "4") 
            || ( $requisito == "1" and $forma_cumpli = "2")
            || ( $requisito == "15" and $forma_cumpli = "22")) {
            $resultado = 'S';
        } else {
            $resultado = 'N';
        }
       
        return $resultado;
    }

}

/* ------------------------------------------------------------------------------------------------------------------
  FUNCION QUE INSERTA UN REQUISITO DE INGRESO EN LA UNIDAD ACADEMICA CORRESPONDIENTE. ES INVOCADA POR Ingreso UNL.
  ------------------------------------------------------------------------------------------------------------------- */

Class IngresoAltaRequisitoWS {

    function insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito, $forma_cumpli, $fecha_presentacion, $exceptuado,$credenciales) {

        $requisito = new DatosAltaRequisitoWS();
        $convertir = new RecodeAltaRequisitoWS();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso');


        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
        // PASO 1: Autentico el usuario y password de webservices
        
        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $requisito->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $requisito->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $requisito;
        }

        // PASO 2: Verifico integridad de los datos pasados
        if ($ua == "" || $tipotitulo == "" || $carrera == "" || $pais_documento == "" || $tipo_doc == "" || $nro_doc == "" || $cod_requisito == "") {
            $requisito->codigoWS = CODIGO_ERROR_PARAMETROS;
            $requisito->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            return $requisito;
        }
        //Verifica existencia de requisito
        if ($convertir->recodeRequisito($cod_requisito, $forma_cumpli) == '') {
            $requisito->codigoWS = CODIGO_OK;
            $requisito->mensajeWS = MENSAJE_OK;
            $requisito->codigoRetorno = (string)'-3' ;
            $requisito->mensajeRetorno = "El requisito " . $cod_requisito . " es inexistente - Verifique";
            return $requisito;
        }

        // PASO 3: Conexion a informix

        $db = Generales::recuperarDB($ua, $tipotitulo);
        $objCC = Generales::conectar($db);
        if ($objCC == '3') {
            $requisito->codigoWS = CODIGO_ERROR_CONEXION;
            $requisito->mensajeWS = MENSAJE_ERROR_CONEXION;
            return $requisito;
        }

        // PASO 4: Desarrollo la funcion que necesito
        if (($tipotitulo != '7') && (!Generales::verificaUAPS($ua, $tipotitulo))) {

            $strSQL = "EXECUTE PROCEDURE web_ser_alta_req('" . $ua . "', '" . $carrera . "', '" . $pais_documento . "','" .
                    $tipo_doc . "','" . $nro_doc . "','" . $nro_inscripcion . "','" . $convertir->recodeRequisito($cod_requisito, $forma_cumpli) . "','" .
                    $convertir->recodeObligatorio($requisito, $forma_cumpli) . "','" .
                    $fecha_presentacion . "','" . $exceptuado . "');";


            $res = $objCC->Execute($strSQL);

            if ($res->fields[0] != "") {
                $datosproc = $res->getRows();
                $requisito->codigoWS = CODIGO_OK;
                $requisito->mensajeWS = MENSAJE_OK;
                $requisito->codigoRetorno = (string) $datosproc[0][0];
                $requisito->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $datosproc[0][1]);
                return $requisito;
            } else {
                $requisito->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $requisito->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $requisito;
            }
        } else {
            
            $codigoRequisito = $convertir->recodeRequisito($cod_requisito, $forma_cumpli);
            $obligatorio = $convertir->recodeObligatorio($cod_requisito, $forma_cumpli);
           
            $rep = new RepositorioWS();
            $resul = $rep->insertarRequisito($ua, $carrera, $tipo_doc, $nro_doc, $pais_documento, $codigoRequisito, $obligatorio, $fecha_presentacion, $exceptuado, $objCC);

            if (!empty($resul)) {
                $requisito->codigoWS = CODIGO_OK;
                $requisito->mensajeWS = MENSAJE_OK;
                $requisito->codigoRetorno = (string) $resul[0][0];
                $requisito->mensajeRetorno = iconv("ISO-8859-1", "utf-8", $resul[0][1]);
                return $requisito;
            } else {
                $requisito->codigoWS = CODIGO_ERROR_PROCEDIMIENTO;
                $requisito->mensajeWS = MENSAJE_ERROR_PROCEDIMIENTO;
                return $requisito;
            }
        }
    }

}

function altaRequisito($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito, $forma_cumpli, $fecha_presentacion, $exceptuado, $validado) {
    $servicio = new IngresoAltaRequisitoWS();
    $credenciales = new Credenciales();
    $parametros = array('ua'=>$ua, 'tipotitulo'=>$tipotitulo, 'carrera'=>$carrera, 'tipo_doc'=>$tipo_doc, 'nro_doc'=>$nro_doc, 'pais_documento'=>$pais_documento, 'nro_inscripcion'=>$nro_inscripcion, 'cod_requisito'=>$cod_requisito, 'forma_cumpli'=>$forma_cumpli, 'fecha_presentacion'=>$fecha_presentacion, 'exceptuado'=>$exceptuado, 'validado'=>$validado);
    Generales::logLlamada('altaRequisito', $parametros, true);
    $resultado = $servicio->insertar($ua, $tipotitulo, $carrera, $tipo_doc, $nro_doc, $pais_documento, $nro_inscripcion, $cod_requisito, $forma_cumpli, $fecha_presentacion, $exceptuado,$credenciales);
    if ($resultado->codigoWS == 0) {
        $resp = generaLegajo(strtoupper(trim($ua)), $tipotitulo, trim($carrera), $pais_documento, $tipo_doc, $nro_doc, $validado,$credenciales);
    }
    
    return json_encode($resultado);
}

?>
