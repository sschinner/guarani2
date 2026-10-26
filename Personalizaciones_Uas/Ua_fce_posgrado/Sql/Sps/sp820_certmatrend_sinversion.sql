drop PROCEDURE "dba".sp820_certmatrend_sinversion;
CREATE PROCEDURE "dba".sp820_certmatrend_sinversion( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo, pObservaciones VARCHAR(255) )
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(3), decimal(15,0), varchar(5), varchar(60), varchar(20), varchar(15), varchar(5), varchar(5), varchar(100), varchar(20), date, varchar(15), varchar(5), varchar(255), char(1), varchar(10), varchar(10), varchar(15), varchar(5), varchar(5), integer, varchar(15), char(1), integer, varchar(255), varchar(60), varchar(255), varchar(255), float, integer, integer, varchar(15);


-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(3),   -- vc_TipoDocDesAbre
-- decimal(15,0),-- vc_NroDocumento
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
-- varchar(255),  -- forma de aprobacion
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
-- varchar(255), -- pObservaciones
-- varchar(60),  -- vc_UANombre
-- varchar(255), -- vc_LocalidadNombre
-- varchar(255), -- vc_PaisNombre
-- float,        -- vi_Promedio
-- integer,      -- vc_Folio
-- integer,      -- vc_Renglon
-- varchar(15); -- vc_ConceptoNota 



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
DEFINE vc_NroDocumento       LIKE sga_personas.nro_documento;
DEFINE vc_Materia            LIKE sga_materias.materia;
DEFINE vc_MateriaNombre      LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_MateriaNomRed, vc_MateNombreRed      LIKE sga_atrib_mat_plan.nombre_reducido;
DEFINE vdt_Fecha             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_Resultado          VARCHAR(15);
DEFINE vc_Nota               LIKE sga_detalle_acta.nota;
DEFINE vc_FormaAprob         VARCHAR(255);
DEFINE vc_TipoActa           LIKE sga_actas_examen.tipo_acta;
DEFINE vc_Acta               LIKE sga_actas_examen.acta;
DEFINE vc_ActaPromo          LIKE sga_actas_promo.acta;
DEFINE vc_NroResol           LIKE sga_equiv_resol.nro_resolucion;
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


DEFINE vc_DescNota LIKE sga_det_escala.descripcion;
DEFINE vc_ConceptoNota LIKE sga_det_escala.concepto;

-- variables auxiliares
DEFINE vc_Aprobacion         VARCHAR(2);



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
   LET vi_Promedio          = 0 ;
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

   -- datos personales.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres
     INTO vc_UA,
          vc_NroInscripcion,
          vc_TipoDocDesAbre,
          vc_NroDocumento,
          vc_PersonaApellido,
          vc_PersonaNombres
     FROM sga_personas,
          sga_alumnos,
          mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento ;

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
      AND mug_paises.pais = mug_provincias.pais ;

   -- datos de la carrera y el alumno.
   SELECT sga_carreras.carrera,
          sga_carreras.nombre,
          sga_alumnos.legajo,
          sga_alumnos.plan
     INTO vc_Carrera,
          vc_CarreraNombre,
          vc_Legajo,
          vc_PlanAlumno
     FROM sga_alumnos,
          sga_carreras
    WHERE sga_alumnos.unidad_academica = pUA
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
      AND sga_carreras.carrera = sga_alumnos.carrera ;

   -- promedio del alumno en la carrera.
 --  EXECUTE PROCEDURE sp820_prom_alu_res( pUA, pCarrera, pLegajo, 'S')
 --               INTO vi_Promedio;


   -- ejecuto el SP de la historia academica el alumno.
   FOREACH EXECUTE PROCEDURE sp820_histAcademic_sinversion ( pUA, pCarrera, pLegajo ) 
      INTO vc_Materia, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_CarreraNomRed, vc_MateNombreRed, iEscalaNota, iEquivalencia, vc_DescNota, vc_ConceptoNota
      
      -- Solo muestra las Materias que el alumno rindio en un examen.
      IF vc_FormaAprob[1, 6] = 'Examen' AND 
          vc_Resultado = 'Aprobado' AND
                                                            
 vc_materia In (SELECT sga_atrib_mat_plan.materia
						FROM sga_atrib_mat_plan
						          WHERE sga_atrib_mat_plan.unidad_academica = pUA
							AND sga_atrib_mat_plan.carrera = pCarrera
							AND sga_atrib_mat_plan.plan = vc_Plan
							AND sga_atrib_mat_plan.version = vc_Version
							AND sga_atrib_mat_plan.materia = vc_Materia
							AND sga_atrib_mat_plan.sale_listado = 'S') THEN
      
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

         -- *** TRAIGO LA ESCALA DE NOTA SI ESTA CARGADA.

         IF vc_Nota IS NULL THEN

            -- seteo en nulos para que no queden valores anteriores.
            LET vc_Nota         = NULL;
            LET vc_EscalaNota   = NULL;
            LET vc_NotaDescrip  = NULL;
            
         ELSE

            LET vc_Aprobacion = vc_FormaAprob;
            
            -- SEGUN FORMA DE APROBACION.
            -- X EXAMEN.
            IF vc_Aprobacion = 'Ex' and vc_FormaAprob[1, 11] <> 'Examen Ext.' THEN
               SELECT sga_actas_examen.escala_notas
                 INTO vc_EscalaNota
                 FROM sga_actas_examen
                WHERE sga_actas_examen.unidad_academica = vc_UA
                  AND sga_actas_examen.tipo_acta        = vc_TipoActa
                  AND sga_actas_examen.acta             = vc_Acta ;
             END IF;

            -- TRAIGO LA DESCRIPCION DE LA NOTA DE ACUERDO A LA ESCALA SELECCIONADA ANTES.
            SELECT sga_det_escala.descripcion
              INTO vc_NotaDescrip
              FROM sga_det_escala
             WHERE sga_det_escala.escala_notas = iEscalaNota
               AND sga_det_escala.nota =  vc_Nota ;

         END IF;
      
         -- *** TRAIGO EL FOLIO Y RENGLON DE CADA ACTA.
         LET vc_Aprobacion = vc_FormaAprob;
      
         -- X EQUIVALENCIA ESTE DATO NO EXISTE.
         LET vc_Folio   = NULL;
         LET vc_Renglon = NULL;
      
      
         -- SEGUN FORMA DE APROBACION.
         -- X EXAMEN.
         IF vc_Aprobacion = 'Ex' THEN
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
         RETURN vc_UA, vc_NroInscripcion, vc_PersonaApellido, vc_PersonaNombres, vc_TipoDocDesAbre, vc_NroDocumento, vc_Carrera, vc_CarreraNombre, vc_CarreraNomRed, vc_Legajo, vc_PlanAlumno, vc_Materia, vc_MateriaNombre, vc_MateriaNomRed, vdt_Fecha, vc_Resultado, vc_Nota, vc_FormaAprob, vc_TipoActa, vc_Acta, vc_ActaPromo, vc_NroResol, vc_Plan, vc_Version, vc_EscalaNota, vc_NotaDescrip, vc_Promediable, vi_AnioCursada, pObservaciones, vc_UANombre, vc_LocalidadNombre, vc_PaisNombre, vi_Promedio, vc_Folio, vc_Renglon, vc_ConceptoNota   WITH RESUME;
      
      END IF;
      
   END FOREACH;

END;
END PROCEDURE
         
