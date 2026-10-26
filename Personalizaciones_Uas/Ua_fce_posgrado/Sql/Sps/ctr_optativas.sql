DROP PROCEDURE "dba".ctr_optativas;
CREATE PROCEDURE "dba".ctr_optativas(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,

                                  pCarrera          LIKE sga_alumnos.carrera,

                                  pLegajo           LIKE sga_alumnos.legajo,

                                  pMateria          LIKE sga_materias.materia)



	RETURNING 	smallint,       -- status

			varchar(255);   -- <mensaje, parametros>



  -- vars para la respuesta

  DEFINE iStatus 		smallint;	-- status

  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros





  -- var's para el manejo de excepciones

   DEFINE sql_err,isam_err 	integer;

   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);





   -- variables locales

   DEFINE viCantAus integer;

   DEFINE vcAnioAcademico LIKE sga_mesas_examen.anio_academico;

   DEFINE vcTurnoExamen LIKE sga_mesas_examen.turno_examen;

   DEFINE vdFecha_fin  LIKE sga_turnos_examen.fecha_fin;

  DEFINE v_plan 	LIKE sga_planes.plan;

  DEFINE v_version	LIKE sga_planes.version_actual;

  DEFINE v_cant_opt Integer;

  DEFINE v_cant_mat Integer;



   -- blk de excepciones

   ON EXCEPTION SET sql_err, isam_err, error_info

     LET iStatus = -1 ;

     LET vcMsg = '800321' || ',' || 'ctr_optativas' || ',' || sql_err || ' - '  || error_info ;  

     RETURN iStatus, vcMsg ;

   END EXCEPTION;        



BEGIN

   -- seteo los valores default

   LET iStatus		= 1 ;

   LET vcMsg		= 'OK';

   LET viCantAus  = 0;



select a.plan, p.version_actual Into v_plan, v_version

from sga_alumnos a

	join sga_planes p

	  on a.carrera = p.carrera

		and a.plan = p.plan

where a.legajo = pLegajo

	and a.carrera = pCarrera 

	and a.unidad_academica = pUnidadAcademica;



  

-- SI la materia No es optativa. Lo hago asi para no colocarla como correlativa.

IF pMateria Not In (select materia_optativa

		from sga_atrib_mat_plan a join sga_mat_genericas g

			on a.materia = g.materia_generica

		where  a.unidad_academica = pUnidadAcademica

			and a.carrera = pCarrera

			and a.plan = v_plan

			and a.version = v_version) THEN

	

	RETURN iStatus, vcMsg; 

END IF;



--  Control que se pueda inscribir a 1 sola optativa. OJO esto esta particularizado para un periodo lectivo. Habira que hacerlo generico.



IF EXISTS (Select ''  FROM sga_insc_cursadas cur

			 join sga_comisiones com

			 on cur.comision = com.comision

		WHERE  	com.anio_academico = 2005

			and com.periodo_lectivo = '2do. CUATRIMESTRE'

			and cur.legajo =  pLegajo

			and com.materia In (select materia_optativa

					from sga_atrib_mat_plan a join sga_mat_genericas g

					on a.materia = g.materia_generica

					where  a.unidad_academica = pUnidadAcademica

						and a.carrera = pCarrera

						and a.plan = v_plan

						and a.version = v_version) ) THEN

		LET iStatus = -1 ;

		LET vcMsg = 'Solo podés inscribirte a 1 sola Optativa.';

		RETURN iStatus, vcMsg; 

END IF;









select count (*)  Into v_cant_opt

from vw_hist_academica

where unidad_academica = pUnidadAcademica

	and carrera = pCarrera

	and plan = v_plan

--	and version = v_version

	and legajo = pLegajo

	and resultado = 'A'

	and materia In (select materia_optativa

		from sga_atrib_mat_plan a join sga_mat_genericas g

			on a.materia = g.materia_generica

		where  a.unidad_academica = pUnidadAcademica

			and a.carrera = pCarrera

			and a.plan = v_plan

			and a.version = v_version);



LET v_cant_opt = v_cant_opt + 1;



select count (*)  Into v_cant_mat

from vw_hist_academica

where unidad_academica = pUnidadAcademica

	and carrera = pCarrera

	and plan = v_plan

	and legajo = pLegajo

	and resultado = 'A'

	and materia Not In ('1011', '1041', '1080');



LET iStatus		= -1 ;

LET vcMsg		= 'No tenés la cantidad de materias aprobadas necesarias para rendir/cursar la Optativa.';



If v_cant_opt = 1 then

	if v_cant_mat < 8 then

	RETURN iStatus, vcMsg; 

	end if;

else



	if pMateria in ('0029', '0022', '0018') then

		LET iStatus = -1 ;

		LET vcMsg = 'No estas habilitado para inscribirte a esta Optativa.';
		RETURN iStatus, vcMsg; 

	end if;



	if v_cant_opt = 2  then       

		if v_cant_mat < 12 then

		RETURN iStatus, vcMsg; 

		end if;

	elif v_cant_opt = 3 then

		if v_cant_mat < 18 then

		RETURN iStatus, vcMsg; 

		end if;

	elif v_cant_opt >= 4 then

		if v_cant_mat < 24 then

		RETURN iStatus, vcMsg; 

		end if;

	end if;

end if;



LET iStatus		= 1 ;

LET vcMsg		= 'OK';

RETURN iStatus, vcMsg; 

END;

END PROCEDURE;
                                                                                                                                                                                                                                                             
