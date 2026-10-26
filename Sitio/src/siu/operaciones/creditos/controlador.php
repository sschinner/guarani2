<?php
namespace siu\operaciones\creditos;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
	function accion__detalle(){
		$hash = $this->validate_param('hash', 'get', validador::TIPO_ALPHANUM);
		
		$per_lecs = catalogo::consultar('alumno', 'periodos_lectivos');		
		
		$datos = array();
		$encabezado = array();
		if (isset($per_lecs[$hash])){
			$anio = $per_lecs[$hash][0];
			$per_lec = $per_lecs[$hash][1];
			$parametros = array(
				'nro_inscripcion' =>  kernel::persona()->get_nro_inscripcion(),
				'anio' =>  $anio,
				'periodo_lectivo' => $per_lec
			);
			$encabezado = $per_lecs[$hash];
			$datos = catalogo::consultar('alumno', 'creditos', $parametros);
		}
		
		$clase = 'operaciones\creditos\pagelet_detalle';
		$pl = kernel::localizador()->instanciar($clase, 'items');		
        $this->vista()->add_pagelet($pl);
		
		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
		
		$pl->data['datos'] = $datos;
		$pl->data['encabezado'] = $encabezado;
	}
}
?>