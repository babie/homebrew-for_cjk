require 'formula'

class ZshForCjk < Formula
  homepage 'http://www.zsh.org/'
  url 'https://downloads.sourceforge.net/project/zsh/zsh/5.0.5/zsh-5.0.5.tar.bz2'
  mirror 'http://www.zsh.org/pub/zsh-5.0.5.tar.bz2'
  sha1 '75426146bce45ee176d9d50b32f1ced78418ae16'

  depends_on 'gdbm'
  depends_on 'pcre'
  depends_on 'ncurses'

  option 'disable-etcdir', 'Disable the reading of Zsh rc files in /etc'

  def patches
    [
      'https://gist.github.com/waltarix/1407905/raw',
      'https://gist.github.com/waltarix/1403346/raw'
    ]
  end

  def install
    ENV.append "LDFLAGS", "-L/usr/local/opt/ncurses/lib"
    ENV.append "CPPFLAGS", "-I/usr/local/opt/ncurses/include"

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --with-term-lib=ncursesw
    ]

    if build.include? 'disable-etcdir'
      args << '--disable-etcdir'
    else
      args << '--enable-etcdir=/etc'
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make", "install"
    system "make", "install.info"
  end

  test do
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/helpfiles
    EOS
  end
end
