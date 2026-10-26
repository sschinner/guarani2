-- Controla si al Alumno le faltan como máximo la cantidad de materias establecidas en el parámetro '820_cant_de_mat_turno_esp', para egresar.



CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;


-- El control esta asociado al Punto de Control Nro 10 (Alumno - Llamado Mesa de Examen)

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_CanMatTurEs", "s,s,s,s,n,s,s,n,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820004, "ctr820_CanMatTurEs", "Falten a lo sumo N Materias para egresar.", "Controla que al Alumno le falten a lo sumo N materias para egresar.", null);

insert into par_cont_x_punto (punto_de_control, control) values (10, 820004);

execute procedure sp_confcont_cont (10, 820004);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_canmattures') THEN
		DROP PROCEDURE ctr820_canmattures;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- **************************************************************************
-- Control: ctr820_CanMatTurEs
-- Version 1.3
--
--  Controla si al Alumno le faltan como máximo la cantidad de materias establecidas en el parámetro '820_cant_de_mat_turno_esp', para egresar.
--       devuelve:  1 - si esta OK         No Tiene 
--                 -1 - en otro caso       Tiene 
--
-- ***************************************************************************

CREATE PROCEDURE "dba".ctr820_CanMatTurEs(
	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
	pCarrera		LIKE sga_alumnos.carrera,
	pLegajo 		LIKE sga_alumnos.legajo,
	pMateria 		LIKE sga_mesas_examen.materia,
	pAnioAcademico 	LIKE sga_mesas_examen.anio_academico,
	pTurnoExamen	LIKE sga_mesas_examen.turno_examen,
	pMesaExamen 	LIKE sga_mesas_examen.mesa_examen,
	pLlamado 	LIKE sga_insc_examen.llamado,
	pTipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion)
	RETURNING smallint, varchar(255); 


-- vars para la respuesta
DEFINE iStatus 	smallint;	-- status
DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

-- var's para el manejo de excepciones
DEFINE sql_err, isam_err 	integer;
DEFINE error_info 	varchar(76);
DEFINE vcUserError	varchar(10);

DEFINE	cnt_mat integer;
DEFINE	cnt_mat_plan integer;
DEFINE	cnt_mat_apro integer;
DEFINE	cnt_mat_apro_gen integer;
DEFINE   vmateria Varchar (5);
DEFINE   vplan Varchar (5);
DEFINE   vorientacion Varchar (5);
DEFINE   vtitulo Varchar (5);
DEFINE   vresultado char (1);
DEFINE icreditos integer;
DEFINE tipo_turno char (1);

 -- blk de excepciones
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
   LET iStatus = -1 ;
   LET vcMsg = '800321' || sql_err ||  ' - '  || error_info ; 	
   RETURN iStatus, vcMsg; 
 END EXCEPTION;        

BEGIN
   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1 ;
   LET vcMsg = '800320' ;

   --- inicializo como turno normal
   LET cnt_mat = 0;
   LET cnt_mat_plan = 0;
   LET cnt_mat_apro = 0;
   LET cnt_mat_apro_gen = 0;
   LET tipo_turno = 'N';
   LET vresultado = 'R';
   LET icreditos = 0;

SELECT tipo_de_turno Into tipo_turno FROM sga_turnos_examen WHERE  anio_academico = pAnioAcademico AND turno_examen = pTurnoExamen;

IF tipo_turno = 'E' THEN

	SELECT valor*1 Into cnt_mat FROM sga_param_sistema WHERE parametro = '820_cant_de_mat_turno_esp' AND unidad_academica = pUnidadAcademica;

	IF cnt_mat > 0 THEN	

		-- Cantidad de materias Obligatorias del Plan----- SE AGREGA EL ULTIMO AND SOLICITADO POR EL TICKET #6253
		SELECT COUNT(*) Into cnt_mat_plan
			FROM sga_alumnos a 
					Join sga_planes p
						Join sga_atrib_mat_plan m
						on p.carrera = m.carrera AND p.plan = m.plan AND p.unidad_academica = m.unidad_academica AND p.version_actual = m.version
					on a.carrera = p.carrera AND a.plan = p.plan AND a.unidad_academica = p.unidad_academica
					
			WHERE a.unidad_academica = pUnidadAcademica
				AND a.carrera = pCarrera
				AND a.legajo = pLegajo
				AND m.obligatoria = 'S'
				AND m.materia not in ("Q0112","60034","70013","30030","60034","I0094","Q0012","60015","C0015","M0015");

		-- Cantidad de materias Comunes Obligatorias Aprobadas. En vw_hist_academica, no figuran las genericas.  -- SE AGREGA EL ULTIMO AND SOLICITADO POR EL TICKET #6253
		SELECT COUNT(*) Into cnt_mat_apro
			FROM vw_hist_academica vw
					join sga_atrib_mat_plan m
					on vw.carrera = m.carrera AND vw.plan = m.plan AND vw.version = m.version AND vw.materia = m.materia
		   WHERE  vw.unidad_academica = pUnidadAcademica
			AND vw.carrera = pcarrera 
			AND vw.legajo  =  pLegajo
			AND vw.resultado = 'A'
			AND m.obligatoria = 'S'
			AND vw.materia not in ("Q0112","60034","70013","30030","60034","I0094","Q0012","60015","C0015","M0015");

		-- Cantidad de materias Genéricas Obligatorias Aprobadas
		FOREACH SELECT m.materia, a.plan Into vmateria, vplan
			FROM sga_alumnos a 
					Join sga_planes p
						Join sga_atrib_mat_plan m
						on p.carrera = m.carrera
							AND p.plan = m.plan
							AND p.unidad_academica = m.unidad_academica
							AND p.version_actual = m.version
					on a.carrera = p.carrera
						AND a.plan = p.plan
						AND a.unidad_academica = p.unidad_academica
					
			WHERE a.unidad_academica = pUnidadAcademica
				AND a.carrera = pCarrera
				AND a.legajo = pLegajo
				AND m.obligatoria = 'S'
				AND m.tipo_materia = 'G'

			IF EXISTS(SELECT o.orientacion, o.titulo
				FROM sga_alumnos a
					Join sga_orient_alumno o
					on a.unidad_academica = o.unidad_academica
						AND a.carrera = o.carrera
						AND a.plan = o.plan
						AND a.legajo = o.legajo) then
				FOREACH SELECT o.orientacion, o.titulo Into vorientacion, vtitulo
					FROM sga_alumnos a
						Join sga_orient_alumno o
						on a.unidad_academica = o.unidad_academica
							AND a.carrera = o.carrera
							AND a.plan = o.plan
							AND a.legajo = o.legajo
					WHERE a.unidad_academica = pUnidadAcademica
						AND a.carrera = pCarrera
						AND a.legajo = pLegajo
						AND a.plan = vplan

					execute procedure sp_resultGenerica (pUnidadAcademica, pCarrera, pLegajo,
						vTitulo, vOrientacion, vMateria) Into vresultado, icreditos;
					IF  vresultado = 'A' THEN 
						LET cnt_mat_apro	= cnt_mat_apro + 1;
					END IF;
				END FOREACH;
			ELSE

				execute procedure sp_resultGenerica (pUnidadAcademica, pCarrera, pLegajo,
					null, null, vMateria) Into vresultado, icreditos;
				IF  vresultado = 'A' THEN 
					LET cnt_mat_apro	= cnt_mat_apro + 1;
				END IF;
			END IF;
		END FOREACH;

		IF (cnt_mat_plan - cnt_mat_apro) > cnt_mat  THEN

			-- Error
			LET vcUserError  = '82001002' ;
			LET iStatus 	  = -1; 
			LET vcMsg 	  =  vcUserError || ',' || cnt_mat;
			RETURN iStatus, vcMsg; 
		END IF;

	END IF;

END IF;

RETURN iStatus, vcMsg; 
END;
END PROCEDURE;

-- execute PROCEDURE "dba".ctr820_CanMatTurEs('FIQ', '00010', '30292239-1', 'C0014', '2012',	'Especial Junio 2012',	'Tesina.CLTA', 1,'R');

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_CanMatTurEs
-- *****************************************************************************
revoke execute on "dba".ctr820_CanMatTurEs from public;
grant execute on "dba".ctr820_CanMatTurEs to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_CanMatTurEs to internet; -- Rol de usuario de Internet