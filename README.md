dotvim
======
You can setup the environment in the following steps.

Preparation
-----------
1. Install `Git`
2. Install `GCC` or `Microsoft Visual C++`

Setup
-----
1. clone this repository from https://github.com/daisuzu/dotvim
2. copy `.vimrc` to `$HOME/.vim` or `$VIM`
3. run `vim -c "call InstallPackPlugins() | qall!"`
4. cd to path to `vimproc`
5. run `make -f make_YOUR-ARCHITECTURE.mak`
6. install following softwares as necessary

Useful Softwares
----------------
Some plugin needs these Programming languages.

* Python [https://www.python.org]

* Perl [https://www.perl.org]

* Node.js [https://nodejs.org]

* Clojure [http://clojure.org]
* leiningen [https://github.com/technomancy/leiningen]

* Go [https://golang.org]


Some plugin needs these tag generation softwares.

* Ctags [http://hp.vector.co.jp/authors/VA025040/ctags]
* Universal Ctags [https://github.com/universal-ctags/ctags]


Some plugin needs command line tool for transferring data with URL syntax.

* cURL [https://curl.haxx.se]


Some plugin can use jvgrep as text finder.

* jvgrep [https://github.com/mattn/jvgrep]


For processing markdown.

* Pandoc [http://pandoc.org]


If using Windows OS, these software extends command line processing.

* Everything [http://www.voidtools.com]
* MSYS2 or Cygwin [https://msys2.github.io] or [http://www.cygwin.com]
* grep [http://gnuwin32.sourceforge.net/packages/grep.htm]
* DiffUtils  [http://gnuwin32.sourceforge.net/packages/diffutils.htm]
* Lynx [http://lynx-win32-pata.sourceforge.jp/index-ja.html]
* w3m [http://w3m.sourceforge.net]
