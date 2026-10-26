CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_datos_tramite_diploma_digital') THEN
		DROP PROCEDURE sp820_datos_tramite_diploma_digital;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".sp820_datos_tramite_diploma_digital(p_solicitud int)
RETURNING 
	int,
	varchar(255),
	varchar(255),
	varchar(255),	
	varchar(255), 	
	int,
	int,
	varchar(255),
	varchar(255),
	varchar(5),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255), 	
	varchar(255),
	varchar(255),
	varchar(255),
	int,
	varchar(5),
	varchar(1),
	varchar(1),
	varchar(255),
	varchar(1),
	varchar(1),
	varchar(20);

DEFINE vc_apellido					varchar(255);
DEFINE vc_nombres					varchar(255);
DEFINE vc_sexo						varchar(255);	
DEFINE vc_fecha_nacimiento			varchar(255); 	
DEFINE vc_cod_pais_dni				int;
DEFINE vc_tipo_doc					int;
DEFINE vc_tipo_doc_descripcion  	varchar(255);
DEFINE vc_nro_documento				varchar(255);
DEFINE vc_carrera					varchar(5);
DEFINE vc_nombre_carrera			varchar(255);
DEFINE vc_tipo_de_carrera			varchar(255);
DEFINE vc_localidad_nacimiento		varchar(255);
DEFINE vc_provincia_nacimiento		varchar(255);
DEFINE vc_pais_nacimiento			varchar(255);
DEFINE vc_expediente				varchar(255);
DEFINE vc_diploma_impreso			varchar(255);
DEFINE vc_autorizante_retiro		varchar(255);
DEFINE vc_url_foto					varchar(255);
DEFINE vc_fecha_egreso				varchar(255); 	
DEFINE vc_resolucion_ministerial	varchar(255);
DEFINE vc_nombre_titulo				varchar(255);
DEFINE vc_nombre_tesina				varchar(255);
DEFINE vc_certif_pedido				int;
DEFINE vc_codigo_titulo				varchar(5);
DEFINE vc_es_titulo_intermedio				varchar(1);
DEFINE vc_es_extranjero				varchar(1);
DEFINE vc_nro_inscripcion				varchar(255);
DEFINE vc_codigo_tipo_car				varchar(1);
DEFINE vcTituloSuperior				varchar(255);
DEFINE EsColSecExtranjero				varchar(1);
DEFINE vc_tipo_tramite				varchar(1);
DEFINE vc_path_nuxeo				varchar(20);

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			varchar(10);
DEFINE vcMsg			varchar(100);

-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
     RETURN iStatus, vc_apellido, vc_nombres, vc_sexo, vc_fecha_nacimiento, vc_cod_pais_dni, 
	vc_tipo_doc, vc_tipo_doc_descripcion, vc_nro_documento, vc_carrera, vc_nombre_carrera,
	vc_tipo_de_carrera, vc_localidad_nacimiento, vc_provincia_nacimiento,
	vc_pais_nacimiento, vc_expediente, vc_diploma_impreso, vc_autorizante_retiro,
	vc_url_foto, vc_fecha_egreso, vc_resolucion_ministerial, vc_nombre_titulo, 
	vc_nombre_tesina, vc_certif_pedido, vc_codigo_titulo, vc_es_titulo_intermedio, vc_es_extranjero, vcTituloSuperior, EsColSecExtranjero, vc_tipo_tramite, vc_path_nuxeo;
END EXCEPTION;

BEGIN

LET iStatus = 0;
LET vc_apellido = null;
LET vc_nombres = null;
LET vc_sexo = null;
LET vc_fecha_nacimiento = null;
LET vc_cod_pais_dni = null;
LET vc_tipo_doc = null;
LET vc_tipo_doc_descripcion = null;
LET vc_nro_documento = null;
LET vc_carrera = null;
LET vc_nombre_carrera = null;
LET vc_tipo_de_carrera = null;
LET vc_localidad_nacimiento = null;
LET vc_provincia_nacimiento	 = null;
LET vc_pais_nacimiento = null;
LET vc_expediente = null;
LET vc_diploma_impreso = null;
LET vc_autorizante_retiro = null;
LET vc_url_foto = null;
LET vc_fecha_egreso = null;
LET vc_resolucion_ministerial = null;
LET vc_nombre_titulo = null;
LET vc_nombre_tesina = null;
LET vc_certif_pedido = null;
LET vc_codigo_titulo = null;
LET vc_es_titulo_intermedio = null;
LET vc_nro_inscripcion = null;
LET vc_codigo_tipo_car = null;
LET vcTituloSuperior = null;
LET EsColSecExtranjero = null;
LET vc_tipo_tramite = null;
LET vc_es_extranjero = null;
LET vc_path_nuxeo = null;

SELECT per.apellido as apellido
	, per.nombres as nombres
	, CASE WHEN (per.sexo = 1) THEN 'M' ELSE 'F' END as sexo
	, to_char(per.fecha_nacimiento, '%d/%m/%Y') as fecha_nacimiento
	, per.pais_documento as cod_pais_dni
	, per.tipo_documento as tipo_doc
	, mtd.desc_abreviada as tipo_doc_descripcion
	, per.nro_documento as nro_documento
	, car.carrera as carrera
	-- , car.nombre as nombre_carrera

	,CASE 
		WHEN per.unidad_academica = 'FCE' and car.carrera= '0201' and pl.plan in ('0201')
		     	THEN 'Contador Público Nacional'
		WHEN per.unidad_academica = 'FCE' and car.carrera= '0207' and pl.plan in ('2004', '2007')
		     	THEN 'Tecnicatura en Control y Auditoría Gubernamental' 
		WHEN per.unidad_academica = 'FIQ' and car.carrera= '00003' and pl.plan in ('2009', 'D.T.Q')
		     	THEN 'Doctorado en Tecnología Química' 
		WHEN per.unidad_academica = 'FIQ' and car.carrera=  '00013' and pl.plan in ('DCTA')
		     	THEN 'Doctorado en Ciencia y Tecnología de los Alimentos' 
		WHEN per.unidad_academica = 'ISM' and car.carrera= '01' and pl.plan in ('2001')
		     	THEN 'Ciclo de Licenciatura en Teoría y Crítica de la Música' 
		WHEN per.unidad_academica = 'ISM' and car.carrera= '04' and pl.plan in ('2018')
		     	THEN 'Tecnicatura en Composición Musical con Medios Electroacústicos' 
		WHEN per.unidad_academica = 'ISM' and car.carrera=  '02' and pl.plan in ('2009')
		     	THEN 'Tecnicatura en Arreglos Musicales'
		WHEN per.unidad_academica = 'FICH' and car.carrera=  '0001' and pl.plan in ('2001', '2014')
		     	THEN 'Tecnicatura en Informática Aplicada al Diseño Multimedia y de Sitios Web' 
		WHEN per.unidad_academica = 'FICH' and car.carrera=  '0002' and pl.plan in ('2004', '2007', '2014')
		     	THEN 'Tecnicatura en Informática Aplicada a la Gráfica y Animación Digital' 
		WHEN per.unidad_academica = 'FICH' and car.carrera=  '0003' and pl.plan in ('2002', '2014')
		     	THEN 'Tecnicatura en Informática de Gestión' 
		WHEN per.unidad_academica = 'FCA' and car.carrera=  '00004' and pl.plan in ('2008')
		     	THEN 'Maestría en Extensión Agropecuaria' 
		WHEN per.unidad_academica = 'FCV' and car.carrera=  '002' and pl.plan in ('2002')
		     	THEN 'Tecnicatura en Alimentación de Ganado Vacuno' 

		WHEN per.unidad_academica = 'FCJS' and car.carrera= 'MDPP' and pl.plan in ('2017') and ori.orientacion = 'MDPP1'
		     	THEN car.nombre || ' Mención Teorías y Políticas del Desarrollo'

		WHEN per.unidad_academica = 'FCJS' and car.carrera= 'MDPP' and pl.plan in ('2017') and ori.orientacion = 'MDPP2'
		     	THEN car.nombre || ' Mención Gestión Pública del Desarrollo'
		WHEN per.unidad_academica = 'FCJS' and car.carrera= 'PG000' and pl.plan in ('2016')
		     	THEN 'Especialización en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores'
		-- FADU
		WHEN per.unidad_academica = 'FADU' and car.carrera = '12' and pl.plan in ('2002')
		     	THEN 'Tecnicatura en Interiorismo y Decoración'
		WHEN per.unidad_academica = 'FADU' and car.carrera = '9' and pl.plan in ('2003')
		     	THEN 'Tecnicatura en Composición de Parques y Jardines'
		-- FBCB
		WHEN per.unidad_academica = 'FBCB' and car.carrera = '004' and pl.plan in ('2004')
		     	THEN 'Tecnicatura en Estadística de Salud'
		-- FCA
		WHEN per.unidad_academica = 'FCA' and car.carrera = '001' and pl.plan in ('2003')
		     	THEN 'Tecnicatura en Gestión y Producción Apícola'
		-- FHUC
		WHEN per.unidad_academica = 'FHUC' and car.carrera= '21' and pl.plan in ('2003')
		     	THEN 'Ciclo de Licenciatura en Periodismo y Comunicación'
		WHEN per.unidad_academica = 'FHUC' and car.carrera= '21' and pl.plan in ('2025')
		     	THEN 'Licenciatura en Periodismo y Comunicación - Ciclo de Complementación Curricular'

		    ELSE car.nombre
	END nombre_carrera

	, stc.tipo_de_carrera as codigo_tipo_car
	, stc.nombre as tipo_de_carrera
	, mul.nombre as localidad_nacimiento
	, mpr.nombre as provincia_nacimiento
	, mpa.nombre as pais_nacimiento
	, upc.expediente as expediente
	, upcd.imprenta as diploma_impreso
        , NVL(upcd.autorizado_apellido, '') || ', ' || NVL(upcd.autorizado_nombre, '') || ' - ' || NVL(upcd.autorizado_documento, '') as autorizante_retiro
	, upcdr.url as url_foto
	, to_char(sto.fecha_egreso, '%d/%m/%Y') as fecha_egreso
	, CASE WHEN (tit.titulo = 'PROIN' AND car.carrera = '1' AND pl.plan IN ('2000')) THEN 'ME-2309/17' 
		WHEN (tit.titulo = 'PROIN' AND car.carrera = '1' AND pl.plan IN ('2018')) THEN 'ME-1890/22' 
		WHEN (tit.titulo = 'EDA' AND car.carrera = 'EDA' AND alu.sede IN ('00001')  AND pl.plan  IN ('2014')) THEN 'ME-2197/21' 
		WHEN (tit.titulo = 'EDA' AND car.carrera = 'EDA' AND alu.sede IN ('00000')  AND pl.plan  IN ('2014')) THEN 'ME-4376/17' 
		WHEN (tit.titulo = 'MDAD' AND car.carrera = 'MDAD' AND alu.sede IN ('00001')) THEN 'ME-2574/21' 
		WHEN (tit.titulo = 'MDAD' AND car.carrera = 'MDAD' AND alu.sede IN ('00000')) THEN 'ME-4007/17'
		 
	ELSE pl.nro_resolucion END as resolucion_ministerial
 	
 	, CASE  WHEN (per.sexo = 1) 
		THEN (CASE WHEN ori.nombre IS NULL 
			THEN
				CASE
					WHEN per.unidad_academica = 'FIQ' and car.carrera= '00003' and pl.plan in ('2009', 'D.T.Q')
			     			THEN 'Doctor en Tecnología Química' 
					WHEN per.unidad_academica = 'FIQ' and car.carrera=  '00013' and pl.plan in ('DCTA')
					     	THEN 'Doctor en Ciencia y Tecnología de los Alimentos'
					WHEN per.unidad_academica = 'FCJS' and car.carrera=  'PG000' and pl.plan in ('2016')
					     	THEN 'Especialista en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores'

					ELSE   tit.nombre 
				END

			ELSE 
				CASE 
					WHEN (per.unidad_academica <> 'FHUC' AND per.unidad_academica <> 'FICH' AND per.unidad_academica <> 'FCJS') OR (per.unidad_academica = 'FHUC' AND sto.titulo = 'DH') 
			   			THEN tit.nombre || ': ' || ori.nombre
					WHEN per.unidad_academica= 'FCJS' and car.carrera=  'MDPP' and pl.plan in ('2017')
					     	THEN 'Magíster en Desarrollo y Políticas Públicas' 

					ELSE tit.nombre 
				  END
 
			END)
			
			 
		ELSE (CASE WHEN ori.nombre IS NULL 
			THEN
				CASE
					WHEN per.unidad_academica = 'FIQ' and car.carrera= '00003' and pl.plan in ('2009', 'D.T.Q')
			     			THEN 'Doctora en Tecnología Química' 
					WHEN per.unidad_academica = 'FIQ' and car.carrera=  '00013' and pl.plan in ('DCTA')
					     	THEN 'Doctora en Ciencia y Tecnología de los Alimentos'

					WHEN per.unidad_academica = 'FCJS' and car.carrera=  'PG000' and pl.plan in ('2016')
					     	THEN 'Especialista en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores' 
 
					ELSE   tit.nombre_femenino
				END

			ELSE 
				CASE 
					WHEN (per.unidad_academica <> 'FHUC' AND per.unidad_academica <> 'FICH' AND per.unidad_academica <> 'FCJS') OR (per.unidad_academica = 'FHUC' AND sto.titulo = 'DH') 
			   			THEN tit.nombre_femenino || ': ' || ori.nombre
					WHEN per.unidad_academica= 'FCJS' and car.carrera=  'MDPP' and pl.plan in ('2017')
					     	THEN 'Magíster en Desarrollo y Políticas Públicas' 

					ELSE tit.nombre_femenino
				  END
 
			END)
			
	END as nombre_titulo

 	--, CASE WHEN (per.sexo = 1) THEN tit.nombre ELSE tit.nombre_femenino END as nombre_titulo
	, ste.titulo as nombre_tesina
	, scp.certif_pedido as certif_pedido
	, sto.titulo as codigo_titulo
	, CASE WHEN (tit.nivel = 'INTERMEDIO') THEN 'S' ELSE 'N' end as es_titulo_intermedio
	, CASE WHEN per.nacionalidad = 2 THEN 'S' ELSE 'N' END as es_extranjero
        , per.nro_inscripcion as nro_inscripcion
        , CASE WHEN upcd.tipo_tramite IS NULL THEN 'N' ELSE upcd.tipo_tramite END as tipo_tramite
        , upc.path_nuxeo as path_nuxeo
	INTO vc_apellido, vc_nombres, vc_sexo, vc_fecha_nacimiento, vc_cod_pais_dni, 
	vc_tipo_doc, vc_tipo_doc_descripcion, vc_nro_documento, vc_carrera, vc_nombre_carrera, vc_codigo_tipo_car,
	vc_tipo_de_carrera, vc_localidad_nacimiento, vc_provincia_nacimiento,
	vc_pais_nacimiento, vc_expediente, vc_diploma_impreso, vc_autorizante_retiro,
	vc_url_foto, vc_fecha_egreso, vc_resolucion_ministerial, vc_nombre_titulo, 
	vc_nombre_tesina, vc_certif_pedido, vc_codigo_titulo, vc_es_titulo_intermedio, vc_es_extranjero, vc_nro_inscripcion, vc_tipo_tramite, vc_path_nuxeo
	FROM sga_certif_pedidos as scp
	JOIN sga_personas per ON per.nro_inscripcion = scp.nro_inscripcion
	JOIN mdp_tipo_documento mtd ON mtd.tipo_documento = per.tipo_documento
	JOIN u820_pedidos_certif_diploma upcd ON upcd.id_certif_pedido = scp.certif_pedido
	JOIN sga_carreras car ON car.carrera = upcd.carrera
	JOIN sga_tipos_carrera stc ON stc.tipo_de_carrera = car.tipo_de_carrera
	LEFT JOIN mug_localidades mul ON mul.localidad = per.loc_nacimiento
	LEFT JOIN mug_dptos_partidos mdp ON mdp.dpto_partido = mul.dpto_partido
	LEFT JOIN mug_provincias mpr ON mpr.provincia = mdp.provincia
	LEFT JOIN mug_paises mpa ON mpa.pais = mpr.pais
	LEFT JOIN u820_pedidos_certif upc ON upc.id_certif_pedido = scp.certif_pedido
	LEFT JOIN u820_pedidos_certif_diploma_req upcdr ON upcdr.id_certif_pedido = scp.certif_pedido AND upcdr.requisito = "UNL04"
	LEFT JOIN sga_titulos_otorg sto ON sto.nro_inscripcion = scp.nro_inscripcion AND sto.carrera = upcd.carrera AND sto.titulo = upcd.titulo
	JOIN sga_titulos tit ON tit.titulo = upcd.titulo
	JOIN sga_alumnos alu ON alu.nro_inscripcion = per.nro_inscripcion AND alu.carrera = upcd.carrera
	JOIN sga_planes pl ON pl.carrera = alu.carrera AND pl.plan = alu.plan 
	LEFT JOIN sga_tesis_alumnos sta ON sta.carrera = alu.carrera AND sta.legajo = alu.legajo AND stc.tipo_de_carrera IN ('P', 'S')
	LEFT JOIN sga_tesis ste ON ste.tesis = sta.tesis
	LEFT JOIN sga_orie_tit_otorg tit_ori ON tit_ori.unidad_academica = sto.unidad_academica AND tit_ori.nro_inscripcion = sto.nro_inscripcion AND tit_ori.titulo = sto.titulo
	LEFT JOIN sga_orientaciones ori ON ori.unidad_academica = tit_ori.unidad_academica 
		AND ori.carrera = tit_ori.carrera 
		AND ori.plan = tit_ori.plan AND ori.titulo = tit_ori.titulo 
		AND ori.orientacion = tit_ori.orientacion 
		AND ori.orientacion <> '0'
	WHERE scp.certif_pedido = p_solicitud;

	--------------------------------------------------------------
	-- Datos del titulo superior según sean posgrados o no
	--------------------------------------------------------------
	IF vc_codigo_tipo_car IN ('P', 'S') THEN
		SELECT super.nombre
		INTO vcTituloSuperior
		FROM sga_personas per
			join sga_formacion_acad acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
			join sga_titulos_super super
			on acad.titulo_superior = super.titulo_superior
	
		WHERE per.nro_inscripcion = vc_nro_inscripcion
			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
						from  sga_formacion_acad acad1
						where acad1.nro_inscripcion = vc_nro_inscripcion);
	ELSE
		IF vc_codigo_tipo_car = 'W' THEN
			SELECT acad.alu_otestsup_carr
			INTO vcTituloSuperior
			FROM sga_personas per
			join sga_datos_cen_aux2 acad    
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
				and per.nro_inscripcion  = vc_nro_inscripcion
				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 
					from  sga_datos_cen_aux2 acad1
					where acad1.nro_inscripcion = vc_nro_inscripcion);
		END IF;
	END IF;

-- Colegio Secundario Extranjero (S o N)
SELECT CASE WHEN PA.pais = 54 THEN 'N' ELSE 'S' END
INTO EsColSecExtranjero
FROM sga_certif_pedidos as scp
JOIN sga_personas per ON per.nro_inscripcion = scp.nro_inscripcion
JOIN sga_coleg_sec CS ON per.colegio_secundario = CS.colegio
JOIN mug_localidades L ON CS.localidad = L.localidad
JOIN mug_dptos_partidos D ON L.dpto_partido = D.dpto_partido
JOIN mug_provincias PR ON D.provincia = PR.provincia
JOIN mug_paises PA ON PR.pais = PA.pais
WHERE scp.certif_pedido = p_solicitud; 

RETURN iStatus, vc_apellido, vc_nombres, vc_sexo, vc_fecha_nacimiento, vc_cod_pais_dni, 
	vc_tipo_doc, vc_tipo_doc_descripcion, vc_nro_documento, vc_carrera, vc_nombre_carrera,
	vc_tipo_de_carrera, vc_localidad_nacimiento, vc_provincia_nacimiento,
	vc_pais_nacimiento, vc_expediente, vc_diploma_impreso, vc_autorizante_retiro,
	vc_url_foto, vc_fecha_egreso, vc_resolucion_ministerial, vc_nombre_titulo, 
	vc_nombre_tesina, vc_certif_pedido, vc_codigo_titulo, vc_es_titulo_intermedio, vc_es_extranjero, vcTituloSuperior, EsColSecExtranjero, vc_tipo_tramite, vc_path_nuxeo;

END;
END PROCEDURE;

-- EXECUTE PROCEDURE "dba".sp820_datos_tramite_diploma_digital(8659); 
-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_datos_tramite_diploma_digital 
-- *****************************************************************************
revoke execute on "dba".sp820_datos_tramite_diploma_digital from public;
grant execute on "dba".sp820_datos_tramite_diploma_digital to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_datos_tramite_diploma_digital to internet; -- Rol de usuario de Internet

