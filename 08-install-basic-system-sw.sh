#!/bin/bash

set -e
set -v

cd /
cd /sources

case "$KVM_LFS_CONTINUE" in
"8.3")
	### 8.3. Man-pages-5.1.163
	tar -xf man-pages-5.13.tar.xz
	cd man-pages-5.13
	make install
	cd ..
	rm -rf man-pages-5.13
;&

"8.4")
	### 8.4. Tcl-8.6.12
	tar -xf tcl8.6.12-src.tar.gz
	cd tcl8.6.12
	tar -xf ../tcl8.6.12-html.tar.gz --strip-components=1
	SRCDIR=$(pwd)
	cd unix/
	./configure --prefix=/usr --mandir=/usr/share/man \
		$([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
	make

	sed -e "s|$SRCDIR/unix|/usr/lib|" \
	    -e "s|$SRCDIR|/usr/include|"  \
	    -i tclConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|/usr/lib/tdbc1.1.3|" \
	    -e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|/usr/include|"    \
	    -e "s|$SRCDIR/pkgs/tdbc1.1.3/library|/usr/lib/tcl8.6|" \
	    -e "s|$SRCDIR/pkgs/tdbc1.1.3|/usr/include|"            \
	    -i pkgs/tdbc1.1.3/tdbcConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|/usr/lib/itcl4.2.2|" \
	    -e "s|$SRCDIR/pkgs/itcl4.2.2/generic|/usr/include|"    \
	    -e "s|$SRCDIR/pkgs/itcl4.2.2|/usr/include|"            \
	    -i pkgs/itcl4.2.2/itclConfig.sh
	unset SRCDIR
	make test
	make install
	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
	mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
	cd ../..
	rm -rf tcl8.6.12
;&

"8.5")
	### 8.5. Expect-5.45.4
	tar -xf expect5.45.4.tar.gz
	cd expect5.45.4
	./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
	make
	make test
	make install
	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
	cd ..
	rm -rf expect5.45.4
;&

"8.6")
	### 8.6. DejaGNU-1.6.3
	tar -xf dejagnu-1.6.3.tar.gz
	cd dejagnu-1.6.3
	mkdir -v build
	cd build
	../configure --prefix=/usr
	makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
	makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
	make install
	install -v -dm755  /usr/share/doc/dejagnu-1.6.3
	install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
	make check
	cd ..
	rm -rf dejagnu-1.6.3
;&

"8.7")
	### 8.7. Iana-Etc-20220207
	tar -xf iana-etc-20220207.tar.gz
	cd iana-etc-20220207
	cp services protocols /etc
	cd ..
	rm -rf iana-etc-20220207
;&

"8.8")
	### 8.8. Glibc-2.35
	tar -xf glibc-2.35.tar.xz
	cd glibc-2.35
	patch -Np1 -i ../glibc-2.35-fhs-1.patch
	mkdir -v build
	cd build
	echo "rootsbindir=/usr/sbin" > configparms
	../configure --prefix=/usr                            \
		     --disable-werror                         \
        	     --enable-kernel=3.2                      \
            	     --enable-stack-protector=strong          \
            	     --with-headers=/usr/include              \
            	     libc_cv_slibdir=/usr/lib
	make
	make check || true
	touch /etc/ld.so.conf
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
	make install
	sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
	cp -v ../nscd/nscd.conf /etc/nscd.conf
	mkdir -pv /var/cache/nscd
	if [ "$KVM_LFS_INIT" == "systemd" ]; then
		install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
		install -v -Dm644 ../nscd/nscd.service /usr/lib/systemd/system/nscd.service
	fi
	mkdir -pv /usr/lib/locale
	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i el_GR -f ISO-8859-7 el_GR
	localedef -i en_GB -f ISO-8859-1 en_GB
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_ES -f ISO-8859-15 es_ES@euro
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i is_IS -f ISO-8859-1 is_IS
	localedef -i is_IS -f UTF-8 is_IS.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f ISO-8859-15 it_IT@euro
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
	localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
	localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i se_NO -f UTF-8 se_NO.UTF-8
	localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
	localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
	localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
	make localedata/install-locales
	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
	localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
	cat > /etc/nsswitch.conf << "EOF"
	# Begin /etc/nsswitch.conf
	
	passwd: files
	group: files
	shadow: files
	
	hosts: files dns
	networks: files
	
	protocols: files
	services: files
	ethers: files
	rpc: files
	
	# End /etc/nsswitch.conf
EOF
	
	tar -xf ../../tzdata2021e.tar.gz
	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}
	for tz in etcetera southamerica northamerica europe africa antarctica  \
	          asia australasia backward; do
	    zic -L /dev/null   -d $ZONEINFO       ${tz}
	    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
	    zic -L leapseconds -d $ZONEINFO/right ${tz}
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p Europe/Athens
	unset ZONEINFO
	ln -sfv /usr/share/zoneinfo/Europe/Athens /etc/localtime
	cat > /etc/ld.so.conf << "EOF"
	# Begin /etc/ld.so.conf
	/usr/local/lib
	/opt/lib
EOF
	cat >> /etc/ld.so.conf << "EOF"
	# Add an include directory
	include /etc/ld.so.conf.d/*.conf

EOF
	mkdir -pv /etc/ld.so.conf.d
	cd ../..
	rm -rf glibc-2.35
	cat >> glibc.log << "EOF"
	finaly installed correctly
EOF

;&

"8.9")
	### 8.9. Zlib-1.2.11
	tar -xf zlib-1.2.11.tar.xz
	cd zlib-1.2.11
	./configure --prefix=/usr
	make
	make check
	make install
	rm -fv /usr/lib/libz.a
	cd ..
	rm -rf zlib-1.2.11
;&

"8.10")
	### 8.10. Bzip2-1.0.8
	tar -xf bzip2-1.0.8.tar.gz
	cd bzip2-1.0.8
	patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	make -f Makefile-libbz2_so
	make clean
	make
	make PREFIX=/usr install
	cp -av libbz2.so.* /usr/lib
	ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
	cp -v bzip2-shared /usr/bin/bzip2
	for i in /usr/bin/{bzcat,bunzip2}; do
  	  ln -sfv bzip2 $i
	done
	rm -fv /usr/lib/libbz2.a
	cd ..
	rm -rf bzip2-1.0.8
;&

"8.11")
	### 8.11. Xz-5.2.5
	tar -xf xz-5.2.5.tar.xz
	cd xz-5.2.5
	./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/xz-5.2.5
	make
	make check
	make install
	cd ..
	rm -rf xz-5.2.5
;&

"8.12")
	### 8.12. Zstd-1.5.2
	tar -xf zstd-1.5.2.tar.gz
	cd zstd-1.5.2
	make
	make prefix=/usr install
	rm -v /usr/lib/libzstd.a
	cd ..
	rm -rf zstd-1.5.2
;&

"8.13")
	### 8.13. File-5.41
	tar -xf file-5.41.tar.gz
	cd file-5.41
	./configure --prefix=/usr
	make
	make check
	make install
	cd ..
	rm -rf file-5.41
;&

"8.14")
	### 8.14. Readline-8.1.2
	tar -xf readline-8.1.2.tar.gz
	cd readline-8.1.2
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr --disable-static --with-curses \
		--docdir=/usr/share/doc/readline-8.1.2
	make SHLIB_LIBS="-lncursesw"
	make SHLIB_LIBS="-lncursesw" install
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1.2
	cd ..
	rm -rf readline-8.1.2
;&

"8.15")
	### 8.15. M4-1.4.19
	tar -xf m4-1.4.19.tar.xz
	cd m4-1.4.19
	./configure --prefix=/usr
	make
	make check
	make install
	cd ..
	rm -rf m4-1.4.19
;&

"8.16")
	### 8.16. Bc-5.2.2
	tar -xf bc-5.2.2.tar.xz
	cd bc-5.2.2
	CC=gcc ./configure --prefix=/usr -G -O3
	make
	make test
	make install
	cd ..
	rm -rf bc-5.2.2
;&

"8.17")
	### 8.17. Flex-2.6.4
	tar -xf flex-2.6.4.tar.gz
	cd flex-2.6.4
	./configure --prefix=/usr \
		    --docdir=/usr/share/doc/flex-2.6.4 \
		    --disable-static
	make
	make check
	make install
	ln -sv flex /usr/bin/lex
	cd ..
	rm -rf flex-2.6.4
;&

"8.18")
	### 8.18. Binutils-2.38
	tar -xf binutils-2.38.tar.xz
	cd binutils-2.38
	expect -c "spawn ls" | grep -F 'spawn ls'
	sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
	mkdir -v build
	cd build
	../configure --prefix=/usr --enable-gold --enable-ld=default --enable-plugins \
		--enable-shared --disable-werror --enable-64-bit-bfd --with-system-zlib
	make tooldir=/usr
	make -k check
	make tooldir=/usr install
	cd ../..
	rm -rf binutils-2.38
;&

"8.19")
	### 8.19. GMP-6.2.1
	tar -xf gmp-6.2.1.tar.xz
	cd gmp-6.2.1
	cp -v configfsf.guess config.guess
	cp -v configfsf.sub config.sub
	./configure --prefix=/usr --enable-cxx --disable-static \
		--docdir=/usr/share/doc/gmp-6.2.1
	make
	make html
	make check 2>&1 | tee gmp-check-log
	awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log | grep -F '197'
	make install
	make install-html
	cd ..
	rm -rf gmp-6.2.1
;&

"8.20")
	### 8.20. MPFR-4.1.0
	tar -xf mpfr-4.1.0.tar.xz
	cd mpfr-4.1.0
	./configure --prefix=/usr --disable-static --enable-thread-safe \
		--docdir=/usr/share/doc/mpfr-4.1.0
	make
	make html
	make check
	make install
	make install-html
	cd ..
	rm -rf mpfr-4.1.0
;&

"8.21")
	### 8.21. MPC-1.2.1
	tar -xf mpc-1.2.1.tar.gz
	cd mpc-1.2.1
	./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/mpc-1.1.0
	make
	make html
	make check
	make install
	make install-html
	cd ..
	rm -rf mpc-1.2.1
;&

"8.22")
	### 8.22. Attr-2.5.1
	tar -xf attr-2.5.1.tar.gz
	cd attr-2.5.1
	if [ "$KVM_LFS_INIT" == "sysvinit" ]; then
		KVM_LFS_ATTR_CONFIGURE_BINDIR_ARG="--bindir=/bin"
	fi
	./configure --prefix=/usr $KVM_LFS_ATTR_CONFIGURE_BINDIR_ARG --disable-static \
		--sysconfdir=/etc --docdir=/usr/share/doc/attr-2.5.1
	make
	make check
	make install
	cd ..
	rm -rf attr-2.5.1
;&

"8.23")
	### 8.23. Acl-2.3.1
	tar -xf acl-2.3.1.tar.xz
	cd acl-2.3.1
	if [ "$KVM_LFS_INIT" == "sysvinit" ]; then
		KVM_LFS_ACL_CONFIGURE_BINDIR_ARG="--bindir=/bin"
	fi
	./configure --prefix=/usr $KVM_LFS_ACL_CONFIGURE_BINDIR_ARG --disable-static \
		    --docdir=/usr/share/doc/acl-2.3.1
	make
	make install
	cd ..
	rm -rf acl-2.3.1
;&

"8.24")
	### 8.24 Libcap-2.63
	tar -xf libcap-2.63.tar.xz
	cd libcap-2.63
	sed -i '/install -m.*STA/d' libcap/Makefile
	make prefix=/usr lib=lib
	make test
	make prefix=/usr lib=lib install
	cd ..
	rm -rf libcap-2.63
;&

"8.25")
	### 8.25 Shadow-4.11.1
	tar -xf shadow-4.11.1.tar.xz
	cd shadow-4.11.1
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	touch /usr/bin/passwd
	./configure --sysconfdir=/etc \
        	    --disable-static  \
       		    --with-group-name-max-length=32
	make
	make exec_prefix=/usr install
	make -C man install-man
	pwconv
	grpconv
	mkdir -p /etc/default
	useradd -D --gid 999
	sed -i '/MAIL/s/yes/no/' /etc/default/useradd
	echo "root:root" | chpasswd
	cd ..
	rm -rf shadow-4.11.1
;&

"8.26")
	### 8.26. GCC-11.2.0
	tar -xf gcc-11.2.0.tar.xz
	cd gcc-11.2.0
	sed -e '/static.*SIGSTKSZ/d' \
    	    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
    	    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
			;;
	esac
	[ -e build ] && rm -r build
	mkdir -v build
	cd build
	../configure --prefix=/usr \
		     LD=ld \
		     --enable-languages=c,c++ \
		     --disable-multilib \
		     --disable-bootstrap \
		     --with-system-zlib
	make
	ulimit -s 32768
	chown -Rv tester .
	su tester -c "PATH=$PATH make -k check" || true
	../contrib/test_summary
	make install
	rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/
	chown -v -R root:root /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
	ln -svr ../usr/bin/cpp /lib
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	cd ../..
	rm -rf gcc-11.2.0
;&

"8.27")
	### 8.27. Pkg-config-0.29.2
	tar -xf pkg-config-0.29.2.tar.gz
	cd pkg-config-0.29.2
	./configure --prefix=/usr --with-internal-glib --disable-host-tool \
		--docdir=/usr/share/doc/pkg-config-0.29.2
	make
	make check
	make install
	cd ..
	rm -rf pkg-config-0.29.2
;&

"8.28")
	### 8.28. Ncurses-6.3
	tar -xf ncurses-6.3.tar.gz
	cd ncurses-6.3
	./configure --prefix=/usr \
				--mandir=/usr/share/man \
				--with-shared \
				--without-debug \
				--without-normal \
				--enable-pc-files \
				--enable-widec \
				--with-pkg-config-libdir=/usr/lib/pkgconfig
	make
	make DESTDIR=$PWD/dest install
	install -vm755 dest/usr/lib/libncursesw.so.6.3 /usr/lib
	rm -v  dest/usr/lib/{libncursesw.so.6.3,libncurses++w.a}
	cp -av dest/* /
	for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
	done
	rm -vf                     /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so      /usr/lib/libcurses.so
	cd ..
	rm -rf ncurses-6.3
;&

"8.29")
	### 8.29. Sed-4.8
	tar -xf sed-4.8.tar.xz
	cd sed-4.8
	./configure --prefix=/usr
	make
	make html
	chown -Rv tester .
	su tester -c "PATH=$PATH make check"
	make install
	install -d -m755 /usr/share/doc/sed-4.8
	install -m644 doc/sed.html /usr/share/doc/sed-4.8
	cd ..
	rm -rf sed-4.8
;&

"8.30")
	### 8.30. Psmisc-23.7
	tar -xf psmisc-23.7.tar.xz
	cd psmisc-23.7
	./configure --prefix=/usr
	make
	make install
	cd ..
	rm -rf psmisc-23.7
;&

"8.31")
	### 8.31.Gettext-0.21
	tar -xf gettext-0.21.tar.xz
	cd gettext-0.21
	./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/gettext-0.21
	make
	make check
	make install
	chmod -v 0755 /usr/lib/preloadable_libintl.so
	cd ..
	rm -rf gettext-0.21
;&

"8.32")
	### 8.32. Bison-3.8.2
	tar -xf bison-3.8.2.tar.xz
	cd bison-3.8.2
	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
	make
	make check || make check
	make install
	cd ..
	rm -rf bison-3.8.2
;&

"8.33")
	### 8.33. Grep-3.7
	tar -xf grep-3.7.tar.xz
	cd grep-3.7
	./configure --prefix=/usr
	make
	make check
	make install
	cd ..
	rm -rf grep-3.7
;&

"8.34")
	### 8.34. Bash-5.1.16
	tar -xf bash-5.1.16.tar.gz
	cd bash-5.1.16
	patch -Np1 -i ../bash-5.1.16-upstream_fixes-1.patch
	./configure --prefix=/usr --docdir=/usr/share/doc/bash-5.1.16 \
		--without-bash-malloc --with-installed-readline
	make
	chown -Rv tester .
	su -s /usr/bin/expect tester << EOF
		set timeout -1
		spawn make tests
		expect eof
		lassign [wait] _ _ _ value
		exit $value
EOF
	make install
	exec /usr/bin/bash --login
	echo "SUCCESS - 8.1"
	exit
;&
esac

