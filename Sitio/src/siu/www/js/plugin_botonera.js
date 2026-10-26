/**
 */

(function ( $ ) {
	var defaults = {

		on_change: function(checkbox, $grupo) {

		}
	};

	
	var methods = {
		init: function ( options ) {
			if ( options )
				options = {};

			var aux = {};
			$.extend(true, aux, defaults, options);
			this.data('settings', aux);

			var grupo = this;

			this.find("label").each(function(){
				var $this = $(this);
				$this.addClass('btn btn-mini');
			});

			grupo.find("input").on('change', function () {
				var settings = $(this).parents('.botonera').data('settings');
				var check = this;
				if(check.checked){
					$(check).parent().addClass('active');
				}else {
					$(check).parent().removeClass('active');
				}

				settings.on_change(check, grupo);

			}).change();

			this.find("input").hide();
			return this;
		},
		valores: function () {
			var allVals = [];
			this.find('input:checked').each(function()
			{
				allVals.push($(this).val());
			});
			return allVals;
		},
		change_settings: function(new_settings) {
			var settings = this.data('settings');
			$.extend(settings, new_settings);
			this.data('settings', settings);
		}
	}
	
	$.fn.botonera = function ( method ) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return  methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' doesnt exist on jQuery.upload');
		}
	}
}) (jQuery);