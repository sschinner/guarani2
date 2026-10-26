kernel.renderer.registrar_pagelet('herramientas', function(info) {
    var id = '#' + info.id;
	var campos_undo = {
		tipo: '',
		campos: null
	};
	
	function set_undo(tipo, campos) {
		campos_undo.tipo = tipo;
		campos_undo.campos = campos.clone();
		$('#preset_undo').removeAttr('disabled');
	}
	
	function limpiar(campo) {
		kernel.ui.prompt({
                            msg: '¿Desea limpiar el campo "'+ etiqueta(campo) +'"?',
                            msg_ok: 'Aceptar',
                            msg_cancel: 'Cancelar',
                            ok: function() {
                                    $('#renglones .'+campo).val('');
									if(campo==='nota'){
										$('#renglones .col-resultado').text('Ausente');
										$('#renglones .col-resultado').val('U');
										$('#renglones .concepto').text('');
									}										
                                }
                            });		
	}

	function etiqueta(campo){
		if (campo === 'nota'){
			return 'Nota';
		} 
		if (campo === 'fecha'){
			return 'Fecha';
		} 
		if (campo === 'asistencia'){
			return 'Asistencia';
		} 
		if (campo === 'condicion'){
			return 'Condición';
		} 
	}
			
	
    return {
        onload: function() {
			$('#preset_form .fecha').datepicker();
			
			$('#preset_form .preset_valor').focus(function(){
				$('.alert-error').remove();
			});
			
			$('#preset_form').submit(function(e) {
				e.preventDefault();
				
				var campo = $('#preset_campo').val();
				
				var val = $.trim($(this).find('.preset_valor:visible').val());
				if (val == '') {
					return false;
				}
				$(this).find('.preset_valor:visible').val('');
				
				// chequeo si el valor es una nota valida
				if (campo === 'nota' && typeof info.escala[val] === "undefined"){
					return false;
				}
				
				var campos;
				if (campo === 'nota'){
					campos = $('#renglones').find('.' + campo);
				} else {
					campos = $('#renglones').find('.' + campo+'[disabled!="disabled"]');
				}
				
				set_undo(campo, campos);
				
				var solo_vacio = $('#preset_solo_vacio').is(':checked');
				campos.filter(function() {
					return (solo_vacio) ? $(this).val() == '' : true;
				}).val(val).change().keyup();
			});
			
			$('#preset_campo').change(function() {
				$('.alert-error').remove();
				$('#preset_form').find('.preset_valor').val('');
				if ($(this).val() == 'fecha') {
					$('#preset_form').find('.otros').hide();
					$('#preset_form').find('.fecha').show();
				} else {
					$('#preset_form').find('.otros').show();
					$('#preset_form').find('.fecha').hide();
				}
			});
			
			$('#preset_undo').click(function() {
				$('.alert-error').remove();
				$('#renglones').find('.' + campos_undo.tipo).each(function(i) {
					$(this).val($(campos_undo.campos[i]).val()).keyup().change();
				});
				$('#renglones').attr('disabled', 'disabled');
			});
			
			$('#preset_form .preset_valor').change(function(){
				var campo = $('#preset_campo').val();
				var val = $('#preset_form .preset_valor').val();
					
				var msg_arriba;
				if (campo === 'nota' && typeof info.escala[val] === "undefined"){
					$(this).find('.preset_valor:visible').val('');
					
					msg_arriba = $('<div role="alert" class="alert alert alert-error" style="width: auto; float:left; margin:0;">'+info.nota_invalida+'<button type="button" class="close" data-dismiss="alert">×</button></div>');
					$(id).append(msg_arriba);
					msg_arriba.position({
						my: 'top',
						at: 'top center',
						offset: '0 0',
						of: $(id)
					}).show();
					
				}
				
				if (campo === 'corregido_por'){
					if (val.length > info.max_textarea){
						$('#preset_form .preset_valor').val('');
						info.texto_invalido = info.texto_invalido.replace('%max_textarea%', info.max_textarea);
						msg_arriba = $('<div role="alert" class="alert alert alert-error" style="width: auto; float:left; margin:0;">'+info.texto_invalido+'<button type="button" class="close" data-dismiss="alert">×</button></div>');
						$(id).append(msg_arriba);
						msg_arriba.position({
							my: 'top',
							at: 'top center',
							offset: '0 0',
							of: $(id)
						}).show();
					}
				}
			});
			
			$('#notas_examen_query').autocomplete({
				source: info.url_autocomplete,
				minLength: 1,
				select: function( event, ui ) {
//					kernel.ajax.load(ui.item.id, '#renglones', {
//						historia: true,
//						type: 'GET',
//						success: function() {
//						}
//					});
					guarani.cambiar_op({
						href: ui.item.id
					});
				}
			});
			
			$('#btn_limpiar').click(function() {
			var campo = $('#preset_campo').val();
			limpiar(campo);
			});		        
		}
    }
})
