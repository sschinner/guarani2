# Primer caso: Inscribir a un nuevo alumno, que no esta ni en sga_personas, ni en sga_alumnos, ni en sga_carrera_aspira


select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';


execute procedure sp820_inscribir_carrera_capic("2008","01/01/2008","SCHINNER","SEBASTIAN","0","30300300","1");       --BIEN!!




# Segundo caso: Inscribir un alumno que solo es persona, pero no esta en sga_carrera_aspira ni en sga_alumnos
# Borro a SCHINNER de las tablas sga_carrera_aspira y de sga_alumnos, pero lo dejo en sga_personas...

select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';




delete from sga_alumnos
where carrera = 'AI001';

delete from sga_carrera_aspira
where carrera = 'AI001';




execute procedure sp820_inscribir_carrera_capic("2008","01/01/2008","SCHINNER","SEBASTIAN","0","30300300","1");    


# Tercer caso: Inscribir un alumno que es persona, esta inscripto en sga_carrera_aspira y no en sga_alumnos
# Borro a SCHINNER de la tabla sga_alumnos, pero lo dejo en sga_carrera_aspira y sga_personas...
# Borrar al alumno de sga_alumnos implica cambiar la situacion del aspirante en sga_carrera_aspira a AC y luego borrar la linea de sga_alumnos
# Sin enbargo no deberia pasar nunca que un alumno este en sga_carrera_aspira y no este en sga_alumnos por eso este caso no es tan tenido en cuenta 

select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';


delete from sga_alumnos
where carrera = 'AI001'


execute procedure sp820_inscribir_carrera_capic("2008","01/01/2008","SCHINNER","SEBASTIAN","0","30300300","1"); 


# Caso 4: Borrar todo a pata e intentar inscribir nuevamente


select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';


-- Borrado

delete from sga_datos_censales
where nro_inscripcion = 'FBCB-4191'; -- Nro inscripcion del alumno a borrar


delete from sga_movimientos
where nro_inscripcion = 'FBCB-4191';


delete from sga_alumnos
where carrera = 'AI001';


delete from sga_carrera_aspira
where carrera = 'AI001';


delete from sga_personas
where apellido = 'SCHINNER';


execute procedure sp820_inscribir_carrera_capic("2008","01/01/2008","SCHINNER","SEBASTIAN","0","30300300","1"); 

# Caso 5: Dar de baja a un alumno desde sistema Guarani e intentar inscribir nuevamente.


select * from sga_personas
where apellido = 'SCHINNER';


select * from sga_alumnos
where carrera = 'AI001';


select * from sga_carrera_aspira
where carrera = 'AI001';

execute procedure sp820_inscribir_carrera_capic("2008","01/01/2008","SCHINNER","SEBASTIAN","0","30300300","1");	-- BIEN


