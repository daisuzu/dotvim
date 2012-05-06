dotvim
======
You can setup the environment in the following steps.

Preparation
-----------
1. Install `Git`
2. Install `GCC` or `Microsoft Visual C++`

Setup
-----
1. clone this repository from git://github.com/daisuzu/dotvim
2. copy to `.vimrc` and `.gvimrc` to `$HOME/.vim` or `$VIM`
3. make `vimfiles/Bundle` directory in `$HOME/.vim` or `$VIM`
4. cd to `vimfiles/Bundle`
5. clone neobundle.vim from git://github.com/Shougo/neobundle.vim
6. clone unite.vim from git://github.com/Shougo/unite.vim
7. clone vimproc from git://github.com/Shougo/vimproc
8. cd to `vimproc`
9. run `make -f make_YOUR-ARCHITECTURE.mak`
10. start up `gvim` or `vim`
11. press a key to the order of the `fpi`
12. install following softwares as necessary

Useful Softwares
----------------
Some plugin needs these Programming languages.

* Python [http://www.python.org/]

* Perl [http://www.perl.org/]

* GHC [http://www.haskell.org/ghc/]
* Cabal [http://www.haskell.org/cabal/]
* ghc-mod [using Cabal]

* Node.js [http://nodejs.org/]
* CoffeeScript [using npm(Node Package Manager)]

* Clojure [http://clojure.org/]
* leiningen [https://github.com/technomancy/leiningen]

* LLVM/Clang [http://llvm.org/]


Some plugin needs these tag generation softwares.

* Ctags [http://hp.vector.co.jp/authors/VA025040/ctags/]
* GNU GLOBAL [http://www.gnu.org/software/global/]
* CSCOPE [http://cscope.sourceforge.net/]


Some plugin needs command line tool for transferring data with URL syntax.

* cURL [http://curl.haxx.se/]


Some plugin can use ack as text finder.

* ack  [using CPAN(Comprehensive Perl Archive Network)]


For processing markdown.

* Pandoc [using Cabal]


If using Windows OS, these software extends command line processing.

* Everything [http://www.voidtools.com/]
* MinGW or Cygwin [http://www.mingw.org/] or [http://www.cygwin.com/]
* grep [http://gnuwin32.sourceforge.net/packages/grep.htm]
* DiffUtils  [http://gnuwin32.sourceforge.net/packages/diffutils.htm]
* Lynx [http://lynx-win32-pata.sourceforge.jp/index-ja.html]
