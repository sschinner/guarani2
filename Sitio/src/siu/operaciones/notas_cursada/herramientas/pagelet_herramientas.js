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
	
    function create_date(date_string) {
		var fecha_split = date_string.split('/');
        var parse = Date.parse(fecha_split[1]+'/'+fecha_split[0]+'/'+fecha_split[2]);
        if (isNaN(parse)){
            return false;
        }
        
        var fecha;
		fecha = new Date(fecha_split[2], fecha_split[1], fecha_split[0]);        
		return fecha;
	}

    function msj_error_mostrar(texto){
        $('#msj-autoerror').text(texto);
        $('#msj-autoerror').show();
    }
    
    function msj_error_ocultar(){
        $('#msj-autoerror').hide();
    }
	
	function limpiar(campo) {
		kernel.ui.prompt({
                            msg: '¿Desea limpiar el campo "'+ etiqueta(campo) +'"?',
                            msg_ok: 'Aceptar',
                            msg_cancel: 'Cancelar',
                            ok: function() {
                                    $('#renglones .'+campo).not(':disabled').val('');
									if(campo==='condicion'){
										$('#renglones .resultado').not(':disabled').text('');
									}									
//									if(campo==='nota'){
//										$('#renglones .resultado').text('');
//									}									
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
			$('#preset_form #autofecha').datepicker();
			
			$('#preset_form .preset_valor').focus(function(){
				msj_error_ocultar();
			});
			
			$('#preset_form').submit(function(e) {
				e.preventDefault();
				
				var campo = $('#preset_campo').val();
				
				var val = $.trim($(this).find('.preset_valor:visible').val());
				if (val === '') {
					return false;
				}
				$(this).find('.preset_valor:visible').val('');
				
				// chequeo si el valor es una nota valida
				if (campo === 'nota' && typeof info.escala[val] === "undefined"){
					return false;
				}
				
				// chequeo si el valor es una asistencia valida				
				if (campo === 'asistencia' && !asistencia_valida(val)){
					return false;
				}
                
				// chequeo si el valor es una fecha valida
				if (campo === 'fecha' && !fecha_valida(val)){
					return false;
				}
				
                
				var campos;
				campos = $('#renglones').find('.' + campo+'[disabled!="disabled"]');
				
				set_undo(campo, campos);
				
				var solo_vacio = $('#preset_solo_vacio').is(':checked');
				campos.filter(function() {
					return (solo_vacio) ? $(this).val() === '' : true;
				}).val(val).change().keyup();
			});
			
			function asistencia_valida(val){
				return ($.isNumeric(val) && val == parseInt(val, 10) && val > 0);
			}
            
			function fecha_valida(val){
				fecha_inicio = create_date(info.fecha_inicio);
                fecha_fin = create_date(info.fecha_fin);
                actual =  create_date(val);
                if (actual != false && actual >= fecha_inicio && actual <= fecha_fin){
                    return true;
                }
                return false;
			}
            
			$('#preset_campo').change(function() {
                msj_error_ocultar();
				$('#preset_form').find('.preset_valor').val('');
                $('#preset_form').find('.preset_valor').hide();
                $('#preset_form').find('.preset_label').hide();
                
                if ($(this).val() === 'fecha') {
					$('#preset_form').find('#autofecha').show();
					$('#preset_form').find('#lfecha').show();
				} else if ($(this).val() === 'nota') {
                        $('#preset_form').find('#autonota').show();
                        $('#preset_form').find('#lnota').show();
                } else if ($(this).val() === 'asistencia') {
                        $('#preset_form').find('#autonota').show();
                        $('#preset_form').find('#lasistencia').show();
                } else if ($(this).val() === 'condicion') {
                        $('#preset_form').find('#autocondicion').show();
                        $('#preset_form').find('#lcondicion').show();
                }
			});
			
			$('#preset_undo').click(function() {
                msj_error_ocultar();
				$('#renglones').find('.' + campos_undo.tipo).each(function(i) {
					$(this).val($(campos_undo.campos[i]).val()).keyup().change();
				});
				$('#renglones').attr('disabled', 'disabled');
			});
			
			$('#preset_form .preset_valor').on('change',function(){
				var campo = $('#preset_campo').val();
				var val = $(this).val();
                
                var msg_arriba;
				if (campo === 'nota' && typeof info.escala[val] === "undefined"){
					$(this).val('');
                    msj_error_mostrar(info.nota_invalida);
                    
//                    msg_arriba = $('<div role="alert" class="alert alert alert-error" style="width: auto; float:left; margin:0;">'+info.nota_invalida+'<button type="button" class="close" data-dismiss="alert">x</button></div>');
//					$(id).append(msg_arriba);
//					msg_arriba.position({
//						my: 'top',
//						at: 'top center',
//						offset: '0 0',
//						of: $(id)
//					}).show();
				}
				
				if (campo === 'asistencia' && !asistencia_valida(val)){
					$(this).val('');
                    
                    msj_error_mostrar(info.asistencia_invalida);
//                    msg_arriba = $('<div role="alert" class="alert alert alert-error" style="width: auto; float:left; margin:0;">'+info.asistencia_invalida+'<button type="button" class="close" data-dismiss="alert">x</button></div>');
//					$(id).append(msg_arriba);
//                    msg_arriba.position({
//						my: 'top',
//						at: 'top center',
//						offset: '0 0',
//						of: $(id)
//					}).show();
				}
                
				if (campo === 'fecha' && !fecha_valida(val)){
					$(this).val('');
                    
                    msj_error_mostrar(info.fecha_invalida);
//                    msg_arriba = $('<div role="alert" class="alert alert alert-error" style="width: auto; float:left; margin:0;">'+info.fecha_invalida+'<button type="button" class="close" data-dismiss="alert">x</button></div>');
//					$(id).append(msg_arriba);
//                    msg_arriba.position({
//						my: 'top',
//						at: 'top center',
//						offset: '0 0',
//						of: $(id)
//					}).show();
				}
			});
			
			$('#btn_limpiar').click(function() {
			var campo = $('#preset_campo').val();
			limpiar(campo);
			});			
		}
	}
})
