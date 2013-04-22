# Captchaプラグイン

CAPTCHA&trade;テストによる簡単なアンチコメントスパムプラグイン。

## 更新履歴

 * 0.01(2006-05-18):
   * 公開。
 * 0.02(2006-05-19):
   * プラグインの設定画面からCAPTCHAテストのTTL(有効期限)を設定できるようにした。
 * 0.10(2006-10-04):
   * ブログごとにCAPTCHAテストの有効・無効を選択できるようにした。
   * CAPTCHAテスト文字列の長さを変更できるようにした。
   * CAPTCHAテストの生成時・検証時に用いるsecret keyを設定できるようにした。
   * CAPTCHA画像の格納先ディレクトリをユーザが指定できるようにしました。いくつかのWebホスティングサービスではCGIスクリプトの格納場所に制限があるため、0.02までのような固定のディレクトリではCAPTCHA画像にブラウザでアクセスできない場合がありました。
 * 0.11(2006-10-05):
   * 設定ファイルのシリアライズにData::Dumperモジュールを使うようにした。
   * プラグインデータを無駄にキャッシングをしていたので止めた。
 * 0.11a(2006-10-05):
   * FreeBSD portsのp5-Authen-Captchaはsecretオプションをサポートしているが、CPANで配っているAuthen-Captchaはサポートしていないようだ。secretオプションが使えないときは華麗にスルーするように修正した。
 * 0.12(2006-10-08):
   * CAPTCHAテスト表示時のテンプレートをプラグインの設定画面から変更できるようにした。ただし、変更する際は慎重に行う必要がある。
 * 0.13(2006-10-17):
   * CAPTCHAを使用しないブログのコメント投稿に不具合があった問題を修正。

## 概要

Captcha Pluginは、CAPTCHAテストを生成・検証することで、アンチコメントスパム機能を実現するプラグインです。CAPTCHAテストとは、大抵の人間には容易に解答できるがプログラムでは簡単に解けないようなテストを課すことでspambotを排除するもので、Google、Yahoo!をはじめ多くのオンラインサービスでCAPTCHAを使ったbot防御が実現されています。

類似のプラグインとしてSCode pluginなどが知られていますが、Captcha pluginはこれらとは異なり、コメンターがコメントページを閲覧するたびに異なるCAPTCHAテストを生成し、それぞれのテストには短めの有効期限があります。あるエントリーのコメントページに対して一意なテストを課した場合(その場合、各エントリーのテストに対する答えは一定になります)に比べてより防御力が高くなることが期待されます。

## 必要なソフトウェア

このプラグインは、Movable Type 3.2以降で動作します。また、以下のPerlモジュールが必要になります。

 * [http://search.cpan.org/dist/Authen-Captcha/]()
 * [http://search.cpan.org/dist/GD/]()

Captcha Plugin 0.10以降では、brute force attackへの対策としてsecret keyによる簡易な認証機能をサポートしています。この機能を使うためには、下記のパッチをAuthen::Captchaに適用する必要があります。FreeBSDなどのportsではこのパッチは適用済みになっています。

 * [http://rt.cpan.org/Public/Bug/Display.html?id=7664]()

## インストール方法

インストール作業はそれほど難しくありません。

 * Captcha.zipをダウンロードします。
 * 配布ファイルをMovable Typeのディレクトリでアンパックします。すると、pluginsディレクトリにcaptchaという名前のディレクトリが作られるはずです。
 * ファイルとディレクトリのパーミッションをチェックします。
  * plugins/captcha/captcha_js.cgi … CGIスクリプトとして実行可能にする
  * plugins/captcha/data … CGIスクリプトから書き込み可能にする
  * plugins/captcha/images … CGIスクリプトから書き込み可能にする

以上。無事インストールが済めば、システムのプラグイン一覧ページにCaptcha pluginが表示されるはずです。

## 使い方

CAPTCHAテストを使うには、コメントフォームのあるすべてのテンプレートに以下の行を追加(コメント用のform要素の内部に記述する)し、再構築する必要があります。

    <script type="text/javascript" src="<$MTCaptchaJsURL$>"></script>

各CAPTCHAテストは、デフォルトで一時間の有効期限を持っています。コメンターはコメントページ表示後一時間以内に正しい解答と共にコメントをサブミットする必要があります。この有効期限は、各ブログのプラグイン設定画面の「CAPTCHA TTL」で設定することができます。

## TODO

 * ブログごとにCaptcha Testをenable/disableできるようにする → 0.10で対応
 * Captchaの長さを設定できるようにする → 0.10で対応
 * Secret keyを設定できるようにする → 0.10で対応
 * pluginsディレクトリが「Options ExecCGI」なディレクトリのとき、Captcha画像が表示できない問題がある。Captcha画像のoutput_folderをmt-staticの下などに移動する。 → 0.10で対応

## See Also

## License

This code is released under the Artistic License. The terms of the Artistic License are described at [http://www.perl.com/language/misc/Artistic.html]().

## Author & Copyright

Copyright 2006, Hirotaka Ogawa (hirotaka.ogawa at gmail.com)
