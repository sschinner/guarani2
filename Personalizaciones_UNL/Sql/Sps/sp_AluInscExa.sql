CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_aluinscexa') THEN
		DROP PROCEDURE sp_aluinscexa;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.8.0
-- Ultima version de Modificacion: version 2.03.0, 2.05.0, 2.9.2
--
-- Procedure sp_AluInscExa
-- Listado de alumnos inscriptos en una mesa de examen en un llamado.
-- *******************************************************************************
CREATE PROCEDURE "dba".sp_aluinscexa (
                                pUnidad_academica LIKE sga_llamados_mesa.unidad_academica, 
                                pMateria          LIKE sga_llamados_mesa.materia, 
                                pAnio_academico   LIKE sga_llamados_mesa.anio_academico, 
                                pTurno_examen     LIKE sga_llamados_mesa.turno_examen, 
                                pMesa_examen      LIKE sga_llamados_mesa.mesa_examen, 
                                pLlamado          LIKE sga_llamados_mesa.llamado)
                
        RETURNING 
                        varchar(5),   --  0 Unidad academica
                          varchar(5),   --  1 pMateria
                          varchar(255), --  2 Materia Nombre
                          integer,      --  3 pAnio_academico
                          varchar(20),  --  4 pTurno_examen
                          varchar(15),  --  5 pMesa_examen
                          integer,      --  6 pLlamado
                          varchar(50),  --  7 Fecha-Hora
                          integer,      --  8 Edificio
                          varchar(50),  --  9 Edificio Nombre
                          integer,      -- 10 Aula
                          varchar(50),  -- 11 Aula Nombre
                          varchar(5),   -- 12 Carrera
                          varchar(255), -- 13 Carrera Nombre 
                          varchar(15),  -- 14 Legajo 
                          varchar(255), -- 15 Apellido y Nombres 
                          varchar(10),  -- 16 Descripcion del Tipo de Inscripcion
                          varchar(20),  -- 17 Estado
                          varchar(30),  -- 18 Carrera Nombre Reducido
                          varchar(5),   -- 19 sede
                          varchar(255), -- 20 nombre sede
                          varchar(20),  -- 21 Fecha y Hora de Inscripcion en formato yyyy/mm/dd hh:mm:ss
                          varchar(20),  -- 22 Fecha y hora de inscripcion en formato dd/mm/yyyy hh:mm:ss
                          varchar(255); -- 23 Email

--var para el manejo de excepciones
DEFINE  sql_err             integer;
DEFINE  isam_err            integer;
DEFINE  error_info          varchar(76);
DEFINE  v_user_error        varchar(10);

-- Variables de retorno
DEFINE  vcUnidadAcademica varchar(5);
DEFINE  vcFechaHora       varchar(50);
DEFINE  vcEdificio        varchar(50);
DEFINE  vcAula            varchar(50);
DEFINE  vcCarrera         varchar(50);
DEFINE  vcLegajo          varchar(50);
DEFINE  vcApeNombre       varchar(50);
DEFINE  vcEmail           varchar(50);
DEFINE  vcCarreraNombre   varchar(255);
DEFINE  vcMateriaNombre   varchar(255);
DEFINE  vcTipoInscDesc    varchar(20);
DEFINE  vcTipoInsc        char(1);
DEFINE  vcEstado          varchar(20);
DEFINE  iEdificio         integer;
DEFINE  iAula             integer;
DEFINE  vcCarrNomRed      LIKE sga_carreras.nombre_reducido;
DEFINE  vcSede varchar(5);
DEFINE  vcNombreSede varchar(255);
DEFINE  vcFechaInscDisplay varchar(20);
DEFINE vcFechaInscOrden   varchar(20); 


-- Blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN

    LET vcUnidadAcademica   =   NULL;
    LET vcFechaHora         =   NULL;
    LET iEdificio           =   NULL;
    LET vcEdificio          =   NULL;
    LET iAula               =   NULL;
    LET vcAula              =   NULL;
    LET vcCarrera           =   NULL;
    LET vcLegajo            =   NULL;
    LET vcApeNombre         =   NULL;
    LET vcEmail         =   NULL;
    LET vcCarreraNombre     =   NULL;
    LET vcMateriaNombre     =   NULL;
    LET vcTipoInsc          =   NULL;
    LET vcTipoInscDesc      =   NULL;
    LET vcEstado            =   NULL;
    LET vcFechaInscDisplay  = NULL;
    LET vcFechaInscOrden     = NULL;

    FOREACH 
     SELECT {+ ordered}
            sga_personas.unidad_academica,
            TO_CHAR(sga_prestamos.fecha, "%d/%m/%Y"), -- || TO_CHAR(sga_prestamos.hora_inicio, " %H:%M"),
            sga_prestamos.edificio,
            sga_prestamos.aula,
            sga_alumnos.carrera,
            sga_alumnos.legajo,
            sga_personas.apellido || ', ' || sga_personas.nombres,
            NVL(TRIM(gda_anun_conf_pers.e_mail), 'Mail desconocido') nombre_alumno,
            sga_materias.nombre,
            sga_carreras.nombre,
            sga_insc_examen.tipo_inscripcion,
            DECODE(sga_insc_examen.estado, 'A', 'Activa', 'P', 'Pendiente', 'R', 'Rechazado', 'E', 'Exceptuado' ),
            sga_carreras.nombre_reducido,
            TO_CHAR(sga_insc_examen.fecha_inscripcion, "%Y/%m/%d %H:%M:%S") as fechainscorden,
            TO_CHAR(sga_insc_examen.fecha_inscripcion, "%d/%m/%Y %H:%M:%S") as fechainscdisplay

       INTO vcUnidadAcademica,
            vcFechaHora,
            iEdificio,
            iAula,
            vcCarrera,
            vcLegajo,
            vcApeNombre,
            vcEmail,
            vcMateriaNombre,
            vcCarreraNombre,
            vcTipoInsc,
            vcEstado,
            vcCarrNomRed,
            vcFechaInscOrden,
            vcFechaInscDisplay
          
       FROM sga_insc_examen,
            sga_llamados_mesa,
            sga_prestamos,
            sga_materias,
            sga_alumnos,
            sga_personas,
            sga_carreras,
            gda_anun_conf_pers 

      WHERE sga_insc_examen.unidad_academica    = pUnidad_academica
        AND sga_insc_examen.materia             = pMateria
        AND sga_insc_examen.anio_academico      = pAnio_academico
        AND sga_insc_examen.turno_examen        = pTurno_examen
        AND sga_insc_examen.mesa_examen         = pMesa_examen
        AND sga_insc_examen.llamado             = pLlamado
        AND sga_insc_examen.estado              IN ('A', 'E', 'P')

        AND sga_insc_examen.unidad_academica    = sga_llamados_mesa.unidad_academica
        AND sga_insc_examen.materia             = sga_llamados_mesa.materia
        AND sga_insc_examen.anio_academico      = sga_llamados_mesa.anio_academico
        AND sga_insc_examen.turno_examen        = sga_llamados_mesa.turno_examen
        AND sga_insc_examen.mesa_examen         = sga_llamados_mesa.mesa_examen
        AND sga_insc_examen.llamado             = sga_llamados_mesa.llamado

        AND sga_prestamos.prestamo              = sga_llamados_mesa.prestamo

        AND sga_materias.unidad_academica       = sga_llamados_mesa.unidad_academica
        AND sga_materias.materia                = sga_llamados_mesa.materia


        AND sga_insc_examen.unidad_academica    = sga_alumnos.unidad_academica
        AND sga_insc_examen.carrera             = sga_alumnos.carrera
        AND sga_insc_examen.legajo              = sga_alumnos.legajo

        AND sga_carreras.unidad_academica       = sga_alumnos.unidad_academica
        AND sga_carreras.carrera                = sga_alumnos.carrera

        AND sga_personas.unidad_academica       = sga_alumnos.unidad_academica
        AND sga_personas.nro_inscripcion        = sga_alumnos.nro_inscripcion

       AND sga_personas.unidad_academica = gda_anun_conf_pers.unidad_academica
       AND sga_personas.nro_inscripcion  = gda_anun_conf_pers.nro_inscripcion
		

-- ******************************************************************************
-- U820 Ordeno la lista de salida
-- *******************************************************************************
	ORDER BY sga_personas.apellido || ', ' || sga_personas.nombres


       --  DECODE(sga_insc_examen.tipo_inscripcion, 'L', 'Libre', 'R', 'Regular'),
       SELECT desc_tipo_insc INTO vcTipoInscDesc
	FROM sga_tipos_mesa
	WHERE tipo_mesa = vcTipoInsc;
     	 
	
        -- recupero el aula y edificio.
        SELECT sga_aulas.nombre_aula
          INTO vcAula
          FROM sga_aulas
         WHERE sga_aulas.edificio = iEdificio
           AND sga_aulas.aula = iAula;
        
        SELECT sga_edificios.nombre
          INTO vcEdificio
          FROM sga_edificios
         WHERE sga_edificios.edificio = iEdificio;

	SELECT ss.sede, ss.nombre
		INTO vcSede, vcNombreSede
		FROM sga_sedes ss, sga_mesas_examen sme
		WHERE ss.sede = sme.sede
			AND sme.unidad_academica = vcUnidadAcademica
			AND sme.materia = pMateria
			AND sme.anio_academico = pAnio_academico
			AND  sme.turno_examen =  pTurno_examen
			AND sme.mesa_examen = pMesa_examen;
      
      -- si no encontro nada, devuelve vacios
      RETURN vcUnidadAcademica, pMateria, vcMateriaNombre, pAnio_academico, pTurno_examen,
             pMesa_examen, pLlamado, vcFechaHora, iEdificio, vcEdificio, iAula, vcAula, 
             vcCarrera, vcCarreraNombre, vcLegajo, vcApeNombre, vcTipoInscDesc, vcEstado,
             vcCarrNomRed, vcSede, vcNombreSede, vcFechaInscOrden, vcFechaInscDisplay, vcEmail  WITH RESUME ;
   END FOREACH ;

END;

END PROCEDURE;
-- ************************ FIN PROCESO sp_AluInscExa ************************
revoke execute on sp_aluinscexa from public;

grant execute on sp_aluinscexa to guarani; -- Rol de usuarios de Gestión
grant execute on sp_aluinscexa to internet; -- Usuario de internet

