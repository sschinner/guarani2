<?php

/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio o erroneo.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */

//require_once("adodb/adodb.inc.php");

Class PeriodosLectivos {

    public $codigoWS;
    public $mensajeWS;
	public $periodos_lectivos = array();

}

/* ---------------------------------------------------------------------------------------------
  FUNCION QUE DEVUELVE EL ESTADO EN QUE SE ENCUENTRA EN ASPIRANTE/ALUMNO Y SUS REQUISITOS PRESENTADOS
  ---------------------------------------------------------------------------------------------- */

Class DatosPeriodosLectivos {

    function datos($ua, $tipoTitulo, $anio_academico, $credenciales) {

        $datosPeriodosLectivos = new PeriodosLectivos();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'bedeliamovil', 'siguv');
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosPeriodosLectivos->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datosPeriodosLectivos->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $datosPeriodosLectivos;
        }

        if ($ua == "" || $tipoTitulo == "" || $anio_academico == "") {
            $datosPeriodosLectivos->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            $datosPeriodosLectivos->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosPeriodosLectivos;
		}

        if (!Generales::verificaUnidadAcademica($ua)) {
            $datosPeriodosLectivos->mensajeWS = utf8_encode("Error de parametros - Unidad Académica " . $ua . " inexistente - Verifique");
            $datosPeriodosLectivos->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosPeriodosLectivos;
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
					$datosPeriodosLectivos->codigoWS = CODIGO_ERROR_CONEXION;
					$datosPeriodosLectivos->mensajeWS = MENSAJE_ERROR_CONEXION;
					return $datosPeriodosLectivos;
				}

				if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
					$instancia = 'g3';
					$rep = new RepositorioWS();    
					$ua = ($ua == 'EUAA') ? 'CU-G' : $ua;
					$resultado = $rep->obtenerPeriodosLectivos($anio_academico, $ua, $objCC);

				} else {
					$instancia = 'g2';
					$sql = "EXECUTE PROCEDURE ws_periodos_lectivos('{$anio_academico}');";
					$res = $objCC->Execute($sql);
					$resultado = $res->getRows();
				}

				if (!empty($resultado)) {
					foreach ($resultado as $resu) {
						$arreglo['periodo_lectivo'] = (string) Generales::decodificador($resu[0], $instancia);
						$arreglo['inicio']			= $resu[1];
						$arreglo['fin']				= $resu[2];
						$arreglo['tipoTitulo']		= $titulo;
						$datosPeriodosLectivos->periodos_lectivos[] = $arreglo;
					}
				}
		}

		$datosPeriodosLectivos->codigoWS = CODIGO_OK;
		$datosPeriodosLectivos->mensajeWS = MENSAJE_OK;
		return $datosPeriodosLectivos;
	}
}

function periodosLectivos($unidad_academica, $tipoTitulo, $anio_academico) {
    $servicio = new DatosPeriodosLectivos();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=> $unidad_academica, 'tipoTitulo' => $tipoTitulo, 'anioAcademico' => $anio_academico);
    Generales::logLlamada('periodosLectivos', $parametros, false);

    $resultado = $servicio->datos(strtoupper(trim($unidad_academica)), $tipoTitulo, $anio_academico, $credenciales);
    return json_encode($resultado);
}

?>
