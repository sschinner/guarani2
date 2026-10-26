-- Precondiciones: la carrera de integración esta asociada al grupo de carreras 'i0001' (grupo de carreras de integración)
--	El grupo de carreras de integración solo tiene asociado la carrera de integración

-- Parámetros: materia

-- Fixture:

-- Tests:
La materia de integracion existe como materia de la carrera de integración
-- execute procedure sp820_existeMat('LN017');
La materia de integracion no existe como materia de la carrera de integración
-- execute procedure sp820_existeMat('LN016');