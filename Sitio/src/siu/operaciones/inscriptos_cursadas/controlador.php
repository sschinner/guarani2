<?php
namespace siu\operaciones\inscriptos_cursadas;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use kernel\util\validador;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
    public $comision;
    public $subcomision;

    function accion__info_comision()
    {
        $this->comision = $this->validate_param('c', 'get', validador::TIPO_TEXTO);
        $this->subcomision = $this->validate_param('s', 'get', validador::TIPO_TEXTO,array('allowempty' => true));
        $clase = 'operaciones\inscriptos_cursadas\pagelet_comision';
        $pl = kernel::localizador()->instanciar($clase, 'items');
        $this->vista()->add_pagelet($pl);
        
		/* url bot?n Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
		
        $this->vista()->pagelet('items')->data['alumnos_comision'] = $this->get_info_comision();
    }
    
    function get_lista_comisiones()
    {
//      $parametros = array('nro_inscripcion' =>  kernel::persona()->get_nro_inscripcion());
//		$datos = catalogo::consultar('docente', 'lista_comisiones', $parametros);
        $parametros = array('nro_inscripcion' =>  kernel::persona()->get_nro_inscripcion(),
							'filtro_inscripciones' => $this->vista()->pagelet('items')->filtros['filtro']);
		$datos = catalogo::consultar('docente', 'lista_comisiones_subcomisiones_vigentes', $parametros);
		return $datos;
    }

    public function get_info_comision()
    {
		$datos= array();
		if(empty($this->subcomision))
		{
			$parametros = array('comision' => $this->comision);
			$datos = catalogo::consultar('docente', 'alum_inscriptos_comision', $parametros);			
		}else
		{
			$parametros = array('comision' => $this->comision, 'subcomision'=> $this->subcomision);
			$datos = catalogo::consultar('docente', 'alum_inscriptos_subcomision', $parametros);
		}

        return $datos;
    }
    
	/*Generar excel y pdf con filtros*/
	
	function accion__generar_pdf(){
		$filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
		$pagelet = $this->vista()->pagelet('items');
		$pagelet->set_filtros($filtros);
		parent::accion__generar_pdf();
	}
	
	function accion__generar_excel(){
		$filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
		$pagelet = $this->vista()->pagelet('items');
		$pagelet->set_filtros($filtros);
		parent::accion__generar_excel();
	}
		
	/* Exportación INFO COMISIÓN*/
	function accion__generar_pdf_comision(){
		$this->comision = $this->validate_param('c', 'get', validador::TIPO_TEXTO);
		$this->subcomision = $this->validate_param('s', 'get', validador::TIPO_TEXTO,array('allowempty' => true));
        $clase = 'operaciones\inscriptos_cursadas\pagelet_comision';
        $pl = kernel::localizador()->instanciar($clase, 'items');
        $this->vista()->add_pagelet($pl);
			
		$this->vista()->pagelet('items')->generar_pdf();
	}
	
	function accion__generar_excel_comision(){
		$this->comision = $this->validate_param('c', 'get', validador::TIPO_TEXTO);
		$this->subcomision = $this->validate_param('s', 'get', validador::TIPO_TEXTO,array('allowempty' => true));
        $clase = 'operaciones\inscriptos_cursadas\pagelet_comision';
        $pl = kernel::localizador()->instanciar($clase, 'items');
        $this->vista()->add_pagelet($pl);
			
		$this->vista()->pagelet('items')->generar_excel();
	}
	
	function accion__filtrar(){
		$filtros = array();
		$filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
		$pagelet = $this->vista()->pagelet('items');
		$pagelet->set_filtros($filtros);
		kernel::renderer()->add($pagelet);
	}	
}
?>