DROP TABLE AUX_DW_EGRESADOS;
CREATE TABLE AUX_DW_EGRESADOS (
unidad_academica	varchar(5) not null,
carrera		varchar(5) not null,
anio_ingreso	varchar(20)not null,
anio_egreso	varchar(20)not null,
legajo		varchar(15) not null);

DROP PROCEDURE "dba".sp820_contar_egresados;
CREATE PROCEDURE "dba".sp820_contar_egresados()
	Returning VARCHAR(5), VARCHAR(5), VARCHAR(4), VARCHAR(4), VARCHAR(10)
-- Descripcion de Return:
-- INT: 0 - OK
-- -1 - Error
-- VARCHAR(80): string con la descripcion del error
	
DEFINE aunidad_academica	LIKE sga_alumnos.unidad_academica;
DEFINE acarrera		LIKE sga_alumnos.carrera;
DEFINE alegajo		LIKE sga_alumnos.legajo;
DEFINE atitulo		LIKE sga_titulos.titulo;
DEFINE aanio_ingreso	LIKE sga_carrera_aspira.periodo_inscripcio;
DEFINE aanio_egreso	LIKE sga_carrera_aspira.periodo_inscripcio;


DEFINE sql_err, isam_err 	int;
DEFINE error_info		varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus		int;
DEFINE vcMsg		varchar(100);
DEFINE orientacion		varchar(10);
DEFINE plan		varchar(10);
DEFINE version		varchar(10);

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
	LET vcUserError	= '800401' ;
	LET iStatus	= -1; 
	LET vcMsg	=  vcUserError || ',' || sql_err || ' - ' || error_Info;
END EXCEPTION;

LET aunidad_academica = NULL;
LET acarrera  = NULL;
LET alegajo  = NULL;
LET atitulo  = NULL;
LET aanio_ingreso  = NULL;
LET aanio_egreso  = NULL;

LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = NULL;
LET orientacion = 0;
LET plan = NULL;
LET version = NULL;

delete from AUX_DW_EGRESADOS
where 1 = 1;

FOREACH WITH HOLD SELECT a.unidad_academica, a.carrera, a.legajo, tp.titulo
	INTO aunidad_academica, acarrera, alegajo, atitulo
FROM sga_alumnos a
JOIN sga_titulos_plan tp on a.carrera = tp.carrera and a.plan = tp.plan
	BEGIN
	EXECUTE PROCEDURE sp_titulo_aprobado(aunidad_academica, acarrera, alegajo, atitulo) Into orientacion, plan, version;
	if (orientacion is not null) then
		select ca.periodo_inscripcio into aanio_ingreso from sga_carrera_aspira ca
		join sga_alumnos a on ca.carrera = a.carrera and ca.nro_inscripcion = a.nro_inscripcion
		where a.carrera = acarrera and a.legajo = alegajo;
		select year(max(ha.fecha)) into aanio_egreso from vw_hist_academica ha
		where ha.carrera = acarrera and ha.legajo = alegajo and ha.resultado = 'A';
		insert into AUX_DW_EGRESADOS values (aunidad_academica, acarrera, aanio_ingreso, aanio_egreso, alegajo);
	end if;
	END
END FOREACH;

END PROCEDURE;
-- *************** FIN DEL PROCEDURE sp820_contar_egresados***************

{
execute procedure sp820_contar_egresados();

select * from AUX_DW_EGRESADOS
order by 2,3,4;

select * from vw_hist_academica
where legajo = '26756358-6'

unload to 'D:\wschulte\SIU-Guarani\Egresados.csv' delimiter '|'
select p.apellido, p.nombres, p.nro_documento, e.anio_ingreso, e.anio_egreso from AUX_DW_EGRESADOS e
join sga_alumnos a on e.carrera = a.carrera and e.legajo = a.legajo
join sga_personas p on a.nro_inscripcion = p.nro_inscripcion
where e.carrera = '003'

select p.apellido, p.nombres, p.nro_documento, e.anio_ingreso, e.anio_egreso from AUX_DW_EGRESADOS e


select * from sga_datos_censales

}
