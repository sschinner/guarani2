<?php
namespace siu\operaciones\mensajes;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use \siu\modelo\datos\catalogo;

class pagelet_lista_mensajes extends pagelet
{
	const E_ENVIADOS  = 'enviados';
	const E_RECIBIDOS = 'recibidos';

	function ini()
	{
	}

	function get_nombre()
	{
		return 'lista_mensajes';
	}

	function modelo()
	{
		return $this->controlador->modelo();
	}

	protected function agregar_url_leer($mensajes)
	{
		foreach ($mensajes as $key => $mensaje) {
			$mensajes[$key]['URL_LEER'] = kernel::vinculador()->crear('mensajes', 'leer_mensaje', $mensaje[catalogo::id]);
			if (isset($mensaje['ADJUNTOS'])) {
				foreach ($mensaje['ADJUNTOS'] as $key_adj => $archivo) {
					$mensajes[$key]['ADJUNTOS'][$key_adj]['URL_DESCARGA'] = kernel::vinculador()->crear('mensajes', 'descargar', array(
						'm' => $mensaje[catalogo::id],
						'a' => $archivo[catalogo::id]
					));
				}
			}
		}

		return $mensajes;
	}

	protected function agregar_url_leer_enviados($mensajes)
	{
		foreach ($mensajes as $key => $mensaje) {
			$mensajes[$key]['URL_LEER'] = kernel::vinculador()->crear('mensajes', 'leer_mensaje_enviado', $mensaje[catalogo::id]);
			if (isset($mensaje['ADJUNTOS'])) {
				foreach ($mensaje['ADJUNTOS'] as $key_adj => $archivo) {
					$mensajes[$key]['ADJUNTOS'][$key_adj]['URL_DESCARGA'] = kernel::vinculador()->crear('mensajes', 'descargar', array(
						'm' => $mensaje[catalogo::id],
						'a' => $archivo[catalogo::id]
					));
				}
			}
		}

		return $mensajes;
	}

	function prepare()
	{
		$operacion = kernel::ruteador()->get_id_operacion();
	//		$this->add_var_js('url', kernel::vinculador()->crear($operacion, 'leer_mensaje'));

		switch ($this->get_estado()) {
			case self::E_RECIBIDOS:
				$mensajes = $this->modelo()->get_mensajes_recibidos();
				$mensajes = $this->agregar_url_leer($mensajes);
				$this->data['url_enviados'] = kernel::vinculador()->crear($operacion, 'enviados');
				$this->data['vista'] = self::E_RECIBIDOS;
				break;
			case self::E_ENVIADOS:
				$mensajes = $this->modelo()->get_mensajes_enviados();
				$mensajes = $this->agregar_url_leer_enviados($mensajes);
				$this->data['url_recibidos'] = kernel::vinculador()->crear($operacion);
				$this->data['vista'] = self::E_ENVIADOS;
				break;
		}

		$this->data['mensajes'] = $mensajes;
		if (kernel::persona()->es_perfil_docente()) {
			$operacion = kernel::ruteador()->get_id_operacion();
			$this->data['url_enviar'] = kernel::vinculador()->crear($operacion, 'enviar_mensaje');
			$this->data['puede_enviar'] = true;
		} else {
			$this->data['puede_enviar'] = true;
		}
		$this->data['es_docente'] = kernel::persona()->perfil()->es('DOC');
	}
}
?>