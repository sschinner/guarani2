<?php
namespace siu\operaciones\notas_examen;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_actas extends pagelet
{
    function get_nombre()
    {
        return 'actas';
    }

	function get_lista_actas()
	{
		$actas = $this->controlador->modelo()->info__actas_abiertas();
		foreach ($actas as $key => $acta) {
			$actas[$key]['LINK'] = kernel::vinculador()->crear('notas_examen', 'edicion', $acta[catalogo::id]);
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
