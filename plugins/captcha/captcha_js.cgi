#!/usr/bin/perl
use Authen::Captcha;
use CGI;

my $captcha = Authen::Captcha->new(data_folder => './data',
				   output_folder => './images');
my $captcha_length = 5;
my $captcha_img_width = 25 * $captcha_length;
my $captcha_img_height = 35;

my $q = CGI->new;

my $captcha_md5 = $captcha->generate_code($captcha_length);

my $url = $q->url;
$url =~ s!/[^/]+$!!;

print $q->header('text/javascript');
print <<EOD;
if (!commenter_name) {
document.writeln('<div id="comment-captcha-block">');
document.writeln('<input type="hidden" name="captcha_md5" value="$captcha_md5" />');
document.writeln('<label for="comment-captcha">CAPTCHA&trade; Code:</label>');
document.writeln('<img src="$url/images/$captcha_md5.png" width="$captcha_img_width" height="$captcha_img_height" alt="CAPTCHA Image" />');
document.writeln('<input type="text" id="comment-captcha" name="captcha_code" value="" length="$captcha_length" maxlength="$captcha_length" />');
document.writeln('</div>');
}
EOD

1;
