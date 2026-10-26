kernel.renderer.registrar_pagelet('configuraciones', function(info) {
	var id = '#' + info.id;
	var weak_pass = false;
	
	$.fn.chkPass = function(ops, callback) {
		if(!callback) {
			callback = ops;
			ops = {};
		}
		var dflt = {
			minPasswordLength: 8,
			baseScore: 50,
			bonus: {
				Excess: 3,
				Upper: 4,
				Numbers: 5,
				Symbols: 5,
				Combo: {
					full: 25,
					medium: 15
				},
				FlatLower: -15,
				FlatNumber: 35
			},
			strength: {
				weak: {t: 50},
				average: {f: 50, t: 75},
				strong: {f: 75, t: 100},
				secure: {f: 100}
			}
		};

		this.data('ckhPass.ops', $.extend({}, dflt, ops));
		return this.keyup(function(){
			var num = {
				Excess: 0,
				Upper: 0,
				Numbers: 0,
				Symbols: 0,
				Combo: 0,
				FlatLower: 0,
				FlatNumber: 0,
				baseScore: 0,
				score: 0
			};
			num.charPassword = this.value.split("");
			var ops = $(this).data('ckhPass.ops');
			if (num.charPassword.length >= ops.minPasswordLength)
			{
				num.baseScore = ops.baseScore;	
				for (i=0; i<num.charPassword.length;i++)
				{
					if (num.charPassword[i].match(/[A-Z]/g)) {num.Upper++;}
					if (num.charPassword[i].match(/[0-9]/g)) {num.Numbers++;}
					if (num.charPassword[i].match(/(.*[!,@,#,$,%,^,&,*,?,_,~])/)) {num.Symbols++;} 
				}

				num.Excess = num.charPassword.length - ops.minPasswordLength;

				if (num.Upper && num.Numbers && num.Symbols)
				{
					num.Combo = ops.bonus.Combo.full; 
				} else if ((num.Upper && num.Numbers) || (num.Upper && num.Symbols) || (num.Numbers && num.Symbols))
				{
					num.Combo = ops.bonus.Combo.medium; 
				}

				if (this.value.match(/^[\sa-z]+$/))
				{ 
					num.FlatLower = ops.bonus.FlatLower;
				}

				if (this.value.match(/^[\s0-9]+$/))
				{ 
					num.FlatNumber = ops.bonus.FlatNumber;
				}
				num.score = num.baseScore + (num.Excess*ops.bonus.Excess) + (num.Upper*ops.bonus.Upper) + (num.Numbers*ops.bonus.Numbers) + (num.Symbols*ops.bonus.Symbols) + num.Combo + num.FlatLower + num.FlatNumber;		
			}
			for(var i in ops.strength) {
				var s = ops.strength[i];
				if($.type(s.f) == 'undefined' && $.type(s.t) == 'undefined') continue;
				if(($.type(s.f) == 'undefined' || num.score >= s.f) && ($.type(s.t) == 'undefined' || num.score < s.t)){
					num.strength = i;
					break;
				}
			}
			$(this).data('chkPass.num', num);
			callback.apply(this);
		});
	};
	
	$.fn.prevVal = function(val) {
		if($.type(val) == 'undefined') {
			return this.data('prev_value');
		} else if($.type(val) != 'object' || (!val.dflt && !val.cmpr) ) {
			return this.data('prev_value', val);
		} else if(val.dflt) {
			this.each(function(){
				switch ($(this).prop('type'))
				{
					case 'checkbox':
						$(this).data('prev_value', $(this).is(':checked'));
						break;
					case 'radio':
						if ($(this).is(':checked')) {
							$('input[name='+$(this).prop('name')+']').data('prev_value',$(this).val());
						}
						break;
					default:
						$(this).data('prev_value', $(this).val());
				}
			});
			return this;
		} else {
			var equals = true;
			this.each(function(){
				var teq;
				switch ($(this).prop('type'))
				{
					case 'checkbox':
						teq = $(this).data('prev_value') == $(this).is(':checked');
						break;
					case 'radio':
						teq = $('input[name='+$(this).prop('name')+']:checked').val() == $(this).data('prev_value');
						break;
					default:
						if($(this).hasClass('serv-mail') && ($(this).parent().find('.estado-inp').val() == 'vinculado' || $(this).parent().find('.estado-inp').val() == 'no-vinculado')) {
							teq = true;
						} else {
							teq = $(this).data('prev_value') == $(this).val();
						}	
				}
				if(!teq) {
					equals = teq;
				}
				
			});
			return equals;
		}
	};

	return {
		onload: function() {
			var msgCambioMail = function(mail) {
				var tmp = $('<div>'+kernel.util.trans(info.mensajes.mail_token_cambio, {mail:mail})+'</div>');
				$('<a class="set_mail_token_cancel" rel="1" href="#">'+info.mensajes.cancelar+'</a>').click(function(evt){
					evt.stopPropagation();
					kernel.ajax.call(info.url_eliminar_token, {
						type: 'get',
						success: function(data) {
							kernel.ui.show_mensaje(kernel.util.trans(data.cont, {mail:mail}));
						}
					});
					return false;
				}).appendTo(tmp);
				
				$('<span class="cerrar-msg icon-remove"></span>').click(function(){
					$('#_msg_placeholder').fadeOut();
				}).appendTo(tmp);
				return tmp;
			};
			
			$(document).ready(function(){
				$('.edChange').prevVal({dflt: true}).change(function(){
					if(!$('.editable').prevVal({cmpr:true})) {
						$('.guardar').prop('disabled', false).html('Guardar ahora');
					} else {
						$('.guardar').prop('disabled', true).html('Guardado');
					}
				});
				$('.edKeyup').prevVal({dflt: true}).keyup(function(){
					if(!$('.editable').prevVal({cmpr:true})) {
						$('.guardar').prop('disabled', false).html('Guardar ahora');
					} else {
						$('.guardar').prop('disabled', true).html('Guardado');
					}
				});
				if(info.mail_token) {
					kernel.ui.show_mensaje(msgCambioMail(info.mail_token), {until_interaction: true});
				} else if(info.mensajes.cambio_mail_exitoso) {
					kernel.ui.show_mensaje(info.mensajes.cambio_mail_exitoso);
				}
				$('#password').chkPass(function(){
					var password_nuevo_error = '<span class="g3w-icono-fail"></span>'+info.mensajes.password_nuevo_error;
					var password_debil = '<span class="g3w-icono-fail"></span>'+info.mensajes.password_debil;
					weak_pass = guarani.validar_password_debil($(this), $('#passworderror'), password_nuevo_error, password_debil, 'error_val', info.pass_pattern);
				});
			});
			
			$('#mensaje-pass').hide();
			
			$('.guardar').click(function(){
				if($('.guardar').prop('disabled')) return;
				var data = {};
				$('#mensaje-pass').hide();
				$('#password_actual').removeClass('error_val');
				$('#password').removeClass('error_val');
				$('#password1').removeClass('error_val');
				$('#password_actualerror').hide();
				$('#passworderror').hide();
				$('#password1error').hide();
				var error = false;
				
				if($('#mail_token_cancel').length && parseInt($('#mail_token_cancel').val(),10)) {
					data.mail_token_cancel = 1;
				}
			//Password				
				if($('#password_actual').val() != '' || $('#password').val() != '' || $('#password1').val() != '') {
					
					var password_nuevo_error = '<span class="g3w-icono-fail"></span>'+info.mensajes.password_nuevo_error;
					var passwords_no_coinciden = '<span class="g3w-icono-fail"></span>'+info.mensajes.passwords_no_coinciden;
					var password_repetir_error = '<span class="g3w-icono-fail"></span>'+info.mensajes.password_repetir_error;
					var password_debil = '<span class="g3w-icono-fail"></span>'+info.mensajes.password_debil;

					error = !guarani.validar_password($('#password_actual'), $('#password'), $('#password1'), $('#password_actualerror'), $('#passworderror'), $('#password1error'), 'error_val', password_nuevo_error, passwords_no_coinciden, password_repetir_error, weak_pass, password_debil);

					if(!error){
						data.password = {password_actual: $('#password_actual').val(), password: $('#password').val()};		
					}
				}
				
				

			//Checks
				var mail_notificacion = "N";

				if ($('#mail-notificacion').is(":checked")){
					mail_notificacion = "S";
				}

				//var error = false;
				$('#mail').removeClass('error_val');
				var mail = $('#mail').val();

				if ($('#mail').val() != ""){                    
					if (!isValidEmailAddress(mail)){
							error = true;
							$('#mail').addClass('error_val');
							$('#mail').focus();
					}
				} else {
					if (mail_notificacion == "S") {
							error = true;
							$('#mail').addClass('error_val');
					}
				}
				data.checks = {recibe_mail: mail_notificacion, mail: mail, manual: $('#mail').data('manualChange')||false};
				

				data['__csrf']= $('.guardar').parents('form').find('[name=__csrf]').val();
				if (!error){
					kernel.ajax.call($('.guardar').attr('action'), {
						type: 'post',
						data: data,
						success: function(data) {
							$('.guardar').parent('form').find('[name=__csrf]').val(data.csrf_token);
							var ops = {};
							var msg = $('<span></span>');
							if(data.checks && data.checks.cod == 2) {
								msg.append(msgCambioMail(data.checks.mail_new));
								
								ops.until_interaction = true;
								$('#mail').val(data.checks.mail_old);
							} 
							if(data.password) { 
								if(data.password.cod && data.password.cod == '-1') {
									$(data.password.which).addClass('error_val');
									$(data.password.which).focus();
									msg.append(data.password.cont);
									ops.tipo = 'alert-error';
								}
								else{
									$('#password_actual').val("");
									$('#password').val("");
									$('#password1').val("");
								}
							}


							if(msg.html() == '') { 
								msg.html(data.cont);
							} 
							kernel.ui.show_mensaje(msg, ops);
							if(ops.tipo != 'alert-error') {
                                $("#mail-notificacion").data('prev_value', $("#mail-notificacion").is(':checked'));
								$('.guardar').prop('disabled', true).html('Guardado');
							}
							$('.guardar').parents('form').find('[name=__csrf]').val(data.csrf_token);
						}
					});
				}
			});
                        
			$('.guardar').on('keypress', function(e) {
				if (e.which == 13) { $(this).trigger('click'); }
			});

			$('#mail').change(function(){
				$(this).data('manualChange', true);

			});
		}
	}

	function isValidEmailAddress(emailAddress) {
		var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
		return pattern.test(emailAddress);
	}
})
