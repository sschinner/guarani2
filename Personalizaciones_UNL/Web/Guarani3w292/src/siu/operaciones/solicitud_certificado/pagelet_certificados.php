<?php
namespace siu\operaciones\solicitud_certificado;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_certificados extends pagelet {

	const CERTIFICADO_SELECCIONADO			= 'cert_sel';
	const ERROR_CERTIFICADO_SELECCIONADO	= 'error_cert_sel';
	
	public function get_nombre(){
        return 'certificados';
    }

	function prepare() {
        $this->add_mensaje_js('esconder_menu', ucfirst(kernel::traductor()->trans('certificado_evaluacion.esconder_menu')));
        $this->add_mensaje_js('mostrar_menu', ucfirst(kernel::traductor()->trans('certificado_evaluacion.mostrar_menu')));
        $id_certificado = $this->controlador->get_id_certificado();
        $this->add_var_js('id_certificado', $id_certificado);
		$this->data['id_form'] = $id_certificado;
	}
	
	function opciones() {
		$certs = $this->controlador->modelo()->lista_certificados();
        //Agrego el certificado de evaluación a la lista de certificados.
        //$certs[100] = $this->get_certificado_evaluacion();
		$opciones = array();
		foreach ($certs as $id => $cert) {
			$opciones[$id] = array(
				'url' => kernel::vinculador()->crear('solicitud_certificado', 'elegir_certificado', $id),
				'nrcert' => $id,
				'nombre' => $cert['nombre'],
				'solicitud_pendiente' => $cert['solicitud_pendiente']
			);
		}
		return $opciones;
	}

    function get_certificado_evaluacion(){
        return array(
            'nombre' => kernel::traductor()->trans('certificado_evaluacion.certificado_evaluacion'),
            'solicitud_pendiente' => 'N',
            'maximo_copias' => '1'
        );
    }
}
?>