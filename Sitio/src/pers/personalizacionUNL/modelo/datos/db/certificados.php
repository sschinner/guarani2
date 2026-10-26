<?php

namespace personalizacionUNL\modelo\datos\db;

use kernel\kernel;
use kernel\util\db\db;

class certificados extends \siu\modelo\datos\db\certificados {

    /**
     * parametros: _ua, carrera, legajo, anio
     * cache: no
     * filas: n
     */
    function ctr_alumno_reinscripcion($parametros) {
        //  print_r($parametros);die;
        $sql = "EXECUTE PROCEDURE ctr820_reinscrAlumno({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . "," . $parametros['anio'] . ",'')";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return array(
            "estado" => $datos[0],
            "mensaje" => $datos[1]
        );
    }

    /**
     * parametros: id_certif_pedido, fecha_vencimiento_pago, hash_pago, identificador_deuda, path_nuxeo
     * cache: no
     * filas: n
     */
    function guardar_certificado_arancelado($parametros) {
        // $parametros_serialize = kernel::db()->quote(serialize($parametros['parametros']));
        //print_r($parametros);die;
        $sql = "
                INSERT INTO u820_pedidos_certif (
                        id_certif_pedido,
                        estado_pago,
                        validado,
                        fecha_vencimiento_pago,
                        hash_pago,
                        expediente,
                        url_descarga,
                        identificador_deuda,
                        path_nuxeo
                        )
                VALUES (
                        {$parametros['id_certif_pedido']},
                        'N',
                        'N',
                        to_date({$parametros['fecha_vencimiento_pago']}, '%d-%m-%Y'), 
                        {$parametros['hash_pago']},
                        NULL,
                        NULL,
                        {$parametros['identificador_deuda']},
                        {$parametros['path_nuxeo']}
                )
		";

        return kernel::db()->ejecutar($sql);
    }

    /**
     * parametros: ua, nro_solicitud, nro_inscripcion, nro_certificado
     * cache: no
     * filas: n
     */
    function obtiene_idCertif($parametros) {
        //  print_r($parametros);die;
        $sql = "SELECT max(certif_pedido)as id FROM sga_certif_pedidos
                        WHERE unidad_academica = {$parametros['ua']} 
                        AND nro_inscripcion = {$parametros['nro_inscripcion']} 
                        AND nro_transaccion =   {$parametros['nro_solicitud']}
                         AND certificado =   {$parametros['nro_certificado']}";

        return kernel::db()->consultar($sql);
    }

    /**
     * parametros: ua, nro_inscripcion, carrera
     * cache: no
     * filas: n
     */
    function mostrar_certif_descarga($parametros) {

        $sql = "SELECT p.id_certif_pedido, p.url_descarga, TO_CHAR(cp.fecha_de_emision, '%d/%m/%Y')as fecha_de_emision , c.nombre, p.fecha_vencimiento_pago 
                            FROM u820_pedidos_certif p
                            INNER JOIN sga_certif_pedidos cp ON (cp.certif_pedido = p.id_certif_pedido)
                            INNER JOIN sga_certificados c ON (c.certificado = cp.certificado)
                            INNER JOIN sga_certif_argum ca ON (cp.certificado = ca.certificado)
                            INNER JOIN sga_cert_ped_argum pa ON (pa.certif_pedido = cp.certif_pedido AND ca.orden = pa.orden AND ca.nombre = 'carrera' AND argumento = {$parametros['carrera']})
                        WHERE cp.unidad_academica = {$parametros['ua']}
                        AND cp.nro_inscripcion = {$parametros['nro_inscripcion']} 
                        AND p.url_descarga IS NOT NULL";

        return kernel::db()->consultar($sql);
    }

    /**
     * parametros: ua, nro_inscripcion, nro_certificado, carrera
     * cache: no
     * filas: n
     */
    function obtener_fecha_vence($parametros) {

        $sql = "SELECT p.id_certif_pedido,pa.argumento, p.url_descarga, TO_CHAR(cp.fecha_de_emision, '%d/%m/%Y')as fecha_de_emision , c.nombre, TO_CHAR(p.fecha_vencimiento_pago, '%d-%m-%Y')as fecha_vencimiento_pago, p.identificador_cobro
                    FROM u820_pedidos_certif p
                    INNER JOIN sga_certif_pedidos cp ON (cp.certif_pedido = p.id_certif_pedido)
                    INNER JOIN sga_certificados c ON (c.certificado = cp.certificado)
                    INNER JOIN sga_certif_argum ca ON (cp.certificado = ca.certificado)
                    INNER JOIN sga_cert_ped_argum pa ON (pa.certif_pedido = cp.certif_pedido AND ca.orden = pa.orden )
                    WHERE cp.unidad_academica = {$parametros['ua']}
                    AND cp.nro_inscripcion = {$parametros['nro_inscripcion']}
                    AND cp.certificado  = {$parametros['nro_certificado']} 
                    AND cp.copias_pedidas <> cp.copias_impresas
                    AND p.fecha_vencimiento_pago||p.id_certif_pedido = (Select max(u.fecha_vencimiento_pago)||u.id_certif_pedido
                                        					From u820_pedidos_certif u
                        							INNER JOIN sga_certif_pedidos a ON (a.certif_pedido = u.id_certif_pedido)
                        							INNER JOIN sga_certif_argum ca ON (a.certificado = ca.certificado)
                        							INNER JOIN sga_cert_ped_argum cpa ON (cpa.certif_pedido = a.certif_pedido AND ca.orden = cpa.orden AND ca.nombre = 'carrera'  and argumento = {$parametros['carrera']}) 
                        							WHERE a.certificado  = {$parametros['nro_certificado']} 
                        							AND a.unidad_academica = {$parametros['ua']}
                        							AND a.nro_inscripcion = {$parametros['nro_inscripcion']}
                                                                                AND a.fecha_de_emision IS NULL
                                                                                AND u.estado_pago <> 'V'
                        							GROUP BY u.id_certif_pedido)";

        return kernel::db()->consultar($sql);
    }

    /**
     * parametros: _ua, carrera, legajo, certif
     * cache: no
     * filas: n
     */
    function controla_si_esta_pedido($parametros) {

        $sql = "EXECUTE PROCEDURE ctr_alumnocertif({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . "," . $parametros['certif'] . ")";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos[0];
    }

    /**
     * parametros: 
     * cache: no
     * filas: n
     */
    function listado_arancelados() {

        $certificados = array();
        $sql = "SELECT tabname  FROM systables
                    WHERE tabname = 'u820_certificados'";

        $tabla = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        if (!empty($tabla)) {
            $sql = "SELECT * FROM {$tabla[0]} WHERE arancelado='S'";
            $datos = kernel::db()->consultar($sql);

            foreach ($datos as $fila) {
                $certificados[] = $fila['CERTIFICADO'];
            }
        }
        return $certificados;
    }

    /**
     * parametros: _ua, carrera, legajo, anio
     * cache: no
     * filas: n
     */
    function es_ingresante($parametros) {

        $sql = "EXECUTE PROCEDURE sp820_es_ingresante({$parametros['_ua']}" . "," . $parametros['carrera'] . "," . $parametros['legajo'] . "," . $parametros['anio'] . ");";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return $datos[0];
    }

    /**
     * parametros: id_certif_pedido
     * cache: no
     * filas: n
     */
    function controla_si_pago($parametros) {

        $sql = "Select * From u820_pedidos_certif where id_certif_pedido= {$parametros['id_certif_pedido']} ;";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos;
    }

    /**
     * parametros:  _ua, carrera, legajo, certif
     * cache: no
     * filas: n
     */
    function controla_si_esta_vencido($parametros) {

        $sql = " Select upc.estado_pago From sga_certif_pedidos cp, u820_pedidos_certif upc, sga_alumnos a, sga_certif_argum ca, sga_cert_ped_argum cpa
                        WHERE a.legajo = {$parametros['legajo']}
                        AND a.nro_inscripcion =  cp.nro_inscripcion
                        AND cp.certificado = {$parametros['certif']} 
                        AND cp.certif_pedido = upc.id_certif_pedido
                        AND cp.certificado = ca.certificado
                        AND cp.fecha_de_pedido = (Select max(fecha_de_pedido) from sga_certif_pedidos where nro_inscripcion = a.nro_inscripcion and certificado =  {$parametros['certif']} )
                        AND cpa.certif_pedido = cp.certif_pedido 
                        AND ca.orden = cpa.orden 
                        AND ca.nombre = 'carrera'  
                        AND argumento = {$parametros['carrera']} ;";

        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        return $datos[0];
    }
    
    
    /**
     * parametros:   
     * cache: no
     * filas: n
     */
    function nro_transaccion() {
        
        $sql = "execute procedure sp_nroTransaccAG()";
    
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);

        return $datos[0];
    }
    
    /**
     * parametros: _ua, nro_inscripcion, certificado,fecha_de_pedido, copias_pedidas, interfaz, copias_impresas  
     * cache: no
     * filas: n
     */
    function guardar_certificado_solicitado($parametros) {
        
        $sql = "execute procedure sp_nroTransaccAG()";
    
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
        
        $sql = "
                INSERT INTO sga_certif_pedidos (
                        unidad_academica,
                        nro_inscripcion,
                        certificado,
                        fecha_de_pedido,
                        copias_pedidas,
                        nro_transaccion,
                        interfaz,
                        fecha_de_emision,
                        usuario_emisor,
                        copias_impresas
                        )
                VALUES (
                        {$parametros['_ua']},
                        {$parametros['nro_inscripcion']},
                        {$parametros['certificado']},
                        to_date({$parametros['fecha_de_pedido']}, '%d-%m-%Y %H:%M:%S'), 
                        {$parametros['copias_pedidas']},
                        {$datos[0]},
                        {$parametros['interfaz']},
                        NULL,
                        NULL,
                        {$parametros['copias_impresas']}
                )
		";

        kernel::db()->ejecutar($sql);
        return $datos[0];
    }
    
    
    /**
     * parametros: id_certif_pedido,carrera, titulo, imprenta,autorizado_apellido, autorizado_nombre, autorizado_documento, tipo_tramite
     * param_null: autorizado_apellido, autorizado_nombre, autorizado_documento   
     * cache: no
     * filas: n
     */
    function guardar_diploma($parametros) {
        
        $parametros['autorizado_apellido'] =  ($parametros['autorizado_apellido'] == "''" ? 'null' : $parametros['autorizado_apellido']);
        $parametros['autorizado_nombre'] =  ($parametros['autorizado_nombre'] == "''" ? 'null' : $parametros['autorizado_nombre']);
        $parametros['autorizado_documento'] =  ($parametros['autorizado_documento'] == "''" ? 'null' : $parametros['autorizado_documento']);
        
        $sql = "
                INSERT INTO u820_pedidos_certif_diploma (
                        id_certif_pedido,
                        imprenta,
                        requisitos_validados,
                        carrera,
                        titulo,
                        autorizado_apellido,
                        autorizado_nombre,
                        autorizado_documento,
						tipo_tramite
                        )
                VALUES (
                        {$parametros['id_certif_pedido']},
                        {$parametros['imprenta']},
                        'N',
                        {$parametros['carrera']},
                        {$parametros['titulo']},
                        {$parametros['autorizado_apellido']},
                        {$parametros['autorizado_nombre']},
                        {$parametros['autorizado_documento']},
						{$parametros['tipo_tramite']}
                )
		";

        return kernel::db()->ejecutar($sql);
        
    }
    
    /**
     * parametros:  id_certificado
     * cache: no
     * filas: n
     */
    function u820_certificado_solicitado($parametros) {
      
        $sql = "Select * From u820_pedidos_certif 
                    Where id_certif_pedido = {$parametros['id_certificado']}";
    
        $datos = kernel::db()->consultar_fila($sql);
       
        return $datos;
    }
    
    /**
     * parametros:  id_certificado, legajo
     * cache: no
     * filas: n
     */
    function u820_certificado_diploma($parametros) {

        $sql = "Select c.*,t.titulo, CASE WHEN p.sexo = 1 THEN t.nombre 
                        ELSE t.nombre_femenino END as nombre, t.tipo_de_titulo 
                    From u820_pedidos_certif_diploma c
                    JOIN sga_titulos_otorg a ON a.carrera = c.carrera AND a.titulo = c.titulo
                    JOIN sga_titulos as t ON t.titulo = a.titulo
                    JOIN sga_alumnos alu ON alu.legajo = a.legajo AND alu.carrera = a.carrera
                    JOIN sga_personas p ON p.nro_inscripcion = alu.nro_inscripcion 
                    Where id_certif_pedido = {$parametros['id_certificado']}
                    AND  a.legajo = {$parametros['legajo']}";
    
        $datos = kernel::db()->consultar_fila($sql);
        
        return $datos;
    }
    
    
    /**
     * parametros:  nro_inscripcion, nro_certificado, carrera
     * cache: no
     * filas: n
     */
    function buscar_certificados_solicitados($parametros) {

        $sql = "SELECT * from sga_certif_pedidos c, u820_pedidos_certif_diploma p, sga_titulos t, u820_pedidos_certif cp
                            WHERE nro_inscripcion = {$parametros['nro_inscripcion']}
                            AND certificado = {$parametros['nro_certificado']}
                            AND c.certif_pedido = p.id_certif_pedido 
                            AND cp.id_certif_pedido = p.id_certif_pedido
                            AND p.carrera = {$parametros['carrera']}
                            AND t.titulo = p.titulo
                            ";
    
        $datos = kernel::db()->consultar($sql);
        
        return $datos;
    }
    
    /**
     * parametros:  nro_inscripcion, nro_certificado, carrera, titulo
     * cache: no
     * filas: n
     */
    function buscar_el_diploma($parametros) {

        $sql = "SELECT 
                    p.id_certif_pedido,
                    PC.estado_pago,
                    PC.hash_pago,
                    PC.fecha_vencimiento_pago,
                    PC.identificador_deuda, 
                    PC.identificador_cobro,
                    p.imprenta
                FROM 
                    sga_certif_pedidos c
                    JOIN u820_pedidos_certif PC ON c.certif_pedido = PC.id_certif_pedido 
                    JOIN u820_pedidos_certif_diploma p ON c.certif_pedido = p.id_certif_pedido
                WHERE 
                    nro_inscripcion     = {$parametros['nro_inscripcion']}
                    AND certificado     = {$parametros['nro_certificado']}
                    AND p.carrera       = {$parametros['carrera']}
                    AND p.titulo        = {$parametros['titulo']}
                            ";
    
        $datos = kernel::db()->consultar_fila($sql);
        
        return $datos;
    }
    
    /**
     * parametros: id_certif_pedido,requisito, hash, fecha
     * cache: no
     * filas: n
     */
    function guardar_hash_digital($parametros) {
        
        $sql = "
                INSERT INTO u820_pedidos_certif_diploma_req (
                        id_certif_pedido,
                        requisito,
                        hash_notificacion,
                        fecha_actualizacion                        
                        )
                VALUES (
                        {$parametros['id_certif_pedido']},
                        {$parametros['requisito']},
                        {$parametros['hash']},
                        to_date({$parametros['fecha']}, '%d-%m-%Y %H:%M:%S')
                        )";

        return kernel::db()->ejecutar($sql);
        
    }
    
    
    /**
     * parametros:  id_certif
     * cache: no
     * filas: n
     */
    function u820_pedidos_certif_diploma_req($parametros) {

        $sql = "SELECT * from u820_pedidos_certif_diploma_req
                            WHERE id_certif_pedido = {$parametros['id_certif']}
                            ";
    
        $datos = kernel::db()->consultar($sql);
        
        return $datos;
    }
    
    /**
     * parametros: id_certif_pedido, estado_pago, fecha_vencimiento_pago, hash_pago, identificador_deuda
     * cache: no
     */
    function actualiza_deuda($parametros) {


        $sql = "UPDATE u820_pedidos_certif 
                SET     
                    estado_pago             = {$parametros['estado_pago']},
                    fecha_vencimiento_pago  = to_date({$parametros['fecha_vencimiento_pago']}, '%d-%m-%Y'),
                    hash_pago               = {$parametros['hash_pago']},
                    identificador_deuda     = {$parametros['identificador_deuda']},
                    identificador_cobro     = NULL    
                WHERE 
                    id_certif_pedido = {$parametros['id_certif_pedido']} ;";
                    
        return kernel::db()->ejecutar($sql);
    }
    

    /**
     * parametros:   carrera, legajo, certif,ministerial,titulo
     * cache: no
     * filas: n
     */ 
    function controla_cert_analitico($parametros) {
        $sql = "SELECT DISTINCT u820_pedidos_certif.*,
                        sga_cert_ped_argum.argumento as titulo, t.ministerio
                       FROM sga_certif_pedidos,
                               sga_titulos_otorg,
                       sga_cert_ped_argum,
                       u820_pedidos_certif,
                       (SELECT u820_pedidos_certif.id_certif_pedido, sga_cert_ped_argum.argumento as ministerio
                       FROM sga_certif_pedidos,
                               sga_titulos_otorg,
                       sga_cert_ped_argum,
                       u820_pedidos_certif
                       WHERE sga_titulos_otorg.carrera = {$parametros['carrera']}
                       AND sga_titulos_otorg.titulo = {$parametros['titulo']}
                       AND sga_titulos_otorg.legajo  = {$parametros['legajo']}
                       AND sga_certif_pedidos.nro_inscripcion  = sga_titulos_otorg.nro_inscripcion
                       AND sga_certif_pedidos.certificado = {$parametros['certif']}
                       AND sga_cert_ped_argum.certif_pedido = sga_certif_pedidos.certif_pedido
                       AND  (sga_cert_ped_argum.orden  = 5 AND sga_cert_ped_argum.argumento = {$parametros['ministerial']})
                       AND u820_pedidos_certif.id_certif_pedido = sga_cert_ped_argum.certif_pedido) as t
                       WHERE sga_titulos_otorg.carrera = {$parametros['carrera']}
                        AND sga_titulos_otorg.titulo = {$parametros['titulo']}   
                        AND sga_titulos_otorg.legajo  = {$parametros['legajo']}
                       AND sga_certif_pedidos.nro_inscripcion  = sga_titulos_otorg.nro_inscripcion
                       AND sga_certif_pedidos.certificado = {$parametros['certif']}
                       AND sga_cert_ped_argum.certif_pedido = sga_certif_pedidos.certif_pedido
                       AND  (sga_cert_ped_argum.orden  = 3  AND sga_cert_ped_argum.argumento = sga_titulos_otorg.titulo)
                       AND u820_pedidos_certif.id_certif_pedido = sga_cert_ped_argum.certif_pedido
                       AND t.id_certif_pedido = sga_certif_pedidos.certif_pedido 
                       AND u820_pedidos_certif.estado_pago not in ('V') ";
                      /* AND sga_certif_pedidos.certif_pedido = (SELECT max(u820_pedidos_certif.id_certif_pedido)
                       FROM sga_certif_pedidos,
                               sga_titulos_otorg,
                       sga_cert_ped_argum,
                       u820_pedidos_certif
                       WHERE sga_titulos_otorg.carrera = {$parametros['carrera']}
                        AND sga_titulos_otorg.legajo  = {$parametros['legajo']}
                        AND sga_titulos_otorg.titulo = {$parametros['titulo']}    
                       AND sga_certif_pedidos.nro_inscripcion  = sga_titulos_otorg.nro_inscripcion
                       AND sga_certif_pedidos.certificado = {$parametros['certif']}
                       AND sga_cert_ped_argum.certif_pedido = sga_certif_pedidos.certif_pedido
                       AND  (sga_cert_ped_argum.orden  = 5 AND sga_cert_ped_argum.argumento = {$parametros['ministerial']})
                       AND u820_pedidos_certif.id_certif_pedido = sga_cert_ped_argum.certif_pedido)";
        */
        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);
        return $datos;
    }
    
    /**
     * parametros: id_certif_pedido, identificador_cobro
     * cache: no
     */
    function guardar_identificador_cobro($parametros) {
        
        $sql = "
                UPDATE u820_pedidos_certif 
                SET    identificador_cobro = {$parametros['identificador_cobro']}
                WHERE   id_certif_pedido = {$parametros['id_certif_pedido']}
               ";

        return kernel::db()->ejecutar($sql);
        
    }
    
    /**
     * parametros: certif_pedido
     * cache: no
     */
    function argumento_orden_5_cert_pedido($parametros) {
    
        $sql = "SELECT argumento FROM sga_cert_ped_argum WHERE certif_pedido = {$parametros['certif_pedido']} AND orden = 5;";  
        
        return kernel::db()->consultar($sql);

    }
    
    /**
     * parametros: nro_inscripcion
     * cache: no
     */
    function get_pais_tipo_nro_doc($parametros) {
        $sql = "SELECT pais_documento, tipo_documento, nro_documento FROM sga_personas WHERE nro_inscripcion = {$parametros['nro_inscripcion']};";
        
        return kernel::db()->consultar($sql);
    }
    
    /**
     * parametros: nro_inscripcion
     * cache: no
     */
    function get_path_nuxeo($parametros) {
        $sql = "SELECT LIMIT 1 path_nuxeo 
                    FROM sga_certif_pedidos 
                    JOIN u820_pedidos_certif ON certif_pedido = id_certif_pedido
                    WHERE nro_inscripcion = {$parametros['nro_inscripcion']} AND certificado = 102 AND path_nuxeo IS NOT NULL;";
                    
        return kernel::db()->consultar($sql);                   
    }
}
