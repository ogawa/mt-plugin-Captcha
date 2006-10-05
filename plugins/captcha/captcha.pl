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
use Data::Dumper;
use Authen::Captcha;
use base 'MT::Plugin';
our $VERSION = '0.11';

my $dirname = dirname(__FILE__);
my $cgipath = MT::ConfigMgr->instance->CGIPath;
$cgipath .= '/' unless $cgipath =~ m!/$!;

my $plugin = __PACKAGE__->new({
    name => 'Captcha',
    description => 'This plugin enables comment-posting with CAPTCHA test.',
    doc_link => 'http://code.as-is.net/wiki/Captcha_Plugin',
    author_name => 'Hirotaka Ogawa',
    author_link => 'http://profile.typekey.com/ogawa/',
    version => $VERSION,
    blog_config_template => 'config.tmpl',
    settings => new MT::PluginSettings([
	['captcha_enable', { Default => 0 }],
	['captcha_ttl', { Default => 3600 }],
	['captcha_secret', { Default => '' }],
	['captcha_length', { Default => 5 }],
	['captcha_images_url', { Default => $cgipath . 'plugins/captcha/images/' }],
	['captcha_images_path', { Default => File::Spec->catdir($dirname, 'images') }],
    ]),
});
MT->add_plugin($plugin);

my $captcha = Authen::Captcha->new(
   data_folder => File::Spec->catdir($dirname, 'data')
);

MT->add_callback('CommentThrottleFilter', 5, $plugin, \&captcha_test);
MT::Template::Context->add_tag(CaptchaJsURL => \&captcha_js_url);

sub captcha_test {
    my ($eh, $app, $entry) = @_;
    my $blog = $entry->blog;

    # check if commenter is logged on to typekey
    if ($blog->allow_reg_comments && $blog->effective_remote_auth_token) {
	my ($session_key, $commenter) = $app->_get_commenter_session();
	return 1 if $commenter;
    }

    my $q = $app->{query};
    my $code = $q->param('captcha_code') or return 0;
    my $md5 = $q->param('captcha_md5') or return 0;

    # load config
    my $cfg = $plugin->get_config_hash('blog:' . $blog->id);

    # check if captcha-test disabled
    return 1 unless $cfg->{captcha_enable};

    # configure Auth::Captcha
    $captcha->output_folder($cfg->{captcha_images_path});
    $captcha->secret($cfg->{captcha_secret} || '')
	if $captcha->can('secret');

    my $ttl = $cfg->{captcha_ttl};
    $ttl = 3600 if $ttl !~ /^\d+$/;
    $captcha->expire($ttl);

    ($captcha->check_code($code, $md5) > 0) ? 1 : 0;
}

sub captcha_js_url {
    my ($ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog')->id;
    my $path = MT::ConfigMgr->instance->CGIPath;
    $path .= '/' unless $path =~ m!/$!;
    $path . 'plugins/captcha/captcha_js.cgi?blog_id=' . $blog_id;
}

sub dump_settings {
    my $plugin = shift;

    my $config;
    for my $blog (MT::Blog->load) {
	$config->{$blog->id} = $plugin->get_config_hash('blog:' . $blog->id);
    }

    my $config_file = File::Spec->catfile(dirname(__FILE__), 'data', 'config.txt');
    local(*FH);
    open FH, ">$config_file" or die "Can't open File: $config_file\n";
    flock FH, 2;
    print FH Data::Dumper->Dump([$config], ['config']);
    close(FH);
}

sub save_config {
    my $plugin = shift;
    $plugin->SUPER::save_config(@_);
    delete $plugin->{__config_obj}{$_[0]}; # invalidate cache
    $plugin->dump_settings();
}

sub reset_config {
    my $plugin = shift;
    $plugin->SUPER::reset_config(@_);
    delete $plugin->{__config_obj}{$_[0]}; # invalidate cache
    $plugin->dump_settings();
}

1;
