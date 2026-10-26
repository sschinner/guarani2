--Se revocaron los permisos al rol 'guarani' para las siguientes tablas:
--Se realiza para garantizar el proceso de Legajo Digital que incluye: Alta de Aspirante, Generación de Legajo y Carga de Requisitos.

revoke insert, update on sga_requisitos from guarani;
revoke insert, update on sga_requisitos_car from guarani;
revoke insert, update on sga_requisitos_ua from guarani;
revoke insert, update on sga_fec_excep_req from guarani;
