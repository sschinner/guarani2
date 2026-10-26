Este procedimiento debe retornar las materias a las cuales el alumno puede inscribirse para rendir. Previamente el alumno debe tener pasada la regularidad parcial proveniente de la UA destino donde curso realmente la materia. 

Los casos de prueba fueron los siguientes:

execute procedure sp820_elegir_materia_exami('FBCB','0302','33931746-2')

execute procedure sp820_elegir_materia_exami('FBCB','0302','34014200-9')

execute procedure sp820_elegir_materia_exami('FBCB','0301','34581693-9')

execute procedure sp820_elegir_materia_exami('FBCB','0303','34563269-8')

Retorna:

Carrera  ||  materia  ||  materia nombre ||  institucion  ||  nombre institucion  ||  acta origen  ||  tipo:   --        '0' : Está inscripto 
                           								     --        '1': Materia disponible  


Para todos los casos devolvió correctamente las materias a las cuales el alumno puede inscribirse.


Esta devolviendo las materias aunque el alumno tenga un resultado reprobado en la materia, es decir: El alumno se puede inscribir como libre habiendo cursado y reprobado en la facultad destino??




