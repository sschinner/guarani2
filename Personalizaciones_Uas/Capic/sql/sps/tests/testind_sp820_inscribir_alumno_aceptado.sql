select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';



EXECUTE PROCEDURE sp_plan_de_alumno( 'FBCB', 'AI001', '30300300-6', TODAY )


INSERT INTO sga_insc_cursada (unidad_academica, carrera, legajo, comision, fecha_inscripcion, calidad_insc, plan, version, nro_transaccion, interfaz, estado) 
		VALUES ('FBCB',
                aCarrera,
                aLegajo,
                aComision,
                CURRENT YEAR TO SECOND,
                "R",
                aPlan,
                aVersion,
                "Insc. auto. Capic",
                "1",
                "A");