<?php
namespace siu\operaciones\notas_examen;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_ficha_alumno extends pagelet
{
	protected $data_ficha;
	protected $url_imagen;

	function get_nombre()
	{
		return 'ficha_alumno';
	}

	function set_data($data)
	{
		$this->data_ficha = $data;
	}

	function set_url_imagen($url)
	{
		$this->url_imagen = $url;
	}

	function prepare()
	{
		$this->data = array();
		$this->data['ficha'] = $this->data_ficha;
		$this->data['url_imagen'] = $this->url_imagen;
	}
}
?>