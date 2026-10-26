kernel.renderer.registrar_pagelet('recuperar_pass', function (info) {
    var id = '#' + info.id;
    var weak_pass = false;

    return {
        onload: function () {

            $('#columna_1, #columna_2').removeClass("span5 span7").addClass("span6");

//			$('#guarani_form_recuperar_pass').find('input[name=documento]').keyup(function(e) {
//				var reg = new RegExp('^[0-9]+$');
//				if (! reg.test($(this).val())) {
//										if (! $(this).hasClass('js-error')) {
//						$(this).after(notif);
//						$(this).addClass('js-error');
//					}kernel.ui.armar_notificaciones('', [{
//						mtipo: 'E',
//						mcuerpo: 'El campo documento sólo debe contener números'
//					}]);
//					if (! $(this).hasClass('js-error')) {
//						$(this).after(notif);
//						$(this).addClass('js-error');
//					}
//				} else {
//					$(this).parent().find('.alert').remove();
//					$(this).removeClass('js-error');
//				}
//				
//				return true;
//			}).focus();

            $('#guarani_form_reset_pass').submit(function () {

                var npassword = $('#guarani_form_reset_pass').find('#password');
                var rpassword = $('#guarani_form_reset_pass').find('#rpassword');

                var password_nuevo_error_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.password_nuevo_error;
                var password_debil_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.password_debil;
                var passwords_no_coinciden_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.passwords_no_coinciden;
                var password_repetir_error_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.password_repetir_error;

                return guarani.validar_password(null, npassword, rpassword, null, $('#password-error'), $('#rpassword-error'), 'error_val', password_nuevo_error_msg, passwords_no_coinciden_msg, password_repetir_error_msg, weak_pass, password_debil_msg);

            });

            $('#password').keyup(function () {

                var password_nuevo_error_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.password_nuevo_error;
                var password_debil_msg = '<span class="g3w-icono-fail"></span>' + info.mensajes.password_debil;

                weak_pass = guarani.validar_password_debil($(this), $('#password-error'), password_nuevo_error_msg, password_debil_msg, 'error_val', info.pass_pattern);

            });

        }
    }
})
