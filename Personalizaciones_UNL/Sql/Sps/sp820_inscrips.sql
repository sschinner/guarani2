CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_inscrips') THEN
		DROP PROCEDURE sp820_inscrips;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Procedure sp820_inscrips
-- Ultima modificacion: version 2.9.1
-- 
-- PERSONALIZCION:
-- Relacionado al Reporte de inscriptos a cursada en un período lectivo - Operación UNL: 820cur05
-- *****************************************************************************
CREATE PROCEDURE  "dba".sp820_inscrips (
	punidad_academica LIKE sga_comisiones.unidad_academica,
	panio_academico LIKE  sga_comisiones.anio_academico,
	pperiodo_lectivo    LIKE  sga_comisiones.periodo_lectivo)
	returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	integer,          --anio_academico
	varchar(30),   --periodo_lectivo
	varchar(50), --carrera
	varchar(30), --materia
	varchar(30), --comision
	varchar(30), --año_acad_ing
	varchar(30); --dni

DEFINE vlegajo varchar(15);
DEFINE vapellido, vnombres varchar(30);
DEFINE vcarrera, vmateria, vnombre_com, vdni varchar(50);
DEFINE vanio_acad_ing varchar(30);
DEFINE vcomision integer;

--vars para el manejo de excepciones
DEFINE sql_err	 			integer;
DEFINE isam_err 			integer;
DEFINE error_info			varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

   on exception in (-206)
    -- Tabla no existe continuo el proceso	
   end exception with resume;

-- {+ index(c 592_3497, i idx_cur_com,  a pp_ua_leg, p 312_1420)} {+ ordered } 

FOREACH SELECT {+ ordered }  distinct i.legajo, apellido, nombres, g.nombre, c.materia, c.nombre, s.periodo_inscripcio, p.nro_documento, c.comision
   INTO vlegajo,vapellido,vnombres, vcarrera, vmateria, vnombre_com, vanio_acad_ing, vdni, vcomision
                 FROM sga_insc_cursadas i,sga_comisiones c,  sga_alumnos a, sga_personas p, sga_carrera_aspira s, sga_carreras g
	  WHERE c.anio_academico = panio_academico
		AND c.periodo_lectivo = pperiodo_lectivo 
		AND c.unidad_academica = pUnidad_Academica
		AND c.unidad_academica = a.unidad_academica
		AND  c.comision = i.comision 		
		and a.unidad_academica=p.unidad_academica
		and a.nro_inscripcion=p.nro_inscripcion
		AND a.legajo = i.legajo
		and a.nro_inscripcion = s.nro_inscripcion
		and a.carrera = s.carrera
		and a.carrera = g.carrera

	ORDER BY g.nombre, c.materia, c.comision, apellido, nombres


return  vlegajo, vapellido, vnombres, panio_academico, pperiodo_lectivo, vcarrera, vmateria, vcomision, vanio_acad_ing, vdni WITH RESUME;

END FOREACH;

end ;
end PROCEDURE;
                          
-- execute procedure dba.sp820_inscrips ( 'FCE', 2004, 'Preinscripción')
-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_inscrips
-- *****************************************************************************
revoke execute on "dba".sp820_inscrips from public;
grant execute on "dba".sp820_inscrips to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_inscrips to internet; -- Rol de usuario de Internet


