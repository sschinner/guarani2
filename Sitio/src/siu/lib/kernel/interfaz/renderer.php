<?php
namespace kernel\interfaz;
use kernel\interfaz\unidad_renderizacion;
use kernel\kernel;

class renderer
{
	protected $unidades = array();
	/**
	 * @var \kernel\nucleo\nuevo_request
	 */
    protected $nuevo_req = false;
	protected $error = false;
	protected $force_ajax = false;
	protected $mensajes = false;
	protected $titulo_notificaciones = false;
	protected $notificaciones = false;
	protected $csrf_token = false;
	protected $cod = false;
	
	function set_error($e, $cod) 
	{
		$this->error = $this->armar_paquete_ajax($cod, $e->getMessage());
		$this->error = array_merge($this->error, $e->get_params());
		
		$this->force_ajax = $e->get_force_ajax();
	}
	
	function reset()
	{
		$this->unidades = array();
	}

	function add(unidad_renderizacion $u)
	{
		if (is_null($u)) {
			throw new error_kernel_interface('La unidad de renderización es nula');
		}
		else{
			$this->unidades[] = $u;
		}
	}

    function set_redireccion(\kernel\nucleo\nuevo_request $nuevo_req)
    {
        $this->nuevo_req = $nuevo_req;
    }
    /**
     * Se utiliza cuando se cambia la operación por menú
     */
    protected function render_vista()
    {
		kernel::pagina()->get_vista()->render_ajax();
    }
    
    protected function render_redireccion()
    {
		$cont = array(
			'url' => $this->nuevo_req->get_url(),
			'tiene_mensaje' => $this->nuevo_req->tiene_mensaje_post_nav()
		);
		if ($this->nuevo_req->tiene_mensaje_post_nav()) {
			$cont['mensaje'] = $this->nuevo_req->get_mensaje_post_nav();
		}
		
		$paquete  = array(
			'cod' => -2,
			'cont' => $cont
		);
		echo $this->json_encode($paquete);
    }
    
	/**
	 * Devuelve verdadero si se va a renderizar la operación completa. falso en cualquier
	 * otro caso
	 */
	function operacion_completa()
	{
		$rs = (isset($_GET['co']) && $_GET['co'] == 1) || ! kernel::request()->isXmlHttpRequest(); // si se cambia de op o no es ajax
		return $rs;
	}
		
	function json_encode($array_to_encode)
	{
		if (kernel::proyecto()->get_encoding() != 'utf-8') {
			$array_to_encode = $this->utf8_encode_fields($array_to_encode);
		}
		return json_encode($array_to_encode);
	}
	
	protected function utf8_encode_fields($elements)
	{
		foreach ($elements as $key => $element) {
			if (is_array($element)) {
				$elements[$key] = $this->utf8_encode_fields($element);
			} else {
				$elements[$key] = utf8_encode($element);
			}
		}
		
		return $elements;
	}
	
	function procesar()
	{
		$cambia_operacion = (isset($_GET['co']) && $_GET['co'] == 1);
		
		if ( ! kernel::request()->isXmlHttpRequest() && ! $this->force_ajax ) {
            // Si no es ajax entonces se renderiza toda la página
			$this->add(kernel::pagina());
			if ($this->error === false) {
				kernel::pagina()->render();	
			} else {
				kernel::pagina()->render_error($this->error['cont']);
			}
		} else if ($this->error !== false) { // hay error
			echo json_encode($this->utf8_encode_fields($this->error));
        } else if ($this->nuevo_req !== false) { // es redirección
            $this->render_redireccion();
		} else if (empty($this->unidades) || $cambia_operacion) { 
            // si es ajax y no se seteo ninguna unidad de renderización (o se cambió de operación) 
			// se asume que se quiere renderizar toda la vista
            $this->render_vista();
        } else {
            foreach($this->unidades as $unidad) {
                $unidad->render_ajax();
            }
        }
	}
    
	function add_mensajes($mensajes)
	{
		$this->mensajes = $mensajes;
	}
	
	function add_csrf($token)
	{
		$this->csrf_token = $token;
	}
	
	protected $custom_vars = array();
	function add_to_ajax_response($key, $value)
	{
		$this->custom_vars[$key] = $value;
	}
	
	
    /**
     * Arma un paquete de rta ajax
     * @param type $cod
     * @param type $cont 
     */
    protected function armar_paquete_ajax($cod, $cont, $opciones = array())
    {
        $paquete = array(
            'cod'  => $cod,
            'cont' => $cont
        );
		
		if ($this->mensajes !== false) {
			$paquete['mensajes'] = $this->mensajes;
		}
		
		if ($this->csrf_token !== false) {
			$paquete['csrf_token'] = $this->csrf_token;
		}
	
		if ($this->notificaciones !== false) {
			$paquete['_notif'] = array(
				'titulo' => $this->titulo_notificaciones,
				'notificaciones' => $this->notificaciones
			);
		}
		
		foreach ($this->custom_vars as $key => $value) {
			$paquete[$key] = $value;
		}
		
        return array_merge($paquete, $opciones);
    }
	
	function get_respuesta_json($cod, $cont, $opciones = array())
	{
		$paquete = $this->armar_paquete_ajax($cod, $cont, $opciones);
		return $this->json_encode($paquete);
	}
	
	function set_popup_notificaciones($titulo, $notif)
	{
		$this->titulo_notificaciones = $titulo;
		$this->notificaciones = $notif;
	}
}
?>