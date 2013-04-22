# Captcha Plugin

A simple plugin for commenting with CAPTCHA(TM) test.

## Changes

 * 0.01(2006-05-18):
   * First release.
 * 0.02(2006-05-19):
   * Now can configure TTL for CAPTCHA tests from the plugin setting screen.
 * 0.10(2006-10-04):
   * Now can enable or disable CAPTCHA tests per-blog basis.
   * Now can change the length of CAPTCHA test strings.
   * Now can set a secret key for generating CAPTCHA codes.
   * Captcha images can be placed under the user-specific directory.  This is for someone who can make plugins directory be executable but not readable (it might be usual for most web-hosting services).
 * 0.11(2006-10-05):
   * Captcha plugin now employed Data::Dumper module for configuration object serialization.
   * Meaningless caching for plugin data is removed.
 * 0.11a(2006-10-05):
   * Now Captcha plugin becomes compatible with Authen-Captcha distributed via CPAN, which doesn't support "secret" option.
 * 0.12(2006-10-08):
   * Now users can modify the template for showing CAPTCHA tests from the plugin setting screen.  Be careful to modify this.
 * 0.13(2006-10-17):
   * Fix a bug for captcha-disabled blogs.

## Overview

"Captcha Plugin" is an anti comment-spam plugin which generates and verifies CAPTCHA(TM) tests that most human commenters can easily pass but current spambots cannot pass.

Unlike well-known SCode plugin, Captcha plugin generates different CAPTCHA tests whenever commenters request commenting pages, and each tests have shorter time to live.  So, I think, Captcha plugin is less exploitable by spammers than the predecessors.

## Requirements

This plugin is supported on Movable Type 3.2 or later and requires the following Perl modules:

 * [http://search.cpan.org/dist/Authen-Captcha/]()
 * [http://search.cpan.org/dist/GD/]()

If you want to employ "secret key" feature, you must apply the following patch to Authen::Captcha.

 * [http://rt.cpan.org/Public/Bug/Display.html?id=7664]()

## Installation

Installation process is not so hard.

 * Download Captcha.zip.
 * Unpack the distribution in your Movable Type directory.  You will get just one directory called "captcha" under your plugins directory.
 * Check permissions for files and directories.
   * plugins/captcha/captcha_js.cgi should be executable as a CGI script.
   * plugins/captcha/data should be writable by CGI programs.
   * plugins/captcha/images should be writable by CGI programs.

That's all.  You'll see the Captcha plugin in the plugins listing in the system overview screen.

## Usage

To use CAPTCHA tests, you will need to add the following line into your all commenting templates and rebuild them.

    <script type="text/javascript" src="<$MTCaptchaJsURL$>"></script>

Each CAPTCHA tests has a time to live, and the default lifetime is 1 hour.  To customize the lifetime, you will need to change "CAPTCHA TTL" from the blog plugin setting screen.

## See Also

## License

This code is released under the Artistic License. The terms of the Artistic License are described at [http://www.perl.com/language/misc/Artistic.html]().

## Author & Copyright

Copyright 2006, Hirotaka Ogawa (hirotaka.ogawa at gmail.com)
