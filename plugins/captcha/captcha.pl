# Captcha - A simple plugin for commenting with CAPTCHA test.
#
# $Id$
#
# This software is provided as-is. You may use it for commercial or 
# personal use. If you distribute it, please keep this notice intact.
#
# Copyright (c) 2006 Hirotaka Ogawa

package MT::Plugin::Captcha;
use strict;
use MT;
use MT::Template::Context;
use Authen::Captcha;
use base 'MT::Plugin';
our $VERSION = '0.01';

my $plugin = __PACKAGE__->new({
    name => 'Captcha',
    description => 'This plugin enables comment-posting with CAPTCHA test.',
    doc_link => 'http://as-is.net/wiki/Captcha_Plugin',
    author_name => 'Hirotaka Ogawa',
    author_link => 'http://profile.typekey.com/ogawa/',
    version => $VERSION,
});
MT->add_plugin($plugin);

my $captcha = Authen::Captcha->new(data_folder => './data',
				   output_folder => './images');
MT->add_callback('CommentThrottleFilter', 5, $plugin, \&captcha_test);
MT::Template::Context->add_tag(CaptchaJsURL => \&captcha_js_url);

sub captcha_test {
    my ($eh, $app, $entry) = @_;
    my $blog = $entry->blog;
    if ($blog->allow_reg_comments && $blog->effective_remote_auth_token) {
	my ($session_key, $commenter) = $app->_get_commenter_session();
	return 1 if $commenter;
    }

    my $q = $app->{query};
    my $code = $q->param('captcha_code') or return 0;
    my $md5 = $q->param('captcha_md5') or return 0;

    ($captcha->check_code($code, $md5) > 0) ? 1 : 0;
}

sub captcha_js_url {
    my ($ctx, $args) = @_;
    my $path = MT::ConfigMgr->instance->CGIPath;
    $path .= '/' unless $path =~ m!/$!;
    $path . 'plugins/captcha/captcha_js.cgi'; # ad hoc
}

1;
