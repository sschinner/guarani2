CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_dat_cen_hefe') THEN
		DROP PROCEDURE web_serv_dat_cen_hefe;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- Par?metros de WS: usuario guaran?;
-- Criterios: se asume que es un usuario autenticado


CREATE PROCEDURE "dba".web_serv_dat_cen_hefe(pusuario varchar(20))
RETURNING integer, -- 0) codigo retorno
integer, --1) Tipo de documento
varchar(20), --2)  N?mero de documento
date, --3) Fecha de nacimiento
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
varchar(10); --19) Compania Celular

DEFINE vi_codigo_ret integer;
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


LET vi_codigo_ret = 0;
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


SELECT per.tipo_documento, per.nro_documento, per.fecha_nacimiento, per.apellido, per.nombres, per.sexo, dat.loc_proc, dat.cp_proc, dat.loc_per_lect, dat.cp_per_lect, dat.calle_per_lect, dat.numero_per_lect, dat.piso_per_lect, dat.dpto_per_lect, dat.unidad_per_lect, dat.te_per_lect, dat.e_mail, xdat.celular_numero, xdat.celular_compania

 INTO  vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail, vc_n_cel, vc_c_cel 
FROM aca_usuarios_ag ag
	join sga_personas per
		on ag.nro_inscripcion = per.nro_inscripcion
	join sga_datos_censales dat
		on per.nro_inscripcion = dat.nro_inscripcion
	left join sga_datos_cen_aux xdat
		on per.nro_inscripcion = xdat.nro_inscripcion and dat.fecha_relevamiento = xdat.fecha_relevamiento
WHERE  ag.identificacion = pusuario
AND dat.fecha_relevamiento = (select max(fecha_relevamiento) 
			from sga_datos_censales
			where sga_datos_censales.nro_inscripcion = per.nro_inscripcion);



IF vi_tipo_doc is not null THEN 
	LET vi_codigo_ret = 1;
		
END IF;



RETURN vi_codigo_ret, vi_tipo_doc, vc_nro_doc, vd_fecha_nac, vc_apellido, vc_nombre, vc_sexo, vi_loc_proc, vc_cp_proc, vi_loc_per_lect, vc_cp_per_lect , vc_calle_per_lect , vc_nro , vc_piso , vc_dpto , vc_unidad , vc_te_per_lect , vc_e_mail,vc_n_cel, vc_c_cel ;

END PROCEDURE;

-- Casos de prueba
{
select * from aca_usuarios_ag tipo_usuario = 'DOC';
select * from sga_carrera_aspira where situacion_asp = 'AC';
select * from sga_personas where nro_inscripcion = 'FICH-7193';

Casos:
-- Usuario Autenticado
EXECUTE PROCEDURE "dba".web_serv_dat_cen_hefe("30339240"); --1

-- Usuario No autenticado por identificacion
EXECUTE PROCEDURE "dba".web_serv_dat_cen_hefe("30339250"); --0

} 
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_cen_hefe 
-- *****************************************************************************
revoke execute on "dba".web_serv_dat_cen_hefe from public;
grant execute on "dba".web_serv_dat_cen_hefe to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_dat_cen_hefe to internet; -- Rol de usuario de Internet
