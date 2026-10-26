<?php
namespace kernel\util;

use kernel\kernel;
use kernel\error_kernel;
require_once 'phpmailer/class.phpmailer.php';

class mail
{
	protected $desde;
	protected $hacia;
	protected $asunto;
	protected $cuerpo;
	protected $firma;
	protected $html = false;
	protected $cc = array();
	protected $datos_configuracion;
	protected $adjuntos = array();
	protected $debug = false;
	protected $timeout = 30;
	protected $reply_to;
	protected $confirmacion;
	protected $charset;
	
	function __construct($hacia, $asunto, $cuerpo, $desde=null, $firma='', $charset='utf-8')
	{
		$this->hacia = $hacia;
		$this->asunto = $asunto;
		$this->cuerpo = $cuerpo;
		$this->desde = $desde;
		$this->firma = $firma;
		$this->charset = $charset;
		$this->charset = kernel::proyecto()->get_encoding();
		$this->datos_configuracion = kernel::proyecto()->get_parametros_smtp(); 
	}
	
	static function firma()
	{
		return $this->firma;
	}

	function enviar()
	{
		if (! isset($this->desde)) {
			$this->desde = $this->datos_configuracion['from'];
		}

		if (empty($this->reply_to)) {
			$this->reply_to = $this->datos_configuracion['reply_to'];
		}

		//Construye y envia el mail
	   	$mail = new \PHPMailer();
	   	$mail->CharSet = $this->charset;
	   	$mail->IsSMTP();
	   	if ($this->debug) {
	   		$mail->SMTPDebug = true;
	   	}
		$mail->Timeout  = $this->timeout;
		$host = trim($this->datos_configuracion['host']);
		if ($this->datos_configuracion['seguridad'] == 'ssl') {
			if (! extension_loaded('openssl')) {
				throw new error_kernel('Para usar un SMTP con encriptacion SSL es necesario activar la extension "openssl" en el php.ini');
			}
			$host = 'ssl://'.$host;
		}		
		$mail->Host = trim($host);
		if (isset($this->datos_configuracion['auth']) && $this->datos_configuracion['auth']) {
			$mail->SMTPAuth = true;
			$mail->Username = trim($this->datos_configuracion['usuario']);
			$mail->Password = trim($this->datos_configuracion['clave']);
            $seguridad = trim(strtolower($this->datos_configuracion['seguridad']));
            if($seguridad == 'tls') $mail->SMTPSecure = $seguridad;
		}
		if (isset($this->datos_configuracion['port'])) {
			$mail->Port = $this->datos_configuracion['port'];
		}
		$mail->From     = $this->desde;
		if (isset($this->datos_configuracion['from_name'])) {
			$mail->FromName = $this->datos_configuracion['from_name'];
		} else {
			$mail->FromName = $this->desde;
		}

        //Si los destinatarios son un array agregó uno por uno a la lista como copia oculta...
        if(is_array($this->hacia)){
            foreach($this->hacia as $destinatario){
                $mail->AddBCC($destinatario);
            }
        }
        else{//...sino agrego solo uno como destinatario.
            $mail->AddAddress($this->hacia);
        }

		foreach($this->cc as $copia){
			$mail->AddCC($copia);
		}

		if (isset($this->reply_to)){
			$mail->AddReplyTo($this->reply_to);
		}
		
		if (isset($this->confirmacion)){
			$mail->ConfirmReadingTo = $this->confirmacion;
		}
			
		$mail->Subject  = $this->asunto;
		$mail->Body     = $this->cuerpo;
		$mail->IsHTML($this->html);
		$temporales = array();

		foreach (array_keys($this->adjuntos) as $id_adjunto) {
			if (! is_null($this->adjuntos[$id_adjunto]['cid'])) {
				$mail->AddEmbeddedImage($this->adjuntos[$id_adjunto]['archivo'], 
						$this->adjuntos[$id_adjunto]['cid'],
						$this->adjuntos[$id_adjunto]['nombre']);
			} else {
				$mail->AddAttachment($this->adjuntos[$id_adjunto]['archivo'], 
						$this->adjuntos[$id_adjunto]['nombre']);
			}
		}
		
		$exito = $mail->Send();
        $hacia = is_array($this->hacia)? implode(", ", $this->hacia) : $this->hacia;
		$info = "Enviado mail con asunto {$this->asunto} a {$hacia}";
		kernel::log()->add_info("Mail", $info);
		
		//Elimina los temporales creado para los attachments
		foreach ($temporales as $temp) {
			unlink($temp);
		}
		if (!$exito) {
			throw new error_kernel($mail->ErrorInfo);
		}			
	}
	
	function set_cc($direcciones = array())
	{
		$this->cc = $direcciones;
	}
	
	function set_html($html=true)
	{
		$this->html = true;
	}
	
	function set_reply($reply)
	{
		$this->reply_to = $reply;
	}
	
	function set_confirmacion($confirm)
	{
		$this->confirmacion = $confirm;
	}

	/**
	 * Agrega un archivo adjunto al mail
	 * @param string $nombre Nombre del archivo a mostrarse en el correo
	 * @param string $path_archivo Path al archivo en el disco
	 */
	function agregar_adjunto($nombre, $path_archivo, $cid = null)
	{
		$this->adjuntos[] = array(
			'nombre' => $nombre,
			'archivo' => $path_archivo,
			'cid' => $cid
		);
	}

    /**
     * Establece el o los destinatarios del email a enviar.
     * @param string|array $hacia algunas veces string (un solo destinatario), otras array (varios destinatarios)
     */
    function set_hacia($hacia)
    {
        $this->hacia = $hacia;
    }

}

?>