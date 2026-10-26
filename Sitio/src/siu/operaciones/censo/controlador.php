<?php
namespace siu\operaciones\censo;

use kernel\error_kernel_db;
use siu\guarani;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\extension_kernel\controlador_g3w2;
use siu\errores\error_procesar_datos_censales;


class controlador extends controlador_g3w2
{	
	
	protected $campos_faltantes;
	
	function ini() 
	{
		$this->controlar_csrf_accion('guardar');
	}

	/**
	 * @return \siu\modelo\transacciones\datos_censales
	 */
	function modelo()
	{
		return guarani::datos_censales();
	}

    function get_clase_vista()
	{
		switch ($this->accion) {
			case 'datos_discapacidad':
			case 'discapacidad_agregar':
			case 'discapacidad_guardar':
			case 'discapacidad_eliminar':
				return 'vista_discapacidad';
		}
		return 'vista';
	}
    
	function accion__index()
	{
		$form_actual = (kernel::url()->hay_param(0)) ? $this->get_param(0, 'get') : 'principales';
        
		if(kernel::url()->hay_param(1)) {
			$this->vista()->pagelet('acciones')->data['save_status'] = $this->get_param(1, 'get');
		}
        
        $datos = $this->modelo()->get_datos_censales();
        
		if ($this->modo_reinscripcion()) {
			$this->set_form_visitado($form_actual);
		}
        
		$this->vista()->agregar_a_contexto('ultima_actualizacion', $this->get_ultima_fecha_actualizacion());
		$this->vista()->agregar_a_contexto('datos_vigentes', $this->modelo()->tiene_datos_censales_actualizados());
		$this->vista()->mostrar($form_actual, $datos);
		$this->add_var('form_actual', $form_actual);
		kernel::renderer()->add($this->vista()->pagelet('formulario'));
	}

	function accion__guardar()
	{
		if (kernel::request()->isPost()) {
			try {
				$respuesta = $this->modelo()->grabar_datos_censales($_POST);
				$respuesta['cont'] = "Guardar";
			} catch (error_procesar_datos_censales $e) {
				kernel::renderer()->add_csrf($this->generar_csrf());
				throw $e;
			}
			$form_actual = $_POST['form_id'];
			$datos = $this->modelo()->get_datos_censales();
			$this->vista()->mostrar($form_actual, $datos);
			$this->add_var('form_actual', $form_actual);
			kernel::renderer()->add($this->vista()->pagelet('formulario'));
		}
	}

	function accion__confirmar()
	{
		if (!kernel::request()->isPost()) return false;
		
		try {
			
			if ($this->hay_datos_faltantes()) {
				$resultado = array('ok' => false, 'msg' => kernel::traductor()->trans('datos_censales.msj_campos_faltantes'));
			} else {
				
				$respuesta = $this->modelo()->actualizar_revision();
				$resultado = array('ok' => true, 'msg' => kernel::traductor()->trans('datos_censales.msj_datos_confirmados'));
				$this->vista()->agregar_a_contexto('datos_confirmados', 1);
				
			}
			
		} catch (error_procesar_datos_censales $e) {
			kernel::renderer()->add_csrf($this->generar_csrf());
			kernel::log()->add_error($e);
			$resultado = array('ok' => false, 'msg' => kernel::traductor()->trans('datos_censales.msj_datos_confirmados_error'));
		}
		
		$this->vista()->agregar_a_contexto('ultima_actualizacion', $this->get_ultima_fecha_actualizacion());
		$this->render_json($resultado);
			
	}
	
	function get_campos_faltantes()
	{
		if (!isset($this->campos_faltantes)) {
			$this->campos_faltantes = $this->modelo()->get_datos_faltantes();
		}
		return $this->campos_faltantes;
	}

	function hay_datos_faltantes()
	{
		$faltantes = $this->get_campos_faltantes();
		return (count($faltantes) > 0);
	}
	
	function accion__provincias()
	{
		$pais = $this->get_param('pais', 'post');

		$provincias = catalogo::consultar('etiquetas',
										'provincias',
										array('pais' => $pais)
										);
		$this->render_raw_json($provincias);
	}

	function accion__localidades()
	{
		$provincia = $this->get_param('provincia', 'post');
		$localidad = $this->get_param('localidad', 'post');

		$parametros = array('provincia_id' => $provincia, 'localidad' => $localidad);

		$localidades = catalogo::consultar('etiquetas', 'localidades', $parametros);
		$this->render_raw_json($localidades);
	}

	function accion__subsectores()
	{
		$sector = $this->get_param('sector', 'post');

		$parametros = array('sector' => $sector);

		$subsectores = catalogo::consultar('etiquetas', 'subsectores_ac_ec', $parametros);
		$this->render_raw_json($subsectores);
	}

	// MANEJO REINSCRIPCION

	function modo_reinscripcion()
	{
		return kernel::sesion()->esta_seteada('datos_censales_reinscripcion');
	}

	function set_form_visitado($form)
	{
		$visitados = $this->get_forms_visitados();
        //$visitados[$form] = array('visitado' => true);
        $visitados[$form] = true;
		$this->guardar_forms_visitados($visitados);

		$completo = true;
		$menu = $this->vista()->pagelet('lista_forms')->get_menu();
		if($form == 'discapacidad')
		{
			$menu[]=array('form'=>$form, 'visitado'=>true);
		}
		foreach ($menu as $key => $value) {
			if (isset($menu[$key]['form'])) {
				if (!isset($visitados[$value['form']])) {
					$completo = false;
				}
			}
		}

		$this->set_revision_completa($completo);
	}

	function get_forms_visitados()
	{
		if (kernel::sesion()->esta_seteada('dcensales_form_visitados')) {
			return kernel::sesion()->get('dcensales_form_visitados');
		} else {
			return array();
		}
	}

	protected function guardar_forms_visitados($forms_visitados)
	{
		kernel::sesion()->set('dcensales_form_visitados', $forms_visitados);
	}

	function set_revision_completa($value)
	{
        if ($value){
            $this->modelo()->actualizar_revision();
        }
		kernel::sesion()->set('dcensales_revision_completa', $value);
	}

	function get_revision_completa()
	{
		return kernel::sesion()->get('dcensales_revision_completa');
	}
    
    /* Formulario discapacidad */
    function accion__datos_discapacidad(){
        $this->add_var('form_actual', 'discapacidad');
        $this->set_form_visitado('discapacidad');
		$this->vista()->agregar_a_contexto('ultima_actualizacion', $this->get_ultima_fecha_actualizacion());
		$this->vista()->agregar_a_contexto('datos_vigentes', $this->modelo()->tiene_datos_censales_actualizados());
    }
    
    function accion__discapacidad_agregar(){
        $this->add_var('form_actual', 'discapacidad');
        $this->set_form_visitado('discapacidad');
        $hash = (kernel::url()->hay_param(0)) ? $this->get_param(0, 'get') : null;
        
        $form_builder = $this->get_form_builder();
        $form = $form_builder->get_formulario();
		$pl = $this->vista()->pagelet('formulario');
        $pl->set_pantalla($pl::ESTADO_EDICION);
        
        if (kernel::request()->isPost()) { 
            
            if (!empty($_POST) && !empty($_POST['form_datos_discapacidad']['__ID__'])){
                $datos = $this->decodificar_hash($_POST['form_datos_discapacidad']['__ID__']);
                $_POST['form_datos_discapacidad']['ID'] = $datos['ID'];
            } else {
                $_POST['form_datos_discapacidad']['ID'] = null;
            }

            if ($form->procesar()) {

                try{
                    $respuesta = $this->modelo()->grabar_datos_salud($_POST);
                }
                catch(error_kernel_db $e){
                    $respuesta = false;
                    $msj_error_excepcion = $e->get_mensaje();
                    preg_match('/\[Informix\]\[Informix ODBC Driver\]\[Informix\](.+)\(SQLExecDirect.*\)/', $msj_error_excepcion, $matches);
                    //Traigo solo el mensaje a mostrar (el primer grupo de la RegExp)
                    $msj_error_excepcion = trim($matches[1]);
                }

                if ($respuesta){
                    $pl->set_pantalla($pl::ESTADO_LISTADO);
                    $pl->add_var_js('estado', 'ok');
                    $mensaje = kernel::traductor()->trans('form_exito_grabar');
                } else {
                    $pl->add_var_js('estado', 'error');
                    $mensaje = kernel::traductor()->trans('form_error_grabar');
                    if(isset($msj_error_excepcion)) $mensaje .= " ($msj_error_excepcion)";
                }
                $pl->add_var_js('mensaje', $mensaje);
            }
            else{
                $pl->add_var_js('estado', 'error');
                $mensaje = kernel::traductor()->trans('form_validacion_error.error');
                $pl->add_var_js('mensaje', $mensaje);
            }
        } else {
            if ($hash){
                $datos = $this->decodificar_hash($hash);
                $_POST['form_datos_discapacidad'] = $datos;
                $form->procesar();
            }
        }
    }
    
    function accion__discapacidad_eliminar(){
        $hash = (kernel::url()->hay_param(0)) ? $this->get_param(0, 'get') : null;
        $mensaje = "";
        if (!empty($hash)){
            $datos = $this->decodificar_hash($hash);
            if (!empty($datos) && !empty($datos['ID'])){
                if ($this->modelo()->eliminar_datos_salud($datos['ID'])){
                    $mensaje = kernel::traductor()->trans('form_exito_eliminar');
                } else {
                    $mensaje = kernel::traductor()->trans('form_error_eliminar');
                }
            }
        }
        $this->render_ajax($mensaje, array('msj' => $mensaje));
        
    }
    
    public function get_vista_form()
	{
        $vista = $this->get_form_builder()->get_vista();
        $vista->get_salida()->set_es_minimizable(false);
        return $vista;
	}

	public function get_form_builder()
	{
		if (!isset($this->form_builder)) {
			$this->form_builder = $this->instanciar_form_builder();
		}
		return $this->form_builder;
	}
    
    protected function instanciar_form_builder()
	{
		return kernel::localizador()->instanciar('operaciones\censo\datos_discapacidad\builder_form_discapacidad');
	}
    
    public function decodificar_hash($hash)
	{
		$datos = $this->modelo()->get_datos_discapacidad();
        foreach($datos as $dato){
            if ($dato[catalogo::id] == $hash){
                return $dato;
            }
        }
        return false;
	}
    
    public function datos()
    {
        $hash = (kernel::url()->hay_param(0)) ? $this->get_param(0, 'get') : null;
        return ($this->decodificar_hash($hash));
    }
    
    public function get_ultima_fecha_actualizacion()
    {
		$fecha =$this->modelo()->get_ultima_fecha_actualizacion();				
        return date("d/m/Y", strtotime($fecha));
    }
}
?>