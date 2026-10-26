<?php
namespace siu\operaciones\configuracion;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_cuentas_externas extends pagelet
{

	function get_nombre()
	{
		return 'cuentas_externas';
	}

	function prepare()
	{

		if ( ($adm_ctas = $this->controlador->get_administrador_cuentas_externas() ) != null){
			$operacion = kernel::ruteador()->get_id_operacion();
			$this->data['cuentas_externas'] = 1; //habilito el fragmento entero
			$this->data['url_vincular'] = kernel::vinculador()->crear($operacion, 'vincular_cuenta_externa');
			$this->data['url_desvincular'] = kernel::vinculador()->crear($operacion, 'desvincular_cuenta_externa');
			$this->add_var_js('url_recargar', kernel::vinculador()->crear($operacion, 'cuentas_externas') );

			$modelo = $adm_ctas->get_modelo();

			$existentes = catalogo::consultar('persona', 'get_login_externos', array(
				'nro_inscripcion' => guarani::persona()->get_nro_inscripcion()
			));


			$cuentas_vinculadas = array();
			$cuentas_disponibles = array();

			foreach ($modelo['proveedores'] as $c) {
				$cuentas_disponibles[$c['id']] = $c;
			}

			foreach ($existentes  as $existente) {
				$p = $existente['proveedor'];
				if(isset($cuentas_disponibles[$p])){
					$cuentas_vinculadas[$p] = $cuentas_disponibles[$p];
					$cuentas_vinculadas[$p]['vinculada'] = 1;
					$cuentas_vinculadas[$p]['descripcion'] = $existente['descripcion'];
					unset($cuentas_disponibles[$p]);
				}else {
					kernel::log()->add_info('Cuentas externas', 'No existe el proveedor ' . $p);
				}
			}

			$modelo['proveedores'] = $cuentas_vinculadas;

			$this->data['cuentas_vinculadas'] = $cuentas_vinculadas;
			$this->data['cuentas_disponibles'] = $cuentas_disponibles;
		}
	}
}
?>