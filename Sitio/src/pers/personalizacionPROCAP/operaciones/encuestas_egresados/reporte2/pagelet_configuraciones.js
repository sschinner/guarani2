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
//						data: data,
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
						$('.guardar').attr('disabled', false).html('Guardar ahora');
					} else {
						$('.guardar').attr('disabled', true).html('Guardado');
					}
				});
				$('.edKeyup').prevVal({dflt: true}).keyup(function(){
					if(!$('.editable').prevVal({cmpr:true})) {
						$('.guardar').attr('disabled', false).html('Guardar ahora');
					} else {
						$('.guardar').attr('disabled', true).html('Guardado');
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
				if($('.guardar').attr('disabled')) return;
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
				var mail_inscripcion = "N";

				if ($('#mail-notificacion').is(":checked")){
					mail_notificacion = "S";
				} 

				if ($('#mail-inscripcion').is(":checked")){
					mail_inscripcion = "S";
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
					if (mail_notificacion == "S" | mail_inscripcion == "S") {
							error = true;
							$('#mail').addClass('error_val');
					}
				}
				data.checks = {recibe_mail: mail_notificacion, recibe_mail_inscripcion: mail_inscripcion, mail: mail, manual: $('#mail').data('manualChange')||false};
				
				data.login = {vincular: [], desvincular: []};
				$(".login-srv-wrapper:not(.no-action)").each(function(){
					data.login[$('.estado-inp', this).val()].push({serv: $(this).attr('name'), id: $('.id-inp', this).val()});
				});
				
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
							if(data.login) {
								$(".login-srv-wrapper:not(.no-action)").each(function(){
									if($('.estado-inp', this).val() == 'vincular') {
										$('.estado-inp', this).val('vinculado');
										$('.estado-spn', this).html('Vinculado');
									} else {
										$('.estado-inp', this).val('no-vinculado');
										$('.estado-spn', this).html('No Vinculado');
									}
									$(this).addClass('no-action');
								});
							}

							if(msg.html() == '') { 
								msg.html(data.cont);
							} 
							kernel.ui.show_mensaje(msg, ops);
							if(ops.tipo != 'alert-error') {
								$('.guardar').attr('disabled', true).html('Guardado');
							}
							$('.guardar').parents('form').find('[name=__csrf]').val(data.csrf_token);
						}
					});
				}
			});
                        
			$('.guardar').on('keypress', function(e) {
				if (e.which == 13) { $(this).trigger('click'); }
			});
			
			$(".login-srv-wrapper").click(function(){
				if($('.estado-inp', this).val()=='no-vinculado' || $('.estado-inp', this).val()=='desvincular') {
					window.open($(this).attr('rel'), '', 'menubar=no,status=no,titlebar=no,toolbar=no');
				} else {
					srv_vinculo.call(this);
				}
			});
			
			var srv_vinculo = function(id) {
				if(id) {
					$(this).removeClass('no-action');
					$('.estado-inp', this).val('vincular').change();
					$('.estado-spn', this).html('A Vincular');
					$('.id-inp', this).val(id);
				} else {
					if($('.estado-ini',this).val() == 'vinculado' || $('.estado-inp', this).val() == 'vinculado') {
						$(this).removeClass('no-action');
						$('.estado-inp', this).val('desvincular').change();
						$('.estado-spn', this).html('A Desvincular');
						$('.id-inp', this).val('');
					} else if($('.estado-inp', this).val() == 'vincular') {
						$(this).addClass('no-action');
						$('.estado-inp', this).val('no-vinculado').change();
						$('.estado-spn', this).html('No Vinculado');
						$('.id-inp', this).val('');
					}
				}

			};
			window.returnPopup = function(data) {
				if(data.estado == 'error') {
					kernel.ui.show_mensaje(data.msg, {tipo: 'error'});
				} else {
					var lsw = $('.login-srv-wrapper[rel="'+data.url+'"]');
					if(!data.email || !isValidEmailAddress(data.email)) {
						kernel.ui.show_mensaje('El mail devuelto por '+data.proveedor+' no es válido', {tipo: 'error'});
						return;
					}
					$('#mensaje-admin-login').hide();
					if($('#mail').val() != data.email) {
						var msg = $('<div>'+kernel.util.trans(info.mensajes.mail_no_concuerda, {mail_nuevo: data.email, proveedor: data.proveedor, mail_configurado: $('#mail').val()})+'</div>');
		
						$('<a class="btn btn-info">'+info.mensajes.aceptar+'</a>').click(function(){
							srv_vinculo.call(lsw, data.id);
							$('.login-srv-wrapper').not(lsw).each(function(){
								srv_vinculo.call(this);
							});
							$('#mail').val(data.email);
							$('#mail').data('manualChange', false);
							lsw.find('.serv-mail').val(data.email).change();
							$.facebox.close();
							return false;
						}).appendTo(msg);
						$('<a class="btn btn-info">'+info.mensajes.cancelar+'</a>').click(function(){
							$.facebox.close();
							return false;
						}).appendTo(msg);
						$.facebox(msg);
					} else {
						srv_vinculo.call(lsw, data.id);
						lsw.find('.serv-mail').val(data.email).change();
					}
					
				}
			}
			
			$('#mail').change(function(){
				$(this).data('manualChange', true);
				$(".login-srv-wrapper:has(.estado-inp[value='vinculado'], .estado-inp[value='vincular']):has(.serv-mail[value!='"+this.value+"'])").click();
				var $sd = $(".login-srv-wrapper:has(.estado-inp[value='desvincular'], .estado-inp[value='no-vinculado']):has(.serv-mail[value='"+this.value+"'])");
				if($sd.length) {
					var names = [];
					$sd.each(function(){
						names.push($(this).attr('name'));
					});
					var plural = names.length>1;
					var msg = $('<div>'+kernel.util.trans(plural?info.mensajes.revincular_plural:info.mensajes.revincular_singular, {servicios: names.join(', ')})+'</div>');
					$('<a class="btn btn-info">'+info.mensajes.aceptar+'</a>').click(function(){
						$('#mail').data('manualChange', false);
						$sd.click();
						$.facebox.close();
						return false;
					}).appendTo(msg);
					$('<a class="btn btn-info">'+info.mensajes.cancelar+'</a>').click(function(){
						$.facebox.close();
						return false;
					}).appendTo(msg);
					$.facebox(msg);
				}
			});
		}
	}

	function isValidEmailAddress(emailAddress) {
		var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
		return pattern.test(emailAddress);
	}
})
