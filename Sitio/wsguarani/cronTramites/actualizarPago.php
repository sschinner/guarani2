<?php

include_once('../../clientes_ws/mediosCobro/clientews.php');
include_once('tramites.php');
include_once('logTramiteAnalitico.php');

class Pagos {

    public $configApp;

    function __construct() {
        $this->configApp = parse_ini_file(dirname(__DIR__) . "../../configApp.ini", true);
    }

    function actualizarPago() {
        $timer = $this->configApp["cronTramites"]["timer"]; // Segundos
        $intentos = $this->configApp["cronTramites"]["intentos"];
        $tramites = new Tramites();
        $clienteWS = new ClienteMediosCobro();
        // Obtener el identificador de los cobros pendientes
        $cobros = $tramites->obtenerIdsCobros();
        $totalCobros = sizeof($cobros);
        $cont = 1;
        syslog(LOG_ERR,"[info] Cantidad de tramites: " . $totalCobros);
        // Consultar el estado del cobro y registrarlo en caso de pago
        // Se realiza un bucle hasta obtener el resultado del WS de cobros
        foreach ($cobros as $cobro) {
            $j = 1;
            do {
                if ($j <> 1) {
                    sleep($timer);
                }
                syslog(LOG_ERR,"[info] Tramite " . $cont . " de " . $totalCobros);
                $estado = $clienteWS->consultarEstadoCobro($cobro["id"]);
                // Ver que retorna estado del WS para ingresar al registro del cobro
                $registro = false;
                if ($estado <> null) {
                    $cobrado = 'false';
                    if (array_key_exists('return', $estado)){
                        if ($estado["return"]["cobrada"] == 'true'){
                            $cobrado = 'true';
                            $registro = $tramites->registrarCobro($cobro["id"], $cobro["db"]);
                            if (!$registro) {
                                syslog(LOG_ERR, "[IMPORTANTE] No se actualiza estado de pago en Guarani: " . $cobro["id"] . " - " . $cobro["db"] . " - " . $estado);
                            }
                        }
                        
                    }
                    
                    if ($cobrado == 'true') {
                        if ($cobro["certificado"] == 102){
                            $titulo = 'Solicitud de diploma';
                            $mensaje = 'Por este medio, le informamos que se ha registrado correctamente el pago de la tasa del diploma por ud. solicitado.';
                        } else {
                            $titulo = 'Solicitud de certificado';
                            $mensaje = 'Por este medio, le informamos que se ha registrado correctamente el pago del certificado por ud. solicitado.';
                        }
                        $campoBusqueda = 'identificador_cobro';
                        $datoBusqueda = $cobro["id"];
                        $mail = $tramites->enviarMail($titulo, $mensaje, $campoBusqueda, $datoBusqueda, $cobro["db"]);
                    }
                    
                } else {
                    syslog(LOG_ERR, "[error] Fallo consulta a Medios de Cobro: " . $cobro["id"] . " - BD: ". $cobro["db"]);
                }
                if ($estado && $registro) {
                    syslog(LOG_ERR, "[info] Actualizacion exitosa del estado de pago: " . $cobro["id"] . " - " . $cobro["db"] . " - Cobrado: " . $cobrado);
                }
                
                $j++;

            } while ((!$registro || !$estado) && ($intentos > $j));
            $cont++;
        }
    }

    function controlarVencimientos() {
        $tramites = new Tramites();
        $tramites->registrarVencidos();
    }

}
