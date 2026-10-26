--Se debe cargar la tabla app_versiones con la personalización a controlar, insertando el registro con fecha posterior a los del SIU:
--(Cuando se quisiera obligar a sincronizar, realizar una nueva inserción en la tabla y modificar el objeto para que chequee la misma)

insert into app_versiones values ('UNL2.09.2.1',    '12/23/2016',    '2016-12-23 12:00:00',    '1');

