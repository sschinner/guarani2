
CREATE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();

BEGIN

IF NOT EXISTS (SELECT * FROM systables where tabname = 'u820_ult_nro_acta') THEN
DROP TABLE u820_ult_nro_acta;

CREATE TABLE "dba".u820_ult_nro_acta (
	       	anio_academico		int NOT NULL,
		nro_rec			int,
		nro			int,
		nro_01			int,
		nro_02			int,
		nro_03			int,
		nro_04			int);


ALTER TABLE  u820_ult_nro_acta 
       ADD CONSTRAINT PRIMARY KEY (anio_academico)
              CONSTRAINT pk_u820_ult_nro_acta ;


ALTER TABLE u820_ult_nro_acta ADD nro_05 integer;



END IF;
END;
END PROCEDURE;

EXECUTE PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();
DROP PROCEDURE "dba".sp_crea_tabla_u820_ult_nro_acta();


{
--select * from u820_datos_cen_aux

--select * from sga_carreras


--select * from u820_ult_nro_acta

--select * from sga_materias
--order by 2




insert into u820_ult_nro_acta 
		values ('2009', 1, 1, 1, 1, 1, 1);

select * from u820_ult_nro_acta 

select v_acta = "EB" || lpad(v_acta, 4, "0") from u820_ult_nro_acta ;


00001	Especialización en Ciencia y Tecnología de la Carne          
00002	Especialización en Buiatría            EB
00003	Maestría en Ciencias Veterinarias            MCV
00004	Especialización en Salud de los Animales de Compañía        AC
00005	octorado en Ciencias Veterinarias            MCV

}
