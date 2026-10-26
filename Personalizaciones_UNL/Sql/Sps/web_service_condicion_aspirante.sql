CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_condicion_aspirante') THEN
		DROP PROCEDURE web_service_condicion_aspirante;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **********************************************************************
-- Retorna la condicion en que se encuentra un aspirante a carrera
-- Condiciones:
--	* El aspirante no se encuentra en la carrera
--	* El aspirante no puede cursar (AC, RR o RF)
--	* Alumno puede cursar (IC)
--	* Alumno puede cursar y rendir (IL o IC con requisito supletorio)
-- **********************************************************************
create procedure "dba".web_service_condicion_aspirante(ptipo_documento	LIKE dba.sga_personas.tipo_documento,
				pnro_documento	LIKE dba.sga_personas.nro_documento,
				pcarrera	LIKE dba.sga_carreras.carrera)

returning integer, varchar(128); -- condicion del aspirante

   -- Variables locales del procedimiento
   DEFINE vsituacion_aspirante LIKE sga_carrera_aspira.situacion_asp;
   DEFINE vnro_inscripcion LIKE sga_carrera_aspira.nro_inscripcion;

   --Variables para el manejo de excepciones
   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN

   LET vsituacion_aspirante= NULL;

	-- Verifico si el aspirante tiene alguna inscripcion en la carrera
	IF EXISTS (SELECT *
			FROM 	sga_carrera_aspira as ca
			JOIN	sga_personas as p ON ca.nro_inscripcion = p.nro_inscripcion
			WHERE	p.tipo_documento = ptipo_documento
				AND p.nro_documento = pnro_documento
				AND carrera = pcarrera) THEN

		-- Obtengo la condicion en la que se encuentra el aspirante en su ultima inscripcion
		SELECT	ca.situacion_asp, ca.nro_inscripcion
		INTO	vsituacion_aspirante, vnro_inscripcion
		FROM 	sga_carrera_aspira as ca
			JOIN sga_personas as p ON ca.nro_inscripcion = p.nro_inscripcion
		WHERE	p.tipo_documento = ptipo_documento
			AND p.nro_documento = pnro_documento
			AND carrera = pcarrera
		AND	ca.fecha_inscripcion = (SELECT MAX(ca.fecha_inscripcion) FROM sga_carrera_aspira as ca
							JOIN	sga_personas as p ON ca.nro_inscripcion = p.nro_inscripcion
							WHERE	p.tipo_documento = ptipo_documento
							AND p.nro_documento = pnro_documento
							AND carrera = pcarrera);

		-- Si la condicion es AC
		IF (vsituacion_aspirante = 'AC') THEN
			return 2, "Según requisitos de ingreso: la persona no puede realizar actividades académicas" WITH RESUME;
		END IF;

		-- Si la condicion es RR o RF
		IF (vsituacion_aspirante = 'RR' OR vsituacion_aspirante = 'RF') THEN
			return 5, "Alumno rechazado en la carrera" WITH RESUME;
		END IF;

		-- Si la condicion es IL
		IF (vsituacion_aspirante = 'IL') THEN
			return 4, "Según requisitos de ingreso: Alumno podría cursar y rendir" WITH RESUME;
		END IF;

		-- Si la condicion es IC
		IF (vsituacion_aspirante = 'IC') THEN
			--Verifico si cumplio los requisitos obligatorios 1 y 2
			IF EXISTS (SELECT	DISTINCT nro_inscripcion, COUNT(*)
					FROM	sga_req_cumplidos
					WHERE	nro_inscripcion = vnro_inscripcion
						AND requisito IN ('UNL01','UNL8')
						AND carrera = pcarrera
						AND fecha_presentacion IS NOT NULL
					GROUP BY nro_inscripcion
					HAVING COUNT(*) = 2) THEN
				-- Si tiene supletorio de titulo secundario
				IF EXISTS(SELECT	*
						FROM	sga_req_cumplidos
						WHERE	nro_inscripcion = vnro_inscripcion
							AND requisito IN ('UNL03', 'UNL07', 'UNL15','UNL16','UNL17','UNL18','UNL19')
							AND carrera = pcarrera
							AND fecha_presentacion IS NOT NULL) THEN
					return 4, "Según requisitos de ingreso: la persona podría cursar y rendir" WITH RESUME;
				ELSE
					return 3, "Según requisitos de ingreso: la persona podría cursar" WITH RESUME;
				END IF;
			ELSE
				return 2, "Según requisitos de ingreso: la persona no puede realizar actividades académicas" WITH RESUME;
			END IF;

		END IF;

	ELSE
		return 1, "La persona no se encuentra inscripta en la carrera" WITH RESUME;
	END IF;

END;

END PROCEDURE;

-- CASOS DE PRUEBA EN FICH:
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '31862148', '0798'); --La persona no se encuentra inscripta en la carrera
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '31115338', '02'); 	--RR: Alumno rechazado en la carrera
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '40318034', '02'); 	--AC: El aspirante no puede cursar
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '31862148', '03'); 	--IL: Alumno puede cursar y rendir
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '39050157', '03'); 	--IC con supletorio: Alumno puede cursar y rendir
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '41490209', '03'); 	--IC sin supletorio: Alumno puede cursar
-- EXECUTE PROCEDURE web_service_condicion_aspirante ('0', '42070292', '01'); 	--IC sin CUIL o DNI: La persona no puede realizar actividades académicas


-- *****************************************************************************
-- Permisos del procedimiento "dba".web_service_condicion_aspirante
-- *****************************************************************************
revoke execute on "dba".web_service_condicion_aspirante from public;
grant execute on "dba".web_service_condicion_aspirante to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_condicion_aspirante to internet; -- Rol de usuario de Internet
