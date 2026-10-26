-- *******************************************************************************
-- SP: sp820_pasantias_insc
-- 
-- Registra una Inscripcion a Pasantía
--
-- *******************************************************************************
-- DROP PROCEDURE sp820_pasantias_insc;
CREATE PROCEDURE "dba".sp820_pasantias_insc(
	pUnidadAcademica		LIKE sga_personas.unidad_academica,
	pNroInscripcion		LIKE sga_personas.nro_inscripcion)

RETURNING 
	varchar(5),		-- unidad academica
	varchar(15),		-- nro_transaccion
              	integer,			-- id_pasantia
	integer,			-- solicitante
	varchar(60),		-- nombre_solicitante
	varchar(15),		-- legajo
	varchar(5),		-- carrera
	varchar(5),		-- plan
	varchar(60);		-- nombre


define vUnidadAcademica like u820_solicit_pas.unidad_academica;
define vId_Pasantia like u820_pasantias.id_pasantia;
define vSolicitante like u820_solicit_pas.solicitante;
define vRazonSocial like u820_solicit_pas.razon_social;
define vLegajo like sga_alumnos.legajo;
define vCarrera like sga_alumnos.carrera;
define vPlan like sga_alumnos.plan;
define vNombre like sga_carreras.nombre;

begin

SELECT p.unidad_academica, p.id_pasantia, s.solicitante, s.razon_social, a.legajo, a.carrera, a.plan, c.nombre
	FROM u820_pasantias p
		join u820_solicit_pas s
		  on p.solicitante = s.solicitante
		join u820_planes_pas pp
			join sga_alumnos a
				join sga_carreras c
				  on a.carrera = c.carrera
			  on pp.carrera = a.carrera
				and pp.plan = a.plan
				and a.nro_inscripcion = pNroInscripcion
		  on p.id_pasantia = pp.id_pasantia
	WHERE today between p.fecha_inicio and p.fecha_fin
		and p.id_pasantia not in (	select id_pasantia
					from u820_insc_pas
					where nro_inscripcion = pNroInscripcion)
	INTO TEMP temporal;

FOREACH SELECT unidad_academica, id_pasantia, solicitante, razon_social, legajo, carrera, plan, nombre
	INTO vUnidadAcademica, vId_Pasantia, vSolicitante, vRazonSocial, vLegajo, vCarrera, vPlan, vNombre
	FROM temporal
	order by carrera, id_pasantia

 	  RETURN vUnidadAcademica, pNroInscripcion, vId_Pasantia, vSolicitante, vRazonSocial, vLegajo, vCarrera, vPlan, vNombre WITH RESUME;
END FOREACH ;

drop table temporal;
end

END PROCEDURE

-- ++++++++++++++++++++++++++++++++++++++++++++++ FIN SP sp820_pasantias_insc +++++++++++++++++++++++++++++++++++++++

