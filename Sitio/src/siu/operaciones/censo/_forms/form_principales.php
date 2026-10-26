<?php
namespace siu\operaciones\censo\_forms;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\forms;

class form_principales extends form_comun
{
	protected $form = 'principales';

	public function init()
	{
		$datos = $this->datos;

		$empresas_celulares = catalogo::consultar('etiquetas', 'empresas_celulares');
		$empresas_celulares  = forms::rs_to_select($empresas_celulares,'-- SELECCIONE --');

		if (!empty($datos['CENS_LOC_PER_LECT'])){
			$this->datos['CENS_LOC_PER_LECT_TEXTO'] = catalogo::consultar(	'etiquetas',
													'nombre_localidad', 
													array(
														'localidad'=>$datos['CENS_LOC_PER_LECT']
														)
												);
		}
		else {
			$this->datos['CENS_LOC_PER_LECT_TEXTO'] = "";
		}

		if (!empty($datos['CENS_LOC_PROC'])){
			$this->datos['CENS_LOC_PROC_TEXTO'] = catalogo::consultar(	'etiquetas',
														'nombre_localidad',
														array(
															'localidad'=>$datos['CENS_LOC_PROC']
															)
													 );
		}
		else {
			$this->datos['CENS_LOC_PROC_TEXTO'] = "";
		}

		if (!empty($datos['CENS_LOC_PERS_ALLEG'])){
			$this->datos['CENS_LOC_PERS_ALLEG_TEXTO'] = catalogo::consultar(	'etiquetas', 
														'nombre_localidad', 
														array(
															'localidad'=>$datos['CENS_LOC_PERS_ALLEG']
															)
													);
		}
		else {
			$this->datos['CENS_LOC_PERS_ALLEG_TEXTO'] = "";
		}
		$this->crear_elementos();
	}
}
?>