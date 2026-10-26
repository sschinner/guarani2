CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certmataprob') THEN
		DROP PROCEDURE sp820_certmataprob;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Procedure sp820_CertMatAprob
-- Ultima version de modificacion: 2.0.0
-- Certificado de Materias Aprobadas por un  Alumno en una Carrera determinada.
-- Usa el SP: sp820_histAcademic (que trae la info de un alumno).
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_CertMatAprob ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pObservaciones CHAR(400), pInteresado VARCHAR(255), pExterior CHAR(1) )
       RETURNING varchar(5), varchar (60), varchar(10), varchar(60), varchar(60), varchar(3), varchar(15), varchar(5), varchar(255), varchar(20), varchar(15), varchar(5), char (1), varchar(5), varchar(100), varchar(20), date, varchar(15), varchar(5), varchar(255), char(1), varchar(10), varchar(10), varchar(15), varchar(5), varchar(5), integer, varchar(15), char(400), varchar(255), varchar(255), varchar(255), float, CHAR(1), varchar(15), char(1), char(1), integer, integer, varchar(255), integer;


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica

-- varchar(60),   -- unidad_academica_nombre U820

-- varchar(10),  -- nro_inscripcion
-- varchar(60),  -- apellido
-- varchar(60),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),-- vc_NroDocumento
-- varchar(5),   -- carrera
-- varchar(255),  -- carrera_nombre
-- varchar(20),  -- carrera_nombre_reducido
-- varchar(15),  -- legajo
-- varchar(5),   -- plan_alumno

-- char(1), -- calidad_alumno U820

-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- varchar(20),  -- nombre materia reducido
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- varchar(255),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- integer,      -- vc_EscalaNota 
-- varchar(15),  -- vc_NotaDescrip
-- char(400), -- pObservaciones
-- varchar(255), -- pInteresado
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre
-- float;        -- vi_Promedio
-- CHAR(1); -- pExterior
-- varchar(15); -- vcConceptoNota
-- char(1); -- tipo de carrera
-- char(1); -- si el promedio es por resolucion 609/2010 o no

-- integer; -- cantidad de materias del plan
-- integer; -- cantidad de materias obligatorias aprobadas

-- varchar(255); Titilo superior previo
-- integer; Institucion otorgante

-- variables de retorno.

DEFINE vcNroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vcCarreraNombre      LIKE sga_carreras.nombre;
DEFINE vcCarreraNomRed      LIKE sga_carreras.nombre_reducido;
DEFINE vcPlanAlumno         LIKE sga_alumnos.plan;
DEFINE vcPersonaApellido    LIKE sga_personas.apellido;
DEFINE vcPersonaNombres     LIKE sga_personas.nombres;
DEFINE vcTipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vcNroDocumento       LIKE sga_personas.nro_documento;
DEFINE vcMateria            LIKE sga_materias.materia;
DEFINE vcNombreMateria      LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vcNombreMateriaRed      LIKE sga_atrib_mat_plan.nombre_reducido;
DEFINE dFecha             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vcResultado          VARCHAR(15);
DEFINE vcNota               LIKE sga_detalle_acta.nota;
DEFINE vcFormaAprob         VARCHAR(255);
DEFINE vcTipoActa           LIKE sga_actas_examen.tipo_acta;
DEFINE vcActa               LIKE sga_actas_examen.acta;
DEFINE vcActaPromo          LIKE sga_actas_promo.acta;
DEFINE vcNroResolucion           LIKE sga_equiv_operac.nro_resolucion;
DEFINE iEquivalencia           LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcPlan               LIKE sga_atrib_mat_plan.plan;
DEFINE vcVersion            LIKE sga_atrib_mat_plan.version;
DEFINE iEscalaNota         LIKE sga_tipos_materia.escala_examen;
DEFINE vcNotaDescrip        LIKE sga_det_escala.descripcion;
DEFINE vcLocalidadNombre    LIKE mug_localidades.nombre;
DEFINE vcPaisNombre         LIKE mug_paises.nombre;
DEFINE iPromedio           FLOAT;
DEFINE cPromedioResolucion char(1);
DEFINE vi_retorno          SMALLINT;

DEFINE vTipo_Doc integer;
DEFINE vDocumento varchar(20);
DEFINE vCarrera varchar(60);
DEFINE vMat_Plan integer;
DEFINE vMat_Aprob integer;
DEFINE vcCodigoCarrera VARCHAR(5); 

-- U820 ***************************************************************
-- Variables auxiliares personalizadas
-- U820 ***************************************************************

DEFINE vc_UANombre                 LIKE sga_unidades_acad.nombre;
DEFINE vc_ConceptoNota LIKE sga_det_escala.concepto;
DEFINE vc_DescNota LIKE sga_det_escala.descripcion;
DEFINE vc_CalidadAlumno LIKE sga_alumnos.calidad;
DEFINE vc_tipo_carrera char(1);
-- variables auxiliares
DEFINE vc_Aprobacion         VARCHAR(2);
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;

-- Variables para el manejo de excepciones
DEFINE SQL_Err             integer;
DEFINE ISAM_Err          integer;
DEFINE error_Info          varchar(76);

DEFINE vcTituloSuperior varchar(255);
DEFINE viInstitucion integer;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   -- Borra la tabla temporal
   BEGIN
      -- Si no existía, continúa
      ON EXCEPTION IN  (-206)
      END EXCEPTION WITH RESUME ;
      -- Borra la tabla temporal
      DROP TABLE tmp_histacad;
   END
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

-- Inicializaciones.
LET vcNroInscripcion    = NULL ;
LET vcCarreraNombre     = NULL ;
LET vcCarreraNomRed     = NULL ;
LET vcPlanAlumno        = NULL ;
LET vcPersonaApellido   = NULL ;
LET vcPersonaNombres    = NULL ;
LET vcTipoDocDesAbre    = NULL ;
LET vcNroDocumento      = NULL ;
LET vcMateria           = NULL ;
LET vcNombreMateria     = NULL ;
LET vcNombreMateriaRed     = NULL ;
LET dFecha            = NULL ;
LET vcResultado         = NULL ;
LET vcNota              = NULL ;
LET vcFormaAprob        = NULL ;
LET vcTipoActa          = NULL ;
LET vcActa              = NULL ;
LET vcActaPromo         = NULL ;
LET vcNroResolucion          = NULL ;

LET vcPlan              = NULL ;
LET vcVersion           = NULL ;
LET iEscalaNota        = NULL ;

LET vcNotaDescrip       = NULL ;
LET vcLocalidadNombre   = NULL ;
LET vcPaisNombre        = NULL ;
LET iPromedio          = NULL ;
LET vi_retorno          = 0;

LET vc_ConceptoNota = NULL;
LET vc_DescNota = NULL;
LET vc_calidadAlumno = NULL;
LET vc_tipo_carrera = NULL;
LET cPromedioResolucion = NULL;

LET vTipo_Doc 	= NULL;
LET vDocumento 	= NULL;
LET vCarrera 	= NULL;
LET vMat_Plan 	= NULL;
LET vMat_Aprob 	= NULL;

LET  vcCodigoCarrera = NULL;
LET vplan_version_act = NULL;

LET vcTituloSuperior = NULL;
LET viInstitucion = NULL;

   -- datos personales.
   SELECT     sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres
     INTO vcNroInscripcion,
          vcTipoDocDesAbre,
          vcNroDocumento,
          vcPersonaApellido,
          vcPersonaNombres
     FROM sga_alumnos, sga_personas,  mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento ;

   -- datos de la unidad academica.
   SELECT mug_localidades.nombre,   mug_paises.nombre, sga_unidades_acad.nombre
     INTO vcLocalidadNombre,   vcPaisNombre,  vc_UANombre
     FROM sga_unidades_acad,
          mug_localidades,
          mug_dptos_partidos,
          mug_provincias,
          mug_paises
    WHERE mug_localidades.localidad = sga_unidades_acad.localidad
      AND mug_dptos_partidos.dpto_partido = mug_localidades.dpto_partido
      AND mug_provincias.provincia = mug_dptos_partidos.provincia
      AND mug_paises.pais = mug_provincias.pais 
	  AND sga_unidades_acad.unidad_academica = pUA;

   -- datos de la carrera y el alumno.
   SELECT 
	CASE 
		WHEN pUA = 'FICH' and pCarrera = '0003' and sga_alumnos.plan in ('2002', '2014')
		     	THEN 'Tecnicatura en Informática de Gestión'
		WHEN pUA = 'FCE' and pCarrera = '0201' and sga_alumnos.plan in ('0201')
		     	THEN 'Contador Público Nacional' 
		WHEN pUA = 'FCE' and pCarrera = '0207' and sga_alumnos.plan in ('2004', '2007')
		     	THEN 'Tecnicatura en Control y Auditoría Gubernamental' 

		WHEN pUA = 'FIQ' and pCarrera = '00003' and sga_alumnos.plan in ('2009', 'D.T.Q')
		     	THEN 'Doctorado en Tecnología Química' 
		WHEN pUA = 'ISM' and pCarrera = '02' and sga_alumnos.plan in ('2009')
		     	THEN 'Tecnicatura en Arreglos Musicales'
		WHEN pUA = 'FCJS' and pCarrera = 'PG000' and sga_alumnos.plan in ('2016')
		     	THEN 'Especialización en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores'
		-- FADU
		WHEN pUA = 'FADU' and pCarrera = '12' and sga_alumnos.plan in ('2002')
		     	THEN 'Tecnicatura en Interiorismo y Decoración'
		WHEN pUA = 'FADU' and pCarrera = '9' and sga_alumnos.plan in ('2003')
		     	THEN 'Tecnicatura en Composición de Parques y Jardines'

		-- FBCB
		WHEN pUA = 'FBCB' and pCarrera = '004' and sga_alumnos.plan in ('2004')
		     	THEN 'Tecnicatura en Estadística de Salud'

		-- FCA
		WHEN pUA = 'FCA' and pCarrera = '001' and sga_alumnos.plan in ('2003')
		     	THEN 'Tecnicatura en Gestión y Producción Apícola'
		-- FHUC
		WHEN pUA = 'FHUC' and pCarrera = '21' and sga_alumnos.plan in ('2003')
		     	THEN 'Ciclo de Licenciatura en Periodismo y Comunicación'
		WHEN pUA = 'FHUC' and pCarrera = '21' and sga_alumnos.plan in ('2025')
		     	THEN 'Licenciatura en Periodismo y Comunicación - Ciclo de Complementación Curricular'

		    ELSE sga_carreras.nombre
	END as nombre,


sga_alumnos.plan, sga_alumnos.calidad, sga_carreras.tipo_de_carrera
     INTO  vcCarreraNombre,      vcPlanAlumno, vc_calidadAlumno, vc_tipo_carrera 
     FROM sga_alumnos,     sga_carreras
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
      AND sga_carreras.carrera = sga_alumnos.carrera ;

   -- Datos de la versión actual del plan
   SELECT version_actual INTO vplan_version_act
   FROM sga_planes
   WHERE carrera = pCarrera
   AND plan = vcPlanAlumno;

	--------------------------------------------------------------
	-- Datos del titulo superior según sean posgrados o no
	--------------------------------------------------------------
	IF vc_tipo_carrera IN ('P', 'S') THEN
		SELECT super.nombre, acad.institucion
		INTO vcTituloSuperior, viInstitucion
		FROM sga_personas per
			join sga_formacion_acad acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
			join sga_titulos_super super
			on acad.titulo_superior = super.titulo_superior
	
		WHERE per.unidad_academica = pUA
			AND per.nro_inscripcion = vcNroInscripcion
			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
						from  sga_formacion_acad acad1
						where acad1.unidad_academica = pUA
							and acad1.nro_inscripcion = vcNroInscripcion);
	ELSE
		IF vc_tipo_carrera = 'W' THEN
			SELECT acad.alu_otestsup_carr
			INTO vcTituloSuperior
			FROM sga_personas per
			join sga_datos_cen_aux2 acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
				and per.nro_inscripcion  = vcNroInscripcion
				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 
					from  sga_datos_cen_aux2 acad1
					where acad1.unidad_academica = pUA
						and acad1.nro_inscripcion = vcNroInscripcion);
		END IF;
	END IF;

   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUA, pCarrera, pLegajo, 'N')  INTO iPromedio, cPromedioResolucion;
    
   -- recupero la cantidad de materias obligatorias aprobadas y la cantidad de materias obligatorias del plan
   EXECUTE PROCEDURE sp820_can_apro ( vcNroInscripcion, pCarrera) INTO vTipo_Doc, vDocumento, vcCodigoCarrera, vCarrera, vMat_Plan, vMat_Aprob;

   -- ejecuto el SP de la historia academica el alumno.
   FOREACH EXECUTE PROCEDURE sp820_histAcademic ( pUA, pCarrera, pLegajo ) 
      INTO vcMateria, vcNombreMateria, dFecha, vcResultado, vcNota, vcFormaAprob, vcTipoActa, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, vcCarreraNomRed, vcNombreMateriaRed, iEscalaNota, iEquivalencia, vc_DescNota, vc_ConceptoNota


      -- Solo devuelve:  Materias Aprobadas y que no estan no esten HOMOLOGADAS
      -- El atributo sale listado, se recupera de la versión actual del plan
      IF (vcResultado = 'Aprobado'  OR vcResultado =  'Promocionado' ) AND vcFormaAprob <> 'Homologada' 
			AND vcmateria In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUA
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vcPlanAlumno
							AND sga_atrib_mat_plan.version = vplan_version_act
							-- AND sga_atrib_mat_plan.sale_listado = 'S'
							AND sga_atrib_mat_plan.materia = vcMateria) THEN
         LET vi_retorno = 1;         
         LET vcNotaDescrip = NULL;
 
         -- Averiguo la descripcion de la nota!
         IF vcNota IS NULL THEN

            -- seteo en nulos para que no queden valores anteriores.
            LET iEscalaNota   = NULL;
            LET vcNotaDescrip  = NULL;
         ELSE
            
            -- Recupero LA DESCRIPCION DE LA NOTA DE ACUERDO A LA ESCALA SELECCIONADA ANTES.
            SELECT sga_det_escala.descripcion         INTO vcNotaDescrip
              FROM sga_det_escala
             WHERE sga_det_escala.escala_notas = iEscalaNota
               AND sga_det_escala.nota =  vcNota ;
         END IF;

     
         -- retorno final por cada materia.
         RETURN pUA, vc_UANombre, vcNroInscripcion, vcPersonaApellido, vcPersonaNombres, vcTipoDocDesAbre, vcNroDocumento, 
                                   pCarrera, vcCarreraNombre, vcCarreraNomRed, pLegajo, vcPlanAlumno, vc_calidadAlumno,
                                   vcMateria, vcNombreMateria, vcNombreMateriaRed, dFecha, vcResultado, vcNota, vcFormaAprob, 
                                   vcTipoActa, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, iEscalaNota, vcNotaDescrip,
                                   pObservaciones, pInteresado, vcLocalidadNombre, vcPaisNombre, iPromedio, pExterior, vc_ConceptoNota, 
								   vc_tipo_carrera, cPromedioResolucion, vMat_Plan, vMat_Aprob, vcTituloSuperior, viInstitucion  WITH RESUME;
   
      END IF; -- Solo materias aprobadas y no Homologadas.
       
   END FOREACH;

   IF vi_retorno = 0 THEN
      RETURN  pUA, vc_UANombre, vcNroInscripcion, vcPersonaApellido, vcPersonaNombres, vcTipoDocDesAbre, vcNroDocumento, 
                                   pCarrera, vcCarreraNombre, vcCarreraNomRed, pLegajo, vcPlanAlumno, vc_calidadAlumno,
                                   vcMateria, vcNombreMateria, vcNombreMateriaRed, dFecha, vcResultado, vcNota, vcFormaAprob, 
                                   vcTipoActa, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, iEscalaNota, vcNotaDescrip,
                                   pObservaciones, pInteresado, vcLocalidadNombre, vcPaisNombre, iPromedio, pExterior, vc_ConceptoNota, 
								   vc_tipo_carrera, cPromedioResolucion, vMat_Plan, vMat_Aprob, vcTituloSuperior, viInstitucion   WITH RESUME;
   END IF;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_CertMatAprob **********************************

-- execute procedure "dba".sp820_CertMatAprob ('FCJS', '1', '27749383-7', 'a', 'a', '1');


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_CertMatAprob 
-- *****************************************************************************
revoke execute on "dba".sp820_CertMatAprob from public;
grant execute on "dba".sp820_CertMatAprob to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_CertMatAprob to internet; -- Rol de usuario de Internet
