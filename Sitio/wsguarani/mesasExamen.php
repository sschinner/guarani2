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

class MesasExamen {
    public $codigoWS;
    public $mensajeWS;
	public $mesas_examen = array();
}

class DatosMesasExamen {

    function datos($ua, $tipoTitulo, $anio_academico, $turno_examen, $credenciales) {

        $datosMesasExamen = new MesasExamen();
        
        $usuarios = $credenciales->getUsuarios();
        $passwords = $credenciales->getPasswords();
        $permitidos = array('wsingreso', 'bedeliamovil', 'fhuc');
        $aut = Generales::autenticarAutorizar($usuarios, $passwords, $permitidos);

        if ($aut == CODIGO_ERROR_AUTENTICACION) {
            $datosMesasExamen->codigoWS = CODIGO_ERROR_AUTENTICACION;
            $datosMesasExamen->mensajeWS = MENSAJE_ERROR_AUTENTICACION;
            return $datosMesasExamen;
        }

        if ($ua == "" || $tipoTitulo == "" || $anio_academico == "") {
            $datosMesasExamen->mensajeWS = MENSAJE_ERROR_PARAMETROS;
            $datosMesasExamen->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosMesasExamen;
		}

        if (!Generales::verificaUnidadAcademica($ua)) {
            $datosMesasExamen->mensajeWS = utf8_encode("Error de parametros - Unidad Académica " . $ua . " inexistente - Verifique");
            $datosMesasExamen->codigoWS = CODIGO_ERROR_PARAMETROS;
            return $datosMesasExamen;
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
					$datosMesasExamen->codigoWS = CODIGO_ERROR_CONEXION;
					$datosMesasExamen->mensajeWS = MENSAJE_ERROR_CONEXION;
					return $datosMesasExamen;
				}

				if (($titulo == '7') || (Generales::verificaUAPS($ua, $titulo))) {
					$instancia = 'g3';
					$rep = new RepositorioWS();    
					$ua = ($ua == 'EUAA') ? 'CU-G' : $ua;
					$resultado = $rep->obtenerMesasExamen($ua, $turno_examen, $objCC);

				} else {
					$instancia = 'g2';
					$sql = "EXECUTE PROCEDURE ws_mesas_examen({$anio_academico}, '{$turno_examen}');";
					$res = $objCC->Execute($sql);
					$resultado = $res->getRows();
				}

				if (!empty($resultado)) {
					foreach ($resultado as $resu) {
						$arreglo['mesa_codigo']			= (string) Generales::decodificador($instancia === 'g3' ? $resu[0] : $resu[4], $instancia);
						$arreglo['mesa_nombre']			= (string) Generales::decodificador($instancia === 'g3' ? $resu[3] : $resu[0], $instancia);
						$arreglo['actividad_codigo']	= (string) Generales::decodificador($resu[1], $instancia);
						$arreglo['actividad_nombre']	= (string) Generales::decodificador($resu[2], $instancia);
						$arreglo['llamados']			= $this->obtener_llamados_mesa($resu[0], $resu[1], $anio_academico, $turno_examen, $instancia, $objCC);
						$arreglo['tribunal']			= $this->obtener_tribunal_mesa($resu[0], $resu[1], $anio_academico, $turno_examen, $instancia, $objCC);
						$arreglo['propuestas']			= $instancia === 'g3' ? $this->obtener_propuestas_habilitadas_g3($resu[0], $objCC) : [['propuesta_nombre' => utf8_encode($resu[3])]];
						$arreglo['inscriptos']			= (integer) $this->obtener_inscriptos_mesa($resu[0], $resu[1], $anio_academico, $turno_examen, $instancia, $objCC);
						$datosMesasExamen->mesas_examen[] = $arreglo;
					}
				}
		}
		$datosMesasExamen->codigoWS = CODIGO_OK;
		$datosMesasExamen->mensajeWS = MENSAJE_OK;
		return $datosMesasExamen;
	}
	
	function obtener_propuestas_habilitadas_g3($mesa_examen, $objCC)
	{
		$rep = new RepositorioWS();    
		$resultado = $rep->obtenerPropuestasHabilitadas($mesa_examen, $objCC);
		return $resultado;
	}
	
	function obtener_tribunal_mesa($mesa_examen, $materia, $anio_academico, $turno_examen, $instancia, $objCC)
	{
		if ($instancia === 'g3') {
			$rep = new RepositorioWS();    
			$resultado = $rep->obtenerTribunalMesa($mesa_examen, $objCC);						
		}
		elseif ($instancia === 'g2') {
			$sql = "SELECT P.apellido, P.nombres
					FROM sga_docentes_llama DL
					JOIN sga_docentes D ON DL.legajo = D.legajo
					JOIN sga_personas P ON P.nro_inscripcion = D.nro_inscripcion
					WHERE anio_academico = {$anio_academico} AND turno_examen = '{$turno_examen}' AND materia = '{$materia}' AND mesa_examen = '{$mesa_examen}';";
			$res = $objCC->Execute($sql);
			$resultado = $res->getRows();
		}
		if (!empty($resultado)) {
			foreach ($resultado as $resu) {
				$docentes[] = ['apellido' => (string) Generales::decodificador($resu['apellido'], $instancia), 'nombres' => (string) Generales::decodificador($resu['nombres'], $instancia)];
			}
			$resultado = $docentes;
		}
		return $resultado;
	}
	
	function obtener_inscriptos_mesa($mesa_examen, $materia, $anio_academico, $turno_examen, $instancia, $objCC)
	{
		if ($instancia === 'g3') {
			$rep = new RepositorioWS();    
			$resultado = $rep->obtenerInscriptosMesa($mesa_examen, $objCC);						
		}
		elseif ($instancia === 'g2') {
			$sql = "SELECT count(*) as inscriptos FROM sga_insc_examen WHERE anio_academico = {$anio_academico} AND turno_examen = '{$turno_examen}' AND mesa_examen = '{$mesa_examen}' AND materia = '{$materia}';";
			$resultado = $objCC->getOne($sql);
		}
		return $resultado;
	}
	
	function obtener_llamados_mesa($mesa_examen, $materia, $anio_academico, $turno_examen, $instancia, $objCC)
	{
		if ($instancia === 'g3') {
			$rep = new RepositorioWS();    
			$resultado = $rep->obtenerLlamadosMesa($mesa_examen, $objCC);						
		}
		elseif ($instancia === 'g2') {
			$sql = "SELECT 
						LM.llamado, PRE.fecha, PRE.hora_inicio, PRE.hora_finalizacion
					FROM		sga_llamados_mesa LM	
					JOIN		sga_prestamos PRE		ON LM.prestamo = PRE.prestamo
					WHERE 
						LM.anio_academico = {$anio_academico} AND LM.turno_examen = '{$turno_examen}' AND LM.mesa_examen = '{$mesa_examen}'	AND LM.materia = '{$materia}'";
			$res = $objCC->Execute($sql);
			$resultado = $res->getRows();
			
			if (isset($resultado)) {
				foreach ($resultado as $resu) {
					$llamados[] = ['llamado' => (integer) $resu['llamado'], 'llamado_nombre' => (string) $resu['llamado'], 'fecha' => $resu['fecha'], 'hora_inicio' => $resu['hora_inicio'], 'hora_finalizacion' => $resu['hora_finalizacion']];
				}
				$resultado = $llamados;
			}			
		}
		return $resultado;		
	}
}

function mesasExamen($unidad_academica, $tipoTitulo, $anio_academico, $turno_examen) {
    $servicio = new DatosMesasExamen();
    $credenciales = new Credenciales();
    $parametros = array('unidadAcademica'=> $unidad_academica, 'tipoTitulo' => $tipoTitulo, 'anioAcademico' => $anio_academico, 'turnoExamen' => $turno_examen);
    Generales::logLlamada('mesasExamen', $parametros, false);

    $resultado = $servicio->datos(strtoupper(trim($unidad_academica)), $tipoTitulo, $anio_academico, $turno_examen, $credenciales);
    return json_encode($resultado);
}

?>
