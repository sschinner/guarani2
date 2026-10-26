-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.5
-- Tabla u820_rama_actividad
-- *******************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_rama_actividad') THEN

CREATE TABLE "dba".u820_rama_actividad (
	RAMA		varchar(60) NOT NULL,
	NOMBRE		varchar(255)
);
insert into u820_rama_actividad values ('0','Indeterminado');
insert into u820_rama_actividad values ('1','Administrativas, en planificación o informática');
insert into u820_rama_actividad values ('2','Contables, financieras o presupuestarias');
insert into u820_rama_actividad values ('3','Comerciales, de transporte, almacenaje o telecomunicaciones');
insert into u820_rama_actividad values ('4','en servicios sociales básicos (Ej.: educación, salud, etc.)');
insert into u820_rama_actividad values ('5','en servicios varios (Ej.: peluquería, cocina, etc.)');
insert into u820_rama_actividad values ('6','Agropecuario, forestales, pesca y caza');
insert into u820_rama_actividad values ('7','En producción de energia, agua potable, gas, extracción de minerales, construcción o infraestructura');
insert into u820_rama_actividad values ('8','En producción industrial o artesanal (Ej.: Panificación, mataderos, mueblerías)');
insert into u820_rama_actividad values ('9','Otras');


update sga_datos_censales
set det_rama_act_alum = '9'
where det_rama_act_alum ='Otra';

ALTER TABLE "dba".u820_rama_actividad
       ADD CONSTRAINT PRIMARY KEY (RAMA)
              CONSTRAINT pku820_r_actividad;


-- *********** Fin del script de la tabla u820_rama_actividad **********
END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

revoke all on "dba".u820_rama_actividad from public;
grant select, update, insert, delete on "dba".u820_rama_actividad to guarani;
grant select, update, insert, delete on "dba".u820_rama_actividad to internet;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT constrid
			FROM sysconstraints
			WHERE constrname = 'fku820_dat_cen_rama_act' and constrtype = 'R') THEN
		ALTER TABLE sga_datos_censales DROP CONSTRAINT fku820_dat_cen_rama_act;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

ALTER TABLE sga_datos_censales
       ADD CONSTRAINT FOREIGN KEY (det_rama_act_alum)
                             REFERENCES u820_rama_actividad
              CONSTRAINT fku820_dat_cen_rama_act;

