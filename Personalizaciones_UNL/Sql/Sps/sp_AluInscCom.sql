-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Ultima version modificacion: Version 2.03.0
--
-- Procedure sp_AluInscCom
-- Lista los alumnos inscriptos en una comision determinada.
-- *******************************************************************************
DROP PROCEDURE sp_AluInscCom;
CREATE PROCEDURE sp_AluInscCom ( pComision LIKE sga_comisiones.comision )
                RETURNING varchar(5),    --  0 vcUnidadAcademica,
                          varchar(5),    --  1 vcMateria,
                          varchar(255),  --  2 vcMateriaNombre,
                          integer,       --  3 vcAnio,
                          varchar(20),   --  4 vcPerLect,
                          integer,       --  5 iComision, 
                          varchar(15),   --  6 vcComisionDesc,
                          varchar(15),   --  7 vcCatedra,
                          varchar(15),   --  8 vcCalidadInsc,
                          varchar(15),   --  9 vcEstado,
                          varchar(5),    -- 10 vcCarrera,
                          varchar(255),  -- 11 vcCarreraNombre,
                          varchar(15),   -- 12 vcAlumnoLegajo,
                          varchar(255),  -- 13 vcAlumnoNombre,
                          varchar(255),  -- 14 vcDocenteNombre,
                          varchar(30),   -- 15 vcCarrNomRed;
		varchar(5), -- 16 sede
		varchar(255), -- 17 Nombre sede
		varchar(255); -- 18 vcAlumnoEmail


--var's para el manejo de excepciones
DEFINE  sql_err             integer;
DEFINE  isam_err            integer;
DEFINE  error_info          varchar(76);
DEFINE  v_user_error        varchar(10);

--var's para el manejo de excepciones
DEFINE vcUnidadAcademica LIKE sga_comisiones.unidad_academica;
DEFINE vcMateria         LIKE sga_materias.materia;
DEFINE vcMateriaNombre   LIKE sga_materias.nombre;
DEFINE vcAnio            LIKE sga_comisiones.anio_academico;
DEFINE vcPerLect         LIKE sga_comisiones.periodo_lectivo;
DEFINE iComision         LIKE sga_comisiones.comision;
DEFINE vcComisionDesc    LIKE sga_comisiones.nombre;
DEFINE vcCatedra         LIKE sga_comisiones.catedra;
DEFINE vcCalidadInsc     VARCHAR(15);
DEFINE vcEstado          VARCHAR(15);
DEFINE vcCarrera         LIKE sga_carreras.carrera;
DEFINE vcCarreraNombre   LIKE sga_carreras.nombre;
DEFINE vcAlumnoLegajo    LIKE sga_insc_cursadas.legajo;
DEFINE vcAlumnoNombre    VARCHAR(255);
DEFINE vcAlumnoEmail    VARCHAR(255);
DEFINE vcDocenteNombre   VARCHAR(255);
DEFINE vcCarrNomRed      LIKE sga_carreras.nombre_reducido; 

DEFINE  vcSede varchar(5);
DEFINE vcNombreSede varchar(255);

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN

   -- Inicializaciones.
   LET vcUnidadAcademica  = NULL;
   LET vcMateria          = NULL;
   LET vcMateriaNombre    = NULL;
   LET vcAnio             = NULL;
   LET vcPerLect          = NULL;
   LET iComision          = NULL;
   LET vcComisionDesc     = NULL;
   LET vcCatedra          = NULL;
   LET vcCalidadInsc      = NULL;
   LET vcEstado           = NULL;
   LET vcCarrera          = NULL;
   LET vcCarreraNombre    = NULL;
   LET vcAlumnoLegajo     = NULL;
   LET vcAlumnoNombre     = NULL;
   LET vcAlumnoEmail      = NULL;
   LET vcDocenteNombre    = NULL;

   -- Traigo todos los docentes asignados a la comision.
   EXECUTE PROCEDURE sp_docentes_com ( pComision ) INTO vcDocenteNombre;

   FOREACH
    SELECT sga_comisiones.unidad_academica,
           sga_comisiones.materia,
           sga_materias.nombre,
           sga_comisiones.anio_academico,
           sga_comisiones.periodo_lectivo,
           sga_comisiones.comision,
           sga_comisiones.nombre,
           sga_comisiones.catedra,
           DECODE(sga_insc_cursadas.calidad_insc, 'P', 'Promocional', 'R', 'Regular'),
           DECODE(sga_insc_cursadas.estado, 'A', 'Activa', 'P', 'Pendiente', 'E', 'Exceptuado', 'B', 'Baja'),
           sga_carreras.carrera,
           sga_carreras.nombre,
           sga_insc_cursadas.legajo,
           TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres)  nombre_alumno,
           NVL(TRIM(gda_anun_conf_pers.e_mail), 'Mail desconocido') email,
           sga_carreras.nombre_reducido,
	sga_sedes.sede,
	sga_sedes.nombre

      INTO vcUnidadAcademica,
           vcMateria,
           vcMateriaNombre,
           vcAnio,
           vcPerLect,
           iComision,
           vcComisionDesc,
           vcCatedra,
           vcCalidadInsc,
           vcEstado,
           vcCarrera,
           vcCarreraNombre,
           vcAlumnoLegajo,
           vcAlumnoNombre,
           vcAlumnoEmail,
           vcCarrNomRed,
	vcSede,
	vcNombreSede 

      FROM sga_comisiones,
           sga_insc_cursadas,
           sga_alumnos,
           sga_personas,
           sga_carreras,
           sga_materias, 
	sga_sedes,
	gda_anun_conf_pers 

     WHERE sga_comisiones.comision = pComision

       AND sga_insc_cursadas.comision = sga_comisiones.comision
       AND sga_insc_cursadas.estado   IN ('A', 'E', 'P')

       AND sga_alumnos.unidad_academica = sga_insc_cursadas.unidad_academica
       AND sga_alumnos.carrera = sga_insc_cursadas.carrera
       AND sga_alumnos.legajo  = sga_insc_cursadas.legajo

       AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
       AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion

       AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
       AND sga_carreras.carrera          = sga_alumnos.carrera

       AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
       AND sga_materias.materia          = sga_comisiones.materia

	AND sga_comisiones.sede = sga_sedes.sede
       AND sga_personas.unidad_academica = gda_anun_conf_pers.unidad_academica
       AND sga_personas.nro_inscripcion  = gda_anun_conf_pers.nro_inscripcion

  ORDER BY nombre_alumno

      -- si no encontro nada, devuelve vacios
      RETURN vcUnidadAcademica,
             vcMateria,
             vcMateriaNombre,
             vcAnio,
             vcPerLect,
             iComision,
             vcComisionDesc,
             vcCatedra,
             vcCalidadInsc,
             vcEstado,
             vcCarrera,
             vcCarreraNombre,
             vcAlumnoLegajo,
             vcAlumnoNombre,
             vcDocenteNombre,
             vcCarrNomRed,
	vcSede,
	vcNombreSede,
        vcAlumnoEmail  WITH RESUME ;

   END FOREACH ;

END;

END PROCEDURE;
-- ************************ FIN PROCESO sp_AluInscCom ************************
