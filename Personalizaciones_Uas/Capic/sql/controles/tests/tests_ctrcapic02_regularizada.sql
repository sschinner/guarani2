execute PROCEDURE .ctrcapic02_cursada2(pUnidadAcademica, pCarrera, Legajo, pMateria, pAnioAcademico, pTurnoExamen, pMesaExamen, pLlamado, pTipoInscripcion);

-- TEST FALSE
-- Se inscribe como regular y tiene una Regularidad Vigente de otra UA: no pasa
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', 'LN006', 2009, 'Prueba', 'A', 1, 'R');

-- Se inscribe como libre y tiene una Regularidad Vigente de otra UA: no pasa
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', 'LN006', 2009, 'Prueba', 'A', 1, 'L');


-- TEST TRUE
-- Se inscribe como regular y tiene una Regularidad Vigente de su UA: pasa
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', '', 2009, 'Prueba', 'A', 1, 'R');

-- Se inscribe como regular y NO tiene una Regularidad Vigente: pasa (aunque no sea coherente el tipo de inscripcion con la condicion en la materia - eso se controla en otro lado)
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', '', 2009, 'Prueba', 'A', 1, 'R');


-- Se inscribe como libre y tiene una Regularidad Vigente de su UA: pasa (aunque no sea coherente el tipo de inscripcion con la condicion en la materia - eso se controla en otro lado)
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', '', 2009, 'Prueba', 'A', 1, 'L');

-- Se inscribe como libre y NO tiene una Regularidad Vigente: pasa 
execute PROCEDURE "dba".ctrcapic02_cursada2('FBCB', '0303', '34827797-4', '', 2009, 'Prueba', 'A', 1, 'L');
