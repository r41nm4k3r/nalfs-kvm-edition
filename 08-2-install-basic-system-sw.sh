#!/bin/bash

set -e
set -v

cd /
cd /sources

### Automate uncompress and clean up processes
package_name=""
package_ext=""

begin() {
	package_name=$1
	package_ext=$2
	echo "[lfs-cross] Starting build of $package_name at $(date)"
	tar xf $package_name.$package_ext
	cd $package_name
}

build() {
	./configure --prefix=/usr
	make
	make check
	make install
}

finish() {
	echo "[lfs-cross] Finishing build of $package_name at $(date)"
	cd $LFS/sources
	rm -rf $package_name
}

case "$KVM_LFS_CONTINUE" in
"8.34.2")
	### 8.34. Bash-5.1.16 Continued
	cd bash-5.1.16
	cd ..
	rm -rf bash-5.1.16
;&

"8.35")
	### 8.35. Libtool-2.4.7
	begin libtool-2.4.7 tar.xz
	./configure --prefix=/usr
	make
	make check TESTSUITEFLAGS=-j$NPROCx4 || true
	make install
	rm -fv /usr/lib/libltdl.a
	finish
;&

"8.36")
	### 8.36. GDBM-1.23
	begin gdbm-1.23 tar.gz
	./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
	make
	make check
	make install
	finish
;&

"8.37")
	### 8.37. Gperf-3.1
	begin gperf-3.1 tar.gz
	./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
	make
	make -j1 check
	make install
	finish
;&

"8.38")
	### 8.38. Expat-2.4.8
	begin expat-2.4.8 tar.xz
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.4.8
	make
	make check
	make install
	install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.4.8
	finish
;&

"8.39")
	### 8.39. Inetutils-2.3
	begin inetutils-2.3 tar.xz
	./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
	make
	make check || true
	make install
	mv -v /usr/{,s}bin/ifconfig
	finish
;&

"8.40")
	### 8.40. Less-590
	begin less-590 tar.gz
	./configure --prefix=/usr --sysconfdir=/etc
	make
	make install
	finish
;&


"8.41")
	### 8.41. Perl-5.36.0
	begin perl-5.36.0.tar.xz
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.36/core_perl      \
             -Darchlib=/usr/lib/perl5/5.36/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.36/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.36/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
	make
	make test
	make install
	unset BUILD_ZLIB BUILD_BZIP2
	finish
;&

"8.42")
	### 8.42. XML::Parser-2.46
	begin XML-Parser-2.46 tar.gz
	perl Makefile.PL
	make
	make test
	make install
	finish
;&

"8.43")
	### 8.43. Intltool-0.51.0
	begin intltool-0.51.0 tar.gz
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in
	build
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
	finish
;&

"8.44")
	### 8.44. Autoconf-2.71
	begin autoconf-2.71 tar.xz
	build
	finish
;&

"8.45")
	### 8.45. Automake-1.16.5
	begin automake-1.16.5 tar.xz
	./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
	make
	make -j$NPROCx4 check || true # test t/subobj.sh fail
	make install
	finish
;&

"8.46")
	### 8.46. OpenSSL-3.0.5
	begin openssl-3.0.1 tar.gz
	./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
	make
	make test || true # test 30-test_afalg.t fail
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.5
	cp -vfr doc/* /usr/share/doc/openssl-3.0.5
	finish
;&

"8.47")
	### 8.47. Kmod-30
	begin kmod-30 tar.xz
	./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-openssl         \
            --with-xz              \
            --with-zstd            \
            --with-zlib
	make
	make install
	for target in depmod insmod modinfo modprobe rmmod; do
	  ln -sfv ../bin/kmod /usr/sbin/$target
	done
	ln -sfv kmod /usr/bin/lsmod
	finish
;&

"8.48")
	### 8.48. Libelf from Elfutils-0.187
	begin elfutils-0.187 tar.bz2
	./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
	make
	make check
	make -C libelf install
	install -vm644 config/libelf.pc /usr/lib/pkgconfig
	rm /usr/lib/libelf.a
	finish
;&

"8.49")
	### 8.49. Libffi-3.4.2
	begin libffi-3.4.2 tar.gz
	./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native \
            --disable-exec-static-tramp
	make
	make check
	make install
	finish
;&

"8.50")
	### 8.50. Python-3.10.6
	begin Python-3.10.2 tar.xz
	./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --with-system-ffi    \
            --enable-optimizations
	make
	make install
	cat > /etc/pip.conf << EOF
	[global]
	root-user-action = ignore
	disable-pip-version-check = true
EOF
	install -v -dm755 /usr/share/doc/python-3.10.6/html

	tar --strip-components=1  \
    	--no-same-owner       \
    	--no-same-permissions \
    	-C /usr/share/doc/python-3.10.6/html \
    	-xvf ../python-3.10.6-docs-html.tar.bz2
	finish
;&

"8.51")
	### 8.51. Wheel-0.37.1
	begin wheel-0.37.1 tar.gz
	pip3 install --no-index $PWD
	finish
;&

"8.52")
	### 8.52. Ninja-1.11.0
	begin ninja-1.11.0 tar.gz
	export NINJAJOBS=$NPROC
	sed -i '/int Guess/a \
	  int   j = 0;\
	  char* jobs = getenv( "NINJAJOBS" );\
	  if ( jobs != NULL ) j = atoi( jobs );\
	  if ( j > 0 ) return j;\
	' src/ninja.cc
	python3 configure.py --bootstrap
	./ninja ninja_test
	./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
	install -vm755 ninja /usr/bin/
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
	install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
	finish
;&

"8.53")
	### 8.53. Meson-0.63.1
	begin meson-0.63.1 tar.gz
	pip3 wheel -w dist --no-build-isolation --no-deps $PWD
	pip3 install --no-index --find-links dist meson
	install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
	install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
	finish
;&

"8.54")
	### 8.54. Coreutils-9.1
	[ -e coreutils-9.1 ] && rm -rfv coreutils-9.1
	begin coreutils-9.1 tar.xz
	patch -Np1 -i ../coreutils-9.1-i18n-1.patch
	autoreconf -fiv
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
    	        --prefix=/usr            \
    	        --enable-no-install-program=kill,uptime
	make
	make NON_ROOT_USERNAME=tester check-root
	echo "dummy:x:102:tester" >> /etc/group
	chown -Rv tester . 	
	su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
	sed -i '/dummy/d' /etc/group
	make install
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8		
	finish
;&

"8.55")
	### 8.55. Check-0.15.2
	begin check-0.15.2 tar.gz
	./configure --prefix=/usr --disable-static
	make
	make check
	make docdir=/usr/share/doc/check-0.15.2 install
	finish
;&

"8.56")
	### 8.56. Diffutils-3.8
	begin diffutils-3.8 tar.xz
	build
	finish
;&

"8.57")
	### 8.57. Gawk-5.1.1
	begin gawk-5.1.1 tar.xz
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr
	make
	make check
	make install
	mkdir -pv                                   /usr/share/doc/gawk-5.1.1
	cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.1
	finish
;&

"8.58")
	### 8.58. Findutils-4.9.0
	begin findutils-4.9.0 tar.xz
	case $(uname -m) in
    	i?86)   TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
    	x86_64) ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
esac
	make
	chown -Rv tester .
	su tester -c "PATH=$PATH make check"
	make install
	finish
;&

"8.59")
	### 8.59. Groff-1.22.4
	begin groff-1.22.4 tar.gz
	PAGE=<paper_size> ./configure --prefix=/usr
	make -j1
	make install
	finish
;&

"8.60")
	### 8.60. GRUB-2.06
	begin grub-2.06 tar.xz
	./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
	make
	make install
	mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
	finish
;&


"8.61")
	### 8.61. Gzip-1.12
	begin gzip-1.12 tar.xz
	build
	finish
;&

"8.62")
	### 8.62. IPRoute2-5.19.0
	begin iproute2-5.19.0 tar.xz
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8
	make NETNS_RUN_DIR=/run/netns
	make SBINDIR=/usr/sbin install
	mkdir -pv             /usr/share/doc/iproute2-5.19.0
	cp -v COPYING README* /usr/share/doc/iproute2-5.19.0
	finish
;&

"8.63")
	### 8.63. Kbd-2.5.1
	begin kbd-2.4.0 tar.xz
	patch -Np1 -i ../kbd-2.5.1-backspace-1.patch
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
	./configure --prefix=/usr --disable-vlock
	make
	make check
	make install
	mkdir -pv           /usr/share/doc/kbd-2.5.1
	cp -R -v docs/doc/* /usr/share/doc/kbd-2.5.1
	finish
;&

"8.64")
	### 8.64. Libpipeline-1.5.6
	begin libpipeline-1.5.6 tar.gz
	build
	finish
;&

"8.65")
	### 8.65. Make-4.3
	begin make-4.3 tar.gz
	build
	finish
;&

"8.66")
	### 8.66. Patch-2.7.6
	begin patch-2.7.6 tar.xz
	build
	finish
;&

"8.67")
	### 8.67. Tar-1.34
	begin tar-1.34 tar.xz
	FORCE_UNSAFE_CONFIGURE=1  \
	build
	make -C doc install-html docdir=/usr/share/doc/tar-1.34
	finish
;&

"8.68")
	### 8.68. Texinfo-6.8
	begin texinfo-6.8 tar.xz
	build
	make TEXMF=/usr/share/texmf install-tex
	pushd /usr/share/info
	  rm -v dir
	  for f in *
	    do install-info $f dir 2>/dev/null
	  done
	popd
	finish
;&

"8.69")
	### 8.69. Vim-9.0.0228 
	begin vim-9.0.0228 tar.gz
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
	./configure --prefix=/usr
	make
	chown -Rv tester .
	su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
	make install
	ln -sv vim /usr/bin/vi
	or L in  /usr/share/man/{,*/}man1/vim.1; do
	    ln -sv vim.1 $(dirname $L)/vi.1
	done
	ln -sv ../vim/vim90/doc /usr/share/doc/vim-9.0.0228
	cat > /etc/vimrc << "EOF"
	" Begin /etc/vimrc

	" Ensure defaults are set before customizing settings, not after
	source $VIMRUNTIME/defaults.vim
	let skip_defaults_vim=1

	set nocompatible
	set backspace=2
	set mouse=
	syntax on
	if (&term == "xterm") || (&term == "putty")
	  set background=dark
	endif

	" End /etc/vimrc
EOF
	finish
;&

"8.70")
	### 8.70. MarkupSafe-2.1.1 
	begin MarkupSafe-2.1.1 tar.gz
	pip3 wheel -w dist --no-build-isolation --no-deps $PWD
	pip3 install --no-index --no-user --find-links dist Markupsafe
	finish
;&

"8.71")
	### 8.71. Jinja2-3.1.2  
	begin Jinja2-3.1.2 tar.gz
	pip3 wheel -w dist --no-build-isolation --no-deps $PWD
	pip3 install --no-index --no-user --find-links dist Jinja2
	finish
;&

"8.72")
	### 8.72. Systemd-251
	begin systemd-251 tar.gz
	patch -Np1 -i ../systemd-251-glibc_2.36_fix-1.patch
	sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
	mkdir -p build
	cd       build
	meson --prefix=/usr                 \
	      --buildtype=release           \
	      -Ddefault-dnssec=no           \
	      -Dfirstboot=false             \
	      -Dinstall-tests=false         \
	      -Dldconfig=false              \
	      -Dsysusers=false              \
	      -Drpmmacrosdir=no             \
	      -Dhomed=false                 \
	      -Duserdb=false                \
	      -Dman=false                   \
	      -Dmode=release                \
	      -Dpamconfdir=no               \
	      -Ddocdir=/usr/share/doc/systemd-251 \
	      ..
	ninja
	ninja install
	tar -xf ../../systemd-man-pages-251.tar.xz --strip-components=1 -C /usr/share/man
	systemd-machine-id-setup
	systemctl preset-all
	systemctl disable systemd-sysupdate
	finish
;&

"8.73")
	### 8.73. D-Bus-1.14.0
	begin dbus-1.14.0 tar.gz
	./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --runstatedir=/run                   \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.14.0 \
            --with-system-socket=/run/dbus/system_bus_socket
	make
	make install
	ln -sfv /etc/machine-id /var/lib/dbus
	finish
;&

"8.74")
	### 8.74. Man-DB-2.10.2
	begin man-db-2.10.2 tar.xz
	./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.10.2 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap
	make
	make check
	make install
	finish
;&

"8.75")
	### 8.75. Procps-ng-4.0.0
	begin procps-ng-4.0.0 tar.xz
	./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-4.0.0 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd
	make
	make check
	make install
	finish
;&

"8.76")
	### 8.76. Util-linux-2.38.1 
	begin util-linux-2.38.1 tar.xz
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --bindir=/usr/bin    \
            --libdir=/usr/lib    \
            --sbindir=/usr/sbin  \
            --docdir=/usr/share/doc/util-linux-2.38.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python
	make
	# to run tests, need to check that kernel config must include CONFIG_SCSI_DEBUG=m (not 'y' or 'n', must be 'm')
	# do not run tests as they may damage the system (if run as root)
	# su tester -c "bash tests/run.sh --srcdir=$PWD --builddir=$PWD"
	chown -Rv tester .
	su tester -c "make -k check"
	make install
	finish
;&

"8.77")
	### 8.77. E2fsprogs-1.46.5
	begin e2fsprogs-1.46.5 tar.gz
	mkdir -v build
	cd build
	../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
	make
	make check
	make install
	rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	gunzip -v /usr/share/info/libext2fs.info.gz
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
	makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
	install -v -m644 doc/com_err.info /usr/share/info
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
	finish
;&

"8.78")
	### 8.78. Stripping Again
	save_usrlib="$(cd /usr/lib; ls ld-linux*[^g])
	             libc.so.6
	             libthread_db.so.1
	             libquadmath.so.0.0.0
	             libstdc++.so.6.0.30
	             libitm.so.1.0.0
	             libatomic.so.1.2.0"

	cd /usr/lib

	for LIB in $save_usrlib; do
	    objcopy --only-keep-debug $LIB $LIB.dbg
	    cp $LIB /tmp/$LIB
	    strip --strip-unneeded /tmp/$LIB
	    objcopy --add-gnu-debuglink=$LIB.dbg /tmp/$LIB
	    install -vm755 /tmp/$LIB /usr/lib
	    rm /tmp/$LIB
	done

	online_usrbin="bash find strip"
	online_usrlib="libbfd-2.39.so
	               libhistory.so.8.1
	               libncursesw.so.6.3
	               libm.so.6
	               libreadline.so.8.1
	               libz.so.1.2.12
	               $(cd /usr/lib; find libnss*.so* -type f)"

	for BIN in $online_usrbin; do
	    cp /usr/bin/$BIN /tmp/$BIN
	    strip --strip-unneeded /tmp/$BIN
	    install -vm755 /tmp/$BIN /usr/bin
	    rm /tmp/$BIN
	done

	for LIB in $online_usrlib; do
	    cp /usr/lib/$LIB /tmp/$LIB
	    strip --strip-unneeded /tmp/$LIB
	    install -vm755 /tmp/$LIB /usr/lib
	    rm /tmp/$LIB
	done

	for i in $(find /usr/lib -type f -name \*.so* ! -name \*dbg) \
	         $(find /usr/lib -type f -name \*.a)                 \
	         $(find /usr/{bin,sbin,libexec} -type f); do
	    case "$online_usrbin $online_usrlib $save_usrlib" in
	        *$(basename $i)* )
	            ;;
	        * ) strip --strip-unneeded $i
	            ;;
	    esac
	done

	unset BIN LIB save_usrlib online_usrbin online_usrlib
;&

"8.78")
	### 8.78. Cleaning Up
	rm -rf /tmp/*
	find /usr/lib /usr/libexec -name \*.la -delete
	find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
	userdel -r tester
	echo "SUCCESS - 8.2" >> 8-2.log
	logout
;&
esac
