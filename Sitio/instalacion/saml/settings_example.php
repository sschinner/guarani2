<?php

//settings y advanced_settings de la libreria de saml.

return $settings = array (
    // If 'strict' is True, then the PHP Toolkit will reject unsigned
    // or unencrypted messages if it expects them signed or encrypted
    // Also will reject the messages if not strictly follow the SAML
    // standard: Destination, NameId, Conditions ... are validated too.
    'strict' => false,

    // Enable debug mode (to print errors)
    'debug' => false,

    // Service Provider Data that we are deploying
    'sp' => array (
        // Identifier of the SP entity  (must be a URI)
        'entityId' => 'http://mv.com/g3w2_trunk/acceso',
        // Specifies info about where and how the <AuthnResponse> message MUST be
        // returned to the requester, in this case our SP.
        'assertionConsumerService' => array (
            // URL Location where the <Response> from the IdP will be returned
            'url' => 'http://mv.com/g3w2_trunk/acceso?auth=saml',
            // SAML protocol binding to be used when returning the <Response>
            // message.  Onelogin Toolkit supports for this endpoint the
            // HTTP-Redirect binding only
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
        ),
        // Specifies info about where and how the <Logout Response> message MUST be
        // returned to the requester, in this case our SP.
        'singleLogoutService' => array (
            // URL Location where the <Response> from the IdP will be returned
            'url' => 'http://mv.com/g3w2_trunk/acceso/logout',
            // SAML protocol binding to be used when returning the <Response>
            // message.  Onelogin Toolkit supports for this endpoint the
            // HTTP-Redirect binding only
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        ),
        // Specifies constraints on the name identifier to be used to
        // represent the requested subject.
        // Take a look on lib/Saml2/Constants.php to see the NameIdFormat supported
        'nameIdFormat' => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',

        // Usually x509cert and privateKey of the SP are provided by files placed at
        // the certs folder. But we can also provide them with the following parameters
        'x509cert' => file_get_contents(\siu\bootstrap::get_dir_instalacion() . '/saml/example.org.crt'),
        'privateKey' > file_get_contents(\siu\bootstrap::get_dir_instalacion() . '/saml/example.org.pem'),
    ),

    // Identity Provider Data that we want connect with our SP
    'idp' => array (
        // Identifier of the IdP entity  (must be a URI)
        'entityId' => 'http://idp.loc/simplesaml/saml2/idp/metadata.php',
        // SSO endpoint info of the IdP. (Authentication Request protocol)
        'singleSignOnService' => array (
            // URL Target of the IdP where the SP will send the Authentication Request Message
            'url' => 'http://idp.loc/simplesaml/saml2/idp/SSOService.php',
            // SAML protocol binding to be used when returning the <Response>
            // message.  Onelogin Toolkit supports for this endpoint the
            // HTTP-POST binding only
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        ),
        // SLO endpoint info of the IdP.
        'singleLogoutService' => array (
            // URL Location of the IdP where the SP will send the SLO Request
            'url' => 'http://idp.loc/simplesaml/saml2/idp/SingleLogoutService.php',
            // SAML protocol binding to be used when returning the <Response>
            // message.  Onelogin Toolkit supports for this endpoint the
            // HTTP-Redirect binding only
            'binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
        ),
        // Public x509 certificate of the IdP
//        'x509cert' => \siu\bootstrap::get_dir_instalacion() . '/saml/example.org.crt',
        /*
         *  Instead of use the whole x509cert you can use a fingerprint
         *  (openssl x509 -noout -fingerprint -in "idp.crt" to generate it)
         */
         'certFingerprint' => 'DD4672DA5B0AAD183F1F69408BD3397D80BE1529',
    ),

	//Advanced settings
	// Security settings
    'security' => array (

	    /** signatures and encryptions offered */

	    // Indicates that the nameID of the <samlp:logoutRequest> sent by this SP
	    // will be encrypted.
	    'nameIdEncrypted' => false,

	    // Indicates whether the <samlp:AuthnRequest> messages sent by this SP
	    // will be signed.              [The Metadata of the SP will offer this info]
	    'authnRequestsSigned' => false,

	    // Indicates whether the <samlp:logoutRequest> messages sent by this SP
	    // will be signed.
	    'logoutRequestSigned' => false,

	    // Indicates whether the <samlp:logoutResponse> messages sent by this SP
	    // will be signed.
	    'logoutResponseSigned' => false,

	    /* Sign the Metadata
	 False || True (use sp certs) || array (
												keyFileName => 'metadata.key',
												certFileName => 'metadata.crt'
											)
	*/
	    'signMetadata' => false,


	    /** signatures and encryptions required **/

	    // Indicates a requirement for the <samlp:Response>, <samlp:LogoutRequest> and
	    // <samlp:LogoutResponse> elements received by this SP to be signed.
	    'wantMessagesSigned' => false,

	    // Indicates a requirement for the <saml:Assertion> elements received by
	    // this SP to be signed.        [The Metadata of the SP will offer this info]
	    'wantAssertionsSigned' => false,

	    // Indicates a requirement for the NameID received by
	    // this SP to be encrypted.
	    'wantNameIdEncrypted' => false,
    ),

	// Contact information template, it is recommended to suply a technical and support contacts
    'contactPerson' => array (
	    'technical' => array (
		    'givenName' => 'CAMBIAR',
		    'emailAddress' => 'CAMBIAR'
	    ),
	    'support' => array (
		    'givenName' => 'CAMBIAR',
		    'emailAddress' => 'CAMBIAR'
	    ),
    ),

	// Organization information template, the info in en_US lang is recomended, add more if required
    'organization' => array (
	    'en-US' => array(
		    'name' => 'CAMBIAR',
		    'displayname' => 'CAMBIAR',
		    'url' => 'CAMBIAR.com'
	    ),
    ),
);
