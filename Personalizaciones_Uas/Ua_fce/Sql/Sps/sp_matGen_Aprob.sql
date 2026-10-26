DROP  PROCEDURE sp_matGen_Aprob;
CREATE PROCEDURE sp_matGen_Aprob( 
	pua like sga_alumnos.unidad_academica, 
	pcarrera like sga_alumnos.carrera, 
	plegajo like sga_alumnos.legajo)
       RETURNING  varchar(5) , varchar(255), VARCHAR(5), varchar(63), varchar(5), varchar (255),char(1), char(1), char(1);

--  varchar(5) ,   -- Código Carrera
--  varchar(255),   -- Nombre Carrera
--  VARCHAR (5),   -- PLAN ,
--  varchar(63),   -- Apellido y Nombre  del alumno
--  varchar(5),    -- código de materia genérica
--  varchar (255), -- nombre materia genérica
--  varchar(1),    -- resultado
--  char (1),      -- regular
--  char (1)       -- calidad 
	         
DEFINE sResultado          char(1);

DEFINE vcTitulo            LIKE sga_titulos.titulo;
DEFINE vMateria            LIKE dba.sga_materias.materia;
DEFINE vtipo_Materia       LIKE dba.sga_atrib_mat_plan.tipo_materia;
	
DEFINE vcCarrera           LIKE dba.sga_alumnos.carrera;
DEFINE vcLegajo            LIKE dba.sga_alumnos.legajo;

DEFINE vcarreras_nombre    LIKE dba.sga_carreras.nombre ;
DEFINE vplan               LIKE dba.sga_alumnos.plan ;
DEFINE vregular            LIKE dba.sga_alumnos.regular;
DEFINE vcalidad            LIKE dba.sga_alumnos.calidad;
DEFINE vnombre_matplan     LIKE dba.sga_atrib_mat_plan.nombre_materia;
DEFINE vpersonas_apellido  LIKE dba.sga_personas.apellido;
DEFINE vpersonas_nombres   LIKE dba.sga_personas.nombres;
DEFINE vnomyape            varchar(60);
DEFINE iTotalCreditos	INTEGER;

-- Por CADA MATERIA GENÉRICA QUE TIENE EL ALUMNO DEL PARÁMETRO EN SU PLAN debo fijarme si la tiene aprobada 

FOREACH  
	SELECT  
       	dba.sga_alumnos.carrera,
     	dba.sga_alumnos.legajo,
	dba.sga_alumnos.plan,
	dba.sga_alumnos.regular,
	dba.sga_alumnos.calidad,
	dba.sga_atrib_mat_plan.materia,
	dba.sga_atrib_mat_plan.tipo_materia,
(dba.sga_personas.apellido || ',' || dba.sga_personas.nombres ),
dba.sga_carreras.nombre,
dba.sga_atrib_mat_plan.nombre_materia

   	 INTO   vcCarrera, vcLegajo, vplan,vregular,vcalidad,vmateria,vtipo_Materia, vnomyape , vcarreras_nombre,vnombre_matplan

  	FROM 
		dba.sga_alumnos,
       		dba.sga_atrib_mat_plan,
		dba.sga_planes,
		dba.sga_carreras,
		dba.sga_personas
                WHERE 		
	             dba.sga_alumnos.unidad_academica  	= pua	
	   AND dba.sga_alumnos.carrera 	 	= pcarrera
	   AND dba.sga_alumnos.legajo		 = plegajo
--	   AND dba.sga_alumnos.calidad		 = 'A'
--	   AND dba.sga_alumnos.regular		 = 'S'

	   AND dba.sga_alumnos.unidad_academica 	= dba.sga_atrib_mat_plan.unidad_academica
	   AND dba.sga_alumnos.carrera 		= dba.sga_atrib_mat_plan.carrera
	   AND dba.sga_alumnos.plan	 		= dba.sga_atrib_mat_plan.plan
	   AND dba.sga_atrib_mat_plan.tipo_materia	= 'G'

	   AND dba.sga_alumnos.carrera 		= dba.sga_planes.carrera
	   AND dba.sga_alumnos.plan			= dba.sga_planes.plan
	   AND dba.sga_alumnos.unidad_academica 	= dba.sga_planes.unidad_academica
	   AND dba.sga_planes.version_actual		= dba.sga_atrib_mat_plan.version
	   AND dba.sga_alumnos.nro_inscripcion	= dba.sga_personas.nro_inscripcion
	   AND dba.sga_carreras.carrera		= dba.sga_alumnos.carrera

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Por cada materia genérica , debo fijarme si la tiene aprobada: sp_resultGenerica   Verifica si una Materia Generica esta aprobada. 
-- Retorna:  A - Aprobo     R - No Aprobo la Mat. Generica.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
			-- Orientacion Base.	
			-- Recupero el Titulo de Grado del Plan-Version
		SELECT sga_orientaciones.titulo 
			INTO vcTitulo
			FROM sga_orientaciones,sga_titulos
        			WHERE sga_orientaciones.titulo = sga_titulos.titulo
				AND   sga_orientaciones.unidad_academica   	= pUa
	                		AND   sga_orientaciones.carrera  	= pCarrera  
	                		AND   sga_orientaciones.orientacion 	= '0'
				AND   Sga_orientaciones.plan = vplan
				AND   sga_titulos.nivel	= 'GRADO';
			   	
		LET sResultado = '';

		EXECUTE PROCEDURE sp_resultGenerica( pua, pcarrera, vcLegajo, vcTitulo,'0' ,vmateria) INTO sResultado, iTotalCreditos;
			--  IF sResultado = 'A' THEN
        		   RETURN 
			    vcCarrera,vcarreras_nombre, vplan ,  vnomyape , Vmateria ,vnombre_matplan, sResultado, vregular, vcalidad 
		WITH RESUME;
	
 END FOREACH ;  

END PROCEDURE;
                                                                                                                                                                                                       
