<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;

class rest_legacy
{

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function inscriptos_carrera($parametros)
    {
        $sql = "execute procedure ws_insc_a_carrera()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);

        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[3] == $parametros['_ua']){

                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['ANIO_ACADEMICO'] = $fila[1];
                $datos[$key]['PERIODO_INSCRIPCION'] = $fila[2];
                $datos[$key]['CODIGO_UA'] = $fila[3];
                $datos[$key]['NOMBRE_UA'] = $fila[4];
                $datos[$key]['CODIGO_CARRERA'] = $fila[5];
                $datos[$key]['NOMBRE_CARRERA'] = $fila[6];
                $datos[$key]['PLAN'] = $fila[7];
                $datos[$key]['CODIGO_SEDE'] = $fila[8];
                $datos[$key]['NOMBRE_SEDE'] = $fila[9];
                $datos[$key]['CANT_INSC_CARRERA_TODOS'] = $fila[10];
                $datos[$key]['CANT_INSC_CARRERA_RECHAZADOS'] = $fila[11];
                $datos[$key]['CANT_INSC_CARRERA_ASPIRANTES_SIN_LEGAJO_GENERADO'] = $fila[12];
                $datos[$key]['CANT_INSC_CARRERA_CON_LEGAJO_CONDICIONAL'] = $fila[13];
                $datos[$key]['CANT_INSC_CARRERA_CON_LEGAJO_DEFINITIVO'] = $fila[14];

            }
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function carrera_titulo($parametros)
    {
        $sql = "execute procedure ws_int_kolla_ca_ti()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[1] == $parametros['_ua']){
                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['CODIGO_UA'] = $fila[1];
                $datos[$key]['CODIGO_CARRERA'] = $fila[2];
                $datos[$key]['CODIGO_TITULO'] = $fila[3];
            }
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function carrera($parametros)
    {
        $sql = "execute procedure ws_int_kolla_carr()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            $datos[$key]['FECHA_PROCESO'] = $fila[0];
            $datos[$key]['NOMBRE'] = $fila[1];
            $datos[$key]['CODIGO'] = $fila[2];
            $datos[$key]['ESTADO'] = $fila[3];
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function institucion($parametros)
    {
        $sql = "execute procedure ws_int_kolla_inst()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            $datos[$key]['FECHA_PROCESO'] = $fila[0];
            $datos[$key]['NOMBRE_INSTITUCION'] = $fila[1];
            $datos[$key]['CODIGO_INSTITUCION'] = $fila[2];
            $datos[$key]['CODIGO_INSTITUCION_ARAUCANO'] = $fila[3];
        }
        return $datos;
    }


    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function respacad($parametros)
    {
        $sql = "execute procedure ws_int_kolla_ra()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[2] == $parametros['_ua']){
                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['NOMBRE_RA'] = $fila[1];
                $datos[$key]['CODIGO_RA'] = $fila[2];
                $datos[$key]['TIPO_RA'] = $fila[3];
                $datos[$key]['INSTITUCION'] = $fila[4];
                $datos[$key]['LOCALIDAD'] = $fila[5];
                $datos[$key]['CALLE'] = $fila[6];
                $datos[$key]['NUMERO'] = $fila[7];
                $datos[$key]['CODIGO_POSTAL'] = $fila[8];
                $datos[$key]['TELEFONO'] = $fila[9];
                $datos[$key]['FAX'] = $fila[10];
                $datos[$key]['MAIL'] = $fila[11];
            }
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function respacad_carrera($parametros)
    {
        $sql = "execute procedure ws_int_kolla_ra_ca()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[1] == $parametros['_ua']){
                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['CODIGO_RA'] = $fila[1];
                $datos[$key]['CODIGO_CARRERA'] = $fila[2];
            }
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function respacad_titulo($parametros)
    {
        $sql = "execute procedure ws_int_kolla_ra_ti()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[1] == $parametros['_ua']){
                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['CODIGO_RA'] = $fila[1];
                $datos[$key]['CODIGO_TITULO'] = $fila[2];
            }
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function titulo($parametros)
    {
        $sql = "execute procedure ws_int_kolla_tit()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            $datos[$key]['FECHA_PROCESO'] = $fila[0];
            $datos[$key]['NOMBRE'] = $fila[1];
            $datos[$key]['NOMBRE_FEMENINO'] = $fila[2];
            $datos[$key]['CODIGO'] = $fila[3];
            $datos[$key]['CODIGO_ARAUCANO'] = $fila[4];
            $datos[$key]['ESTADO'] = $fila[5];
        }
        return $datos;
    }

    /**
     * parametros: _ua
     * no_quote: _ua
     * cache: no
     * filas: n
     */
    function graduado($parametros)
    {
        $sql = "execute procedure ws_int_kolla_per()";
        $filas = kernel::db()->consultar($sql, db::FETCH_NUM);
        $datos = array();
        foreach($filas as $key => $fila){
            if($fila[3] == $parametros['_ua']){

                $datos[$key]['FECHA_PROCESO'] = $fila[0];
                $datos[$key]['USUARIO_AUTOGESTION'] = $fila[1];
                $datos[$key]['CLAVE_AUTOGESTION'] = $fila[2];
                $datos[$key]['UNIDAD_ACADEMICA'] = $fila[3];
                $datos[$key]['NRO_INSCRIPCION'] = $fila[4];
                $datos[$key]['APELLIDO'] = $fila[5];
                $datos[$key]['NOMBRES'] = $fila[6];
                $datos[$key]['PAIS_DOCUMENTO'] = $fila[7];
                $datos[$key]['TIPO_DOCUMENTO'] = $fila[8];
                $datos[$key]['NRO_DOCUMENTO'] = $fila[9];
                $datos[$key]['SEXO'] = $fila[10];
                $datos[$key]['FECHA_NACIMIENTO'] = $fila[11];
                $datos[$key]['EMAIL'] = $fila[12];
                $datos[$key]['TITULO'] = $fila[13];
                $datos[$key]['COLACION'] = $fila[14];
                $datos[$key]['FECHA_COLACION'] = $fila[15];

            }
        }
        return $datos;
    }

}