CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_insccursadas') THEN
		DROP PROCEDURE sp_insccursadas;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- REcupera las Inscripciones a cursadas de materias de los Periodos lectivos Actuales. 
-- Es decir periodos que no han finalizado.
-- 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".sp_inscCursadas (
       pUnidadAcademica  LIKE sga_personas.unidad_academica,
       pNroInscripcion   LIKE sga_personas.nro_inscripcion,
       pEstado           char(1) DEFAULT 'T',      -- Activa/ Baja/ Pendiente/ Todas
	pActualesHistorico char(1) DEFAULT 'A'
 )

RETURNING varchar(5),    -- unidad academica
          varchar(5),    -- carrera
          varchar(15),   -- legajo
          integer,       -- comision
          varchar(5),    -- plan
          varchar(5),    -- materia
          varchar(20),   -- calidad Insc
          date,          -- fecha Insc
          varchar(20),   -- periodo lectivo
          integer,       -- ano academico
          varchar(20),   -- nro. transaccion
          varchar(20),   -- estado
          varchar(15),   -- comision nombre
          varchar(15),   -- catedra nombre
          varchar(255),   -- carrera nombre
          varchar(255),  -- materia nombre Reducido(20)
          varchar(100),  -- alumno nombre          
          varchar(20),   -- interfase
          varchar(10),   -- Turno de la Comisión
          integer,       -- Créditos de la materia
	varchar(100), -- nombre reducido materia
	varchar(5), -- sede
	varchar(255); -- nombre sede

/*  Recupera las Inscripciones a Cursadas en cualquier periodo activo de una persona ordenadas por carrera
   -- NOTA: los estados posibles en la tabla son Activa/ Baja/ Pendiente/ Todas
   --             En la consulta usat T - Todas
   --             Para la consulta usar D que significa A - Activa o P - Pendiente
*/
-- Modificaciones:
-- 19/05/2000 : se agrego un estado en la tabla sga_insc_cursadas

   DEFINE vcUnidadAcademica  LIKE sga_alumnos.unidad_academica;
   DEFINE vcCarrera          LIKE sga_alumnos.carrera;
   DEFINE vcLegajo           LIKE sga_alumnos.legajo;
   DEFINE iComision          LIKE sga_insc_cursadas.comision;
   DEFINE iPlan              LIKE sga_insc_cursadas.plan;
   DEFINE vcCalidadInscDesc  VARCHAR(20);
   DEFINE dFecInsc           LIKE sga_insc_cursadas.fecha_inscripcion;
   DEFINE vcEstadoDesc       VARCHAR(20);
   DEFINE vcMateria          LIKE sga_comisiones.materia;
   DEFINE iAnioAcademico     LIKE sga_comisiones.anio_academico;
   DEFINE vcPerLect          LIKE sga_comisiones.periodo_lectivo;
   DEFINE vcNroTransaccion   LIKE sga_insc_cursadas.nro_transaccion;
   DEFINE vcComDesc          LIKE sga_comisiones.nombre;
   DEFINE vcCatedra          LIKE sga_comisiones.catedra;
   DEFINE vcTurnoComision    LIKE sga_comisiones.turno;
   DEFINE vcCarreraDesc      LIKE sga_carreras.nombre;
   DEFINE vcMateriaDescRed   LIKE sga_atrib_mat_plan.nombre_reducido;
   DEFINE vcAlumnoNombre     VARCHAR(100);
   DEFINE vcInterfase        LIKE par_interfaces.nombre;
   DEFINE vcCreditos         LIKE sga_atrib_mat_plan.credito;
DEFINE vc_MateriaNomRed      LIKE sga_materias.nombre_reducido;
DEFINE vc_sede	           LIKE sga_sedes.sede;
DEFINE vc_nomsede	           LIKE sga_sedes.nombre;




-- recupera las Inscripciones a Cursadas vigentes de una persona
BEGIN

   LET vcUnidadAcademica   = NULL;
   LET vcCarrera           = NULL;
   LET vcLegajo            = NULL;
   LET iComision           = NULL;
   LET iPlan               = NULL;
   LET vcCalidadInscDesc   = NULL;
   LET dFecInsc            = NULL;
   LET vcEstadoDesc        = NULL;
   LET vcMateria           = NULL;
   LET iAnioAcademico      = NULL;
   LET vcPerLect           = NULL;
   LET vcComDesc           = NULL;
   LET vcCatedra           = NULL;
   LET vcCarreraDesc       = NULL;
   LET vcMateriaDescRed    = NULL;
   LET vcAlumnoNombre      = NULL;
   LET vcInterfase         = NULL;
   LET vcNroTransaccion    = NULL;

LET vc_MateriaNomRed        = NULL;
LET vc_sede        = NULL;
LET vc_nomsede        = NULL;
   
   SELECT TRIM(sga_personas.apellido) || ', ' || sga_personas.nombres
     INTO vcAlumnoNombre
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;
   
   
       FOREACH
        SELECT sga_alumnos.unidad_academica,
               sga_alumnos.carrera,
               sga_alumnos.legajo,
               sga_insc_cursadas.comision,
               sga_insc_cursadas.plan,
               sga_comisiones.materia,
               DECODE(sga_insc_cursadas.calidad_insc, 'R', 'Regular', 'P', 'Promocional'),
               sga_insc_cursadas.fecha_inscripcion,
               sga_comisiones.periodo_lectivo,
               sga_comisiones.anio_academico,
               sga_insc_cursadas.nro_transaccion,
               -- DECODE(sga_insc_cursadas.estado, 'A', 'Activa', 'P', 'Pendiente', 'B', 'Baja', 'E', 'Exceptuado'),

	-- U820 ****************************
	-- Setear el estado según lo disponga FCJS:
	-- Se muestra simpre pendiente de proceso hasta que alumnado disponga publicar el ranking. Para la materia Practica Profesional Final (233)
	--'Pendiente de Proceso' as estado,
	
	CASE 
		WHEN (sga_comisiones.materia = '233') THEN 'Consultar en Extensión FCJS'
		WHEN (sga_comisiones.materia = '234') THEN 'Consultar en Extensión FCJS'
		WHEN (u820_rank_curs.ingreso = 'S') THEN '<b>INGRESO</b>'
		
		WHEN (u820_rank_curs.ingreso = 'N') 
				THEN (CASE	WHEN u820_rank_curs.estado = 'H' THEN 'Sup. Horaria'
				WHEN u820_rank_curs.estado = 'C' THEN 'Supera Cant. Materia'
				WHEN u820_rank_curs.estado = 'A' THEN 'Supera Cupo Comision'
				WHEN u820_rank_curs.estado = 'O' THEN 'Ingreso a Otra Com.'
				WHEN u820_rank_curs.estado = 'U' THEN 'Supera Cupo Comision'
				END)
		
		WHEN (u820_rank_curs.ingreso IS NULL) 
				THEN (CASE 	WHEN sga_insc_cursadas.estado IN ( 'P', 'A', 'E') THEN 'Pendiente de Proceso' 
				WHEN sga_insc_cursadas.estado  = 'B' THEN 'Baja' 
				WHEN sga_insc_cursadas.estado  = 'R' THEN 'Rechazado' 
				END) 
		END as estado,
		
	-- U820 ****************************
               sga_comisiones.nombre,
               sga_comisiones.turno,
               NVL(sga_comisiones.catedra, 'NO informada'),
               sga_carreras.nombre,
               sga_atrib_mat_plan.nombre_reducido,
               par_interfaces.nombre,
               sga_atrib_mat_plan.credito,
               sga_atrib_mat_plan.nombre_reducido,
		sga_sedes.sede,
		sga_sedes.nombre

          INTO vcUnidadAcademica,
               vcCarrera,
               vcLegajo,
               iComision,
               iPlan,
               vcMateria,
               vcCalidadInscDesc,
               dFecInsc,
               vcPerLect,
               iAnioAcademico,
               vcNroTransaccion,
               vcEstadoDesc,
               vcComDesc,
               vcTurnoComision,
               vcCatedra,
               vcCarreraDesc,
               vcMateriaDescRed,
               vcInterfase,
               vcCreditos,
	vc_MateriaNomRed,
	vc_sede,
	vc_nomsede

          FROM sga_alumnos,
               sga_insc_cursadas,
               sga_comisiones,
               sga_periodos_lect,
               sga_carreras,
               sga_planes,
               sga_atrib_mat_plan,
               par_interfaces, 
	sga_sedes, OUTER u820_rank_curs

         WHERE sga_alumnos.unidad_academica    = pUnidadAcademica
           AND sga_alumnos.nro_inscripcion     = pNroInscripcion

           AND sga_carreras.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_carreras.carrera            = sga_alumnos.carrera

           AND sga_insc_cursadas.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_insc_cursadas.carrera            = sga_alumnos.carrera
           AND sga_insc_cursadas.legajo             = sga_alumnos.legajo

           AND sga_insc_cursadas.comision           = sga_comisiones.comision

           AND sga_planes.unidad_academica  = sga_alumnos.unidad_academica
           AND sga_planes.carrera           = sga_alumnos.carrera
           AND sga_planes.plan              = sga_alumnos.plan

           AND sga_atrib_mat_plan.unidad_academica  = sga_planes.unidad_academica
           AND sga_atrib_mat_plan.carrera           = sga_planes.carrera
           AND sga_atrib_mat_plan.plan              = sga_planes.plan
           AND sga_atrib_mat_plan.version           = sga_planes.version_actual
           AND sga_atrib_mat_plan.materia           = sga_comisiones.materia

           AND sga_insc_cursadas.interfaz        = par_interfaces.interfaz

           AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
           AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo

	AND sga_comisiones.sede = sga_sedes.sede

           AND TODAY                            <= sga_periodos_lect.fecha_fin	

           AND ( sga_insc_cursadas.estado = pEstado  OR pEstado='T' OR DECODE (sga_insc_cursadas.estado, 'P', 'N', 'A', 'N', 'R', 'N') ='N')

	AND sga_insc_cursadas.legajo = u820_rank_curs.legajo
	AND sga_insc_cursadas.comision = u820_rank_curs.comision

         ORDER BY sga_carreras.nombre, sga_insc_cursadas.fecha_inscripcion, sga_comisiones.materia


        -- si no encontro nada, devuelve valores iniciales.
        RETURN vcUnidadAcademica,
               vcCarrera,
               vcLegajo,
               iComision,
               iPlan,
               vcMateria,
               vcCalidadInscDesc,
               dFecInsc,
               vcPerLect,
               iAnioAcademico,
               vcNroTransaccion,
               vcEstadoDesc,
               vcComDesc,
               vcCatedra,
               vcCarreraDesc,
               vcMateriaDescRed,
               vcAlumnoNombre,
               vcInterfase,
               vcTurnoComision,
               vcCreditos, 
	vc_MateriaNomRed,
	vc_sede,
	vc_nomsede  WITH RESUME;
   END FOREACH ;

END;

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_inscCursadas ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_inscCursadas 
-- *****************************************************************************
revoke execute on "dba".sp_inscCursadas from public;
grant execute on "dba".sp_inscCursadas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_inscCursadas to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute PROCEDURE "dba".sp_inscCursadas ( 'FCJS', '00078754', "T" );