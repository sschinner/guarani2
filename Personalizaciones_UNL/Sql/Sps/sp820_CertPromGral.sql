CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certpromgral') THEN
		DROP PROCEDURE sp820_certpromgral;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Procedure sp_CertPromGral
-- Certificado del Promedio de MATERIAS APROBADAS del Alumno en una Carrera.
-- 
-- PERSONALIZACION:
-- Procedure sp820_CertPromGral
-- *****************************************************************************
-- execute PROCEDURE "dba".sp820_CertPromGral ( '10' , '125' , '9000831' , 'gay' , 'fdsf'  ) ; 
CREATE PROCEDURE "dba".sp820_certpromgral ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pObservaciones VARCHAR(255), pInteresado VARCHAR(255) )
       RETURNING varchar(255), varchar(10), varchar(30), varchar(30), varchar(3), varchar(15), varchar(5), varchar(255), varchar(20), varchar(15), varchar(5), varchar(255), varchar(255), varchar(255), varchar(255), varchar(255), float, char(1);


-- Descripcion del Return:
-- varchar(255),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),-- vc_NroDocumento
-- varchar(5),   -- carrera
-- varchar(255),  -- carrera_nombre
-- varchar(20),  -- carrera_nombre_reducido
-- varchar(15),  -- legajo
-- varchar(5),   -- plan_alumno
-- varchar(255), -- pObservaciones
-- varchar(255), -- pInteresado
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_ProvinciaNombre
-- varchar(255), -- vc_PaisNombre
-- float;        -- vi_Promedio
-- char(1); -- si el promedio es por resolucion 609/2010 o no


-- variables de retorno.
DEFINE vc_UA                 LIKE sga_unidades_acad.nombre;
DEFINE vc_NroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vc_Carrera            LIKE sga_carreras.carrera;
DEFINE vc_CarreraNombre      LIKE sga_carreras.nombre;
DEFINE vc_CarreraNomRed      LIKE sga_carreras.nombre_reducido;
DEFINE vc_Legajo             LIKE sga_alumnos.legajo;
DEFINE vc_PlanAlumno         LIKE sga_alumnos.plan;
DEFINE vc_PersonaApellido    LIKE sga_personas.apellido;
DEFINE vc_PersonaNombres     LIKE sga_personas.nombres;
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_NroDocumento       LIKE sga_personas.nro_documento;
DEFINE vc_LocalidadNombre    LIKE mug_localidades.nombre;
DEFINE vc_ProvinciaNombre    LIKE mug_provincias.nombre;
DEFINE vc_PaisNombre         LIKE mug_paises.nombre;
DEFINE vi_Promedio           FLOAT;
DEFINE cPromedioResolucion char(1);

BEGIN

   -- Inicializaciones.
   LET vc_UA                = NULL ;
   LET vc_NroInscripcion    = NULL ;
   LET vc_Carrera           = NULL ;
   LET vc_CarreraNombre     = NULL ;
   LET vc_CarreraNomRed     = NULL ;
   LET vc_Legajo            = NULL ;
   LET vc_PlanAlumno        = NULL ;
   LET vc_PersonaApellido   = NULL ;
   LET vc_PersonaNombres    = NULL ;
   LET vc_TipoDocDesAbre    = NULL ;
   LET vc_NroDocumento      = NULL ;
   LET vc_LocalidadNombre   = NULL ;
   LET vc_ProvinciaNombre   = NULL ;
   LET vc_PaisNombre        = NULL ;
   LET vi_Promedio          = NULL ;
LET cPromedioResolucion = NULL;

   -- datos personales.
   SELECT 
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres
     INTO 
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
   SELECT mug_localidades.nombre,
          mug_paises.nombre,
	sga_unidades_acad.nombre
     INTO vc_LocalidadNombre, 
          vc_PaisNombre,
	vc_Ua
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
          sga_carreras.nombre_reducido,
          sga_alumnos.legajo,
          sga_alumnos.plan
     INTO vc_Carrera,
          vc_CarreraNombre,
          vc_CarreraNomRed,
          vc_Legajo,
          vc_PlanAlumno
     FROM sga_alumnos,
          sga_carreras
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
      AND sga_carreras.carrera = sga_alumnos.carrera ;

   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUA, pCarrera, pLegajo, 'A')
                INTO vi_Promedio, cPromedioResolucion;


   -- retorno final por cada materia.
   RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_CarreraNomRed, vc_Legajo, vc_PlanAlumno, pObservaciones, pInteresado, vc_LocalidadNombre, vc_ProvinciaNombre, vc_PaisNombre, vi_Promedio, cPromedioResolucion WITH RESUME;


END;
END PROCEDURE;
-- ********************************** FIN PROCESO "dba".sp820_CertPromGral **********************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_CertPromGral 
-- *****************************************************************************
revoke execute on "dba".sp820_CertPromGral from public;
grant execute on "dba".sp820_CertPromGral to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_CertPromGral to internet; -- Rol de usuario de Internet