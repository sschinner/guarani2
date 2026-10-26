--Este procedimiento verifica que exista el periodo lectivo,si este no existe lo crea
--Se asume que el  anio lectivo ya debe existir.
--Se asume que el periodo lectivo generico '2do. Cuatrimestre' existe.

--DROP PROCEDURE "dba".sp820_verif_crea_per_lect;

CREATE PROCEDURE "dba".sp820_verif_crea_per_lect (
		pUA 		LIKE sga_alumnos.unidad_academica, 
		pPerLect 		LIKE sga_periodos_lect.periodo_lectivo,  
		pAnioAcad 	LIKE sga_periodos_lect.anio_academico, 
		pFechaInicio 	LIKE sga_periodos_lect.fecha_inicio,
		pFechaFin 	LIKE sga_periodos_lect.fecha_fin,
		pFechaInicioInsc	LIKE sga_fec_insc_cur.fecha_inicio,
		pFechaFinInsc	LIKE sga_fec_insc_cur.fecha_fin,
		porden		LIKE sga_fec_insc_cur.orden)

	RETURNING char(1), char(1), char(1), char(1);

-- vars para la respuesta

DEFINE existe           char(1);
DEFINE inserta          char(1);
DEFINE existeinsc           char(1);
DEFINE insertainsc          char(1);

-- vars para el manejo de excepciones
DEFINE SQLErr          integer;
DEFINE ISAMError       integer;
DEFINE errorInfo       varchar(76);

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION  SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN


-- OK
LET existe = 'S'; -- existe el periodo lectivo
LET inserta = 'N'; -- no inserta
LET existeinsc = 'S'; -- existe el periodo de inscripcion
LET insertainsc = 'N'; -- no inserta

IF NOT EXISTS (SELECT "*"
     FROM sga_periodos_lect
	WHERE periodo_lectivo = pPerLect
	and anio_academico = pAnioAcad) THEN
     -- El periodo lectivo no existe.
	insert into sga_periodos_lect (ANIO_ACADEMICO, PERIODO_LECTIVO, TIPO_DE_PERIODO, FECHA_INICIO, FECHA_FIN, TOPE_INSCRIPCIONES, FECHA_INACTIVACION, ORDEN_EN_EL_ANIO, ORDEN_EN_SU_TIPO) values (pAnioAcad, pPerLect, 'Cuatrimestral', pFechaInicio, pFechaFin, pFechaFin, pFechaFin, 1, 1);

	LET existe = 'N';
      	LET inserta = 'S';
END IF;

IF NOT EXISTS (SELECT "*"
     FROM sga_fec_insc_cur
	WHERE periodo_lectivo = pPerLect
	and anio_academico = pAnioAcad
                --and fecha_inicio = pFechaInicioInsc
	and orden = porden)
    THEN
      -- El periodo de inscripcion no existe.
	
   	insert into sga_fec_insc_cur (ANIO_ACADEMICO, PERIODO_LECTIVO, ORDEN, NOMBRE,  FECHA_INICIO, FECHA_FIN, FECHA_TOPE_BAJAS) values (pAnioAcad, pPerLect, porden,  'periodo integracion', pFechaInicioInsc, pFechaFinInsc, pFechaFinInsc);

	LET existeinsc = 'N';
      	LET insertainsc = 'S';
END IF;


  RETURN existe, inserta, existeinsc, insertainsc;
END;
END PROCEDURE;


