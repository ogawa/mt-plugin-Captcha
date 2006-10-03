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
my $cfg_file = File::Spec->catfile($dirname, 'data', 'config.txt');
my $config;

my $q = CGI->new;
eval {
    $config = read_config($cfg_file);
    gen_code($q);
};
if ($@) {
    print $q->header("text/plain"), $@ if $@;
}

sub read_config {
    my($cfg_file) = @_;
    my $config;

    local(*FH, $_, $/);
    $/ = "\n";
    open FH, $cfg_file or die "Can't open File: $cfg_file\n";
    flock FH, 1;
    while (<FH>) {
	chomp;
	my @c = split(',', $_);
	next unless scalar @c == 6;
	$config->{$c[0]} = {
	    captcha_ttl => $c[1],
	    captcha_secret => $c[2],
	    captcha_length => $c[3],
	    captcha_images_url => $c[4],
	    captcha_images_path => $c[5],
	};
    }
    close(FH);
    $config;
}

sub gen_code {
    my $q = shift;
    my $blog_id = $q->param('blog_id') || 1;
    my $conf = $config->{$blog_id} or die "blog_id is not properly given.";

    $captcha->expire($conf->{captcha_ttl} || 3600);
    $captcha->secret($conf->{captcha_secret} || '');
    $captcha->output_folder($conf->{captcha_images_path});

    my $captcha_images_url = $conf->{captcha_images_url};
    $captcha_images_url .= '/' if $captcha_images_url !~ m!/$!;

    my $captcha_length = $conf->{captcha_length} || 5;
    my $captcha_img_width = 25 * $captcha_length;
    my $captcha_img_height = 35;

    my $captcha_md5 = $captcha->generate_code($captcha_length);

    print $q->header('text/javascript');
    print <<EOD;
if (!commenter_name) {
  document.writeln('<div id="comment-captcha-block">');
  document.writeln('<input type="hidden" name="captcha_md5" value="$captcha_md5" />');
  document.writeln('<label for="comment-captcha">CAPTCHA&trade; Code:</label>');
  document.writeln('<img src="$captcha_images_url$captcha_md5.png" width="$captcha_img_width" height="$captcha_img_height" alt="CAPTCHA Image" />');
  document.writeln('<input type="text" id="comment-captcha" name="captcha_code" value="" length="$captcha_length" maxlength="$captcha_length" />');
  document.writeln('</div>');
}
EOD
}

1;
