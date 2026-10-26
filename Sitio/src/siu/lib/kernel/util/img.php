<?php
namespace kernel\util;
use kernel\kernel;
class img
{
	static function get_resource_blob($img_string, $ext)
	{
		$dir  = kernel::proyecto()->get_dir_temp();
		$path = "$dir/tmp.$ext";
		file_put_contents($path, $img_string);
		$img_src = img::cargar($path);
		list($width, $height) = getimagesize($path);
		unlink($path);
		return array(
			'img' => $img_src,
			'width' => $width,
			'height' => $height
		);
	}
	
//	static function resize_from_blob($img_string, $size)
//	{
//		$path = '/tmp/fotoblob.jpg';
//		file_put_contents($path, $img_string);
//		$img_src = img::cargar($path);
//		if ($img_src === false) {
//			throw new \Exception('errrrooo');
//		}
//		list($width, $height) = getimagesize($path);
//		echo "w $width, h $height\n";
////		$img_src = \imagecreatefromstring($img_string);
////		$width  = imagesx($img_src);
////		$height = imagesy($img_src);
//		
//		return self::resize_resource($img_src, $width, $height, $size);
//	}
	
	static function resize($path, $size) 
	{
		list($width, $height) = getimagesize($path);
		$img_src = self::cargar($path);
		return self::resize_resource($img_src, $width, $height, $size);
	}
	
	static function resize_resource($img_src, $width, $height, $new_size)
	{
		$r = $width / $height;
		$src_x = 0; $src_y = 0;
		
		if ($width > $height) {
			$src_x = ($width - $height) / 2;
			$width = $height;
		} else {
			$src_y = ($height - $width) / 2;
			$height = $width;
		}
		$new_width  = $new_size;
		$new_height = $new_size;
		
		$dst = imagecreatetruecolor($new_width, $new_height);
		imagecopyresampled($dst, $img_src, 0, 0, $src_x, $src_y, $new_width, $new_height, $width, $height);
		
		return $dst;
	}
	
	protected static function cargar($path)
	{
		$extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
		switch ($extension) {
			case 'jpg':
			case 'jpeg':
				$img = imagecreatefromjpeg($path);
				break;
			case 'gif':
				$img = imagecreatefromgif($path);
				break;
			case 'png':
				$img = imagecreatefrompng($path);
				break;
			default:
				throw new \kernel\error_kernel("El formato de imagen '$extension' no es soportado. Path: '$path'");
				break;
		}
		
		return $img;
	}
	
	static function guardar($resource, $path)
	{
		$extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));
		switch ($extension) {
			case 'jpg':
			case 'jpeg':
				$rs = imagejpeg($resource, $path, 100);
				break;
			case 'gif':
				$rs = imagegif($resource, $path);
				break;
			case 'png':
				$rs = imagepng($resource, $path);
				break;
			default:
				throw new \kernel\error_kernel("No se puede guardar una imagen con el formato '$extension'");
				break;
		}
	}
}

//$img = \kernel\util\img::resize('img.jpg', 35);
//imagejpeg($img, 'resized.jpg', 100);
?>
