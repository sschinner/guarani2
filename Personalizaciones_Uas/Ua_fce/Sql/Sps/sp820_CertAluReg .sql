drop PROCEDURE "dba".sp820_CertAluReg;
CREATE PROCEDURE "dba".sp820_CertAluReg ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pInteresado VARCHAR(255) , pObservaciones varchar(255))
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(3), varchar(15), varchar(5), varchar(60), varchar(20), varchar(15), varchar(5), varchar(5), varchar(100), varchar(20), date, varchar(15), varchar(5), varchar(20), char(1), varchar(10), varchar(10), varchar(15), varchar(5), varchar(5), integer, varchar(15), char(1), integer, varchar(255), varchar(60), varchar(255), varchar(255), float, integer, integer, varchar(15), varchar(255);


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- varchar(15),-- vc_NroDocumento
-- varchar(5),   -- carrera
-- varchar(60),  -- carrera_nombre
-- varchar(20),  -- carrera_nombre_reducido
-- varchar(15),  -- legajo
-- varchar(5),   -- plan_alumno
-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- varchar(20),  -- nombre materia reducido
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- varchar(20),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- integer,      -- vc_EscalaNota 
-- varchar(15),  -- vc_NotaDescrip
-- char(1),      -- vc_Promediable
-- integer,      -- vi_AnioCursada
-- varchar(255), -- pInteresado
-- varchar(60),  -- vc_UANombre
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre
-- float,        -- vi_Promedio
-- integer,      -- vc_Folio
-- integer,      -- vc_Renglon
-- varchar(15); -- vc_ConceptoNota 
-- varchar(255); -- pObservaciones




-- variables de retorno.
DEFINE vc_UA                 LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion     LIKE sga_personas.nro_inscripcion;
DEFINE vc_Carrera            LIKE sga_carreras.carrera;
DEFINE vc_CarreraNombre      LIKE sga_carreras.nombre;
DEFINE vc_CarreraNomRed      LIKE sga_carreras.nombre_reducido;
DEFINE vc_Legajo             LIKE sga_alumnos.legajo;
DEFINE vc_PlanAlumno         LIKE sga_alumnos.plan;
DEFINE vc_PersonaApellido    LIKE sga_personas.apellido;
DEFINE vc_PersonaNombres     LIKE sga_personas.nombres;
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_NroDocumento       VARCHAR(15);
DEFINE vc_Materia            LIKE sga_materias.materia;
DEFINE vc_MateriaNombre      LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_MateriaNomRed, vc_MateNombreRed      LIKE sga_atrib_mat_plan.nombre_reducido;
DEFINE vdt_Fecha             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_Resultado          VARCHAR(15);
DEFINE vc_Nota               LIKE sga_detalle_acta.nota;
DEFINE vc_FormaAprob         VARCHAR(20);
DEFINE vc_TipoActa           LIKE sga_actas_examen.tipo_acta;
DEFINE vc_Acta               LIKE sga_actas_examen.acta;
DEFINE vc_ActaPromo          LIKE sga_actas_promo.acta;
DEFINE vc_NroResol           LIKE sga_equiv_operac.nro_resolucion;
DEFINE iEquivalencia           LIKE sga_equiv_otorgada.equivalencia;
DEFINE vc_Plan               LIKE sga_atrib_mat_plan.plan;
DEFINE vc_Version            LIKE sga_atrib_mat_plan.version;
DEFINE vc_EscalaNota , iEscalaNota        LIKE sga_tipos_materia.escala_examen;
DEFINE vc_NotaDescrip        LIKE sga_det_escala.descripcion;
DEFINE vc_LocalidadNombre    LIKE mug_localidades.nombre;
DEFINE vc_PaisNombre         LIKE mug_paises.nombre;
DEFINE vi_Promedio           FLOAT;
DEFINE vc_Folio              LIKE sga_detalle_acta.folio;
DEFINE vc_Renglon            LIKE sga_detalle_acta.renglon;
DEFINE vc_Promediable        LIKE sga_atrib_mat_plan.promediable;
DEFINE vi_AnioCursada        LIKE sga_atrib_mat_plan.anio_de_cursada;
DEFINE vc_UANombre           LIKE sga_unidades_acad.nombre;
DEFINE vi_retorno integer;

DEFINE vc_nacionalidad integer;
DEFINE vc_nro_pasap varchar(15);

DEFINE vc_DescNota LIKE sga_det_escala.descripcion;
DEFINE vc_ConceptoNota LIKE sga_det_escala.concepto;

-- variables auxiliares
DEFINE vc_Aprobacion         VARCHAR(2);
DEFINE vi_cantidad	integer;
DEFINE vianio_academico like sga_periodo_insc.anio_academico;
DEFINE vianio_inscripcio like sga_periodo_insc.anio_academico;

BEGIN

   -- Inicializaciones.
   LET vc_UA                = NULL ;
   LET vc_NroInscripcion    = NULL ;
   LET vc_Carrera           = NULL ;
   LET vc_CarreraNombre     = NULL ;
   LET vc_CarreraNomRed     = NULL ;
   LET vc_Legajo            = NULL ;
   LET vc_PlanAlumno        = NULL ;
   LET vc_PersonaApellido   = NULL ;
   LET vc_PersonaNombres    = NULL ;
   LET vc_TipoDocDesAbre    = NULL ;
   LET vc_NroDocumento      = NULL ;
   LET vc_Materia           = NULL ;
   LET vc_MateriaNombre     = NULL ;
   LET vc_MateriaNomRed     = NULL ;
   LET vdt_Fecha            = NULL ;
   LET vc_Resultado         = NULL ;
   LET vc_Nota              = NULL ;
   LET vc_FormaAprob        = NULL ;
   LET vc_TipoActa          = NULL ;
   LET vc_Acta              = NULL ;
   LET vc_ActaPromo         = NULL ;
   LET vc_NroResol          = NULL ;
   LET vc_Plan              = NULL ;
   LET vc_Version           = NULL ;
   LET vc_EscalaNota        = NULL ;
   LET iEscalaNota        = NULL ;
   LET vc_NotaDescrip       = NULL ;
   LET vc_LocalidadNombre   = NULL ;
   LET vc_PaisNombre        = NULL ;
   LET vi_Promedio          = NULL ;
   LET vc_Aprobacion        = NULL ;
   LET vc_Folio             = NULL ;
   LET vc_Renglon           = NULL ;
   LET vc_Promediable       = NULL ;
   LET vi_AnioCursada       = NULL ;
   LET vc_UANombre          = NULL ;
   LET iEquivalencia         = NULL ;
   LET vc_MateNombreRed = NULL;

LET vc_DescNota = NULL;
LET vc_ConceptoNota = NULL;

LET vi_cantidad = 1;
LET vi_retorno = 0;
LET vianio_academico = NULL;
LET vianio_inscripcio = NULL;

LET vc_nacionalidad  = NULL ;
LET vc_nro_pasap = NULL;

   -- datos personales.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_carreras.carrera,
          sga_carreras.nombre,
		  sga_personas.nacionalidad,
		  sga_personas.nro_pasap
     INTO vc_UA,
          vc_NroInscripcion,
          vc_TipoDocDesAbre,
          vc_NroDocumento,
          vc_PersonaApellido,
          vc_PersonaNombres,
          vc_Carrera,
          vc_CarreraNombre,
		  vc_nacionalidad,
		  vc_nro_pasap
     FROM sga_personas,
          sga_alumnos,
	sga_carreras,
          mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento 
     AND dba.sga_carreras.carrera = dba.sga_alumnos.carrera;

   -- Personalización para ver si es alumno extranjero se cambia el tipo_doc y nro_documento
   IF (vc_nacionalidad = 2) THEN
		IF (vc_nro_pasap IS NOT NULL) THEN 
			LET vc_TipoDocDesAbre = "PAS";
			LET vc_NroDocumento = vc_nro_pasap;
		END IF;
	END IF;
	 
	 
   -- datos de la unidad academica.
   SELECT sga_unidades_acad.nombre
     INTO vc_UANombre
     FROM sga_unidades_acad
    WHERE sga_unidades_acad.unidad_academica = pUA;
   
   SELECT mug_localidades.nombre,
          mug_paises.nombre
     INTO vc_LocalidadNombre, 
          vc_PaisNombre
     FROM sga_unidades_acad,
          mug_localidades,
          mug_dptos_partidos,
          mug_provincias,
          mug_paises
    WHERE mug_localidades.localidad = sga_unidades_acad.localidad
      AND mug_dptos_partidos.dpto_partido = mug_localidades.dpto_partido
      AND mug_provincias.provincia = mug_dptos_partidos.provincia
      AND mug_paises.pais = mug_provincias.pais
	  AND sga_unidades_acad.unidad_academica = pUA;

   -- datos del año academico
	SELECT max(anio_academico)   Into vianio_academico
	FROM sga_anio_academico
	WHERE TODAY > fecha_inicio;

   -- datos del año de ingreso el alumno
	select per.anio_academico  Into vianio_inscripcio
	from sga_alumnos alu
		join sga_carrera_aspira asp
			join sga_periodo_insc per
			on asp.periodo_inscripcio = per.periodo_inscripcio and asp.situacion_asp in ( 'IL', 'IC')
		on alu.nro_inscripcion = asp.nro_inscripcion
		and alu.carrera = asp.carrera
	where alu.legajo = plegajo
		and alu.carrera = pcarrera;

IF vianio_academico <> vianio_inscripcio THEN

   -- datos de la carrera, reinscripcion y el alumno.
   SELECT 
          alu.legajo,
          alu.plan
     INTO 
          vc_Legajo,
          vc_PlanAlumno
     FROM sga_carrera_aspira asp
		join sga_alumnos alu
			join sga_reinscripcion reinsc
				join  sga_carreras car
				on reinsc.carrera = car.carrera
				and reinsc.unidad_academica = car.unidad_academica
				and reinsc.anio_academico = vianio_academico
         			on alu.unidad_academica = reinsc.unidad_academica
			and alu.carrera = reinsc.carrera
			and alu.legajo = reinsc.legajo 
		on asp.nro_inscripcion = alu.nro_inscripcion
		and asp.carrera = alu.carrera
		
    WHERE alu.unidad_academica = pUA
      AND alu.carrera = pCarrera
      AND alu.legajo  = pLegajo
      AND alu.regular = 'S'
      AND alu.calidad = 'A'
      AND asp.situacion_asp in ('IL', 'IC');

ELSE

   SELECT  alu.legajo,
          alu.plan
     INTO  vc_Legajo,
          vc_PlanAlumno
     FROM sga_alumnos alu
		join  sga_carreras car
			on alu.unidad_academica = car.unidad_academica
			and alu.carrera = car.carrera		
    WHERE alu.unidad_academica = pUA
      AND alu.carrera = pCarrera
      AND alu.legajo  = pLegajo
      AND alu.regular = 'S'
      AND alu.calidad = 'A';

END IF;     

  -- retorna si no hizo la reinscripcion, esta pasivo o no es regular

  IF vc_legajo Is null THEN
	RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_CarreraNomRed, vc_Legajo, vc_PlanAlumno, vc_Materia, vc_MateriaNombre, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_EscalaNota, vc_NotaDescrip, vc_Promediable, vi_AnioCursada, pInteresado, vc_UANombre, vc_LocalidadNombre, vc_PaisNombre, vi_Promedio, vc_Folio, vc_Renglon, vc_conceptoNota, pObservaciones;
  END IF;



   -- promedio del alumno en la carrera.
   EXECUTE PROCEDURE sp820_prom_alu_res( pUA, pCarrera, pLegajo, 'S')
                INTO vi_Promedio;


   -- ejecuto el SP de la historia academica el alumno.
   FOREACH EXECUTE PROCEDURE sp820_histAluReg ( pUA, pCarrera, pLegajo ) 
      INTO vc_Materia, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_CarreraNomRed, vc_MateNombreRed, iEscalaNota, iEquivalencia, vc_DescNota, vc_ConceptoNota
      
      -- Solo muestra las Materias que el alumno rindio en un examen y Aprobo.
      IF vc_FormaAprob = 'Examen' and vc_resultado = 'Aprobado' THEN
	LET vi_retorno = 1;
	IF vi_cantidad <= 2 THEN
	-- Solo muestra las ultimas 2 materias
		LET vi_cantidad = vi_cantidad + 1;
      
         -- *** TRAIGO EL NOMBRE LARGO DE LA MATERIA.
         SELECT sga_atrib_mat_plan.nombre_materia,
                         sga_atrib_mat_plan.promediable,
                sga_atrib_mat_plan.anio_de_cursada
           INTO vc_MateriaNombre,
                vc_Promediable,
                vi_AnioCursada
           FROM sga_atrib_mat_plan
          WHERE sga_atrib_mat_plan.unidad_academica = pUA
            AND sga_atrib_mat_plan.carrera = vc_Carrera
            AND sga_atrib_mat_plan.plan = vc_Plan
            AND sga_atrib_mat_plan.version = vc_Version
            AND sga_atrib_mat_plan.materia = vc_Materia ;
         

         -- *** TRAIGO EL FOLIO Y RENGLON DE CADA ACTA.
         LET vc_Aprobacion = vc_FormaAprob;
      
         -- X EQUIVALENCIA ESTE DATO NO EXISTE.
         LET vc_Folio   = NULL;
         LET vc_Renglon = NULL;
      
      
         -- SEGUN FORMA DE APROBACION.
         -- X EXAMEN.
         IF vc_Aprobacion = 'Examen' THEN
            SELECT sga_detalle_acta.folio,
                   sga_detalle_acta.renglon
              INTO vc_Folio, 
                   vc_Renglon
              FROM sga_detalle_acta
             WHERE sga_detalle_acta.unidad_academica = vc_UA
               AND sga_detalle_acta.tipo_acta        = vc_TipoActa
               AND sga_detalle_acta.acta             = vc_Acta 
               AND sga_detalle_acta.carrera          = vc_Carrera
               AND sga_detalle_acta.legajo           = vc_Legajo ;
          END IF;
            
         -- retorno final por cada materia.
         RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_CarreraNomRed, vc_Legajo, vc_PlanAlumno, vc_Materia, vc_MateriaNombre, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_EscalaNota, vc_DescNota, vc_Promediable, vi_AnioCursada, pInteresado, vc_UANombre, vc_LocalidadNombre, vc_PaisNombre, vi_Promedio, vc_Folio, vc_Renglon, vc_conceptoNota, pObservaciones    WITH RESUME;
      

	ELSE -- De la cantidad de materias
		EXIT FOREACH;
	END IF;	
 
      END IF; -- de la forma de aprobacion
      
   END FOREACH;

IF vi_retorno = 0 THEN
	let vc_Materia = NULL;
	let vc_MateriaNombre = NULL;
	let vc_MateriaNomRed = NULL;
	let vdt_Fecha = NULL;
	let vc_Resultado = NULL;
	let vc_Nota = NULL;
	let vc_DescNota = NULL;
	let vc_conceptoNota = NULL;

 RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_CarreraNomRed, vc_Legajo, vc_PlanAlumno, vc_Materia, vc_MateriaNombre, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_EscalaNota, vc_DescNota, vc_Promediable, vi_AnioCursada, pInteresado, vc_UANombre, vc_LocalidadNombre, vc_PaisNombre, vi_Promedio, vc_Folio, vc_Renglon, vc_conceptoNota, pObservaciones  WITH RESUME;
END IF;

END;
END PROCEDURE                                                                                                                                                    
