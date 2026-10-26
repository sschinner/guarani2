CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_tabla_u820_equiv_cant_mat') THEN
		DROP PROCEDURE sp_crea_tabla_u820_equiv_cant_mat;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp_crea_tabla_u820_equiv_cant_mat ();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_equiv_cant_mat') THEN

create table u820_equiv_cant_mat (
	UNIDAD_ACADEMICA	varchar(5) NOT NULL,
	CARRERA		varchar(5) NOT NULL,
	PLAN			varchar(5) NOT NULL,
	CANTIDAD		int NOT NULL,
	CORRECCION		int  NOT NULL);

ALTER TABLE u820_equiv_cant_mat
       ADD CONSTRAINT PRIMARY KEY (CARRERA, PLAN, CANTIDAD)
              CONSTRAINT pk_u820_equiv_cant_mat;

alter table u820_equiv_cant_mat
	add constraint  FOREIGN KEY (UNIDAD_ACADEMICA, CARRERA, PLAN)
              REFERENCES sga_planes (UNIDAD_ACADEMICA, CARRERA, PLAN)
CONSTRAINT fk_u820_equiv_cant_mat1;

grant all on u820_equiv_cant_mat to public;


END IF;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_crea_tabla_u820_equiv_cant_mat *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_crea_tabla_u820_equiv_cant_mat 
-- *****************************************************************************
revoke execute on "dba".sp_crea_tabla_u820_equiv_cant_mat from public;
grant execute on "dba".sp_crea_tabla_u820_equiv_cant_mat to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_crea_tabla_u820_equiv_cant_mat to internet; -- Rol de usuario de Internet

-- Se ejecuta y eliminar procedimiento
EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_equiv_cant_mat ();
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

{
select * from u820_equiv_cant_mat;

-- INSERT
-- PROCURACION 1985
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 1, 1);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 2, 3);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 3, 5);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 4, 7);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 5, 8);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 6, 10);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 7, 11);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 8, 14);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 9, 15);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 10, 17);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 11, 18);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 12, 21);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 13, 23);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 14, 24);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 15, 26);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 16, 28);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 17, 30);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 18, 31);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 19, 33);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 20, 34);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "2", "1985", 21, 37);

-- ABOGACIA 1985
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 1, 1);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 2, 2);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 3, 3);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 4, 5);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 5, 6);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 6, 7);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 7, 8);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 8, 9);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 9, 10);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 10, 11);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 11, 12);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 12, 14);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 13, 15);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 14, 16);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 15, 17);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 16, 18);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 17, 20);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 18, 21);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 19, 22);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 20, 23);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 21, 24);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 22, 25);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 23, 26);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 24, 28);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 25, 29);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 26, 30);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 27, 31);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 28, 32);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 29, 33);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 30, 34);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 31, 36);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "1985", 32, 37);
 
-- ABOGACIA 2000
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 1, 1);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 2, 2);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 3, 3);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 4, 4);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 5, 5);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 6, 6);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 7, 7);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 8, 8);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 9, 9);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 10, 10);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 11, 11);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 12, 12);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 13, 13);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 14, 14);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 15, 15);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 16, 16);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 17, 17);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 18, 18);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 19, 19);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 20, 20);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 21, 21);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 22, 22);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 23, 23);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 24, 24);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 25, 25);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 26, 26);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 27, 27);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 28, 28);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 29, 29);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 30, 30);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 31, 31);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 32, 32);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 33, 33);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 34, 34);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 35, 35);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 36, 36);
insert into u820_equiv_cant_mat (UNIDAD_ACADEMICA, CARRERA, PLAN, CANTIDAD, CORRECCION) values ("FCJS", "1", "2000", 37, 37);
}