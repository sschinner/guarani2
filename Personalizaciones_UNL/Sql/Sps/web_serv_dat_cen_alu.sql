



CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

	IF EXISTS (SELECT procid

			FROM sysprocedures

			WHERE procname = 'web_serv_dat_cen_alu') THEN

		DROP PROCEDURE web_serv_dat_cen_alu;

	END IF;		

END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();





-- Par?metros de WS: usuario guaran?;

-- Criterios: se asume que es un usuario autenticado






--  EXECUTE PROCEDURE web_serv_dat_cen_alu('usuario' ,23929955,'0',54); --1
--  EXECUTE PROCEDURE web_serv_dat_cen_alu('carrera' ,'03','0',54); --1
--  EXECUTE PROCEDURE web_serv_dat_cen_alu('ingreso' ,2018,'0',54); --1
--  EXECUTE PROCEDURE web_serv_dat_cen_alu('reinscripcion' ,2018,'0',54); --1
--  EXECUTE PROCEDURE web_serv_dat_cen_alu('documento' ,23929955,'0',54); --1



CREATE PROCEDURE web_serv_dat_cen_alu(pfiltro varchar(20),pvalor1 varchar(10), pvalor2 varchar(10), pvalor3 integer)



RETURNING integer, -- 0) codigo retorno



integer, --1) Tipo de documento



varchar(20), --2)  N?mero de documento



date, --3) Fecha denacimiento



varchar(30), --4) Apellido



varchar(30), --5) Nombres



char(1), --6) Sexo



integer, --7) Localidad de residencia del grupo familiar



varchar(15), --8) cp residencia del grupo familiar



integer, --9) Localidad de residencia del estudiante



varchar(15), --10) cp residencia del estudiante



varchar(50), --11) Direcci?n de residencia del estudiante



varchar(5), --12) Nro



varchar(3), -- 13) Piso



varchar(5), -- 14) Dpto



varchar(3), -- 15) Unidad



char(18), --16) Tel?fono del estudiante



varchar(50), --17) Direcci?n de correo electr?nico



varchar(25), --18) Nro Celular



varchar(10), --19) Compania Celular



integer, -- pasi doc


integer, --vc_prov_lect 

integer, --vc_pais_lect 

 integer, --vc_prov_proc 

 integer, --vc_pais_proc 

 varchar(50),--vc_te_proc 

 varchar(100), --vc_calle_proc 

 varchar(6),  --vc_numero_proc 

-- date, --vc_fecha_venc 

varchar(150); --20) Mensaje retorno

  



DEFINE vi_codigo_ret integer;

DEFINE vc_mje_ret varchar(150);

DEFINE vi_tipo_doc integer;

DEFINE vc_nro_doc varchar(20);

DEFINE vd_fecha_nac date;

DEFINE vc_apellido varchar(30); 

DEFINE vc_nombre varchar(30); 

DEFINE vc_sexo char(1);

DEFINE vi_loc_proc integer;

DEFINE vc_cp_proc varchar(15); 

DEFINE vi_loc_per_lect integer;

DEFINE vc_cp_per_lect varchar(15); 

DEFINE vc_calle_per_lect varchar(50); 

DEFINE vc_nro varchar(5); 

DEFINE vc_piso varchar(3); 

DEFINE vc_dpto varchar(5); 

DEFINE vc_unidad varchar(3);

DEFINE vc_te_per_lect char(18);

DEFINE vc_e_mail varchar(50); 

DEFINE vc_n_cel varchar(25);

DEFINE vc_c_cel varchar(10);

DEFINE vi_pais_doc integer;

DEFINE  vc_prov_lect integer;

DEFINE  vc_pais_lect integer;

DEFINE  vc_prov_proc integer;

DEFINE  vc_pais_proc integer;

DEFINE  vc_te_proc varchar(50);

DEFINE  vc_calle_proc varchar(100);

DEFINE  vc_numero_proc varchar(6);

--DEFINE  vc_fecha_venc date;






LET vi_codigo_ret = 0;



LET vc_mje_ret = 'OK - Datos Censales';



LET vi_tipo_doc = NULL;



LET vc_nro_doc = NULL;



LET vd_fecha_nac = NULL;



LET vc_apellido = NULL;



LET vc_nombre = NULL;



LET vc_sexo = NULL;



LET vi_loc_proc = NULL;



LET vc_cp_proc = NULL;



LET vi_loc_per_lect = NULL;



LET vc_cp_per_lect = NULL;



LET vc_calle_per_lect = NULL;



LET vc_nro = NULL;



LET vc_piso = NULL;



LET vc_dpto = NULL;



LET vc_unidad = NULL;



LET vc_te_per_lect = NULL;



LET vc_e_mail = NULL;



LET vc_n_cel = NULL;



LET vc_c_cel = NULL;



LET vi_pais_doc = NULL;


LET vc_prov_lect = NULL;

LET vc_pais_lect = NULL;

LET vc_prov_proc  = NULL;

LET vc_pais_proc = NULL;

LET vc_te_proc = NULL;

LET vc_calle_proc = NULL;

LET vc_numero_proc = NULL;

--LET vc_fecha_venc = NULL;






IF (pfiltro = 'usuario' ) THEN	



	SELECT per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo,   dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania, per.pais_documento , pro.provincia as provincia_per_lect, pro.pais as pais_per_lect, pro2.provincia  as provincia_proc, pro2.pais as pais_proc, dat.te_proc, dat.calle_proc, dat.numero_proc

		INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel, vi_pais_doc ,vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc


	FROM aca_usuarios_ag ag

		join sga_personas per

			on ag.nro_inscripcion = per.nro_inscripcion

		left join sga_datos_censales dat

			ON (per.nro_inscripcion = dat.nro_inscripcion AND dat.fecha_relevamiento = (select max(fecha_relevamiento) from sga_datos_censales where sga_datos_censales.nro_inscripcion = per.nro_inscripcion))

		left join sga_datos_cen_aux xdat

			on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento
			
				
		left join mug_localidades ml
			on (ml.localidad = dat.loc_per_lect)
		left join mug_dptos_partidos dpto

		  	ON (ml.dpto_partido = dpto.dpto_partido)

		left join mug_provincias pro

			  ON (dpto.provincia = pro.provincia)
		
		left join mug_localidades ml2
			on (ml2.localidad = dat.loc_proc)
		left join mug_dptos_partidos dpto2

		  	ON (ml2.dpto_partido = dpto2.dpto_partido)

		left join mug_provincias pro2

			  ON (dpto2.provincia = pro2.provincia)

	WHERE  ag.identificacion = pvalor1;

	



	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret = -1;

		LET vc_mje_ret = 'No hay datos - Usuario ' || pvalor1 || ' inexistente';

	END IF;



ELIF  (pfiltro = 'carrera'  ) THEN



FOREACH 



	SELECT unique per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo,   dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania, per.pais_documento, pro.provincia as provincia_per_lect, pro.pais as pais_per_lect, pro2.provincia  as provincia_proc, pro2.pais as pais_proc, dat.te_proc, dat.calle_proc, dat.numero_proc

		INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel, vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc


	FROM sga_personas per

		join sga_carrera_aspira car

			on car.nro_inscripcion = per.nro_inscripcion

		left join sga_datos_censales dat

			ON (per.nro_inscripcion = dat.nro_inscripcion AND dat.fecha_relevamiento = (select max(fecha_relevamiento) from sga_datos_censales where sga_datos_censales.nro_inscripcion = per.nro_inscripcion))

		left join sga_datos_cen_aux xdat

			on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento
		
		left join mug_localidades ml
			on (ml.localidad = dat.loc_per_lect)
		left join mug_dptos_partidos dpto

		  	ON (ml.dpto_partido = dpto.dpto_partido)

		left join mug_provincias pro

			  ON (dpto.provincia = pro.provincia)
		
		left join mug_localidades ml2
			on (ml2.localidad = dat.loc_proc)
		left join mug_dptos_partidos dpto2

		  	ON (ml2.dpto_partido = dpto2.dpto_partido)

		left join mug_provincias pro2

			  ON (dpto2.provincia = pro2.provincia)

	WHERE  car.carrera = pvalor1

	



	RETURN vi_codigo_ret, vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail,vc_n_cel, vc_c_cel, vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc,  vc_mje_ret  WITH RESUME; 



END FOREACH ;



	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret = -1;

		LET vc_mje_ret = 'No hay datos - Carrera ' || pvalor1 || ' inexistente';

	END IF;



ELIF  ( pfiltro  = 'ingreso' ) THEN



FOREACH 

	SELECT unique per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo,   dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania, per.pais_documento , pro.provincia as provincia_per_lect, pro.pais as pais_per_lect, pro2.provincia  as provincia_proc, pro2.pais as pais_proc, dat.te_proc, dat.calle_proc, dat.numero_proc

		INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso, vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel , vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc

	FROM sga_personas per

		join sga_carrera_aspira car

			on car.nro_inscripcion = per.nro_inscripcion

		join sga_periodo_insc pi

			on car.periodo_inscripcio = pi.periodo_inscripcio
		
		left join sga_datos_censales dat

			ON (per.nro_inscripcion = dat.nro_inscripcion AND dat.fecha_relevamiento = (select max(fecha_relevamiento) from sga_datos_censales where sga_datos_censales.nro_inscripcion = per.nro_inscripcion))

		left join sga_datos_cen_aux xdat

			on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento

		left join mug_localidades ml
			on (ml.localidad = dat.loc_per_lect)
		left join mug_dptos_partidos dpto

		  	ON (ml.dpto_partido = dpto.dpto_partido)

		left join mug_provincias pro

			  ON (dpto.provincia = pro.provincia)
		
		left join mug_localidades ml2
			on (ml2.localidad = dat.loc_proc)
		left join mug_dptos_partidos dpto2

		  	ON (ml2.dpto_partido = dpto2.dpto_partido)

		left join mug_provincias pro2

			  ON (dpto2.provincia = pro2.provincia)

	WHERE  pi.anio_academico = pvalor1

	

RETURN vi_codigo_ret, vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail,vc_n_cel, vc_c_cel, vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc, vc_mje_ret   WITH RESUME; 



END FOREACH ;



	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret = -1;

		LET vc_mje_ret = 'No hay datos - Ingreso ' || pvalor1 || ' inexistente';

	END IF;



ELIF ( pfiltro  = 'reinscripcion' ) THEN



FOREACH 



	SELECT unique per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo,   dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania, per.pais_documento , pro.provincia as provincia_per_lect, pro.pais as pais_per_lect, pro2.provincia  as provincia_proc, pro2.pais as pais_proc, dat.te_proc, dat.calle_proc, dat.numero_proc

		INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel , vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc

	FROM  sga_personas per

		join sga_carrera_aspira car

			on car.nro_inscripcion = per.nro_inscripcion

		join sga_alumnos alu

			on alu.nro_inscripcion = per.nro_inscripcion

		join sga_periodo_insc pi

			on car.periodo_inscripcio = pi.periodo_inscripcio

		join sga_reinscripcion r

			on alu.legajo = r.legajo 

		left join sga_datos_censales dat

			ON (per.nro_inscripcion = dat.nro_inscripcion AND dat.fecha_relevamiento = (select max(fecha_relevamiento) from sga_datos_censales where sga_datos_censales.nro_inscripcion = per.nro_inscripcion))

		left join sga_datos_cen_aux xdat

			on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento

		left join mug_localidades ml
			on (ml.localidad = dat.loc_per_lect)
		left join mug_dptos_partidos dpto

		  	ON (ml.dpto_partido = dpto.dpto_partido)

		left join mug_provincias pro

			  ON (dpto.provincia = pro.provincia)
		
		left join mug_localidades ml2
			on (ml2.localidad = dat.loc_proc)
		left join mug_dptos_partidos dpto2

		  	ON (ml2.dpto_partido = dpto2.dpto_partido)

		left join mug_provincias pro2

			  ON (dpto2.provincia = pro2.provincia)



	WHERE  r.anio_academico = pvalor1

	



	RETURN vi_codigo_ret ,vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail,vc_n_cel, vc_c_cel , vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc, vc_mje_ret  WITH RESUME; 



END FOREACH ;



	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret = -1;

		LET vc_mje_ret = 'No hay datos - Año reinscripcion ' || pvalor1 || ' inexistente';

	END IF;



ELIF ( pfiltro  = 'documento' ) THEN

	SELECT per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo,   dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania, per.pais_documento , pro.provincia as provincia_per_lect, pro.pais as pais_per_lect, pro2.provincia  as provincia_proc, pro2.pais as pais_proc, dat.te_proc, dat.calle_proc, dat.numero_proc

		INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel, vi_pais_doc ,vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc

	FROM sga_personas per

		left join sga_datos_censales dat

			ON (per.nro_inscripcion = dat.nro_inscripcion AND dat.fecha_relevamiento = (select max(fecha_relevamiento) from sga_datos_censales where sga_datos_censales.nro_inscripcion = per.nro_inscripcion))

		left join sga_datos_cen_aux xdat

			on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento

		left join mug_localidades ml
			on (ml.localidad = dat.loc_per_lect)
		left join mug_dptos_partidos dpto

		  	ON (ml.dpto_partido = dpto.dpto_partido)

		left join mug_provincias pro

			  ON (dpto.provincia = pro.provincia)
		
		left join mug_localidades ml2
			on (ml2.localidad = dat.loc_proc)
		left join mug_dptos_partidos dpto2

		  	ON (ml2.dpto_partido = dpto2.dpto_partido)

		left join mug_provincias pro2

			  ON (dpto2.provincia = pro2.provincia)

	WHERE  per.tipo_documento = pvalor2

	AND per.nro_documento = pvalor1

	AND per.pais_documento = pvalor3;



	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret = -1;

		LET vc_mje_ret = 'No hay datos - Tipo documento ' || pvalor2 || ', Pais documento ' || pvalor3 || ' y Nro documento ' || pvalor1 || ' inexistente';

	END IF;



ELSE

	

	IF vi_tipo_doc is null THEN 

		LET vi_codigo_ret= -2;

		LET vc_mje_ret = 'El filtro indicado "' || pfiltro || '" no se reconoce - Valores posibles: carrera, usuario, documento, ingreso y reinscripcion ';

	END IF;



END IF;



RETURN vi_codigo_ret, vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail,vc_n_cel, vc_c_cel, vi_pais_doc, vc_prov_lect, vc_pais_lect, vc_prov_proc, vc_pais_proc, vc_te_proc, vc_calle_proc, vc_numero_proc, vc_mje_ret   WITH RESUME; 



END PROCEDURE;


