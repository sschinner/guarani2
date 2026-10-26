-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Procedimiento que devuelve los datos necesarios para la inscripcion a una materia de integración
--Estos datos serviran tambien para inscribir al alumno como alumno de integración en caso de que este no esté registrado en la base CAPIC
--Datos a devolver: Plan, TipoDocumento, Sexo, Año de ingreso
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--DROP PROCEDURE sp_datosAlumnoCapic;
CREATE PROCEDURE sp_datosAlumnoCapic(pUnidadAcademica LIKE sga_alumnos.unidad_academica,  pnroinscripcion LIKE sga_alumnos.nro_inscripcion, pcarrera LIKE sga_alumnos.carrera)

RETURNING  varchar(5), --Plan
                        integer,       --Tipo Documento
                        char(1),      --Sexo
	        varchar(20), -- Año de ingreso
	        date, -- Fecha de ingreso
	        decimal(15,0); -- Nro de documento

-- vars para el manejo de excepciones
DEFINE SQLErr       integer;
DEFINE ISAMError    integer;
DEFINE errorInfo    varchar(76);
 
-- vars locales

DEFINE vcPlan LIKE sga_alumnos.plan;
DEFINE vcTipoDocumento LIKE sga_personas.tipo_documento;
DEFINE vcSexo  LIKE sga_personas.sexo;
DEFINE vcAnioIngreso  LIKE sga_carrera_aspira.periodo_inscripcio;
DEFINE vcFechaIngreso  LIKE sga_alumnos.fecha_ingreso;
DEFINE vcNroDocumento  LIKE sga_personas.nro_documento;

-- si hay algun error NO controlado
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
END EXCEPTION;

BEGIN

   -- inicializo las vars a retornar
   LET vcPlan		= NULL;
   LET vcTipoDocumento	= NULL;
   LET vcSexo		= NULL;
   LET vcAnioIngreso	= NULL;
   LET vcFechaIngreso	= NULL;
   LET vcNroDocumento	= NULL;
   
   SELECT a.plan,
	 b.tipo_documento,
	 b.sexo,
	pi.anio_academico,
	a.fecha_ingreso,
	b.nro_documento
   INTO 
	vcPlan,
	vcTipoDocumento,
	vcSexo,
	vcAnioIngreso,
	vcFechaIngreso,
	vcNroDocumento
   FROM sga_alumnos a, sga_personas b, sga_carrera_aspira ca, sga_periodo_insc pi
   WHERE a.unidad_academica = b.unidad_academica
	and a.nro_inscripcion = b.nro_inscripcion
	and a.unidad_academica = pUnidadAcademica
    and a.nro_inscripcion =  pnroinscripcion
	and ca.nro_inscripcion =  pnroinscripcion
	and a.carrera = pcarrera
	and ca.carrera = pcarrera
	and ca.periodo_inscripcio = pi.periodo_inscripcio;

 -- devueve el result set 
   RETURN vcPlan, vcTipoDocumento, vcSexo, vcAnioIngreso, vcFechaIngreso, vcNroDocumento;

END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
