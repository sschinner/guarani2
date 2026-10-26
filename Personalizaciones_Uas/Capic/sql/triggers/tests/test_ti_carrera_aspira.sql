*Nombre archivo:
 - ti_carrera_aspira.sql
 *Precondiciones: 
 - La persona existe y esta como aspirante a la carrera
 *Parámetros:

 *Fixture:

1
select * from sga_alumnos
where calidad = 'A' and carrera = 'EXTBI';
select * from sga_alumnos
where calidad = 'A' and carrera <> 'EXTBI';

2
select nro_inscripcion, carrera 
from sga_alumnos
where carrera <> 'EXTBI'
group by 1, 2 
having count(*) = 1;

3
select nro_inscripcion, carrera 
from sga_alumnos
where carrera = 'EXTBI'
group by 1, 2 
having count(*) = 1;

4
select nro_inscripcion, carrera 
from sga_alumnos
where carrera <> 'EXTBI'
group by 1, 2 
having count(*) = 1;

5
Nuevo

6

 *Tests:
 1 - La persona es alumno de la carrera en cuestión (nuestro caso la carrera de integración). No genera Usuario AG
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();
 2 - La persona se inscribe a la carrera de integración y es alumno de alguna/s carrera/s de la UA. No genera Usuario AG
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();
 3 - La persona se inscribe a una carrera de la UA y es alumno unicamente de la carrera de integración. Si genera Usuario AG
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();
 4 - La persona se inscribe a una carrera de la UA y es alumno de alguna/s carrera/s de la UA. No genera Usuario AG
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();
 5 - La persona se inscribe a la carrera de integración y no es alumno de ninguna carrera de la UA. No genera Usuario AG
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();
 6 - La persona es aspirante a la carrera rechazado en otro período de inscripción. Proceden todos los casos salvo el 1.
INSERT INTO sga_carrera_aspira (UNIDAD_ACADEMICA, CARRERA, NRO_INSCRIPCION, PERIODO_INSCRIPCIO, FECHA_INSCRIPCION, SEDE, SITUACION_ASP) values ();

