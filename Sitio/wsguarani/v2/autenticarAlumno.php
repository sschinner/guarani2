<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
require_once (dirname(__DIR__).'/bcrypt.php');
require_once (dirname(__DIR__).'/Repositorio/RepositorioWS.php');

//define("URL_AUTENTICA_SIGUV_REST", "https://www.unlvirtual.edu.ar/test/campusvirtual/ws/autenticarUsuario?");

Class AtributosAutenticar
{

	public $codigoWS;
	public $mensajeWS;
	public $codigoRetorno;
	public $mensajeRetorno;
}

/* ---------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE SI EXISTE USUARIO DE AUTOGESTION - ES INVOCADA POR EL SISTEMA HEFESTO
  ---------------------------------------------------------------------------------------- */

Class Autenticar
{

	function autenticarUsuario($usuario, $clave, $credenciales)
	{
		$alumno = new AtributosAutenticar();
		$alumno->codigoWS = CODIGO_OK;
		$alumno->mensajeWS = MENSAJE_OK;
		$alumno->codigoRetorno = false;
		$alumno->mensajeRetorno = "No es usuario Guarani";

		$usuarios = $credenciales->getUsuarios();
		$passwords = $credenciales->getPasswords();
		$permitidos = array('siguv', 'hefesto', 'telematica', 'gea', 'bedeliamovil');
		$aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

		if ($aut == CODIGO_ERROR_AUTENTICACION) {
			$alumno->codigoWS = CODIGO_ERROR_AUTENTICACION;
			$alumno->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
			return $alumno;
		}

		if ($usuario == "" || $clave == "") {
			$alumno->codigoWS = CODIGO_ERROR_PARAMETROS;
			$alumno->mensajeWS = MENSAJE_ERROR_PARAMETROS;
			return $alumno;
		}

		/**
		 * ************ Autenticacion ws externo SIGUV *************
		 */
		$resultado = json_decode(self::autenticaSiguv($usuario, $clave));

		if ($resultado->mensajeRetorno->esUsuario) {
			$alumno->codigoRetorno = true;
			$alumno->mensajeRetorno = "Es usuario Guarani CEMED";
			return $alumno;
		}

		/*
		 * **************** Autenticacion Guarani 3 *****************
		 */
		$objCC = Generales::conectar("guarani3_");
		$rep = new RepositorioWS();
		$resul = $rep->validarUsuarioGuarani($usuario, $objCC);

		if (!empty($resul)) {

			$enc = new bcrypt(10);
			$hash = md5($clave);
			$login_ok = ($enc->verify($hash, $resul[0]['clave']));
			unset($enc);
			if ($login_ok) {
				$alumno->codigoRetorno = true;
				$alumno->mensajeRetorno = "Es usuario Guarani3";
				return $alumno;
			}
		}

		/*
		 * **************** Autenticacion Guarani 2 *****************
		 */
		$bases = Generales::obtener_bases_g2_sin_distancia();
		foreach ($bases as $base) {

			$objCC = Generales::conectar($base);

			if ($objCC == '3')
				continue;

			$strSQL = "execute procedure web_serv_alu_clave('" . $usuario . "');";
			$res = $objCC->Execute($strSQL);
			$objCC->Close();
			if ($res && ($res->RecordCount() > 0)) {
				$resultado = $res->getRows();
				if ($resultado) {

					$enc = new bcrypt(10);

					$login_ok = ($enc->verify(md5($clave), $resultado[0][1]));
					unset($enc);
					if ($login_ok) {
						$alumno->codigoRetorno = true;
						$alumno->mensajeRetorno = "Es usuario Guarani2: " . $db;
						return $alumno;
					}
				}
			}
		}
		return $alumno;
	}

	private function autenticaSiguv($usuario, $clave) {

        $username = 'hefesto';
        $password = 'h3f3st4';
        $url = URL_AUTENTICA_SIGUV_REST . "usuario=" . $usuario . "&clave=" . $clave;
        $digest = hash('sha256', "$username:$password");
        $headers = array('Content-Type:application/json', 'Authorization: Digest ' .$digest);
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_DIGEST);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);

        $result = curl_exec($ch);
        curl_close($ch);

        return $result;
    }

}

function autenticarAlumno($usuario, $clave) {
    $servicio = new Autenticar();
    $credenciales = new Credenciales();
    $parametros = array('usuario'=> $usuario, 'clave'=> $clave);
    Generales::logLlamada('v2/autenticarAlumno', $parametros,false);
   
    $resultado = $servicio->autenticarUsuario($usuario, $clave, $credenciales);
    return json_encode($resultado);
}

?>