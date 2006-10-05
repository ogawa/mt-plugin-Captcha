#!/usr/bin/perl
#
# $Id$
#
use Authen::Captcha;
use File::Spec;
use File::Basename;
use CGI;

my $dirname = dirname(__FILE__);
my $captcha = Authen::Captcha->new(
   data_folder => File::Spec->catdir($dirname, 'data')
);
my $config_file = File::Spec->catfile($dirname, 'data', 'config.txt');
my $config;

my $q = CGI->new;
eval {
    $config = read_config($config_file);
    generate_code($q);
};
if ($@) {
    print $q->header("text/plain"), $@ if $@;
}

sub read_config {
    my($config_file) = @_;

    local(*FH);
    open FH, $config_file or die "Can't open File: $config_file.";
    flock FH, 1; # read lock
    my @lines = <FH>;
    close(FH);

    my $config;
    eval join('', @lines);
}

sub generate_code {
    my $q = shift;
    my $blog_id = $q->param('blog_id') || 1;
    my $cfg = $config->{$blog_id} or die "blog_id is not properly given.";

    die "CAPTCHA test is disabled for this blog (BLOG_ID:$blog_id)."
	unless $cfg->{captcha_enable};

    $captcha->expire($cfg->{captcha_ttl} || 3600);
    $captcha->secret($cfg->{captcha_secret} || '')
	if $captcha->can('secret');
    $captcha->output_folder($cfg->{captcha_images_path});
    my $captcha_length = $cfg->{captcha_length} || 5;
    my $captcha_md5 = $captcha->generate_code($captcha_length);
    my $captcha_img = $cfg->{captcha_images_url};
    $captcha_img .= '/' if $captcha_img !~ m!/$!;
    $captcha_img .= $captcha_md5 . '.png';
    my $captcha_img_width = 25 * $captcha_length;
    my $captcha_img_height = 35;

    print $q->header('text/javascript');
    print <<EOD;
if (!commenter_name) {
  document.writeln('<div id="comment-captcha-block">');
  document.writeln('<input type="hidden" name="captcha_md5" value="$captcha_md5" />');
  document.writeln('<label for="comment-captcha">CAPTCHA&trade; Code:</label>');
  document.writeln('<img src="$captcha_img" width="$captcha_img_width" height="$captcha_img_height" alt="CAPTCHA Image" />');
  document.writeln('<input type="text" id="comment-captcha" name="captcha_code" value="" length="$captcha_length" maxlength="$captcha_length" />');
  document.writeln('</div>');
}
EOD
}

1;
