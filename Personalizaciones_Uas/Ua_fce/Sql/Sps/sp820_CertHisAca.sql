drop PROCEDURE "dba".sp820_CertHisAca ;
CREATE PROCEDURE "dba".sp820_CertHisAca ( pUnidadAcademica LIKE sga_personas.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pCorresponda varchar(255) DEFAULT 'A QUIEN CORRESPONDA')
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(15), varchar(5), varchar(100), varchar(15), varchar(5), varchar(5), varchar(5), varchar(100), date, varchar(15), varchar(5), varchar(20), char(1), varchar(10), varchar(10), varchar(15), varchar(15), Float, varchar(15),  char(1), varchar(10), varchar(60), varchar (255), char(1), char(1);


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- decimal(10), -- documento
-- varchar(5),   -- carrera
-- varchar(100), -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- varchar(20),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(15),	-- Descripcion de la nota
-- varchar(15);	-- Concepto de la nota
-- float; -- promedio
-- char(1); -- calidad del alumno
-- varchar (10); tipo_documento
-- varchar (60); nombre_ua
-- varchar (60); interesado
-- char(1); -- tipo de carrera
-- char(1); -- si el promedio es por resolucion 609/2010 o no

DEFINE vc_UANombre                 LIKE sga_unidades_acad.nombre;
DEFINE vc_nroInscripcion         LIKE sga_personas.nro_inscripcion;
DEFINE vc_apellido         LIKE sga_personas.apellido;
DEFINE vc_nombres          LIKE sga_personas.nombres;
DEFINE vcTipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_documento          LIKE sga_personas.nro_documento;
DEFINE vc_carrera          LIKE sga_alumnos.carrera;
DEFINE vc_carrera_nombre   LIKE sga_carreras.nombre;
DEFINE vc_legajo           LIKE sga_alumnos.legajo;
DEFINE vc_plan             LIKE sga_atrib_mat_plan.plan;
DEFINE vc_alu_plan             LIKE sga_atrib_mat_plan.plan;
DEFINE vc_version          LIKE sga_atrib_mat_plan.version;
DEFINE vc_materia          LIKE sga_materias.materia;
DEFINE vc_materia_nombre   LIKE sga_materias.nombre;
DEFINE vdt_fecha           LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_resultado        VARCHAR(15);
DEFINE vc_nota             LIKE sga_detalle_acta.nota;
DEFINE vc_forma_aprob      VARCHAR(20);
DEFINE vc_tipo_acta        LIKE sga_actas_examen.tipo_acta;
DEFINE vc_acta             LIKE sga_actas_examen.acta;
DEFINE vc_acta_promo       LIKE sga_actas_promo.acta;
DEFINE vc_nro_resol        LIKE sga_equiv_operac.nro_resolucion;
DEFINE vc_car_nom_red      LIKE sga_carreras.nombre_reducido;
DEFINE vi_retorno          SMALLINT;
DEFINE	vcDescripcion	LIKE sga_det_escala.descripcion;
DEFINE	vcConcepto	LIKE sga_det_escala.concepto;
DEFINE vfPromedio          FLOAT;
DEFINE vcCalidad		LIKE sga_alumnos.calidad;
DEFINE vc_materia_nom_red varchar (30);
DEFINE vi_escala integer;
DEFINE vi_equivalencia integer;
DEFINE vc_interesado varchar (255);
DEFINE vc_tipo_carrera char(1);
DEFINE cPromedioResolucion char(1);

BEGIN
   
   -- inicializaciones.
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_carrera          = pCarrera;
   LET vc_car_nom_red      = NULL;
   LET vc_legajo           = pLegajo;
   LET vc_plan             = NULL;
   LET vc_version          = NULL;
   LET vc_materia          = NULL;
   LET vc_materia_nombre   = NULL;
   LET vdt_fecha           = NULL;
   LET vc_resultado        = NULL;
   LET vc_nota             = NULL;
   LET vc_forma_aprob      = NULL;
   LET vc_tipo_acta        = NULL;
   LET vc_acta             = NULL;
   LET vc_acta_promo       = NULL;
   LET vc_nro_resol        = NULL;
   LET vi_retorno          = 0;
   LET vcDescripcion	= NULL	;
   LET vcConcepto		= NULL	;
  -- LET vfpromedio = "dba".sp820_prom_alu_res (punidadAcademica, pCarrera, pLegajo, 'S');  -- S- Aprobadas y Reprobadas / N- Solo aprobadas
   LET vcCalidad = NULL;
   LET vc_materia_nom_red = NULL;
   LET vi_escala = NULL;
   LET vi_equivalencia = NULL;
   LET vcTipoDocDesAbre    = NULL ;
LET vc_carrera_nombre = NULL;
LET vc_interesado = pCorresponda;
LET vc_tipo_carrera = NULL;
LET cPromedioResolucion = NULL;

   -- selecciono los datos personales de la persona.
   SELECT DISTINCT p.apellido, p.nombres, p.nro_documento, p.nro_inscripcion, a.calidad, tipo.desc_abreviada, ua.nombre, car.nombre, a.plan, car.tipo_de_carrera
     INTO vc_apellido, vc_nombres, vc_documento, vc_nroInscripcion, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_carrera_nombre, vc_alu_plan, vc_tipo_carrera 
     FROM  mdp_tipo_documento tipo
		join sga_personas p
			join sga_alumnos a
				join sga_carreras car
				on car.unidad_academica = a.unidad_academica
				and car.carrera = a.carrera
			on p.unidad_academica = a.unidad_academica
			and p.nro_inscripcion = a.nro_inscripcion
		on tipo.tipo_documento = p.tipo_documento
	left join sga_unidades_acad ua
		on p.unidad_academica = ua.unidad_academica
    WHERE a.unidad_academica = pUnidadAcademica
      AND a.legajo = plegajo
	AND a.carrera = pcarrera;

   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUnidadAcademica, pCarrera, pLegajo, 'S')  INTO vfpromedio, cPromedioResolucion;

    
      -- ejecuto el SP de la historia academica para cada carrera de la persona.
FOREACH EXECUTE PROCEDURE sp820_histAcademic ( pUnidadAcademica, vc_carrera, vc_legajo ) 
         INTO vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vc_plan, vc_version, vc_car_nom_red, vc_materia_nom_red, vi_escala, vi_equivalencia, vcdescripcion, vcconcepto
            
         -- el retorno final por cada materia.
         LET vi_retorno = 1;
IF vc_materia In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUnidadAcademica
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vc_Plan
							AND sga_atrib_mat_plan.version = vc_Version
							AND sga_atrib_mat_plan.materia = vc_Materia
							AND sga_atrib_mat_plan.sale_listado = 'S') THEN

         RETURN pUnidadAcademica, vc_nroInscripcion, vc_apellido, vc_nombres, vc_documento, vc_carrera, vc_carrera_nombre, vc_legajo, vc_alu_plan, vc_version, vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion, vfpromedio, vcconcepto, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_interesado, vc_tipo_carrera, cPromedioResolucion  WITH RESUME;

END IF;

END FOREACH;         

      -- reseteo las variables de carrera.
      LET vc_carrera = NULL;
      LET vc_car_nom_red = NULL;
      LET vc_legajo = NULL;
	LET vc_carrera_nombre = NULL;
      
   
   -- si no tiene materias aprobadas en ninguna carrera, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN pUnidadAcademica, vc_nroInscripcion, vc_apellido, vc_nombres, vc_documento, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vc_version, vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion,  null, vcconcepto, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_interesado, vc_tipo_carrera, cPromedioResolucion  WITH RESUME;
   END IF;
   
END;

END PROCEDURE                                                                                                                                             
