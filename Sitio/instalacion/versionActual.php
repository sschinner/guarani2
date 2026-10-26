<?php

if (!function_exists('utf8_decode')) {
	function utf8_decode($data) {
		return $data;
	}
}

$version_str = 'versión 2.9.5.35.0';
if (function_exists('utf8_decode')) {
	$version_str = utf8_decode($version_str);
}
define('VERSION', $version_str);
/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

