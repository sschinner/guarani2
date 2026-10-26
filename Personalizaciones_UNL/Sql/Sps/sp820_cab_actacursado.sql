CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_cab_actacursado') THEN
		DROP PROCEDURE sp820_cab_actacursado;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure: sp_cab_actacursado;
-- Version: 2.0.0, 2.8.0
-- Recupera la cabecera del Acta de Regulares (Abierta o Cerrada) y si existe la cabecera del Acta de Promocion
--
-- Recibe: Un Acta de Regulares
--
-- Retorna: datos del Acta de Regulares y Promocion.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- DROP PROCEDURE sp820_cab_actacursado;
CREATE PROCEDURE "dba".sp820_cab_actacursado(
   pUA LIKE sga_actas_cursado.unidad_academica,
   pActaReg  LIKE sga_actas_cursado.acta)
  RETURNING VARCHAR(5),    -- Unidad Academica
            INTEGER,       -- Acta Regulares
            INTEGER,       -- Acta Promocion
            VARCHAR(15),   -- libro de Acta de Cursados.
            INTEGER,       -- Comision
            VARCHAR(255),  -- Nombre Comision
            VARCHAR(5),    -- Materia
            VARCHAR(255),  -- Nombre materia
            INTEGER,       -- A�o Academico
            VARCHAR(20),   -- PeriodoLectivo
            INTEGER,       -- Escala de Notas
            VARCHAR(10),   -- Fecha Inicio periodo Lectivo (dd/mm/yyyy)
            VARCHAR(10),   -- Fecha Fin periodo Lectivo
            CHAR(1),       -- Estado del Acta de Promocion.
            CHAR(1),       -- Si maneja el concepto de Cierre Parcial de Actas de Cursados.
            varchar(5),    -- sede
            varchar(255),  -- nombre sede
            integer,       -- cantidad de folios
            VARCHAR(255),  -- observaciones
            VARCHAR(60),   -- Nombre del Libro de Acta de Regulares
            CHAR(1),       -- Estado Acta de Regulares

	VARCHAR(60), -- Nombre UA
	VARCHAR(255), -- Nombre carrera
	VARCHAR(5),  -- Plan
	VARCHAR(255), --Nombre de quien genero el acta
	VARCHAR(15); --Fecha generacion acta

--var's para el manejo de excepciones
DEFINE sql_err, isam_err     INTEGER;
DEFINE error_info            VARCHAR(76);
DEFINE v_user_error          VARCHAR(10) ;

-- Variables del procedure
DEFINE iComision           LIKE sga_comisiones.comision;
DEFINE vcMateria           LIKE sga_comisiones.materia;
DEFINE iAnioAcademico      LIKE sga_comisiones.anio_academico;
DEFINE vcNombreComision    LIKE sga_comisiones.nombre;
DEFINE vcPeriodoLectivo    LIKE sga_comisiones.periodo_lectivo;
DEFINE pLegajo             LIKE sga_docentes.legajo;
DEFINE vcNombreMateria     LIKE sga_materias.nombre;
DEFINE vcActaReg           LIKE sga_actas_cursado.acta;
DEFINE vcLibroReg          LIKE sga_actas_cursado.libro;
DEFINE vcLibroRegNombre  Varchar(60);
DEFINE iActaProm           LIKE sga_actas_promo.acta;
DEFINE vcEstadoActaProm    LIKE sga_actas_promo.estado;
DEFINE vcEstadoActaReg    LIKE sga_actas_cursado.estado;
DEFINE iEscalaNotas        LIKE sga_comisiones.escala_notas;
DEFINE dFechaInicio, dFechaFin    LIKE sga_periodos_lect.fecha_inicio;
DEFINE vcFechaInicio, vcFechaFin  VARCHAR(10);
DEFINE vcCierreParcial            LIKE sga_param_sistema.valor;
DEFINE vcSede LIKE sga_sedes.sede;
DEFINE vcNombreSede LIKE sga_sedes.nombre;
DEFINE iFolios             INTEGER;
DEFINE vcObservaciones like sga_actas_cursado.observaciones;

DEFINE vcNombreGeneraActa     varchar(255);
DEFINE vcFechaGen     varchar(30);
DEFINE vcNombreUa like sga_unidades_acad.nombre;
DEFINE vcCarrera like sga_carreras.nombre;
DEFINE vcPlan like sga_planes.plan;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN

  -- Inicializo las vars que voy a devolver
  LET  vcMateria        = NULL; 
  LET  iAnioAcademico   = NULL; 
  LET  iComision        = NULL; 
  LET  iEscalaNotas     = NULL; 
  LET  vcPeriodoLectivo = NULL; 
  LET  vcLibroReg       = NULL; 
  LET  vcNombreMateria  = NULL; 
  LET  vcNombreComision = NULL; 
  LET  vcActaReg        = NULL; 
  LET  iActaProm        = NULL; 
  LET  dFechaInicio     = NULL; 
  LET  dFechaFin        = NULL; 
  LET  vcFechaInicio    = NULL; 
  LET  vcFechaFin       = NULL; 
  LET  vcEstadoActaProm = NULL; 
  LET  vcEstadoActaReg = NULL; 
  LET  iFolios   = 1; 
  LET  vcObservaciones = NULL; 

   LET  vcCarrera   = NULL; 
   LET  vcPlan   = NULL; 
   LET  vcNombreUa   = NULL; 

  EXECUTE PROCEDURE sp_param_sistema('cierre_parcial_acta_cursados') INTO vcCierreParcial;

  SELECT sga_comisiones.comision,
         sga_comisiones.nombre,
         sga_comisiones.materia,
         sga_comisiones.anio_academico,
         sga_comisiones.periodo_lectivo,
         sga_comisiones.escala_notas,
         nvl(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
         sga_actas_cursado.acta,
         sga_actas_cursado.libro,
         sga_libros_actacur.nombre,
         sga_actas_cursado.estado,
         sga_actas_promo.acta,
         sga_actas_promo.estado,
         sga_sedes.sede,
         sga_sedes.nombre,
         sga_actas_cursado.observaciones,
	sga_unidades_acad.nombre,
	nvl(sga_carreras.nombre, ''),
	nvl(sga_comisiones.plan, '')

    INTO iComision,
         vcNombreComision,
         vcMateria,
         iAnioAcademico,
         vcPeriodoLectivo,
         iEscalaNotas,
         vcNombreMateria,
         vcActaReg,
         vcLibroReg,
         vcLibroRegNombre,
         vcEstadoActaReg,
         iActaProm,
         vcEstadoActaProm,
         vcSede,
         vcNombreSede,
         vcObservaciones,
		vcNombreUa,
		vcCarrera,
		vcPlan
 
    FROM sga_actas_cursado,
         sga_comisiones,
         sga_materias,
         sga_sedes, 
	 sga_unidades_acad,

         OUTER sga_libros_actacur,
         OUTER sga_actas_promo,
         OUTER(sga_planes, sga_atrib_mat_plan),
	 OUTER sga_carreras

   WHERE sga_actas_cursado.unidad_academica   = pUA
     AND sga_actas_cursado.acta = pActaReg
     AND sga_comisiones.comision = sga_actas_cursado.comision
     AND sga_materias.unidad_academica  = sga_comisiones.unidad_academica
     AND sga_materias.materia           = sga_comisiones.materia
     AND sga_actas_cursado.comision   = sga_comisiones.comision
     AND sga_actas_cursado.estado <> 'B' -- Abierta o cerrada
     AND sga_libros_actacur.unidad_academica  = sga_actas_cursado.unidad_academica
     AND sga_libros_actacur.libro             = sga_actas_cursado.libro
     AND sga_actas_promo.comision = sga_comisiones.comision
     AND sga_actas_promo.tipo = 'P' -- Muestra el Acta Original de Promocion
     AND sga_actas_promo.estado <> 'B' -- para que no devuelva las anuladas
     AND sga_planes.unidad_academica = sga_comisiones.unidad_academica
     AND sga_planes.carrera = sga_comisiones.carrera
     AND sga_planes.plan = sga_comisiones.plan
     AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
     AND sga_atrib_mat_plan.carrera = sga_planes.carrera
     AND sga_atrib_mat_plan.plan = sga_planes.plan
     AND sga_atrib_mat_plan.version = sga_planes.version_actual
     AND sga_atrib_mat_plan.materia = sga_comisiones.materia
     AND sga_comisiones.sede = sga_sedes.sede
    

	AND sga_actas_cursado.unidad_academica = sga_unidades_acad.unidad_academica
	AND sga_actas_cursado.carrera = sga_carreras.carrera;

    -- Si encontro la Cabecera del Acta de Regulares.	
    IF DBINFO("sqlca.sqlerrd2") > 0 THEN
	   
      -- Recupero fecha de Inicio y Fin del Periodo Lectivo
      SELECT fecha_inicio, fecha_fin
        INTO dFechaInicio, dFechaFin
        FROM sga_periodos_lect
       WHERE anio_academico = iAnioAcademico
         AND periodo_lectivo = vcPeriodoLectivo;
    
      IF DBINFO("sqlca.sqlerrd2") > 0 THEN  	    
        LET vcFechaInicio = to_char(dFechaInicio, "%d/%m/%Y");
        LET vcFechaFin = to_char(dFechaFin, "%d/%m/%Y");
      END IF;

      
      -- Saco la cantidad de folios de los registros del Acta de Regulares
      IF vcEstadoActaReg = 'A' THEN
          -- Busco los registros por la comision (no siempre tienen el dato del campo acta_regular)
          SELECT Max(folio_regular) INTO iFolios FROM sga_curs_pendiente WHERE comision = iComision;                      
      ELIF vcEstadoActaReg = 'C' THEN
          -- Busco en el detalle del Acta 
          SELECT Max(folio) INTO iFolios FROM sga_det_acta_curs WHERE unidad_academica = pUA AND acta = pActaReg;   
      END IF;    
      
      IF iFolios IS NULL THEN
         LET iFolios = 1;
      END IF;   

	LET vcNombreGeneraActa  = NULL;
	LET vcFechaGen = NULL;
 	--busco quien genero el acta
	SELECT u.nombre,max(fecha_act) as fecha  INTO vcNombreGeneraActa, vcFechaGen 
	FROM log_actas_cursado l, acc_usuarios u
	
	WHERE l.unidad_academica = pUa
		AND l.acta = pActaReg
		AND l.comision = iComision --SE AGREGA ESTA LINEA YA QUE CASOS EN LOS QUE EXISTE UN MISMO NRO DE ACTA EN DISTINTAS CARRERAS Y TRAE 2 USUARIOS EN LUGAR DE 1, AL AGREGAR LA COMISION SOLO OBTIENE EL REFERENTE A ESA ACTA DE ESA CARRERA
		AND l.usuario=u.usuario
		AND l.operacion="I"
	Group by u.nombre;

     
      -- si no encontro nada, devuelve nulos
      RETURN pUA, vcActaReg, iActaProm, vcLibroReg, iComision, vcNombreComision, vcMateria, 
             vcNombreMateria, iAnioAcademico, vcPeriodoLectivo, iEscalaNotas, vcFechaInicio, 
             vcFechaFin, vcEstadoActaProm , vcCierreParcial, vcSede, vcNombreSede, iFolios, vcObservaciones, vcLibroRegNombre, vcEstadoActaReg, vcNombreUa, vcCarrera, vcPlan, vcNombreGeneraActa, vcFechaGen;

    END IF;
  END;                                                           
END PROCEDURE;                 
-- +++++++++++++++++++++++++ Fin Procedure sp_cab_actacursado  ++++++++++++++++++++++++++++++++++++++++++++               

-- execute PROCEDURE "dba".sp820_cab_actacursado('FICH', 4117);


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_cab_acta_examen 
-- *****************************************************************************
revoke execute on "dba".sp820_cab_actacursado from public;
grant execute on "dba".sp820_cab_actacursado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_cab_actacursado to internet; -- Rol de usuario de Internet