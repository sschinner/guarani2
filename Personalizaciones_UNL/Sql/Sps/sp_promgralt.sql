
-- ****************** COMIENZO PROCESO sp_promgralt ******************
-- Proceso que se usa para la emisión del titulo.
-- Trae el promedio de todas las materias que rindio
-- la persona para el titulo que se le esta otorgando.
--
-- Ultima version de modificacion: version 2.5.0
-- *******************************************************************

--execute procedure sp_promgralt ('FICH','4120','03','03','29349542-6')

DROP PROCEDURE sp_promgralt;
CREATE PROCEDURE sp_promgralt ( pUA like sga_titulos_otorg.unidad_academica, pNroInscripcion like sga_titulos_otorg.Nro_Inscripcion, pTitulo like sga_titulos_otorg.titulo, pCarrera LIKE sga_titulos_otorg.carrera, pLegajo LIKE sga_titulos_otorg.legajo)
      RETURNING decimal(6,2); --PromGral

DEFINE nSumExam   float;
DEFINE nCantExam  Integer;
DEFINE cPromedioResolucion char(1);
DEFINE nPromedio		DECIMAL(6,2);
DEFINE	vcPlan, vcVersion	varchar(5);
DEFINE	pTodas	varchar(1);


BEGIN

   LET nSumExam      = 0;
   LET nCantExam     = 0; 
   LET nPromedio		= NULL; 
   LET cPromedioResolucion = NULL;
   LET pTodas	= 'S';

  BEGIN
     -- Recupero Historia Academica del Alumno
     ON EXCEPTION IN (-206)
     END EXCEPTION WITH RESUME;

  END

EXECUTE PROCEDURE "dba".sp820_prom_alu_res1(pUA, pCarrera, pLegajo, pTodas) INTO nPromedio;

   -- Retorno el Promedio General   
   RETURN nPromedio;

END;

END PROCEDURE;
-- ****************** FIN PROCESO sp_promgralt ******************


