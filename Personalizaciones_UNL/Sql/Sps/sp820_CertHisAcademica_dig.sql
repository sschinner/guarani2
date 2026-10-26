CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_certhaca_dig') THEN
		DROP PROCEDURE sp820_certhaca_dig;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- PERSONALIZACION:
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Revisado 2.0.0
-- Procedure sp820_certhaca_dig
-- 
-- Muestra la historia academica de una persona (todas las carreras).
-- Usa el SP: sp820_histAcademic (que trae la info de un alumno).
-- *****************************************************************************
CREATE PROCEDURE "dba".sp820_certhaca_dig ( pUnidadAcademica LIKE sga_personas.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pCorresponda varchar(255) DEFAULT 'A QUIEN CORRESPONDA')
       RETURNING varchar(5), varchar(10), varchar(60), varchar(60), varchar(15), varchar(5), varchar(255), varchar(15), varchar(5), varchar(5), varchar(5), varchar(255), date, varchar(15), varchar(5), varchar(255), char(1), varchar(15), varchar(15), varchar(15), varchar(15), Float, varchar(15),  char(1), varchar(10), varchar(60), varchar (255), char(1), char(1), Float, varchar(255), date, varchar(15), varchar(255), integer;


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(60),  -- apellido
-- varchar(60),  -- nombres
-- varchar(15), -- documento
-- varchar(5),   -- carrera
-- varchar(255), -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- varchar(255),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(15),	-- Descripcion de la nota
-- float; -- promedio
-- varchar(15);	-- Concepto de la nota
-- char(1); -- calidad del alumno
-- varchar (10); tipo_documento
-- varchar (60); nombre_ua
-- varchar (60); interesado
-- char(1); -- tipo de carrera
-- char(1); -- si el promedio es por resolucion 609/2010 o no
-- float; -- promedio sin aplazos
-- varchar(255); localidad
-- date; resolucion fecha
-- varchar(15); resolucion numero
-- varchar(255); Titilo superior previo
-- integer; Institucion otorgante

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
DEFINE vc_forma_aprob      VARCHAR(255);
DEFINE vc_tipo_acta        LIKE sga_actas_examen.tipo_acta;
DEFINE vc_acta             varchar(15); -- LIKE  sga_actas_examen.acta;
DEFINE vc_acta_promo  varchar(15); -- LIKE sga_actas_promo.acta;
DEFINE vc_nro_resol        LIKE sga_equiv_operac.nro_resolucion;
DEFINE vc_car_nom_red      LIKE sga_carreras.nombre_reducido;
DEFINE vi_retorno          SMALLINT;
DEFINE	vcDescripcion	LIKE sga_det_escala.descripcion;
DEFINE	vcConcepto	LIKE sga_det_escala.concepto;
DEFINE vfPromedio, vfpromedioSinApl decimal(6,2);
DEFINE vcCalidad		LIKE sga_alumnos.calidad;
DEFINE vc_materia_nom_red varchar (30);
DEFINE vi_escala integer;
DEFINE vi_equivalencia integer;
DEFINE vc_interesado varchar (255);
DEFINE vc_tipo_carrera char(1);
DEFINE cPromedioResolucion char(1);
DEFINE vplan_version_act	LIKE sga_atrib_mat_plan.version;
DEFINE vcLocalidad varchar(255);

DEFINE  dResolucionFecha    date;

DEFINE  vcResolucionNro     varchar(15);

DEFINE vcTituloSuperior varchar(255);
DEFINE viInstitucion integer;
DEFINE vc_sede LIKE sga_alumnos.sede;

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
   LET vfpromedio = NULL;
   LET vfpromedioSinApl = NULL;
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
LET vplan_version_act = NULL;
LET vcTituloSuperior = NULL;
LET viInstitucion = NULL;
LET vc_sede = NULL;


	--------------------------------------------------------------

	-- Datos localidad.

	--------------------------------------------------------------

	IF pUnidadAcademica IN ('FCV', 'FCA') THEN

		LET vcLocalidad = "ESPERANZA";

	ELIF pUnidadAcademica = 'EUA' THEN		  

		LET vcLocalidad = "GÁLVEZ";

	ELSE  

		LET vcLocalidad = "SANTA FE";

	END IF;

   -- selecciono los datos personales de la persona.
   SELECT DISTINCT p.apellido, p.nombres, p.nro_documento, p.nro_inscripcion, a.calidad, tipo.desc_abreviada, ua.nombre, 
	CASE 
		WHEN pUnidadAcademica = 'FICH' and pCarrera = '0003' and a.plan in ('2002', '2014')
		     	THEN 'Tecnicatura en Informática de Gestión'
		WHEN pUnidadAcademica = 'FCE' and pCarrera = '0201' and a.plan in ('0201')
		     	THEN 'Contador Público Nacional' 
		WHEN pUnidadAcademica = 'FCE' and pCarrera = '0207' and a.plan in ('2004', '2007')
		     	THEN 'Tecnicatura en Control y Auditoría Gubernamental' 

		WHEN pUnidadAcademica = 'FIQ' and pCarrera = '00003' and a.plan in ('2009', 'D.T.Q')
		     	THEN 'Doctorado en Tecnología Química' 
		WHEN pUnidadAcademica = 'FIQ' and pCarrera = '00013' and a.plan in ('DCTA')
		     	THEN 'Doctorado en Ciencia y Tecnología de los Alimentos' 
		WHEN pUnidadAcademica = 'ISM' and pCarrera = '02' and a.plan in ('2009')
		     	THEN 'Tecnicatura en Arreglos Musicales'
		WHEN pUnidadAcademica = 'FICH' and pCarrera = '0002' and a.plan in ('2004', '2007', '2014')
		     	THEN 'Tecnicatura en Informática Aplicada a la Gráfica y Animación Digital'
		WHEN pUnidadAcademica = 'FCJS' and pCarrera = 'PG000' and a.plan in ('2016')
		     	THEN 'Especialización en Defensa y Garantías, con orientación en Derecho Penal y Derecho de Familia y Menores' 
		-- FADU
		WHEN pUnidadAcademica = 'FADU' and pCarrera = '12' and a.plan in ('2002')
		     	THEN 'Tecnicatura en Interiorismo y Decoración'
		WHEN pUnidadAcademica = 'FADU' and pCarrera = '9' and a.plan in ('2003')
		     	THEN 'Tecnicatura en Composición de Parques y Jardines'
		-- FBCB
		WHEN pUnidadAcademica = 'FBCB' and pCarrera = '004' and a.plan in ('2004')
		     	THEN 'Tecnicatura en Estadística de Salud'

		-- FCA
		WHEN pUnidadAcademica = 'FCA' and pCarrera = '001' and a.plan in ('2003')
		     	THEN 'Tecnicatura en Gestión y Producción Apícola'
		-- FHUC
		WHEN pUnidadAcademica = 'FHUC' and pCarrera = '21' and a.plan in ('2003')
		     	THEN 'Ciclo de Licenciatura en Periodismo y Comunicación'
		WHEN pUnidadAcademica = 'FHUC' and pCarrera = '21' and a.plan in ('2025')
		     	THEN 'Licenciatura en Periodismo y Comunicación - Ciclo de Complementación Curricular'

		    ELSE car.nombre
	END as nombre,

a.plan, car.tipo_de_carrera, a.sede
     INTO vc_apellido, vc_nombres, vc_documento, vc_nroInscripcion, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_carrera_nombre, vc_alu_plan, vc_tipo_carrera, vc_sede 
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

	--------------------------------------------------------------
	-- Descripcion del Plan
	--------------------------------------------------------------
	SELECT sga_planes.version_actual, sga_planes.fecha_resolucion, sga_planes.nro_resolucion
        INTO vplan_version_act, dResolucionFecha, vcResolucionNro
        FROM sga_planes
        WHERE sga_planes.unidad_academica = pUnidadAcademica
            AND sga_planes.carrera = pCarrera
            AND sga_planes.plan = vc_alu_plan;    
        
        -- Caso particular FCJS: titulo intermedio Procurador de la carrera Abogacia (plan 2000).
	IF (pUnidadAcademica = 'FCJS' AND pCarrera = '1' AND vc_alu_plan IN ('2000')) THEN
		LET vcResolucionNro = 'ME-2309/17';
	-- Caso particular Posgrado FCJS: reoluciones por Sede		
	ELIF (pUnidadAcademica = 'FCJS' AND pCarrera = 'EDA' AND vc_alu_plan IN ('2014') AND vc_sede IN ('00001')) THEN
		LET vcResolucionNro = 'ME-2197/21';
	ELIF (pUnidadAcademica = 'FCJS' AND pCarrera = 'EDA' AND vc_alu_plan IN ('2014') AND vc_sede IN ('00000')) THEN
		LET vcResolucionNro = 'ME-4376/17';		
	ELIF (pUnidadAcademica = 'FCJS' AND pCarrera = 'MDAD' AND vc_alu_plan IN ('2015') AND vc_sede IN ('00001')) THEN
		LET vcResolucionNro = 'ME-2574/21';		
	ELIF (pUnidadAcademica = 'FCJS' AND pCarrera = 'MDAD' AND vc_alu_plan IN ('2015') AND vc_sede IN ('00000')) THEN
		LET vcResolucionNro = 'ME-4007/17';
		
	END IF;
        

	--------------------------------------------------------------
	-- Datos del titulo superior según sean posgrados o no
	--------------------------------------------------------------
	IF vc_tipo_carrera IN ('P', 'S') THEN
		SELECT super.nombre, acad.institucion
		INTO vcTituloSuperior, viInstitucion
		FROM sga_personas per
			join sga_formacion_acad acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
			join sga_titulos_super super
			on acad.titulo_superior = super.titulo_superior
	
		WHERE per.unidad_academica = pUnidadAcademica
			AND per.nro_inscripcion = vc_nroInscripcion
			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 
						from  sga_formacion_acad acad1
						where acad1.unidad_academica = pUnidadAcademica
							and acad1.nro_inscripcion = vc_nroInscripcion);
	ELSE
		IF vc_tipo_carrera = 'W' THEN
			SELECT acad.alu_otestsup_carr
			INTO vcTituloSuperior
			FROM sga_personas per
			join sga_datos_cen_aux2 acad
			on per.unidad_academica = acad.unidad_academica
				and per.nro_inscripcion = acad.nro_inscripcion
				and per.nro_inscripcion  = vc_nroInscripcion
				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 
					from  sga_datos_cen_aux2 acad1
					where acad1.unidad_academica = pUnidadAcademica
						and acad1.nro_inscripcion = vc_nroInscripcion);
		END IF;
	END IF;


   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUnidadAcademica, pCarrera, pLegajo, 'S')  INTO vfpromedio, cPromedioResolucion;
   EXECUTE PROCEDURE sp820_prom_alu_res( pUnidadAcademica, pCarrera, pLegajo, 'N')  INTO vfpromedioSinApl, cPromedioResolucion;

    
      -- ejecuto el SP de la historia academica para cada carrera de la persona.
FOREACH EXECUTE PROCEDURE sp820_histAcademic ( pUnidadAcademica, vc_carrera, vc_legajo ) 
         INTO vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vc_plan, vc_version, vc_car_nom_red, vc_materia_nom_red, vi_escala, vi_equivalencia, vcdescripcion, vcconcepto
            
         -- el retorno final por cada materia.
         -- El atributo sale listado, se recupera de la versiÃ³n actual del plan
         LET vi_retorno = 1;
IF vc_materia In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUnidadAcademica
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vc_alu_plan
							AND sga_atrib_mat_plan.version = vplan_version_act
							-- AND sga_atrib_mat_plan.sale_listado = 'S'
							AND sga_atrib_mat_plan.materia = vc_materia ) THEN

         RETURN pUnidadAcademica, vc_nroInscripcion, vc_apellido, vc_nombres, vc_documento, vc_carrera, vc_carrera_nombre, vc_legajo, vc_alu_plan, vc_version, vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion, vfpromedio, vcconcepto, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_interesado, vc_tipo_carrera, cPromedioResolucion, vfpromedioSinApl, vcLocalidad, dResolucionFecha, vcResolucionNro, vcTituloSuperior, viInstitucion   WITH RESUME;

END IF;

END FOREACH;         

-- reseteo las variables de carrera.
-- LET vc_carrera = NULL;
-- LET vc_car_nom_red = NULL;
-- LET vc_legajo = NULL;
-- LET vc_carrera_nombre = NULL;
  
   
-- si no tiene materias aprobadas en ninguna carrera, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN pUnidadAcademica, vc_nroInscripcion, vc_apellido, vc_nombres, vc_documento, vc_carrera, vc_carrera_nombre, vc_legajo, vc_alu_plan, vc_version, vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion,  null, vcconcepto, vcCalidad, vcTipoDocDesAbre, vc_UANombre, vc_interesado, vc_tipo_carrera, cPromedioResolucion, vfpromedioSinApl, vcLocalidad, dResolucionFecha, vcResolucionNro, vcTituloSuperior, viInstitucion WITH RESUME;
   END IF;

END;

END PROCEDURE;
-- **************************  Fin del Procedure "dba".sp820_certhaca_dig**************************

-- execute PROCEDURE "dba".sp820_certhaca_dig ( 'FBCB', '00005', '36258329-1', null)

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_certhaca_dig 
-- *****************************************************************************
revoke execute on "dba".sp820_certhaca_dig from public;
grant execute on "dba".sp820_certhaca_dig to guarani;  -- Rol de usuarios de Gestion
grant execute on "dba".sp820_certhaca_dig to internet; -- Rol de usuario de Internet


