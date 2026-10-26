CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certexamen') THEN
		DROP PROCEDURE sp820_certexamen;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.5.2
-- Procedure sp820_CertExamen
-- Autor: Jorge Azcoaga
-- Certificado de Examen de  Alumno.
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_certexamen ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pActa Like sga_detalle_acta.acta, pObservaciones varchar(255), pInteresado VARCHAR(255) )
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(3), varchar(15), varchar(5), varchar(255), varchar(15), varchar(5), varchar(100), date, char(1), varchar(10), varchar(10), varchar(5), varchar(5), varchar(255), varchar(255), varchar(60), varchar(255), varchar(255);


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),-- vc_NroDocumento
-- varchar(5),   -- carrera
-- varchar(255),  -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan_alumno
-- varchar(100), -- nombre de la materia
-- date,         -- fecha
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- varchar(255), -- pInteresado
-- varchar(255), -- pObservaciones
-- varchar(60),  -- vc_UANombre
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre



-- variables de retorno.
DEFINE vc_UA                 LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vc_Carrera            LIKE sga_carreras.carrera;
DEFINE vc_CarreraNombre      LIKE sga_carreras.nombre;

DEFINE vc_Legajo             LIKE sga_alumnos.legajo;
DEFINE vc_PlanAlumno         LIKE sga_alumnos.plan;
DEFINE vc_PersonaApellido    LIKE sga_personas.apellido;
DEFINE vc_PersonaNombres     LIKE sga_personas.nombres;
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_NroDocumento       LIKE sga_personas.nro_documento;

DEFINE vc_MateriaNombre      LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_Materia	LIKE sga_atrib_mat_plan.materia;
DEFINE vdt_Fecha             LIKE sga_detalle_acta.fecha_de_examen;

DEFINE vc_TipoActa           LIKE sga_actas_examen.tipo_acta;
DEFINE vc_Acta               LIKE sga_actas_examen.acta;
DEFINE vc_ActaPromo          LIKE sga_actas_promo.acta;


DEFINE vc_Plan               LIKE sga_atrib_mat_plan.plan;
DEFINE vc_Version            LIKE sga_atrib_mat_plan.version;
DEFINE vc_LocalidadNombre    LIKE mug_localidades.nombre;
DEFINE vc_PaisNombre         LIKE mug_paises.nombre;
DEFINE vc_UANombre           LIKE sga_unidades_acad.nombre;


BEGIN

   -- Inicializaciones.
   LET vc_UA                = NULL ;
   LET vc_NroInscripcion    = NULL ;
   LET vc_Carrera           = NULL ;
   LET vc_CarreraNombre     = NULL ;

   LET vc_Legajo            = NULL ;
   LET vc_PlanAlumno        = NULL ;
   LET vc_PersonaApellido   = NULL ;
   LET vc_PersonaNombres    = NULL ;
   LET vc_TipoDocDesAbre    = NULL ;
   LET vc_NroDocumento      = NULL ;

   LET vc_MateriaNombre     = NULL ;
   LET vc_Materia = NULL;
   LET vdt_Fecha            = NULL ;
   LET vc_TipoActa          = NULL ;

   LET vc_Acta              = NULL ;
   LET vc_ActaPromo         = NULL ;

   LET vc_Plan              = NULL ;
   LET vc_Version           = NULL ;
   LET vc_LocalidadNombre   = NULL ;
   LET vc_PaisNombre        = NULL ;
   LET vc_UANombre          = NULL ;

   -- datos personales.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres
     INTO vc_UA,
          vc_NroInscripcion,
          vc_TipoDocDesAbre,
          vc_NroDocumento,
          vc_PersonaApellido,
          vc_PersonaNombres
     FROM sga_personas,
          sga_alumnos,
          mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento ;

   -- datos de la unidad academica.
   SELECT sga_unidades_acad.nombre
     INTO vc_UANombre
     FROM sga_unidades_acad
    WHERE sga_unidades_acad.unidad_academica = pUA;
   
   SELECT mug_localidades.nombre,
          mug_paises.nombre
     INTO vc_LocalidadNombre, 
          vc_PaisNombre
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
   SELECT sga_carreras.carrera,
          sga_carreras.nombre,
          sga_alumnos.legajo,
          sga_alumnos.plan
     INTO vc_Carrera,
          vc_CarreraNombre,
          vc_Legajo,
          vc_PlanAlumno
     FROM sga_alumnos,
          sga_carreras
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
      AND sga_carreras.carrera = sga_alumnos.carrera ;

  -- datos del examen
  SELECT act.materia, det.fecha_de_examen, det.plan, det.version INTO vc_Materia, vdt_Fecha, vc_Plan, vc_Version
  FROM sga_actas_examen act
	join sga_detalle_acta  det
	on act.acta = det.acta
  where act.acta = pActa
	and det.carrera = pcarrera
	and det.legajo = plegajo;

     
         -- *** TRAIGO EL NOMBRE LARGO DE LA MATERIA.
         SELECT sga_atrib_mat_plan.nombre_materia
           INTO vc_MateriaNombre
           FROM sga_atrib_mat_plan
          WHERE sga_atrib_mat_plan.unidad_academica = pUA
            AND sga_atrib_mat_plan.carrera = vc_Carrera
            AND sga_atrib_mat_plan.plan = vc_Plan
            AND sga_atrib_mat_plan.version = vc_Version
            AND sga_atrib_mat_plan.materia = vc_Materia ;    
            
         -- retorno final por cada materia.
         RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_PlanAlumno, vc_MateriaNombre, vdt_Fecha, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_Plan, vc_Version, pInteresado, pObservaciones, vc_UANombre, vc_LocalidadNombre, vc_PaisNombre;
       

END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_certexamen **********************************

-- *****************************************************************************
-- Permisos del procedimiento  "dba".sp820_certexamen
-- *****************************************************************************
revoke execute on  "dba".sp820_certexamen from public;
grant execute on  "dba".sp820_certexamen to guarani; -- Rol de usuarios de Gestion
grant execute on  "dba".sp820_certexamen to internet; -- Rol de usuario de Internet