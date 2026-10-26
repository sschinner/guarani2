CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certmatcurs') THEN
		DROP PROCEDURE sp820_certmatcurs;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.6.2
-- Procedure sp820_CertMatCurs
-- Ultima version de modificacion: 2.0.0
-- Certificado de Materias Cursadas por un  Alumno en una Carrera determinada.
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_CertMatCurs ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pObservaciones CHAR(400), pInteresado VARCHAR(255), pExterior VARCHAR(10) DEFAULT 'Vigentes')
       RETURNING varchar(5), varchar(60), varchar(10), varchar(30), varchar(30), varchar(3), varchar(15), varchar(5), varchar(255), varchar(15), varchar(5), char (1), varchar(5), varchar(100), date, date, varchar(15), varchar(5), integer, integer,  integer, varchar(15), varchar(5), varchar(5), integer, char(400), varchar(255), varchar(255), varchar(255), char(1), char(1);

-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(60),   -- unidad_academica_nombre U820
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),-- vc_NroDocumento
-- varchar(5),   -- carrera
-- varchar(255),  -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan_alumno
-- char(1), -- calidad_alumno U820
-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- date,         -- fecha
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- integer, -- acta
-- integer, -- acta promocion
-- integer, -- equivalencia
-- varchar(15)   -- nro resolucion
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- integer,      -- vc_EscalaNota 
-- char(400), -- pObservaciones
-- varchar(255), -- pInteresado
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre
-- VARCHAR(10); -- pExterior
-- char(1); -- tipo de carrera

-- variables de retorno.

DEFINE vcNroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vcCarreraNombre      LIKE sga_carreras.nombre;
DEFINE vcPlanAlumno         LIKE sga_alumnos.plan;
DEFINE vcPersonaApellido    LIKE sga_personas.apellido;
DEFINE vcPersonaNombres     LIKE sga_personas.nombres;
DEFINE vcTipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vcNroDocumento       LIKE sga_personas.nro_documento;
DEFINE vcMateria            LIKE sga_materias.materia;
DEFINE vcNombreMateria      LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE dFecha             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE dFecha2             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vcResultado          VARCHAR(15);
DEFINE vcNota               LIKE sga_detalle_acta.nota;
DEFINE vcActa               LIKE sga_actas_cursado.acta;
DEFINE vcActaPromo          LIKE sga_actas_promo.acta;
DEFINE vcNroResolucion           LIKE sga_equiv_operac.nro_resolucion;
DEFINE iEquivalencia           LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcPlan               LIKE sga_atrib_mat_plan.plan;
DEFINE vcVersion            LIKE sga_atrib_mat_plan.version;
DEFINE iEscalaNota         LIKE sga_tipos_materia.escala_examen;
DEFINE vcLocalidadNombre    LIKE mug_localidades.nombre;
DEFINE vcPaisNombre         LIKE mug_paises.nombre;

-- U820 ***************************************************************
-- Variables auxiliares personalizadas
-- U820 ***************************************************************
DEFINE vc_UANombre                 LIKE sga_unidades_acad.nombre;
DEFINE vc_CalidadAlumno LIKE sga_alumnos.calidad;
DEFINE vc_tipo_carrera char(1);
DEFINE vc_Aprobacion         VARCHAR(2);
DEFINE	vplan_version_act	LIKE sga_atrib_mat_plan.version;

-- Variables para el manejo de excepciones
DEFINE SQL_Err             integer;
DEFINE ISAM_Err          integer;
DEFINE error_Info          varchar(76);


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
   LET vcPlanAlumno        = NULL ;
   LET vcPersonaApellido   = NULL ;
   LET vcPersonaNombres    = NULL ;
   LET vcTipoDocDesAbre    = NULL ;
   LET vcNroDocumento      = NULL ;
   LET vcMateria           = NULL ;
   LET vcNombreMateria     = NULL ;
   LET dFecha            = NULL ;
   LET dFecha2            = NULL ;
   LET vcResultado         = NULL ;
   LET vcNota              = NULL ;
   LET vcActa              = NULL ;
   LET vcActaPromo         = NULL ;
   LET vcNroResolucion          = NULL ;
   LET vcPlan              = NULL ;
   LET vcVersion           = NULL ;
   LET iEscalaNota        = NULL ;
   LET iEquivalencia        = NULL ;
   LET vcLocalidadNombre   = NULL ;
   LET vcPaisNombre        = NULL ;
   LET vc_calidadAlumno = NULL;
   LET vc_tipo_carrera = NULL;
LET vplan_version_act = NULL;

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
   SELECT sga_carreras.nombre,     sga_alumnos.plan, sga_alumnos.calidad, sga_carreras.tipo_de_carrera
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

   -- ejecuto el SP de la historia academica el alumno.
   FOREACH 
	SELECT  vw.materia, atm.nombre_materia, vw.fecha_regularidad, vw.fin_vigencia_regul, vw.resultado, vw.nota, vw.acta_regular, vw.acta_promocion, vw.nro_resolucion, vw.plan, vw.version, vw.escala_notas, vw.equivalencia
      INTO vcMateria, vcNombreMateria, dFecha, dFecha2, vcResultado, vcNota, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, iEscalaNota, iEquivalencia
	FROM sga_cursadas vw
		JOIN sga_atrib_mat_plan atm
		ON vw.carrera = atm.carrera
			and vw.plan = atm.plan
			and vw.materia = atm.materia
			and vw.version = atm.version
	WHERE vw.resultado = 'A'
		AND (vw.fin_vigencia_regul >= today OR pExterior = 'Todas')
		AND vw.unidad_academica = pUA
      		AND vw.carrera = pCarrera
      		AND vw.legajo  = pLegajo
	        -- El atributo sale listado, se recupera de la versión actual del plan
		AND vw.materia In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUA
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vcPlanAlumno
							AND sga_atrib_mat_plan.version = vplan_version_act
							AND sga_atrib_mat_plan.materia = vw.materia
							AND sga_atrib_mat_plan.sale_listado = 'S')
      
         -- retorno final por cada materia.
         RETURN pUA, vc_UANombre, vcNroInscripcion, vcPersonaApellido, vcPersonaNombres, vcTipoDocDesAbre, vcNroDocumento, 
                                   pCarrera, vcCarreraNombre, pLegajo, vcPlanAlumno, vc_calidadAlumno, vcMateria, vcNombreMateria, dFecha, dFecha2, vcResultado, vcNota, vcActa, vcActaPromo, iEquivalencia, vcNroResolucion, vcPlan, vcVersion, iEscalaNota, pObservaciones, pInteresado, vcLocalidadNombre, vcPaisNombre, pExterior, vc_tipo_carrera WITH RESUME;
       
   END FOREACH;

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_CertMatCurs **********************************

-- execute procedure "dba".sp820_CertMatCurs ('FICH', '03', '28673244-5', 'a', 'a');   --, '0');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_CertMatCurs
-- *****************************************************************************
revoke execute on "dba".sp820_CertMatCurs from public;
grant execute on "dba".sp820_CertMatCurs to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_CertMatCurs to internet; -- Rol de usuario de Internet
