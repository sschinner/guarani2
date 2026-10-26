<?php
namespace kernel\interfaz\componentes\forms\elementos;

use kernel\error_kernel;
use kernel\interfaz\componentes\forms\form_elemento;
use kernel\interfaz\componentes\forms\form_elemento_config;
use kernel\kernel;

class form_elemento_ml extends form_elemento
{
	protected $permite_alta_baja = true;
	protected $columna_clave = '';

	protected $cols_todo_nada = array();
	
	protected $analisis_columnas = false;
	protected $info_analisis_columnas = false;
	
	protected $se_seteo_valor_desde_post = false;
	protected $hubo_error_form = false;
	/**
	 * @var form_elemento[]
	 */
	protected $columnas;
	protected $zend_form;
	protected $zend_form_initialized = false;
	/**
	 * @var form_elemento_ml_fila[]
	 */
	protected $filas;

	protected $fn_completar_efs_fijos;

	function __construct($nombre)
	{
		$this->nombre = $nombre;
		$this->def[form_elemento_config::elemento] = array('tipo' => 'ml');
		$this->filas = array();
	}
	
	function __destruct()
	{
		if ($this->se_seteo_valor_desde_post) {
			if (!$this->hubo_error_form) {
				$this->borrar_filas_sesion();
			}
		}
	}
	
	/**
	 * Des/Activa el analisis alta, baja, modificacion o sin cambios de las filas del ML
	 * @param bool $activo
	 */
	function set_analisis_columnas($activo)
	{
		$this->analisis_columnas = $activo;
	}
	
	/**
	 * Des/Activa la info del analisis alta, baja, modificacion o sin cambios de las filas del ML
	 * @param bool $activo
	 */
	function set_info_analisis_columnas($activo)
	{
		$this->info_analisis_columnas = $activo;
	}
	
	/**
	 * Los mls necesitan un form aparte para manejar las distintas filas
	 * de elementos
	 */
	protected function create_zend_form()
	{
		if ($this->zend_form_initialized) {
			return;
		}
		$this->zend_form = new \Zend_Form();
		$view = new \Zend_View();
		$view->setEncoding(kernel::proyecto()->get_encoding());
		$this->zend_form->setView($view);

		$this->crear_fila(true);
		$this->zend_form_initialized = true;
	}

	protected function crear_fila($es_template = false, $data = array(), $desde_post = false, $analisis = null, $info_analisis = null)
	{
		$nro = count($this->filas) - 1; // la fila template no se cuenta así empiezan de 0
		$fila = new form_elemento_ml_fila($this->id_form, $this->zend_form, $this->nombre, $nro);
		$fila->set_es_template($es_template);
		$fila->set_columnas($this->columnas);
		$fila->set_columna_clave($this->get_columna_clave());
		if ($desde_post) {
			$fila->set_valor_desde_post($data);
		} else {
			$fila->set_valor($data);
		}
		$fila->set_valor_analisis($analisis);
		$fila->set_valor_info_analisis($info_analisis);
		$this->filas[] = $fila;
	}

	function added_to_form($id_form)
	{
		parent::added_to_form($id_form);
		if (!$this->permite_alta_baja && empty($this->columna_clave)) {
			throw new error_kernel("No se puede crear un elemento ml que no permita altas y bajas sin setear una columna como clave");
		}
		$this->create_zend_form();
	}

	function set_fn_completar_efs_fijos($fn)
	{
		$this->fn_completar_efs_fijos = $fn;
		return $this;
	}

	function get_permite_alta_baja()
	{
		return $this->permite_alta_baja;
	}

	function set_permite_alta_baja($permite)
	{
		$this->permite_alta_baja = $permite;
		return $this;
	}

	function set_columna_clave($columna)
	{
		$this->columna_clave = $columna;
		return $this;
	}

	function add_columna(form_elemento $elemento)
	{
		$this->columnas[$elemento->get_nombre()] = $elemento;
		return $this;
	}

	/**
	 *
	 * @return form_elemento[]
	 */
	function get_columnas()
	{
		return $this->columnas;
	}

	/**
	 *
	 * @return form_elemento_ml_fila[]
	 */
	function get_filas()
	{
		return $this->filas;
	}

	function set_valor($data_filas)
	{
		foreach ($data_filas as $data) {
			$this->crear_fila(false, $data);
		}
		
		return $this;
	}

	protected function get_columna_clave()
	{
		if (!isset($this->columna_clave)) {
			throw new error_kernel("El ML debe tener una columna clave. Se setea con el método 'set_columna_clave()'");
		}
		return $this->columna_clave;
	}


	function set_columna_todo_nada($col){
		$this->cols_todo_nada[] = $col;
		return $this;
	}

	function get_columna_todo_nada(){
		return $this->cols_todo_nada;
	}

	protected function guardar_filas_sesion()
	{
		$guardar = array();
		foreach ($this->filas as $fila) {
			if ($fila->es_template()) {
				continue;
			}
			$guardar[$fila->get_valor_columna($this->get_columna_clave())] = $fila->get_data_sesion();
		}
		kernel::sesion()->set($this->get_clave_sesion(), $guardar);
	}

	protected function get_clave_sesion()
	{
		return "form_ml-" . $this->id_form . "-" . $this->nombre;
	}

	protected function borrar_filas_sesion()
	{
		$clave = $this->get_clave_sesion();
		if (kernel::sesion()->esta_seteada($clave)) {
			kernel::sesion()->borrar($clave);
		}
	}
	
	protected function get_filas_sesion()
	{
		return kernel::sesion()->get($this->get_clave_sesion());
	}
	
	protected function chequear_filas_recibidas($filas_post)
	{
		$data_sesion = $this->get_filas_sesion();
		$ids_columna_clave = array_keys($data_sesion);
		foreach ($filas_post as $fila) {
			if (!in_array($fila[$this->get_columna_clave()], $ids_columna_clave)) {
				throw new error_kernel("Error seguridad, se recibió una fila que no se envío en un ML que no soporta altas ni bajas");
			}
		}
	}
	
	/**
	 * Setea los valores de los efs fijos. Se utiliza sólo en el caso que el ml
	 * no permita altas y bajas xq los valores fueron guardados en la sesión. Si el ML
	 * permite altas y bajas hay que completarlos manualmente
	 */
	protected function completar_ef_fijo_desde_sesion()
	{
		$data_sesion = kernel::sesion()->get($this->get_clave_sesion());
		foreach (array_keys($data_sesion) as $key) {
			$fila = $this->get_fila_por_columna_valor($this->get_columna_clave(), $key);
			$fila->set_valor_elementos_fijos($data_sesion[$key]['fijos']);
		}

	}

	protected function completar_ef_fijo_desde_post($filas_post)
	{
		if (!isset($this->fn_completar_efs_fijos)) {
			// no se completan los efs fijos. Se deja así xq puede ser que no 
			// haya efs fijos en el ml
			return;
		}
		$fn = $this->fn_completar_efs_fijos;
		$nuevas_filas = $fn($filas_post);
		foreach ($nuevas_filas as $fila) {
			$fila_ml = $this->get_fila_por_columna_valor($this->get_columna_clave(), $fila[$this->get_columna_clave()]);
			$fila_ml->set_valor_elementos_fijos($fila);
		}
	}

	protected function get_fila_por_columna_valor($columna, $valor)
	{
		foreach ($this->filas as $fila) {
			if ($fila->get_valor_columna($columna) == $valor) {
				return $fila;
			}
		}

		throw new error_kernel("No existe la fila con el valor '$valor' en la columna '$columna'");
	}

	function set_valor_desde_post($filas_post)
	{
		unset($filas_post[form_elemento_ml_fila::NRO_FILA_TEMPLATE]);
		if (!$this->permite_alta_baja) {
			$this->chequear_filas_recibidas($filas_post);
		}
		
		$this->procesar_filas_post($filas_post);
		
		if (!$this->permite_alta_baja) {
			$this->completar_ef_fijo_desde_sesion();
		} else {
			$this->completar_ef_fijo_desde_post($filas_post);
		}
		
		$this->refrescar_disabled();
		$this->se_seteo_valor_desde_post = true;
//		$this->borrar_filas_sesion();
		return $this;
	}
	
	protected function procesar_filas_post($filas_post)
	{
		if ($this->analisis_columnas) {
			$filas_sesion = $this->get_filas_sesion();
			foreach ($filas_sesion as $fila_sesion) {
				$fila = $this->get_fila_por_id_desde_array($fila_sesion['original'][$this->get_columna_clave()], $filas_post);
				if ($fila === null) {
					$this->crear_fila(false, $fila_sesion['original'], true, analisis_baja);
				}
			}
			
			foreach ($filas_post as $fila_post) {
				$fila = $this->get_fila_por_id_desde_array($fila_post[$this->get_columna_clave()], $filas_sesion, true);
				if ($fila === null) {
					$this->crear_fila(false, $fila_post, true, analisis_alta);
				} else {
					$resultado = $this->son_filas_iguales($fila, $fila_post);
					if ($resultado === true) {
						$this->crear_fila(false, $fila_post, true, analisis_sin_cambios);
					} else {
						if ($this->info_analisis_columnas) {
							$this->crear_fila(false, $fila_post, true, analisis_modificacion, $resultado);
						} else {
							$this->crear_fila(false, $fila_post, true, analisis_modificacion);
						}
					}
				}
			}

		} else {
			foreach ($filas_post as $data) {
				$this->crear_fila(false, $data, true);
			}
		}
		
	}
	
	protected function son_filas_iguales($fila_sesion, $fila_post)
	{
		$distintas = false;
		$columnas = '';

		foreach ($this->columnas as $col) {
			if ($col instanceof form_elemento_fijo) continue;
			if ($col->get_elemento_html_tipo() == 'button') continue;
			if ($fila_sesion[ml_fila__columna_disabled][$col->get_nombre()]) continue;
			
			if ($fila_sesion[$col->get_nombre()] != $fila_post[$col->get_nombre()]) {
				$distintas = true;
				$columnas .= $col->get_nombre().",";
			}
		}
		
		$retorno = $distintas ? substr($columnas, 0, -1) : true;
		return $retorno;
	}
	
	protected function get_fila_por_id_desde_array($id, $filas, $es_sesion = false)
	{
		foreach ($filas as $fila) {
			if ($es_sesion) {
				if ($fila['original'][$this->get_columna_clave()] == $id) {
					return $fila['original'];
				}	
			} else {
				if ($fila[$this->get_columna_clave()] == $id) {
					return $fila;
				}
			}
			
		}
		
		return null;
	}
	
	function validar()
	{
		$valido = true;
		foreach ($this->filas as $fila) {
			if (!$fila->validar()) {
				$valido = false;
			}
		}
		return $valido;
	}

	function get_valor()
	{
		$valores = array();
		foreach ($this->filas as $fila) {
			if ($fila->es_template()) {
				continue;
			}
			$valores[$fila->get_numero()] = $fila->get_valor();
		}

		return $valores;
	}
	
	function evt_pre_render()
	{
		if (!$this->hubo_error_form) {
			$this->guardar_filas_sesion();
		}
		
	}
	
	function refrescar_disabled() 
	{
		$filas_sesion = $this->get_filas_sesion();
		
		foreach ($filas_sesion as $fila_sesion) {
			$fila = $this->get_fila_por_columna_valor($this->get_columna_clave(), $fila_sesion['clave'][$this->get_columna_clave()]);
			$columnas = $fila->get_columnas();
			foreach ($fila_sesion['original'] as $col_key => $col_value) {
				// se saltea la columna que trae si la columna está o no disabled
				if ($col_key == ml_fila__columna_disabled) continue;
				if ($col_key == analisis_columna) continue;
				if ($col_key == info_analisis_columna) continue;
				
				if ($fila_sesion['original'][ml_fila__columna_disabled][$col_key]) {
					$columnas[$col_key]->set_disabled(true);
					$columnas[$col_key]->set_valor($col_value);
				}
			}
		}
	}
	
	function set_hubo_error_form($hubo_error)
	{
		$this->hubo_error_form = $hubo_error;
	}
}

?>
