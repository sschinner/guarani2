CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_inserts_codigos') THEN
		DROP PROCEDURE sp820_inserts_codigos;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp820_inserts_codigos();

BEGIN

-- ***************************
-- SITUACION LABORAL
-- ***************************
update sga_sit_laboral
set descirpcion = "Desocupado/a"
where situacion_laboral = 1;

update sga_sit_laboral
set descirpcion = "Ocupado/a Temporal"
where situacion_laboral = 2;

update sga_sit_laboral
set descirpcion = "Ocupado/a Permanente"
where situacion_laboral = 3;

update sga_sit_laboral
set descirpcion = "Subocupado/a"
where situacion_laboral = 4;

IF NOT EXISTS (select * from sga_sit_laboral where situacion_laboral = 5) THEN
	insert into sga_sit_laboral values(5, "Atención del Hogar y la Familia");
ELSE
	update sga_sit_laboral
	set descirpcion = "Atención del Hogar y la Familia"
	where situacion_laboral = 5;
END IF;

IF NOT EXISTS (select * from sga_sit_laboral where situacion_laboral = 6) THEN
	insert into sga_sit_laboral values(6, "Jubilado/a o Pensionado/a");
ELSE
	update sga_sit_laboral
	set descirpcion = "Jubilado/a o Pensionado/a"
	where situacion_laboral = 6;
END IF;

IF NOT EXISTS (select * from sga_sit_laboral where situacion_laboral = 7) THEN
	insert into sga_sit_laboral values(7, "Otros");
ELSE
	update sga_sit_laboral
	set descirpcion = "Otros"
	where situacion_laboral = 7;

END IF;

-- *******************************************************
-- CONTROL REGULARIDAD EN LA CARRERA
-- *******************************************************
-- Nuevo codigo de perdida de Regularidad en la carrera - UNL
-- select * from sga_causa_perd_reg

update sga_causa_perd_reg set estado = "B" where causa_perdida_reg <> 82001 and estado = "A";

IF NOT EXISTS (select * from sga_causa_perd_reg where causa_perdida_reg = 82001) THEN
	Insert into sga_causa_perd_reg values (82001, 'Inactividad Académica', 'El Alumno no ha realizado actividad académica en los últimos 5 años', 'A' );

END IF;

-- ***********************************
-- NUEVAS REGULARIDADES
-- ***********************************

IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 7) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(7, "Promoción Pendiente", "A");
END IF;

IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 8) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(8, "Condición Pendiente", "U");
END IF;

IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 9) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(9, "Examen Habilitante", "A");
END IF;

IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 10) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(10, "Trabajo Práctico", "A");
END IF;


IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 11) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(11, "Renuncia", "U"); 
END IF;

IF NOT EXISTS (select * from sga_cond_regular where cond_regularidad = 12) THEN
	insert into sga_cond_regular (cond_regularidad, descripcion, resultado) values(12, "Coloquio Final Integrador", "A");
END IF;

-- ***********************************
-- NUEVOS TIPOS
-- ***********************************

IF NOT EXISTS (select * from sga_resol_tipo where resolucion_tipo = 'R') THEN
	insert into sga_resol_tipo values ('R', 'RR', 'Resolución del Rector');
END IF;

IF NOT EXISTS (select * from sga_resol_tipo where resolucion_tipo = 'D') THEN
	insert into sga_resol_tipo values ('D', 'RD', 'Resolución del Decano');
END IF;


IF NOT EXISTS (select * from sga_tipos_titulo where tipo_de_titulo = 'B') THEN
	insert into sga_tipos_titulo values ('B', 'Bachiller Universitario', 'Bachiller Universitario', null);

END IF;


END;

END PROCEDURE;

EXECUTE PROCEDURE  dba.sp820_inserts_codigos();




