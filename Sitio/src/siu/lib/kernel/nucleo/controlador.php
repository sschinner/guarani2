<?php

namespace kernel\nucleo;

use GuzzleHttp\Client;
use kernel\kernel;
use kernel\nucleo\nuevo_request;
use kernel\nucleo\parametros;
use kernel\util\u;
use kernel\util\validador;
use kernel\error_kernel;
use kernel\error_kernel_validacion;
use siu\operaciones\_comun\util\caracteres_especiales;

abstract class controlador
{
	/**
	 * Cantidad máxima de tokens csrf a almacenar en la sesión. Si se excede esta
	 * cantidad se borra el csrf más antiguo
	 */
	const MAX_CSRF_TOKENS = 40;

	/****************************************************************************/
	/* MODELO																	*/
	/****************************************************************************/

	/**
	 * En las subclases de este controlador hay que extender este método para que
	 * retorno el modelo correspondiente a la operación
	 */
	abstract function modelo();

	/****************************************************************************/
	/* VISTA																	*/
	/****************************************************************************/

	/**
	 * @var \kernel\interfaz\vista
	 */
	protected $vista;

	/**
	 * @return \kernel\interfaz\vista
	 */
	function vista()
	{
		return $this->vista;
	}

	/**
	 * Devuelve el nombre de la clase de la vista. No se especifica ns xq se asume
	 * el mismo de la operación
	 * @return string la clase de la vista
	 */
	function get_clase_vista()
	{
		return 'vista';
	}


	/****************************************************************************/
	/* INVOCACIÓN. Métodos que conforman el flujo de control en una invocación	*/
	/* a una acción																*/
	/****************************************************************************/

	protected $accion;
	protected $accion_original;
	private $impedir_ejecucion_accion = false;

	/**
	 * Configura el controlador para que pueda ser ejecutado. Recibe la vista
	 * como parámetro para que el usuario del controlador no tenga que instanciarla
	 * @param \kernel\interfaz\vista $vista
	 */
	function configurar($vista)
	{
		$this->vista = $vista;
		kernel::pagina()->set_vista($this->vista);
		$this->vista->set_controlador($this);
		$this->ini();
	}

	/**
	 * Ventana que se ejecuta al inicializar el controlador
	 */
	function ini()
	{
	}

	/**
	 * Setea la acción que se va a ejecutar. Se debe ejecutar antes de get_clase_vista
	 * ya que este método puede utilizar la acción para definir su resultado
	 * @param string $accion
	 */
	function set_accion($accion)
	{
		if (!$this->existe_accion($accion)) {
			kernel::log()->add_info("La acción '$accion' no existe Se redirige a 'index' con parámetro '$accion'", '');
			kernel::url()->notificar_accion_no_especificada();
			$accion = $this->get_accion_defecto();
		}
		$this->accion = $accion;
	}

	/**
	 * Ventana que se ejecuta antes de ejecutar una acción
	 */
	protected function pre_accion()
	{
	}

	/**
	 * Impide que se ejecute la acción
	 */
	protected function impedir_ejecucion_accion($impedir)
	{
		$this->impedir_ejecucion_accion = $impedir;
	}

	/**
	 * Controla precondiciones sobre la acción
	 */
	private function control_precondiciones()
	{
		$operacion = kernel::ruteador()->get_id_operacion();
		if ($operacion == 'logger') {
			return;
		}

		if ($this->get_controlar_csrf($this->accion)) {
			kernel::log()->add_debug("LA ACCION '{$this->get_name_for_log()}' TIENE CONTROL DE CSRF ACTIVO", '');
			$this->check_csrf();
		}
	}

	function procesar_accion()
	{
		if ($this->impedir_ejecucion_accion) {
			return;
		}
		// el $this->existe_accion($this->accion) se está haciendo en $this->set_accion(), analizar si existe algún caso
		// en que esto tenga que estar acá
		if ($this->existe_accion($this->accion)) {
			kernel::log()->add_info("EJECUTANDO ACCION '{$this->get_name_for_log()}'", '');
			$this->pre_accion();
			$this->control_precondiciones();
			$this->invocar_accion($this->accion);
		} else {
			$default = $this->get_accion_defecto();
			kernel::log()->add_info("REDIRIGIENDO ACCION '{$this->get_name_for_log($default)}'", '');
			$this->accion_original = $this->accion;
			if ($this->accion == $default) { // si index no lo atrapó error
				throw new \Exception('No existe la accion solicitada: ' . $this->accion_original);
			} else {
				$this->accion = $default; // por defecto, si no se especifica una acción se asume index
				kernel::url()->notificar_accion_no_especificada();
				$this->procesar_accion();
			}
		}
	}

	protected function get_accion_defecto()
	{
		return kernel::persona()->perfil()->get_accion_defecto(kernel::ruteador()->get_id_operacion());
	}

	/****************************************************************************/
	/* PARÁMETROS																*/
	/****************************************************************************/

	protected function get_post($key, $default = null)
	{
		return kernel::request()->getPost($key, $default);
	}

	/**
	 * Valida parámetros desde alguna entrada
	 * @param mixed $key la clave dentro de los parámetros
	 * @param string $method de donde sacar el parámetro. Valores posibles: 'get' o 'post'
	 * @param string $type tipo de validación. Valores posibles: 'alpha', 'alphanum', 'int', 'date', 'time', 'custom'
	 * @param boolean $options['action'] Puede tener tres valores,
	 *    'redirect', 'fail', false. Por defecto es 'fail'.
	 * @param string $options['format'] sólo se utiliza si $type es date, time
	 * o custom. Si es custom es una expresión regular, sino un formato de fecha
	 * válido (http://ar2.php.net/manual/en/function.date.php)
	 * @param boolean $options['allowempty'] Por defecto su valor es false.
	 * Define si se permite el valor vacío
	 * @param mixed $options['default'] El valor a retornar si el parámetro buscado es vacío
	 * @return mixed el valor si pasa la validación. Si falla la validación devuelve false
	 */
	protected function validate_param($key, $method = 'post', $type = validador::TIPO_ALPHA, $options = array())
	{
		$value = ($method == 'post') ? kernel::request()->getPost($key, '') : kernel::url()->get_param($key, false, '');
		return $this->validate_value($value, $type, $options, $key, $method);
	}


	protected function validate_value($value, $type, $options, $key = '-', $method = '-')
	{
//		$rs = u::validate_value($value, $type, $options);
		$rs = validador::validar($value, $type, $options);
		$accion = !isset($options['action']) ? 'fail' : $options['action'];
		if ($rs === false && $accion !== false) {
			$this->fail_validation($key, $value, $method, $type, $options, $accion);
		}
		return $rs;
	}

	protected function fail_validation($key, $value, $method, $type, $options, $accion)
	{
		$data = array(
			'key' => $key,
			'value' => $value,
			'method' => $method,
			'type' => validador::const_name($type),
			'options' => $options
		);
		kernel::log()->add_debug("FALLA VALIDACION en '{$this->get_name_for_log()}'", $data);
		if ($accion == 'fail') {

			if (kernel::proyecto()->get_produccion()) {
				throw new error_kernel_validacion('Ha ocurrido un error');
			} else {
				throw new error_kernel_validacion("error de validación de clave \$_$method ['$key']: <pre>" . print_r($data, true) . "</pre>");
			}

		} else {
			$this->redirect_index();
		}
	}

	/**
	 * Valida parámetros desde alguna entrada y luego lo decodifica con decodificar_hash
	 * @param mixed $key la clave dentro de los parámetros
	 * @param string $method de donde sacar el parámetro. Valores posibles: 'get' o 'post'
	 * @param string $para
	 * @param mixed $options['default'] El valor a retornar si el parámetro buscado es vacío
	 * @return mixed el valor si pasa la validación. Si falla la validación devuelve false
	 */
	function decodificar_param($key, $method = 'post', $para = null, $options = array())
	{
		//mantener compatibilidad con validate_param en cuanto a los defaults
		$param = $this->validate_param($key, $method, validador::TIPO_ALPHANUM, $options);
		return $this->codificador_modelo()->decodificar_fila($param, $para);

	}

	/**
	 * Decodifica un parametro hasheado generado mediante el codificado_modelo,
	 * para una acción dada, por defecto la accion actual.
	 * @param string $param
	 * @param string $para
	 * @return array
	 */
	function decodificar_hash($param, $para = null)
	{
		return $this->codificador_modelo()->decodificar_fila($param, $para);
	}


	/**
	 * @throws \kernel\error_kernel
	 * @return \kernel\util\modelo\adaptador_modelo
	 */
	function codificador_modelo()
	{
		throw new error_kernel("No se encuentra configurado el adaptador de modelo para el controlador. Para utilizar
		los mecanismos de cifrado del modelo, configurar un /kernel/util/modelo/adaptador_modelo para el proyecto");
	}

	/****************************************************************************/
	/* CSRF																		*/
	/****************************************************************************/

	// Clave del value del parámetro de _POST que trae el token csrf
	const CSRF_KEY = '__csrf';

	// Registro de activación de chequeo de csrf
	protected $control_csrf = array();

	/**
	 * Indica que la acción $accion tiene que controlar csrf automáticamente antes
	 * de su invocación. Si se quiere chequear mientras se ejecuta la acción hay
	 * que hacerlo manualmente.
	 * @see check_csrf
	 * @param string $accion
	 * @throws error_kernel si la acción $accion no existe
	 */
	protected function controlar_csrf_accion($accion)
	{
		if (!$this->existe_accion($accion)) {
			throw new error_kernel("La acción '{$this->get_name_for_log()}' no existe en el controlador");
		}

		kernel::log()->add_debug("SE AGREGA CONTROL DE CSRF A '{$this->get_name_for_log($accion)}'", '');
		$this->control_csrf[$accion] = true;
	}

	protected function get_controlar_csrf($accion)
	{
		return isset($this->control_csrf[$accion]) && $this->control_csrf[$accion] === true;
	}

	/**
	 * Chequea el token csrf
	 * @throws \kernel\acceso\error_kernel_seguridad si falla la validación
	 */
	protected function check_csrf()
	{
		if (defined('TEST_STRESS__NUNCA_ACTIVAR_EN_PRODUCCION') &&
			(TEST_STRESS__NUNCA_ACTIVAR_EN_PRODUCCION == 1)
		) {
			return;
		}
		$token = $this->validate_param(self::CSRF_KEY, 'post', validador::TIPO_ALPHANUM);

		kernel::log()->add_debug('CHEQUEO CSRF', $token);

		if (isset($_SESSION['csrf'][$token])) {
			unset($_SESSION['csrf'][$token]);
		} else {
			throw new \kernel\acceso\error_kernel_seguridad("Error de chequeo de csrf [$token]");
		}
	}

	function generar_csrf()
	{
		if (!isset($_SESSION['csrf'])) {
			$_SESSION['csrf'] = array();
		}

		if (count($_SESSION['csrf']) >= self::MAX_CSRF_TOKENS) {
			// borramos el primer elemento para respetar el máximo
			reset($_SESSION['csrf']);
			$first_key = key($_SESSION['csrf']);
			unset($_SESSION['csrf'][$first_key]);
		}

		$token = 'csrf' . sha1(session_id() . uniqid());
		$_SESSION['csrf'][$token] = true;
		return $token;
	}

	/****************************************************************************/
	/* MEMORIA																	*/
	/****************************************************************************/

	protected $memoria;

	/**
	 *
	 * @return \kernel\util\memoria\memoria_sesion
	 */
	protected function memoria()
	{
		if (!isset($this->memoria)) {
			$clave = '__' . kernel::ruteador()->get_id_operacion();
			$this->memoria = new \kernel\util\memoria\memoria_sesion($clave);
		}

		return $this->memoria;
	}

	/****************************************************************************/
	/* UTIL																		*/
	/****************************************************************************/
	protected $vars;

	protected function add_var($key, $value)
	{
		if (isset($this->vars[$key])) {
			kernel::log()->add_info("SE SOBREESCRIBE LA VARIABLE COMPARTIDA '$key'", '');
		}
		$this->vars[$key] = $value;
	}

	function hay_var($key)
	{
		return isset($this->vars[$key]);
	}

	function get_var($key)
	{
		return $this->vars[$key];
	}

	function get_var_default($key, $default)
	{
		if (!$this->hay_var($key)) {
			return $default;
		}

		return $this->get_var($key);
	}

	protected function redirect_index()
	{
		$this->nuevo_request(kernel::persona()->perfil()->get_parametro('index'));
	}

	protected function finalizar_request()
	{
		throw new finalizador_request();
	}

	protected function existe_accion($accion)
	{
		$funcion = 'accion__' . $accion;
		return \method_exists($this, $funcion);
	}

	protected function invocar_accion($accion)
	{
		$funcion = 'accion__' . $accion;
		$this->$funcion();
	}

	protected function finalizar_request_con_notificaciones($titulo, $mensajes)
	{
		$e = new \kernel\error_kernel_notificaciones($titulo);
		$e->set_data($titulo, $mensajes);
		throw $e;
	}

	function nuevo_request($operacion, $accion = null)
	{
		throw new nuevo_request($operacion, $accion);
	}

	function nuevo_request_url($url, $mensaje = null)
	{
		$nuevo_req = new nuevo_request('index');
		$nuevo_req->set_url($url);
		if ($mensaje !== null) {
			$nuevo_req->set_mensaje_post_nav($mensaje);
		}
		throw $nuevo_req;
	}

	protected function get_name_for_log($accion = false)
	{
		$class = \get_called_class();
		$accion = ($accion === false) ? $this->accion : $accion;
		$funcion = 'accion__' . $accion;
		return "$class::$funcion";
	}

	/**
	 * Guarda un archivo subido y lo saca de $_FILES[$indice].
	 * @param mixed $indice el indice en el archivo $_FILES. Es el name del input
	 * @param string $path el path donde se va a guardar el archivo
	 * @return array arreglo asociativo donde los elementos tienen la siguiente estructura
	 *    array(
	 *        'nombre_fs' => (string) el nombre con el que se guardó
	 *        'nombre_original' => (string) el nombre con el que se subió el archivo
	 *    )
	 * @throws error_kernel cuando hay un error subiendo el archivo
	 */
	protected function guardar_archivos_subidos($indice, $path)
	{
		if (!isset($_FILES[$indice])) {
			return array();
		}

		$descriptor = $_FILES[$indice];

		// estructura alternativa para facilitar el consumo de archivos desde $_FILES
		$archivos = array();
		if (!is_array($descriptor)) { // se está subiendo un sólo archivo
			$archivos[] = array(
				'nombre' => $descriptor['name'],
				'tmp_name' => $descriptor['tmp_name'],
				'error' => $_FILES['error'],
				'size' => $descriptor['size']
			);
		} else {
			foreach ($descriptor['name'] as $key => $nombre) {
				if (empty($nombre)) {
					continue;
				}
				$archivos[] = array(
					'nombre' => $nombre,
					'tmp_name' => $descriptor['tmp_name'][$key],
					'error' => $descriptor['error'][$key],
					'size' => $descriptor['size'][$key]
				);
			}
		}

		$nombres = array();
		foreach ($archivos as $archivo) {
			if (!is_uploaded_file($archivo['tmp_name']) || $archivo['error'] > 0) {
				throw new error_kernel('Error subiendo archivo');
			}

			$nombre_fs = $this->get_nombre_archivo_subido($archivo['nombre']);
			$destino = "$path/$nombre_fs";
			move_uploaded_file($archivo['tmp_name'], $destino);
			$nombres[] = array(
				'nombre_fs' => $nombre_fs,
				'nombre_original' => $archivo['nombre']
			);
		}

		return $nombres;
	}

	/**
	 * Ventana para setear el nombre del archivo subido a guardar
	 * @param string $nombre_original el nombre con el que se subió el archivo
	 * @return string
	 */
	protected function get_nombre_archivo_subido($nombre_original)
	{
		$ext = pathinfo($nombre_original, PATHINFO_EXTENSION);
		return \kernel\util\manejador_archivos::nombre_valido(\base64_encode(\uniqid(\rand())) . ".$ext");
	}

	/**
	 * Envía el archivo $path a descargar con nombre de archivo $nombre_descarga,
	 * si no se setea $nombre_descarga entonces se usa PATHINFO_BASENAME del $path
	 * como nombre de la descarga.
	 * Después de enviar el archivo finaliza el request porque ya se enviaron los
	 * headers y no se puede enviar nada más al cliente.
	 * @param string $path el path del archivo a descargar
	 * @param string $nombre_descarga el nombre con el que se va a descargar el
	 * archivo
	 * @throws error_kernel si el archivo no existe
	 */
	protected function descargar_archivo($path, $nombre_descarga = false)
	{
		if (!file_exists($path)) {
			throw new error_kernel("El archivo '$path' no existe");
		}

		if ($nombre_descarga === false) {
			$nombre_descarga = pathinfo($path, PATHINFO_BASENAME);
		}

		$ext = pathinfo($path, PATHINFO_EXTENSION);
		if($ext == 'pdf') header("Content-type:application/pdf");

		header('Content-Description: File Transfer');
		header("Content-Disposition: attachment; filename=\"$nombre_descarga\"");
		header('Content-Transfer-Encoding: binary');
		header('Expires: 0');
		header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
		header('Pragma: public');
		header('Content-Length: ' . filesize($path));
		ob_clean();
		flush();
		readfile($path);

		$this->finalizar_request();
	}

    /**
     * Muestra el contenido del archivo $path en una ventana del navegador,
     * si no se setea $nombre_descarga entonces se usa PATHINFO_BASENAME del $path
     * como nombre de la descarga.
     * Después de mostrar el archivo finaliza el request porque ya se enviaron los
     * headers y no se puede enviar nada más al cliente.
     * @param string $path el path del archivo a mostrar
     * @param string $nombre_descarga el nombre con el que se va a descargar el
     * archivo
     * @throws error_kernel si el archivo no existe
     */
    protected function mostrar_archivo($path, $nombre_descarga = false)
    {
        if (!file_exists($path)) {
            throw new error_kernel("El archivo '$path' no existe");
        }

        if ($nombre_descarga === false) {
            $nombre_descarga = pathinfo($path, PATHINFO_BASENAME);
        }

        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime_type = finfo_file($finfo, $path);
        finfo_close($finfo);

        //http://yogeshchaugule.com/blog/2013/how-display-pdf-browser-php
        header('Content-type: '.$mime_type);
        header('Content-Disposition: inline; filename="' . $nombre_descarga . '"');
        header('Content-Transfer-Encoding: binary');
        header('Content-Length: ' . filesize($path));
        header('Accept-Ranges: bytes');
        @readfile($path);

        $this->finalizar_request();
    }

	/**
	 * Este método debe ser utilizado para enviar paquetes arbitrarios al cliente.
	 * NO DEBE SER UTILIZADO PARA ENVIAR CONTENIDO GENERADO POR EL USUARIO
	 * @see controlador::render_ajax_html
	 * @param string $mensaje
	 * @param mixed $params
	 * @throws finalizador_request
	 */
	protected function render_ajax($mensaje = '', $params = array())
	{
		$paquete = array(
			'cod' => 1,
			'cont' => $mensaje
		);
		$paquete = array_merge($paquete, $params);

		echo kernel::renderer()->json_encode($paquete);
		throw new finalizador_request();
	}

	protected function render_json($params = array())
	{
		$paquete = array(
			'cod' => 1,
			'cont' => $params,
		);

		echo kernel::renderer()->json_encode($paquete);
		throw new finalizador_request();
	}

	/**
	 * Utilizado para mandar contenido con html a través de ajax
	 * @param string $mensaje
	 * @param mixed $params
	 * @throws finalizador_request
	 */
	protected function render_ajax_html($mensaje = '')
	{
		echo kernel::renderer()->get_respuesta_json(1, $mensaje, $this->vista()->get_extra_params());
		throw new finalizador_request();
	}

	protected function render_raw_json($data)
	{
		echo kernel::renderer()->json_encode($data);
		throw new finalizador_request();
	}

	protected function render_template($template, $contexto)
	{
		$tpl = kernel::load_template($template);
		echo kernel::renderer()->get_respuesta_json(1, $tpl->render($contexto));
		throw new finalizador_request();
	}

	protected function trans($key)
	{
		return kernel::traductor()->trans($key);
	}
	
	/**
     * @see https://developers.google.com/recaptcha/docs/verify Documentaci�n sobre como validar Captcha.
     *
     * @return boolean true si el Captcha es valido, false si falla.
     */	public static function check_recaptcha2()
	{
		if (! kernel::proyecto()->usa_captcha()) {
			return true;
		}

		$client = new Client(['base_url' => 'https://www.google.com/recaptcha/api/']);
		$response = $client->post('siteverify', array(
			"body" => array(
				"secret" => kernel::proyecto()->get_captcha_secret_key(),
				"response" => kernel::request()->getPost("g-recaptcha-response")
			)
		));

		$resultado = rest_decode($response->json());
		kernel::log()->add_debug("=== reCAPTCHA Response ===", $resultado);
		return $resultado['success'];
	}

	/**
	 * Devuelve el termino ingresado en el autocomplete
	 * @return string El termino a buscar
	 */
	protected function getAutocompleteTerm()
	{
		//Obtengo el termino
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO, array('allowempty' => true, 'default' => ''));
		//lo decodifico
		$term = utf8_decode($term);
		//le quito los acentos y la �
		$term = caracteres_especiales::simplificar_caracteres($term);
		kernel::log()->add_debug("Termino a buscar autocomplete", $term);
		return $term;
	}
	
}

?>