DROP PROCEDURE "dba".sp820_aprob_reprob;

CREATE PROCEDURE "dba".sp820_aprob_reprob( pPeriodoInscripcion LIKE sga_carrera_aspira.periodo_inscripcio, pCarrera LIKE sga_alumnos.carrera, pDesdeAprob integer, pHastaAprob integer, pDesdeReprob integer, pHastaReprob integer,pReinsc  integer, pCuenta integer)
       RETURNING varchar(5),  -- unidad academica
		varchar(5),  -- carrera
		varchar(20),          -- periodo inscripcio
                 varchar(15),          -- legajo
                 varchar(10),          -- nro inscripcion
                 varchar(30),          -- apellido
                 varchar(30),          -- nombres
                 decimal(15),          -- nro documento
                 varchar(5),            -- plan
                 varchar(5),            -- version
                 integer,                 -- aprobadas
                 integer,                 -- reprobadas 
                 varchar(20),      -- periodo inscripcio parametro
	   varchar(5),  -- carrera parametro
                 integer,                 -- aprobadas desde parametro
                 integer,                 -- aprobadas hasta parametro
                 integer,                 -- reprobadas desde parametro
                 integer,                 -- reprobadas hata parametro
                 integer,             -- reinscripcion parametro
                decimal(9,2),	              -- Promedio gral
	 decimal(9,2);	             -- Promedio sin aplazos (academico)


 DEFINE vUnidadAcademica, pUnidadAcademica LIKE sga_alumnos.unidad_academica;
 DEFINE vCarrera LIKE sga_alumnos.carrera;
 DEFINE vPeriodoInscripcio LIKE sga_carrera_aspira.periodo_inscripcio;
 DEFINE vLegajo LIKE sga_alumnos.legajo;
 DEFINE vNroInscripcion LIKE sga_alumnos.nro_inscripcion;
 DEFINE vApellido LIKE sga_personas.apellido;
 DEFINE vNombres LIKE sga_personas.nombres;
 DEFINE vNroDocumento LIKE sga_personas.nro_documento;
 DEFINE vPlan LIKE sga_planes.plan;
 DEFINE vVersion LIKE sga_planes.version_actual;
 DEFINE vAprobadas integer;
 DEFINE vReprobadas integer;
DEFINE  fPromGral           float;
DEFINE  fPromSinAplazos     float;
DEFINE pp varchar(1);


BEGIN

 -- inicializo valores default
 LET pUnidadAcademica   = 'FCE';
 LET vUnidadAcademica   = NULL;
 LET vCarrera   = NULL;
 LET vPeriodoInscripcio   = NULL;
 LET vLegajo   = NULL;
 LET vNroInscripcion   = NULL;
 LET vApellido   = NULL;
 LET vNombres   = NULL;
 LET vNroDocumento   = NULL;
 LET vPlan   = NULL;
 LET vVersion   = NULL;
 LET vAprobadas   = NULL;
 LET vReprobadas   = NULL;
 LET  fPromGral        = NULL;
 LET fPromSinAplazos    = NULL;


/*   select plan, calidad into vplan_alumno, vcalidad
from sga_alumnos
where carrera = pCarrera
	and legajo = pLegajo;
if vcalidad = 'E' then 
	select version  into vplan_version_alumno 
	from sga_titulos_otorg
	where       legajo = pLegajo
                                and carrera = pCarrera
		and plan = vplan_alumno
                            and titulo <>'02-11';  -- se descartan los títulos intermedios para la carrera
else 
	select version_actual into vplan_version_alumno
	from sga_planes
	where carrera = pCarrera
		and plan = vplan_alumno;
end if;
SELECT   nombre_reducido  INTO vcCarNomReducido
FROM   sga_carreras
  WHERE unidad_academica 	= pUnidadAcademica
   AND carrera		= pCarrera;

*/
if (pReinsc <> 0) then
 FOREACH
  SELECT
  alu.unidad_academica,
  alu.carrera,
  asp.periodo_inscripcio,
  alu.legajo,
  alu.nro_inscripcion,
  per.apellido,
  per.nombres,
  per.nro_documento,
  pla.plan,
  pla.version_actual
  INTO	vUnidadAcademica,
	vCarrera,
	vPeriodoInscripcio,
	vLegajo,
	vNroInscripcion,
	vApellido,
	vNombres,
	vNroDocumento,
	vPlan,
	vVersion          
        	FROM 	 sga_alumnos alu,
            		 sga_personas per,
             		 sga_carrera_aspira  asp,
            		 sga_reinscripcion rei,
            		 sga_planes pla    
	WHERE	  
         rei.legajo    =   alu.legajo       and
         rei.carrera   =   alu.carrera      and
          rei.anio_academico = pReinsc  and 
         alu.calidad = "A" and         
        per.nro_inscripcion = alu.nro_inscripcion   and         
         asp.unidad_academica = alu.unidad_academica and
         asp.carrera = alu.carrera and
         asp.nro_inscripcion = alu.nro_inscripcion  and 
         (asp.periodo_inscripcio = pPeriodoInscripcion or
         pPeriodoInscripcion = "Todos") and     
         (asp.carrera = pCarrera or pCarrera = "Todas") and
         pla.unidad_academica = alu.unidad_academica and
         pla.carrera = alu.carrera  and
         pla.estado = 'V' 
    if pCuenta = 0 then   ----- cuenta todas las materias
     execute procedure u820_cuenta_apr_repr  (vUnidadAcademica,vCarrera,vLegajo,vPlan,vVersion) into vAprobadas,           vReprobadas;
   else   --- cuenta solo materias del periodo lectivo de la reinscripción
     execute procedure u820_cuenta_apr_repr_periodo  (vUnidadAcademica,vCarrera,vLegajo,vPlan,vVersion, pReinsc) into vAprobadas,           vReprobadas;
   end if;
     execute  procedure    sp820_prom_alu_res (vUnidadAcademica,vCarrera,vLegajo,'S' ) into  fPromGral, pp;  
    execute   procedure   sp820_prom_alu_res (vUnidadAcademica,vCarrera,vLegajo,'N' ) into  fPromSinAplazos, pp;

       IF vAprobadas >= pDesdeAprob and  vAprobadas <= pHastaAprob and
         vReprobadas >= pDesdeReprob and  vReprobadas <= pHastaReprob  THEN
       --   if  vReprobadas = 0 then
      ---       let fPromGral = fPromSinAplazos;
        ---  end if;

         -- devuelvo los valores
         RETURN     vUnidadAcademica, vCarrera, vPeriodoInscripcio, vLegajo, vNroInscripcion, vApellido,  vNombres, vNroDocumento, vPlan, vVersion,  vAprobadas,  vReprobadas, pPeriodoInscripcion,               pCarrera , pDesdeAprob, pHastaAprob , pDesdeReprob , pHastaReprob ,pReinsc, fPromGral, fPromSinAplazos  
               WITH RESUME;

      END IF;

   END FOREACH ;

else
 FOREACH
  SELECT
  alu.unidad_academica,
  alu.carrera,
  asp.periodo_inscripcio,
  alu.legajo,
  alu.nro_inscripcion,
  per.apellido,
  per.nombres,
  per.nro_documento,
  pla.plan,
  pla.version_actual
  INTO	vUnidadAcademica,
	vCarrera,
	vPeriodoInscripcio,
	vLegajo,
	vNroInscripcion,
	vApellido,
	vNombres,
	vNroDocumento,
	vPlan,
	vVersion          
        	FROM 	 sga_alumnos alu,
            		 sga_personas per,
             		 sga_carrera_aspira  asp,
            		 sga_planes pla    
	WHERE	  
         alu.calidad = "A" and         
        per.nro_inscripcion = alu.nro_inscripcion   and         
         asp.unidad_academica = alu.unidad_academica and
         asp.carrera = alu.carrera and
         asp.nro_inscripcion = alu.nro_inscripcion  and 
         (asp.periodo_inscripcio = pPeriodoInscripcion or
         pPeriodoInscripcion = "Todos") and     
         (asp.carrera = pCarrera or pCarrera = "Todas") and
         pla.unidad_academica = alu.unidad_academica and
         pla.carrera = alu.carrera  and
         pla.estado = 'V' 
        execute procedure u820_cuenta_apr_repr  (vUnidadAcademica,vCarrera,vLegajo,vPlan,vVersion) into vAprobadas,           vReprobadas;
  execute  procedure    sp820_prom_alu_res (vUnidadAcademica,vCarrera,vLegajo,'S' ) into  fPromGral, pp;
execute   procedure   sp820_prom_alu_res (vUnidadAcademica,vCarrera,vLegajo,'N' ) into  fPromSinAplazos, pp;

       IF vAprobadas >= pDesdeAprob and  vAprobadas <= pHastaAprob and
         vReprobadas >= pDesdeReprob and  vReprobadas <= pHastaReprob  THEN
        ---    if  vReprobadas = 0 then
          ---     let fPromGral = fPromSinAplazos;
        ----    end if;

         -- devuelvo los valores
         RETURN     vUnidadAcademica, vCarrera, vPeriodoInscripcio, vLegajo, vNroInscripcion, vApellido,  vNombres, vNroDocumento, vPlan, vVersion,  vAprobadas,  vReprobadas, 
                              pPeriodoInscripcion, pCarrera , pDesdeAprob, pHastaAprob , pDesdeReprob , pHastaReprob ,pReinsc, fPromGral, fPromSinAplazos  
      WITH RESUME;

      END IF;

   END FOREACH ;
end if;
END;

END PROCEDURE                                                            

-- EXECUTE PROCEDURE "dba".sp820_aprob_reprob( '2014', '0201', 1, 7, 2, 8,2015, 0)

