CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ted_1e') THEN
		DROP PROCEDURE sp820_ted_1e;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Stored Procedure: sp_ted_1e
-- Version 1.7.0
-- Ultima version de modificacion: 2.02.0, 2.03.0, 2.04.0, 2.6.0
--
-- Certificado Analitico del alumno.
-- **************************************************************************
CREATE PROCEDURE "dba".sp820_ted_1e ( pUA like sga_titulos_otorg.unidad_academica, pNroInscripcion like sga_titulos_otorg.nro_inscripcion, pTitulo like sga_titulos_otorg.titulo )

RETURNING 
	varchar (5),		-- Unidad Academica
	varchar (20),		-- Nro. Expediente
	varchar (15),		-- Legajo
	varchar(120),		-- Nombre Universidad
	varchar(60),		-- Nombre Facultad
	varchar (5),		-- Carrera
	varchar (255),		-- Nombre Carrera
	varchar (5),		-- Plan
	date,			-- Fecha de resolución
	varchar(15),		-- Nro. Resolución Plan
	varchar(30),		-- Apellido
	varchar(30),		-- Nombres
	integer,		-- Tipo de documento
	varchar(15),		-- Nro. de documento
	varchar (10),		-- Nro. inscripcion
	date,			-- fecha de egreso
	float,			-- Promedio gral
	float,			-- Promedio sin aplazos (academico)
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
	varchar(15); 		-- descripcion de la nota		

DEFINE  vcExpedienteNro     varchar(20);
DEFINE  vcLegajo            varchar(15);
DEFINE  vcUnivNombre        varchar(120);
DEFINE  vcFacultadNombre    varchar(60);
DEFINE  vcCarrera           varchar(5);
DEFINE  vcCarreraNombre     varchar(255);
DEFINE  vcCarreraNombreRed  varchar(20);
DEFINE  vcPlan, vcPlanHA              varchar(5);
DEFINE  vcPlanVersion, vcPlanVersionHA       varchar(5);
DEFINE  dResolucionFecha    date;
DEFINE  vcResolucionNro     varchar(15);
DEFINE  vcApellido          varchar(30);
DEFINE  vcNombre            varchar(30);
DEFINE  iDocTipo            integer;
DEFINE  iDocNro             varchar(15);
DEFINE  vcSexo varchar(1);
DEFINE  vcInscripcionNro    varchar(10);
DEFINE  dEgresoFecha        date;
DEFINE  fPromGral           float;
DEFINE  fPromSinAplazos     float;
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

DEFINE vcTieneReprobadas char(1);

DEFINE  vcOrientacion varchar(255);

BEGIN

LET vcTieneReprobadas = 'N';
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
		CASE WHEN ori.nombre is NULL 
		     	THEN '' 
		     ELSE CASE WHEN pUA = 'FCV' 
			       	THEN CASE WHEN pTitulo = '00003' 
					   THEN ': ' || ori.nombre 
					 ELSE '' 
				    END
			       WHEN pUA = 'FHUC'
			       	THEN CASE WHEN pTitulo = 'DH' 
					   THEN ': ' || ori.nombre 
					 ELSE '' 
				    END
			   END 
		END as nombre_orientacion,
		today
	INTO vcCarrera, 
		vcLegajo,
		vcExpedienteNro,
		dEgresoFecha,
		fPromGral,
		fPromSinAplazos,
		vcPlan,
		vcOrientacion,
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
	SELECT sga_carreras.nombre
	INTO vcCarreraNombre
	FROM sga_carreras
	WHERE sga_carreras.unidad_academica = pUA
		AND sga_carreras.carrera = vcCarrera ;
	--------------------------------------------------------------
	-- Descripcion del Plan
	--------------------------------------------------------------
	SELECT sga_planes.fecha_resolucion,
		sga_planes.nro_resolucion,
		sga_planes.version_actual
	INTO dResolucionFecha,
		vcResolucionNro,
		vcPlanVersion
	FROM sga_planes
	WHERE sga_planes.unidad_academica = pUA
		AND sga_planes.carrera = vcCarrera
		AND sga_planes.plan = vcPlan ;
	--------------------------------------------------------------
	-- Datos de la persona
	--------------------------------------------------------------
	SELECT sga_personas.apellido,
		sga_personas.nombres,
		sga_personas.tipo_documento,
		sga_personas.nro_documento,
		sga_personas.nro_inscripcion,
		sga_personas.sexo
	INTO vcApellido,
		vcNombre,
		iDocTipo,
		iDocNro,
		vcInscripcionNro,
		vcSexo
	FROM sga_personas
	WHERE sga_personas.unidad_academica = pUA
		AND sga_personas.nro_inscripcion = pNroInscripcion ;

	SELECT mdp_tipo_documento.desc_abreviada
	INTO vcDocTipoDescrip
	FROM mdp_tipo_documento
	WHERE mdp_tipo_documento.tipo_documento = iDocTipo ;
	--------------------------------------------------------------
	-- Datos del titulo
	--------------------------------------------------------------
	SELECT case vcSexo when '1' then sga_titulos.nombre when '2' then sga_titulos.nombre_femenino else sga_titulos.nombre end, 
		sga_titulos.nivel
	INTO vcTituloNombre, vcNivel
	FROM sga_titulos
	WHERE sga_titulos.unidad_academica = pUA
		AND sga_titulos.titulo = pTitulo ;
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
			LET vcTieneReprobadas = 'S';
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
					RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera, 						vcCarreraNombre,	vcPlan,	dResolucionFecha,	vcResolucionNro,vcApellido, vcNombre, 						iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, fPromGral, fPromSinAplazos, 						trim(vcTituloNombre)||trim(vcOrientacion),vcMateria , vcMateriaNombre, dFecha, vcNota, vcConcepto, vcActa, 						vcActaPromocion, vcNroResolucion, vcFormaAprobacion, iFolio, vcResultado, vcDocTipoDescrip, vdFecha_pedido, vcDescripcionNota WITH RESUME ;
				END IF;
			ELSE
			RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera,	vcCarreraNombre,	vcPlan,	dResolucionFecha,
				vcResolucionNro,vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, fPromGral, fPromSinAplazos,
				trim(vcTituloNombre)||trim(vcOrientacion),vcMateria , vcMateriaNombre, dFecha, vcNota, vcConcepto, vcActa, vcActaPromocion, vcNroResolucion,
				vcFormaAprobacion, iFolio, vcResultado, vcDocTipoDescrip, vdFecha_pedido, vcDescripcionNota
			WITH RESUME ;
			END IF;
		END IF;
	END FOREACH;
-- MANEJO DE ALUMNOS QUE NO TIENEN REPROBADAS
IF vcTieneReprobadas = 'N' THEN
	RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera,	vcCarreraNombre,	vcPlan,	dResolucionFecha,
				vcResolucionNro,vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, fPromGral, fPromSinAplazos, trim(vcTituloNombre)||trim(vcOrientacion), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'R', vcDocTipoDescrip, vdFecha_pedido, NULL;
END IF;


END;
END PROCEDURE;
-- ************************** FIN DEL PROCEDURE sp_ted_1e **************************

revoke execute on "dba".sp820_ted_1e from public;
grant execute on "dba".sp820_ted_1e to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ted_1e to internet; -- Rol de usuario de Internet


