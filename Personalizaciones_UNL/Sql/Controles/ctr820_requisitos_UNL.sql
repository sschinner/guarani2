-- *******************************************************************************
-- Controla si el Alumno tiene los requisitos Obligatorios que UNL exige para poder realizar actividad académica, posterior al 30/11
-- El control esta asociado al Punto de Control Nro 24 (Requisitos Obligatorios y No Obligatorios de la UA y la Carrera)
-- Este control podr{ia estar Mensaje o Advertencia. si eventualmente
-- *******************************************************************************
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_requi_unl", "s,s,s");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820007, "ctr820_requi_unl", "Controla req. obligatorios UNL", "Controla req. obligatorios UNL", null);
insert into par_cont_x_punto (punto_de_control, control) values (24, 820007);
execute procedure sp_confcont_cont (24, 820007);	

END
END PROCEDURE;


EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_requi_unl') THEN
		DROP PROCEDURE ctr820_requi_unl;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.5.2
--
-- Procedure ctr820_requi_unl
-- 
-- Controla que los requisitos obligatorios pero no para generar legajo de UNL
-- esten presentados y en la fecha correspondiente.
-- **************************************************************************

CREATE PROCEDURE "dba".ctr820_requi_unl( pUnidadAcademica  LIKE sga_personas.unidad_academica,
					pCarrera          LIKE sga_carreras.carrera,
					pNroInscripcion   LIKE sga_personas.nro_inscripcion)
					
RETURNING smallint,     -- status
          varchar(255); -- <mensaje, parametros>

/*
devuelve:  1 (OK) / -1 (en otro caso)
           msg
*/

   -- vars para la respuesta
   DEFINE iStatus            smallint;      -- status
   DEFINE vcMsg              varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err, isam_err  integer;
   DEFINE error_info         varchar(76);
   DEFINE vcUserError        varchar(10);

   -- var's para obtener las fechas de vencimiento del período de inscripción
   DEFINE ld_f_cie_req_pi_le LIKE sga_periodo_insc.fec_cierre_req_leg; 
   DEFINE ld_fec_cier_req_pi LIKE sga_periodo_insc.fecha_cierre_req; 
   DEFINE li_anio_periodo_insc	LIKE sga_anio_academico.anio_academico;
   DEFINE li_anio_academico LIKE sga_anio_academico.anio_academico;
   DEFINE li_grupo_carrera LIKE sga_carreras_grupo.grupo_carrera;

DEFINE dFHasta DATE;

   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_requi_unl,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   LET iStatus = 1 ;
   LET vcMsg = '800320' ;

   -- Obtener el año del período de inscripción del aspirante a carrera.
   SELECT	insc.anio_academico
   INTO		li_anio_periodo_insc
   FROM		sga_carrera_aspira casp,
		sga_periodo_insc insc
   WHERE	casp.unidad_academica = pUnidadAcademica
   AND		casp.carrera = pCarrera
   AND		casp.nro_inscripcion = pNroInscripcion

   AND		casp.periodo_inscripcio = insc.periodo_inscripcio
   AND casp.situacion_asp in ('IL', 'IC');

   -- Verifico que la carrera del aspirante este dentro del grupo_carrera 00001
   SELECT	cgrupo.grupo_carrera
   INTO		li_grupo_carrera
   FROM		sga_carreras_grupo cgrupo
   WHERE	cgrupo.carrera = pCarrera
   AND		cgrupo.grupo_carrera = '00001';


SELECT anio_academico
INTO li_anio_academico
FROM sga_anio_academico
WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;

LET dFHasta = stringToDate( '30-11-'||li_anio_periodo_insc, '%d-%m-%Y');

IF  (li_grupo_carrera == '00001') THEN

	IF  (li_anio_periodo_insc >= 2006) AND (li_anio_periodo_insc <= 2015) THEN

	   ---------------------------------------------------------------------------------------------------------
	   -- Controlar si estan todos los requisitos obligatorios de UNL, para realizar actividad académica, del alumno presentados.
	   -- Esquema anterior al 2016, año en que se empieza a utilizar el esquema de Bienestar
	   ---------------------------------------------------------------------------------------------------------

		IF EXISTS (
			SELECT *
			FROM sga_req_cumplidos
			WHERE requisito IN (
						SELECT requisito 
						FROM u820_req_no_oblig
						WHERE TRIM(carrera)||TRIM(requisito) 
								not in (SELECT TRIM(carrera)||TRIM(requisito) 									FROM sga_req_cumplidos
									WHERE carrera = u820_req_no_oblig.carrera
									and requisito = u820_req_no_oblig.requisito
									and nro_inscripcion = pNroInscripcion
									and carrera = pCarrera
									and fecha_presentacion is not null)
						AND carrera = pCarrera
						AND TODAY >= MDY(u820_req_no_oblig.mes, u820_req_no_oblig.dia, li_anio_periodo_insc  + u820_req_no_oblig.delta_anio) -- requisitos a controlar para los que ya pasó la fecha de vencimiento
					) -- in
			AND nro_inscripcion = pNroInscripcion
			AND carrera = pCarrera
			AND (f_prorroga_hasta is null OR f_prorroga_hasta < TODAY) -- el alumno tiene algún requisito no prorrogado
			) THEN
	      
	      	-- Error hay Requisitos Obligatorios, para realizar actividad académica, que no fueron presentados
		      LET iStatus = -1 ;
		      LET vcMsg = '800607';	

		END IF;
		
	ELIF (li_anio_periodo_insc >= 2016) THEN
		-- Control Año 2016 de Requisitos de Ingreso
		-- Control de presentación de requisito académico para no ser rechazado, por ctrl. de cierre de período de inscripción, en fecha 30/04
		IF TODAY > dFHasta THEN
			IF NOT EXISTS (
				SELECT * FROM sga_req_cumplidos
				WHERE requisito IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02', 'POS08', 'UNL20', 'UNL21', 'UNL22')
				AND nro_inscripcion = pNroInscripcion
				AND carrera = pCarrera
				AND (fecha_presentacion is not null 
					or  exceptuado = 'S'
					or (f_prorroga_hasta is not NULL and f_prorroga_hasta >= TODAY))

				) THEN
				      	-- Error hay Requisitos Obligatorios, para realizar actividad académica, que no fueron presentados
				      LET iStatus = -1 ;
				      LET vcMsg = '800607';
			END IF;		
		END IF;

	END IF;

END IF;
RETURN iStatus, vcMsg ;

END;
END PROCEDURE;
-- ********************** Fin del procedure ctr820_requi_unl **********************
{Casos de prueba
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-1807'); -- Ingreso 2008 debe ambos
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-1497'); -- Ingreso 2008 debe profilaxis
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2140'); -- Ingreso 2008 debe titulo
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2065'); -- Ingreso 2008 no debe nada

execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2401'); -- Ingreso 2009 debe ambos
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2440'); -- Ingreso 2009 debe profilaxis
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2618'); -- Ingreso 2009 debe titulo
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2431'); -- Ingreso 2009 no debe nada

execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-3061'); -- Ingreso 2010 debe ambos
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2424'); -- Ingreso 2010 debe profilaxis
execute procedure ctr820_requi_unl( 'FCV', '01', 'FCV-2788'); -- Ingreso 2010 no debe nada

execute procedure ctr820_requi_unl( 'FICH', '12', 'FICH-10876');
}
