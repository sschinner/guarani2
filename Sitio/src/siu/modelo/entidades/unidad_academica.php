<?php
namespace siu\modelo\entidades;
use siu\modelo\datos\catalogo;

class unidad_academica
{
	protected $id;
	protected $info;
	protected $nombre;

	function __construct($id)
	{
		$this->id = $id;
		$this->info = catalogo::consultar('unidad_academica','info',array('ua' => $this->id));
	}

	function get_id()
	{
		return $this->id;
	}
	
	function get_nombre()
	{
		return $this->info['NOMBRE'];
	}
	
	function get_nombre_institucion()
	{
		return $this->info['NOMBRE_UNIVERSIDAD'];
	}

    function get_localidad_institucion()
    {
        return $this->info['LOCALIDAD'];
    }
	
	function get_fecha_inscripciones()
	{
		
	}

	function get_fecha_inicio_clases()
	{

	}
}
?>