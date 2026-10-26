drop PROCEDURE "dba".sp820_alumnoSituacion_ciclo;
CREATE PROCEDURE "dba".sp820_alumnoSituacion_ciclo ( pUnidadAcademica varchar(5), pCarrera varchar(5), pLegajo varchar(15))
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(15), varchar(5), varchar(255), integer, varchar(20), 
        varchar(5), varchar(5), integer, varchar(3), varchar(15), integer, integer, decimal(4,2), integer, varchar(2), varchar(2), varchar(20), integer;

-- Descripcion del Return:
-- varchar(5),   -- vc_UA, 
-- varchar(10),  -- vc_NroInscripcion, 
-- varchar(30),  -- vc_Apellido, 
-- varchar(30),  -- vc_Nombres, 
-- varchar(5),   -- vc_Carrera, 
-- varchar(255), -- vc_CarreraNombre, 
-- varchar(15),  -- vc_Legajo,
 
-- varchar(5),   -- vc_Materia, 
-- varchar(255), -- vc_MateriaNombre, 
-- integer,       -- vc_Anio, 
-- varchar(20),   -- vc_PerLect,     

-- varchar(5),   --    Año reinscripcion,    

-- varchar(5),  -- Calidad  
-- integer,     -- Año ingreso FCE

-- varchar(3),   -- TipoDocDesAbre   
-- varchar(15),  -- NroDocumento  
-- integer, -- Aprobadas
-- integer, -- Reprobadas
-- decimal, -- PromPorAnio

--- agregadas
    -- integer, -- AprAnioAnt
    -- varchar(2), -- Reg1081
    -- varchar(2), -- Apr1080
    -- varchar(20), -- cursadas anio ant
     --  integer; --  Cant Rendidas mal


-- Definición de Variables.
DEFINE vi_retorno          SMALLINT;
DEFINE vc_UA               LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion   LIKE sga_personas.nro_inscripcion;
DEFINE vc_apellido         LIKE sga_personas.apellido;
DEFINE vc_nombres          LIKE sga_personas.nombres;
DEFINE vc_Carrera          LIKE sga_alumnos.carrera;
DEFINE vc_CarreraNombre    LIKE sga_carreras.nombre;
DEFINE vc_CarreraNomRed    LIKE sga_carreras.nombre_reducido;
DEFINE vc_Legajo           LIKE sga_alumnos.legajo;
DEFINE vc_Materia          LIKE sga_materias.materia;
DEFINE vc_Anio             LIKE sga_anio_academico.anio_academico;
DEFINE vc_PerLect          LIKE sga_periodos_lect.periodo_lectivo;
DEFINE vc_ResultadoDesc    varchar(20);
--- agregado
DEFINE vc_Observaciones varchar(200);

DEFINE vc_Origen           varchar(20);
--- agregado
DEFINE vc_FechaUltima varchar(20);
DEFINE vd_FinVigencia      LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE vd_Regularidad      LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE vd_Resultado        LIKE sga_det_acta_curs.resultado;
DEFINE vc_CondRegular      LIKE sga_det_acta_curs.cond_regularidad;
DEFINE vc_MateriaNombre    LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_Docentes         varchar(255);
DEFINE vc_Credito          LIKE sga_atrib_mat_plan.credito;
DEFINE vc_PlanReg          LIKE sga_planes.plan;
---- agregado
DEFINE vc_AnioReinsc 	VARCHAR(5);

DEFINE vc_Resultado        char(1);
DEFINE vc_Vigente	   char(1); -- S = Vigente, N = Reg no Vigente
DEFINE vc_Aprobada	   char(1); -- S = Aprobada, N = No Aprobada
DEFINE vc_Nota          LIKE sga_det_acta_curs.nota;
---- agregado
DEFINE vc_Calidad 	VARCHAR(5);

DEFINE vc_Acta	LIKE sga_det_acta_curs.acta;
---- agregado
DEFINE vc_AnioIngreso	LIKE sga_det_acta_curs.acta;
DEFINE vcCondRegDesc	like sga_cond_regular.descripcion;
--- agregado
DEFINE vc_planRegReg varchar(5);
DEFINE vc_versionReg varchar(5);
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_NroDocumento       VARCHAR(15);
DEFINE vi_Aprobadas INTEGER;
DEFINE vi_Reprobadas INTEGER;
DEFINE vs_PromPorAnio DECIMAL;
DEFINE vi_AprAnioAnt INTEGER;
DEFINE vc_Reg1081 varchar(2);
DEFINE vc_Apr1082 varchar(2);
DEFINE vc_Apr1080 varchar(2);

DEFINE vcCondRegDesc1	like sga_cond_regular.descripcion;
DEFINE a_actual DATE;
DEFINE vc_FechaUltimaa varchar(20);

DEFINE vc_CursAnioAnt    VARCHAR(20);
DEFINE vi_CantRendMal INTEGER;

BEGIN
   
   -- inicializaciones.
   LET vi_retorno          = 0;
   LET vc_UA               = pUnidadAcademica;
   LET vc_NroInscripcion   = NULL;
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_Carrera          = pCarrera;
   LET vc_CarreraNombre    = NULL;
   LET vc_CarreraNomRed    = NULL;
   LET vc_Legajo           = pLegajo;
   LET vc_Materia          = NULL;
   LET vc_Anio             = NULL;
   LET vc_PerLect          = NULL;
   LET vc_Resultado        = NULL;
   LET vc_ResultadoDesc    = NULL;
   LET vc_Observaciones = NULL;
 	
   LET vc_Origen           = NULL;
   LET vc_FechaUltima = NULL;		
   LET vd_FinVigencia      = NULL;
   LET vd_Regularidad      = NULL;
   LET vc_CondRegular      = NULL;
   LET vc_MateriaNombre    = NULL;
   LET vc_Docentes         = NULL;
   LET vc_PlanReg 	   = NULL;
   LET vc_AnioReinsc = NULL;
   LET vc_Vigente 	   = NULL;
   LET vc_Nota	 	   = NULL;
   LET vc_Calidad = NULL;	
   LET vc_Acta = Null;
   LET vc_AnioIngreso 		   = NULL;
   LET vcCondRegDesc	= NULL;
   LET vc_planRegReg 		= NULL;
   LET vc_versionReg 	= NULL;
   LET vc_TipoDocDesAbre    = NULL ;
   LET vc_NroDocumento      = NULL ;
   LET vi_Aprobadas      = 0 ;
   LET vi_Reprobadas      = 0 ;
   LET vs_PromPorAnio      = 0 ;
   LET vi_AprAnioAnt      = 0 ;
   LET vc_Reg1081      = 'NO' ;
   LET vc_Apr1082     = 'NO';
   LET vc_Apr1080     = 'NO';
   LET vc_CursAnioAnt  = NULL;
   LET  vi_CantRendMal = 0;


   -- datos personales.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_carreras.carrera,
          sga_carreras.nombre,
          sga_alumnos.calidad
     INTO vc_UA,
          vc_NroInscripcion,
          vc_TipoDocDesAbre,
          vc_NroDocumento,
          vc_apellido,
          vc_nombres,
          vc_carrera,
          vc_CarreraNombre,
          vc_Calidad
     FROM sga_personas,
          sga_alumnos,
	sga_carreras,
          mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUnidadAcademica
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento 
     AND dba.sga_carreras.carrera = dba.sga_alumnos.carrera;

--    
    select min(p.anio_academico) into vc_AnioIngreso
	from sga_alumnos a 
		join sga_carrera_aspira c 
			join sga_periodo_insc p
			on c.periodo_inscripcio = p.periodo_inscripcio
		on c.unidad_academica = a.unidad_academica
--			and c.carrera = a.carrera
			and c.nro_inscripcion = a.nro_inscripcion
-- se agrega que no considere carreras inválidas
 			and c.situacion_asp not in ('RC','RF','RR')
                where a.legajo = pLegajo
	and a.unidad_academica = pUnidadAcademica;
--	and a.calidad <> 'E';

--   
    select max(rei.anio_academico) into vc_AnioReinsc
	from sga_reinscripcion rei
                where rei.legajo = pLegajo and
                           rei.carrera = pCarrera;
		 
	 	
   ------------------------------------------   APROBADAS/REPROBADAS

SELECT 
         u820_cuenta_mat_rapido(pUnidadAcademica, pCarrera, pLegajo,"A",pla.plan,pla.version_actual),
         u820_cuenta_mat_rapido(pUnidadAcademica, pCarrera, pLegajo,"R",pla.plan,pla.version_actual)
    INTO vi_Aprobadas,
             vi_Reprobadas
    FROM sga_planes pla        
   WHERE     
         pla.unidad_academica = pUnidadAcademica and
         pla.carrera = pCarrera  and
         pla.estado = 'V';
        

-------------------------------------
SELECT   
     
          vw820_hist_academ.legajo,

         vw820_hist_academ.acta_examen_orig,
     
         vw820_hist_academ.materia,
 
         sga_materias.nombre,

         sga_materias.tipo_de_materia,

         vw820_hist_academ.fecha,

         vw820_hist_academ.nota,

         vw820_hist_academ.forma_aprobacion, 

         sga_atrib_mat_plan.anio_de_cursada, 
      
         sga_materias_ciclo.ciclo
         
    
        FROM   

          sga_atrib_mat_plan,

			 sga_alumnos,

			 sga_personas,

          mdp_tipo_documento,

          sga_materias,

          sga_carreras,

         vw820_hist_academ,

         OUTER sga_materias_ciclo 
    
   
        WHERE                            

         sga_atrib_mat_plan.unidad_academica =  pUnidadAcademica   and
 
         sga_atrib_mat_plan.carrera =   pCarrera and

         sga_atrib_mat_plan.plan = vw820_hist_academ.plan    and

         sga_atrib_mat_plan.version =   vw820_hist_academ.version  and

         sga_atrib_mat_plan.materia =  vw820_hist_academ.materia  and
   
             (sga_atrib_mat_plan.materia = sga_materias_ciclo.materia and
                       (tipo_de_materia = 'O' or
                        sga_materias_ciclo.ciclo in
                           (select ciclo from sga_ciclos_plan cp, sga_planes pl
                                where cp.unidad_academica = pUnidadAcademica      AND                                     
                                           cp.carrera = pCarrera  and                                          
                                           cp.carrera = pl.carrera and 
                                           pl.estado = 'V' and
                                           pl.plan = cp.plan and
                                           pl.version_actual = cp.version))) and

(
   (
    sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     vw820_hist_academ.materia in       
           (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     vw820_hist_academ.materia in       
            (select sga_materias_ciclo.materia
                from sga_materias_ciclo 
             where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                              and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
UNION
              (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
             )
   )
)

and
              vw820_hist_academ.materia not in ('1041',
 '1081',
 '1011'
-- , '1800'
)  

           and

  
          sga_materias.tipo_de_materia <> "G" AND

          sga_carreras.carrera = sga_alumnos.carrera and
		
			 sga_alumnos.unidad_academica =   pUnidadAcademica  AND 
			 sga_alumnos.carrera =   pCarrera  AND 
			 sga_alumnos.legajo  =  pLegajo   AND 
 
			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND

			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  AND
         vw820_hist_academ.resultado  = "A" AND
     
           vw820_hist_academ.materia =  sga_materias.materia  AND
      vw820_hist_academ.unidad_academica  =  sga_materias.unidad_academica   AND
 vw820_hist_academ.unidad_academica =  sga_alumnos.unidad_academica AND
     vw820_hist_academ.carrera = sga_alumnos.carrera AND
vw820_hist_academ.legajo = sga_alumnos.legajo AND

 vw820_hist_academ.materia  NOT IN (
SELECT      
         sga_equiv_otorgada.materia
			
    FROM  sga_equiv_otorgada,

          sga_carreras,

			 sga_alumnos,

			 sga_personas,

          mdp_tipo_documento,

          sga_materias,

          sga_equiv_operac,


			OUTER  sga_det_escala  
   WHERE   
                                    
          sga_alumnos.unidad_academica = pUnidadAcademica   AND
			 sga_alumnos.legajo  = pLegajo   AND 
          sga_materias.tipo_de_materia <> "G" AND
          sga_alumnos.carrera =  pCarrera AND


         sga_carreras.carrera = sga_alumnos.carrera and

          sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND
			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  AND

         sga_equiv_otorgada.unidad_academica = pUnidadAcademica  AND  
						
			 sga_equiv_otorgada.legajo =  sga_alumnos.legajo   AND 
           sga_equiv_otorgada.carrera =  sga_alumnos.carrera  AND 	
	
          sga_equiv_operac.operacion_equiv = sga_equiv_otorgada.operacion_equiv AND

          sga_det_escala.escala_notas  =  sga_equiv_otorgada.escala_notas and  
          sga_det_escala.nota        =    sga_equiv_otorgada.nota    and 

          sga_equiv_otorgada.materia =  sga_materias.materia 

 
           AND sga_equiv_otorgada.nota > "5"

)

UNION


SELECT  sga_equiv_otorgada.legajo,
  
        sga_equiv_operac.nro_resolucion,
     
         sga_equiv_otorgada.materia,
 
          sga_materias.nombre,

          sga_materias.tipo_de_materia,

          sga_equiv_otorgada.fecha,
   
          sga_equiv_otorgada.nota,

         "Equivalencia",

		sga_atrib_mat_plan.anio_de_cursada,
           
 sga_materias_ciclo.ciclo		

    FROM  

          sga_atrib_mat_plan,

          sga_equiv_otorgada,

          sga_carreras,

			 sga_alumnos,

			 sga_personas,

          mdp_tipo_documento,

          sga_materias,

          sga_equiv_operac,

                OUTER          sga_materias_ciclo,
			OUTER  sga_det_escala  
   
WHERE   
         
         sga_atrib_mat_plan.unidad_academica =  pUnidadAcademica   and
 
         sga_atrib_mat_plan.carrera =   pCarrera and

         sga_atrib_mat_plan.plan = sga_equiv_otorgada.plan    and

         sga_atrib_mat_plan.version =   sga_equiv_otorgada.version  and

         sga_atrib_mat_plan.materia =  sga_equiv_otorgada.materia  and

           (sga_atrib_mat_plan.materia = sga_materias_ciclo.materia and
                        (tipo_de_materia = 'O' or
                        sga_materias_ciclo.ciclo in
                           (select ciclo from sga_ciclos_plan cp, sga_planes pl
                                where cp.unidad_academica = pUnidadAcademica      AND                                     
                                           cp.carrera = pCarrera  and                                          
                                           cp.carrera = pl.carrera and 
                                           pl.estado = 'V' and
                                           pl.plan = cp.plan and
                                           pl.version_actual = cp.version)))  and


(
   (sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_equiv_otorgada.materia  in       
           (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_equiv_otorgada.materia  in             
            (select sga_materias_ciclo.materia
                from sga_materias_ciclo 
             where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                              and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
UNION 
              (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
             )
   )
)

and

              sga_equiv_otorgada.materia not in ('1041',
 '1081',
 '1011', 
--'1800', 
'1082')  
                                   and
 
          sga_alumnos.unidad_academica = pUnidadAcademica   AND
			 sga_alumnos.legajo  = pLegajo   AND 
          sga_materias.tipo_de_materia <> "G" AND
          sga_alumnos.carrera =  pCarrera AND


         sga_carreras.carrera = sga_alumnos.carrera and

          sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND
			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  AND

         sga_equiv_otorgada.unidad_academica = pUnidadAcademica  AND  
						
			 sga_equiv_otorgada.legajo =  sga_alumnos.legajo   AND 
           sga_equiv_otorgada.carrera =  sga_alumnos.carrera  AND 	
	
          sga_equiv_operac.operacion_equiv = sga_equiv_otorgada.operacion_equiv AND

          sga_det_escala.escala_notas  =  sga_equiv_otorgada.escala_notas and  
          sga_det_escala.nota        =    sga_equiv_otorgada.nota    and 

          sga_equiv_otorgada.materia =  sga_materias.materia 

 
           AND sga_equiv_otorgada.nota > "5"

 


UNION



 SELECT  
   
               sga_alumnos.legajo,
 

         "          ",
      
          sga_atrib_mat_plan.materia,
 
          sga_materias.nombre,

          sga_materias.tipo_de_materia,

         date("01/01/2005"),
  
         "     ",

         "NO",

      sga_atrib_mat_plan.anio_de_cursada,

         sga_materias_ciclo.ciclo


      	
    FROM sga_carreras,

	 sga_alumnos,

	 sga_personas,

          mdp_tipo_documento,

          sga_atrib_mat_plan,

          sga_materias,

                OUTER         sga_materias_ciclo		

	
   WHERE  		 sga_alumnos.unidad_academica =   pUnidadAcademica  AND 
			 sga_alumnos.carrera =   pCarrera  AND 
			 sga_alumnos.legajo  =  pLegajo   AND 

           (sga_atrib_mat_plan.materia = sga_materias_ciclo.materia and
                       (tipo_de_materia = 'O' or
                        sga_materias_ciclo.ciclo in
                           (select ciclo from sga_ciclos_plan cp, sga_planes pl
                                where cp.unidad_academica = pUnidadAcademica      AND                                     
                                           cp.carrera = pCarrera  and                                          
                                           cp.carrera = pl.carrera and 
                                           pl.estado = 'V' and
                                           pl.plan = cp.plan and
                                           pl.version_actual = cp.version)))  and

(
   (sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_atrib_mat_plan.materia in       
           (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_atrib_mat_plan.materia in       
            (select sga_materias_ciclo.materia
                from sga_materias_ciclo 
            where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                              and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
            )
   )
)

and
---------  modificado 09/09/2014
           ---   sga_atrib_mat_plan.materia not in ('1041', '1081', '1011', --'1800', '1082')  
	pCarrera||sga_atrib_mat_plan.materia  not in (select carrera||materia from u820_cursos_ing)       
-----------------------------------------
           and

            sga_atrib_mat_plan.tipo_materia <> "O"

                and
            
          sga_carreras.carrera = sga_alumnos.carrera and

			 sga_atrib_mat_plan.unidad_academica =  sga_alumnos.unidad_academica and
			 sga_atrib_mat_plan.carrera =  sga_alumnos.carrera and	
			 sga_atrib_mat_plan.plan =  sga_alumnos.plan and
          sga_atrib_mat_plan.materia =  sga_materias.materia and

 ( 
   (sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_atrib_mat_plan.version in
           (select sga_planes.version_actual
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUnidadAcademica) 
     and 
     sga_atrib_mat_plan.version in       
            (select sga_ciclos_orient.version
                from sga_ciclos_orient 
            where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                             and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
            )
   )
)

 and

          sga_materias.tipo_de_materia <> "O" and	
          sga_materias.tipo_de_materia <> "G" and	

			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND

			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  and


             not ( (sga_alumnos.carrera = "0203" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '4020',
 '3040',
 '3230',
 '1005',
 '1006',
 '3001'
--,'1800'
)) or

                (sga_alumnos.carrera = "0202" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '4160',
 '3150',
 '1005',
 '1006',
 '4340'
--, '1800'
)) or

                (sga_alumnos.carrera = "0201" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '1005',
 '1006',
 '4340',
 '0154'
--, '1800'
)) )     and

                                             sga_atrib_mat_plan.materia not in

         (   SELECT   
         vw820_hist_academ.materia

			
    FROM   
			  
			 sga_alumnos,

			 sga_personas,

          mdp_tipo_documento,

          sga_materias,

          sga_carreras,


         vw820_hist_academ
			
   WHERE                               
          sga_materias.tipo_de_materia <> "G" AND

          sga_carreras.carrera = sga_alumnos.carrera and
		
				 sga_alumnos.unidad_academica =   pUnidadAcademica  AND 
			 sga_alumnos.carrera =   pCarrera  AND 
			 sga_alumnos.legajo  =  pLegajo   AND 

 
			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND

			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  AND
         vw820_hist_academ.resultado  = "A" AND
     
           vw820_hist_academ.materia =  sga_materias.materia  AND
      vw820_hist_academ.unidad_academica  =  sga_materias.unidad_academica   AND
 vw820_hist_academ.unidad_academica =  sga_alumnos.unidad_academica AND
     vw820_hist_academ.carrera = sga_alumnos.carrera AND
vw820_hist_academ.legajo = sga_alumnos.legajo
          )
        order by 8, 7
         into temp aux_plan_alu with no log;

-- Promedio materias aprobadas por año -  

select  sum(cant) / count(fecha)
into vs_PromPorAnio
from
(select year (fecha) as fecha, count (*) as cant
   from aux_plan_alu 
     where forma_aprobacion <> 'NO'
      group by 1);


-- Cantidad mats aprob año anterior  

select  count (*) 
   into vi_AprAnioAnt
   from aux_plan_alu 
     where forma_aprobacion <> 'NO' and
                year(fecha) = year(TODAY) - 1;

-- REGULARIZADA o APROBADA 1081 / APROBADA 1082

IF EXISTS (select '1'  from sga_cursadas where 	
                    resultado = 'A'
                    and (materia = '1081'  and cond_regularidad = 10)  
                   and fin_vigencia_regul >= TODAY
	    and carrera = pCarrera 
                    and legajo = pLegajo)        or
    EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = pUnidadAcademica
		and carrera = pCarrera 
                                and legajo = pLegajo
    		and materia = '1081'
		and resultado = 'A') then 
       LET   vc_Reg1081      = 'SI' ;
   END IF;

  
IF    EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = pUnidadAcademica
		and carrera = pCarrera 
                                and legajo = pLegajo
    		and materia = '1082'
		and resultado = 'A') then 
       LET vc_Apr1082     = 'SI';
   END IF;

IF     EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = pUnidadAcademica
		and carrera = pCarrera 
                                and legajo = pLegajo
    		and materia = '1080'
		and resultado = 'A') then 
       LET   vc_Apr1080      = 'SI' ;
   END IF;
-- 
    FOREACH
        SELECT materia, nombre, anio_de_cursada, ciclo  
          INTO    vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect
           FROM aux_plan_alu
                where    forma_aprobacion = 'NO'  and materia not in ('1005', '1006')
                             and (materia <> 1800 or 
                                    (materia = 1800 and vc_Apr1080 <> 'SI' and vc_Apr1082 <> 'SI'))
           ORDER BY anio_de_cursada, nombre

        IF vc_Anio is null and vc_Materia in ('1080', '1081', '2330', '1082', '1800') then 
                LET vc_Anio = 1;
        END IF;
       
-- agrega si cursó en el año anterior y cantidad de veces que la rindió mal
----   aca estoy armando
            LET vc_CursAnioAnt  =  ' ';
            select 'Cursada año anterior'
            INTO vc_CursAnioAnt  
            from sga_cursadas
            where 	
                    (sga_cursadas.estado = 'A'
                    and sga_cursadas.materia = vc_Materia 
                   and year(fecha_regularidad)  = year(TODAY) - 1
                   and fecha_regularidad = 
                            (select max(fecha_regularidad) from sga_cursadas cur
                                  where cur.estado = 'A' and
                                            cur.materia = vc_Materia and
                                            cur.carrera = pCarrera and
                                            cur.legajo = pLegajo)
	    and sga_cursadas.carrera = pCarrera 
                    and sga_cursadas.legajo = pLegajo) ;

            LET vi_CantRendMal  =  0;
            select count(vw.legajo)
            INTO vi_CantRendMal          
            from  vw820_hist_academ vw 
            where 	                  
                      (vw.unidad_academica = pUnidadAcademica
		and vw.carrera = pCarrera 
                              and vw.legajo = pLegajo
 		and vw.materia = vc_Materia
 		and vw.resultado = 'R') ;

            RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, 
                 vc_CarreraNombre, vc_Legajo,  vc_Materia, vc_MateriaNombre, vc_Anio, 
                 vc_PerLect,  vc_AnioReinsc,  vc_Calidad, vc_AnioIngreso,  vc_TipoDocDesAbre,
          vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromPorAnio, vi_AprAnioAnt, 
                      vc_Reg1081, vc_Apr1082, vc_CursAnioAnt, vi_CantRendMal  WITH RESUME;  

         LET vi_retorno = 1;            
     END FOREACH;  
 
        
   -- si no tiene materias faltantes, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, NULL, NULL, ' ', NULL, vc_AnioReinsc, vc_Calidad, 
             vc_AnioIngreso,   vc_TipoDocDesAbre,
          vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromPorAnio, vi_AprAnioAnt, vc_Reg1081, vc_Apr1082, vc_CursAnioAnt, vi_CantRendMal WITH RESUME;  
   END IF;

 drop table   aux_plan_alu;

END;
END PROCEDURE;                                                                                                                         
