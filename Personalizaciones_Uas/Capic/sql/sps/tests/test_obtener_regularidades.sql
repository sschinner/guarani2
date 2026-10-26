Casos de prueba:

* comision creada, alumnos insriptos, regularidades pasadas	--->	salida = 0

execute procedure sp820_obtener_regularidades('2007','2do. Cuatrimestre','FBCB')
execute procedure sp820_obtener_regularidades('2001','2do. Cuatrimestre','FBCB')


* comision creada, alumnos inscriptos, pero sin regularidad pasada.	---> salida = -3
execute procedure sp820_obtener_regularidades('2007','2do. Cuatrimestre','FIQ')



* comsion creada, pero sin alumnos inscriptos.	--->	salida = -2 	o mensaje de error -746 y leyenda
execute procedure sp820_obtener_regularidades('2007','2do. Cuatrimestre','FCA');

select * from u820_capic_comision



* no existe comision para la unidad academica seleccionada	--->	salida = -1	o mensaje de error -746 y leyenda
* Revisar la tabla u820_capic_com y colocar en la ejecucion una unidad academica que no figure en dicha tabla
execute procedure sp820_obtener_regularidades('2007','2do. Cuatrimestre','ESS')
