(function ( $ ) {
	var defaults = {
		url: '',
		select: false,
		valor_default: false,
		min_length: 0,
		change: false
	};

	var methods = {
		callback_select: function(fn) {
			var settings = $(this).before().data('settings');
			settings.select = fn;
			$(this).before().data('settings', settings);
		},
		init: function(options) {
			if (options) {
				var aux = {};
				$.extend(true, aux, defaults, options);
				this.data('settings', aux);
			}
			if (aux.url == '') return;
			var input = $(this);
            var pagelet_id = "#"+input.parents('.pagelet').attr('id');
			var id = input.attr('id');
			var name = input.attr('name');

			input.removeAttr('name');
			input.after('<input id="' + id + '-autocomplete" name="' + name + '" type="hidden">').autocomplete({
				source: aux.url,
                appendTo: pagelet_id,
				minLength: aux.min_length,
				change: function(event, ui) {
					var aux = $(this).before().data('settings');
					if (ui.item == null)
					{
						if (aux.valor_default)
						{
							$('#'+id+'-autocomplete').val(aux.valor_default.id);
							input.val(aux.valor_default.value);
							if (aux.select)
								aux.select(aux.valor_default.id, aux.valor_default.value, aux.valor_default);
						}
						else
							$('#'+id+'-autocomplete').val('');
					}
					if (aux.change)
						aux.change(ui.item);
				},
				select: function(event, ui) {
					var aux = $(this).before().data('settings');
					$('#'+id+'-autocomplete').val(ui.item.id);
					if (aux.select)
						aux.select(ui.item.id, ui.item.value, ui.item);
					$(this).css('background-color', '#eeeeee');
					return true;
				}
			});
			$('#'+id).on('focus', function() {
				$(this).css('background-color', '#FFFFFF');
				$(this).val('');
				$('#'+id+'-autocomplete').val('');
			});
			if (aux.valor_default)
			{
				$('#'+id+'-autocomplete').val(aux.valor_default.id);
				input.val(aux.valor_default.value);
				$(this).css('background-color', '#eeeeee');
			}
		},
		change_settings: function(new_settings) {
			var settings = this.data('settings');
			$.extend(settings, new_settings);
			this.data('settings', settings);
		},
//		get_settings: function() {
//            console.log(this.text());
//			return this.data('settings');
//		},
		auto_init: function(options) {
			var aux =  {
				url: this.data('url'),
				valor_default: {
					id: this.val(),
					value: this.data('texto')
				},
				min_length: 1
			};
			if (options) {
				$.extend(true, aux, options);
			}
			this.plugin_autocompletar(aux);//invoco init con inicializacion

		}
	}

	$.fn.plugin_autocompletar = function(method) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return  methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' doesnt exist on jQuery.upload');
		}
	}
}) (jQuery);