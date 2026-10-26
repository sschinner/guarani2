<?php
namespace kernel\util;

use Auth_OpenID;
use kernel\acceso\error_kernel_login;
use kernel\kernel;
use kernel\nucleo\nuevo_request;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login_externo;
use siu\guarani;

/**
 * Helpers para usar openid/oauth.
 */
class servicios_externos
{

	//Precaucion!!
	public function openid_mail($conf, $callback_url)
	{
		$to_url = $conf['url'];
		set_include_path(get_include_path() . PATH_SEPARATOR . realpath(kernel::dir().'/../janrain'));
		require_once "Auth/OpenID/Consumer.php";
		require_once "Auth/OpenID/FileStore.php";
		require_once "Auth/OpenID/SReg.php";
		require_once "Auth/OpenID/AX.php";
		require_once "Auth/OpenID/PAPE.php";
		$temp = kernel::proyecto()->get_dir_temp().DIRECTORY_SEPARATOR .'janrain';
		if(!file_exists($temp)) {
			mkdir($temp);
		}
		$store = new \Auth_OpenID_FileStore($temp);
		$consumer = new \Auth_OpenID_Consumer($store);

		if($this->es_callback_openid()) {
//			$query = array();
//			foreach(\Auth_OpenID::getQuery() as $k => $v) {
//				if($k != '__a' && $k != '__o')	$query[$k] = $v; //los genera el rewrite, los saco!
//			}
			$return_url = $callback_url; // kernel::url()->self();
			$url_parts = parse_url( $_SERVER[ 'REQUEST_URI' ] );
			$response = $consumer->complete($return_url, Auth_OpenID::params_from_string( $url_parts[ 'query' ] ));

			if($response->status == Auth_OpenID_SUCCESS) {
				$ax = \Auth_OpenID_AX_FetchResponse::fromSuccessResponse($response);
				$email = false;
				if(isset($ax->data['http://axschema.org/contact/email'])) {
					$email = $ax->data['http://axschema.org/contact/email'][0];
				}
				$sreg = \Auth_OpenID_SRegResponse::fromSuccessResponse($response)->contents();
				if(isset($sreg['email'])) {
					$email = $sreg['email'];
				}
				if($email) {
					return array('id'=>$response->getDisplayIdentifier(), 'mail'=>$email);
				} else {
					throw new error_kernel_login('No se pudo conseguir el email desde OpenID');
				}
			} elseif($response->status == Auth_OpenID_CANCEL) {
				throw new error_kernel_login('Verificación cancelada');
			} elseif($response->status == Auth_OpenID_FAILURE) {
				throw new error_kernel_login('Error de autenticación de OpenID: '.$response->message);
			}
		} else {
			//redirijo a openid
			$ax = new \Auth_OpenID_AX_FetchRequest();
			$ax->add(\Auth_OpenID_AX_AttrInfo::make('http://axschema.org/contact/email', 1, true, 'email'));
			$sreg = \Auth_OpenID_SRegRequest::build(array('email'),array('fullname', 'nickname'));
			$request = $consumer->begin($to_url);
			$request->addExtension($ax);
			$request->addExtension($sreg);

			$url = $request->redirectURL('http'.($_SERVER['SERVER_PORT']==80?'':'s').'://'.$_SERVER['HTTP_HOST'].$_SERVER['ACC_ALIAS'], $callback_url);

			$nr = new nuevo_request();
			$nr->set_url($url);
			throw $nr;

		}
	}

	protected function es_callback_openid()
	{
		return isset($_REQUEST['openid_mode']);
	}

	/**
	 * Atencion!! esta probado para facebook y para google.Parece poco robusto
	 */
	public function oauth2_mail($conf, $return_url)
	{

		if (kernel::url()->get_param('code') != null) {
			if (!isset($_SESSION['state']) || kernel::url()->get_param('state') != $_SESSION['state']) {
				unset($_SESSION['state']);
				throw new error_kernel_login('El parámetro state no coincide. Usted podría estar sufriendo un ataque "Cross Site Request Forgery"');
			}

			$code = kernel::url()->get_param('code');
			$params_token = array(
				'client_id'     => $conf['app_key'],
				'redirect_uri'  => $return_url,
				'client_secret' => $conf['app_secret'],
				'code'          => $code,
				'grant_type'    => 'authorization_code');


			$response = $this->get_external_url($conf['acc_url'], $params_token, true);


			if(substr($response,0, 1) == '{'){ //testeo rapido si es en json (google) o no (facebook)
				$params = json_decode($response, true);
			}else {
				parse_str($response, $params);
			}
            if(!isset($params['access_token'])){
                throw new error_kernel_login('No se pudo conectar con el servicio externo');
            }

			$json = json_decode($this->get_external_url($conf['id_url'], array('access_token' => $params['access_token']), false), true);
			$id = $json[$conf['id_path']];

//			if (isset($conf['email_url'])) {
//				$json = json_decode($this->get_external_url($conf['email_path'], array('access_token' => $params['access_token']) ), true);
//			}
			$email = $json[$conf['email_path']]; //el mail puede salir del primer json, y si no esta hay que llamar al segundo
			unset($_SESSION['state']);

			return array('id' => $id, 'mail' => $email);
		} else {
			if (kernel::url()->get_param('error_code')) { // error
//				$error_reason = $this->validate_param('error_reason', 'get', validador::TIPO_TEXTO);
//				$error_name = $this->validate_param('error', 'get', validador::TIPO_ALPHANUM);
//				$error_desc = $this->validate_param('error', 'get', validador::TIPO_TEXTO);
//				throw new error_guarani_login_externo($error_name.' ('.$error_reason.'): '.$error_desc);
				//ESTAS 3 LINEAS DE ARRIBA NO FUNCIONAN, NO ES UN METODO DE ESTA CLASE... Y PARA QUE SE VALIDAN?
				$e = new error_kernel_login('Error al procesar respuesta Oauth. -' . kernel::url()->get_param('error_message'));
				kernel::log()->add_error($e);
				throw $e;
			} else {
				$_SESSION['state'] = urlencode(substr(md5(kernel::url()->self() . time()), 0, 8));
				$my_url = urlencode($return_url);

				/////////////////////////////////////
				/////@TODO: este exit sale como un shutdown en el log!
				//////////////////////////////////////
				header("Location: {$conf['auth_url']}?client_id={$conf['app_key']}&scope={$conf['scope']}&state={$_SESSION['state']}&redirect_uri=$my_url&response_type=code");
				exit;
			}
		}
	}

/*	protected function oauth1($servicio, $return_url, $name)
	{
		if(extension_loaded('OAuth')) {
			try {
				$conf = $servicio['conf'];
				if($conf) {
					if(!isset($_REQUEST['oauth_token']) && $_SESSION['state']==1) $_SESSION['state'] = 0;
					$oauth = new \OAuth($conf['app_key'],$conf['app_secret']);
					$oauth->enableDebug();
					if(!isset($_REQUEST['oauth_token']) && !$_SESSION['state']) {
						$request_token_info = $oauth->getRequestToken($conf['req_url'], $return_url);
						$_SESSION['secret'] = $request_token_info['oauth_token_secret'];
						$_SESSION['state'] = 1;
						if(isset($conf['auth_url'])) {
							header('Location: '.$conf['auth_url'].'?oauth_token='.$request_token_info['oauth_token']);
							exit;
						}
					}
					if($_SESSION['state']==1 && (isset($_REQUEST['oauth_token']) || !isset($conf['auth_url']))) {
						$oauth->setToken(isset($_REQUEST['oauth_token'])?$_REQUEST['oauth_token']:$request_token_info['oauth_token'],$_SESSION['secret']);
						$access_token_info = $oauth->getAccessToken($conf['acc_url']);
						$_SESSION['state'] = 2;
						$_SESSION['token'] = $access_token_info['oauth_token'];
						$_SESSION['secret'] = $access_token_info['oauth_token_secret'];
					}
					$oauth->setToken($_SESSION['token'],$_SESSION['secret']);
					$oauth->fetch($conf['id_url']);
					$json = json_decode($oauth->getLastResponse());
					eval('$id = $json->'.$conf['id_path'].';');
					if(isset($conf['email_url'])) {
						$oauth->fetch($conf['email_url']);
						$json = json_decode($oauth->getLastResponse());
					}
					eval('$email = $json->'.$conf['email_path'].';');
					unset($_SESSION['state']);
					return array('id'=>$id, 'email'=>$email);
				} else {
					throw new error_guarani("El servicio $name no está configurado para oauth versión 1");
				}
			} catch(OAuthException $e) {
				throw new error_guarani_login_externo($e->getMessage());
			}
		} else {
			throw new error_guarani('No puede autenticar con oauth versión 1. La extensión "oauth" de php no está cargada');
		}
	}
*/

	protected function get_external_url($url, $params, $post = false)
	{
		$timeout = 10;
		$ch = curl_init();

		if($post){
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $params);

		}else {
			$query = http_build_query($params);
			curl_setopt($ch, CURLOPT_URL, $url . '?' . $query);
		}

		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);

		$data = curl_exec($ch);
        klog(curl_error($ch));
        curl_close($ch);
		return $data;
	}


}
?>
