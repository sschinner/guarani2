CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ted_1e_dig') THEN
		DROP PROCEDURE sp820_ted_1e_dig;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Stored Procedure: sp_ted_1e_dig
-- Version 1.7.0
-- Ultima version de modificacion: 2.02.0, 2.03.0, 2.04.0, 2.6.0, 2.9.2
--
-- Certificado Analitico del alumno.
-- **************************************************************************

--  EXECUTE PROCEDURE "dba".sp820_ted_1e_dig ( 'FCJS', 'FCJS-5857' , 'MDPP');
--  EXECUTE PROCEDURE sp820_histAcaEgre('FADU', '1', '22215550-5' ) 

{
select * from sga_titulos_otorg tit
	-- join sga_orie_tit_otorg tit_ori on tit_ori.unidad_academica = tit.unidad_academica
		AND tit_ori.nro_inscripcion = tit.nro_inscripcion
		AND tit_ori.titulo = tit.titulo 
	where tit.legajo = '29620260-5';

select * from sga_orie_tit_otorg 
-- insert into sga_orie_tit_otorg  values ('FCE',	'FCE-2810',	'0221',	'2006',	'0221',	'34');
select * from sga_alumnos where nro_inscripcion = 'FCE-2810' and carrera = '0221';

-- begin;
--set triggers for sga_alumnos disabled;
--update sga_alumnos set calidad = 'E' where nro_inscripcion = 'FCE-2810' and carrera = '0221';
--set triggers for sga_alumnos enabled;
--commit;

--begin;
--delete from sga_orie_tit_otorg where nro_inscripcion = 'FBCB-999' and orientacion = 'OQ';		
--commit;
}

CREATE PROCEDURE "dba".sp820_ted_1e_dig ( pUA like sga_titulos_otorg.unidad_academica, pNroInscripcion like sga_titulos_otorg.nro_inscripcion, pTitulo like sga_titulos_otorg.titulo )

RETURNING 
	varchar (5),		-- Unidad Academica
	varchar (20),		-- Nro. Expediente
	varchar (15),		-- Legajo
	varchar(120),		-- Nombre Universidad
	varchar(60),		-- Nombre Facultad
	varchar (5),		-- Carrera
	varchar (255),		-- Nombre Carrera
	varchar (255),		-- Plan
	date,			-- Fecha de resolución
	varchar(15),		-- Nro. Resolución Plan
	varchar(60),		-- Apellido
	varchar(60),		-- Nombres
	integer,		-- Tipo de documento
	varchar(15),		-- Nro. de documento
	varchar (10),		-- Nro. inscripcion
	date,			-- fecha de egreso
	Float,			-- Promedio gral
	Float,			-- Promedio sin aplazos (academico)
	varchar(255),		-- Nombre del título
	varchar(5),		-- Materia
	varchar(255),		-- Nombre Materia
	date,			-- Fecha
	varchar (5),		-- Nota
	varchar(15),		-- Concepto
	varchar(10),		-- Acta
	integer, 		-- vcActaPromocion,
	varchar(15), 		-- vcNroResolucion,
	varchar(20), 		-- vcFormaAprobacion,
	integer,		-- Folio
	varchar(2), 		-- Resultado
	varchar(3),		-- Tipo Doc. Descrip.
	date,			-- fecha de pedido de certificado
	varchar(15), 		-- descripcion de la nota		

	char(1),		-- tipo de titulo: Título de Grado Universitario, Magister, Postítulo, Terciario, etc.
	varchar(255), 		-- descripcion del titulo secundario si curso el secundario en el exterior
	char(1),		-- colegio secundario exterior
	varchar(15),		-- resolucion ingreso
	varchar(255),		-- Titulo superior previo obtenido sga_formacion_acad (posgrados)/ sga_datos_cen_aux2 (ciclos)
	integer,		-- Tipo ingreso
	varchar(255), 	-- Localidad
	varchar(255),	-- fecha egreso string
	char(1), 		-- tipo de carrera
	integer, -- Institución otorgante del titulo superior previo en caso de posgrados
        char(1);                -- sexo

DEFINE  vcExpedienteNro     varchar(20);
DEFINE  vcLegajo            varchar(15);
DEFINE  vcUnivNombre        varchar(120);
DEFINE  vcFacultadNombre    varchar(60);
DEFINE  vcCarrera           varchar(5);
DEFINE  vcCarreraNombre     varchar(255);
DEFINE  vcCarreraNombreRed  varchar(20);
DEFINE  vcPlan, vcPlanHA varchar(5);
DEFINE  vcPlan_aux VARCHAR(255);
DEFINE  vcPlanVersion, vcPlanVersionHA       varchar(5);
DEFINE  dResolucionFecha    date;
DEFINE  vcResolucionNro     varchar(15);
DEFINE  vcApellido          varchar(60);
DEFINE  vcNombre            varchar(60);
DEFINE  iDocTipo            integer;
DEFINE  iDocNro             varchar(15);
DEFINE  vcSexo varchar(1);
DEFINE  vcInscripcionNro    varchar(10);
DEFINE  dEgresoFecha        date;
DEFINE  fPromGral           decimal(6,2);
DEFINE  fPromSinAplazos     decimal(6,2);
DEFINE  vcTituloNombre      varchar(255);
DEFINE  vcMateria           varchar(5);
DEFINE  vcMateriaNombre     varchar(255);
DEFINE  vcMateriaNombreRed  varchar(30);
DEFINE  dFecha              date;
DEFINE  vcNota              varchar(5);
DEFINE  vcConcepto          varchar(15);
DEFINE  vcActa              varchar(10);
DEFINE  vcActaTipo          varchar(1); 
DEFINE  iFolio              integer;
DEFINE  vcResultado         varchar(15);
DEFINE  vcDocTipoDescrip    varchar(3);
DEFINE  iEscalaExamen       integer;
DEFINE  vcFormaAprobacion   varchar(20);
DEFINE  vcActaPromocion     integer;
DEFINE  iEquivalencia	    integer;
DEFINE  vcNroResolucion     varchar(15);
DEFINE  vdFecha_pedido     date;
DEFINE vcDescripcionNota varchar(15);
DEFINE vcNivel varchar(15);

DEFINE vcTipoTitulo varchar(1); 
DEFINE vcDescripcionTitSec varchar(255); 
DEFINE vcTituloSecExt char(1); 
DEFINE vcResolIngreso varchar(15); 
DEFINE vcTituloSuperior varchar(255);
DEFINE viTipoIngreso integer; 

DEFINE vcLocalidad varchar(255);
DEFINE vcFechaEgresoStr varchar(255);


DEFINE  vcOrientacion varchar(255);
DEFINE  vcOrientacionCodigo varchar(5);
DEFINE vcTipoCarrera char(1);

DEFINE viInstitucion integer;
DEFINE vcSede varchar(5);

BEGIN


LET vcTituloSuperior = NULL;
LET vcTituloSecExt = NULL;
LET vcDescripcionTitSec = NULL;
LET viTipoIngreso = NULL;
LET vcTipoCarrera = NULL;
LET viInstitucion = NULL;
LET vcOrientacion = NULL;
LET vcOrientacionCodigo = NULL;
LET vcSede = NULL;
--------------------------------------------------------------
-- Datos del título
--------------------------------------------------------------
	SELECT tit.carrera, 
		tit.legajo,
		tit.nro_expediente,
		tit.fecha_egreso,
		tit.prom_general,
		tit.prom_sin_aplazos,
		tit.plan,
		CASE 
			WHEN ori.nombre is NULL 
		     	THEN ' ' 
		    ELSE CASE 
			WHEN pUA = 'FCV' 
				       	THEN CASE 
							WHEN pTitulo = '00003' 
							   THEN ': ' || ori.nombre 
					 		ELSE ' ' 
				    		END
			WHEN pUA = 'FHUC'
			       		THEN CASE 
							WHEN pTitulo = 'DH' 
								   THEN ': ' || ori.nombre 
					 			ELSE ' ' 
				    		END
			WHEN pUA = 'FICH' 
				       	THEN CASE 
							WHEN pTitulo = '0005' 
							   THEN ' ' 
					 		ELSE ' ' 
				    		END
			WHEN pUA = 'FCJS' 
				       	THEN CASE 
							WHEN pTitulo = 'MDPP' 
							   THEN ' ' 
					 		ELSE ' ' 
				    		END

			ELSE ': ' || ori.nombre
			END 
		END,
		ori.orientacion,
		today
	INTO vcCarrera, 
		vcLegajo,
		vcExpedienteNro,
		dEgresoFecha,
		fPromGral,
		fPromSinAplazos,
		vcPlan,
		vcOrientacion,
		vcOrientacionCodigo,
		vdFecha_pedido
	FROM sga_titulos_otorg  tit,
		OUTER (sga_orie_tit_otorg tit_ori, sga_orientaciones ori)


	WHERE tit.unidad_academica = pUA 
		AND tit.titulo = pTitulo
		AND tit.nro_inscripcion = pNroInscripcion
		AND tit_ori.unidad_academica = tit.unidad_academica
		AND tit_ori.nro_inscripcion = tit.nro_inscripcion
		AND tit_ori.titulo = tit.titulo

		AND ori.unidad_academica = tit_ori.unidad_academica
		AND ori.carrera = tit_ori.carrera
		AND ori.plan = tit_ori.plan
		AND ori.titulo = 	tit_ori.titulo
		AND ori.orientacion = tit_ori.orientacion

	  	AND ori.orientacion <> '0';

	--------------------------------------------------------------
	-- Fecha Egreso String.
	--------------------------------------------------------------
	execute procedure sp_815_dfechaletra(dEgresoFecha ,1 ) INTO vcFechaEgresoStr;
	--------------------------------------------------------------
	-- Datos localidad.
	--------------------------------------------------------------
	IF pUA IN ('FCV', 'FCA') THEN
		LET vcLocalidad = "ESPERANZA";
	ELIF pUA = 'EUA' THEN		  
		LET vcLocalidad = "GÁLVEZ";
	ELSE  
		LET vcLocalidad = "SANTA FE";
	END IF;

	--------------------------------------------------------------
	-- Descripcion de la Universidad.
	--------------------------------------------------------------
	SELECT sga_unidades_acad.nombre_universidad,
		sga_unidades_acad.nombre
	INTO vcUnivNombre,
		vcFacultadNombre
	FROM sga_unidades_acad
	WHERE sga_unidades_acad.unidad_academica = pUA;
	--------------------------------------------------------------
	-- Descripcion de la carrera
	--------------------------------------------------------------
	SELECT 
	CASE 
		WHEN pUA = 'FICH' and vcCarrera = '0001' and vcPlan in ('2001', '2014')
		     	THEN 'Tecnicatura en Informática Aplicada al Diseño Multimedia y de Sitios Web'
		WHEN pUA = 'FICH' and vcCarrera = '0002' and vcPlan in ('2004', '2007', '2014')
		     	THEN 'Tecnicatura en Informática Aplicada a la Gráfica y Animación Digital'
		WHEN pUA = 'FICH' and vcCarrera = '0003' and vcPlan in ('2002', '2014')
		     	THEN 'Tecnicatura en Informática de Gestión'
		WHEN pUA = 'FCE' and vcCarrera = '0201' and vcPlan in ('0201')
		     	THEN 'Contador Público Nacional' 
		WHEN pUA = 'FCE' and vcCarrera = '0207' and vcPlan in ('2004', '2007')
		     	THEN 'Tecnicatura en Control y Auditoría Gubernamental' 

		WHEN pUA = 'FIQ' and vcCarrera = '00003' and vcPlan in ('2009', 'D.T.Q')
		     	THEN 'Doctorado en Tecnología Química' 
		WHEN pUA = 'FIQ' and vcCarrera = '00013' and vcPlan in ('DCTA')
		     	THEN 'Doctorado en Ciencia y Tecnología de los Alimentos' 
		WHEN pUA = 'ISM' and vcCarrera = '01' and vcPlan in ('2001')
		     	THEN 'Ciclo de Licenciatura en Teoría y Crítica de la Música' 
		WHEN pUA = 'ISM' and vcCarrera = '04' and vcPlan in ('2018')
		     	THEN 'Tecnicatura en Composición Musical con Medios Electroacústicos' 
		WHEN pUA = 'ISM' and vcCarrera = '02' and vcPlan in ('2009')
		     	THEN 'Tecnicatura en Arreglos Musicales' 
		WHEN pUA = 'FCA' and vcCarrera = '00004' and vcPlan in ('2008')
		     	THEN 'Maestría en Extensión Agropecuaria'
		WHEN pUA = 'FCV' and vcCarrera = '002' and vcPlan in ('2002')
		     	THEN 'Tecnicatura en Alimentación de Ganado Vacuno'

		WHEN pUA = 'FCJS' and vcCarrera = 'MDPP' and vcPlan in ('2017') and vcOrientacionCodigo = 'MDPP1'
		     	THEN sga_carreras.nombre || ' Mención Teorías y Políticas del Desarrollo'

		WHEN pUA = 'FCJS' and vcCarrera = 'MDPP' and vcPlan in ('2017') and vcOrientacionCodigo = 'MDPP2'
		     	THEN sga_carreras.nombre || ' Mención Gestión Pública del Desarrollo'

		WHEN pUA = 'FCJS' and vcCarrera = 'PG000' and vcPlan in ('2016')
		     	THEN 'Especialización en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores'
		-- FADU
		WHEN pUA = 'FADU' and vcCarrera = '12' and vcPlan in ('2002')
		     	THEN 'Tecnicatura en Interiorismo y Decoración'
		WHEN pUA = 'FADU' and vcCarrera = '9' and vcPlan in ('2003')
		     	THEN 'Tecnicatura en Composición de Parques y Jardines'
		-- FBCB
		WHEN pUA = 'FBCB' and vcCarrera = '004' and vcPlan in ('2004')
		     	THEN 'Tecnicatura en Estadística de Salud'

		-- FCA
		WHEN pUA = 'FCA' and vcCarrera = '001' and vcPlan in ('2003')
		     	THEN 'Tecnicatura en Gestión y Producción Apícola'
		-- FHUC
		WHEN pUA = 'FHUC' and vcCarrera = '21' and vcPlan in ('2003')
		     	THEN 'Ciclo de Licenciatura en Periodismo y Comunicación'
		WHEN pUA = 'FHUC' and vcCarrera = '21' and vcPlan in ('2025')
		     	THEN 'Licenciatura en Periodismo y Comunicación - Ciclo de Complementación Curricular'

		    ELSE sga_carreras.nombre
	END as nombre,

	sga_carreras.tipo_de_carrera
	INTO vcCarreraNombre, vcTipoCarrera
	FROM sga_carreras
	WHERE sga_carreras.unidad_academica = pUA
		AND sga_carreras.carrera = vcCarrera ;

	--------------------------------------------------------------
	-- Datos de la persona
	--------------------------------------------------------------
	SELECT per.apellido,
		per.nombres,
		per.tipo_documento,
		per.nro_documento,
		per.nro_inscripcion,
		CASE WHEN per.sexo = 1 THEN 'M' ELSE 'F' END,
		car.resolucion_ingreso,
		car.tipo_ingreso,
		alu.sede
	INTO vcApellido,
		vcNombre,
		iDocTipo,
		iDocNro,
		vcInscripcionNro,
		vcSexo,
		vcResolIngreso,
		viTipoIngreso,
		vcSede
		
	FROM sga_personas per
		join sga_carrera_aspira car
		on per.unidad_academica = car.unidad_academica
			and per.nro_inscripcion = car.nro_inscripcion
		join sga_alumnos alu
		on alu.unidad_academica = car.unidad_academica
			and alu.nro_inscripcion = car.nro_inscripcion
			and alu.carrera = car.carrera
	
	WHERE per.unidad_academica = pUA
		AND per.nro_inscripcion = pNroInscripcion
		AND car.carrera = vcCarrera
		AND car.situacion_asp in ('IL', 'IC');

	SELECT mdp_tipo_documento.desc_abreviada
	INTO vcDocTipoDescrip
	FROM mdp_tipo_documento
	WHERE mdp_tipo_documento.tipo_documento = iDocTipo ;

	--------------------------------------------------------------
	-- Descripcion del Plan
	--------------------------------------------------------------
	SELECT sga_planes.version_actual, sga_planes.fecha_resolucion, sga_planes.nro_resolucion
	INTO vcPlanVersion, dResolucionFecha, vcResolucionNro
	FROM sga_planes
	WHERE sga_planes.unidad_academica = pUA
		AND sga_planes.carrera = vcCarrera
		AND sga_planes.plan = vcPlan;

	-- Caso particular FCJS: titulo intermedio Procurador de la carrera Abogacia (plan 2000).
	IF (pUA = 'FCJS' AND vcCarrera = '1' AND vcPlan IN ('2000') AND pTitulo = 'PROIN') THEN
		LET vcResolucionNro = 'ME-2309/17';
	-- Caso particular FCJS: titulo intermedio Procurador de la carrera Abogacia (plan 2018).
	ELIF (pUA = 'FCJS' AND vcCarrera = '1' AND vcPlan IN ('2018') AND pTitulo = 'PROIN') THEN
		LET vcResolucionNro = 'ME-1890/22';
	-- Caso particular Posgrado FCJS: reoluciones por Sede		
	ELIF (pUA = 'FCJS' AND vcCarrera = 'EDA' AND vcPlan IN ('2014') AND vcSede IN ('00001') AND pTitulo = 'EDA') THEN
		LET vcResolucionNro = 'ME-2197/21';
	ELIF (pUA = 'FCJS' AND vcCarrera = 'EDA' AND vcPlan IN ('2014') AND vcSede IN ('00000') AND pTitulo = 'EDA') THEN
		LET vcResolucionNro = 'ME-4376/17';		
	ELIF (pUA = 'FCJS' AND vcCarrera = 'MDAD' AND vcPlan IN ('2015') AND vcSede IN ('00001') AND pTitulo = 'MDAD') THEN
		LET vcResolucionNro = 'ME-2574/21';		
	ELIF (pUA = 'FCJS' AND vcCarrera = 'MDAD' AND vcPlan IN ('2015') AND vcSede IN ('00000') AND pTitulo = 'MDAD') THEN
		LET vcResolucionNro = 'ME-4007/17';
		
	END IF;

	--------------------------------------------------------------
	-- Datos del titulo
	--------------------------------------------------------------
	SELECT -- case vcSexo when 'M' then tit.nombre when 'F' then tit.nombre_femenino else tit.nombre end, 
 	CASE  WHEN (vcSexo  = 'M') 
		THEN (CASE
					WHEN pUA = 'FIQ' and titotorg.carrera=  '00003' and titotorg.plan in ('2009', 'D.T.Q')
			     			THEN 'Doctor en Tecnología Química' 
					WHEN pUA = 'FIQ' and titotorg.carrera=  '00013' and titotorg.plan in ('DCTA')
					     	THEN 'Doctor en Ciencia y Tecnología de los Alimentos' 
					WHEN pUA = 'FCJS' and titotorg.carrera=  'MDPP' and titotorg.plan in ('2017')
					     	THEN 'Magíster en Desarrollo y Políticas Públicas' 
					WHEN pUA = 'FCJS' and titotorg.carrera=  'PG000' and titotorg.plan in ('2016')
					     	THEN 'Especialista en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores' 
					
					ELSE   tit.nombre 
				END)
			
			 
		ELSE (CASE
					WHEN pUA = 'FIQ' and titotorg.carrera=  '00003' and titotorg.plan in ('2009', 'D.T.Q')
			     			THEN 'Doctora en Tecnología Química' 
					WHEN pUA = 'FIQ' and titotorg.carrera=  '00013' and titotorg.plan in ('DCTA')
					     	THEN 'Doctora en Ciencia y Tecnología de los Alimentos'
					WHEN pUA = 'FCJS' and titotorg.carrera=  'MDPP' and titotorg.plan in ('2017')
					     	THEN 'Magíster en Desarrollo y Políticas Públicas' 
					WHEN pUA = 'FCJS' and titotorg.carrera=  'PG000' and titotorg.plan in ('2016')
					     	THEN 'Especialista en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores' 

					ELSE   tit.nombre_femenino
				END)
			
	END as nombre_titulo, tit.nivel, tt.tipo_de_titulo

		INTO vcTituloNombre, vcNivel, vcTipoTitulo
	FROM sga_titulos tit
		join sga_tipos_titulo tt
			on tit.tipo_de_titulo = tt.tipo_de_titulo
		join sga_titulos_otorg titotorg on titotorg.titulo = tit.titulo
	WHERE tit.unidad_academica = pUA
		AND tit.titulo = pTitulo
		AND titotorg.nro_inscripcion = pNroInscripcion;

	--------------------------------------------------------------
	-- Datos del colegio secundario: titulo
	--------------------------------------------------------------
	SELECT tsec.descripcion
	INTO vcDescripcionTitSec
	FROM sga_personas per
		join sga_titulos_sec tsec
			on per.titulo_secundario = tsec.titulo_secundario
	WHERE per.unidad_academica = pUA
		AND per.nro_inscripcion = pNroInscripcion;

	--------------------------------------------------------------
	-- Datos del colegio secundario: si es exterior.
	--------------------------------------------------------------
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

	WHERE per.unidad_academica = pUA
		AND per.nro_inscripcion = pNroInscripcion;


	--------------------------------------------------------------
	-- Datos del titulo superior según sean posgrados o no
	--------------------------------------------------------------
	IF vcTipoCarrera IN ('P', 'S') THEN
		SELECT  super.nombre, 
                        CASE I.tipo_institucion 
                            WHEN 'U' THEN 1 -- Universidad nacional
                            WHEN 'P' THEN 2 -- Universidad privada
                            WHEN 'T' THEN 3 -- Instituto terciario
                            WHEN 'E' THEN 4 -- Institucion extranjera
                            ELSE 0
                        END
		INTO vcTituloSuperior, viInstitucion
		FROM sga_personas per
			join sga_formacion_acad acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
			join sga_titulos_super super
			on acad.titulo_superior = super.titulo_superior
                        JOIN sga_instituciones I ON I.institucion = acad.institucion
	
		WHERE per.unidad_academica = pUA
			AND per.nro_inscripcion = pNroInscripcion
			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
						from  sga_formacion_acad acad1
						where acad1.unidad_academica = pUA
							and acad1.nro_inscripcion = pNroInscripcion);
	ELSE
		IF vcTipoCarrera = 'W' THEN
			SELECT acad.alu_otestsup_carr
			INTO vcTituloSuperior
			FROM sga_personas per
			join sga_datos_cen_aux2 acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
				and per.nro_inscripcion  = pNroInscripcion
				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 
					from  sga_datos_cen_aux2 acad1
					where acad1.unidad_academica = pUA
						and acad1.nro_inscripcion = pNroInscripcion);
		END IF;
	END IF;

	--------------------------------------------------------------
	-- Barro la vista de historia academica.
	-- Recupera TODAS las materias aprobadas o reprobadas por el alumno 
	-- de TODOS LOS PLANES de la carrera en la que el alumno tiene registro.
	--------------------------------------------------------------
	FOREACH EXECUTE PROCEDURE sp820_histAcaEgre(pUA, vcCarrera, vcLegajo) 
		INTO vcMateria,	vcMateriaNombre, dFecha,
			vcResultado, vcNota, vcFormaAprobacion,
			vcActaTipo, vcActa, vcActaPromocion,
			vcNroResolucion, vcPlanHA, vcPlanVersionHA,
			vcCarreraNombreRed, vcMateriaNombreRed, iEscalaExamen, 
			iEquivalencia, vcDescripcionNota, vcConcepto
			
		
		-- MANEJO DE ALUMNOS QUE NO TIENEN REPROBADAS
		IF vcResultado = 'Reprobado' THEN
			LET vcResultado = 'R';

		ELSE 
			LET vcResultado = 'A';
		END IF;

		-- La materia no existe en el Plan-Version Actual del Alumno
		IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
			-- Recupero el nombre de la materia en el Plan-Version Actual del Alumno!
			SELECT sga_atrib_mat_plan.nombre_materia
			INTO vcMateriaNombre
			FROM sga_atrib_mat_plan
			WHERE sga_atrib_mat_plan.unidad_academica = pUA
				AND sga_atrib_mat_plan.carrera = vcCarrera
				AND sga_atrib_mat_plan.plan    = vcPlan
				AND sga_atrib_mat_plan.version = vcPlanVersion
				AND sga_atrib_mat_plan.materia = vcMateria ;
		END IF;
      
		-- Escala de Notas
		SELECT sga_det_escala.concepto, sga_det_escala.descripcion
		INTO vcConcepto, vcDescripcionNota
		FROM sga_det_escala
		WHERE sga_det_escala.escala_notas = iEscalaExamen
			AND sga_det_escala.nota = vcNota ;
		LET iFolio = NULL;
		-- Aprobado por Examen
		IF   vcFormaAprobacion = 'Examen' or vcFormaAprobacion =  'Examen equivalente' THEN  
			-- Folio Examen.
			SELECT sga_detalle_acta.folio
			INTO iFolio
			FROM sga_detalle_acta
			WHERE sga_detalle_acta.unidad_academica = pUA
				AND sga_detalle_acta.tipo_acta = vcActaTipo
				AND sga_detalle_acta.acta      = vcActa
				AND sga_detalle_acta.carrera   = vcCarrera
				AND sga_detalle_acta.legajo    = vcLegajo ;
		END IF;
		-- Aprobado por Promocion	
		IF   vcFormaAprobacion = 'Promoción' or vcFormaAprobacion =  'Promoción en otra carrera' THEN  
			SELECT sga_det_acta_promo.folio
			INTO iFolio
			FROM sga_det_acta_promo
			WHERE sga_det_acta_promo.unidad_academica = pUA
				AND sga_det_acta_promo.carrera   = vcCarrera
				AND sga_det_acta_promo.legajo    = vcLegajo
				AND sga_det_acta_promo.acta      = vcActa ;
		END IF;
		IF vcmateria In (	SELECT sga_atrib_mat_plan.materia
				FROM sga_atrib_mat_plan
				WHERE sga_atrib_mat_plan.unidad_academica = pUA
					AND sga_atrib_mat_plan.carrera = vcCarrera
					AND sga_atrib_mat_plan.plan = vcPlan
					AND sga_atrib_mat_plan.version = vcPlanVersion
					AND sga_atrib_mat_plan.materia = vcMateria
					AND sga_atrib_mat_plan.sale_listado = 'S') THEN
			IF vcNivel = 'INTERMEDIO' THEN
				IF vcmateria In  (select mc.materia from sga_titulos tit
					join sga_titulos_plan tp
						join  sga_orientaciones ori
							join sga_ciclos_orient cic
								join sga_materias_ciclo mc
								on cic.ciclo = mc.ciclo		
							on ori.orientacion = cic.orientacion	
							and ori.carrera = cic.carrera
							and ori.plan = cic.plan
							and ori.titulo = cic.titulo
						on tp.carrera =  ori.carrera
						and tp.plan = ori.plan
						and tp.titulo = ori.titulo
					on tit.titulo = tp.titulo
					where tit.nivel = 'INTERMEDIO' and tit.titulo = pTitulo and cic.version = vcPlanVersion) 
				OR vcmateria In  (select  og.materia_optativa from sga_titulos tit
					join sga_titulos_plan tp
						join  sga_orientaciones ori
							join sga_ciclos_orient cic
								join sga_materias_ciclo mc
								INNER join sga_opt_generica og
								on og.materia_generica=mc.materia 
								and og.carrera=vcCarrera
								and og.plan=vcPlan
								and og.version=vcPlanVersion
								on cic.ciclo = mc.ciclo		
							on ori.orientacion = cic.orientacion	
							and ori.carrera = cic.carrera
							and ori.plan = cic.plan
							and ori.titulo = cic.titulo
						on tp.carrera =  ori.carrera
						and tp.plan = ori.plan
						and tp.titulo = ori.titulo
					on tit.titulo = tp.titulo
					where tit.nivel = 'INTERMEDIO' and tit.titulo = pTitulo and cic.version = vcPlanVersion)	
					THEN
						-- Ajuste personal FADU
						IF pNroInscripcion = '22215550' and vcCarrera = '1' and vcPlan = '1996' and pUA = 'FADU' THEN
							LET vcPlan_aux = 'Plan 1985 - RCS Nº 404/19';
						ELSE
							LET vcPlan_aux = vcPlan;
						END IF;

					RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera, vcCarreraNombre, vcPlan_aux, dResolucionFecha, vcResolucionNro,vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, fPromGral, fPromSinAplazos, trim(vcTituloNombre) || trim(vcOrientacion),vcMateria , vcMateriaNombre, dFecha, vcNota, vcConcepto, vcActa, vcActaPromocion, vcNroResolucion, vcFormaAprobacion, iFolio, vcResultado, vcDocTipoDescrip, vdFecha_pedido, vcDescripcionNota, vcTipoTitulo, vcDescripcionTitSec, vcTituloSecExt, vcResolIngreso, vcTituloSuperior, viTipoIngreso, vcLocalidad, vcFechaEgresoStr, vcTipoCarrera, viInstitucion, vcSexo   WITH RESUME ;
				END IF;
			ELSE

				-- Ajuste personal FADU
				IF pNroInscripcion = '22215550' and vcCarrera = '1' and vcPlan = '1996' and pUA = 'FADU' THEN
					let vcPlan_aux = 'Plan 1985 - RCS Nº 404/19';
				ELSE
					LET vcPlan_aux = vcPlan;
				END IF;

			RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera, vcCarreraNombre, vcPlan_aux, dResolucionFecha, vcResolucionNro,vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, fPromGral, fPromSinAplazos, trim(vcTituloNombre) || trim(vcOrientacion),vcMateria, vcMateriaNombre, dFecha, vcNota, vcConcepto, vcActa, vcActaPromocion, vcNroResolucion, vcFormaAprobacion, iFolio, vcResultado, vcDocTipoDescrip, vdFecha_pedido, vcDescripcionNota, vcTipoTitulo, vcDescripcionTitSec, vcTituloSecExt, vcResolIngreso, vcTituloSuperior, viTipoIngreso, vcLocalidad, vcFechaEgresoStr, vcTipoCarrera, viInstitucion, vcSexo WITH RESUME ;
			END IF;
		END IF;
	END FOREACH;


END;
END PROCEDURE;
-- ************************** FIN DEL PROCEDURE sp_ted_1e_dig **************************

revoke execute on "dba".sp820_ted_1e_dig from public;
grant execute on "dba".sp820_ted_1e_dig to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ted_1e_dig to internet; -- Rol de usuario de Internet