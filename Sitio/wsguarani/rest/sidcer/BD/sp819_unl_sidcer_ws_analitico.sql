CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid

		FROM sysprocedures

			WHERE procname = 'sp819_unl_sidcer_ws_analitico') THEN

		DROP PROCEDURE sp819_unl_sidcer_ws_analitico;

	END IF;		

END

END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();

--  execute procedure  "dba".sp819_unl_sidcer_ws_analitico( 0,'22215550') ;


CREATE PROCEDURE "dba".sp819_unl_sidcer_ws_analitico ( p_tipo_documento LIKE sga_personas.tipo_documento, p_nro_documento LIKE sga_personas.nro_documento) 



RETURNING 	

		integer, 	-- titulo_araucano

		varchar (255), 	-- nombre titulo

		integer, 	-- institucion_araucano

		varchar(5),  	-- carrera

		VARCHAR(255), 	-- nombre carrera 
		
		VARCHAR(100), 	-- nro_resolucion_ministerial

		VARCHAR(15) ,	-- nro_resolucion_coneau

		DATE, 		-- fecha_ingreso

		DATE,  		-- fecha_egreso

		varchar (100), 	-- titulo_anterior_nivel

		varchar (50), 	-- titulo_anterior_nacionalidad

		varchar (255), 	-- titulo_anterior_institucion

		varchar (255), 	-- titulo_anterior_denominacion

		varchar (50), 	-- titulo_anterior_revalidado

		varchar (50), 	-- titulo_anterior_nro_resolucion

		varchar (50), 	-- titulo_anterior_apto_ejercicio

		varchar (1), 	-- plan vigente 

		VARCHAR(255), 	-- Nombre materia  

		varchar(5), 	-- Materia 

		date, 		-- fecha actividad

		varchar(50), 	--  nota

		VARCHAR(1), 	--  resultado

		VARCHAR (50) ,	--  acta 

		VARCHAR (60) ,	--  folio y tomo	

		VARCHAR (50) ,	--  acta resolución

	        	VARCHAR(4), 	--  promedio  

		VARCHAR(4), 	--  promedio sin aplazos

		VARCHAR(20),	--  vc_FormaAprob  

		VARCHAR(255),  	--  plan

		VARCHAR(1),	--  tiene sanciones
		
		varchar(2),  --titulo_esta_cumplido
		
		integer, --vcOrigenTitAnterior
		
		varchar(1),  --tipo 
		
		integer; --creditos








-- Implementar consulta de datos de analítico (según los valores a devolver)

DEFINE viTituloAraucano		integer;

DEFINE vcTituloNombre		varchar(255);

DEFINE viInstitucionAraucano	integer;

DEFINE vcCarrera		varchar(5);

DEFINE vcCarreraNombre		varchar(255);

DEFINE vcResolucionNro		varchar(15);

DEFINE vcResolucionNro_c	varchar(15); -- Nro. resolución CONEAU

DEFINE dIngresoFecha	date;

DEFINE dEgresoFecha	date;



-- titulo anterior variables:

DEFINE vcNivelTitAnterior	varchar (100); --nivel

DEFINE vcNacionTitAnterior	varchar (50);--nacionalidad

DEFINE vcInstitucionHab		varchar(255); --institucion

DEFINE vcTituloSuperior		varchar(255); --denominacion

DEFINE vcRevalidado		varchar (50); --revalidado

DEFINE vcResolucionRev		varchar (50);--nro_resolucion

DEFINE vcAptoEjercicio		varchar (50);--apto_ejercicio





DEFINE vcPlanVigente 		char(1);
DEFINE  vcPlan_aux VARCHAR(255);

DEFINE vcMateriaNombre		varchar(255);

DEFINE vcMateria		varchar(5);

DEFINE dFecha			date;

DEFINE vcNota			varchar(5);

DEFINE vcResultado		varchar(15);

DEFINE vcActa			varchar(10);

DEFINE iFolio			integer;

DEFINE vcNroResolucion		varchar(15);

DEFINE fPromGral		float;

DEFINE fPromSinAplazos		float;

DEFINE vcFormaAprobacion	varchar(20);

DEFINE vcPlan 			varchar(5);

DEFINE viTieneSanciones		varchar(1);

-- 

DEFINE vcLegajo			varchar(15);

DEFINE vcPlanVersion 		varchar(5);

DEFINE vcPlanVersionHA		varchar(5);

DEFINE vcPlanHA			varchar(5);



DEFINE vcSexo			varchar(1);

DEFINE vcMateriaNombreRed	varchar(30);

DEFINE vcConcepto		varchar(15);

DEFINE vcActaTipo		varchar(1); 

DEFINE iEscalaExamen		integer;

DEFINE iEquivalencia		integer;

DEFINE vcDescripcionNota	varchar(15);

DEFINE vcNivel			varchar(15);

DEFINE vcTipoTitulo		varchar(1); 



DEFINE vcOrientacion		varchar(255);

DEFINE vcTipoCarrera		char(1);

DEFINE viInstitucion		integer;



DEFINE vcTitulo 			varchar(5);

DEFINE vcActaPromocion		varchar(10);

DEFINE vcCarreraNombreRed	varchar(30);

DEFINE p_unidad_academica varchar(5);

DEFINE p_nro_inscripcion varchar(15);

DEFINE p_codigo_titulo_araucano integer;

DEFINE vc_titulo_esta_cumplido varchar(2); 

DEFINE vcOrigenTitAnterior  integer;

DEFINE vc_tipo_actividad varchar(1);

DEFINE vc_creditos integer;

BEGIN





-- set debug file to '/tmp/error.log';



-- trace on;



LET viTituloAraucano = NULL;

LET vcTituloNombre = NULL;

LET viInstitucionAraucano = NULL;



LET vcNivelTitAnterior = NULL;

LET vcNacionTitAnterior = NULL;

LET vcInstitucionHab = NULL;

LET vcTituloSuperior = NULL;

LET vcRevalidado = NULL;

LET vcResolucionRev = NULL;

LET vcAptoEjercicio = NULL;



LET vcTipoCarrera = NULL;

LET viInstitucion = NULL;

LET vcOrientacion = NULL;

LET vcTitulo = NULL;

LET vcNivel = NULL;

LET p_unidad_academica = NULL;

LET p_nro_inscripcion = NULL;

LET vcResolucionNro_c = NULL;

LET p_codigo_titulo_araucano = NULL;

LET vc_titulo_esta_cumplido = NULL;

LET vcOrigenTitAnterior = NULL;

LET vc_tipo_actividad = 'A';

LET vc_creditos = 0;

SELECT unidad_academica, nro_inscripcion INTO p_unidad_academica, p_nro_inscripcion
	FROM sga_personas
	WHERE tipo_documento = p_tipo_documento
	AND nro_documento = p_nro_documento;


FOREACH 

--------------------------------------------------------------

-- Datos del título

--------------------------------------------------------------

	SELECT tit.carrera, 

		tit.legajo,
--ACA !!!!!
		(CASE WHEN tit.titulo IS NOT NULL THEN 'SI' ELSE 'NO' END) as titulo_otorg,

		tit.fecha_egreso,

		tit.prom_general,

		tit.prom_sin_aplazos,

		tit.plan,

		

		CASE 

			WHEN ori.nombre is NULL 

		     	THEN ' ' 

			ELSE   CASE 

				WHEN p_unidad_academica = 'FCV' 

				THEN CASE 

					WHEN tt.titulo = '00003' 

					THEN ': ' || ori.nombre 

				 	ELSE ' ' 

				     END

				WHEN p_unidad_academica = 'FHUC'

				THEN CASE 

					WHEN tt.titulo = 'DH' 

					THEN ': ' || ori.nombre 

					ELSE ' ' 

				      END

				ELSE ' '

			       END 

		END,

		tt.titulo,

		 tt.titulo_araucano

		

	INTO vcCarrera, 

		vcLegajo,

		vc_titulo_esta_cumplido,

		dEgresoFecha,

		fPromGral,

		fPromSinAplazos,

		vcPlan,

		vcOrientacion,

		vcTitulo,

		p_codigo_titulo_araucano 



	FROM sga_titulos_otorg  tit,

		sga_titulos tt,

		OUTER (sga_orie_tit_otorg tit_ori, sga_orientaciones ori)





	WHERE tit.unidad_academica = p_unidad_academica

		--AND tt.titulo_araucano = p_codigo_titulo_araucano

		AND tit.nro_inscripcion = p_nro_inscripcion

		AND tit.titulo = tt.titulo 

		AND tit_ori.unidad_academica = tit.unidad_academica

		AND tit_ori.nro_inscripcion = tit.nro_inscripcion

		AND tit_ori.titulo = tit.titulo



		AND ori.unidad_academica = tit_ori.unidad_academica

		AND ori.carrera = tit_ori.carrera

		AND ori.plan = tit_ori.plan

		AND ori.titulo = 	tit_ori.titulo

		AND ori.orientacion = tit_ori.orientacion



	  	AND ori.orientacion <> '0'



--------------------------------------------------------------

-- Tiene sanciones

--------------------------------------------------------------

         SELECT (CASE WHEN count(*) > 0 THEN 'S' ELSE 'N' END) as sancion INTO  viTieneSanciones	 FROM sga_sancion_pers

           WHERE unidad_academica = p_unidad_academica

             AND nro_inscripcion = p_nro_inscripcion

             AND (fecha_desde IS NULL OR fecha_desde <= dEgresoFecha)

             AND (fecha_hasta IS NULL OR fecha_hasta >= dEgresoFecha)

             AND (fecha_canc is null OR (fecha_canc IS NOT NULL AND fecha_canc > dEgresoFecha));



--------------------------------------------------------------

-- Descripcion de la Universidad.

--------------------------------------------------------------

	SELECT sga_unidades_acad.instituc_araucano



	INTO viInstitucionAraucano

	FROM sga_unidades_acad

	WHERE sga_unidades_acad.unidad_academica = p_unidad_academica;

--------------------------------------------------------------

-- Descripcion de la carrera

--------------------------------------------------------------

	SELECT sga_carreras.nombre, sga_carreras.tipo_de_carrera

	INTO vcCarreraNombre, vcTipoCarrera

	FROM sga_carreras

	WHERE sga_carreras.unidad_academica = p_unidad_academica

		AND sga_carreras.carrera = vcCarrera;

--------------------------------------------------------------

-- Descripcion del Plan

--------------------------------------------------------------

	SELECT sga_planes.version_actual, sga_planes.nro_resolucion, DECODE(sga_planes.estado, 'V', 'SI', 'NO')

	INTO vcPlanVersion, vcResolucionNro, vcPlanVigente

	FROM sga_planes

	WHERE sga_planes.unidad_academica = p_unidad_academica

		AND sga_planes.carrera = vcCarrera

		AND sga_planes.plan = vcPlan;



	-- Caso particular FCJS: titulo intermedio Procurador de la carrera Abogacia (plan 2000).

	IF (p_unidad_academica = 'FCJS' AND vcCarrera = '1' AND vcPlan IN ('2000','2018') AND vcTitulo = 'PROIN') THEN

		LET vcResolucionNro = 'ME-2309/17';

	END IF;



--------------------------------------------------------------

-- Datos de la persona

--------------------------------------------------------------

	SELECT	per.sexo,

		alu.fecha_ingreso

	INTO 	vcSexo,

		dIngresoFecha

		

	FROM sga_personas per

		join sga_carrera_aspira car

		on per.unidad_academica = car.unidad_academica

			and per.nro_inscripcion = car.nro_inscripcion

		join sga_alumnos alu

		on car.nro_inscripcion = alu.nro_inscripcion

			and car.carrera = alu.carrera

	

	WHERE per.unidad_academica = p_unidad_academica

		AND per.nro_inscripcion = p_nro_inscripcion

		AND car.carrera = vcCarrera

		AND car.situacion_asp in ('IL', 'IC');



--------------------------------------------------------------

-- Datos del titulo

--------------------------------------------------------------

	SELECT case vcSexo when '1' then tit.nombre when '2' then tit.nombre_femenino else tit.nombre end, 

		tit.nivel, tt.tipo_de_titulo, tit.titulo_araucano, tit.nro_res_coneau

	INTO vcTituloNombre, vcNivel, vcTipoTitulo, viTituloAraucano, vcResolucionNro_c

	FROM sga_titulos tit

		join sga_tipos_titulo tt

		on tit.tipo_de_titulo = tt.tipo_de_titulo

	WHERE tit.unidad_academica = p_unidad_academica

		AND tit.titulo_araucano = p_codigo_titulo_araucano

		AND tit.titulo = vcTitulo;





--------------------------------------------------------------

-- Datos del titulo superior seg\FAn sean posgrados o no: obtenido seg\FAn sp original: sp_titulo_ant_hab

--------------------------------------------------------------

	IF vcTipoCarrera IN ('P', 'S') THEN

		LET vcNivelTitAnterior = 'Universitario';

		SELECT super.nombre, inst.nombre, case inst.pais when "54" then '1' else '2' end, case inst.pais when "54" then 1 else 2 end

		INTO vcTituloSuperior, vcInstitucionHab, vcNacionTitAnterior, vcOrigenTitAnterior 

		FROM sga_personas per

			join sga_formacion_acad acad

			on per.unidad_academica = acad.unidad_academica

				and per.nro_inscripcion = acad.nro_inscripcion

			join sga_titulos_super super

			on acad.titulo_superior = super.titulo_superior



			left join sga_instituciones inst

			on inst.institucion = acad.institucion

	

		WHERE per.unidad_academica = p_unidad_academica

			AND per.nro_inscripcion = p_nro_inscripcion

			AND acad.fecha_egreso = (select max(acad1.fecha_egreso) 

						from  sga_formacion_acad acad1

						where acad1.unidad_academica = p_unidad_academica

							and acad1.nro_inscripcion = p_nro_inscripcion);

	ELSE

		IF vcTipoCarrera = 'W' THEN

			SELECT acad.alu_otestsup_carr, acad.alu_otestsup_uni,  case "acad.alu_otestsup_niv" when "1" then 'Universitario' when "2" then 'Superior no Univ.' end

			INTO vcTituloSuperior, vcInstitucionHab, vcNivelTitAnterior

			FROM sga_personas per

			join sga_datos_cen_aux2 acad

			on per.unidad_academica = acad.unidad_academica

				and per.nro_inscripcion = acad.nro_inscripcion

				and per.nro_inscripcion  = p_nro_inscripcion

				and fecha_relevamiento = (select max(acad1.fecha_relevamiento) 

					from  sga_datos_cen_aux2 acad1

					where acad1.unidad_academica = p_unidad_academica

						and acad1.nro_inscripcion = p_nro_inscripcion);

		ELSE

		  -- Si no es una carrera de Posgrado ni Ciclo entonces se informa el titulo secundario y la institucion

		LET vcNivelTitAnterior = 'Secundario';

		  SELECT sga_coleg_sec.nombre, sga_titulos_sec.descripcion, ""

		    INTO vcInstitucionHab, vcTituloSuperior, vcNacionTitAnterior

		   FROM sga_personas,

			OUTER sga_coleg_sec,

			OUTER sga_titulos_sec

		  WHERE sga_personas.unidad_academica     = p_unidad_academica

		    AND sga_personas.nro_inscripcion      = p_nro_inscripcion 

		    AND sga_coleg_sec.colegio             = sga_personas.colegio_secundario

		    AND sga_titulos_sec.titulo_secundario = sga_personas.titulo_secundario;



		END IF;

	END IF;



--------------------------------------------------------------

-- Barro la vista de historia academica.

-- Recupera TODAS las materias aprobadas o reprobadas por el alumno 

-- de TODOS LOS PLANES de la carrera en la que el alumno tiene registro.

--------------------------------------------------------------

	FOREACH EXECUTE PROCEDURE sp820_histAcaEgre(p_unidad_academica, vcCarrera, vcLegajo) 

		INTO vcMateria,	vcMateriaNombre, dFecha,

			vcResultado, vcNota, vcFormaAprobacion,

			vcActaTipo, vcActa, vcActaPromocion,

			vcNroResolucion, vcPlanHA, vcPlanVersionHA,

			vcCarreraNombreRed, vcMateriaNombreRed, iEscalaExamen, 

			iEquivalencia, vcDescripcionNota, vcConcepto

		

		-- MANEJO DE ALUMNOS QUE NO TIENEN REPROBADAS

		IF vcResultado = 'Reprobado' THEN

			LET vcResultado = 'R';



		ELSE 

			LET vcResultado = 'A';

		END IF;



		-- La materia no existe en el Plan-Version Actual del Alumno

		IF DBINFO("sqlca.sqlerrd2") <= 0 THEN

			-- Recupero el nombre de la materia en el Plan que la aprobo!

			SELECT sga_atrib_mat_plan.nombre_materia

			INTO vcMateriaNombre

			FROM sga_atrib_mat_plan

			WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica

				AND sga_atrib_mat_plan.carrera = vcCarrera

				AND sga_atrib_mat_plan.plan    = vcPlan

				AND sga_atrib_mat_plan.version = vcPlanVersion

				AND sga_atrib_mat_plan.materia = vcMateria;

		END IF;

      



		LET iFolio = NULL;

		-- Aprobado por Examen

		IF   vcFormaAprobacion = 'Examen' or vcFormaAprobacion =  'Examen equivalente' THEN  

			-- Folio Examen.

			SELECT sga_detalle_acta.folio

			INTO iFolio

			FROM sga_detalle_acta

			WHERE sga_detalle_acta.unidad_academica = p_unidad_academica

				AND sga_detalle_acta.tipo_acta = vcActaTipo

				AND sga_detalle_acta.acta      = vcActa

				AND sga_detalle_acta.carrera   = vcCarrera

				AND sga_detalle_acta.legajo    = vcLegajo ;

		END IF;

		-- Aprobado por Promocion	

		IF   vcFormaAprobacion = 'Promoción' or vcFormaAprobacion =  'Promoción en otra carrera' THEN  

			SELECT sga_det_acta_promo.folio

			INTO iFolio

			FROM sga_det_acta_promo

			WHERE sga_det_acta_promo.unidad_academica = p_unidad_academica

				AND sga_det_acta_promo.carrera   = vcCarrera

				AND sga_det_acta_promo.legajo    = vcLegajo

				AND sga_det_acta_promo.acta      = vcActa ;

		END IF;

		-- Verificar que la materia esté actualmente en la última versión

		IF vcmateria In (SELECT sga_atrib_mat_plan.materia

				FROM sga_atrib_mat_plan

				WHERE sga_atrib_mat_plan.unidad_academica = p_unidad_academica

					AND sga_atrib_mat_plan.carrera = vcCarrera

					AND sga_atrib_mat_plan.plan = vcPlan

					AND sga_atrib_mat_plan.version = vcPlanVersion

					AND sga_atrib_mat_plan.materia = vcMateria

					AND sga_atrib_mat_plan.sale_listado = 'S') THEN

			IF vcNivel = 'INTERMEDIO' THEN

				IF vcmateria In  (SELECT mc.materia from sga_titulos tit

					join sga_titulos_plan tp

						join  sga_orientaciones ori

							join sga_ciclos_orient cic

								join sga_materias_ciclo mc

								on cic.ciclo = mc.ciclo		

							on ori.orientacion = cic.orientacion	

							and ori.carrera = cic.carrera

							and ori.plan = cic.plan

							and ori.titulo = cic.titulo

						on tp.carrera =  ori.carrera

						and tp.plan = ori.plan

						and tp.titulo = ori.titulo

					on tit.titulo = tp.titulo

					where tit.nivel = 'INTERMEDIO' and tit.titulo = vcTitulo and cic.version = vcPlanVersion) 

				OR vcmateria In  (select  og.materia_optativa from sga_titulos tit

					join sga_titulos_plan tp

						join  sga_orientaciones ori

							join sga_ciclos_orient cic

								join sga_materias_ciclo mc

								INNER join sga_opt_generica og

								on og.materia_generica=mc.materia 

								and og.carrera=vcCarrera

								and og.plan=vcPlan

								and og.version=vcPlanVersion

								on cic.ciclo = mc.ciclo		

							on ori.orientacion = cic.orientacion	

							and ori.carrera = cic.carrera

							and ori.plan = cic.plan

							and ori.titulo = cic.titulo

						on tp.carrera =  ori.carrera

						and tp.plan = ori.plan

						and tp.titulo = ori.titulo

					on tit.titulo = tp.titulo

					where tit.nivel = 'INTERMEDIO' and tit.titulo = vcTitulo and cic.version = vcPlanVersion)	

					THEN
						-- Caso particular de FADU
						IF vcLegajo = '22215550-5' and p_unidad_academica = 'FADU' and vcCarrera = '1' and vcPlan = '1996' THEN
							let vcPlan_aux = 'Plan 1985 - RCS Nº 404/19';
						ELSE
							LET vcPlan_aux = vcPlan;
						END IF;

					RETURN viTituloAraucano, vcTituloNombre, viInstitucionAraucano, vcCarrera, vcCarreraNombre, vcResolucionNro, vcResolucionNro_c, dIngresoFecha, dEgresoFecha,  vcNivelTitAnterior, vcNacionTitAnterior, vcInstitucionHab, vcTituloSuperior, vcRevalidado, vcResolucionRev, vcAptoEjercicio, vcPlanVigente, vcMateriaNombre, vcMateria, dFecha, vcNota, vcResultado, vcActa, iFolio, vcNroResolucion, fPromGral, fPromSinAplazos, DECODE(vcFormaAprobacion, 'Examen', 'E', 'Promoción', 'P', 'Equivalencia', 'Q', 'Resolución', 'R', vcFormaAprobacion), vcPlan_aux, viTieneSanciones, vc_titulo_esta_cumplido, vcOrigenTitAnterior, vc_tipo_actividad, vc_creditos  WITH RESUME ;

				END IF;

			ELSE

				-- Caso particular de FADU
				IF vcLegajo = '22215550-5' and p_unidad_academica = 'FADU' and vcCarrera = '1' and vcPlan = '1996' THEN
					let vcPlan_aux = 'Plan 1985 - RCS Nº 404/19';
				ELSE
					LET vcPlan_aux = vcPlan;
				END IF;

			RETURN viTituloAraucano, vcTituloNombre, viInstitucionAraucano, vcCarrera, vcCarreraNombre, vcResolucionNro, vcResolucionNro_c, dIngresoFecha, dEgresoFecha,  vcNivelTitAnterior, vcNacionTitAnterior, vcInstitucionHab, vcTituloSuperior, vcRevalidado, vcResolucionRev, vcAptoEjercicio, vcPlanVigente, vcMateriaNombre, vcMateria, dFecha, vcNota, vcResultado, vcActa, iFolio, vcNroResolucion, fPromGral, fPromSinAplazos, DECODE(vcFormaAprobacion, 'Examen', 'E', 'Promoción', 'P', 'Equivalencia', 'Q', 'Resolución', 'R', vcFormaAprobacion), vcPlan_aux, viTieneSanciones,vc_titulo_esta_cumplido, vcOrigenTitAnterior, vc_tipo_actividad, vc_creditos  WITH RESUME ;

			END IF;

		END IF;

	END FOREACH;
END FOREACH;

-- trace off;



END;

END PROCEDURE;

-- ************************** FIN DEL PROCEDURE sp_ted_1e_dig **************************


