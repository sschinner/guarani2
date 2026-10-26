<?php

require_once ('Repositorio/RepositorioWS.php');
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contraseña invalidas.
  '2': Error de parametros - Algun campo es vacio.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class HorariosComisiones {
    /* --------- variables datosCensalesHefesto---------- */

    public $codigoWS;
    public $mensajeWS;
    public $codigoRetorno;
    public $mensajeRetorno;
    public $materia = array();

}

/* ------------------------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE xxxxxxxxxxxxxxxxxx - ES INVOCADA POR xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ------------------------------------------------------------------------------------------------------------- */

class Cursadas {

    function datos($ua, $anio_academico, $periodo_lectivo, $tipoTitulo, $credenciales) {
		
		$cursadas = new HorariosComisiones();

		$usuarios = $credenciales->getUsuarios();
		$passwords = $credenciales->getPasswords();
		$permitidos = array('fhuc', 'extencionFich', 'bedeliamovil', 'wsingreso', 'siguv');

		$aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);
		if ($aut == CODIGO_ERROR_AUTENTICACION) {
			$cursadas->codigoWS = CODIGO_ERROR_AUTENTICACION;
			$cursadas->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
			return $cursadas;
		}
		if ($tipoTitulo == "" || $anio_academico == "" || $periodo_lectivo == "" || $ua == "") {
			$cursadas->mensajeWS = MENSAJE_ERROR_PARAMETROS;
			$cursadas->codigoWS = CODIGO_ERROR_PARAMETROS;
			return $cursadas;
		}
		$unidadAcademicaPermitida = Generales::getUnidadAcademicaUsuario($_SERVER['PHP_AUTH_USER']);

		if (strtoupper($unidadAcademicaPermitida) != $ua && $unidadAcademicaPermitida != 'todas') {
			$cursadas->mensajeWS = MENSAJE_OK;
			$cursadas->codigoWS = CODIGO_OK;
			$cursadas->mensajeRetorno = utf8_encode('No posee permisos para consultar datos de la unidad académica ' . $ua);
			$cursadas->codigoRetorno = '-5';
			return $cursadas;
		}

		if ($tipoTitulo == 0) {
			$titulos = Generales::recuperarTipoTituloConCemed($ua);
		} else {
			$titulos = array($tipoTitulo);
		}

		foreach ($titulos as $titulo) {

			$db = Generales::recuperarDB($ua, $titulo);
			$objCC = Generales::conectar($db);
			if ($objCC == '3') {
				$cursadas->codigoWS = CODIGO_ERROR_CONEXION;
				$cursadas->mensajeWS = MENSAJE_ERROR_CONEXION;
				return $cursadas;
			}

			if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
				$rep = new RepositorioWS();
				$ua = ($ua == 'EUAA') ? 'CU-G' : $ua;
				$resultado = $rep->getHorariosComisiones($anio_academico, $periodo_lectivo, $ua, $objCC);
			} else {
				$instancia = 'g2';
			$strSQL = "execute procedure web_serv_horario_catedra('{$anio_academico}', '{$periodo_lectivo}');";
				$res = $objCC->Execute($strSQL);
				$resultado = $res->getRows();
			}

			if (!empty($resultado)) {
				foreach ($resultado as $resu) {
					$arreglo['nombreMateria']		= (string) Generales::decodificador($resu[0], $instancia);
					$arreglo['codigoMateria']		= (string) $resu[1];
					$arreglo['codigoCarrera']		= (string) $resu[2];
					$arreglo['nombreCarrera']		= (string) Generales::decodificador($resu[3], $instancia);
					$arreglo['comision']			= (string) $resu[4];
					$arreglo['nombreComision']		= (string) $resu[5];
					$arreglo['apellido']			= (string) Generales::decodificador($resu[6], $instancia);
					$arreglo['nombreProfesor']		= (string) Generales::decodificador($resu[7], $instancia);
					$arreglo['documentoProfesor']	= (string) $resu[8];
					$arreglo['diaSemana']			= (string) $resu[9];
					$arreglo['nombreDia']			= (string) Generales::decodificador($resu[10], $instancia);
					$arreglo['tipoClase']			= (string) Generales::decodificador($resu[11], $instancia);
					$arreglo['horaInicio']			= (string) $resu[12];
					$arreglo['horaFin']				= (string) $resu[13];
					$arreglo['nombreAula']			= (string) Generales::decodificador($resu[14], $instancia);
					$arreglo['nombreEdificio']		= (string) Generales::decodificador($resu[15], $instancia);
					$arreglo['anioCursada']			= (string) $resu[16];
					$arreglo['ubicacion']			= (string) Generales::decodificador($resu[17], $instancia);
					$arreglo['tiene_subcomisiones']	= (bool)   $instancia == 'g2' ? false : $resu[18];
					$cursadas->materia[] = $arreglo;
					$cursadas->codigoRetorno = 0;
					$cursadas->mensajeRetorno = 'OK - Datos Horarios Comisiones';
				}
			} else {
				$cursadas->codigoRetorno = 1;
				$cursadas->mensajeRetorno = 'No se encontraron comisiones';
			}
			$cursadas->codigoWS = CODIGO_OK;
			$cursadas->mensajeWS = MENSAJE_OK;
			return $cursadas;
		}
	}
}

function detallesComisiones($ua, $anio_academico, $periodo_lectivo, $tipoTitulo) {

    $servicio = new Cursadas();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica' => $ua, 'anio_academico' => $anio_academico, 'periodo_lectivo' => $periodo_lectivo, 'tipotitulo' => $tipoTitulo);
    Generales::logLlamada('detallesComisiones', $parametros, false);

    $resultado = $servicio->datos(strtoupper(trim($ua)), $anio_academico, $periodo_lectivo, $tipoTitulo, $credenciales);
    return json_encode($resultado);
}
?>

