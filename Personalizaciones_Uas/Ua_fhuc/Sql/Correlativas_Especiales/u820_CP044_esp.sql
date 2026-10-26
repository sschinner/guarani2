
--El que esta en condiciones: Poletti, Paulina Leg: 34565142-5

--El que no esta en condiciones: Bussi, Lucía Itatí Leg: 39252777-4

--execute procedure u820_CP044_esp('FHUC','18','34565142-5','CP044','2005','2')

CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

	IF EXISTS (SELECT procid

			FROM sysprocedures

			WHERE procname = 'u820_cp044_esp') THEN

		DROP PROCEDURE u820_CP044_esp;

	END IF;		

END

END PROCEDURE;



EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();



create procedure "dba".u820_CP044_esp(	v_unidad_acad	like sga_alumnos.unidad_academica,

					v_carrera		like sga_alumnos.carrera,

					v_legajo		like sga_alumnos.legajo,

					v_materia		like sga_actas_examen.materia,

					v_plan		like sga_alumnos.plan,

					v_version		like sga_actas_examen.version)

				

		returning smallint, varchar(255);



begin



	define sqlerr		integer;

	define isamerr		integer;

	define errorinfo		varchar(76);

	define v_resu		numeric(1);

	define v_c_resu		char(76);

	define v_cantidad		numeric(5);
	

DEFINE vinro_documento LIKE sga_personas.nro_documento;

DEFINE vctipo_documento LIKE sga_personas.tipo_documento;

DEFINE vcCarreraNombre varchar (60);

DEFINE viCantMatPlan integer;

DEFINE viCantMatAprob integer;
DEFINE vcCodCarreraUNL varchar(5);

DEFINE vcNroInscripcion varchar(10);



	-- si hay algun error

	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo

		RETURN -1, errorInfo;

	END EXCEPTION;

	

	let v_resu = 1;

	let v_c_resu = "";



LET vinro_documento = NULL;

LET vctipo_documento = NULL;

LET vcCarreraNombre = NULL;

LET viCantMatPlan = NULL;

LET viCantMatAprob = NULL;

LET vcCodCarreraUNL = NULL;



        ---------------------------------------------------------------------------------------------------------------------

	select distinct materia

	from vw_hist_academica 

	where legajo =v_legajo

		and resultado = 'A'

		and materia in ("CP003","CP031","CP008","CP015")

	Into Temp aux_materias;



	select count(*) into v_cantidad

	from aux_materias h;
       ----------------------------------------------------------------------------------------------------------------------

	

Select nro_inscripcion Into vcNroInscripcion 

from  sga_alumnos

Where legajo = v_legajo

	and carrera =v_carrera;



 EXECUTE PROCEDURE "dba".sp820_can_apro (vcNroInscripcion, v_carrera) INTO vctipo_documento, vinro_documento, vcCodCarreraUNL, vcCarreraNombre, viCantMatPlan, viCantMatAprob;



IF  ( (viCantMatPlan-viCantMatAprob >5) AND (v_cantidad < 4)) Then

	let v_resu = -1;

	let v_c_resu = "No tenés la cantidad de materias necesarias para rendir esta materia.";

End if;


	



	drop table aux_materias;

	return v_resu, v_c_resu;

end;



end procedure;

-- *************** Fin del procedimiento "dba".u820_CP044_esp ********************

REVOKE execute ON "dba".u820_CP044_esp FROM public;
GRANT execute ON "dba".u820_CP044_esp to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".u820_CP044_esp to internet; -- Rol de usuario de Internet


