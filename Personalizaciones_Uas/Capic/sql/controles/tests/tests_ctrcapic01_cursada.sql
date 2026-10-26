execute PROCEDURE ctrcapic01_cursada(pUnidadAcademica, pCarrera, Legajo, pMateria);

-- TEST FALSE
-- (Alumno regular por equivalencia parcial Capic = -1)
-- (Alumno regular por equivalencia parcial = -1)
-- (Alumno regular por cursado = -1)
-- (Alumno regular por rectificado de equivalencia parcial = -1)
-- (Alumno regular por rectificado de cursado = -1)

-- TEST TRUE
-- (Alumno no regular = 1)
-- (Alumno no regular por equivalencia parcial Capic = 1)
-- (Alumno no regular por equivalencia parcial = 1)
-- (Alumno no regular por rectificado de equivalencia parcial Capic = 1)
-- (Alumno no regular por rectificado de equivalencia parcial  = 1)
-- (Alumno no regular por rectificado de cursado = 1)
