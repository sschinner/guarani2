(function ($) {
	var devaults = {
		before_remove: function (fila_a_borrar) {
		},
		after_remove: function () {
		},
		success: function () {
		},
		error: function () {
		}
	};
	var $form_element;

	function ini_toggle() {
		$form_element.find('.collapse').on('hidden',function () {
			$(this).prev().find('i').removeClass('icon-chevron-up').addClass('icon-chevron-down');
		}).
			on('shown', function () {
				$(this).prev().find('i').addClass('icon-chevron-up').removeClass('icon-chevron-down');
			});
	}

	function ini_botonera() {
		$form_element.find('.botonera').each(function () {
			$(this).botonera({})
		});

	}

	function ini_ml() {
		$form_element.find('.form-ml').each(function () {
			$(this).form_ml({
//				after_remove: function(){
//					controlar_tabla_vacia();
//				}
			});
		});
	}

	function ini_autocompletar() {
		$form_element.find('.js-autocomplete').each(function (index) {
			$(this).plugin_autocompletar('auto_init', {
				//select: filtro_actividades
			});
		});
	}

	function ini_fechas() {
		$.datepicker.setDefaults($.datepicker.regional["es"]);
		$form_element.find('input.date').datepicker({
			changeMonth: true,
			changeYear: true,
			firstDay: 0,
			yearRange: "-70:+0",
			maxDate: "+0"
		});
	}


	var methods = {
		init: function (options) {
//			if ( options ) {
//				var aux = {};
//				$.extend(true, aux, devaults, options);
//				devaults = aux;
//			}
			$form_element = this;
			ini_toggle();
			ini_fechas();
			ini_botonera();
			ini_ml();
			ini_autocompletar();
			return $form_element;
		},
		elemento: function (identificador, grupo) {
			$form_element = this;
			var id = '#'

			var form_id = $form_element.prop('id');
			if (form_id) {
				id += form_id + '-';
			}

			if (grupo) {
				id += grupo + '-';
			}

			id += identificador;
			//console.log("buscando a " + id );
			return $form_element.find(id);
		},

		postear_y_reemplazar: function (pagelet, on_succes) {
			$form_element = this;
			var data = $form_element.serializeArray();

			kernel.ajax.call($form_element.attr('action'), {
				type: 'post',
				data: data,
				//historia: false,
				success: function (response) {
					$(pagelet).html(response.cont);
					on_succes();
					//console.log(response.cont);
					//kernel.renderer.pagelet('comisiones').onload();
					//kernel.ui.show_mensaje(info.mensajes.mensaje_exito);
				}
			})
		},
		submit_blank_get: function (url) { //para mandar por url (pdf, xls). Si es una op, usar serialize();
			$form_element = this;
			$form_element.prop('target', '_blank');
			$form_element.prop('method', 'get');
			$form_element.prop('action', url);
			$form_element.submit();
		},
		postear_a_url: function (url, on_succes) {
			$form_element = this;
			var data = $form_element.serializeArray();

			kernel.ajax.call(url, {
				type: 'post',
				data: data,
				//historia: false,
				success: function (response) {
					//location.hash = url;
					on_succes(response.cont);
					//console.log(response.cont);
					//kernel.renderer.pagelet('comisiones').onload();
					//kernel.ui.show_mensaje(info.mensajes.mensaje_exito);
				}
			})
		}
	}

	$.fn.formulario = function (method) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return  methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' doesnt exist on plugin.form.ml');
		}
	}
})(jQuery);


