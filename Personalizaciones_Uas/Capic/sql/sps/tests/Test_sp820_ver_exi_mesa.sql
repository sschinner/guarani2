Para realizar los test al procedimiento(sp820_ver_exi_mesa()), primero se debió versionar el plan AE, agregando al mismo el ciclo de integración CI001 y dentro de este se agrego la materia genéria GMI01. Luego se debió cambiar a los alumnos(AE) la versión del plan para que les aparezca la regularidad en la ficha de cada uno.

Los legajos a los cuales se les cambio la versión del plan son los siguientes:

33931746-2
34147602-8
32276666-4
34679326-6

Por último se crearon los turnos y mesas de examenes para que dichos alumnos tengan la opción de inscribirse.

Test:

execute procedure sp820_ver_exi_mesa ('FHUC', 0, 32276666, 'BIO31');

execute procedure sp820_ver_exi_mesa ('FHUC', 0, 34679326, 'BIO06');

El procedimiento funciona correctamente, en caso de que existan mesas el alumno puede inscribirse, caso contrario no muestra nada. 