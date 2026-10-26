<?php
namespace siu\operaciones\inicio_docente;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;

class pagelet_actas_examen extends pagelet
{
    function get_nombre()
    {
        return 'actas_examen';
    }

	function get_lista_actas()
	{
		$actas = $this->controlador->modelo()->info__actas_abiertas();
		foreach ($actas as $key => $acta) {
			$actas[$key]['LINK'] = kernel::vinculador()->crear('notas_examen', 'edicion', $acta[\siu\modelo\datos\catalogo::id]);
		}
		
		return $actas;
	}
	
    function prepare()
    {
		$this->data = array();
		$this->data['actas'] = $this->get_lista_actas();
    }
}
?>
