<?php
namespace siu\operaciones\cursada;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;
use siu\modelo\entidades\parametro;

class vista extends vista_g3w2
{
	protected $hay_mensajes = false;
	protected $error = false;

	function set_error($error)
	{
		$this->error = $error;
	}

	function set_hay_mensajes($hay_mensajes)
	{
		$this->hay_mensajes = $hay_mensajes;
	}

	protected function before_render()
	{
		$this->agregar_a_contexto('hay_mensajes', $this->hay_mensajes);
		if ($this->hay_mensajes) {
			// se buscan en el controlador que es donde se generan
			klog2('NMS', $this->controlador->get_mensajes());
			$this->agregar_a_contexto('mensajes', $this->controlador->get_mensajes());
		}

		$this->agregar_a_contexto('error', $this->error);
	}

	function ini()
	{
		$clase = 'operaciones\cursada\pagelet_info_materia';
		$pl = kernel::localizador()->instanciar($clase, 'info_materia');
		$this->add_pagelet($pl, 20);

		$clase = 'operaciones\_comun\pagelets\pagelet_lista_materias';
		$pl = kernel::localizador()->instanciar($clase, 'lista_materias');
		$this->add_pagelet($pl, 10);

		$notif_activa = parametro::usa_asignacion_horaria() == 'S';
		if (kernel::agente()->es_browser() && $notif_activa) {
			$clase = 'operaciones\_comun\pagelets\pagelet_notificaciones';
			$pl = kernel::localizador()->instanciar($clase, 'notificaciones');
			$this->add_pagelet($pl, 0);
		}

		kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_inscripcion_cursada"));
	}

	/**
	 * Se agrega una función en especial para poder desactivar la renderización
	 * en caso de haya error
	 * @param type $nombre 
	 */
	function render_pagelet($nombre)
	{
		if (! $this->error) {
			return $this->pagelet($nombre)->render();
		}

		return '';
	}
}
?>