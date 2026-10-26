<?php
namespace siu\operaciones\cursada;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use \siu\modelo\entidades\parametro;
use \siu\modelo\datos\catalogo;
use \siu\guarani;

class pagelet_info_materia extends pagelet
{
	const MATERIA_SELECCIONADA				= 'mat_sel';
	const ERROR_MATERIA_SELECCIONADA		= 'error_mat_sel';
	const REINSCRIPCION						= 'reinsc';

	function ini()
	{
		$this->add_mensaje_js('error_subcomision', kernel::traductor()->trans('info_materia.errores.subcomision'));
	}

	function get_nombre()
	{
		return 'info_materia';
	}

	function get_materia()
	{
		return $this->controlador->get_var('materia');
	}

	function get_materia_nombre()
	{
		$info = $this->modelo()->info__materia($this->get_materia());
		return $info['MATERIA_NOMBRE'];
	}

	function get_comision()
	{
		return $this->controlador->get_var('comision');
	}

	function get_mensajes()
	{
		return $this->controlador->get_var('mensajes');
	}

	/**
	 * Shortcut al modelo
	 * @return \siu\modelo\transacciones\inscripcion_cursada
	 */
	protected function modelo()
	{
		return $this->controlador->modelo();
	}

	function prepare()
	{
		$this->data = array();
		$this->add_mensajes_js();
		switch ($this->estado) {
			case 'inicial':
				$this->prepare_inicial();
				break;
			// seleccioné una materia que no estoy inscripto
			case self::MATERIA_SELECCIONADA: 
				$this->prepare_materia_seleccionada();
				break;

			// seleccioné una materia que no estoy inscripto Y HUBO ERRor de controles
			case self::ERROR_MATERIA_SELECCIONADA: 
				$this->prepare_error_materia_seleccionada();
				break;

			// estoy inscripto a una materia pero quiero reinscribirme en otra comisión
			case self::REINSCRIPCION: 
				$this->prepare_reinscripcion();
				break;
		}
		$this->data['mensajes'] = $this->get_mensajes();
		
		$param_insc_cur_baja = parametro::inscripcion_cursada_baja() == 'S';
		$this->data['param_insc_cur_baja']	= $param_insc_cur_baja;
	}

	protected function add_mensajes_js()
	{
		$this->add_var_js('msg_baja', kernel::traductor()->trans('mensaje_baja_cursada'));
		$this->add_var_js('msg_confirmar_baja', kernel::traductor()->trans('mensaje_confirmar_baja'));
		$this->add_var_js('msg_baja_exitosa', kernel::traductor()->trans('baja_exitosa'));
		$this->add_var_js('msg_titulo_enviar', kernel::traductor()->trans('titulo_enviar_comprobante'));
		$this->add_var_js('msg_enviar', kernel::traductor()->trans('enviar_comprobante_cursada', array(
			'%1%' => kernel::persona()->get_mail()
		)));
		$this->add_var_js('msg_enviar_boton', kernel::traductor()->trans('enviar_por_mail'));

		$this->add_var_js('msg_falta_mail', kernel::traductor()->trans('mail_no_cargado', array(
			'%1%' => kernel::vinculador()->crear('configuracion')
		)));

		$this->add_var_js('envio_mail_exitoso', kernel::traductor()->trans('envio_mail_exitoso'));

		$mail = kernel::persona()->get_mail();
		if (empty($mail)) {
			$this->add_var_js('falta_mail', true);
		} else {
			$this->add_var_js('falta_mail', false);
		}

		$this->add_var_js('url_baja_inicial', kernel::vinculador()->crear('cursada', 'baja_inicial'));
	}

	protected function prepare_inicial()
	{
		$parametros_cursada = array();
		$parametros_cursada['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		$parametros_cursada['estado'] = "T";
		$parametros_cursada['alcance'] = "A";

		$carrera = kernel::persona()->get_id_carrera_activa();
		$inscs = catalogo::consultar('alumno', 'inscripciones_cursadas', $parametros_cursada);
		$inscs_por_carrera = array();

		foreach ($inscs as $insc) {
			if ($insc['carrera'] == $carrera) {
				$inscs_por_carrera[] = $insc;
			}
		}

		$this->data['inscripciones'] = $inscs_por_carrera;
		$this->data['csrf']	= $this->generar_csrf();
	}

	protected function get_comision_ignorar()
	{
		if ($this->controlador->hay_var('ignorar_orden_comision')) {
			return $this->controlador->get_var('ignorar_orden_comision');
		}
		
		return false;
	}

	protected function get_vinculo_comp($actividad, $inscripcion)
	{
		return kernel::vinculador()->crear(
				'cursada', 
				'generar_comprobante', 
				array(
					'materia' => $actividad,
					'transaccion' => $inscripcion
				)
		);
	}

	protected function get_vinculo_imp_comp($actividad, $inscripcion)
	{
		return kernel::vinculador()->crear(
				'cursada', 
				'generar_comprobante', 
				array(
					'materia' => $actividad,
					'transaccion' => $inscripcion,
					'i' => 1
				)
		);
	}

	protected function get_vinculo_mail_comp($actividad, $inscripcion)
	{
		return kernel::vinculador()->crear(
				'cursada', 
				'enviar_comprobante', 
				array(
					'materia' => $actividad,
					'transaccion' => $inscripcion
				)
		);
	}

	protected function prepare_materia_seleccionada()
	{
		$materia = $this->get_materia();

		$comisiones = $this->modelo()->info__lista_comisiones($materia);
		$comisiones_inscriptas = $this->modelo()->info__inscripciones_materia($materia);

		$this->data['comisiones'] = $comisiones;
		foreach ($comisiones as $key => $comision) {
			$comision_inscripta = false;
			foreach ($comisiones_inscriptas as $com_insc) {
				if ($comision['COMISION'] == $com_insc['COMISION']) {
					$comision_inscripta = $com_insc;
					break;
				}
			}

			if ($comision_inscripta !== false) { // está inscripto a la comision
				$comision_inscripta['INSCRIPTO'] = true;
				$comision_inscripta['ID'] = $comision[catalogo::id];
				$comision_inscripta['MATERIA'] = $materia;
				$comision_inscripta['URL_COMP'] = $this->get_vinculo_comp($materia, $comision_inscripta['URL_NRO_TRANSACCION']);
				$comision_inscripta['URL_IMP_COMP'] = $this->get_vinculo_imp_comp($materia, $comision_inscripta['URL_NRO_TRANSACCION']);
				$comision_inscripta['URL_MAIL_COMP'] = $this->get_vinculo_mail_comp($materia, $comision_inscripta['URL_NRO_TRANSACCION']);
				$comision_inscripta['URL_BAJA'] = kernel::vinculador()->crear('cursada', 'baja');

				$this->data['comisiones'][$key] = $comision_inscripta;
			} else {
				$this->data['comisiones'][$key]['INSCRIPTO'] = false;
				$this->data['comisiones'][$key]['ID'] = $comision[catalogo::id];
				$this->data['comisiones'][$key]['MATERIA'] = $materia;
				$this->data['comisiones'][$key]['URL_INSCRIBIRSE'] = kernel::vinculador()->crear('cursada', 'inscribir');
				$this->data['comisiones'][$key]['TIENE_CUPO'] = ($comision['TIENE_CUPO'] == 'S') ? true : false;
				if ($comision['TIENE_CUPO'] == 'S') {
					$this->data['comisiones'][$key]['PORCENTAJE_CUPO'] = 
							($comision['COMISION_INSCRIPTOS'] / $comision['COMISION_CUPO'])*100;
				} else
				{
					$this->data['comisiones'][$key]['PORCENTAJE_CUPO'] = 100;
				}	
			}
		}

		$this->data['materia_nombre']	= $this->get_materia_nombre();

		// parámetros
		$param_horarios		= parametro::usa_asignacion_horaria() == 'S';
		$param_maneja_sedes	= parametro::maneja_sedes() == 'S';
		$param_cupo			= parametro::controla_cupo() == 'S';
		$this->data['param_usar_horarios']	= $param_horarios;
		$this->data['param_maneja_sedes']	= $param_maneja_sedes;
		$this->data['param_controla_cupo']	= $param_cupo;
		$this->add_var_js('param_usar_horarios' , $param_horarios);
		$this->add_var_js('param_maneja_sedes'	, $param_maneja_sedes);

		// sedes
		$this->data['sedes'] = guarani::lista_sedes();
		
		$this->data['csrf']	= $this->generar_csrf();
	}

	protected function prepare_error_materia_seleccionada()
	{
		$this->data['materia_nombre'] = $this->get_materia_nombre();
	}

	protected function prepare_reinscripcion()
	{
	}
}
?>