<?php
// openlog("certificados", LOG_PID, LOG_LOCAL0);
syslog(LOG_ERR,"[info] === COMIENZO DE CRON TRAMITES ===");

include_once(dirname(__DIR__) . '/cronTramites/actualizarPago.php');
include_once(dirname(__DIR__) . '/cronTramites/ingresarExpediente.php');
include_once(dirname(__DIR__) . '/cronTramites/ingresarTramite.php');

// Ejecutar funcion que verifica tramites en estado_pago = M
// y verifica el estado del mismo con Medios de cobro
$pagos = new Pagos();
syslog(LOG_ERR,"[info] COMIENZO ACTUALIZACION DE PAGOS");
$pagos->actualizarPago();

// Ejecutar funcion que verifica tramites en estado_pago = N o M
// y fecha_vencimiento_pago > TODAY
syslog(LOG_ERR,"[info] COMIENZO CONTROL DE VENCIMIENTOS");
$pagos->controlarVencimientos();

// Ejecuta funcion que verifica los tramites pagos sin numero
// de expediente y solicita el alta
$expediente = new Expedientes();
syslog(LOG_ERR,"[info] COMIENZO CONEXION CON MESA DE ENTRADAS");
$expediente->ingresarExpediente();

// Ejecuta funcion que verifica los tramites validados sin fecha
// de impresion y registra un nuevo tramite
$tramites = new SistemaTramites();
syslog(LOG_ERR,"[info] COMIENZO CONEXION CON SISTEMA DE TRAMITES");
$tramites->ingresarTramite();

syslog(LOG_ERR,"[info] === FIN DE CRON TRAMITES ===");
// closelog();
