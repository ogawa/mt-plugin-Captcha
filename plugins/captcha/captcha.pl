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
use File::Spec;
use File::Basename;
use Authen::Captcha;
use base 'MT::Plugin';
our $VERSION = '0.02';

my $plugin = __PACKAGE__->new({
    name => 'Captcha',
    description => 'This plugin enables comment-posting with CAPTCHA test.',
    doc_link => 'http://as-is.net/wiki/Captcha_Plugin',
    author_name => 'Hirotaka Ogawa',
    author_link => 'http://profile.typekey.com/ogawa/',
    version => $VERSION,
    blog_config_template => \&config_tmpl,
    settings => new MT::PluginSettings([
	['captcha_ttl', { Default => 3600 }],
    ]),
});
MT->add_plugin($plugin);

my $dirname = dirname(__FILE__);
my $captcha = Authen::Captcha->new(
   data_folder => File::Spec->catdir($dirname, 'data'),
   output_folder => File::Spec->catdir($dirname, 'images')
);

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

    my $ttl = config('blog:' . $blog->id)->{captcha_ttl};
    $ttl = 3600 if $ttl !~ /^\d+$/;
    $captcha->expire($ttl);

    ($captcha->check_code($code, $md5) > 0) ? 1 : 0;
}

sub captcha_js_url {
    my ($ctx, $args) = @_;
    my $path = MT::ConfigMgr->instance->CGIPath;
    $path .= '/' unless $path =~ m!/$!;
    $path . 'plugins/captcha/captcha_js.cgi';
}

use MT::Request;
sub config {
    return {} unless $plugin;
    my $scope = shift || 'system';
    my $r = MT::Request->instance;
    my $cfg = $r->cache('captcha_config_' . $scope);
    if (!$cfg) {
	$cfg = $plugin->get_config_hash($scope);
	$r->cache('captcha_config_' . $scope, $cfg);
    }
    $cfg;
}

sub config_tmpl {
    my $tmpl = <<'EOT';
<div class="setting">
  <div class="label"><label for="captcha_ttl"><MT_TRANS phrase="CAPTCHA TTL:"></label></div>
  <div class="field">
    <input name="captcha_ttl" id ="captcha_ttl" size="5" value="<TMPL_VAR NAME=CAPTCHA_TTL ESCAPE=HTML>" /> <MT_TRANS phrase="seconds"> (max: 3600 seconds)
  </div>
</div>
EOT
}

1;
