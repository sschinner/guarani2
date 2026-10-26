-- U820 ***********************************************************************************************************************
-- -- Controla si el Alumno tiene una cursada de la correlativa en la misma catedra.
-- U820 ***********************************************************************************************************************

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_cursvertica", "s,s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820025, "ctr820_cursvertica", "Controla Cursado Vertical", "Controla Cursado Vertical", null);
insert into par_cont_x_punto (punto_de_control, control) values (5, 820025);
execute procedure sp_confcont_cont (5, 820025);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_cursvertica') THEN
		DROP PROCEDURE ctr820_cursvertica;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".ctr820_cursvertica ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pComision 		LIKE sga_comisiones.comision)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  --  controla el Alumno Cursa Vertical.
  --    devuelve:  1 - si esta OK            no cursa Vertical
  --         -1 - en otro caso       cursa Vertical
  

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);


   -- variables locales

DEFINE vcNro_inscripcion like sga_alumnos.nro_inscripcion;
DEFINE vcCarrera like sga_comisiones.carrera;
DEFINE vcNombre like sga_comisiones.nombre;
DEFINE vcTurno like sga_comisiones.turno;
DEFINE vcMateria like sga_comisiones.materia;
DEFINE vcMateriaCorrelativa  like sga_comisiones.materia;
DEFINE vc_legajo like sga_docentes_com.legajo;
DEFINE vcRtn             char(1);
DEFINE vi_anioacademico char(4);
DEFINE vc_esingresante char(1);

-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_cursvertica' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET vcNro_inscripcion = NULL;
   LET vcCarrera = NULL;
   LET vcNombre = NULL;
   LET vcTurno = NULL;
   LET vcMateria = NULL;
   LET vc_legajo = NULL;
   LET vcMateriaCorrelativa = NULL;
   LET vcRtn = NULL;
   LET vi_anioacademico = NULL;
   LET vc_esingresante = NULL;

-- Obtengo los datos de la coisión de inscripción
SELECT com.carrera, com.nombre, com.turno, com.materia, com.anio_academico Into vcCarrera, vcNombre, vcTurno, vcMateria, vi_anioacademico 
   FROM sga_comisiones com
   WHERE com.comision = pComision;

-- Control de materias a controlar
IF vcMateria in ('A0322', 'A0307', 'A0317', 'A0313', 'A0321', 'A0328', 'D0305', 'C0303', 'A0329', 'A0326', 'A0310', 'A0308', 'A0324', 'D0311', 'D0316', 'A0318') THEN

	-- Corrección de materia correlativa a controlar:
	IF vcMateria =  'A0329' THEN LET vcMateriaCorrelativa = 'A0322';
		ELIF vcMateria = 'A0326' THEN LET vcMateriaCorrelativa = 'A0320';
		ELIF vcMateria = 'A0310' THEN LET vcMateriaCorrelativa = 'C0303';
		ELIF vcMateria = 'A0308' THEN LET vcMateriaCorrelativa = 'A0303';
		ELIF vcMateria = 'A0324' THEN LET vcMateriaCorrelativa = 'A0318';
		ELIF vcMateria = 'D0311' THEN LET vcMateriaCorrelativa = 'D0305';
		ELIF vcMateria = 'D0316' THEN LET vcMateriaCorrelativa = 'D0311';
		ELIF vcMateria = 'A0318' THEN LET vcMateriaCorrelativa = 'A0309';


		-- Regularidad de la misma materia
		ELIF vcMateria = 'A0322' THEN LET vcMateriaCorrelativa = 'A0322';
		ELIF vcMateria = 'A0307' THEN LET vcMateriaCorrelativa = 'A0307';
		ELIF vcMateria = 'A0317' THEN LET vcMateriaCorrelativa = 'A0317';
		ELIF vcMateria = 'A0313' THEN LET vcMateriaCorrelativa = 'A0313';
		ELIF vcMateria = 'A0321' THEN LET vcMateriaCorrelativa = 'A0321';
		ELIF vcMateria = 'A0328' THEN LET vcMateriaCorrelativa = 'A0328';
		ELIF vcMateria = 'D0305' THEN LET vcMateriaCorrelativa = 'D0305';
		ELIF vcMateria = 'C0303' THEN LET vcMateriaCorrelativa = 'C0303';

		ELSE LET vcMateriaCorrelativa = vcMateria ; 
	END IF;

	-- Verificar que cumplan con el turno
	IF vcMateria in ( 'A0310') THEN
		-- Controla de la materia correlativa, el turno con el que lo curso (Dependiendo de la vigencia la regularidad en ella, manda o no a comisión a designar) 
		EXECUTE PROCEDURE "dba".sp820_ctr_turno (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
	END IF;


	-- Verificar que cumplan con la cátedra
	IF vcMateria in ('A0329', 'A0326', 'A0308', 'A0324', 'D0311', 'D0316', 'A0318') THEN
		EXECUTE PROCEDURE "dba".sp820_ctr_catedra (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
			
			IF iStatus = 1 THEN		
				LET iStatus  = 1;
				LET vcMsg = 'OK';

			ELSE
				LET iStatus = -1;
				LET vcMsg  =  '82012001';
			END IF;

	END IF;


	-- Verificar regularidad de la misma materia: BLANCO
	-- Eligen Cátedra; Cad Libres y Recursantes, controla regularidad la misma materia de inscripción
	IF vcMateria in ('C0303', 'A0322', 'A0307', 'A0317', 'A0313', 'A0321', 'A0328', 'D0305') THEN
		-- Controla de la materia actual si es recursante (Si es Recursante manda a comisión a designar)
		EXECUTE PROCEDURE "dba".sp820_ctr_recur (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
			IF iStatus = 1 THEN -- si es recursante, se controla que la comisión sea CaD (no tenga docente asociado o turno definido)
				IF EXISTS (SELECT *
					   FROM sga_comisiones com
						join sga_docentes_com doc

							on com.comision = doc.comision

					   WHERE com.comision = pComision

					and doc.responsabilidad = 1) THEN

					LET iStatus  = -1;
					LET vcMsg  =  '82012001';

				ELSE
					LET iStatus  = 1;
					LET vcMsg = 'OK';

				END IF;

			ELSE -- no es recursante e intenta inscribirse a una CaD
				IF NOT EXISTS (SELECT *
					   FROM sga_comisiones com
							join sga_docentes_com doc

								on com.comision = doc.comision

						   WHERE com.comision = pComision

							and doc.responsabilidad = 1)  THEN
					LET iStatus  = -1;
					LET vcMsg  =  '82012001';
				ELSE
					LET iStatus  = 1;
					LET vcMsg = 'OK';
				END IF;
			END IF;

	END IF;


END IF;

RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_CursVertical ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_cursvertica
-- *****************************************************************************
revoke execute on "dba".ctr820_cursvertica from public;
grant execute on "dba".ctr820_cursvertica to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_cursvertica to internet; -- Rol de usuario de Internet

{
BEGIN;

UPDATE sga_insc_cursadas
SET estado = 'P'
WHERE nro_transaccion IN (SELECT ic.nro_transaccion
FROM sga_insc_cursadas as ic
JOIN sga_comisiones as c ON ic.comision = c.comision
WHERE ic.estado = 'A'
AND ic.carrera = '1'
AND c.anio_academico = '2018'
AND c.periodo_lectivo IN ('1° cuatrimestre')
AND materia = 'A0322')

-- ROLLBACK;
-- COMMIT;

select * from sysprocedures where procname like '%ctr820_cursvertic%'

-- Casos de prueba:
-- select * from sga_comisiones where anio_academico = 2022 and materia = 'D0311' and periodo_lectivo = 'Anual';

-- select  per.apellido, dc.responsabilidad, com.* from sga_comisiones  com
join sga_docentes_com dc on com.comision = dc.comision
join sga_docentes doc on doc.legajo = dc.legajo
join sga_personas per on per.nro_inscripcion = doc.nro_inscripcion
where anio_academico = 2019 and materia = 'C0301' and periodo_lectivo = '1° cuatrimestre' and dc.responsabilidad = 1;

select * from sga_cursadas where comision = 8518; -- '40278929-7'

select * from sga_cursadas where legajo = '43283254-6';
select * from sga_comisiones where comision = 8645;
select * from sga_docentes_com where comision = 8645;
select * from log_comisiones where comision = 8262;
select * from sga_insc_cursadas where legajo = '41403286-6';

select per.apellido from sga_docentes doc
	join sga_personas per on  doc.nro_inscripcion = per.nro_inscripcion
where legajo = '10473'

-- A0326
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '35251134-2',  10253); -- Bellot NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '35251134-2',  10393); -- Rodriguez SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '35251134-2',  10284); -- CaD NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42601674-9',  10253); -- Bellot SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42601674-9',  10393); -- Rodriguez NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42601674-9',  10284); -- CaD NO


select * from sga_cursadas where legajo = '40450495-8' order by materia; 

-- D0305

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44104452-5',  10398); -- NO ALBRECHT
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44104452-5',  10439); -- SI Cad
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44104452-5',  10444); --  NO GORODISCHER

-- D0311
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43165999-4',  10400); -- ALBRECHT SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43165999-4',  10442); -- GORODISCHER NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43165999-4',  10432); -- CaD NO


-- A0309
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 9990 ); -- SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 10206); -- SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 10213); -- SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 10027); -- NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38897291-9', 9990 ); -- NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38897291-9', 10206); -- NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38897291-9', 10213); -- NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38897291-9', 10027); -- SI


-- C0302
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 10209); -- Step - TM - SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43714649-5', 10211); -- Step - TT - NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44427112-7', 10209); -- Step - TM - NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44427112-7', 10211); -- Step - TT - SI

-- A0302
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44556509-2', 9988); -- TM - SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '44556509-2', 9989); -- TT - NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41696611-5', 10022); -- CaD - SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41696611-5', 9988); -- NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41696611-5', 9989); -- NO

----------------------------------------------------------------------------------------------------------------------------------------------------
EXECUTE PROCEDURE "dba".sp820_ctr_recur ('FADU', '1', '43283254-6', 8845, 'A0309', 0) 

SELECT *
					   FROM sga_comisiones com
							 join sga_docentes_com doc

								on com.comision = doc.comision

						   WHERE com.comision = 8845

							and doc.responsabilidad = 1






EXECUTE PROCEDURE sp_esingresantefec( 'FADU', '1', '39660640-7', '04/01/2019' );

EXECUTE PROCEDURE "dba".sp820_ctr_catedra ('FADU', '1', '40562686-1', 8705, 'D0305', 0);

EXECUTE PROCEDURE "dba".sp820_ctr_catedra ('FADU', '1', '40562686-1', 8711, 'D0305', 0);

EXECUTE PROCEDURE "dba".sp820_ctr_catedra ('FADU', '1', '40562686-1', 8684, 'D0305', 0);

Select * from sga_det_acta_curs det

		join sga_actas_cursado act

			on det.acta = act.acta

		join sga_comisiones com

			on act.comision = com.comision

		left join sga_docentes_com doc

			on com.comision = doc.comision

	where com.materia = 'D0305'
	and det.legajo = '40562686-1'
	and ((det.resultado = 'P') -- Comprobar promoción
		OR
	    (det.resultado = 'A' AND (det.fin_vigencia_regul >= today )))

EXECUTE PROCEDURE "dba".sp820_ctr_recur ('FADU', '1', '40819094-5', 8637, null, 0) ;
SELECT *
					   FROM sga_comisiones com
							join sga_docentes_com doc

								on com.comision = doc.comision

						   WHERE com.comision = 8546

							and doc.responsabilidad = 1



SELECT com.carrera, com.nombre, com.turno, com.materia 
   FROM sga_comisiones com
   WHERE com.comision = 8637;


SELECT *
			   FROM sga_comisiones com
					join sga_docentes_com doc

						on com.comision = doc.comision

				   WHERE com.comision = 8101

					and doc.responsabilidad = 1;
SELECT * from sga_docentes_com

	   WHERE comision = 8022;

begin;
update sga_comisiones set turno = 'T' where comision = 6185;
commit;

select * from sga_cursadas where legajo = '40115513-4';
select * from sga_comisiones where comision = 6185;

begin;
update sga_comisiones set turno = 'M' where comision = 8715;
update sga_comisiones set turno = 'T' where comision = 8722;

commit;


BEGIN;

UPDATE sga_insc_cursadas
SET estado = 'P'
WHERE nro_transaccion IN (SELECT ic.nro_transaccion
FROM sga_insc_cursadas as ic
JOIN sga_comisiones as c ON ic.comision = c.comision
WHERE ic.estado = 'A'
AND ic.carrera = '1'
AND c.anio_academico = '2018'
AND c.periodo_lectivo IN ('1° cuatrimestre')
AND materia = 'A0322')

-- ROLLBACK;
-- COMMIT;

select * from sysprocedures where procname like '%ctr820_cursvertic%'

-- Casos de prueba:
-- select * from sga_comisiones where anio_academico = 2019 and materia = 'C0301' and periodo_lectivo = '1° cuatrimestre';
select * from sga_cursadas where legajo = '41611426-1';
select * from sga_comisiones where comision in ( 8263, 8312); -- x turno
select * from sga_comisiones where comision in ( 8291); -- x docente. 2500
select * from sga_docentes_com where comision = 8291;

select * from sga_docentes_com where comision = 8304;
select * from log_comisiones where comision = 8262;
select * from sga_insc_cursadas where legajo = '40161398-1';
select * from sga_cursadas where legajo = '40161398-1';

select * from sga_comisiones where comision in ( 8107);
select * from sga_docentes_com where comision = 8107; -- x docente. 10473


begin;
update sga_comisiones set turno = 'T' where comision = 6185;
commit;

select * from sga_cursadas where legajo = '40115513-4';
select * from sga_comisiones where comision = 6185;

begin;
update sga_comisiones set turno = 'T' where comision = 6000;
update sga_comisiones set turno = 'M' where comision = 5999;
update sga_comisiones set turno = null where comision = 6983;
commit;

}



{
BEGIN;

UPDATE sga_insc_cursadas
SET estado = 'P'
WHERE nro_transaccion IN (SELECT ic.nro_transaccion
FROM sga_insc_cursadas as ic
JOIN sga_comisiones as c ON ic.comision = c.comision
WHERE ic.estado = 'A'
AND ic.carrera = '1'
AND c.anio_academico = '2018'
AND c.periodo_lectivo IN ('1° cuatrimestre')
AND materia = 'A0322')

-- ROLLBACK;
-- COMMIT;

select * from sysprocedures where procname like '%ctr820_cursvertic%'

-- Casos de prueba:
-- select * from sga_comisiones where anio_academico = 2018 and materia = 'A0304' and periodo_lectivo = '2° cuatrimestre';
select * from sga_cursadas where legajo = '41611426-1';
select * from sga_comisiones where comision in ( 8263, 8312); -- x turno
select * from sga_comisiones where comision in ( 8291); -- x docente. 2500
select * from sga_docentes_com where comision = 8291;

select * from sga_docentes_com where comision = 8304;
select * from log_comisiones where comision = 8262;
select * from sga_insc_cursadas where legajo = '40161398-1';
select * from sga_cursadas where legajo = '40161398-1';

select * from sga_comisiones where comision in ( 8107); -- x docente. 10473 Guisasola Mañana
select * from sga_docentes_com where comision = 8107; -- x docente. 10473 Guisasola Mañana


select * from sga_docentes where legajo = '10473';

SELECT *
					   FROM sga_comisiones com
							join sga_docentes_com doc

								on com.comision = doc.comision

						   WHERE com.comision = 8415

							and doc.responsabilidad = 1;


-- Quiere cursar A0309: Urbanismo I

SELECT com.carrera, com.nombre, com.turno, com.materia, doc.legajo
   FROM sga_comisiones com
	left join sga_docentes_com doc
	on com.comision = doc.comision
   WHERE com.comision = 8312
	and doc.responsabilidad = 1;


EXECUTE PROCEDURE "dba".sp820_ctr_turno ('FADU', '1', '40161398-1', 8312,  'C0301', 0);

SELECT *
			   FROM sga_comisiones com
					join sga_docentes_com doc

						on com.comision = doc.comision

				   WHERE com.comision = 8101

					and doc.responsabilidad = 1;
SELECT * from sga_docentes_com

	   WHERE comision = 8022;




}



