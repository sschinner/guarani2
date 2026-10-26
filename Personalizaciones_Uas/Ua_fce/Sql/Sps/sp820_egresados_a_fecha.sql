drop PROCEDURE "dba".sp820_egresados_a_fecha;
CREATE PROCEDURE "dba".sp820_egresados_a_fecha( pUA like sga_alumnos.unidad_academica, pCarrera like sga_alumnos.carrera, psFechadesde varchar(10) ,psFechahasta varchar(10) )
RETURNING 	
		varchar(10),		-- Unidad Academica
		varchar(5), 		-- Carrera
		varchar(255), 		-- Nombre Carrera
		varchar(15), 		-- Legajo
		varchar(255), 		-- Nombre		
		varchar(3), 		-- Tipo Documento
		decimal(15,0), 		-- Nro. Documento
                       	varchar(5), 		-- Titulo
		varchar(255), 		-- Nombre Titulo
		varchar(10),		-- Nro. Inscripcion
		varchar(5), 		-- Plan
		date,			-- Fecha egreso
		float,			-- Promedio con aplazos
		float			-- Promedio sin aplazos 
-- variables para el manejo de excepciones
DEFINE		SQLErr, ISAMError		integer;
DEFINE		errorInfo 			varchar(76);

--- variables salida
DEFINE ls_Ua  		LIKE  sga_alumnos.unidad_academica;
DEFINE ls_Carrera  		LIKE  sga_alumnos.carrera;
DEFINE ls_CarreraNombre  	LIKE  sga_carreras.nombre;
DEFINE ls_Legajo  		LIKE  sga_alumnos.legajo;
DEFINE ls_NombreAlumno  	Varchar(255);
DEFINE ls_TipoDoc  		LIKE  sga_personas.tipo_documento;
DEFINE ls_NroDoc  		LIKE  sga_personas.nro_documento;
DEFINE ls_Titulo  		LIKE  sga_titulos_plan.titulo;
DEFINE ls_TituloNombre  	LIKE  sga_titulos.nombre;
DEFINE vcNroInscripcion      LIKE sga_titulos_otorg.nro_inscripcion;
DEFINE ls_Plan  		LIKE  sga_alumnos.plan;
DEFINE dFechaEgresoFinal     DATE;
DEFINE fPromGral             LIKE sga_titulos_otorg.prom_general;
DEFINE fPromSinAplazos       LIKE sga_titulos_otorg.prom_sin_aplazos;

--- variables

DEFINE dFDesde DATE;
DEFINE dFHasta DATE;

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION  SQLErr, SQLErr, errorInfo ;
END EXCEPTION;

BEGIN
LET dFDesde = stringToDate( psFechadesde, '%d-%m-%Y');
LET dFHasta = stringToDate( psFechahasta, '%d-%m-%Y');

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Conjunto de alumnos que aprobaron una materia entre las fechas enviadas por parámetro
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
FOREACH
SELECT 	sga_alumnos.unidad_academica,
                sga_alumnos.carrera,
                 sga_carreras.nombre,
                sga_alumnos.legajo,
                TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres)  nombre_alumno,
	sga_personas.tipo_documento,
	sga_personas.nro_documento,
                sga_titulos_plan.titulo,
                sga_titulos.nombre,
	sga_alumnos.nro_inscripcion,
	sga_alumnos.plan,
                sga_titulos_otorg.fecha_egreso,
                sga_titulos_otorg.prom_general,  
                sga_titulos_otorg.prom_sin_aplazos  
into         
                ls_Ua,   
                ls_Carrera,
                ls_CarreraNombre,
                ls_Legajo,
                ls_NombreAlumno,
                ls_TipoDoc,
                ls_NroDoc,
                ls_Titulo,
                ls_TituloNombre,
                vcNroInscripcion,
                ls_Plan,
                dFechaEgresoFinal,
                 fPromGral,
                 fPromSinAplazos
FROM 	sga_alumnos,
                sga_titulos_plan,
                sga_titulos_otorg,
                sga_personas,  
                sga_carreras,
                sga_titulos
WHERE   ((sga_alumnos.calidad = 'E' and pCarrera <> '0205') or pCarrera = '0205')
	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan
                AND sga_alumnos.unidad_academica = pUA
       	AND ((sga_alumnos.carrera = pCarrera  and pCarrera <> '0205'
                AND sga_titulos_plan.titulo <> '02-11') or (pCarrera = '0205' and  sga_titulos_plan.titulo = '02-11'))
                AND sga_titulos_plan.titulo		 = sga_titulos.titulo
                AND sga_carreras.carrera 	    = sga_alumnos.carrera
                and  sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion
                AND sga_titulos_otorg.unidad_academica = sga_alumnos.unidad_academica
                AND sga_titulos_otorg .nro_inscripcion = sga_alumnos.nro_inscripcion
                AND sga_titulos_otorg.titulo =  sga_titulos_plan.titulo
                AND sga_titulos_otorg.fecha_egreso >= dFDesde
                AND sga_titulos_otorg.fecha_egreso <= dFHasta

	RETURN 
		ls_Ua,   
                	ls_Carrera,
                	ls_CarreraNombre,
                	ls_Legajo,
                	ls_NombreAlumno,
                	ls_TipoDoc,
                	ls_NroDoc,
                	ls_Titulo,
                	ls_TituloNombre,
                	vcNroInscripcion,
                	ls_Plan,
                	dFechaEgresoFinal,
                	 fPromGral,
                 	fPromSinAplazos
			WITH RESUME;

 
    END FOREACH; 

END;
END PROCEDURE;
-- execute PROCEDURE "dba".sp820_egresados_a_fecha('FCE', '0205','01-01-2010','01-01-2014'); 
