<?php

namespace siu\operaciones\inicio_alumno;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;

class controlador extends controlador_base
{
    /**
     *
     * @return \siu\modelo\transacciones\inscripcion_cursada 
     */
    function modelo()
    {
        return null;
    }

    function accion__index()
    {
        $nombre = kernel::persona()->get_nombre();

        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $tiene_noticias = catalogo::consultar('noticias', 'tiene_noticias_por_persona', $parametros);
        $this->vista()->agregar_a_contexto('tiene_noticias', $tiene_noticias);
		$this->vista()->pagelet('lista_encuestas_pendientes')->data['tiene_noticias'] = $tiene_noticias;
    }
	
	function info_periodos_lectivos()
	{
		return catalogo::consultar('unidad_academica', 'periodos_lectivos');
	}
	
	function info_turnos_examen()
	{
		return catalogo::consultar('unidad_academica', 'info_turnos_examen');			
	}
	
	function info_encuestas_pendientes()
	{
		$encuestas_pendientes = kernel::persona()->get_encuestas_pendientes();
		// corte
		$corte = array();
		foreach($encuestas_pendientes as $encuesta){
			$corte[$encuesta['id_grupo']]['desplegar_encuestas'] = $encuesta['desplegar_encuestas'];
			$encuesta['link_encuesta'] = kernel::vinculador()->crear('encuestas_kolla', 'index', $encuesta['id']);
			if ($encuesta['desplegar_encuestas'] == 1){
				$corte[$encuesta['id_grupo']]['titulo_grupo'] = $encuesta['titulo_grupo'];
				$corte[$encuesta['id_grupo']]['encuestas'][] = $encuesta;
			} else {
				$corte[$encuesta['id_grupo']] = $encuesta;
			}
			
		}
		return $corte;
	}
	
    function info_lista_noticias(){
        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        return catalogo::consultar('noticias', 'noticias_por_persona', $parametros);
    }
}
?>
