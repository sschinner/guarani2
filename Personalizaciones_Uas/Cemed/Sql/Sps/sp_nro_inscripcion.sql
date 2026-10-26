DROP PROCEDURE "dba".sp_nro_inscripcion;

create procedure "dba".sp_nro_inscripcion(unidad_academica LIKE sga_unidades_acad.unidad_academica) returning varchar(10);
	define i integer;
	begin work;
	   insert into inscripcion values(unidad_academica,0);
	  let i = DBINFO('sqlca.sqlerrd1');
	commit
	 work;
	return 'C' || unidad_academica || i;
end procedure;