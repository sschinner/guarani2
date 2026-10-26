<?php


function sanearString($string) {

    $string = trim($string);

    $string = str_replace(
            array('�', '�', '�', '�', '�', '�', '�', '�', '�'), array('a', 'a', 'a', 'a', 'a', 'A', 'A', 'A', 'A'), $string
    );

    $string = str_replace(
            array('�', '�', '�', '�', '�', '�', '�', '�'), array('e', 'e', 'e', 'e', 'E', 'E', 'E', 'E'), $string
    );

    $string = str_replace(
            array('�', '�', '�', '�', '�', '�', '�', '�'), array('i', 'i', 'i', 'i', 'I', 'I', 'I', 'I'), $string
    );

    $string = str_replace(
            array('�', '�', '�', '�', '�', '�', '�', '�'), array('o', 'o', 'o', 'o', 'O', 'O', 'O', 'O'), $string
    );

    $string = str_replace(
            array('�', '�', '�', '�', '�', '�', '�', '�'), array('u', 'u', 'u', 'u', 'U', 'U', 'U', 'U'), $string
    );

    $string = str_replace(
            array('�', '�'), array('c', 'C',), $string
    ); //'�', '�','n', 'N', 
    return $string;
}

//Verifica si ya esta migrada la base y en consecuencia se convirte el tipoTitulo 
function convertirTT($ua, $tipotitulo) {

    if (($tipotitulo == '2' && $ua == 'FADU') || ($tipotitulo == '1' && $ua == 'EUAA') || ($tipotitulo == '1' && $ua == 'FIQ')) {
        if (!self::existeBase($ua, $tipotitulo)) {
            $titulo = self::conversionUATT($ua, $tipotitulo);
            return $titulo;
        } else {
            return $tipotitulo;
        }
    } else {
        return $tipotitulo;
    }
}

// Se procede a realizar el cambio de tipoTitulo
function conversionUATT($ua, $tipotitulo) {

    $arrayUAPS = array('CU-RA', 'FADU', 'EUAA', 'FIQ');
    if (in_array(strtoupper($ua), $arrayUAPS)) {
        $titulo = 7;
        return $titulo;
    } else {
        return $tipotitulo;
    }
}

//Determina si esta en informix o postgres
function existeBase($ua, $tipotitulo) {

    $sTipoCon = "pdo";
    $objCC = & NewADOConnection($sTipoCon);
    $db = self::recuperarDB($ua, $tipotitulo);
    $conexion = ('informix:host=' . HOST . '; service=' . PUERTO . ';database=' . $db . '; server=' . SERVER . '; protocol=olsoctcp; EnableScrollableCursors=1;');
    $usuario = USUARIOCONEXION;
    $password = PASSWORDCONEXION;
    if (!$objCC->Connect($conexion, $usuario, $password)) {
        return false;
    } else {
        return true;
    }
}

?>