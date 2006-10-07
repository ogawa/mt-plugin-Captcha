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

    my %captcha;
    $captcha{length} = $cfg->{captcha_length} || 5;
    $captcha{md5} = $captcha->generate_code($captcha{length});
    $captcha{img} = $cfg->{captcha_images_url};
    $captcha{img} .= '/' if $captcha{img} !~ m!/$!;
    $captcha{img} .= $captcha{md5}. '.png';
    $captcha{img_width} = 25 * $captcha{length};
    $captcha{img_height} = 35;

    my $tmpl =  $cfg->{captcha_tmpl};
    $tmpl =~ s/\[captcha_([^]]+)\]/$captcha{$1}/g;

    print $q->header('text/javascript');
    print "if (!commenter_name) {\n";
    print "\tdocument.writeln('$_');\n" foreach split(/\r?\n/, $tmpl);
    print "}\n";
}

1;
