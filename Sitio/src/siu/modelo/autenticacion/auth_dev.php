<?php


namespace siu\modelo\autenticacion;

use kernel\kernel;


class auth_dev extends auth_con_sesion {

	protected $id_persona;
	protected $error;

	function __construct($id, $conf)
	{
		parent::__construct($id, $conf);
		$this->id_persona = $conf['id_default'];
	}


	public function autenticar() {

		if (kernel::request()->isPost()) {
			$this->id_persona = kernel::request()->getPost('id_persona');
			$persona_q = kernel::db()->quote($this->id_persona); //no me inyectes developer!

			$c = kernel::db()->consultar_fila('SELECT	*
                FROM	aca_usuarios_ag
                WHERE aca_usuarios_ag.nro_inscripcion	='  . $persona_q);

			if(!empty($c))
				return $this->id_persona;
			else{
				$this->error = 'No existe el id en la tabla';
			}
		}
		return null;
	}

	public function logout() {	}

	public function get_modelo()
	{
		return $datos = array(
			'accion' => kernel::vinculador()->crear('acceso', 'index', array('auth' => $this->get_id())),
			'mensaje' => 'Hola! No te acordas tu contraseña pero sabes tu id_persona de la base de datos? Ingresá conmigo!!',
			'campos' =>array(
				"usuario" => array('name'=>"id_persona", 'type'=>"text", 'value' => $this->id_persona),
			),
			'error' => $this->error,
		);
	}
}