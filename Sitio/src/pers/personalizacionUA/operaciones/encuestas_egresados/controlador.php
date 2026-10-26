<?php

namespace personalizacionUA\operaciones\encuestas_egresados;

use Exception;
use siu\errores\error_procesar_datos_censales;
use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\db\db;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\unidad_academica;
set_include_path('.:'.substr_replace(dirname(__FILE__),'/',-60));
require("clientes_ws/kolla/adodb/adodb.inc.php");
require("clientes_ws/kolla/adodb/crypt.inc.php");
include("clientes_ws/kolla/library/funciones.php");
include("clientes_ws/kolla/clientews.php");

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador {

    function accion__index() {
        
        $pagelet = $this->vista()->pagelet('formulario');
        
        $pagelet->ver_pagina(1);
    }

    function accion__ver_pagina() {
        $pagina = kernel::url()->get_param('pagina', 'get');
        $columna = kernel::url()->get_param('col', 'get');
        $orden = kernel::url()->get_param('ord', 'get');

        $pagelet = $this->vista()->pagelet('formulario');
        $pagelet->ver_pagina($pagina, $columna, $orden);

        kernel::renderer()->add($pagelet);
    }

    function accion__guardar() {
        if (kernel::request()->isPost()) {

            $parametros = array();
            $faltaParametro = false;
            $u = new unidad_academica(\siu\guarani::get_ua_id());
            $uA = utf8_encode($u->get_id());
            $parametros['apellido'] = kernel::request()->getPost('apellido');
            $parametros['nombre'] = kernel::request()->getPost('nombre');
            $parametros['email'] = kernel::request()->getPost('email');
            $parametros['tipo'] = kernel::request()->getPost('tipoDni');
            $parametros['nro'] = kernel::request()->getPost('nroDocumento');
            $parametros['sexo'] = kernel::request()->getPost('sexo');
            $parametros['fecha'] = kernel::request()->getPost('fechaNac');
            $parametros['_ua'] = $uA;
           
            if ( (trim($parametros['apellido']) == "") OR (trim($parametros['nombre']) == "")
                    OR  (trim($parametros['email']) == "") OR (trim($parametros['tipo']) == "")
                    OR (trim($parametros['sexo']) == "")OR (trim($parametros['fecha']) == "")){
                $faltaParametro = true;
            }
           if ($faltaParametro == true) {
                $mensajes[] = new guarani_notificacion(guarani_notificacion::error, 'Por favor complete todos los campos.');
                $this->add_var('mensajes', $mensajes);
                kernel::renderer()->add($this->vista()->pagelet('formulario'));
            } else {

                catalogo::consultar('alumno', 'graba_datos_para_kolla', $parametros);

                $parametros = array();
                $parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
                $parametros['plan'] = kernel::persona()->get_id_plan_activo();
                $parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
                $parametros['_ua'] = $uA;
                $datos = catalogo::consultar('alumno', 'datos_principales', $parametros);

                $parametros = array();
                $parametros["ClaveAg"] = $_SESSION['claveKolla'];
                foreach ($datos as $fila) {
                    $parametros["NombreTitulo"] = iconv("ISO-8859-1", "utf-8",$fila[8]);
                    $parametros["NombreTituloFem"] = iconv("ISO-8859-1", "utf-8",$fila[9]);
                    $parametros["CodigoTitulo"] =iconv("ISO-8859-1", "utf-8",$fila[10]);
                    $parametros["AnioEgreso"] = iconv("ISO-8859-1", "utf-8",$fila[12]);
                    $parametros["FechaEgreso"] = iconv("ISO-8859-1", "utf-8",$fila[13]);
                    $parametros["UAKolla"] = iconv("ISO-8859-1", "utf-8",$fila[14]);
                }
                $parametros['apellido'] =iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('apellido'));
                $parametros['nombre'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('nombre'));
                $parametros['email'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('email'));
                $parametros['tipo'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('tipoDni'));
                $parametros['nro'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('nroDocumento'));
                $parametros['sexo'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('sexo'));
                $parametros['fecha'] = iconv("ISO-8859-1", "utf-8",kernel::request()->getPost('fechaNac'));
                $parametros['_ua'] = iconv("ISO-8859-1", "utf-8",$uA);

                
                $mensaje = web_service_insertar_en_kolla($parametros["ClaveAg"], $parametros['apellido'],
                                                        $parametros['nombre'], $parametros['email'], $parametros['tipo'],
                                                        $parametros['nro'], $parametros['sexo'],
                                                        $this->convertirFecha($parametros['fecha'], 10),
                                                        $parametros["NombreTitulo"], $parametros["NombreTituloFem"],
                                                        $parametros["CodigoTitulo"], $parametros["UAKolla"],
                                                        $parametros["AnioEgreso"],
                                                        $this->convertirFecha($parametros["FechaEgreso"], 10));

               // print_r($mensaje);die;
                $pagelet = $this->vista()->mostrar();
                $this->add_var('formulario', $pagelet);
                kernel::renderer()->add($this->vista()->pagelet('formulario'));
            }
        }
    }

    function convertirFecha($fecha, $tipo) {
        $nom_dias = array(0 => "Domingo",
            1 => "Lunes",
            2 => "Martes",
            3 => "Miércoles",
            4 => "Jueves",
            5 => "Viernes",
            6 => "Sábado");

        if ($tipo === 4 or $tipo === 6) {
            $date = mktime(0, 0, 0, substr($fecha, 5, 2), substr($fecha, 8, 2), substr($fecha, 0, 4));
        }

        switch ($tipo) {
            // De 2005-12-20 -> 20/12/2005
            case 1:
                if (strlen($fecha) > 0 && strlen($fecha) < 11 && !(substr($fecha, 4, 1) == '/' || substr($fecha, 4, 1) == '-')) {
                    // si viene un date
                    $fecha = date('Y-m-d', cadena_a_mktime($fecha, $_SESSION["ses_formato_fecha_web"]));
                }
                return substr($fecha, 8, 2) . "/" . substr($fecha, 5, 2) . "/" . substr($fecha, 0, 4);


            // De 19-12-2001 -> 19/12/2001
            case 2: return substr($fecha, 0, 2) . "/" . substr($fecha, 3, 2) . "/" . substr($fecha, 6, 4);

            // De 19/12/2005 -> 2005-12-19 00:00:00
            case 3: return substr($fecha, 6, 4) . "-" . substr($fecha, 3, 2) . "-" . substr($fecha, 0, 2) . ' 00:00:00';

            // De 2005/12/20 -> Lunes 20/12/2005
            case 4: return $nom_dias[date("w", $date)] . ", " . substr($fecha, 8, 2) . "/" . substr($fecha, 5, 2) . "/" . substr($fecha, 0, 4);

            // De 2005/12/20 -> 20-12-2005
            case 5: return str_replace("/", "-", $fecha);

            // De 2005/12/20 -> Lunes
            case 6: return $nom_dias[date("w", $date)];

            // De 12:34:55 -> 12:34
            case 7: return substr($fecha, 0, 2) . ':' . substr($fecha, 3, 2);

            // De 2005-12-19 01:20:00 -> 19/12/2005 01:20
            case 8: return substr($fecha, 8, 2) . "/" . substr($fecha, 5, 2) . "/" . substr($fecha, 0, 4) . " " . substr($fecha, 11, 2) . ':' . substr($fecha, 14, 2);

            // De 2005-12-20 -> 20-12-2005
            case 9: return substr($fecha, 8, 2) . "-" . substr($fecha, 5, 2) . "-" . substr($fecha, 0, 4);

            // De 20/12/2005 -> 2005-12-20  (Se utiliza junto con $objCon->DBDate('2005-12-20') para sp con param ingreso tipo date)
            case 10: return substr($fecha, 6, 4) . "-" . substr($fecha, 3, 2) . "-" . substr($fecha, 0, 2);

            // De 20/12/2005 01:30 -> 2005-12-20 01:30  (Se utiliza junto con $objCon->DBTimeStamp('2005-12-20 01:30:00') para sp con param ingreso tipo date)
            case 11: return substr($fecha, 6, 4) . "-" . substr($fecha, 3, 2) . "-" . substr($fecha, 0, 2) . " " . substr($fecha, 11, 5) . ":00";
        }
    }

}

?>
