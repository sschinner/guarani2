<?php
namespace kernel\util;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

class encoding {

	static function d($str) {
		if(is_array($str)) {
			$dt = array();
			foreach($str as $k=>$v) {
				$dt[self::d_seguro($k)] = self::d($v);
			}
			return $dt;
		} else {
			return self::d_seguro($str);
		}
	}
	
	static function d_seguro($str) {
		if(mb_detect_encoding($str, 'UTF-8', true) == 'UTF-8') {
//			echo "\ndecoded $str\n";
			return utf8_decode($str);
		}
//		echo "\nnot decoded $str ".mb_detect_encoding($str, 'UTF-8', true)."\n";
		return $str;
	}
	
	static function e($str) {
		if(is_array($str)) {
			$dt = array();
			foreach($str as $k=>$v) {
				$dt[self::e_seguro($k)] = self::e($v);
			}
			return $dt;
		} else {
			return self::e_seguro($str);
		}
	}
	
	static function e_seguro($str) {
		if(mb_detect_encoding($str, 'UTF-8', true) == 'UTF-8') {
//			echo "\nnot encoded $str\n";
			return $str;
		}
//		echo "\nencoded $str\n";
		return utf8_encode($str);
	}
}
?>
