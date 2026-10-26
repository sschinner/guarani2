<?php
namespace siu\operaciones\solicitud_certificado;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_formulario extends pagelet {
	public function get_nombre(){
        return 'formulario';
    }

	function prepare() 
	{
		$this->add_var_js('url_carga_form', kernel::vinculador()->crear('solicitud_certificado', 'cargar_form'));
		$this->data['url_form'] = kernel::vinculador()->crear('solicitud_certificado', 'solicitar');
		//$this->data['url_generar_car'] = kernel::vinculador()->crear('solicitud_certificado', 'generar_cert_alumno_reg');
		$id_form = $this->controlador->get_id_certificado();
		if (!empty($id_form)){
			$this->data['id_form'] = $id_form;
			$argumentos = $this->controlador->modelo()->argumentos_certificado($id_form);
			$this->data['form_argumentos'] = $argumentos;
		}
	}
	
	function get_url_cert_online($id_certificado)
	{
		switch ($id_certificado)
		{
			case 1:
				$url_cert = kernel::vinculador()->crear('solicitud_certificado', 'generar_cert_alumno_reg');
				break;
			default: //si no existe la opción online para el certificado, redirige al inicio
				$url_cert =  kernel::vinculador()->crear('solicitud_certificado', 'solicitar');
		}
		$this->data['url_generar_car'] = $url_cert;
	}
}
?>