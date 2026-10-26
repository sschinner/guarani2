<?php
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
namespace kernel\interfaz\templates;
/**
 * Loads template from the filesystem. Adds capability to dynamically add a
 * directory
 *
 * @package    twig
 */
class Twig_Loader_Custom extends \Twig_Loader_Filesystem
{
    /**
     * Prepends $path to the list of paths
     * @param string $path the path to add
     */
//    public function addPath($path)
//    {
//        if (!is_dir($path)) {
//            throw new \Twig_Error_Loader(sprintf('The "%s" directory does not exist.', $path));
//        }
//        if (!in_array($path, $this->paths)) {
//            array_unshift($this->paths, $path);
//        }
//    }
    
    public function removePath($path)
    {
        foreach ($this->paths as $key => $p) {
            if ($p == $path) {
                unset($this->paths[$key]);
                return;
            }
        }
    }
    
    public function dump()
    {
        var_dump($this->paths);
    }

}

?>
