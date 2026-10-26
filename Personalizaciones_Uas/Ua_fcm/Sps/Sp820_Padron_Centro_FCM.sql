CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_pad_centro') THEN
		DROP PROCEDURE sp820_pad_centro;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

 
-- execute procedure "dba".sp820_pad_centro('2019', '00001');
create procedure "dba".sp820_pad_centro(pAnio_academico Varchar(4), psede LIKE sga_alumnos.sede)

returning 	varchar(15), -- legajo
	varchar(30),  -- apellido
	varchar(30),  -- nombres
	varchar(15),  -- nro. de documento
	varchar (4), -- año academico
	varchar (255); -- sede

  DEFINE vlegajo varchar(15);
  DEFINE vsede varchar(255);
  DEFINE vaprobadas int;
  DEFINE vapellido, vnombres varchar(30);
  DEFINE vnro_documento varchar(15);
   --vars para el manejo de excepciones

   DEFINE sql_err	 			integer;
   DEFINE isam_err 				integer;
   DEFINE error_info				varchar(76);
   DEFINE vd_inicio varchar(10);
   DEFINE vd_fin varchar(10);

   ON EXCEPTION SET sql_err, isam_err, error_info                                        

      RAISE EXCEPTION  sql_err, isam_err, error_info;

   END EXCEPTION;     

BEGIN

LET vd_inicio =  '10/01/' || panio_academico-1;
LET vd_fin = '09/30/' || panio_academico;

	-- crea temporal con alumnos

	Select a.legajo, a.carrera

	from sga_alumnos a
		join vw_hist_academica vw
			on a.legajo = vw.legajo
			and a.carrera = vw.carrera
		
	where a.regular = 'S'
	and a.calidad = 'A'
	and a.carrera in ('1', '5')
	and a.plan in ('2006', '2016')
	and vw.fecha between vd_inicio and vd_fin -- 1/10/2007 al 30/09/2008
	and vw.resultado <> 'U'
	and (vw.forma_aprobacion IN ( "Examen", "Promoción", "Examen equivalente" ) and vw.materia not in (select materia from u820_cursos_ing))
	and vw.materia not in ('AIE01', 'AIE')

	Union

	Select a.legajo, a.carrera

	from  sga_alumnos a
		join sga_cursadas det
			on a.legajo = det.legajo
			and a.carrera = det.carrera
		
	where a.regular = 'S'
	and a.calidad = 'A'
	and a.carrera in ('1', '5')
	and a.plan in ('2006', '2016')
	and det.fecha_regularidad between vd_inicio and vd_fin -- 1/10/2007 al 30/09/2008
	and det.resultado in ('A', 'P', 'N')
	and det.materia not in ('AIE01', 'AIE')
	and det.materia not in (select materia from u820_cursos_ing)
	

	into temp temp_alumnos with no log;

	create index idx_temp_alu on temp_alumnos (legajo, carrera);

FOREACH SELECT distinct a.legajo, p.apellido, p.nombres, p.nro_documento, s.nombre

   INTO vlegajo, vapellido,vnombres, vnro_documento, vsede

     from temp_alumnos t

	join sga_alumnos a
		on t.legajo = a.legajo
		and t.carrera = a.carrera
	join sga_personas p
		on a.nro_inscripcion = p.nro_inscripcion
	join sga_sedes s
		on s.sede = a.sede

	where a.sede = psede

    order by p.apellido, p.nombres

return  vlegajo, vapellido, vnombres, vnro_documento, panio_academico, vsede  WITH RESUME; 

END FOREACH;

drop table temp_alumnos;

end;
end procedure;


-- commit;

-- execute procedure dba.sp820_pad_centro (2008);

-- ********************** FIN DEL PROCEDURE sp820_pad_centro **********************

revoke execute on "dba".sp820_pad_centro from public;
grant execute on "dba".sp820_pad_centro to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_pad_centro to internet; -- Rol de usuario de Internet
 

