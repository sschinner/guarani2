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

IF vcMateria in ('A0322', 'A0329', 'A0326', 'A0310', 'A0308', 'C0303', 'A0324', 'A0307', 'A0313',  'A0321', 'A0328', 'D0305', 'D0311', 'D0316', 'A0323', 'A0318' ) THEN
	-- Corrección de materia correlativa a controlar:
	IF vcMateria = 'A0322'  THEN LET vcMateriaCorrelativa = 'A0322';
		ELIF vcMateria = 'A0329' THEN LET vcMateriaCorrelativa = 'A0322'; --ok
		ELIF vcMateria = 'A0326' THEN LET vcMateriaCorrelativa = 'A0326'; --ok
		ELIF vcMateria = 'A0310' THEN LET vcMateriaCorrelativa = 'C0303';
		ELIF vcMateria = 'A0308' THEN LET vcMateriaCorrelativa = 'A0303'; --ok
		ELIF vcMateria = 'C0303' THEN LET vcMateriaCorrelativa = 'C0303';
		ELIF vcMateria = 'A0324' THEN LET vcMateriaCorrelativa = 'A0318';

		ELIF vcMateria = 'A0307' THEN LET vcMateriaCorrelativa = 'A0307'; --ok
		ELIF vcMateria = 'A0313' THEN LET vcMateriaCorrelativa = 'A0313'; --ok
		ELIF vcMateria = 'A0321' THEN LET vcMateriaCorrelativa = 'A0321'; --ok
		ELIF vcMateria = 'A0328' THEN LET vcMateriaCorrelativa = 'A0328'; --ok
		ELIF vcMateria = 'D0305' THEN LET vcMateriaCorrelativa = 'D0305'; --ok
		ELIF vcMateria = 'D0311' THEN LET vcMateriaCorrelativa = 'D0305'; --ok
		ELIF vcMateria = 'D0316' THEN LET vcMateriaCorrelativa = 'D0311'; --ok
		ELIF vcMateria = 'A0323' THEN LET vcMateriaCorrelativa = 'A0316'; --ok
		ELIF vcMateria = 'A0318' THEN LET vcMateriaCorrelativa = 'A0309'; --ok

		ELSE LET vcMateriaCorrelativa = 'C0301'; 
	END IF;

	-- Año 2021

	-- Verificar regularidad de la misma materia: verde
	-- Eligen Cátedra; Cad Libres y Recursantes. Solo controla regularidad la misma materia de inscripción
	IF vcMateria in ( 'A0307', 'A0313',  'A0321', 'A0328', 'D0305', 'A0322', 'A0326' ) THEN
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

	IF vcMateria in ( 'A0329') THEN
		-- Controla de la materia correlativa, el turno con el que lo curso (Dependiendo de la vigencia la regularidad en ella, manda o no a comisión a designar) 
		EXECUTE PROCEDURE "dba".sp820_ctr_regular (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;

		IF iStatus = 1 THEN
			IF EXISTS (SELECT *
			   FROM sga_comisiones com
				join sga_docentes_com doc
				on com.comision = doc.comision
			   WHERE com.comision = pComision
				and doc.responsabilidad = 1) THEN
					LET iStatus  = 1;
					LET vcMsg = 'OK';
	
			ELSE
					LET iStatus  = -1;
					LET vcMsg  =  '82012001';
			END IF;
		ELSE

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

		END IF;		
	END IF;


	-- Verificar que cumplan con la catedra:
	IF vcMateria in ( 'D0311', 'D0316', 'A0323', 'A0308') THEN
		-- Controla de la materia correlativa, el turno con el que lo curso (Dependiendo de la vigencia la regularidad en ella, manda o no a comisión a designar) 
		EXECUTE PROCEDURE "dba".sp820_ctr_catedra (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
	END IF;


	-- Verificar que cumplan con turno:
	IF vcMateria in ( 'A0310') THEN
		-- Controla de la materia correlativa, el turno con el que lo curso (Dependiendo de la vigencia la regularidad en ella, manda o no a comisión a designar) 
		EXECUTE PROCEDURE "dba".sp820_ctr_turno (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
	END IF;

	-- Verificar que solo se inscriban recursantes
	IF vcMateria in ( 'C0303') THEN
		EXECUTE PROCEDURE "dba".sp820_ctr_recur (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
			IF iStatus = 1 THEN		
				LET iStatus  = 1;
				LET vcMsg = 'OK';

			ELSE
				LET iStatus = -1;
				LET vcMsg  =  '82012001';
			END IF;

	END IF;

	-- Verificar que cumplan con catedra y cambio docente especial
	IF vcMateria in ( 'A0318', 'A0324') THEN
		-- Controla de la materia correlativa, la catedra con el que lo curso (Dependiendo de la vigencia la regularidad en ella, manda o no a comisión a designar) 
		EXECUTE PROCEDURE "dba".sp820_ctr_cat_esp (pUnidadAcademica, pCarrera, pLegajo, pComision, vcMateriaCorrelativa, 0) INTO iStatus, vcMsg;
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
select * from sga_comisiones where anio_academico = 2021 and materia = 'A0318' and periodo_lectivo = 'Anual'; --'1° cuatrimestre';

select  doc.legajo, per.apellido, dc.responsabilidad, com.* from sga_comisiones  com
join sga_docentes_com dc on com.comision = dc.comision
join sga_docentes doc on doc.legajo = dc.legajo
join sga_personas per on per.nro_inscripcion = doc.nro_inscripcion
where materia = 'A0318' and anio_academico = 2019 and  periodo_lectivo = '1° cuatrimestre' and dc.responsabilidad = 1;

select * from sga_cursadas where comision = 8518; -- '40278929-7'

select * from sga_cursadas where legajo = '42924569-7';
select * from sga_comisiones where comision = 9571;
select * from sga_docentes_com where comision = 9571;
select * from log_comisiones where comision = 8262;
select * from sga_insc_cursadas where legajo = '41403286-6';

select per.apellido from sga_docentes doc
	join sga_personas per on  doc.nro_inscripcion = per.nro_inscripcion
where legajo = '4487'

-- A0329: NO OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38771342-7',  9703); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38771342-7',  9711); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '38771342-7',  9832); --  NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '39127418-6',  9703); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '39127418-6',  9711); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '39127418-6',  9832); --  SI
-------------------------------------------------------------------------------------------------------------------------------------------
-- A0308: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295095-2',  9716); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295095-2',  9761); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295095-2',  9708); --  NO

-- A0324: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41866784-3',  9854); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41866784-3',  9712); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41866784-3',  9677); --  NO

-- A0310: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295537-1',  9853); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295537-1',  9710); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43295537-1',  9831); --  NO

-- D0305: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41637149-6',  9932); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41637149-6',  9857); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41637149-6',  9897); --  NO

-- D0311: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283296-7',  9955); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283296-7',  9895); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283296-7',  9899); --  NO

-- D0316: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41754730-9',  9894); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41754730-9',  9856); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '41754730-9',  9898); --  SI

-- A0323: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40645098-6',  9900); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40645098-6',  9868); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40645098-6',  9892); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40645098-6',  9919); --  NO

-- A0318: OK
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42924569-7',  9927); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42924569-7',  9870); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42924569-7',  9889); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '42924569-7',  9930); --  NO

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40121378-5',  9927); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40121378-5',  9870); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40121378-5',  9889); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40121378-5',  9930); --  SI


begin;
update sga_docentes_com set responsabilidad = 1 where comision = 9571 and legajo = 4487;
commit;


Select '*' from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
		left join sga_docentes_com doc
			on com.comision = doc.comision
	where com.materia = 'A0309'
	AND ( 
	(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
		OR
	(det.cond_regularidad = 0 OR (0 = 0 and det.resultado IN('P'))) -- Condicion
		)

	and det.legajo = '42924569-7';

Select '*' from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			where com.materia = 'A0318'
			and det.legajo = '42924569-7';


Select doc.legajo 
		from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			left join sga_docentes_com doc
				on com.comision = doc.comision
		where com.materia = 'A0309'
		and  ( 
			(det.fin_vigencia_regul >= today and det.resultado IN('A')) -- Comprobar Vigencia.
				OR
			(det.cond_regularidad = 0 OR (0 = 0 and det.resultado IN('P'))) -- Condicion
		)
		and det.legajo = '42924569-7'
		--and doc.responsabilidad = 1





-- Ingresante 2021
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9672); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9673); --  SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9674); -- SI
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9675); -- SI

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9836); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9837); --  NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9838); -- NO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43756113-6',  9839); -- NO
-------------------------------------------------------------------------------------------------------------------------------------------



EXECUTE PROCEDURE "dba".sp820_ctr_recur ('FADU', '1', '34822723-3',  9672, 'C0301', 0);
EXECUTE PROCEDURE "dba".sp820_ctr_tur_r ('FADU', '1', '36543093-5',  9672, 'C0301', 0);
EXECUTE PROCEDURE "dba".sp820_ctr_cate_r ('FADU', '1', '36543093-5',  9672, 'C0301', 0);

select * from sga_cursadas where legajo = 'C0301';and materia = 'C0301';
select * from sga_cursadas where legajo = '34822723-3' and materia = 'C0301';

Select * from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
	where com.materia = 'C0301'
	and det.legajo = '34822723-3';




EXECUTE PROCEDURE "dba".sp820_ctr_turno ('FADU', '1', '42576897-9',  9572, 'C0301', 0);
EXECUTE PROCEDURE "dba".sp820_ctr_prom_esp ('FADU', '1', '42576897-9',  9572, 'C0301', 0);

Select com.turno, * from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
		left join sga_docentes_com doc
			on com.comision = doc.comision
	where com.materia = 'C0301'
	-- AND (det.fin_vigencia_regul >= today ) -- Comprobar Vigencia.
	--AND (YEAR(det.fecha_regularidad) = '2019') -- YEAR(today) ) -- Comprobar Vigencia.
	-- and det.resultado IN('P') -- Condicion
	 and det.legajo = '34822723-3' 

select * from sga_cursadas where legajo = '42576897-9';




execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8811); -- Bessone T si puede
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8838); -- CaD
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8889); -- Falco M 

--  C0303
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8897); -- Imbach TM - ARQ 
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8835); -- CaD
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40278929-7',  8899); -- Imbach TT - ARQ si pude

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '3', '42870772-6',  8895); -- Imbach  - LDVC si pude

-- A0303
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40205761-6',  8848); -- De Simone TM
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40205761-6',  8849); -- De Simone TT
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40205761-6',  8837); -- CaD
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40205761-6',  8892); -- Guisasola TM si puede
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40205761-6',  8893); -- Guisasola TT

execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40044847-3',  8848); -- De Simone TM
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40044847-3',  8849); -- De Simone TT
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40044847-3',  8837); -- CaD si puede
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40044847-3',  8892); -- Guisasola TM 
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40044847-3',  8893); -- Guisasola TT


-- C0302
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40407798-5', 8975 ); -- Stipech TM-ARQ
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40407798-5', 8976); -- Stipech TM-LDCV
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40407798-5', 8977); -- Stipech TT-ARQ
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '40407798-5', 8978); -- Stipech TT-LDCV


-- A0309
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8845); -- Com. a Designar
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8902); -- INTERCAMBIO
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8969); -- OPT-LDCV-SOIJ
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8970); -- OPT-LDCV-VAL
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8974); -- SOIJET
execute PROCEDURE "dba".ctr820_cursvertica ( 'FADU', '1', '43283254-6', 8981); -- VALIENTE

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



8518
8519
8520
8521


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



