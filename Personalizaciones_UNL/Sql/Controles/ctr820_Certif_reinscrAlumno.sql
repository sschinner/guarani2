CREATE PROCEDURE verifica_datos()

BEGIN



-- ANTE CUALQUIER ERROR RETORNO



ON EXCEPTION 





END EXCEPTION WITH RESUME;



-- El control es sobre la persona



insert into par_implem_control (stored_procedure, parametros) values ("ctr820_reinscalu", "s,s,s,n");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820015, "ctr820_reinscalu", "Controla la reinscripción anual en una carrera.", "Controla la reinscripción anual en una carrera.", null);

insert into par_cont_x_punto (punto_de_control, control) values (26, 820015);

execute procedure sp_confcont_cont (26, 820015);

	



update sga_conf_controles set activo = 'S'

where operacion = 'agcert01'

and control in ('820015'); 



END

END PROCEDURE;



EXECUTE PROCEDURE verifica_datos();

DROP PROCEDURE verifica_datos();









CREATE PROCEDURE "dba".verifica_objeto()

BEGIN

	IF EXISTS (SELECT procid

			FROM sysprocedures

			WHERE procname = 'ctr820_reinscalu') THEN

		DROP PROCEDURE ctr820_reinscalu;

	END IF;		

END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();



-- *****************************************************************************

-- SIU - SGA - Sistema de Gestion de Alumnos

-- Version 1.11.0

-- Ultima modificacion: Version 2.0.0,2.7.0

-- Procedure ctr820_reinscalu

-- 

-- Controla que la persona este reinscripta en alguna carrera en el año academico actual

-- Si la Persona es ingresante, no controla! 

-- VERIFICA QUE LA CARRERA SEA DE GRADO!!!! (tipo_de_carrera = 'C')

-- SI EL CERTIFICADO PEDIDO ES 100 (CAE) O 9 (HA) O 5 (MA) NO SE CONTROLA, LOS EGRESADOS ESTAN EXCEPTUADOS DEL CONTROL, CUALQUIER ALUMNO REINSCRIP O NO AL AÑO ACADEMICO PUEDE SOLICITAR SU CERTIF HA

-- *****************************************************************************
--EXECUTE PROCEDURE ctr820_reinscalu('ESS','07006','29573787-5','5')

-- DROP PROCEDURE ctr820_reinscalu;

CREATE PROCEDURE ctr820_reinscalu( pUnidadAcademica  LIKE sga_alumnos.unidad_academica,

                                     pCarrera          LIKE sga_alumnos.carrera,

                                     pLegajo           LIKE sga_alumnos.legajo,

                                     pCertificado      LIKE sga_certificados.certificado )



      RETURNING smallint, varchar(255);



-- vars para la respuesta

DEFINE iStatus             smallint;

DEFINE vcMsg               varchar(255);



-- vars para el manejo de excepciones

DEFINE sql_err             integer;

DEFINE isam_err            integer;

DEFINE error_info          varchar(76);



-- vars locales

DEFINE v_anio              LIKE sga_anio_academico.anio_academico;

DEFINE v_cntReinsc, cnt    integer;

DEFINE v_NomCarrera        LIKE sga_carreras.nombre_reducido;

DEFINE vc_TipoCarrera      LIKE sga_carreras.tipo_de_carrera;

DEFINE v_ReinsAluIng       char(1);

DEFINE vcEsIngresante, vcCntrReinsc      char(1);

DEFINE vcNroInscripcion	   LIKE sga_personas.nro_inscripcion;

DEFINE dFechaIngreso       LIKE sga_alumnos.fecha_ingreso;



-- blk de excepciones

ON EXCEPTION SET sql_err, isam_err, error_info

   -- RAISE EXCEPTION  sql_err, isam_err, error_info;

   LET iStatus = -1 ;

   LET vcMsg = '800321' || ',' || 'ctr820_reinscalu' || ',' || sql_err || ' - '  || error_info ;

   RETURN iStatus, vcMsg ;

END EXCEPTION;



BEGIN



   -- OK

   LET iStatus = 1;

   LET vcMsg = '800320'; 

   

   -- Verifico el parametro si reinscribe o no a los alumnos ingresantes!

   EXECUTE PROCEDURE sp_param_sistema('reinscripcion_ingresante') INTO v_ReinsAluIng;





IF (pCertificado <> 100 and pCertificado <> 9 and  pCertificado <> 5) THEN



-- u820 *********************************************************************************************

-- BUSCA EL AÑO CALENDARIO PARA EL CONTROL POR WEB

LET v_anio = YEAR(TODAY);

  



-- u820 *********************************************************************************************



   -- Se fija si el alumno está reinscripto

   SELECT count(*)

     INTO v_cntReinsc

     FROM sga_reinscripcion,   sga_carreras

    WHERE sga_reinscripcion.unidad_academica = pUnidadAcademica

      AND sga_reinscripcion.carrera = pCarrera

      AND sga_reinscripcion.legajo = pLegajo

      AND sga_reinscripcion.anio_academico = v_anio

      AND sga_carreras.unidad_academica = sga_reinscripcion.unidad_academica

      AND sga_carreras.carrera = sga_reinscripcion.carrera;

   



   

   -- NO está reinscripto en la carrera

   IF (v_cntReinsc = 0) THEN

      

      -- Averiguo el Tipo de Carrera, solo controlo a las que son carreras de Grado.

      SELECT sga_carreras.tipo_de_carrera, sga_tipos_carrera.controla_reinscrip

        INTO vc_TipoCarrera, vcCntrReinsc

        FROM sga_carreras, sga_tipos_carrera

       WHERE sga_carreras.unidad_academica = pUnidadAcademica

         AND sga_carreras.carrera = pCarrera

         AND sga_carreras.tipo_de_carrera = sga_tipos_carrera.tipo_de_carrera;

      

      -- ERROR, VERIFICO ANTES DE MANDAR EL ERROR QUE SEA CARRERA DE GRADO!!!

      -- Busca el nombre de la carrera, para devolver el mensaje

      IF (vcCntrReinsc = 'S') THEN

         SELECT nombre_reducido

           INTO v_NomCarrera

           FROM sga_carreras

          WHERE sga_carreras.unidad_academica = pUnidadAcademica

            AND sga_carreras.carrera = pCarrera ;

         

         EXECUTE PROCEDURE sp_es_ingresante(pUnidadAcademica, pCarrera, pLegajo) INTO vcEsIngresante;

         IF vcEsIngresante = 'S' THEN

            -- La Persona es ingresante en la carrera "v_carreraNoReinsc"

            -- verifico si los ingresantes deben reinscribirse.

            IF v_ReinsAluIng = 'S' THEN

               LET iStatus = -1;

               LET vcMsg = '800452, ' || v_NomCarrera;

            END IF;

         ELSE

            -- La persona no es ingresante en la Carrera.	

            LET iStatus = -1;

            LET vcMsg = '800452, ' || v_NomCarrera;

         END IF;

         

      END IF;	-- vcCntrReinsc = 'S'

   END IF;	-- v_cntReinsc = 0

   

END IF;

   RETURN iStatus, vcMsg;

   

END;

END PROCEDURE;

-- ************************* Procedure ctr_reinscrAlumno ****************************

revoke execute on "dba".ctr820_reinscalu from public;

grant execute on "dba".ctr820_reinscalu to guarani; -- Rol de usuarios de Gestion

grant execute on "dba".ctr820_reinscalu to internet; -- Rol de usuario de Internet


