CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certmatdesap') THEN
		DROP PROCEDURE sp820_certmatdesap;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Ultima version de modificacion: 2.0.0
-- Procedure sp_CertMatDesaprob
--  
-- Certificado de Materias Desaprobadas por un  Alumno en una Carrera determinada.
-- Usa el SP: sp_histAcademica (que trae la info de un alumno).
--
-- PERSONALIZACION:
-- Usa el SP: sp820_histAcademica (que trae la info de un alumno).
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_certmatdesap ( pUA LIKE sga_alumnos.unidad_academica, 
	pCarrera LIKE sga_alumnos.carrera, 
	pLegajo LIKE sga_alumnos.legajo,
	pObservaciones VARCHAR(255), 
	pInteresado VARCHAR(255) )
       RETURNING varchar(5), varchar(60), varchar(10), varchar(30), varchar(30), varchar(3), varchar(15), varchar(5), varchar(255), varchar(20), varchar(15), varchar(5), char(1), varchar(5), varchar(100), varchar(20), date, varchar(15), varchar(5), varchar(20), char(1), varchar(10), varchar(10), varchar(15), varchar(5), varchar(5), integer, varchar(15), varchar(255), varchar(255), varchar(255), varchar(255), float, varchar(15), char(1);


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica

-- varchar(60),   -- unidad_academica_nombre U820

-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),  vc_NroDocumento
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
-- varchar(20),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- integer,      -- vc_EscalaNota 
-- varchar(15),  -- vc_NotaDescrip
-- varchar(255), -- pObservaciones
-- varchar(255), -- pInteresado
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre
-- float;        -- vi_Promedio
-- varchar(15); -- concepto_nota
-- char(1); -- si el promedio es por resolucion 609/2010 o no

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
DEFINE vcFormaAprob         VARCHAR(20);
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

DEFINE vc_Concepto LIKE sga_det_escala.concepto;
DEFINE vc_DescNota LIKE sga_det_escala.descripcion;

DEFINE vc_UANombre                 LIKE sga_unidades_acad.nombre;
DEFINE vc_CalidadAlumno LIKE sga_alumnos.calidad;
DEFINE cPromedioResolucion char(1);
DEFINE vplan_version_act	LIKE sga_atrib_mat_plan.version;
DEFINE vcTieneReprobadas char(1);

-- Variables para el manejo de excepciones
DEFINE SQL_Err             integer;
DEFINE ISAM_Err          integer;
DEFINE error_Info          varchar(76);


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
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
   LET cPromedioResolucion = NULL;

   LET vc_Concepto  = NULL ;
   LET vc_DescNota  = NULL ;
   LET vc_UANombre   = NULL ;
   LET vc_calidadAlumno = NULL;
   LET vplan_version_act = NULL;
   LET vcTieneReprobadas = 'N';

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
     INTO vcLocalidadNombre,   vcPaisNombre, vc_UANombre
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
   SELECT sga_carreras.nombre,     sga_alumnos.plan, sga_alumnos.calidad
     INTO  vcCarreraNombre,      vcPlanAlumno, vc_calidadAlumno
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

   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUA, pCarrera, pLegajo, 'S')  INTO iPromedio, cPromedioResolucion;


   -- ejecuto el SP de la historia academica el alumno.
   FOREACH EXECUTE PROCEDURE sp820_histAcademic( pUA, pCarrera, pLegajo ) 
      INTO vcMateria, vcNombreMateria, dFecha, vcResultado, vcNota, vcFormaAprob, vcTipoActa, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, vcCarreraNomRed, vcNombreMateriaRed, iEscalaNota, iEquivalencia, vc_DescNota, vc_Concepto
     
  
      -- Solo devuelve  Materias Reprobadas
      -- El atributo sale listado, se recupera de la versión actual del plan
      IF (vcResultado = 'Reprobado' ) AND vcmateria In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUA
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vcPlanAlumno
							AND sga_atrib_mat_plan.version = vplan_version_act
							AND sga_atrib_mat_plan.materia = vcMateria
							AND sga_atrib_mat_plan.sale_listado = 'S') THEN
          -- Se supone que las materias Homologadas estan siempre aprobadas.
                  
        LET vcNotaDescrip = NULL;
	-- MANEJO DE ALUMNOS QUE NO TIENEN REPROBADAS
	LET vcTieneReprobadas = 'S';
 
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
                                   pObservaciones, pInteresado, vcLocalidadNombre, vcPaisNombre, iPromedio, vc_concepto, cPromedioResolucion WITH RESUME;
   
      END IF; -- Solo materias aprobadas y no Homologadas.
       
   END FOREACH;
-- MANEJO DE ALUMNOS QUE NO TIENEN REPROBADAS
IF vcTieneReprobadas = 'N' THEN
	RETURN pUA, vc_UANombre, vcNroInscripcion, vcPersonaApellido, vcPersonaNombres, vcTipoDocDesAbre, vcNroDocumento, 
                                pCarrera, vcCarreraNombre, vcCarreraNomRed, pLegajo, vcPlanAlumno, vc_calidadAlumno,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
				pObservaciones, pInteresado, vcLocalidadNombre, vcPaisNombre, iPromedio, NULL, cPromedioResolucion;
END IF;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_certmatdesap**********************************
-- execute procedure "dba".sp820_certmatdesap ('FCV','01', '42695413-4', 'a', 'a');
-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_certmatdesap
-- *****************************************************************************
revoke execute on "dba".sp820_certmatdesap from public;
grant execute on "dba".sp820_certmatdesap to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_certmatdesap to internet; -- Rol de usuario de Internet
