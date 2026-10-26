<?php
/* -----------------------------------------------------------------------------------------
  CODIGO DE ERRORES DE WEBSERVICES:
  '0': OK - La funcion se ejecuto correctamente.
  '1': Error de autenticacion - Usuario y contrase�a invalidas.
  '2': Error de parametros - Algun campo es vacio o erroneo.
  '3': Error de conexion - La conexion a la base de datos no se pudo establecer correctamente.
  '4': Error de procedimiento - Algo salio mal dentro de la funcion.
  ------------------------------------------------------------------------------------------ */
require_once ('Repositorio/RepositorioWS.php');

class TurnosExamen {
    public $codigoWS;
    public $mensajeWS;
	public $turnos_examen = array();
}

class DatosTurnosExamen {

    function datos($ua, $tipoTitulo, $anio_academico, $credenciales) {

        $datosTurnosExamen = new TurnosExamen();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('bedeliamovil', 'fhuc');
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosTurnosExamen->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datosTurnosExamen->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $datosTurnosExamen;
        }

        if ($ua == "" || $tipoTitulo == "" || $anio_academico == "") {
            $datosTurnosExamen->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            $datosTurnosExamen->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosTurnosExamen;
		}

        if (!Generales::verificaUnidadAcademica($ua)) {
            $datosTurnosExamen->mensajeWS = utf8_encode("Error de parametros - Unidad Académica " . $ua . " inexistente - Verifique");
            $datosTurnosExamen->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosTurnosExamen;
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
					$datosTurnosExamen->codigoWS = CODIGO_ERROR_CONEXION;
					$datosTurnosExamen->mensajeWS = MENSAJE_ERROR_CONEXION;
					return $datosTurnosExamen;
				}

				if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
					$instancia = 'g3';
					$rep = new RepositorioWS();    
					$ua = ($ua == 'EUAA') ? 'CU-G' : $ua;
					$resultado = $rep->obtenerTurnosExamen($anio_academico, $ua, $objCC);

				} else {
					$instancia = 'g2';
					$sql = "EXECUTE PROCEDURE ws_turnos_examen('{$anio_academico}');";
					$res = $objCC->Execute($sql);
					$resultado = $res->getRows();
				}

				if (!empty($resultado)) {
					foreach ($resultado as $resu) {
						$arreglo['turnoExamen']= (string) Generales::decodificador($resu[0], $instancia);
						$arreglo['nombre']		= (string) Generales::decodificador($resu[1], $instancia);
						$arreglo['turno_tipo']	= $resu[2];
						$arreglo['fecha_inicio']= $resu[3];
						$arreglo['fecha_fin']	= $resu[4];
						$arreglo['tipoTitulo']	= $titulo;
						$datosTurnosExamen->turnos_examen[] = $arreglo;
					}
				}
		}

		$datosTurnosExamen->codigoWS = CODIGO_OK;
		$datosTurnosExamen->mensajeWS = MENSAJE_OK;
		return $datosTurnosExamen;
	}
}

function turnosExamen($unidad_academica, $tipoTitulo, $anio_academico) {
    $servicio = new DatosTurnosExamen();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=> $unidad_academica, 'tipoTitulo' => $tipoTitulo, 'anioAcademico' => $anio_academico);
    Generales::logLlamada('turnosExamen', $parametros, false);

    $resultado = $servicio->datos(strtoupper(trim($unidad_academica)), $tipoTitulo, $anio_academico, $credenciales);
    return json_encode($resultado);
}

?>
