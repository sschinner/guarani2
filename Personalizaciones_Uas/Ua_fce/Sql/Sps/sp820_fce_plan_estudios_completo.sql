DROP  PROCEDURE sp820_fce_plan_estudios_completo;
CREATE PROCEDURE sp820_fce_plan_estudios_completo (p_unidad_academica LIKE sga_alumnos.unidad_academica, p_carrera LIKE sga_alumnos.carrera, pLegajo LIKE sga_alumnos.legajo)

       RETURNING  
                    varchar(15),  ---  legajo
                    varchar(150), --- nombre alumno
                     varchar(21), ---dni
                 varchar(5),    -- unidad_academica,
                 varchar(5),    -- carrera,
                 varchar(255),  -- nombre_carrera,
                 varchar(5),    -- plan,
                 varchar(5),    -- version,
                 varchar(5),    -- titulo,
                 varchar(255),  -- nombre_titulo,
                 varchar(5),    -- orientacion,
                 varchar(255),  -- nombre_orientacion,
                 varchar(5),    -- materia,
                 varchar(255),  -- nombre_materia,
                 integer,       -- total de puntos requeridos,
                 varchar(1),    -- tipo_materia, 
                 integer,       -- anio_de_cursada,
                 varchar(20),   -- periodo_dictado,
                 integer,       -- puntos logrados,
                 varchar(5),    -- materia_optativa,
                 varchar(255),  -- nombre_materia_op,
                 varchar(2),    -- indicador,
            	 varchar(2),   -- modo de agreso
                 char(1), --- resultado
                 varchar(5),     -- nota 
                 date,           -- fecha
                 varchar(10);   -- acta
DEFINE vclegajo   VARCHAR(15);
DEFINE vcnombre_alumno  VARCHAR(55);
DEFINE vcunidad_academica   VARCHAR(5);
DEFINE vcdocumento VARCHAR(21);
DEFINE vccarrera            VARCHAR(5);
DEFINE vcnombre_carrera     VARCHAR(255);
DEFINE vcplan2               VARCHAR(5);
DEFINE vcversion2            VARCHAR(5);
DEFINE vctitulo             VARCHAR(5);
DEFINE vcnombre_titulo      VARCHAR(255);
DEFINE vcorientacion        VARCHAR(5);
DEFINE vcnombre_orientaci   VARCHAR(255);
DEFINE vcmateria            VARCHAR(5);
DEFINE vcnombre_materia     VARCHAR(255);
DEFINE vi_puntos_requerido            INTEGER;
DEFINE vctipo_materia       VARCHAR(1); 
DEFINE vianio_de_cursada    INTEGER;
DEFINE vcperiodo_dictado    VARCHAR(20);
DEFINE vI_puntos_logrados   INTEGER;
DEFINE vcmateria_optativa   VARCHAR(5);
DEFINE vcnombre_materia_op   VARCHAR(255);
DEFINE vcindicador          VARCHAR(2);
DEFINE vitope_cr_reg2       INTEGER;
DEFINE vcegreso       VARCHAR(2);
DEFINE vcVersion		LIKE sga_insc_cursadas.version;
DEFINE vcplan             VARCHAR(5);
DEFINE sResultado          char(1);
DEFINE vMateria            LIKE dba.sga_materias.materia;
DEFINE vtipo_Materia       LIKE dba.sga_atrib_mat_plan.tipo_materia;
DEFINE vcarreras_nombre    LIKE dba.sga_carreras.nombre ;
DEFINE vplan               LIKE dba.sga_alumnos.plan ;
DEFINE vregular            LIKE dba.sga_alumnos.regular;
DEFINE vcalidad            LIKE dba.sga_alumnos.calidad;
DEFINE vnombre_matplan     LIKE dba.sga_atrib_mat_plan.nombre_materia;
DEFINE vpersonas_apellido  LIKE dba.sga_personas.apellido;
DEFINE vpersonas_nombres   LIKE dba.sga_personas.nombres;
DEFINE vnomyape            varchar(150);
DEFINE iTotalpuntos	INTEGER;
DEFINE dFecha             LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vcNota             LIKE sga_detalle_acta.nota;
DEFINE vcActa             LIKE sga_actas_examen.acta;
DEFINE vcResultado         varchar(15);
DEFINE iEscalaNota      integer;
DEFINE cFormaAprob        varchar(255);
DEFINE iEquivalencia             LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcTipoActa          LIKE sga_actas_examen.tipo_acta;
DEFINE vcActaPromo         LIKE sga_actas_promo.acta;
DEFINE vcNroResolucion    LIKE sga_equiv_operac.nro_resolucion;
DEFINE vcFormaAprob        varchar(255);
DEFINE vcNombreMatRed  LIKE sga_materias.nombre_reducido;
DEFINE vcCarreraNomRed  varchar(20);
DEFINE vc_DescNota varchar (15);
DEFINE vc_ConceptoNota varchar (15);
DEFINE lPuntosRequeridos	like sga_materias.puntaje_requerido ;
define vcCalidad   varchar(11);
define vcTipo_de_Titulo   varchar(1);
define dfecvig date;
define dfecvig2 date;

-- Variables para el manejo de excepciones
DEFINE SQL_Err             integer;
DEFINE ISAM_Err          integer;
DEFINE error_Info          varchar(76);

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
begin
on exception in (-206)
-- 	tabla no existe
end exception with resume;
drop table  tmp_Plan_estudio;
drop table  tmp_Plan_estudio2;
DROP TABLE tmp_Plan_estudio3;

end;
 
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

begin
-- obtengo el plan y version del alumno
  ------ EXECUTE PROCEDURE sp_Plan_de_alumno( p_unidad_academica, p_Carrera, pLegajo, TODAY ) 	INTO vcPlan, vcVersion ;
--- Si el alumno es egresado el plan y versión son con los que egresó el alumno 
--- si no es egresado y es de grado es el plan vigente a la fecha
---  si no es egresado y es de posgrado, es el plan con el que ingresó el alumno

SELECT alu.calidad into vcCalidad 
             FROM sga_alumnos alu
              WHERE 	
                 alu.unidad_academica = p_unidad_academica  and  
                 alu.carrera = p_Carrera  and  
                 alu.legajo = pLegajo;
 IF vcCalidad = 'E'
             THEN
                 (SELECT distinct sga_titulos_otorg.plan, sga_titulos_otorg.version
                  INTO vcPlan, vcVersion
                  FROM sga_titulos_otorg
                  WHERE sga_titulos_otorg.unidad_academica = p_unidad_academica 
                  AND sga_titulos_otorg.carrera = p_Carrera
                  AND sga_titulos_otorg.legajo = pLegajo 
                  AND sga_titulos_otorg.fecha_egreso =
                              (SELECT MAX(tito.fecha_egreso)
                                                       FROM  sga_titulos_otorg tito
                                                      WHERE tito.unidad_academica = p_unidad_academica  
                                                      AND tito.carrera = p_Carrera
                                                      AND tito.legajo = pLegajo));
  ELSE
 
              SELECT distinct tipo_de_titulo
		INTO vctipo_de_titulo
			FROM sga_titulos, sga_orientaciones
        			WHERE sga_orientaciones.titulo = sga_titulos.titulo
				AND   sga_orientaciones.unidad_academica   	= p_unidad_academica 
	                		AND   sga_orientaciones.carrera  	= p_Carrera
	                		AND   sga_orientaciones.orientacion 	= '0'
				-----AND   Sga_orientaciones.plan = vplan
				AND   sga_titulos.nivel	= 'GRADO';
              IF vctipo_de_titulo = 'G' THEN 
                    (SELECT sga_planes.plan, sga_planes.version_actual
                        INTO vcPlan, vcVersion
                         FROM sga_planes
                          WHERE sga_planes.unidad_academica = p_unidad_academica  
                           AND sga_planes.carrera = p_Carrera
                           AND sga_planes.estado = 'V');
                ELSE
                    -----------------------------------BUECAR PLAN VERSION ORIGINAL DE POSGRADO
                  SELECT  plan
                                                       into vcPlan
                                                       FROM  sga_cambios_plan tito
                                                      WHERE tito.unidad_academica = p_unidad_academica  
                                                      AND tito.carrera = p_Carrera
                                                      AND tito.legajo = pLegajo
                                                      AND fecha_hasta is null;

                    SELECT sga_planes.version_actual
                        INTO vcVersion
                         FROM sga_planes
                          WHERE sga_planes.unidad_academica = p_unidad_academica  
                           AND sga_planes.carrera = p_Carrera
                           AND sga_planes.plan =vcPlan;

                   /* Se cambia por buscar directamente la versión actual 
                   SELECT MAX(fecha_ent_vigencia)  
                          INTO dfecvig2

         	  FROM 	       sga_versiones_plan

	 WHERE sga_versiones_plan.unidad_academica = p_unidad_academica  
	   AND  sga_versiones_plan.carrera = p_Carrera
	   AND sga_versiones_plan.plan = vcPlan
	   AND  sga_versiones_plan.fecha_ent_vigencia <= dfecvig;

                   SELECT version INTO vcVersion 
             	      FROM 
	       sga_versiones_plan

	  WHERE sga_versiones_plan.unidad_academica = p_unidad_academica  
	   AND  sga_versiones_plan.carrera = p_Carrera
	   AND  sga_versiones_plan.plan = vcPlan
	   AND  sga_versiones_plan.fecha_ent_vigencia = dfecvig2; */

            END IF;

END IF;             
----------------------------------------------------------

-- recupero informacion de materias normales
SELECT DISTINCT sga_atrib_mat_plan.unidad_academica,
                sga_atrib_mat_plan.carrera,
                sga_carreras.nombre nombre_carrera,
                sga_atrib_mat_plan.plan,
		sga_atrib_mat_plan.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion, 
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_plan.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito, --- no se utiliza como tal
		sga_materias.tipo_materia,
		sga_atrib_mat_plan.anio_de_cursada,
		sga_atrib_mat_plan.periodo_dictado,
		sga_planes.tope_cr_cursado,  --- no se utiliza como tal
		sga_planes.tope_cr_reg_vigen,  --- no se utiliza como tal
		----sga_materias.puntaje_requerido,
		sga_atrib_mat_plan.materia materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_op,
		'MN' indicador
	   FROM sga_atrib_mat_plan,
		sga_planes,
		sga_materias_ciclo,
		sga_ciclos_orient,
		sga_carreras,
		sga_materias,
		sga_titulos,
		sga_orientaciones
	 WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_plan.carrera = p_carrera
		AND sga_atrib_mat_plan.plan = vcPlan
		AND sga_atrib_mat_plan.version = vcVersion
		AND sga_atrib_mat_plan.sale_listado = 'S' ---- VER SI SOLO LISTABLES O TODAS
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.unidad_academica = sga_materias_ciclo.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias_ciclo.materia
		AND sga_materias_ciclo.unidad_academica = sga_ciclos_orient.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_ciclos_orient.carrera
		AND sga_atrib_mat_plan.plan = sga_ciclos_orient.plan
		AND sga_atrib_mat_plan.version = sga_ciclos_orient.version
		AND sga_materias_ciclo.ciclo = sga_ciclos_orient.ciclo
		AND sga_ciclos_orient.orientacion = '0'
		AND sga_atrib_mat_plan.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_carreras.carrera
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_ciclos_orient.unidad_academica = sga_titulos.unidad_academica
		AND sga_ciclos_orient.titulo = sga_titulos.titulo

-- aca deberìa corregirse
--		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
--		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
--		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion

		AND sga_ciclos_orient.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_ciclos_orient.carrera= sga_orientaciones.carrera
		AND sga_ciclos_orient.plan=sga_orientaciones.plan
		AND sga_ciclos_orient.titulo = sga_orientaciones.titulo
		AND sga_ciclos_orient.orientacion = sga_orientaciones.orientacion


		AND sga_atrib_mat_plan.tipo_materia='N'

 UNION 
-- recupero informacion de materias normales en orientaciones
SELECT sga_atrib_mat_orie.unidad_academica,
		sga_atrib_mat_orie.carrera,
		sga_carreras.nombre nombre_carrera,
		sga_atrib_mat_orie.plan,
		sga_atrib_mat_orie.version,
		sga_orientaciones.titulo,
		sga_titulos.nombre nombre_titulo,
		sga_orientaciones.orientacion,
		sga_orientaciones.nombre nombre_orientacion,
		sga_atrib_mat_orie.materia,
		sga_atrib_mat_plan.nombre_materia,
		sga_atrib_mat_plan.credito,  --- no se utiliza como tal
		sga_materias.tipo_materia,
		sga_atrib_mat_orie.anio_de_cursada,
		sga_atrib_mat_orie.periodo_dictado,
		sga_planes.tope_cr_cursado,  --- no se utiliza como tal
		sga_planes.tope_cr_reg_vigen,   --- no se utiliza como tal
		----sga_materias.puntaje_requerido,
		sga_atrib_mat_plan.materia materia_optativa,
		sga_atrib_mat_plan.nombre_materia nombre_materia_op,
		'MN' indicador
          FROM sga_atrib_mat_orie,
		sga_atrib_mat_plan,
		sga_planes,
		sga_carreras,
		sga_orientaciones,
		sga_titulos,
		sga_materias
	 WHERE sga_atrib_mat_orie.unidad_academica = sga_carreras.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_carreras.carrera
		AND sga_atrib_mat_orie.unidad_academica = sga_atrib_mat_plan.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_atrib_mat_plan.carrera
		AND sga_atrib_mat_orie.plan = sga_atrib_mat_plan.plan
		AND sga_atrib_mat_orie.version = sga_atrib_mat_plan.version
		AND sga_atrib_mat_orie.materia = sga_atrib_mat_plan.materia
		AND sga_atrib_mat_orie.unidad_academica = p_unidad_academica
		AND sga_atrib_mat_orie.carrera = p_carrera
		AND sga_atrib_mat_orie.plan = vcPlan
		AND sga_atrib_mat_orie.version = vcVersion
		AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
		AND sga_atrib_mat_plan.carrera = sga_planes.carrera
		AND sga_atrib_mat_plan.plan = sga_planes.plan
		AND sga_atrib_mat_plan.sale_listado = 'S' ---- VERRRRR
		AND sga_atrib_mat_plan.unidad_academica = sga_materias.unidad_academica
		AND sga_atrib_mat_plan.materia = sga_materias.materia
		AND sga_atrib_mat_orie.unidad_academica = sga_orientaciones.unidad_academica
		AND sga_atrib_mat_orie.carrera = sga_orientaciones.carrera
		AND sga_atrib_mat_orie.plan = sga_orientaciones.plan
		AND sga_atrib_mat_orie.orientacion = sga_orientaciones.orientacion
		AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
		AND sga_orientaciones.titulo = sga_titulos.titulo
		AND sga_orientaciones.orientacion <> '0'
		AND sga_atrib_mat_plan.tipo_materia='N'
into temp tmp_Plan_estudio with no log;
let vcacta = null;
let dfecha = null;
let vcnota = null;
let vcmateria_optativa = null;
let vcnombre_materia_op = null;
let  vI_puntos_logrados = null;
let vi_puntos_requerido = null;
SELECT unidad_academica, carrera, nombre_carrera, plan, version, titulo, nombre_titulo, orientacion, nombre_orientacion,  materia, nombre_materia, vi_puntos_requerido as puntos_requerido, tipo_materia, 
 anio_de_cursada, periodo_dictado, vI_puntos_logrados as puntos_logrados, vcmateria_optativa as materia_optativa, vcnombre_materia_op as nombre_materia_op, indicador,'' as Resultado, vcnota  as Nota, dfecha as Fecha, vcacta as Acta FROM tmp_Plan_estudio
INTO temp tmp_Plan_estudio2 with no log;


------- Recupera materias Genéricas y su aprobación
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
dba.sga_atrib_mat_plan.nombre_materia,
dba.sga_atrib_mat_plan.anio_de_cursada,
dba.sga_atrib_mat_plan.periodo_dictado

   	 INTO   vcCarrera, vcLegajo, vplan,vregular,vcalidad,vmateria,vtipo_Materia, vnomyape , vcarreras_nombre,vnombre_matplan,vianio_de_cursada, vcperiodo_dictado

  	FROM 
		dba.sga_alumnos,
       		dba.sga_atrib_mat_plan,
		dba.sga_planes,
		dba.sga_carreras,
		dba.sga_personas
                WHERE 		
	             dba.sga_alumnos.unidad_academica  	= p_unidad_academica	
	   AND dba.sga_alumnos.carrera 	 	= p_carrera
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
		SELECT sga_orientaciones.titulo , sga_titulos.nombre, sga_orientaciones.orientacion,sga_orientaciones.nombre
			INTO vcTitulo, vcnombre_titulo,vcorientacion, vcnombre_orientaci
			FROM sga_orientaciones,sga_titulos
        			WHERE sga_orientaciones.titulo = sga_titulos.titulo
				AND   sga_orientaciones.unidad_academica   	= p_unidad_academica
	                		AND   sga_orientaciones.carrera  	= p_carrera  
	                		AND   sga_orientaciones.orientacion 	= '0'
				AND   Sga_orientaciones.plan = vplan
				AND   sga_titulos.nivel	= 'GRADO';
			   	
		LET sResultado = '';

	EXECUTE PROCEDURE sp820_listaGenericas(p_unidad_academica, p_carrera, vcLegajo, vcTitulo,'0' ,vmateria, vcPlan, vcVersion) INTO sResultado, iTotalpuntos,lPuntosRequeridos;
	insert into tmp_Plan_estudio2
                 values (p_unidad_academica, p_carrera, vcarreras_nombre, vcPlan, vcVersion, vctitulo,vcnombre_titulo , vcorientacion, vcnombre_orientaci, Vmateria, vnombre_matplan, lPuntosRequeridos, 'G', 
                vianio_de_cursada, vcperiodo_dictado,iTotalpuntos, '', '', 'MG',sResultado,'','','');
         	
 END FOREACH ;  
-- actualizo el año y periodo de cursada de cada optativa de las genericas y otros datos
-- se presupone que la genérica tiene el año y periodo y todas las optativas tienen que amoldarse

           foreach select distinct orientacion, nombre_orientacion, materia, nombre_materia, anio_de_cursada, periodo_dictado, titulo, nombre_titulo, nombre_carrera
	into vcorientacion, vcnombre_orientaci, vcmateria, vcnombre_materia,vianio_de_cursada, vcperiodo_dictado,vctitulo,vcnombre_titulo,vcarreras_nombre 
	from tmp_Plan_estudio2
	where indicador='MG'

	update tmp_Plan_estudio2 set anio_de_cursada= vianio_de_cursada,
				periodo_dictado=vcperiodo_dictado,
                                                                nombre_carrera = vcarreras_nombre,
				nombre_materia = vcnombre_materia,
                                                                nombre_titulo = vcnombre_titulo,
                                                                nombre_orientacion = vcnombre_orientaci
				where orientacion=vcorientacion and  titulo = vctitulo
					and materia=vcmateria and 
					indicador='MO' ;

end foreach;


-- recupero los modos de egreso de cada titulo que otorga el plan
SELECT DISTINCT unidad_academica, carrera, plan, titulo, calculo_egreso
	FROM sga_titulos_plan 
	WHERE unidad_academica = p_unidad_academica AND
		carrera = p_carrera AND
		plan = vcPlan
into temp tmp_Plan_estudio3 with no log;
------ Recupero las materias aprobadas
Foreach
               EXECUTE PROCEDURE sp820_histAcademic ( p_unidad_academica, p_carrera, pLegajo ) 
                     INTO vcMateria, vcNombre_Materia, dFecha, vcResultado, vcNota, vcFormaAprob, vcTipoActa, vcActa, vcActaPromo, vcNroResolucion, vcPlan, vcVersion, vcCarreraNomRed, vcNombreMatRed, iEscalaNota, iEquivalencia, vc_DescNota,                                  vc_ConceptoNota
               if vcResultado = 'Aprobado' then
                    update tmp_Plan_estudio2 set Nota = vcNota, Resultado = 'A' , acta = vcActa, Fecha = dFecha where materia = vcMateria and tipo_materia = 'N'; 
                    update tmp_Plan_estudio2 set Nota = vcNota, Resultado = 'A' , acta = vcActa, Fecha = dFecha where materia_optativa = vcMateria and tipo_materia = 'O'; 
               end if;
 END FOREACH ;   
  update tmp_Plan_estudio2  set Resultado = 'R' where Resultado = '';
-----

-- retorno la informacion generada y ordenada
foreach select   sga_alumnos.legajo, TRIM( sga_personas.apellido) || ', ' || TRIM( sga_personas.nombres)  , mdp_tipo_documento.desc_abreviada || ' -  ' ||  sga_personas.nro_documento,
                         tpe2.unidad_academica, tpe2.carrera, nombre_carrera, tpe2.plan, version, tpe2.titulo, nombre_titulo, orientacion, nombre_orientacion,  materia, nombre_materia, puntos_requerido, 
		tipo_materia, anio_de_cursada, periodo_dictado, puntos_logrados, materia_optativa, nombre_materia_op, indicador, 
                      calculo_egreso, resultado, Nota, Fecha, ACTA
	into vclegajo,vcnombre_alumno, vcdocumento, vcunidad_academica, vccarrera, vcnombre_carrera, vcplan2, vcversion2, vctitulo, vcnombre_titulo, vcorientacion, vcnombre_orientaci, vcmateria, vcnombre_materia, vi_puntos_requerido, 
		vctipo_materia, vianio_de_cursada, vcperiodo_dictado, vI_puntos_logrados, vcmateria_optativa, vcnombre_materia_op, vcindicador, 
	                    vcegreso,sResultado, vcNota, dFecha, vcACTA
	from tmp_Plan_estudio2 tpe2, tmp_Plan_estudio3 tpe3, sga_alumnos, sga_personas, mdp_tipo_documento
	where tpe2.unidad_academica = tpe3.unidad_academica
		and tpe2.carrera = tpe3.carrera
		and tpe2.plan = tpe3.plan
		and tpe2.titulo = tpe3.titulo
                                and sga_alumnos.unidad_academica =   tpe2.unidad_academica  AND 
			 sga_alumnos.carrera =   tpe2.carrera  AND 
			 sga_alumnos.legajo  =  plegajo   AND 
 			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND
			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  

---    tratamiento para materias de 0205
                              and (sga_alumnos.carrera <> '0205' or
                                       (sga_alumnos.carrera = '0205' and
                                        materia in (select materia 
                                                from sga_materias_ciclo cc 
                                               where cc.ciclo =  'CBC-2' 
                                                      or cc.materia in ('1080', '1081', '1082', '1800', '5000'))))
---    tratamiento para las introducciones en todas las carreras
                              and materia not in  ('1011', '1041')   

---  	ORDER BY tpe2.titulo, orientacion, anio_de_cursada, nombre_materia
	ORDER BY tpe2.titulo, orientacion, anio_de_cursada, periodo_dictado, materia, materia_optativa, indicador desc
	return vclegajo,vcnombre_alumno, vcdocumento,vcunidad_academica, vccarrera, vcnombre_carrera, vcplan2, vcversion2 ,vctitulo, vcnombre_titulo, vcorientacion, vcnombre_orientaci, vcmateria, vcnombre_materia, vi_puntos_requerido, 
		vctipo_materia, vianio_de_cursada, vcperiodo_dictado, vI_puntos_logrados, vcmateria_optativa, vcnombre_materia_op, vcindicador, 
                                ----vitope_cr_reg2 , 
                             vcegreso, sResultado, vcNota, dFecha, vcACTA with resume;

end foreach;

DROP TABLE tmp_Plan_estudio;
DROP TABLE tmp_Plan_estudio2;
DROP TABLE tmp_Plan_estudio3;
end;
END PROCEDURE;                                        
  
-------------

