<?php

include_once(dirname(__DIR__) . '/general.php');
include_once(dirname(__DIR__) . '/Repositorio/RepositorioWS.php');
include_once(dirname(__DIR__) . "../../libraries/adodb/adodb.inc.php");
include_once(dirname(__DIR__) . "/configServer.php");

/**
 * Description of tramites
 *
 * @author sschinner
 */
class Tramites {

    function cambiarEstadoCobro($hash) {
        // openlog("certificado", LOG_PID, LOG_LOCAL0);
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $estado = false;
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                // Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($hash);
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_cambiar_estado_cobro_certif", $objCC);
                    if (!empty($salida) && $salida[0] != 4) { 
                        if ($salida[0][0] == 1) {
                            //print_r($salida[0][0]); die;
                            $estado = true;                            
                        }                                                          
                    } else {                                    
                        syslog(LOG_ERR, "[error] " . ((empty($salida)) ? 'La funciÃ³n no devolviÃ³ datos' : $salida[0][0]) . " - " . ((empty($salida)) ? 'funl_ws_cambiar_estado_cobro_certif' : $salida[0][1]). " - base de datos ". $uas[$i]); // . $uas[$i]. "-" ); //. $e->getMessage());                                                
                    }                       
                } else {
                    syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                $titulo = '0';
                // Informix
                $strSQL = "execute procedure web_serv_cambiar_estado_cobro_certif('" . $hash . "');";
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                        if ($resultado[0][0] == 1) {
                            $estado = true;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        // closelog();
        return $estado;
    }

    function obtenerIdsCobros() {
        $cobros = array();
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $j = 0;
        for ($i = 0; $i < count($uas); $i++) { //para todas las UAs
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Obtener ID de cobros en POSTGRES");
                // Postgres               
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array();
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_obtener_cobro_pend_certif", $objCC);                    
                    if (!empty($salida) && $salida[0] != 4) { 
                        if (!empty($salida)) {
                            foreach ($salida as $resu) {
                                $cobros[$j] = array("id" => $resu[0], "db" => $uas[$i], "certificado" => $resu[1]);
                                $j++;
                            }
                        }                                                                                
                    }           
                } else {
                    syslog(LOG_ERR, "[error] [obtenerIdsCobros] No fue posible conectarse a la base de datos: POSTGRES");
                }
            } else {
                $titulo = '0';
                syslog(LOG_ERR, "[info] Obtener ID de cobros en " . $uas[$i]);
                // Informix
                $strSQL = "execute procedure web_serv_obtener_cobro_pend_certif();";
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                    } else {
                        $resultado = "";
                    }
                    if ($resultado != "" && !empty($resultado)) {
                        foreach ($resultado as $resu) {
                            $cobros[$j] = array("id" => $resu[0], "db" => $uas[$i], "certificado" => $resu[1]);
                            $j++;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] [obtenerIdsCobros] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return $cobros;
    }

    function registrarCobro($idCobro, $db) {
        $registro = false;
        $general = new Generales();
        
        if ($db == 'guarani3_') {
            $titulo = '7';
            //Postgres
            syslog(LOG_ERR, "[info] Registrar cobros en POSTGRES");
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $objCC->beginTransaction();
                $strSQL = "UPDATE u820_constancias_solicitud SET estado_pago = 'P' WHERE identificador_cobro = '" . $idCobro . "';";
                $sth = $objCC->prepare($strSQL);
                $sth->execute();                                                          
                if ($sth->errorCode() == 0) {
                    $registro = true;
                    $objCC->commit();                
                } else {
                    syslog(LOG_ERR, "[error] " . $sth->errorInfo()[2]. " base de datos ". $db);
                    $objCC->rollBack();
                }                
            } else {
                syslog(LOG_ERR, "[error] [registrarCobro] No fue posible conectarse a la base de datos: POSTGRES");
            }            
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Registrar cobros en " . $db);
            //Informix
            $strSQL = "UPDATE u820_pedidos_certif SET estado_pago = 'P' WHERE identificador_cobro = '" . $idCobro . "';";
            $strSQL .= " UPDATE sga_certif_pedidos SET copias_impresas = 0 WHERE certif_pedido IN (SELECT id_certif_pedido FROM u820_pedidos_certif WHERE identificador_cobro = '" . $idCobro . "');";
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $objCC->StartTrans();
                $objCC->Execute($strSQL);
                $objCC->CompleteTrans(); // Commit
                // $objCC->FailTrans(); // Rollback
                $objCC->Close();
                $registro = true;
            } else {
                syslog(LOG_ERR, "[error] [registrarCobro] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $registro;
    }

    function registrarVencidos() {
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $j = 0;
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                syslog(LOG_ERR, "[info] Control de vencimientos en POSTGRES");
                $titulo = '7';
                //Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $objCC->beginTransaction();
                    $strSQL1 = "UPDATE sga_constancias_solicitud SET estado = 'Rechazado', observaciones = 'Expiro Vencimiento de pago' WHERE solicitud IN (SELECT solicitud FROM u820_constancias_solicitud WHERE fecha_vencimiento_pago < current_date AND estado_pago IN ('N', 'M')) AND constancia NOT IN (102);";
                    $strSQL2= "UPDATE u820_constancias_solicitud SET estado_pago = 'V' WHERE fecha_vencimiento_pago < current_date AND estado_pago IN ('N', 'M');";
                    $sth1 = $objCC->prepare($strSQL1);
                    $sth2 = $objCC->prepare($strSQL2);
                    $sth1->execute();
                    $sth2->execute();
                    if ($sth1->errorCode() == 0 && $sth2->errorCode() == 0) {
                        $objCC->commit();
                    } else {
                        syslog(LOG_ERR, "[error] " . $sth1->errorInfo()[2]. " - " . $sth1->errorInfo()[2] . " base de datos ". $uas[$i]);
                        $objCC->rollBack();
                    }                    
                } else {
                    syslog(LOG_ERR, "[error] [registrarVencidos] No fue posible conectarse a la base de datos: POSTGRES");
                }
            } else {
                $titulo = '0';
                // Informix
                syslog(LOG_ERR, "[info] Control de vencimientos en " . $uas[$i]);
                $strSQL = "UPDATE sga_certif_pedidos SET copias_impresas = copias_pedidas WHERE certif_pedido IN (SELECT id_certif_pedido FROM u820_pedidos_certif WHERE fecha_vencimiento_pago < current AND estado_pago IN ('N', 'M')) AND certificado NOT IN (102);";
                $strSQL.= " UPDATE u820_pedidos_certif SET estado_pago = 'V' WHERE fecha_vencimiento_pago < current AND estado_pago IN ('N', 'M');";
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $objCC->StartTrans();
                    $objCC->Execute($strSQL);
                    $objCC->CompleteTrans(); // Commit
                    // $objCC->FailTrans(); // Rollback
                    $objCC->Close();
                } else {
                    syslog(LOG_ERR, "[error] [registrarVencidos] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
    }

    function obtenerTramitesSinExpediente() {
        $tramites = array();
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $j = 0;
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Obtener tramites sin expedientes en POSTGRES");
                //Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array();
                    $rep = new RepositorioWS();                        
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_obtener_certif_sin_expediente", $objCC);
                    if (!empty($salida) && $salida[0] != 4) {   
                        //print_r($salida); die;
                        foreach ($salida as $resu) {
                            $tramites[$j] = array("db" => $uas[$i],
                                "id" => $resu[2], "ua" => $resu[3],
                                "apellido" => $resu[4], "nombres" => $resu[5],
                                "tipoDocumento" => $resu[6], "nroDocumento" => $resu[7],
                                "carrera" => $resu[8],"tipoCertificado" => $resu[9], "certificacionMinisterial" => $resu[10],
                                "ua_completo" => $resu[11],
                                "nroInscripcion" => null, // no aplica en G3
                                "titulo" => null); // no aplica en G3
                            $j++;
                        }
                    } 
                } else {
                    syslog(LOG_ERR, "[error] [obtenerTramitesSinExpediente] No fue posible conectarse a la base de datos: POSTGRES");
                }
            } else {
                $titulo = '0';
                syslog(LOG_ERR, "[info] Obtener tramites sin expedientes en " . $uas[$i]);
                // Informix
                $strSQL = "execute procedure web_serv_obtener_certif_sin_expediente();";
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                    } else {
                        $resultado = "";
                    }
                    if ($resultado != "" && !empty($resultado)) {
                        foreach ($resultado as $resu) {
                            $tramites[$j] = array("db" => $uas[$i],
                                "id" => $resu[2], "ua" => $resu[3],
                                "apellido" => utf8_encode($resu[4]), "nombres" => utf8_encode($resu[5]),
                                "tipoDocumento" => $resu[6], "nroDocumento" => $resu[7],
                                "carrera" => utf8_encode($resu[8]), "tipoCertificado" => $resu[9],
                                "certificacionMinisterial" => $resu[10],
                                "ua_completo" => utf8_encode($resu[11]),
                                "nroInscripcion" => utf8_encode($resu[12]),
                                "titulo" => utf8_encode($resu[13]));
                            $j++;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] [obtenerTramitesSinExpediente] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return $tramites;
    }

    function registrarExpediente($idCertificado, $db, $expediente) {
        $registro = false;
        $general = new Generales();
        $titulo = '0';
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Registrar expedientes en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $objCC->beginTransaction();
                    $strSQL = "UPDATE u820_constancias_solicitud SET expediente = '" . $expediente . "' WHERE solicitud = '" . $idCertificado . "'";
                    $sth = $objCC->prepare($strSQL);
                    $sth->execute();
                    if ($sth->errorCode() == 0) {
                        $registro = true;
                        $objCC->commit();                
                    } else {
                        syslog(LOG_ERR, "[error] " . $sth->errorInfo()[2]. " base de datos ". $db);
                        $objCC->rollBack();
                    }
            } else {
                syslog(LOG_ERR, "[error] [registrarExpediente] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Registrar expedientes en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $objCC->StartTrans();
                $strSQL = "UPDATE u820_pedidos_certif SET expediente = '" . $expediente . "' WHERE id_certif_pedido = '" . $idCertificado . "'";
                $objCC->Execute($strSQL);
                $objCC->CompleteTrans(); // Commit
                // $objCC->FailTrans(); // Rollback
                $objCC->Close();
                $registro = true;
            } else {
                syslog(LOG_ERR, "[error] [registrarExpediente] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $registro;
    }

    function obtenerCertificadosValidados() {
        $tramites = array();
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $j = 0;
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Obtener certificados validados en POSTGRES");
                //Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array();
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_obtener_certif_validados", $objCC);
                    if (!empty($salida) && $salida[0] != 4) {
                        foreach ($salida as $resu) {
                            $tramites[$j] = [
								"db" => $uas[$i],
                                "id" => $resu[2], 
								"ua" => $resu[3],
                                "apellido" => $resu[4], "nombres" => $resu[5],
                                "expediente" => $resu[6], "persona" => $resu[7],
                                "tipoCertificado" => $resu[8], "fechaSolicitud" => $resu[9],
								"alumno" => $resu[10]
									];                                
                            $j++;
                        }                        
                    }                       
                } else {
                    syslog(LOG_ERR, "[error] [obtenerCertificadosValidados] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                syslog(LOG_ERR, "[info] Obtener certificados validados en " . $uas[$i]);
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $strSQL = "execute procedure web_serv_obtener_certif_validados();";
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                    } else {
                        $resultado = "";
                    }
                    if ($resultado != "" && !empty($resultado)) {
                        foreach ($resultado as $resu) {
                            $tramites[$j] = array("db" => $uas[$i],
                                "id" => $resu[2], "ua" => $resu[3],
                                "apellido" => utf8_encode($resu[4]), "nombres" => utf8_encode($resu[5]),
                                "expediente" => $resu[6], "nroInscripcion" => $resu[7], 
                                "tipoCertificado" => $resu[8], "fechaSolicitud" => $resu[9]);
                            $j++;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] [obtenerCertificadosValidados] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return $tramites;
    }

    function getCertificado($expediente) {
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $tramites = false;
        $titulo = '0';
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Obtener certificado en POSTGRES");
                //Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($expediente);
                    $rep = new RepositorioWS();
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_obtener_certif_por_expediente", $objCC);
                    if (!empty($salida) && $salida[0] != 4) {
                        foreach ($salida as $resu) {
                            if ($resu[2]) {
                                $tramites = array("db" => $uas[$i], "id" => $resu[2]);
                            }
                        }                        
                    } 
                } else {
                    syslog(LOG_ERR, "[error] [getCertificado] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                $titulo = '0';
                syslog(LOG_ERR, "[info] Obtener certificado en " . $uas[$i]);
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $strSQL = "execute procedure web_serv_obtener_certif_por_expediente('" . $expediente . "');";
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                    } else {
                        $resultado = "";
                    }
                    if ($resultado != "" && !empty($resultado)) {
                        foreach ($resultado as $resu) {
                            if ($resu[2]) {
                                $tramites = array("db" => $uas[$i], "id" => $resu[2]);
                            }
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] [getCertificado] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return $tramites;
    }

    function obtenerArgumentosCertificado($db, $id) {
        $argumentos = array();
        $general = new Generales();
        $titulo = '0';
        if ($db == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Obtener argumentos de certificado en POSTGRES");
                //Postgres
                $objCC = $general->conectar($db);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($id);
                    $rep = new RepositorioWS();
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_parametros_constancias", $objCC);
                    if (!empty($salida) && $salida[0] != 4) {
                        $j = 0;
                        foreach ($salida as $resu) {
                                $argumentos[$j] = array("nombre" => $resu["campo"], "argumento" => $resu["valor"], "version" => "G3");
                                $j++;
                        }                        
                    }
					$argumentos['version'] = "G3";
                } else {
                    syslog(LOG_ERR, "[error] [obtenerArgumentosCertificado] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                syslog(LOG_ERR, "[info] Obtener argumentos de certificado en " . $db);
                $objCC = $general->conectar($db);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $strSQL = "execute procedure sp820_argumentos_certificado('" . $id . "');";
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                    } else {
                        $resultado = "";
                    }
                    if ($resultado != "" && !empty($resultado)) {
                        $j = 0;
                        foreach ($resultado as $resu) {
                            $argumentos[$j] = array("orden" => $resu[0], "nombre" => $resu[1], "argumento" => $resu[2], "version" => "G2");
                            $j++;
                        }
                    }
					$argumentos['version'] = "G2";
                } else {
                syslog(LOG_ERR, "[error] [obtenerArgumentosCertificado] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $argumentos;
    }

    // 
    function obtenerMateriasCertificado100($db, $ua, $nroInscripcion, $titCertif, $solicitud) {
        $datos = array();
        $general = new Generales();
        $titulo = '0';
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 100 en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $parametros = array($solicitud);
                $rep = new RepositorioWS();           
                $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ted1e_analitico_egreso_dig", $objCC);
                if (!empty($salida) && $salida[0] != 4) {                   
                    $j = 0;
                    foreach ($salida as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                                "ua" => utf8_decode($resu[0]),
                                "expediente" => utf8_decode($resu[1]),
                                "legajo" => utf8_decode($resu[2]),
                                "nombreUniversidad" => utf8_decode($resu[3]),
                                "nombreFacultad" => utf8_decode($resu[4]),
                                "carrera" => utf8_decode($resu[5]),
                                "nombreCarrera" => utf8_decode($resu[6]),
                                "plan" => utf8_decode($resu[8]),
                                "fechaResolucion" => utf8_decode($resu[9]),
                                "nroResolucionPlan" => utf8_decode($resu[10]),
                                "apellido" => utf8_decode($resu[11]),
                                "nombres" => utf8_decode($resu[12]),
                                "tipoDocumento" => utf8_decode($resu[13]),
                                "nroDocumento" => utf8_decode($resu[15]),
                                "nroInscripcion" => utf8_decode($resu[16]),
                                "fechaEgreso" => utf8_decode($resu[17]),
                                "promedioCon" => utf8_decode($resu[18]),
                                "promedioSin" => utf8_decode($resu[19]),
                                "nombreTitulo" => utf8_decode($resu[20]),
                                "materia" => utf8_decode($resu[31]),
                                "nombreMateria" => utf8_decode($resu[32]),
                                "fecha" => utf8_decode($resu[33]),
                                "nota" => utf8_decode($resu[34]),
                                "concepto" => utf8_decode($resu[35]),
                                "acta" => utf8_decode($resu[37]),
                                "actaPromocion" => utf8_decode($resu[40]),
                                "nroResolucion" => utf8_decode($resu[38]),
                                "formaAprobacion" => utf8_decode($resu[39]),
                                "folio" => utf8_decode($resu[41]),
                                "resultado" => utf8_decode($resu[42]),
                                "tipoDocDescripcion" => utf8_decode($resu[14]),
                                "fechaPedidoCertif" => utf8_decode($resu[21]),
                                "descripcionNota" => utf8_decode($resu[36]),
                                "tipoTitulo" => utf8_decode($resu[22]),
                                "descTituloSecundario" => utf8_decode($resu[23]),
                                "secundarioExterior" => utf8_decode($resu[24]),
                                "resolucionIngreso" => utf8_decode($resu[27]),
                                "titSuperiorPrevio" => utf8_decode($resu[25]),
                                "tipoIngreso" => utf8_decode($resu[28]),
                                "localidadUA" => utf8_decode($resu[29]),
                                "fechaEgresoString" => utf8_decode($resu[30]),
                                "tipoDeCarrera" => utf8_decode($resu[7]),
                                "institucionOtorgante" => utf8_decode($resu[26]),
                                "sexo" => utf8_decode($resu[43]));
                        $j++;
                    }

                } 
            } else {
                syslog(LOG_ERR, "[error] [obtenerMateriasCertificado100] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }

        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 100 en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure sp820_ted_1e_dig('" . $ua . "', '" . $nroInscripcion . "', '" . $titCertif . "');";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                } else {
                    $resultado = "";
                }
                if ($resultado != "" && !empty($resultado)) {
                    $j = 0;
                    foreach ($resultado as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                            "ua" => $resu[0],
                            "expediente" => $resu[1],
                            "legajo" => $resu[2],
                            "nombreUniversidad" => $resu[3],
                            "nombreFacultad" => $resu[4],
                            "carrera" => $resu[5],
                            "nombreCarrera" => $resu[6],
                            "plan" => $resu[7],
                            "fechaResolucion" => $resu[8],
                            "nroResolucionPlan" => $resu[9],
                            "apellido" => $resu[10],
                            "nombres" => $resu[11],
                            "tipoDocumento" => $resu[12],
                            "nroDocumento" => $resu[13],
                            "nroInscripcion" => $resu[14],
                            "fechaEgreso" => $resu[15],
                            "promedioCon" => $resu[16],
                            "promedioSin" => $resu[17],
                            "nombreTitulo" => $resu[18],
                            "materia" => $resu[19],
                            "nombreMateria" => $resu[20],
                            "fecha" => $resu[21],
                            "nota" => $resu[22],
                            "concepto" => $resu[23],
                            "acta" => $resu[24],
                            "actaPromocion" => $resu[25],
                            "nroResolucion" => $resu[26],
                            "formaAprobacion" => $resu[27],
                            "folio" => $resu[28],
                            "resultado" => $resu[29],
                            "tipoDocDescripcion" => $resu[30],
                            "fechaPedidoCertif" => $resu[31],
                            "descripcionNota" => $resu[32],
                            "tipoTitulo" => $resu[33],
                            "descTituloSecundario" => $resu[34],
                            "secundarioExterior" => $resu[35],
                            "resolucionIngreso" => $resu[36],
                            "titSuperiorPrevio" => $resu[37],
                            "tipoIngreso" => $resu[38],
                            "localidadUA" => $resu[39],
                            "fechaEgresoString" => $resu[40],
                            "tipoDeCarrera" => $resu[41],
                            "institucionOtorgante" => $resu[42],
                            "sexo" => $resu[43]);
                        $j++;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [obtenerMateriasCertificado100] No fue posible conectarse a la base de datos: " . $db);
            }
        }
    return $datos;
    }

    function obtenerMateriasCertificado9($db, $ua, $carrera, $legajo, $corresponda, $solicitud) {
        $datos = array();
        $general = new Generales();
        $titulo = '0';        
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 9 en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $parametros = array($solicitud);
                $rep = new RepositorioWS();                    
                $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_constancia_historia_academica_dig", $objCC);
                if (!empty($salida) && $salida[0] != 4) {                   
                    $j = 0;
                    foreach ($salida as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                            "ua" => $resu[0],
                            "nroInscripcion" => utf8_decode($resu[1]),
                            "apellido" => utf8_decode($resu[2]),
                            "nombres" => utf8_decode($resu[3]),
                            "nroDocumento" => utf8_decode($resu[4]),
                            "carrera" => utf8_decode($resu[5]),
                            "nombreCarrera" => utf8_decode($resu[6]),
                            "legajo" => utf8_decode($resu[7]),
                            "plan" => utf8_decode($resu[8]),
                            "version" => utf8_decode($resu[9]),
                            "materia" => utf8_decode($resu[10]),
                            "nombreMateria" => utf8_decode($resu[11]),
                            "fecha" => utf8_decode($resu[12]),
                            "resultado" => utf8_decode($resu[13]),
                            "nota" => utf8_decode($resu[14]),
                            "formaAprobacion" => utf8_decode($resu[15]),
                            "tipoActa" => utf8_decode($resu[16]),
                            "acta" => utf8_decode($resu[17]),
                            "actaPromocion" => utf8_decode($resu[18]),
                            "nroResolucion" => utf8_decode($resu[19]),
                            "descripcionNota" => utf8_decode($resu[20]),
                            "promedioCon" => utf8_decode($resu[21]),
                            "concepto" => utf8_decode($resu[22]),
                            "calidad" => utf8_decode($resu[23]),
                            "tipoDocDescripcion" => utf8_decode($resu[24]),
                            "nombreFacultad" => utf8_decode($resu[25]),
                            "interesado" => utf8_decode($resu[26]),
                            "tipoDeCarrera" => utf8_decode($resu[27]),
                            "promedioPorResolucion" => null,
                            "promedioSin" => utf8_decode($resu[28]),
                            "localidad" => utf8_decode($resu[29]),
                            "fechaResolucion" => utf8_decode($resu[30]),
                            "nroResolucionPlan" => utf8_decode($resu[31]),
                            "titSuperiorPrevio" => utf8_decode($resu[32]),
                            "institucionOtorgante" => utf8_decode($resu[33]));
                        $j++;
                    }

                } 
            } else {
                syslog(LOG_ERR, "[error] [obtenerMateriasCertificado9] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }          
            
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 9 en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure sp820_certhaca_dig('" . $ua . "', '" . $carrera . "', '" . $legajo . "', '" . $corresponda . "');";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                } else {
                    $resultado = "";
                }

                if ($resultado != "" && !empty($resultado)) {
                    $j = 0;
                    foreach ($resultado as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                            "ua" => $resu[0],
                            "nroInscripcion" => $resu[1],
                            "apellido" => $resu[2],
                            "nombres" => $resu[3],
                            "nroDocumento" => $resu[4],
                            "carrera" => $resu[5],
                            "nombreCarrera" => $resu[6],
                            "legajo" => $resu[7],
                            "plan" => $resu[8],
                            "version" => $resu[9],
                            "materia" => $resu[10],
                            "nombreMateria" => $resu[11],
                            "fecha" => $resu[12],
                            "resultado" => $resu[13],
                            "nota" => $resu[14],
                            "formaAprobacion" => $resu[15],
                            "tipoActa" => $resu[16],
                            "acta" => $resu[17],
                            "actaPromocion" => $resu[18],
                            "nroResolucion" => $resu[19],
                            "descripcionNota" => $resu[20],
                            "promedioCon" => $resu[21],
                            "concepto" => $resu[22],
                            "calidad" => $resu[23],
                            "tipoDocDescripcion" => $resu[24],
                            "nombreFacultad" => $resu[25],
                            "interesado" => $resu[26],
                            "tipoDeCarrera" => $resu[27],
                            "promedioPorResolucion" => $resu[28],
                            "promedioSin" => $resu[29],
                            "localidad" => $resu[30],
                            "fechaResolucion" => $resu[31],
                            "nroResolucionPlan" => $resu[32],
                            "titSuperiorPrevio" => $resu[33],
                            "institucionOtorgante" => $resu[34]);
                        $j++;
                    }
                }
            } else {
                    syslog(LOG_ERR, "[error] [obtenerMateriasCertificado9] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $datos;
    }

    function obtenerMateriasCertificado5($db, $ua, $carrera, $legajo, $observaciones, $corresponda, $exterior, $solicitud) {
        $datos = array();
        $general = new Generales();        
        $titulo = '0';        
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 5 en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $parametros = array($solicitud);
                $rep = new RepositorioWS();                    
                $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_constancia_actividades_aprobadas_dig", $objCC);
                if (!empty($salida) && $salida[0] != 4) {                   
                    $j = 0;
                    foreach ($salida as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                            "ua" => $resu[0],
                            "nombreFacultad" => utf8_decode($resu[1]),
                            "nroInscripcion" => utf8_decode($resu[2]),
                            "apellido" => utf8_decode($resu[3]),
                            "nombres" => utf8_decode($resu[4]),
                            "tipoDocDescripcion" => utf8_decode($resu[5]),
                            "nroDocumento" => utf8_decode($resu[6]),
                            "carrera" => utf8_decode($resu[7]),
                            "nombreCarrera" => utf8_decode($resu[8]),
                            "nombreCarreraReducido" => utf8_decode($resu[9]),
                            "legajo" => utf8_decode($resu[10]),
                            "planAlumno" => utf8_decode($resu[11]),
                            "calidad" => utf8_decode($resu[12]),
                            "materia" => utf8_decode($resu[13]),
                            "nombreMateria" => utf8_decode($resu[14]),
                            "nombreMateriaReducido" => utf8_decode($resu[15]),
                            "fecha" => utf8_decode($resu[16]),
                            "resultado" => utf8_decode($resu[17]),
                            "nota" => utf8_decode($resu[18]),
                            "formaAprobacion" => utf8_decode($resu[19]),
                            "tipoActa" => utf8_decode($resu[20]),
                            "acta" => utf8_decode($resu[21]),
                            "actaPromocion" => utf8_decode($resu[22]),
                            "nroResolucion" => utf8_decode($resu[23]),
                            "plan" => utf8_decode($resu[24]),
                            "version" => utf8_decode($resu[25]),
                            "escalaNota" => utf8_decode($resu[26]),
                            "descripcionNota" => utf8_decode($resu[27]),
                            "observaciones" => utf8_decode($resu[28]),
                            "interesado" => utf8_decode($resu[29]),
                            "localidad" => utf8_decode($resu[30]),
                            "pais" => utf8_decode($resu[31]),
                            "promedioSin" => utf8_decode($resu[32]),
                            "exterior" => utf8_decode($resu[33]),
                            "concepto" => utf8_decode($resu[34]),
                            "tipoDeCarrera" => utf8_decode($resu[35]),
                            "promedioPorResolucion" => utf8_decode($resu[36]),
                            "cantMateriasPlan" => utf8_decode($resu[37]),
                            "cantMateriasObligAprobadas" => utf8_decode($resu[38]),
                            "titSuperiorPrevio" => utf8_decode($resu[39]),
                            "institucionOtorgante" => utf8_decode($resu[40]));
                        $j++;
                    }
                } 
            } else {
                syslog(LOG_ERR, "[error] [obtenerMateriasCertificado5] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
            
        } else {
        
            $titulo = '0';
            syslog(LOG_ERR, "[info] Obtener materias de certificado 5 en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure sp820_CertMatAprob('" . $ua . "', '" . $carrera . "', '" . $legajo . "', '" . $observaciones . "', '" . $corresponda . "', '" . $exterior . "');";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                } else {
                    $resultado = "";
                }

                if ($resultado != "" && !empty($resultado)) {
                    $j = 0;
                    foreach ($resultado as $resu) {
                        // ver los datos requeridos para el certificado
                        $datos[$j] = array("renglon" => $j + 1,
                            "ua" => $resu[0],
                            "nombreFacultad" => $resu[1],
                            "nroInscripcion" => $resu[2],
                            "apellido" => $resu[3],
                            "nombres" => $resu[4],
                            "tipoDocDescripcion" => $resu[5],
                            "nroDocumento" => $resu[6],
                            "carrera" => $resu[7],
                            "nombreCarrera" => $resu[8],
                            "nombreCarreraReducido" => $resu[9],
                            "legajo" => $resu[10],
                            "planAlumno" => $resu[11],
                            "calidad" => $resu[12],
                            "materia" => $resu[13],
                            "nombreMateria" => $resu[14],
                            "nombreMateriaReducido" => $resu[15],
                            "fecha" => $resu[16],
                            "resultado" => $resu[17],
                            "nota" => $resu[18],
                            "formaAprobacion" => $resu[19],
                            "tipoActa" => $resu[20],
                            "acta" => $resu[21],
                            "actaPromocion" => $resu[22],
                            "nroResolucion" => $resu[23],
                            "plan" => $resu[24],
                            "version" => $resu[25],
                            "escalaNota" => $resu[26],
                            "descripcionNota" => $resu[27],
                            "observaciones" => $resu[28],
                            "interesado" => $resu[29],
                            "localidad" => $resu[30],
                            "pais" => $resu[31],
                            "promedioSin" => $resu[32],
                            "exterior" => $resu[33],
                            "concepto" => $resu[34],
                            "tipoDeCarrera" => $resu[35],
                            "promedioPorResolucion" => $resu[36],
                            "cantMateriasPlan" => $resu[37],
                            "cantMateriasObligAprobadas" => $resu[38],
                            "titSuperiorPrevio" => $resu[39],
                            "institucionOtorgante" => $resu[40]);
                        $j++;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [obtenerMateriasCertificado5] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $datos;
    }

    function obtenerDatosTramiteDiplomaDigital($db, $ua, $solicitud) {
        $datos = array();
        $general = new Generales();        
        $titulo = '0';        
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Obtener datos para tramite de diploma digital en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $parametros = array($solicitud);
                $rep = new RepositorioWS();                    
                $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_datos_tramite_diploma_digital", $objCC);
                if (!empty($salida) && $salida[0] != 4) {                   
                    $j = 0;
                    foreach ($salida as $resu) {
                        // ver los datos requeridos para el diploma digital
                        $datos[$j] = array("apellido" => is_null($resu[0]) ? '' : $resu[0],
                            "nombres" => is_null($resu[1]) ? '' : $resu[1],
                            "sexo" => is_null($resu[2]) ? '' : $resu[2],
                            "fecha_nacimiento" => is_null($resu[3]) ? '' : $resu[3],
                            "cod_pais_dni" => $resu[4],
                            "tipo_doc" => $resu[5],
                            "tipo_doc_descripcion" => is_null($resu[6]) ? '' : $resu[6],
                            "nro_documento" => is_null($resu[7]) ? '' : $resu[7],
                            "carrera" => $resu[8],
                            "nombre_carrera" => is_null($resu[9]) ? '' : $resu[9],
                            "tipo_de_carrera" => is_null($resu[10]) ? '' : $resu[10],
                            "localidad_nacimiento" => is_null($resu[11]) ? '' : $resu[11],
                            "provincia_nacimiento" => is_null($resu[12]) ? '' : $resu[12],
                            "pais_nacimiento" => is_null($resu[13]) ? '' : $resu[13],
                            "expediente" => is_null($resu[14]) ? '' : $resu[14],
                            "diploma_impreso" => is_null($resu[15]) ? '' : $resu[15],
                            "autorizante_retiro" => $resu[16],
                            "url_foto" => is_null($resu[17]) ? '' : $resu[17],
                            "fecha_egreso" => is_null($resu[18]) ? '' : $resu[18],
                            "resolucion_ministerial" => is_null($resu[19]) ? '' : $resu[19],
                            "nombre_titulo" => is_null($resu[20]) ? '' : $resu[20],
                            "nombre_tesina" => is_null($resu[21]) ? '' : $resu[21],
                            "nro_solicitud_egreso" => $resu[22],
                            "codigo_titulo" => $resu[23],
                            "es_titulo_intermedio" => $resu[24],
                            "es_extranjero" => $resu[25],
							"titulo_anterior" => $resu[26],
                            "es_col_sec_extranjero" => $resu[27],
                            "tipo_tramite" => $resu[28],
                            "path_nuxeo" => $resu[29]);
                        $j++;
                    }
                } 
            } else {
                syslog(LOG_ERR, "[error] [obtenerDatosDiplomaDigital] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Obtener datos para tramite de diploma digital en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure sp820_datos_tramite_diploma_digital(" . $solicitud . ");";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                } else {
                    $resultado = "";
                }

                if ($resultado != "" && !empty($resultado)) {
                    $j = 0;
                    foreach ($resultado as $resu) {
                        // ver los datos requeridos para el diploma digital
                        $datos[$j] = array("apellido" => utf8_encode($resu[1]),
                            "nombres" => utf8_encode($resu[2]),
                            "sexo" => utf8_encode($resu[3]),
                            "fecha_nacimiento" => utf8_encode($resu[4]),
                            "cod_pais_dni" => $resu[5],
                            "tipo_doc" => $resu[6],
                            "tipo_doc_descripcion" => utf8_encode($resu[7]),
                            "nro_documento" => utf8_encode($resu[8]),
                            "carrera" => $resu[9],
                            "nombre_carrera" => utf8_encode($resu[10]),
                            "tipo_de_carrera" => utf8_encode($resu[11]),
                            "localidad_nacimiento" => utf8_encode($resu[12]),
                            "provincia_nacimiento" => utf8_encode($resu[13]),
                            "pais_nacimiento" => utf8_encode($resu[14]),
                            "expediente" => utf8_encode($resu[15]),
                            "diploma_impreso" => utf8_encode($resu[16]),
                            "autorizante_retiro" => utf8_encode($resu[17]),
                            "url_foto" => utf8_encode($resu[18]),
                            "fecha_egreso" => utf8_encode($resu[19]),
                            "resolucion_ministerial" => utf8_encode($resu[20]),
                            "nombre_titulo" => utf8_encode($resu[21]),
                            "nombre_tesina" => utf8_encode($resu[22]),
                            "nro_solicitud_egreso" => $resu[23],
                            "codigo_titulo" => $resu[24],
                            "es_titulo_intermedio" => $resu[25],
                            "es_extranjero" => $resu[26],
                            "titulo_anterior" => utf8_encode($resu[27]),
                            "es_col_sec_extranjero" => $resu[28],
                            "tipo_tramite" => $resu[29],
                            "path_nuxeo" => $resu[30]);
                        $j++;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [obtenerDatosDiplomaDigital] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $datos;
    }

    function obtenerDatosCertificadoTT($db, $ua, $solicitud) {
        $datos = array();
        $general = new Generales();        
        $titulo = '0';        
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Obtener datos para certificado de titulo en tramite en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $parametros = array($solicitud);
                $rep = new RepositorioWS();               
                $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_constancia_titulo_tramite", $objCC);
                if (!empty($salida) && $salida[0] != 4) {                   
                    $j = 0;
                    foreach ($salida as $resu) {
                        // ver los datos requeridos para el certificado de titulo en tramite
                        $datos[$j] = array("apellido_y_nombre" => utf8_decode($resu[0]),
                            "documento_principal" => utf8_decode($resu[1]),
                            "fecha_nacimiento_alumno" => utf8_decode($resu[2]),
                            "certificado_nombre" => utf8_decode($resu[3]),
                            "nro_expediente" => $resu[4],
                            "fecha_egreso_alumno" => utf8_decode($resu[5]),
                            "localidad_nombre" => utf8_decode($resu[6]),
                            "provincia_nombre" => utf8_decode($resu[7]),
                            "pais_nombre" => utf8_decode($resu[8]),
                            "nombre_institucion" => utf8_decode($resu[9]),
                            "ra_nombre" => utf8_decode($resu[10]),
                            "ra_direccion" => utf8_decode($resu[11]),
                            "ra_cp" => utf8_decode($resu[12]),
                            "ra_telefono" => utf8_decode($resu[13]),
                            "ra_email" => utf8_decode($resu[14]));
                        $j++;
                    }
                } 
            } else {
                syslog(LOG_ERR, "[error] [obtenerDatosCertificadoTT] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Obtener datos para certificado de titulo en tramite en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure sp820_constancia_titulo_tramite(" . $solicitud . ");";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                } else {
                    $resultado = "";
                }

                if ($resultado != "" && !empty($resultado)) {
                    $j = 0;
                    foreach ($resultado as $resu) {
                        // ver los datos requeridos para el diploma digital
                        $datos[$j] = array("apellido_y_nombre" => $resu[1],
                            "documento_principal" => $resu[2],
                            "fecha_nacimiento_alumno" => $resu[3],
                            "certificado_nombre" => $resu[4],
                            "nro_expediente" => $resu[5],
                            "fecha_egreso_alumno" => $resu[6],
                            "localidad_nombre" => $resu[7],
                            "provincia_nombre" => $resu[8],
                            "pais_nombre" => $resu[9],
                            "nombre_institucion" => $resu[10],
                            "ra_nombre" => $resu[11],
                            "ra_direccion" => $resu[12],
                            "ra_cp" => $resu[13],
                            "ra_telefono" => $resu[14],
                            "ra_email" => $resu[15]);
                        $j++;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [obtenerDatosCertificadoTT] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $datos;
    }

    function registrarImpresion($idCertificado, $db, $fecha = null) {
        $registro = false;
        $general = new Generales();
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Registrar impresion en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {

                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $objCC->beginTransaction();
                    $strSQL = "UPDATE sga_constancias_solicitud SET fecha_entrega = current_timestamp WHERE solicitud = '" . $idCertificado . "'";
                    $sth = $objCC->prepare($strSQL);
                    $sth->execute();
                    if ($sth->errorCode() == 0) {
                        $registro = true;
                        $objCC->commit();                
                    } else {
                        syslog(LOG_ERR, "[error] " . $sth->errorInfo()[2]. " base de datos ". $db);
                        $objCC->rollBack();
                    }

            } else {
                syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
        } else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Registrar impresion en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $objCC->StartTrans();
                $strSQL = "UPDATE sga_certif_pedidos SET fecha_de_emision = current WHERE certif_pedido = '" . $idCertificado . "'";
                $objCC->Execute($strSQL);
                $objCC->CompleteTrans(); // Commit
                // $objCC->FailTrans(); // Rollback
                $objCC->Close();
                $registro = true;
            } else {
                syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return $registro;
    }

    function registrarUrl($db, $expediente, $url, $tipoNotificacion) {
        $general = new Generales();
        if ($db == 'guarani3_') {
            syslog(LOG_ERR, "[info] Registrar url en POSTGRES");
            $titulo = '7';
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($expediente, $url, $tipoNotificacion);
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_cambiar_url_descarga_certif", $objCC);             
                    if (!empty($salida) && $salida[0] != 4) {
                        if ($salida[0][0] == 1) {
                            return true;
                        }   
                    }                    
            } else {
                syslog(LOG_ERR, "[error] [registrarUrl] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
        } else {

            $titulo = '0';
            syslog(LOG_ERR, "[info] Registrar url en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure web_serv_cambiar_url_descarga_certif('" . $expediente . "', '" . $url . "', '" . $tipoNotificacion . "');";
                // return $strSQL;
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                    if ($resultado[0][0] == 1) {
                        return true;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [registrarUrl] No fue posible conectarse a la base de datos: " . $db);
            }
        }
        return false;
    }

    function rechazarValidacion($db, $expediente, $motivoRechazo) {
        $general = new Generales();
        if ($db == 'guarani3_') {
            $titulo = '7';
            syslog(LOG_ERR, "[info] Rechazar validación en POSTGRES");
            //Postgres
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {                
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($expediente, utf8_encode($motivoRechazo));
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_rechazar_validacion", $objCC);       
                    if (!empty($salida) && $salida[0] != 4) {
                        if ($salida[0][0] == 1) {
                            return true;
                        }
                    }                    
            } else {
                syslog(LOG_ERR, "[error] [rechazarValidacion] No fue posible conectarse a la base de datos: " . $uas[$i]);
            }
	} else {
            $titulo = '0';
            syslog(LOG_ERR, "[info] Rechazar validaciÃ³n en " . $db);
            $objCC = $general->conectar($db);
            if (!is_int($objCC)) {
                $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                $strSQL = "execute procedure web_serv_rechazar_validacion('" . $expediente . "', '" . $motivoRechazo . "');";
                $salida = $objCC->Execute($strSQL);
                $objCC->Close();
                if ($salida && ($salida->RecordCount() > 0)) {
                    $resultado = $salida->getRows();
                    if ($resultado[0][0] == 1) {
                        return true;
                    }
                }
            } else {
                syslog(LOG_ERR, "[error] [rechazarValidacion] No fue posible conectarse a la base de datos: " . $db);
            }
        }
    return false;
    }

    function enviarMail($tituloMail, $mensaje, $campoBusqueda, $datoBusqueda, $db = null) {
        $general = new Generales();
        if (is_null($db)) {
            $uas = $general->obtenerTodasUA();
        } else {
            $uas[0] = $db;
        }
        $titulo = '';
        for ($i = 0; $i < count($uas); $i++) {
            // Ver el caso de guarani3 (datosAcademicosCompletos)
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                syslog(LOG_ERR, "[info] Envio de mail en POSTGRES");
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $campoBusqueda = ($campoBusqueda == 'id_certif_pedido') ? 'solicitud' : $campoBusqueda;
                    $parametros = array(mb_convert_encoding($tituloMail, 'UTF-8', 'ISO-8859-1'), mb_convert_encoding($mensaje, 'UTF-8', 'ISO-8859-1'), $campoBusqueda, $datoBusqueda);
                    $rep = new RepositorioWS();
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_nuevo_anuncio_mail", $objCC);
                    if (!empty($salida) && $salida[0] != 4) {
                        if ($salida[0][0] == 1) {
                            closelog();
                            return true;
                        }
                    } 
                } else {
                    syslog(LOG_ERR, "[error] [enviarMail] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                $titulo = '0';
                syslog(LOG_ERR, "[info] Envio de mail en " . $uas[$i]);
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
					$strSQL = "execute procedure web_serv_nuevo_anuncio_mail('{$tituloMail}', '{$mensaje}', '{$campoBusqueda}', '{$datoBusqueda}');";
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                        if ($resultado[0][0] == 1) {
                            closelog();
                            return true;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] [enviarMail] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return false;
    }

    function obtenerUAMesaEntradas($ua) {
        $idMDE = new stdClass();
        switch ($ua) {
            case "EIS":
                $idMDE->alumnado = 237;
                $idMDE->mesaEntrada = 3;
                $idMDE->origenes = 3;
                $idMDE->nombreMesaEntrada = "EIS";
                break;
            case "ESS":
            case "07":
                $idMDE->alumnado = 606;
                $idMDE->mesaEntrada = 5;
                $idMDE->origenes = 5;
                $idMDE->nombreMesaEntrada = "ESS";
                break;
            case "EUA":
            case 'CU-RA':
            case '09':
                $idMDE->alumnado = 10256;
                $idMDE->mesaEntrada = 10245;
                $idMDE->origenes = 10245;
                $idMDE->nombreMesaEntrada = "CURA";
                break;
            case "EUAA":
            case 'CU-G':
            case "11":
                $idMDE->alumnado = 10266;
                $idMDE->mesaEntrada = 10246;
                $idMDE->origenes = 10246;
                $idMDE->nombreMesaEntrada = "CUG";
                break;
            case "FADU":
            case "12":
                $idMDE->alumnado = 113;
                $idMDE->mesaEntrada = 4;
                $idMDE->origenes = 4;
                $idMDE->nombreMesaEntrada = "FADU";
                break;
            case "FBCB":
            case "03":
                $idMDE->alumnado = 606;
                $idMDE->mesaEntrada = 5;
                $idMDE->origenes = 5;
                $idMDE->nombreMesaEntrada = "FBCB";
                break;
            case "FCA":
            case "05":
                $idMDE->alumnado = 40;
                $idMDE->mesaEntrada = 6;
                $idMDE->origenes = 6;
                $idMDE->nombreMesaEntrada = "FCA";
                break;
            case "FCE":
            case "02":
                $idMDE->alumnado = 274;
                $idMDE->mesaEntrada = 8;
                $idMDE->origenes = 8;
                $idMDE->nombreMesaEntrada = "FCE";
                break;
            case "FCJS":
            case "SIU":
            case "10":
                $idMDE->alumnado = 443;
                $idMDE->mesaEntrada = 9;
                $idMDE->origenes = 9;
                $idMDE->nombreMesaEntrada = "FCJS";
                break;
            case "FCM":
            case "ECM":
            case "15":
                $idMDE->alumnado = 327;
                $idMDE->mesaEntrada = 10;
                $idMDE->origenes = 10;
                $idMDE->nombreMesaEntrada = "FCM";
                break;
            case "ECM":
                $idMDE->alumnado = 327;
                $idMDE->mesaEntrada = 10;
                $idMDE->origenes = 10;
                $idMDE->nombreMesaEntrada = "FCM";
                break;
            case "FCV":
            case "13":
                $idMDE->alumnado = 73;
                $idMDE->mesaEntrada = 11;
                $idMDE->origenes = 11;
                $idMDE->nombreMesaEntrada = "FCV";
                break;
            case "FHUC":
            case "06":
                $idMDE->alumnado = 380;
                $idMDE->mesaEntrada = 12;
                $idMDE->origenes = 12;
                $idMDE->nombreMesaEntrada = "FHUC";
                break;
            case "FICH":
            case "04":
                $idMDE->alumnado = 219;
                $idMDE->mesaEntrada = 13;
                $idMDE->origenes = 13;
                $idMDE->nombreMesaEntrada = "FICH";
                break;
            case "FIQ":
            case "01":
                $idMDE->alumnado = 134;
                $idMDE->mesaEntrada = 14;
                $idMDE->origenes = 14;
                $idMDE->nombreMesaEntrada = "FIQ";
                break;
            case "ISM":
            case "08":
                $idMDE->alumnado = 426;
                $idMDE->mesaEntrada = 15;
                $idMDE->origenes = 15;
                $idMDE->nombreMesaEntrada = "ISM";
                break;
            default :
                $idMDE->alumnado = 1;
                $idMDE->mesaEntrada = 1;
                $idMDE->origenes = 1;
                $idMDE->nombreMesaEntrada = "Rectorado";
                break;
        }
        return $idMDE;
    }

    function setPathRequisitoDiploma($hashRequisito, $pathNuxeo, $uidNuxeo) {
        $general = new Generales();
        $uas = $general->obtenerTodasUA();
        $titulo = '0';
        $estado = false;
        for ($i = 0; $i < count($uas); $i++) {
            if ($uas[$i] == 'guarani3_') {
                $titulo = '7';
                // Postgres
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {                    
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $parametros = array($hashRequisito, $pathNuxeo, $uidNuxeo);
                    $rep = new RepositorioWS();                    
                    $salida = $rep->ejecutaFuncionPostgre($parametros, "funl_ws_registrar_path_requisito_diploma", $objCC);
                    if (!empty($salida) && $salida[0] != 4) { 
                        if ($salida[0][0] == 1) {
                            $estado = true;                            
                        }                                                          
                    } else {                                    
                        syslog(LOG_ERR, "[error] " . ((empty($salida)) ? 'La función no devolvió datos' : $salida[0][0]) . " - " . ((empty($salida)) ? 'funl_ws_registrar_path_requisito_diploma' : $salida[0][1]). " - base de datos ". $uas[$i]);                                           
                    }                       
                } else {
                    syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            } else {
                $titulo = '0';
                // Informix
                $strSQL = "execute procedure web_serv_registrar_path_requisito_diploma('" . $hashRequisito . "', '" . $pathNuxeo . "', '" . $uidNuxeo . "');";
                $objCC = $general->conectar($uas[$i]);
                if (!is_int($objCC)) {
                    $ADODB_FETCH_MODE = ADODB_FETCH_ASSOC;
                    $salida = $objCC->Execute($strSQL);
                    $objCC->Close();
                    if ($salida && ($salida->RecordCount() > 0)) {
                        $resultado = $salida->getRows();
                        if ($resultado[0][0] == 1) {
                            $estado = true;
                        }
                    }
                } else {
                    syslog(LOG_ERR, "[error] No fue posible conectarse a la base de datos: " . $uas[$i]);
                }
            }
        }
        return $estado;
    }

	public function obtenerDatosSuplemento($alumno, $fecha_egreso)
	{
		syslog(LOG_ERR, "[info] Obtener suplemento al certificado en POSTGRES");
		$general = new Generales();
		$objCC = $general->conectar('guarani3_');

		if ($objCC != CODIGO_ERROR_CONEXION) {
			$rep = new RepositorioWS();
			$bitacora = $tesis = [];
			
			$datos_bitacora = $rep->get_suplemento_reconocimiento_con_fecha($alumno, $fecha_egreso, $objCC);
			if (!empty($datos_bitacora) && $datos_bitacora[0] != 4) {
				$j = 0;
				foreach ($datos_bitacora as $resu) {
					$bitacora[$j] = [
						"renglon"		=> $j + 1,
						"titulo"		=> utf8_decode($resu['titulo']),
						"observaciones" => utf8_decode($resu['observaciones']),
						"fecha"			=> utf8_decode($resu['fecha'])
						];
					$j++;
				}
			}

			$datos_tesis = $rep->get_tesis($alumno, $objCC);
			if (!empty($datos_tesis) && $datos_tesis[0] != 4) {
				$j = 0;
				foreach ($datos_tesis as $resu) {
					$tesis[$j] = [
						"renglon"			=> $j + 1,
						"titulo"			=> utf8_decode($resu['titulo']),
						"fecha_aprobacion"	=> utf8_decode($resu['fecha_aprobacion']),
						"resolucion_tesis"	=> utf8_decode($resu['resolucion_tesis'])
						];
					$j++;
				}
			}			
		}
		else {
			syslog(LOG_ERR, "[error] [obtenerDatosSuplemento] No fue posible conectarse a la base de datos.");
		}
		return ['bitacora' => $bitacora, 'tesis' => $tesis];
	}
}
