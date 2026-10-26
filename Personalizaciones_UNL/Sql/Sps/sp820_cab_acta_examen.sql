CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_cab_acta_examen') THEN
		DROP PROCEDURE sp820_cab_acta_examen;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SP: sp_cab_acta_examen
-- Version 2.0.0
-- Versi?n de Ultima Modificaci?n: 2.03.0, 2.7.0, 2.8.0
-- Descripcion: Recupera los datos de la cabecera del Acta de Examen (Abierta/Cerrada)
-- Fecha: 08/11/2003
--
-- Recibe:     - Unidad Academica
--              - Tipo Acta
--              - Nro. Acta
--	
-- Retorna:     - Datos del Acta de Examen
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP PROCEDURE sp820_cab_acta_examen;
CREATE PROCEDURE "dba".sp820_cab_acta_examen(
   pUnidadAcademica LIKE sga_actas_examen.unidad_academica, 
   pTipoActa  LIKE sga_actas_examen.tipo_acta,
   pActa  LIKE sga_actas_examen.acta)

  RETURNING 
           VARCHAR(5),  -- Unidad Academica
           CHAR(1),     -- Tipo de Acta
           VARCHAR(10), -- Acta
           VARCHAR(5),  -- Materia 
           VARCHAR(255), -- Nombre Materia
           INTEGER,     -- A?o Academico
           VARCHAR(20), -- Turno de examen
           VARCHAR(15), -- Mesa de Examen
           INTEGER,     -- Llamado
           VARCHAR(15), -- Libro de examen
           VARCHAR(10), -- Fecha del Examen  dd/mm/yyyy
           VARCHAR(5),  -- Hora del Examen hh:mm 
           VARCHAR(60), -- Nombre Edificio
           VARCHAR(30), -- Nombre Aula
           INTEGER,     -- Escala de Notas
           VARCHAR(255), -- Observaciones
           INTEGER,        -- Cantidad de  Folios
           VARCHAR(5),   -- Sede
           VARCHAR(255),  -- Nombre Sede
           VARCHAR(60),   -- Nombre Libro
           VARCHAR(1), -- Estado Acta

	VARCHAR(60), -- Nombre UA
	VARCHAR(255), -- Nombre carrera
	VARCHAR(5),  -- Plan
	VARCHAR(255), --Nombre de quien genero el acta
	VARCHAR(15), --Fecha generacion acta
	 INTEGER, -- version
	 INTEGER,  -- version impresa
	INTEGER; -- nro_ult_copia

-- var para el manejo de excepciones
DEFINE  sql_err, isam_err   INTEGER;
DEFINE  error_info          VARCHAR(76);
DEFINE  v_user_error        VARCHAR(10);


-- Variables del procedure
DEFINE  vcLibro			LIKE sga_actas_examen.libro;
DEFINE  vcMateria               LIKE sga_actas_examen.materia;
DEFINE  iAnioAcademico          LIKE sga_actas_examen.anio_academico;
DEFINE  vcTurnoExamen           LIKE sga_actas_examen.turno_examen;
DEFINE  vcMesaExamen            LIKE sga_actas_examen.mesa_examen;
DEFINE  illamado                LIKE sga_actas_examen.llamado;
DEFINE  iEscalaNotas            LIKE sga_actas_examen.escala_notas;
DEFINE  vcObservaciones         LIKE sga_actas_examen.observaciones;
DEFINE  pLegajo                 LIKE sga_docentes.legajo;
DEFINE  vcNombreMateria         VARCHAR(255);
DEFINE  vcNombreEdificio        LIKE sga_edificios.nombre;
DEFINE  vcNombreAula            LIKE sga_aulas.nombre_aula;
DEFINE  vcFecha                 VARCHAR(10);
DEFINE  vcLibroNombre       VARCHAR(60);
DEFINE  vcEstado     CHAR(1);
DEFINE  vcHora                  VARCHAR(5);
DEFINE  vdFecha                 DATE;
DEFINE  vhHora                  DATETIME HOUR TO SECOND;
DEFINE  iFolios                 INTEGER;
DEFINE vcSede LIKE sga_sedes.sede;
DEFINE vcNombreSede LIKE sga_sedes.nombre;

DEFINE vcNombreGeneraActa     varchar(255);
DEFINE vcFechaGen     varchar(30);
DEFINE vcNombreUa like sga_unidades_acad.nombre;
DEFINE vcCarrera like sga_carreras.nombre;
DEFINE vcPlan like sga_planes.plan;
DEFINE  iVersion                 INTEGER;
DEFINE  iVersionImp                 INTEGER;
DEFINE  iNroCopia                 INTEGER;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN

   -- Inicializo las vars que voy a devolver
   LET  vcMateria         = NULL; 
   LET  iAnioAcademico    = NULL; 
   LET  vcTurnoExamen     = NULL; 
   LET  vcMesaExamen      = NULL; 
   LET  illamado          = NULL; 
   LET  vcNombreMateria   = NULL; 
   LET  vcLibroNombre   = NULL; 
   LET  vcCarrera   = NULL; 
   LET  vcPlan   = NULL; 
   LET  vcNombreUa   = NULL; 

   -- Recupero los datos de la cabecera del Acta de Examen
   SELECT sga_actas_examen.materia,
          sga_actas_examen.anio_academico,
          sga_actas_examen.turno_examen,
          sga_actas_examen.mesa_examen,
          sga_actas_examen.llamado,
          sga_actas_examen.libro,
          sga_libros_de_acta.nombre,
          sga_actas_examen.escala_notas,
          sga_actas_examen.observaciones,
          sga_actas_examen.estado,
          nvl(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
          sga_sedes.sede,
          sga_sedes.nombre,
	sga_unidades_acad.nombre,
	nvl(sga_carreras.nombre, ''),
	nvl(sga_mesas_examen.plan, ''),
sga_actas_examen.version,
sga_actas_examen.version_impresa,
sga_actas_examen.nro_ultima_copia

     INTO vcMateria,
          iAnioAcademico,
          vcTurnoExamen,
          vcMesaExamen,
          illamado,
          vcLibro,
          vcLibroNombre,
          iEscalaNotas,
          vcObservaciones,
          vcEstado, 
          vcNombreMateria,
          vcSede,
          vcNombreSede,
		vcNombreUa,
		vcCarrera,
		vcPlan,
	iVersion,
	iVersionImp,
	iNroCopia
     FROM sga_actas_examen,
          sga_mesas_examen,
          sga_materias,
          sga_sedes,
	  sga_unidades_acad,
          OUTER(sga_planes, sga_atrib_mat_plan),
          OUTER sga_libros_de_acta,
		 OUTER sga_carreras
    WHERE sga_actas_examen.unidad_academica = pUnidadAcademica
      AND sga_actas_examen.tipo_acta = pTipoActa
      AND sga_actas_examen.acta = pActa
      AND sga_materias.unidad_academica      = sga_actas_examen.unidad_academica
      AND sga_materias.materia               = sga_actas_examen.materia
      AND sga_actas_examen.unidad_academica = sga_mesas_examen.unidad_academica
      AND sga_actas_examen.materia = sga_mesas_examen.materia
      AND sga_actas_examen.anio_academico = sga_mesas_examen.anio_academico
      AND sga_actas_examen.turno_examen = sga_mesas_examen.turno_examen
      AND sga_actas_examen.mesa_examen = sga_mesas_examen.mesa_examen
      AND sga_planes.unidad_academica = sga_mesas_examen.unidad_academica
      AND sga_planes.carrera = sga_mesas_examen.carrera
      AND sga_planes.plan = sga_mesas_examen.plan
      AND sga_atrib_mat_plan.unidad_academica =sga_planes.unidad_academica
      AND sga_atrib_mat_plan.carrera = sga_planes.carrera
      AND sga_atrib_mat_plan.plan = sga_planes.plan
      AND sga_atrib_mat_plan.version = sga_planes.version_actual
      AND sga_atrib_mat_plan.materia = sga_mesas_examen.materia
      AND sga_mesas_examen.sede = sga_sedes.sede
      AND sga_libros_de_acta.libro = sga_actas_examen.libro

	AND sga_actas_examen.unidad_academica = sga_unidades_acad.unidad_academica
	AND sga_mesas_examen.carrera = sga_carreras.carrera;
	
   IF DBINFO("sqlca.sqlerrd2") > 0 THEN	
      
      LET iFolios  = 1;
      LET vcHora  = '';
      LET vcFecha = '';
      LET vhHora  = NULL;
      LET vdFecha = NULL;
      LET vcNombreEdificio  = NULL;
      LET vcNombreAula  = NULL;

      -- Si no hay folios, retorna 1.       
      IF vcEstado = 'A' THEN
              SELECT MAX(folio)   INTO iFolios   FROM sga_detalle_acta   WHERE unidad_academica = pUnidadAcademica   AND tipo_acta = pTipoActa   AND acta = pActa;
      ELSE
         -- Acta Cerrada, Anulada, Invalidada, Dada de Baja 
        SELECT count(*)   INTO iFolios   FROM sga_folios   WHERE sga_folios.unidad_academica = pUnidadAcademica   AND sga_folios.tipo_acta = pTipoActa   AND sga_folios.acta = pActa;
      END IF;
      IF iFolios IS NULL OR iFolios = 0 THEN
         LET iFolios = 1;   
      END IF;
      
      -- Recupero fecha y Hora del Examen.
      SELECT fecha, hora_inicio , sga_edificios.nombre, sga_aulas.nombre_aula
        INTO vdFecha, vhHora, vcNombreEdificio, vcNombreAula
        FROM sga_llamados_mesa,
             sga_prestamos,
             OUTER sga_aulas,
             OUTER sga_edificios
       WHERE sga_llamados_mesa.unidad_academica = pUnidadAcademica
         AND sga_llamados_mesa.materia          = vcMateria
         AND sga_llamados_mesa.anio_academico   = iAnioacademico
         AND sga_llamados_mesa.turno_examen     = vcTurnoexamen
         AND sga_llamados_mesa.mesa_examen      = vcMesaExamen
         AND sga_llamados_mesa.llamado          = iLlamado
         AND sga_llamados_mesa.prestamo = sga_prestamos.prestamo
         AND sga_edificios.edificio = sga_prestamos.edificio
         AND sga_aulas.edificio = sga_prestamos.edificio
         AND sga_aulas.aula = sga_prestamos.aula;
      
      IF DBINFO("sqlca.sqlerrd2") > 0 THEN
         IF vdFecha IS NOT NULL THEN
            LET vcFecha  = to_char(vdFecha,"%d/%m/%Y");
         END IF;
         IF vhHora IS NOT NULL THEN
            LET vcHora = to_char(vhHora,"%H:%M");
         END IF;
      END IF;	
      
	LET vcNombreGeneraActa  = NULL;
	LET vcFechaGen = NULL;
 	--busco quien genero el acta
	SELECT u.nombre,max(fecha_act) as fecha  INTO vcNombreGeneraActa, vcFechaGen 
	FROM log_actas_examen l, acc_usuarios u
	
	WHERE l.unidad_academica = pUnidadAcademica
      		AND l.tipo_acta = pTipoActa
		AND l.acta = pActa
		AND l.usuario=u.usuario
		AND l.oper="I"
	Group by u.nombre;

      -- Si no encontro nada, devuelve nulos
      RETURN pUnidadAcademica, pTipoActa, pActa, vcMateria, vcNombreMateria, iAnioAcademico, vcTurnoExamen, vcMesaExamen, illamado, vcLibro, vcFecha, vcHora, vcNombreEdificio, vcNombreAula, iEscalaNotas, vcObservaciones, iFolios, vcSede, vcNombreSede, vcLibroNombre, vcEstado, vcNombreUa,	vcCarrera, vcPlan, vcNombreGeneraActa, vcFechaGen, iVersion, iVersionImp, iNroCopia;
      
   END IF;
   
END;
END PROCEDURE;
