-- **********************************************************************
-- SP: sp820_PasVig
-- Descripcion: Recupera las Pasantías Vigentes de Inscripcion de la UA para las carreras del alumno.
-- Fecha: 12/05/2005
--
-- Recibe: - Unidad_academica
--              - nro de Inscripcion
-- Retorna: - Unidad Academica
--              - Carrera
--              - Pasantia
--              - Nombre Carrera
--              - Nombre Pasantia
--	- Plan
-- **********************************************************************

-- Recupera las Pasantias a las que se puede inscribir un alumno.

--DROP procedure "dba".sp820_pasvig;
CREATE PROCEDURE "dba".sp820_pasvig(pUnidadAcademica LIKE sga_insc_examen.unidad_academica, pNroInscripcion  LIKE sga_personas.nro_inscripcion)
 
RETURNING  varchar(5),                -- unidad academica
           varchar(5),                -- carrera

           integer,                      -- pasantia
           varchar(20),               -- Nombre Carrera Reducido
           varchar(60),               -- Pasantía Detalle
	varchar(5);	-- Plan
   -- variables utilizadas.
   DEFINE	vcCarNomReducido                    varchar(20);
   DEFINE	vcUnidadAcademica                   LIKE  sga_insc_examen.unidad_academica;
   DEFINE	vcCarrera                           LIKE  sga_insc_examen.carrera;

   DEFINE	viPasantia		LIKE u820_pasantias.id_pasantia;
   DEFINE 	vcPasantiaDetalle		LIKE u820_pasantias.detalle;
	DEFINE vcPlan varchar(5);
BEGIN


   -- recupera las inscripciones a las pasantias
FOREACH
	SELECT dba.u820_pasantias.unidad_academica,
	       dba.sga_carreras.carrera,
	       dba.u820_pasantias.id_pasantia,
	       dba.u820_pasantias.detalle,
	       dba.sga_carreras.nombre_reducido,
		dba.u820_planes_pas.plan
	   INTO vcUnidadAcademica, vcCarrera, viPasantia, vcPasantiaDetalle, vcCarNomReducido, vcPlan

	  FROM 	
		dba.sga_personas, 
		dba.sga_alumnos,
		dba.sga_carreras, 
		dba.u820_pasantias,
		dba.u820_solicit_pas,
		dba.u820_planes_pas
       
 WHERE 	dba.sga_personas.nro_inscripcion = pNroInscripcion 
	AND dba.sga_personas.unidad_academica = pUnidadAcademica
	
	AND dba.sga_alumnos.nro_inscripcion = dba.sga_personas.nro_inscripcion
	AND dba.sga_alumnos.unidad_academica = dba.sga_personas.unidad_academica

	AND dba.sga_carreras.unidad_academica = dba.sga_alumnos.unidad_academica
	AND dba.sga_carreras.carrera = dba.sga_alumnos.carrera

	AND dba.u820_planes_pas.unidad_academica = dba.sga_alumnos.unidad_academica
	AND dba.u820_planes_pas.carrera = dba.sga_alumnos.carrera
	AND dba.u820_planes_pas.plan = dba.sga_alumnos.plan

	AND dba.u820_pasantias.unidad_academica = dba.u820_planes_pas.unidad_academica 
	AND dba.u820_pasantias.id_pasantia = dba.u820_planes_pas.id_pasantia

	AND dba.u820_solicit_pas.unidad_academica = dba.u820_pasantias.unidad_academica
	AND dba.u820_solicit_pas.solicitante = dba.u820_pasantias.solicitante

	AND dba.sga_carreras.unidad_academica = dba.sga_alumnos.unidad_academica
	AND dba.sga_carreras.carrera = dba.sga_alumnos.carrera

	AND TODAY BETWEEN dba.u820_pasantias.fecha_inicio AND dba.u820_pasantias.fecha_fin
	and dba.u820_pasantias.id_pasantia not in (select id_pasantia
					from u820_insc_pas
					where nro_inscripcion = pNroInscripcion)

 ORDER BY dba.sga_carreras.carrera, dba.u820_pasantias.id_pasantia 

     	  -- si no encontro nada, devuelve nulos
     	 RETURN  vcUnidadAcademica, vcCarrera, viPasantia, vcCarNomReducido, vcPasantiaDetalle, vcPlan WITH RESUME;


   END FOREACH ;
END;
END PROCEDURE;
-- **********************************************************************

-- execute procedure sp820_pasvig('FICH', '1444');
-- select * from u820_insc_pas


select * from acc_parametros_net;
select * from par_cont_x_punto where punto_de_control = '8201';
EXECUTE PROCEDURE ctr_ptos_x_pagina('netpas03', 'a_alumnos/u820_elegirInscPasantia.php');

SELECT nombre, origen_param_web, orden FROM par_punto_desc_par WHERE punto_de_control = "24" ORDER BY orden;
SELECT nombre, origen_param_web, orden FROM par_punto_desc_par WHERE punto_de_control = "8201" ORDER BY orden;


begin;
insert into par_puntos_x_pag
select 'netpas03', pagina, punto_de_control, orden from par_puntos_x_pag
where operacion like '820pas%';

commit;








