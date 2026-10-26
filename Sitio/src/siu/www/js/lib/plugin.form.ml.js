/**
 * Requiere que los renglones tengan id #renglon_[renglon_nro]
 * los campos de fecha deben ser input[type=date]
 * el formulario debe tener clase form-renglones
 * cuando hay un error en un renglón se agrega la clase error
 */

(function ( $ ) {
	var defaults = {
		before_remove: function(fila_a_borrar) {
		},
		after_remove: function() {
		},
		success: function() {
		},
		error: function() {
		}
	};
	var ml_element;
	var class_template_row = 'form-template-row';
	var input_elements = 'input,select';
	var class_ef_fijo = 'ef-fijo';
	var class_form_error = 'form-ml-data-error';
	var class_remove_row = 'form-ml-remove-row';
	var class_row = 'form-ml-row';
	var class_mje_vacio = 'js-ml-mje-vacio';
	var class_ml = 'form-ml'
	var next_id;
	
	function get_row_count(selector)
	{
		return $(selector).find('tbody tr:not(.'+ class_template_row +')').length;
	}
	function create_row_from_template()
	{
		var copy = ml_element.find('.'+ class_template_row).clone();
		copy.removeClass('hide');
		copy.removeClass(class_template_row);
		copy.addClass(class_row);
		var row_number = get_inc_next_id();
		$.each(copy.find(input_elements), function() {
			var id = $(this).prop('id');
			var name = $(this).prop('name');
			$(this).prop('id', id.replace(/__NUM_FILA_ML__/g, row_number));
			$(this).prop('name', name.replace(/__NUM_FILA_ML__/g, row_number));
		});

		return copy;
	}

	function load_error_tooltips()
	{
		var elements_with_errors = ml_element.find('.' + class_form_error);
		$.each(elements_with_errors, function() {
			var e = $(this);
			e.tooltip({container: 'body'});
			e.change(function() {
				e.tooltip('hide');
				e.tooltip('disable');
				e.removeClass(class_form_error);
			});
		});
	}


	function check_emtpy_table(){
		var elem = ml_element.next('.' + class_mje_vacio);
		if (elem.length <= 0){
			return;
		}
		if (ml_element.find('tr.form-ml-row').length > 0){
			elem.fadeOut('fast', function(){
				ml_element.fadeIn('slow'); //removeClass('hide');
			}); //addClass('hide');

		} else {
			ml_element.fadeOut('fast', function(){
				elem.fadeIn('slow'); //removeClass('hide');
			}); //addClass('hide');
		}
	}

	function load_remove_row_event()
	{
		ml_element.on('click', '.'+class_remove_row, function() {
			var settings = $(this).parents('.'+ class_ml).data('settings');
			if (settings.before_remove($(this).parent('.'+class_row))){
				$(this).parent('.'+class_row).remove();
			}
			check_emtpy_table();
			settings.after_remove();
			return false;
		});
	}
	
	function evento_chebox_todo_nada()
	{
		// evento checkbox todo o nada
		ml_element.on('click', 'input[type="checkbox"].todo_nada', function (){
			if ($(this).prop('checked')){
				$(this).parents('table').find('.'+$(this).prop('id')).find('input[type="checkbox"]').not(":disabled").prop('checked', true);
			} else {
				$(this).parents('table').find('.'+$(this).prop('id')).find('input[type="checkbox"]').not(":disabled").prop('checked', false);
			}
		});
	}
	
	function init_autoincrement()
	{
		next_id = get_row_count(ml_element) + 1;
	}
	
	function get_inc_next_id()
	{
		var res = next_id;
		next_id++;
		return res;
	}
	
	var methods = {
		init: function ( options ) {
			if (!options){
				options = {};
			}
//			if ( options ) {
				var aux = {};
				$.extend(true, aux, defaults, options);
				this.data('settings', aux);
//			}
			ml_element = this;
			load_error_tooltips();
			load_remove_row_event();
			check_emtpy_table();
			evento_chebox_todo_nada();
			init_autoincrement();
		},
		add_row: function (datos) {
			ml_element = this;
			var row = create_row_from_template();
			$.each(datos, function(key, val) {
				var elem = row.find(input_elements).filter(function() {
					var patt = new RegExp(".*\\["+key+"\\]");
					return patt.test($(this).prop('name'));
				});
				$.each(elem, function() {
					if ($(this).prop('type') !== 'checkbox') {	
						$(this).val(val);
					} else {
						$(this).attr('checked', val === 'S');	
					}
				});
				// ef fijos
				var ef_fijo = row.find('.'+ class_ef_fijo +'[data-nombre="'+ key +'"]');
				if (ef_fijo.length > 0) {
					ef_fijo.html(val);
				}
			});
			ml_element.find('tbody').append(row);
			check_emtpy_table();
		},
		remove_row: function (id_row) {
			ml_element = this;
		},
		change_settings: function(new_settings) {
			var settings = this.data('settings');
			$.extend(settings, new_settings);
			this.data('settings', settings);
		}
//		get_settings: function() {
//            console.log(this.text());
//			return this.data('settings');
//		},
	}
	$.fn.form_ml = function ( method ) {
		if (methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if (typeof method === 'object' || !method) {
			return  methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' doesnt exist on plugin.form.ml');
		}
	}
}) (jQuery);


