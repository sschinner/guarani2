<?php
namespace personalizacionPOSGRADO\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\conf\datos_comunes_actas;

class docente extends \siu\modelo\datos\db\docente
{
	/**
	 * parametros: _ua, nro_inscripcion, anio_academico, turno, nombre
	 * param_null: anio_academico, turno, nombre
	 * cache: no
	 * filas: n
	 */
	function acta_examenes($parametros)
	{
		$sql = "execute procedure sp_busq_actaexa(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .",";
		if (empty($parametros["anio_academico"]) or $parametros["anio_academico"] == "''") $sql .= "NULL"; else $sql .= $parametros["anio_academico"]."";
		if (empty($parametros["turno"]) or $parametros["turno"] == "''") $sql .= ", NULL"; else $sql .= ", ".$parametros["turno"]."";
		if (empty($parametros["nombre"]) or $parametros["nombre"] == "''") $sql .= ", NULL)"; else $sql .= ", ".$parametros["nombre"].");";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		$i = 0;
                
		foreach($datos as $id => $dato) {
			if ($dato[9] != "B"){
				$nuevo[$i]['ANIO_ACADEMICO'] = $dato[5];
				$nuevo[$i]['ID_ANIO_ACADEMICO'] = catalogo::generar_id($dato[5]);
				$nuevo[$i]['TURNO_EXAMEN'] = $dato[6];
				$nuevo[$i]['ID_TURNO_EXAMEN'] = catalogo::generar_id($dato[6]);
				$nuevo[$i]['SEDE'] = $dato[12];
				$nuevo[$i]['ACTA'] = $dato[1];
				$nuevo[$i]['URL_ACTA'] = catalogo::generar_id($dato[1]);
				$nuevo[$i]['TIPO_ACTA'] = datos_comunes_actas::get_tipo_acta($dato[2]);
				$nuevo[$i]['MATERIA'] = $dato[4]." (".$dato[3].")";
				$nuevo[$i]['ESTADO'] = datos_comunes_actas::get_estado_acta($dato[9]);
				$nuevo[$i]['ROL_DOCENTE'] = datos_comunes_actas::get_rol_docente($dato[10]);
				$nuevo[$i]['FECHA'] = $dato[14];
				$nuevo[$i]['MESA'] = $dato[15];

				if (!empty($dato[8])){
					$nuevo[$i]['FECHA_CIERRE'] = date("d/m/Y", strtotime($dato[8]));
				} else {
					$nuevo[$i]['FECHA_CIERRE'] = "-";
				}
				$i++;
			}
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, tipo_acta, acta
	 * cache: no
	 * filas: n
	 */
	function detalle_acta_examen($parametros)
	{
		// *********** Cabecera del Acta de examen *********************
		$sql_cab = "EXECUTE PROCEDURE sp820_cab_acta_examen(" . $parametros["_ua"] . ", ".$parametros["tipo_acta"].", " . $parametros["acta"] .")";
		$datos_cab = kernel::db()->consultar($sql_cab, db::FETCH_NUM);
		
		// *********** Alumnos del Acta de Examen **********************
		$sql = "execute procedure sp_detalle_acta_ex(" . $parametros["_ua"] . ", ".$parametros["tipo_acta"].", " . $parametros["acta"] .")";        
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		
		$nuevo = array();
		// ENCABEZADO
		if (!empty($datos_cab)){
			$datos_cab = $datos_cab[0];
			
			// *********** Docentes ****************************************
			$sql_doc = "EXECUTE PROCEDURE sp820_doc_una_mesa(".$parametros["_ua"].",'".$datos_cab[3]."','".$datos_cab[5]."','".$datos_cab[6]."','".$datos_cab[7]."','".$datos_cab[8]."')";
			$docentes = kernel::db()->consultar($sql_doc, db::FETCH_NUM);
			
			$nuevo['ENCABEZADO']['MATERIA'] = $datos_cab[4].' (' . $datos_cab[3] . ')';
			$nuevo['ENCABEZADO']['ACTA'] = $datos_cab[2];
			$nuevo['ENCABEZADO']['ANIO_ACAD'] = $datos_cab[5];
			$nuevo['ENCABEZADO']['FOLIO'] = $datos_cab[16];
			$nuevo['ENCABEZADO']['TURNO'] = $datos_cab[6];
			$nuevo['ENCABEZADO']['MESA'] = $datos_cab[7];
			$nuevo['ENCABEZADO']['LIBRO'] = $datos_cab[19];
			$nuevo['ENCABEZADO']['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($datos_cab[20]);
			$nuevo['ENCABEZADO']['APERTURA'] = $datos_cab[10];
                        $nuevo['ENCABEZADO']['NCARRERA'] = $datos_cab[22];
                        $nuevo['ENCABEZADO']['NUA'] = $datos_cab[21];
                        $nuevo['ENCABEZADO']['PLAN'] = $datos_cab[23];
                        $nuevo['ENCABEZADO']['CONFECCION'] = $datos_cab[24];
			$nuevo['ENCABEZADO']['DOCENTES'] = "";
                        $nuevo['ENCABEZADO']['VERSION'] = $datos_cab[26];
                        $nuevo['ENCABEZADO']['VERSION_IMPRESA'] = $datos_cab[27];
                        $nuevo['ENCABEZADO']['NRO_ULTIMA_COPIA'] = $datos_cab[28];
			if (!empty($docentes)){
				$nuevo['ENCABEZADO']['DOCENTES'] = $docentes[0][0];
			}

			$nuevo['ENCABEZADO']['OBS'] = "-";
			if (!empty($datos_cab[15])){
				$nuevo['ENCABEZADO']['OBS'] = $datos_cab[15];
			}
		}
		
		if (!empty($datos)){
			$folio = false;
			foreach($datos as $id => $dato) {
				if ($folio <> $dato[5]){
					$folio = $dato[5];
				}

				$nuevo['CUERPO'][$folio][$id]['RENGLON'] = $dato[6];
				$nuevo['CUERPO'][$folio][$id]['LEGAJO'] = $dato[3];
				$nuevo['CUERPO'][$folio][$id]['APE_NOM'] = $dato[16].", ".$dato[17];
				$nuevo['CUERPO'][$folio][$id]['CONDICION'] = datos_comunes_actas::get_condicion($dato[7]);
				$nuevo['CUERPO'][$folio][$id]['NOTA_NUM'] = $dato[10];
                                $nuevo['CUERPO'][$folio][$id]['NRO_DOCUMENTO'] = $dato[19];

				if (!empty($dato[8])){
					$nuevo['CUERPO'][$folio][$id]['FECHA'] = date("d/m/Y", strtotime($dato[8]));
				} else {
					$nuevo['CUERPO'][$folio][$id]['FECHA'] = $dato[8];
				}

				if ($dato[14] != "") 
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '(' . $dato[14] . ')';
				else 
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '&nbsp;';

				$nuevo['CUERPO'][$folio][$id]['RESULTADO'] = datos_comunes_actas::get_resultado($dato[9]);
				$nuevo['CUERPO'][$folio][$id]['CONCEPTO'] = $dato[15];
			}
		}
		return $nuevo;
	}
        
        /**
	 * parametros: _ua, nro_inscripcion, anio_academico, periodo_lectivo, nombre
	 * param_null: anio_academico, periodo_lectivo, nombre
	 * cache: no
	 * filas: n
	 */
        function acta_cursadas($parametros)
	{
		$sql = "execute procedure sp_busq_actareg(" . $parametros["_ua"] . ", " . $parametros["nro_inscripcion"] .",";
		if (empty($parametros["anio_academico"]) or $parametros["anio_academico"] == "''") $sql .= "NULL"; else $sql .= $parametros["anio_academico"];        
		if (empty($parametros["periodo_lectivo"]) or $parametros["periodo_lectivo"] == "''") $sql .= ",NULL"; else $sql .= ", ".$parametros["periodo_lectivo"];
		if (empty($parametros["nombre"]) or $parametros["nombre"] == "''") $sql .= ", NULL)"; else $sql .= ", ".$parametros["nombre"].");";

		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['URL_ACTA'] = catalogo::generar_id($dato[3]);
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[1];
			$nuevo[$id]['PERIODO_LECTIVO'] = $dato[2];
			$nuevo[$id]['ACTA'] = $dato[3];
			$nuevo[$id]['MATERIA'] = $dato[4];
			$nuevo[$id]['NOMBRE_MATERIA'] = $dato[5];			
			$nuevo[$id]['FECHA_CIERRE'] = $dato[6];            
			$nuevo[$id]['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($dato[7]);
			$nuevo[$id]['SEDE'] = $dato[8];
			$nuevo[$id]['NOMBRE_SEDE'] = $dato[9];
		}
		return $nuevo;
	}

	/**
	 * parametros: _ua, acta
	 * cache: no
	 * filas: n
	 */
	function detalle_acta_cursada($parametros)
	{
		// *********** Datos de la cabecera del Acta ******************
		$sql_cab = "EXECUTE PROCEDURE sp820_cab_actacursado(".$parametros['_ua'].",". $parametros['acta'].")"; 
		$datos_cab = kernel::db()->consultar($sql_cab, db::FETCH_NUM);

		// ******************* Alumnos del Acta *******************************
		$sql = "execute procedure sp_detalle_acta_cu(" . $parametros["_ua"] . ", " . $parametros["acta"] .")";        
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);

		$nuevo = array();
		
		// ENCABEZADO
		if (!empty($datos_cab)){
			$datos_cab = $datos_cab[0];
			
			// Docentes de la comision
			$sql_doc = "EXECUTE PROCEDURE sp_docentes_com(".$datos_cab[4].")"; 
			$datos_doc = kernel::db()->consultar($sql_doc, db::FETCH_NUM);
			
			// El valor de retorno $datos_cab[13] corresponde al estado del Acta de Promocion!!!
			// Estado del Acta de Regulares:
			$nuevo['ENCABEZADO']['ESTADO_ACTA'] = datos_comunes_actas::get_estado_acta($datos_cab[20]);
			$nuevo['ENCABEZADO']['MATERIA'] = $datos_cab[7].' (' . $datos_cab[6] . ')';
			$nuevo['ENCABEZADO']['ACTA'] = $datos_cab[1];
			$nuevo['ENCABEZADO']['ANIO_ACAD'] = $datos_cab[8];
			$nuevo['ENCABEZADO']['FOLIOS'] = $datos_cab[17];
			$nuevo['ENCABEZADO']['PER_LEC'] = $datos_cab[9];
			$nuevo['ENCABEZADO']['COMISION'] = $datos_cab[4];
			$nuevo['ENCABEZADO']['COMISION_NOMBRE'] = $datos_cab[5];
			$nuevo['ENCABEZADO']['LIBRO'] = $datos_cab[19];
                        $nuevo['ENCABEZADO']['FINICIO'] = $datos_cab[11];
                        $nuevo['ENCABEZADO']['FFIN'] = $datos_cab[12];
                        $nuevo['ENCABEZADO']['NCARRERA'] = $datos_cab[22];
                        $nuevo['ENCABEZADO']['NUA'] = $datos_cab[21];
			$nuevo['ENCABEZADO']['DOCENTES'] = "-";
			if (!empty($datos_doc)){
				$nuevo['ENCABEZADO']['DOCENTES'] = $datos_doc[0][0];
			}

			$nuevo['ENCABEZADO']['OBS'] = "-";
			if (!empty($datos_cab) && !empty($datos_cab[18])){
				$nuevo['ENCABEZADO']['OBS'] = $datos_cab[18];
			}
		}

		if (!empty($datos)){
			$folio = false;
			foreach($datos as $id => $dato) {
				if ($folio <> $dato[23]){
					$folio = $dato[23];
				}

				$nuevo['CUERPO'][$folio][$id]['CARRERA'] = $dato[21];
				$nuevo['CUERPO'][$folio][$id]['RENGLON'] = $dato[24];
				$nuevo['CUERPO'][$folio][$id]['LEGAJO'] = $dato[22];
				$nuevo['CUERPO'][$folio][$id]['APE_NOM'] = $dato[33].", ".$dato[34];
				$nuevo['CUERPO'][$folio][$id]['FECHA'] = datos_comunes_actas::get_fecha($dato[26]);
				$nuevo['CUERPO'][$folio][$id]['NOTA_NUM'] = $dato[28];
				$nuevo['CUERPO'][$folio][$id]['CONDICION'] = $dato[25];
				$nuevo['CUERPO'][$folio][$id]['RESULTADO'] = datos_comunes_actas::get_resultado($dato[27]);

				if ($dato[36] != "") {
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '(' . $dato[36] . ')';
				} else {
					$nuevo['CUERPO'][$folio][$id]['NOTA_LETRAS'] = '&nbsp;';
				}
			}
		}
		return $nuevo;
	}
        
        /**
	 * parametros: acta, version, copia
	 * cache: no
	 * filas: n
	 */
	function actualizar_version_impresa($parametros)
	{
		$sql = "UPDATE 	sga_actas_examen 
				SET 	version_impresa = {$parametros['version']}, nro_ultima_copia = ({$parametros['copia']}+1)
				WHERE 	acta = {$parametros['acta']}";
                
                                
                
		return kernel::db()->ejecutar($sql);
		
	}

        /**
	 * parametros: comision
	 * cache: no
	 * filas: n
	 */
	function alum_inscriptos_comision($parametros)
	{
		$sql = "execute procedure sp_AluInscCom(" . $parametros["comision"] .")";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
	
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['LEGAJO'] = $dato[12];
			$nuevo[$id]['ALUMNO'] = $dato[13];
			$nuevo[$id]['EMAIL'] = $dato[18];   // Personalizacion UNL
			$nuevo[$id]['CALIDAD'] = $dato[8];
			$nuevo[$id]['ESTADO'] = substr($dato[9],0,1)=='P'?'Pendiente':'Aceptado';
			$nuevo[$id]['CARRERA_COD'] = $dato[10];
			$nuevo[$id]['CARRERA'] = $dato[15];
			$nuevo[$id]['MATERIA_COD'] = $dato[1];
			$nuevo[$id]['MATERIA'] = $dato[2];
			$nuevo[$id]['SEDE_COD'] = $dato[16];
			$nuevo[$id]['SEDE'] = $dato[17];
			$nuevo[$id]['COMISION'] = $dato[6];
			$nuevo[$id]['CATEDRA'] = $dato[7];
			$nuevo[$id]['ANIO'] = $dato[3];
			$nuevo[$id]['PER_LEC'] = $dato[4];
			$nuevo[$id]['SUBCOMISION'] = '';
			$nuevo[$id]['SUBCOMISION_NOMBRE'] = '';
}
		return $nuevo;
	}
        
	/**
	 * parametros: _ua, materia, anio_academico, turno_examen, mesa_examen, llamado
	 * cache: no
	 * filas: n
	 */
	function alum_inscriptos_examen($parametros)
	{
		$sql = "execute procedure sp_AluInscExa({$parametros["_ua"]},
												{$parametros["materia"]},
												{$parametros["anio_academico"]},
												{$parametros["turno_examen"]},
												{$parametros["mesa_examen"]},
												{$parametros["llamado"]})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['MATERIA'] = $dato[1];
			$nuevo[$id]['MATERIA_NOMBRE'] = $dato[2];
			$nuevo[$id]['ANIO_ACADEMICO'] = $dato[3];
			$nuevo[$id]['TURNO_EXAMEN'] = $dato[4];
			$nuevo[$id]['MESA_EXAMEN'] = $dato[5];
			$nuevo[$id]['LLAMADO'] = $dato[6];
			$nuevo[$id]['MOMENTO'] = $dato[7];
			$nuevo[$id]['EDIFICIO'] = $dato[8];
			$nuevo[$id]['EDIFICIO_NOMBRE'] = $dato[9];
			$nuevo[$id]['AULA'] = $dato[10];
			$nuevo[$id]['AULA_NOMBRE'] = $dato[11];
			$nuevo[$id]['CARRERA'] = $dato[12];
			$nuevo[$id]['CARRERA_NOMBRE'] = $dato[13];
			$nuevo[$id]['LEGAJO'] = $dato[14];
			$nuevo[$id]['APELLIDO_NOMBRE'] = $dato[15];
			$nuevo[$id]['EMAIL'] = $dato[23]; // Personalizacion UNL
			$nuevo[$id]['TIPO_INSCRIPCION'] = $dato[16];
			$nuevo[$id]['ESTADO'] = substr($dato[17],0,1)=='P'?'Pendiente':'Aceptado';
			$nuevo[$id]['FECHA_INSCRIPCION'] = $dato[22];
			$nuevo[$id]['FECHA_INSCRIPCION_ORD'] = $dato[21];
}
		return $nuevo;
	}        
}
?>
