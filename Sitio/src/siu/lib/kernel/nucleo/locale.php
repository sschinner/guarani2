<?php

namespace kernel\nucleo;

use Symfony\Component\Translation\Translator;
use Symfony\Component\Translation\MessageSelector;
use kernel\kernel;

class locale
{
	protected $dominio;
	protected $loader;
	protected $default_locale;

	/**
	 * Crea un manejador de locales a partir de un dominio de mensajes y un
	 * string que especifíca la default locale
	 * @param string $dominio
	 * @param string $default_locale_string 
	 */
	function __construct($dominio, $default_locale_string)
	{
		$this->dominio = $dominio;
		$this->loader = new \Symfony\Component\Translation\Loader\ArrayLoader();
		$this->default_locale = $default_locale_string;
	}

	/**
	 * Obtiene un traductor al locale pasado por parámetro, si no existe ese
	 * idioma se devuelve uno con el lenguaje default
	 * @param string $target_locale 
	 * @return \Symfony\Component\Translation\Translator 
	 */
	function traductor($target_locale)
	{
		$t = new Translator($this->default_locale, new MessageSelector());
		$t->setFallbackLocale($this->default_locale);

		$t->addLoader('loader', $this->loader);

		$t->setLocale($target_locale);

		if ($this->default_locale != $this->get_lang($target_locale)) {
			$this->cargar_recurso($t, $this->dominio, $this->default_locale);
		}

		$this->cargar_recurso($t, $this->dominio, $this->get_lang($target_locale));
		$this->cargar_recurso($t, $this->dominio, $target_locale);

		return $t;
	}

	protected function cargar_recurso($t, $dominio, $locale)
	{
		$mensajes = kernel::proyecto()->get_mensajes($dominio, $locale);
		if ($mensajes !== false) {
			$t->addResource('loader', $mensajes, $locale);
		}
	}

	protected function get_lang($locale_string)
	{
		if (strlen($locale_string) < 3) {
			return $locale_string;
		}

		return substr($locale_string, 0, -strlen(strrchr($locale_string, '_')));
	}

}

?>
