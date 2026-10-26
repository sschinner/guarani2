-- *******************************************************************************
-- Controla si la persona tiene los datos actualizados para solicitar certificados pagos.
-- *******************************************************************************
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_val_cert_p') THEN
		DROP PROCEDURE ctr820_val_cert_p;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.9.2
--
-- Procedure ctr820_val_cert_p
-- U820
-- Controla que la persona tenga datos actualizados para solicitar certificados pagos.
-- **************************************************************************
-- drop procedure dba.ctr820_val_cert_p;
CREATE PROCEDURE dba.ctr820_val_cert_p( pCertifPedido  LIKE sga_certif_pedidos.certif_pedido)

RETURNING  smallint, 		-- status
           varchar(255);	-- <mensaje, parametros>


-- vars para la respuesta
DEFINE iStatus   smallint;       -- status
DEFINE vcMsg     varchar(255);   -- mensaje y parametros

-- vars para el manejo de excepciones
DEFINE sql_err      integer;
DEFINE isam_err     integer;
DEFINE error_info   varchar(76);
DEFINE vcUserError  varchar(10);

DEFINE vc_NroInscripcion   varchar(10);
DEFINE vc_UnidadAcademica   varchar(10);
DEFINE vc_mail  varchar(50);
DEFINE vc_recibe_mail  char(1);

DEFINE vcTituloSuperior varchar(255);
DEFINE vcTituloSecExt char(1);
DEFINE vcDescripcionTitSec varchar(255); 
DEFINE viTipoIngreso integer; 
DEFINE vcResolIngreso varchar(15); 
DEFINE vcResolucionNro varchar(15);
DEFINE vcPlanVersion varchar(5); 
DEFINE dResolucionFecha date;
DEFINE vc_Carrera varchar(255);
DEFINE vcDescripcionCarrera varchar(255);  
DEFINE vcLegajo varchar(15);
DEFINE vcPlan varchar(5);
DEFINE vcTipoTitulo char(1);
DEFINE vcTipoCarrera char(1);
DEFINE vcNroResConeau varchar(15);
DEFINE vcTitulo varchar(5);
DEFINE viCertificado integer;
DEFINE vc_nombre_tesina varchar(255);
DEFINE vc_loc_nac LIKE mug_localidades.nombre;

DEFINE vc_nacionalidad LIKE sga_personas.nacionalidad;

DEFINE vc_calle_per_lect LIKE sga_datos_censales.calle_per_lect;
DEFINE vc_numero_per_lect  LIKE sga_datos_censales.numero_per_lect;
DEFINE vc_loc_per_lect LIKE sga_datos_censales.loc_per_lect;
DEFINE vc_cp_per_lect LIKE sga_datos_censales.cp_per_lect;

DEFINE vc_calle_proc LIKE sga_datos_censales.calle_proc;
DEFINE vc_numero_proc LIKE sga_datos_censales.numero_proc;
DEFINE vc_loc_proc LIKE sga_datos_censales.loc_proc;
DEFINE vc_cp_proc LIKE sga_datos_censales.cp_proc;


   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_val_cert_p,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

-- seteo los valores default
LET iStatus = 1 ;
LET vcMsg = '' ;
LET vc_NroInscripcion    = NULL ;
LET vc_mail    = NULL ;
LET vc_recibe_mail    = NULL ;

LET vcTituloSuperior = NULL;
LET vcTituloSecExt = NULL;
LET vcDescripcionTitSec = NULL;
LET viTipoIngreso = NULL;
LET vc_UnidadAcademica = NULL;
LET vc_Carrera = NULL;
LET vcDescripcionCarrera = NULL;
LET vcTipoTitulo = NULL;
LET vcTipoCarrera = NULL;
LET vcNroResConeau = NULL;
LET vcTitulo = NULL;
LET viCertificado = NULL;
LET vcResolucionNro = NULL;
LET vc_nombre_tesina = NULL;
LET vc_loc_nac = NULL;

LET vc_nacionalidad = NULL;

LET vc_calle_per_lect = NULL;
LET vc_numero_per_lect = NULL;
LET vc_loc_per_lect  = NULL;
LET vc_cp_per_lect  = NULL;

LET vc_calle_proc = NULL;
LET vc_numero_proc = NULL;
LET vc_loc_proc = NULL;
LET vc_cp_proc = NULL;

-- Obtener el nro. de inscripción de la persona
SELECT nro_inscripcion, unidad_academica INTO vc_NroInscripcion, vc_UnidadAcademica
FROM sga_certif_pedidos
WHERE certif_pedido = pCertifPedido;

-- Control de requisitos digitalizados en caso de ser solicitud de título
SELECT certificado INTO viCertificado FROM sga_certif_pedidos where certif_pedido = pCertifPedido;

IF viCertificado = 102 THEN
-- Obtener la carrera del alumno por pedido  y no por argumentos
	SELECT trim(dip.carrera), tit.legajo, tit.plan, tt.tipo_de_titulo, trim(car.nombre), car.tipo_de_carrera, tt.nro_res_coneau, tit.titulo, ste.titulo  INTO vc_Carrera, vcLegajo, vcPlan, vcTipoTitulo, vcDescripcionCarrera, vcTipoCarrera, vcNroResConeau, vcTitulo, vc_nombre_tesina
	FROM sga_certif_pedidos ped
		join u820_pedidos_certif_diploma dip
			on  dip.id_certif_pedido = ped.certif_pedido
		join sga_titulos_otorg tit
			on ped.unidad_academica = tit.unidad_academica
				and ped.nro_inscripcion = tit.nro_inscripcion
		join sga_titulos tt
			on tit.titulo = tt.titulo
		join sga_carreras car
			on tit.carrera = car.carrera
		JOIN sga_tipos_carrera stc ON stc.tipo_de_carrera = car.tipo_de_carrera

		LEFT JOIN sga_tesis_alumnos sta ON sta.carrera = tit.carrera AND sta.legajo = tit.legajo AND stc.tipo_de_carrera IN ('P', 'S')
		LEFT JOIN sga_tesis ste ON ste.tesis = sta.tesis
		
	WHERE ped.certif_pedido = pCertifPedido
		and dip.titulo = tit.titulo;

ELSE

-- Obtener la carrera del alumno por medio de los argumentos del certificado
	SELECT trim(tit.carrera), tit.legajo, tit.plan, tt.tipo_de_titulo, trim(car.nombre), car.tipo_de_carrera, tt.nro_res_coneau, tit.titulo  INTO vc_Carrera, vcLegajo, vcPlan, vcTipoTitulo, vcDescripcionCarrera, vcTipoCarrera, vcNroResConeau, vcTitulo
	FROM sga_certif_pedidos ped
		join sga_cert_ped_argum arg
			on ped.certif_pedido = arg.certif_pedido
		join sga_titulos_otorg tit
			on ped.unidad_academica = tit.unidad_academica
				and ped.nro_inscripcion = tit.nro_inscripcion
		join sga_titulos tt
			on tit.titulo = tt.titulo
		join sga_carreras car
			on tit.carrera = car.carrera
		
	WHERE ped.certif_pedido = pCertifPedido
		AND arg.orden = 3
		AND trim(tit.titulo) = trim(arg.argumento);

END IF;

-- Obtener el tipo de ingreso del alumno
SELECT car.resolucion_ingreso,
	car.tipo_ingreso
INTO vcResolIngreso,
	viTipoIngreso
FROM sga_personas per
	join sga_carrera_aspira car
	on per.unidad_academica = car.unidad_academica
		and per.nro_inscripcion = car.nro_inscripcion

WHERE per.unidad_academica = vc_UnidadAcademica
	AND per.nro_inscripcion = vc_NroInscripcion
	AND car.carrera = vc_Carrera
	AND car.situacion_asp in ('IL', 'IC');

-- Control de mail
SELECT trim(gda.e_mail), trim(gda.recibe_mail) INTO vc_mail, vc_recibe_mail
FROM sga_personas alu
	join gda_anun_conf_pers gda
	on alu.unidad_academica = gda.unidad_academica
	and alu.nro_inscripcion = gda.nro_inscripcion
WHERE alu.unidad_academica = vc_UnidadAcademica
	AND alu.nro_inscripcion  = vc_NroInscripcion;

IF (vc_mail IS NULL OR vc_recibe_mail = 'N') THEN
	LET iStatus = -1 ;
	LET vcMsg = 'email y/o recepción; ';

END IF;

-- Control de localidad de nacimiento y Nacionalidad
SELECT lloc.nombre, alu.nacionalidad INTO vc_loc_nac, vc_nacionalidad
FROM sga_personas alu
	left join mug_localidades lloc on alu.loc_nacimiento = lloc.localidad

WHERE alu.unidad_academica = vc_UnidadAcademica
	AND alu.nro_inscripcion= vc_NroInscripcion;

IF (vc_loc_nac IS NULL OR vc_loc_nac =  'Indeterminado') THEN
	LET iStatus = -1 ;
	LET vcMsg = 'No tiene localidad de Nacimiento; ';
END IF;

IF (vc_nacionalidad IS NULL) THEN
	LET iStatus = -1 ;
	LET vcMsg = 'No tiene Nacionalidad; ';

END IF;

-- Control de datos del Período Lectivo y Procedencia (este últmo para SIDCER)
SELECT calle_per_lect,
               numero_per_lect,
               loc_per_lect,
               cp_per_lect,
	calle_proc,
               numero_proc,
               loc_proc,
               cp_proc
INTO vc_calle_per_lect, vc_numero_per_lect, vc_loc_per_lect, vc_cp_per_lect, vc_calle_proc, vc_numero_proc, vc_loc_proc, vc_cp_proc
FROM  sga_datos_censales
WHERE sga_datos_censales.unidad_academica = vc_UnidadAcademica
            AND sga_datos_censales.nro_inscripcion        = vc_NroInscripcion
            AND sga_datos_censales.fecha_relevamiento    = ( SELECT MAX(a.fecha_relevamiento)
                                                            FROM     sga_datos_censales  as a
                                                            WHERE     a.unidad_academica = vc_UnidadAcademica
								 AND     a.nro_inscripcion  = vc_NroInscripcion);

IF trim(vc_calle_per_lect) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Calle de última residencia no puede estar vacío. ';
END IF;
IF trim(vc_numero_per_lect) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Número de calle de última residencia no puede estar vacío. ';
END IF;
IF vc_loc_per_lect IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Localidad de última residencia no puede estar vacío. ';
END IF;
IF trim(vc_cp_per_lect) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Código postal de última residencia no puede estar vacío. ';
END IF;

IF trim(vc_calle_proc) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Calle de procedencia no puede estar vacío. ';
END IF;
IF trim(vc_numero_proc) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Número de calle de procedencia no puede estar vacío. ';
END IF;
IF vc_loc_proc IS NULL THEN
    LET iStatus  = -1 ;
    LET vcMsg = vcMsg || 'Localidad de procedencia no puede estar vacío. ';
END IF;
IF trim(vc_cp_proc) IS NULL THEN
    LET iStatus = -1 ;
    LET vcMsg = vcMsg || 'Código postal de procedencia no puede estar vacío. ';
END IF;

-- Control de requisitos digitalizados en caso de ser solicitud de título
IF viCertificado = 102 THEN

	IF NOT EXISTS (SELECT '*' FROM sga_certif_pedidos certif
				join u820_pedidos_certif_diploma u820
				on certif.certif_pedido = u820.id_certif_pedido
			WHERE certif.certif_pedido = pCertifPedido
				and u820.requisitos_validados = 'S') THEN
		LET iStatus = -1 ;
		LET vcMsg = 'No tiene los requisitos para Solicitud de Título Digitalizados; ' || vcMsg;

	END IF;
END IF;

-- Obtener el colegio secundarios
SELECT 	case pro.pais when 54 then 'N' else 'S' end as extranjero
INTO vcTituloSecExt
FROM sga_personas per
	join sga_coleg_sec col
		on per.colegio_secundario = col.colegio
	join  mug_localidades l
		on l.localidad = col.localidad
	join mug_dptos_partidos dpto
	  	on l.dpto_partido = dpto.dpto_partido
	join mug_provincias pro
		on dpto.provincia = pro.provincia

WHERE per.unidad_academica = vc_UnidadAcademica
	AND per.nro_inscripcion = vc_NroInscripcion;


-- Obtener el titulo secundario
SELECT tsec.descripcion
INTO vcDescripcionTitSec
FROM sga_personas per
	join sga_titulos_sec tsec
		on per.titulo_secundario = tsec.titulo_secundario
WHERE per.unidad_academica = vc_UnidadAcademica
	AND per.nro_inscripcion = vc_NroInscripcion;

IF (viTipoIngreso <> 3 OR viTipoIngreso IS NULL) THEN -- INGRESO ARTICULO 7 Y 39BIS ESTAN EXCEPTUADOS DEL CONTROL DE COLEGIO SECUNDARIO

	IF vcTipoCarrera NOT IN ('P', 'S', 'W') THEN

		-- Control de Colegio Secundario (exterior o nacional se debe completar)
		IF (vcTituloSecExt IS NULL) THEN
			LET iStatus = -1 ;
			LET vcMsg = 'colegio secundario; ' || vcMsg;

		END IF;

		-- Control de tipo de ingreso (Con titulo secundario, etc..) y resolución de tipo de ingreso
		IF (vcTituloSecExt = 'S') THEN

			IF viTipoIngreso <> 1 THEN

				-- Control de Título Secundario
					IF (vcDescripcionTitSec IS NULL) THEN
						LET iStatus = -1 ;
						LET vcMsg = 'título secundario; ' || vcMsg;

					END IF;
					IF  (viTipoIngreso IN (9,10)) THEN
						IF (vcResolIngreso  IS NULL) THEN
							LET iStatus = -1;
							LET vcMsg = 'resolución del tipo de ingreso; ' || vcMsg;

						END IF;
					ELSE
						LET iStatus = -1 ;
						LET vcMsg = 'tipo de ingreso no corresponde según colegio secundario extranjero; ' || vcMsg;

					END IF;
			ELSE
				IF (vcDescripcionTitSec IS NULL) THEN
					LET iStatus = -1 ;
					LET vcMsg = 'título secundario; ' || vcMsg;

				END IF;
			END IF;

		ELSE
			IF  (viTipoIngreso IN (9,10)) THEN
				LET iStatus = -1;
				LET vcMsg = 'tipo de ingreso según colegio secundario argentino; ' || vcMsg;

			END IF;
		END IF;

	END IF; -- INGRESO POSGRADOS

END IF; -- INGRESO ARTICULO 7 Y 39BIS

-- Control de Resolución Ministerial del Plan.
-- En caso que esta no exista, colocar la Acreditación de la CONEAU

SELECT sga_planes.fecha_resolucion,
	sga_planes.nro_resolucion,
	sga_planes.version_actual
INTO dResolucionFecha,
	vcResolucionNro,
	vcPlanVersion
FROM sga_planes
WHERE sga_planes.unidad_academica = vc_UnidadAcademica
	AND sga_planes.carrera = vc_Carrera
	AND sga_planes.plan = vcPlan;

-- Caso particular FCJS: titulo intermedio y final de la carrera 1 con resoluciones ME diferentes.
IF (vc_UnidadAcademica = 'FCJS' AND vc_Carrera = '1' AND vcPlan IN ('2000') AND vcTitulo = 'PROIN') THEN
	LET vcResolucionNro = 'ME-2309/17';
-- Caso particular FICH: titulo intermedio Analista en Informatica Aplicada de la carrera Ing. Informatica (plan 2006).
ELIF (vc_UnidadAcademica = 'FICH' AND vc_Carrera = '03' AND vcPlan IN ('2006') AND vcTitulo = '07') THEN
	LET vcResolucionNro = 'ME-901/19';
END IF;


IF (vcResolucionNro IS NULL OR (vcResolucionNro NOT LIKE 'CS-%' AND vcResolucionNro NOT LIKE 'ME-%' AND vcResolucionNro  NOT LIKE 'DI-%' AND vcResolucionNro NOT LIKE 'SR')) THEN
	LET iStatus = -1 ;
	LET vcMsg = 'resolución Ministerial del plan de estudios; ' || vcMsg;

END IF;

-- Control de titulo superior, en caso que sea egresado de Posgrados o Ciclos
-- para el caso de Ciclos verifico por tipo de carrera (W)

IF vcTipoCarrera IN ('P', 'S') THEN
	SELECT super.nombre
	INTO vcTituloSuperior	
	FROM sga_personas per
		join sga_formacion_acad acad
		on per.unidad_academica = acad.unidad_academica
			and per.nro_inscripcion = acad.nro_inscripcion
		join sga_titulos_super super
		on acad.titulo_superior = super.titulo_superior

	WHERE per.unidad_academica = vc_UnidadAcademica
		AND per.nro_inscripcion = vc_NroInscripcion
		AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
					from  sga_formacion_acad acad1
					where acad1.unidad_academica = vc_UnidadAcademica
						and acad1.nro_inscripcion = vc_NroInscripcion);
	IF (vcTituloSuperior IS NULL) THEN
		LET iStatus = -1 ;
		LET vcMsg = 'título de Grado obtenido; ' || vcMsg;

	END IF;

	IF (viCertificado = 102 and vc_nombre_tesina IS NULL) THEN
		LET iStatus = -1 ;
		LET vcMsg = 'título de Tesis/Tesina; ' || vcMsg;

	END IF;


ELSE
	IF vcTipoCarrera = 'W' THEN
			SELECT acad.alu_otestsup_carr
			INTO vcTituloSuperior	
			FROM sga_personas per
			join sga_datos_cen_aux2 acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 
					from  sga_datos_cen_aux2 acad1
					where acad1.unidad_academica = vc_UnidadAcademica
						and acad1.nro_inscripcion = vc_NroInscripcion)
			WHERE per.unidad_academica = vc_UnidadAcademica
				AND per.nro_inscripcion = vc_NroInscripcion;

		IF (vcTituloSuperior IS NULL) THEN
			LET iStatus = -1 ;
			LET vcMsg = 'título Terciario (Para Ciclos) obtenido; ' || vcMsg;

		END IF;
	END IF;
END IF;

IF iStatus = -1 THEN
	LET vcMsg = 'Completar/Corregir: ' || vcMsg;
ELSE
	LET vcMsg = '800320';
END IF;

RETURN iStatus, vcMsg;

END;

END PROCEDURE;
-- ********************** Fin del procedure ctr820_val_cert_p **********************
revoke execute on "dba".ctr820_val_cert_p from public;
grant execute on "dba".ctr820_val_cert_p to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_val_cert_p to internet; -- Rol de usuario de Internet

-- execute procedure ctr820_val_cert_p(69928);
-- EXECUTE PROCEDURE "dba".sp820_datos_tramite_diploma_digital(187); --1
