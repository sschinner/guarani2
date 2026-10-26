CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINÚO
ON EXCEPTION 
END EXCEPTION WITH RESUME;


-- Modificación del estado Inicial:
-- Se modifica la DW d_tesis_principal. Se coloca como Initial Value del campo estado = 'CI'


ALTER TABLE sga_tesis_estados
       drop CONSTRAINT ck_tes_est_tipo;

ALTER TABLE sga_tesis_estados
       ADD CONSTRAINT CHECK (TIPO IN ('F', 'I', 'A', 'P', 'D'))
              CONSTRAINT ck_tes_est_tipo;


set constraints all deferred;
delete from sga_tesis_estados where tipo in ('A', 'P', 'D');

-- A: Adelantado
insert into sga_tesis_estados values ('CI', 'Carta Intención', 'A' );  
 -- P: Pendiente
-- insert into sga_tesis_estados values ('APE', 'Anteproyecto pendiente de Entrega', 'P' ); se elimina este estado
delete from sga_tesis_estados where estado = 'APE';

insert into sga_tesis_estados values ('AR', 'Anteproyecto en Revisión', 'P' );
insert into sga_tesis_estados values ('AO', 'Anteproyecto Observado', 'P' );
insert into sga_tesis_estados values ('AA', 'Anteproyecto Aprobado', 'P' );
-- D: Desarrollo
insert into sga_tesis_estados values ('IA1', 'Informe de Avance I', 'D' );
insert into sga_tesis_estados values ('IA2', 'Informe de Avance II', 'D' );
insert into sga_tesis_estados values ('IA3', 'Informe de Avance III', 'D' );
insert into sga_tesis_estados values ('IA4', 'Informe de Avance IV', 'D' );


delete from sga_tesis_maq_esta where estado_actual in ('CI', 'AR', 'AO', 'AA', 'IA1', 'IA2', 'IA3', 'IA4');
delete from sga_tesis_maq_esta where estado_siguiente in ('IA4');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('CI', 'AR');

-- insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('APE', 'AR'); se elimina esta cambio de estado
delete from sga_tesis_maq_esta where estado_actual = 'APE' and estado_siguiente = 'AR';

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AR', 'AO');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AR', 'AA');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AR', 'CI');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AO', 'AR');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AA', 'IA1');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('AA', 'AR');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA1', 'IA2');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA1', 'AA');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA2', 'IA3');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA2', 'IA1');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA3', 'IA4');
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA3', 'IA2');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA4', 'PE'); -- Aqui engancha con el tramite original: PE: Informe final pendiente de entrega
insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('IA4', 'IA3');

insert into sga_tesis_maq_esta (estado_actual, estado_siguiente) values ('PE', 'IA4'); 


END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();
