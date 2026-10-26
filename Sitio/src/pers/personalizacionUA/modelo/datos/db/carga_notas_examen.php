<?php

namespace personalizacionUA\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;

class carga_notas_examen extends \siu\modelo\datos\db\carga_notas_examen {

    /**
     * parametros: _ua, tipo_acta, acta, folio
     * cache: no
     * filas: 1
     */
    function acta_folio($parametros) {
        $sql = "execute procedure sp_detActExaDocFol({$parametros['_ua']}, " .
                "{$parametros['tipo_acta']}," .
                "{$parametros['acta']}," .
                "{$parametros['folio']})";
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        $img_mm = kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
        $nuevo = array();
        foreach ($datos as $dato) {
            $renglon = $dato[6];
            $nuevo[$renglon]['TIPO_ACTA'] = $dato[1];
            $nuevo[$renglon]['ACTA'] = $dato[2];
            $nuevo[$renglon]['CARRERA'] = $dato[3];
            $nuevo[$renglon]['LEGAJO'] = $dato[4];
            $nuevo[$renglon]['FOLIO'] = $dato[5];
            $nuevo[$renglon]['RENGLON'] = $dato[6];
            switch ($dato[7]) {
                case "L": 
                    $nuevo[$renglon]['TIPO_INSC'] = "LIBRE";
                    break;
                case "EP":
                    $nuevo[$renglon]['TIPO_INSC'] = "E.PARCIAL";
                    break;
                case "R":
                    $nuevo[$renglon]['TIPO_INSC'] = "REGULAR";
                    break;
                case "PP":
                    $nuevo[$renglon]['TIPO_INSC'] = "P.PENDIENTE";
                    break;
                case "TP":
                    $nuevo[$renglon]['TIPO_INSC'] = "T.PRACTICO";
                    break;
                default :
                    $nuevo[$renglon]['TIPO_INSC'] = "REGULAR";
                    break;
            }
            //$nuevo[$renglon]['TIPO_INSC'] = ($dato[7] == 'L') ? 'LIBRE' : 'REGULAR';
            $nuevo[$renglon]['FECHA'] = $dato[8];
            $nuevo[$renglon]['RESULTADO'] = $dato[9];
            $nuevo[$renglon]['NOTA'] = $dato[10];
            $nuevo[$renglon]['PLAN'] = $dato[11];
            $nuevo[$renglon]['VERSION'] = $dato[12];
            $nuevo[$renglon]['ESTADO_EXAMEN'] = $dato[13];
            $nuevo[$renglon]['NOTA_DESCRIPION'] = $dato[14];
            $nuevo[$renglon]['NOTA_CONCEPTO'] = $dato[15];
            $nuevo[$renglon]['NOMBRE'] = $dato[16];
            $nuevo[$renglon]['DOCUMENTO'] = $dato[17];
            $nuevo[$renglon]['ID_IMAGEN'] = $dato[18];
            if (!empty($nuevo[$renglon]['ID_IMAGEN'])) {
                $nuevo[$renglon]['URL_IMAGEN'] = \siu\modelo\entidades\alumno_foto::url_imagen($nuevo[$renglon]['ID_IMAGEN']);
            } else {
                $nuevo[$renglon]['URL_IMAGEN'] = $img_mm;
            }
        }
        return $nuevo;
    }

}
