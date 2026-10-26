CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_insccuralu') THEN
		DROP PROCEDURE sp_insccuralu;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *************************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Procedure sp_InscCurAlu
-- 
-- Reporte de Materias en las que se inscribio el Alumno.
-- Usa el SP: sp_inscCursadas (trae las materias en las que se inscribio la persona).
-- *************************************************************************************

-- EXECUTE PROCEDURE sp_insccuralu ('FADU', '5' , 0, '25077182');

CREATE PROCEDURE "dba".sp_insccuralu ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pTipoDocumento LIKE sga_personas.tipo_documento, pDocumento LIKE sga_personas.nro_documento)
RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(60), varchar(15), varchar(5), integer, varchar(15), varchar(5), varchar(100), varchar(20), date, integer, varchar(20), varchar(20), varchar(15), varchar(10),integer;


-- Descripcion del RETURN:
-- varchar(5),   -- vc_UA
-- varchar(10),  -- vc_NroInscripcion
-- varchar(30),  -- vc_PersonaNombres
-- varchar(30),  -- vc_PersonaApellido
-- varchar(5),   -- vc_Carrera
-- varchar(60),  -- vc_CarreraNombre
-- varchar(15),  -- vc_Legajo
-- varchar(5),   -- plan
-- integer,      -- comision
-- varchar(15),  -- comision nombre
-- varchar(5),   -- vc_Materia
-- varchar(100), -- vc_MateriaNombre
-- varchar(20),   -- calidad Insc
-- date,          -- fecha Insc
-- integer,       -- ano academico
-- varchar(20),   -- periodo lectivo
-- varchar(20),   -- estado
-- varchar(15),   -- catedra nombre
-- varchar(10)   -- Turno de la Comisión
-- integer;	-- Créditos



DEFINE vc_UA                 LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vc_PersonaNombres     LIKE sga_personas.nombres;
DEFINE vc_PersonaApellido    LIKE sga_personas.apellido;
DEFINE vc_Carrera            LIKE sga_carreras.carrera;
DEFINE vc_CarreraNombre      LIKE sga_carreras.nombre;
DEFINE vc_Legajo             LIKE sga_alumnos.legajo;
DEFINE vc_Materia            LIKE sga_materias.materia;
DEFINE vc_MateriaNombre      LIKE sga_materias.nombre;
DEFINE vi_Comision           LIKE sga_comisiones.comision;
DEFINE vc_Plan               LIKE sga_alumnos.plan;
DEFINE vc_Calidad            VARCHAR(20); --LIKE sga_insc_cursadas.calidad_insc;
DEFINE vd_Fecha              LIKE sga_insc_cursadas.fecha_inscripcion;
DEFINE vc_PeriodoLectivo     LIKE sga_comisiones.periodo_lectivo;
DEFINE vi_AnioAcademico      LIKE sga_comisiones.anio_academico;
DEFINE vc_NroTransaccion     LIKE sga_insc_cursadas.nro_transaccion;
DEFINE vc_Estado             VARCHAR(20); --LIKE sga_insc_cursadas.estado;
DEFINE vc_ComisionNombre     LIKE sga_comisiones.nombre;
DEFINE vc_CatedraNombre      LIKE sga_comisiones.catedra;
DEFINE vcMateriaDesc   LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_MateriaNomRed      LIKE sga_materias.nombre_reducido;
DEFINE vc_AlumnoNombre       VARCHAR(100);
DEFINE vc_Interfaz           LIKE par_interfaces.nombre;
DEFINE vc_Turno              LIKE sga_comisiones.turno;
DEFINE vc_creditos           LIKE sga_atrib_mat_plan.credito;

DEFINE aux_legajo LIKE sga_alumnos.legajo;
DEFINE vcSede LIKE sga_sedes.sede;
DEFINE vcNombreSede LIKE sga_sedes.nombre;

BEGIN


-- inicializaciones.
LET vc_UA               = NULL;
LET vc_NroInscripcion   = NULL;
LET vc_PersonaNombres   = NULL;
LET vc_PersonaApellido  = NULL;
LET vc_Carrera          = NULL;
LET vc_CarreraNombre    = NULL;
LET vc_Legajo           = NULL;
LET vc_Materia          = NULL;
LET vc_MateriaNombre    = NULL;
LET vi_Comision         = NULL;
LET vc_Plan             = NULL;
LET vc_Calidad          = NULL;
LET vd_Fecha            = NULL;
LET vc_PeriodoLectivo   = NULL;
LET vi_AnioAcademico    = NULL;
LET vc_NroTransaccion   = NULL;
LET vc_Estado           = NULL;
LET vc_ComisionNombre   = NULL;
LET vc_CatedraNombre    = NULL;
LET vcMateriaDesc    = NULL;
LET vc_MateriaNomRed    = NULL;
LET vc_Interfaz         = NULL;
LET vc_Turno            = NULL;
LET aux_legajo	= NULL;

-- datos de la persona.
SELECT sga_personas.nro_inscripcion
  INTO vc_NroInscripcion
  FROM sga_personas
 WHERE sga_personas.unidad_academica = pUA
   AND sga_personas.tipo_documento = pTipoDocumento
   AND sga_personas.nro_documento = pDocumento ; 

SELECT sga_personas.nombres,
       sga_personas.apellido
  INTO vc_PersonaNombres, vc_PersonaApellido
  FROM sga_personas
 WHERE unidad_academica = pUA
   AND nro_inscripcion = vc_NroInscripcion ;

SELECT sga_alumnos.legajo 
  INTO aux_legajo
 FROM sga_alumnos
 WHERE unidad_academica = pUA
 AND carrera = pCarrera
 AND nro_inscripcion = vc_NroInscripcion ;


-- busco las materias en las que se inscribió.
FOREACH EXECUTE PROCEDURE sp_inscCursadas ( pUA, vc_NroInscripcion, 'T')
   INTO vc_UA, vc_Carrera, vc_Legajo, vi_Comision, vc_Plan, vc_Materia, vc_Calidad, vd_Fecha, vc_PeriodoLectivo, vi_AnioAcademico, vc_NroTransaccion, vc_Estado, vc_ComisionNombre, vc_CatedraNombre, vc_CarreraNombre, vcMateriaDesc, vc_AlumnoNombre, vc_Interfaz, vc_Turno,vc_creditos, vc_MateriaNomRed, vcSede, vcNombreSede
   
   IF (vc_Carrera = pCarrera) AND (vc_Legajo = aux_Legajo) THEN
      
      -- averiguo el nombre completo de la materia.
      SELECT sga_atrib_mat_plan.nombre_materia
        INTO vc_MateriaNombre
        FROM sga_planes,
             sga_atrib_mat_plan
       WHERE sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
         AND sga_atrib_mat_plan.carrera = sga_planes.carrera
         AND sga_atrib_mat_plan.plan = sga_planes.plan
         AND sga_atrib_mat_plan.version = sga_planes.version_actual
         AND sga_atrib_mat_plan.materia = vc_Materia
         AND sga_planes.unidad_academica = vc_UA
         AND sga_planes.carrera = vc_Carrera
         AND sga_planes.plan = vc_Plan ;
      
      -- devuelvo las filas del reporte.
      RETURN vc_UA, vc_NroInscripcion, vc_PersonaNombres, vc_PersonaApellido, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Plan, vi_Comision, vc_ComisionNombre, vc_Materia, vc_MateriaNombre, vc_Calidad, vd_Fecha, vi_AnioAcademico, vc_PeriodoLectivo, vc_Estado, vc_CatedraNombre, vc_Turno,vc_creditos WITH RESUME;
      
   END IF;

END FOREACH;

END; 

END PROCEDURE;
-- ********************************** FIN PROCESO sp820_InscCurAlu **********************************
-- **********************************************************************

-- *****************************************************************************
-- Permisos del procedimiento
-- *****************************************************************************
revoke execute on "dba".sp_insccuralu from public;
grant execute on "dba".sp_insccuralu to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_insccuralu to siguv_consulta; -- Rol de usuarios de SIGUV
grant execute on "dba".sp_insccuralu to ue_siguv_guarani; -- Rol de usuarios de SIGUV
