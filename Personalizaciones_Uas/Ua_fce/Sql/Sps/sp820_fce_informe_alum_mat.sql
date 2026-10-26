DROP PROCEDURE "dba".sp820_fce_informe_alum_mat;
CREATE PROCEDURE "dba".sp820_fce_informe_alum_mat ( pUnidadAcademica varchar(5), pCarrera varchar(5), pLegajo varchar(15), pMateria LIKE sga_atrib_mat_plan.materia)

RETURNING 
	varchar(5), --- unidad academica 
                varchar(10),   -- nro_inscripcion
                varchar(30), -- apellido
                varchar(30), -- nombres
                varchar(5),  -- carrera
                varchar(100), -- carrera_nombre
	varchar(15),  -- legajo
	varchar(5), -- plan
	varchar(5), -- version
	varchar(5), -- materia
	varchar(100), -- nombre de la materia
	varchar(2) , --- tipo de registro
	date ,  -- fecha
	varchar(15), -- resultado
	varchar(5), -- nota
	varchar(255),  -- forma de aprobacion
	char(1), -- tipo de acta
	varchar(15),  -- acta
	varchar(15),  -- acta promocion
	varchar(15), --- nro resolucion
	varchar(15), -- Descripcion de la nota
	varchar(15), -- Concepto de la nota
-------------- de regularidades
  	integer  ,    -- vc_Anio, 
	varchar(20),   -- vc_PerLect, 
	char(1)  ,     -- vc_ResultadoReg, 
	varchar(20) ,  -- vc_ResultadoDesc, 
	varchar(20) ,  -- vc_Origen, 
	date,         -- vd_FinVigencia, 
	date,         -- vd_Regularidad, 
	integer  ,     -- vc_CondRegular;---------- cantidad de materias aprobadas ---- vi_Aprobadas 
	varchar(5) ,  -- vc_PlanReg;
	char(1),    -- Regularidad Vigente o No vigente
	varchar(5),  -- Nota
	integer,     -- Nro de Acta de regulares  -------- cantidad de materias repropbadas ---vi_Reprobadas
	char(1),     -- Materia Aprobada (por examen, equivalencia, promocion)
	varchar (60), -- Descripcion de la regularidad.
-------------------------------------------------------------------------        retornos agregados
	varchar(3),   -------- tipo de documento                
                 varchar(15), --  nro de documento  
                integer, -- anio de ingreso
                char(1),  --  estado alumno en la carrera 
                integer;  -- ultima reinscripcion

------------------------------------------------------------------------          variables agregadas 
DEFINE vc_nroDocumento       VARCHAR(15);
DEFINE vi_anioIngreso integer;
DEFINE vc_estado char(1);
DEFINE vi_ultimaReinsc    integer;
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;


-----------------------
DEFINE vc_apellido         LIKE sga_personas.apellido;
DEFINE vc_nombres          LIKE sga_personas.nombres;
DEFINE vc_carrera          LIKE sga_alumnos.carrera;
DEFINE vc_carrera_nombre   LIKE sga_carreras.nombre;
DEFINE vc_legajo           LIKE sga_alumnos.legajo;
DEFINE vc_CarreraNomRed    LIKE sga_carreras.nombre_reducido;
DEFINE iAnioAcademico   integer;

--------------- variables de materias rendidas

DEFINE vc_materia          LIKE sga_materias.materia;
DEFINE vc_materia_nombre   LIKE sga_materias.nombre;
DEFINE vcNombreMatRed  varchar(30);
DEFINE vdt_fecha           LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_resultado        VARCHAR(15);
DEFINE vc_nota             LIKE sga_detalle_acta.nota;
DEFINE vc_forma_aprob      VARCHAR(255);
DEFINE vc_tipo_acta        LIKE sga_actas_examen.tipo_acta;
DEFINE vc_acta            varchar(15); -- LIKE sga_actas_examen.acta;
DEFINE vc_acta_promo       varchar(15); -- LIKE sga_actas_promo.acta;
DEFINE vc_nro_resol        LIKE sga_equiv_resol.nro_resolucion;
DEFINE iEquivalencia        LIKE sga_equiv_otorgada.equivalencia;
DEFINE vc_car_nom_red      LIKE sga_carreras.nombre_reducido;
DEFINE vi_retorno          SMALLINT;
DEFINE iEscalaNota       integer;
DEFINE vc_plan             LIKE sga_atrib_mat_plan.plan;
DEFINE vc_version          LIKE sga_atrib_mat_plan.version;
DEFINE vcDescripcion	LIKE sga_det_escala.descripcion;
DEFINE vcConcepto	LIKE sga_det_escala.concepto;
-------------------------------------------------------------------------
DEFINE vcCarrera          LIKE sga_alumnos.carrera;
DEFINE vcLegajo           LIKE sga_alumnos.legajo;
DEFINE vc_ResultadoReg     varchar(1);
DEFINE vc_ResultadoDesc    varchar(20);
DEFINE vc_Origen           varchar(20);
DEFINE vd_FinVigencia      LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE vd_Regularidad      LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE vd_Resultado        LIKE sga_det_acta_curs.resultado;
DEFINE vc_CondRegular      LIKE sga_det_acta_curs.cond_regularidad;
DEFINE vc_MateriaNombre    LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_Docentes         varchar(255);
DEFINE vc_Credito          LIKE sga_atrib_mat_plan.credito;
DEFINE vc_PlanReg          LIKE sga_planes.plan;
DEFINE vc_Vigente	   char(1); -- S = Vigente, N = Reg no Vigente
DEFINE vc_Aprobada	   char(1); -- S = Aprobada, N = No Aprobada
DEFINE vc_NotaCur          LIKE sga_det_acta_curs.nota;
DEFINE vc_ActaCur		LIKE sga_det_acta_curs.acta;
DEFINE vcCondRegDesc	like sga_cond_regular.descripcion;
DEFINE vc_planRegReg varchar(5);
DEFINE vc_versionReg varchar(5);
DEFINE vcperlect            LIKE sga_periodos_lect.periodo_lectivo;
DEFINE iNroInscripcion    LIKE sga_personas.nro_inscripcion;
DEFINE vc_UA               LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion   LIKE sga_personas.nro_inscripcion;
---
DEFINE vi_Aprobadas INTEGER;
DEFINE vi_Reprobadas INTEGER;
------------------------
  
DEFINE sqlerr		integer;

DEFINE isamerr		integer;

DEFINE errorinfo		varchar(76);

 on exception set sqlerr, isamerr, errorinfo
    -- error
   raise exception  sqlerr, isamerr, errorinfo;
  end exception;


BEGIN


-- Controlar que se ingresen los datos necesarios para procesar la consulta
IF pCarrera IS NULL OR pcarrera = '' THEN
	RAISE EXCEPTION -746,0,'Debe ingresar una Carrera.';
END IF;

IF pLegajo IS NULL OR plegajo = '' THEN
	RAISE EXCEPTION -746,0,'Debe ingresar el Legajo del Alumno.';
END IF;

IF pMateria IS NULL OR pmateria = '' THEN
	RAISE EXCEPTION -746,0,'Debe ingresar la Materia.';
END IF;


------------------------------------------------------------
---- inicializaciones.
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_carrera          = NULL;
   LET vc_carrera_nombre   = NULL;
   LET vc_legajo           = NULL;
--  LET vd_fecha = to_date(p_Fecha, '%d-%m-%Y');
---  LET r_fecha = vd_fecha;
 ------inicializaciones materias rendidas
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
   LET vc_plan             = NULL;
   LET vc_version          = NULL;
   LET iEscalaNota        = NULL;
   LET iEquivalencia     = NULL;
   LET vcNombreMatRed        = NULL;
   LET vc_car_nom_red   = NULL;
   LET vcDescripcion	= NULL	;
   LET vcConcepto		= NULL	;
   LET vi_retorno          = 0;

-------inicializo cursadas
   LET vcCarrera           = pCarrera;
   LET vcLegajo            = pLegajo;


  ---------------------
   LET vc_notaCur            = NULL;
   LET vc_actaCur            = NULL;
   LET  iAnioAcademico        = NULL;
   LET vcPerLect              = NULL;
   LET vc_ResultadoReg   = NULL;
   LET vc_ResultadoDesc            = NULL;
   LET vc_Origen        = NULL;
   LET vd_FinVigencia           = NULL;
   LET vd_Regularidad     = NULL;
   LET vc_CondRegular           = NULL;
   LET vc_PlanReg           = NULL;
   LET vc_Vigente           = NULL;
   LET vc_notaCur       = NULL;
   LET vc_Acta   = NULL;
   LET vc_Aprobada      = NULL;
   LET vcCondRegDesc        = NULL;
   LET vc_ua= NULL;
  LET  vc_NroInscripcion   = NULL;
  LET vc_Legajo          = NULL;
  LET vc_Materia         = NULL;
------------------------------------------------------------------------          variables agregadas 
LET vc_TipoDocDesAbre = NULL;   
LET vc_nroDocumento = NULL; 
LET vi_anioIngreso = NULL;
LET vc_estado = NULL ;
LET vi_ultimaReinsc   = NULL;
---- obtengo numero de inscripcion del alumno

select nro_inscripcion into  iNroInscripcion  from sga_alumnos where 
                        sga_alumnos.unidad_academica = pUnidadAcademica  AND
		sga_alumnos.carrera = pCarrera AND
		sga_alumnos.legajo = pLegajo;

 IF DBINFO("sqlca.sqlerrd2") = 0 THEN

 	RAISE EXCEPTION -746,0,'No se pudo recuperar el nro. de inscripcion del alumno';

 END IF;

-- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres, mdp_tipo_documento.desc_abreviada, sga_personas.nro_documento
     INTO vc_apellido, vc_nombres,vc_TipoDocDesAbre ,vc_nrodocumento
     FROM sga_personas,   mdp_tipo_documento
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = iNroInscripcion
     AND   mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento  ;

  -- busco nombre carrera
SELECT  sga_carreras.nombre_reducido
             INTO vc_carrera_nombre
             FROM sga_carreras
            WHERE sga_carreras.unidad_academica = pUnidadAcademica
              AND sga_carreras.carrera = pCarrera;
------------------------------------------------------------------------------------------------------------
   -- recupero el plan y version del alumno
  EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, pCarrera, pLegajo, TODAY) INTO vc_Plan, vc_Version ;
----------------------------------
-- selecciono los datos del alumno y materias aprobadas y reprobadas
   LET vi_Aprobadas      = 0 ;
   LET vi_Reprobadas      = 0 ;

   SELECT sga_alumnos.calidad,  
         u820_cuenta_mat_rapido(pUnidadAcademica,pCarrera,pLegajo,"A", vc_Plan, vc_Version),
         u820_cuenta_mat_rapido(pUnidadAcademica,pCarrera,pLegajo,"R", vc_Plan, vc_Version)
     INTO vc_estado, vi_Aprobadas,
             vi_Reprobadas
     FROM sga_alumnos
    WHERE sga_alumnos.unidad_academica = pUnidadAcademica
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo = pLegajo ;
--------------------------------
   SELECT sga_periodo_insc.anio_academico
     INTO vi_anioingreso
     FROM sga_carrera_aspira, sga_periodo_insc 
    WHERE sga_carrera_aspira.unidad_academica = pUnidadAcademica
      AND sga_carrera_aspira.carrera = pCarrera
      AND sga_carrera_aspira.nro_inscripcion = iNroInscripcion
       AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc .periodo_inscripcio;
------------------------------
   select max(rei.anio_academico) into vi_ultimaReinsc  from sga_reinscripcion rei where rei.unidad_academica = pUnidadAcademica
              AND rei.carrera = pCarrera AND rei.legajo = plegajo;


-------------------------------
FOREACH EXECUTE PROCEDURE sp820_histAcademic ( pUnidadAcademica, pCarrera , plegajo ) 
         INTO vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vc_plan, vc_version, vc_car_nom_red, vcNombreMatRed, iEscalaNota, iEquivalencia, vcDescripcion, vcConcepto
   if vc_materia = pmateria then
                 RETURN pUnidadAcademica, iNroInscripcion, vc_apellido, vc_nombres, pCarrera, vc_carrera_nombre, plegajo, vc_plan, vc_version, 
                                 vc_materia,   vc_materia_nombre, 
                                 "MR", vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion, vcconcepto,
                                 iAnioAcademico , vcPerLect , vc_ResultadoReg, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad,vi_Aprobadas,vc_PlanReg, vc_Vigente, vc_notacur , vi_Reprobadas, vc_Aprobada,  vcCondRegDesc
      ---------------- agregados
                                 ,vc_TipoDocDesAbre, vc_nroDocumento, vi_anioIngreso, vc_estado, vi_ultimaReinsc

               WITH RESUME;
   END IF;
             
  END FOREACH;



-- recupera las Inscripciones a Cursadas vigentes de una persona y filtra una materia

 ------inicializaciones materias rendidas
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
   LET vc_plan             = NULL;
   LET vc_version          = NULL;
   LET iEscalaNota        = NULL;
   LET iEquivalencia     = NULL;
   LET vcNombreMatRed        = NULL;
   LET vc_car_nom_red   = NULL;
   LET vcDescripcion	= NULL	;
   LET vcConcepto		= NULL	;
   LET vi_retorno          = 0;
---
   -- recupero el plan y version del alumno
  EXECUTE PROCEDURE sp_plan_de_alumno(pUnidadAcademica, pCarrera, pLegajo, TODAY) INTO vc_Plan, vc_Version ;

FOREACH EXECUTE PROCEDURE sp820_fichalureg(pUnidadAcademica,iNroInscripcion)
         INTO         vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_carrera_nombre, vc_Legajo, vc_Materia, vc_materia_nombre, iAnioAcademico , vcPerLect , vc_ResultadoReg, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vc_CondRegular,vc_PlanReg, vc_Vigente, vc_notacur, vc_Actacur, vc_Aprobada,  vcCondRegDesc

 if vc_materia = pmateria and vc_materia is not null and vc_Carrera = pCarrera then
                 RETURN pUnidadAcademica, iNroInscripcion, vc_apellido, vc_nombres, pcarrera, vc_carrera_nombre, plegajo, vc_plan, vc_version, 
                                pmateria,   vc_materia_nombre, 
                                 "MC", vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion, vcconcepto,
                                 iAnioAcademico , vcPerLect ,vc_ResultadoReg, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vi_Aprobadas,vc_PlanReg, vc_Vigente, vc_notacur, vi_Reprobadas, vc_Aprobada,  vcCondRegDesc
---------------- agregados
                                 ,vc_TipoDocDesAbre, vc_nroDocumento, vi_anioIngreso, vc_estado, vi_ultimaReinsc
               WITH RESUME;
   END IF;

  END FOREACH;
--trace off;
END;
END PROCEDURE;                              


-- execute procedure sp820_fce_informe_alum_mat ( 'FCE', '0201', '27762003-2', '2050')

