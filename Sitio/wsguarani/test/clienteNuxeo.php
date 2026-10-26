<?php

include_once '../../clientes_ws/nuxeo/clientews.php';

// $path = '/default-domain/workspaces/Cargos/Cargo_nota_FIQ-0868593-17';
// $path = '/default-domain/sections/Tramites-CA/CA_FICH-0881508-17';
$path = '/default-domain/sections/Tramites-CA/CA_FCJS-0898242-17';
$nuxeo = new ClienteNuxeo();
$nuxeo->obtenerArchivo($path);