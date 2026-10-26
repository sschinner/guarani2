<?php

require_once("adodb/adodb.inc.php");
require_once ('Repositorio/RepositorioWS.php');
include_once("general.php");

echo '<head><link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
</head>';
echo '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>';

echo "  <table class='table table-hover table-sm'>
            <thead class='table-dark'>
                <tr>
                <th scope='col'>#</th><th scope='col'>Base de datos</th><th scope='col'>Conexión</th>
                </tr>
            </thead>
            <tbody>";

$ua = Generales::obtenerTodasUA(0);
$total = count($ua);

for ($cant = 0; $cant < $total; $cant++) {
    
    $objCC = Generales::conectar($ua[$cant]);
    if ($objCC == '3') {
        $color = 'table-danger';
        $mensaje = 'DOWN';
    }
    else {
        $color = 'table-default';
        $mensaje = 'OK';
    }

echo "  <tr class='$color'>
            <th scope='row'>$cant</th>
            <td scope='row'>{$ua[$cant]}</td>
            <td>$mensaje</td>
        </tr>";
}

echo "</tbody></table> ";

?>