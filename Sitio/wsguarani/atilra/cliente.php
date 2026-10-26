<?php
require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');


//$wsdl="http://guarani3w.intranet/wsguarani/atilra?wsdl"; //el nombre del archivo servidor
$wsdl=WSDLG."atilra?wsdl";

$client=new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsatilra","WSat1lR4","basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}

$unidadAcademica = 'FBCB';
$tipotitulo = '3';
$param = array('ua' => $unidadAcademica, 'tipotitulo' => $tipotitulo,'anio_acad'=>'2014', 'carrera'=>'EUG', 'fecha_insc'=>'01/04/2014','apellido'=>'Schinner',
		'nombres'=>'Sebastian Luis', 'tipo_doc'=>'0', 'nro_doc'=>'30171912','sexo'=>'1', 'usuario_ag' => '30171seba');
$resultado = $client->call('insertaAlumno', $param);
/*
$param = array('ua' => $unidadAcademica, 'tipotitulo' => $tipotitulo,'tipo_doc'=>'0', 'nro_doc'=>'30171912', 'usuario_ag' => 'seba30171');
$resultado = $client->call('cambiarUsuarioAutogestion', $param);
*/
//$param = array('usuario'=>'29349542','unidadAcademica'=>'04' , 'claveVieja'=>'11111','claveNueva'=>'29349');
//$resultado = $client->call('cambiarClaveAutogestion', $param);

// Completar los datos correspondientes para prueba

/*
$unidadAcademica = 'FICH';
$tipotitulo = '1';
$usuario = '29349542';
$claveNueva = md5('Leandro1');

/*$usuarios=array('1266828','1295868','1276358','1254158','1277518','1270508','1260068','1278058','1271498',
                '1260058','1288148','1265268','1259368','1268648','1272588','1269648','1276668','1265318',
                '1271398','1263938','1296318','1254458','1263118','1276298','1286148','1287278','1279558',
                '1270548','1295158','1267218','1287708','1195198','1260008','1276758','1265078','1284378',
                '1266288','1287838','1268258','1289808','1278558','1262118','1259428','DNI35752767','1265008',
                '1275218','DNI22218596','1263858','DNI36052143','1258648','1265638','1284898','1265588','1128178',
                '1190618','1280008','1268578','1269958','1257158','1288898','1200658','1267618','1275718',
                'DNI32520272','1293068','1267038','1268128','1273188','1266908','1274308','1274228','1286598',
                '1270018','1266338','1263318','1257338','1277238','1258988','1264878','1263418','1263448','1266568',
                '1292298','1279348','DNI38449071','1267808','1264748','30232193','1275658','1285218','1272058','1194988',
                '1193508','1266658','1264968','1264488','1274048','1266748','1268288','1279538','31851735','1283408',
                '1270158','1264808','1281228','1261408','1273178','1270748','23832294','1268428','DNI18443217',
                '1281818','1264038','1295148','1258368','1279768','1257768','1268188','1284698','1260408','1277578',
                '1287628','1277548','1272708','16925217','1259858','1208298','1269568','1265388','1275168','1282388',
                '1269148','1266058','1275738','1274058','1264288','1267428','1288098','1286818','1290848','1266138',
                '1271218','1274078','1267078','1261458','1264368','1266848','1284668','1266318','1267148','1276948',
                '1268138','DNI17882529','1201548','1273538','1269088','1284218','1293078','1273078','1286948','1263588',
                '1267208','1271408','1260328','1282918','1257498','1282718','1268368','1267368','1289958','1275108',
                '1261948','1268198','1298188','1266118','1273448','DNI25622373','1282868','1277868','1269698',
                '1264178','1264058','1288388','1292318','1191958','DNI37806720','1195408','1282978','1285038',
                '1292878','1278898','1287878','1283488','1260628','1268708','1290018','1284918','1286558','1199698',
                '1274258','1068768','1271768','1129688','1278968','1262298','1266198','1270638','1287288','1300568',
                '1274108','29524538','1286738','1263778','1299918','1280438','1263578','1288238','1274318','1272208',
                '1283678','1271618','1280478','33128503','1267738','1264278','1267498','1266988','1260388','DNI17328276',
                '1264958','1299568','1271328','1294428','1272538','DNI32330349','1264188','1261688','DNI33215367',
                '1263718','1263388','1260118','1208138','1288588','1296188','1266518','1312168');*/

//$param = array('ua' => $unidadAcademica, 'tipotitulo' => $tipotitulo, 'usuario' => $usuario, 'claveNueva' => $claveNueva);

//$param = array('ua' => 'FBCB', 'tipotitulo' => '3', 'carrera' => 'EUG', 'tipo_doc' => '0', 'nro_doc' => '37300816', 'pais_documento' => '54', 'anio_academico' => '2015', 'fecha_reinscrip ' => '2015-03-09 12:59', 'nro_transaccion' => 'SIGUV');
//$resultado = $client->call('altaReinscripcion', $param, URI."atilra/index.php?wsdl", URI."atilra/index.php?wsdl/altaReinscripcion");

//$resultado = $client->call('cambiarClaveAutogestion', $param, URI."atilra/index.php?wsdl", URI."atilra/index.php?wsdl/cambiarClaveAutogestion");
/*$resp=array();
$claveNueva = md5('jepfwcgj');

for ($i=0; $i<  count($usuarios); $i++){
  $param = array('ua' => 'FBCB', 'tipotitulo' => '3', 'usuario' => $usuarios[$i], 'claveNueva' => $claveNueva);
  $resultado = $client->call('cambiarClaveAutogestion', $param, URI."atilra/index.php?wsdl", URI."atilra/index.php?wsdl/cambiarClaveAutogestion");
  $resp[]=json_decode($resultado);
}*/
$resp = json_decode($resultado);
print_r($resp);
die;

?>
