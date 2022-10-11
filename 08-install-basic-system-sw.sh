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

finish() {
	echo "[lfs-cross] Finishing build of $package_name at $(date)"

	cd $LFS/sources
	rm -rf $package_name
}

case "$KVM_LFS_CONTINUE" in
"8.3")
	### 8.3. Man-pages-5.13
	begin man-pages-5.13 tar.xz
	make prefix=/usr install
	finish
;&

"8.4")
	### 8.4. Iana-Etc-20220812
	begin iana-etc-20220812 tar.gz
	cp services protocols /etc
	finish
;&

"8.5")
	### 8.5. Glibc-2.36
	begin glibc-2.36 tar.xz
	patch -Np1 -i ../glibc-2.36-fhs-1.patch
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
	
	tar -xf ../../tzdata2022c.tar.gz
	ZONEINFO=/usr/share/zoneinfo
	mkdir -pv $ZONEINFO/{posix,right}
	for tz in etcetera southamerica northamerica europe africa antarctica  \
	          asia australasia backward; do
	    zic -L /dev/null   -d $ZONEINFO       ${tz}
	    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
	    zic -L leapseconds -d $ZONEINFO/right ${tz}
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p America/New_York
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
	finish
	cat >> glibc.log << "EOF"
	glibc installed correctly
EOF
;&

"8.6")
	### 8.6. Zlib-1.2.12
	begin zlib-1.2.12 tar.xz
	./configure --prefix=/usr
	make
	make check
	make install
	rm -fv /usr/lib/libz.a
	finish
;&

"8.7")
	### 8.7. Bzip2-1.0.8
	begin bzip2-1.0.8 tar.gz
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
	finish
;&

"8.8")
	### 8.8. Xz-5.2.6
	begin xz-5.2.6 tar.xz
	./configure --prefix=/usr \
				--disable-static \
				--docdir=/usr/share/doc/xz-5.2.6
	make
	make check
	make install
	finish
;&

"8.9")
	### 8.9. Zstd-1.5.2
	begin zstd-1.5.2 tar.gz
	patch -Np1 -i ../zstd-1.5.2-upstream_fixes-1.patch
	make prefix=/usr
	make check
	make prefix=/usr install
	rm -v /usr/lib/libzstd.a
	finish
;&

"8.10")
	### 8.10. File-5.42
	begin file-5.42 tar.gz
	./configure --prefix=/usr
	make
	make check
	make install
	finish
;&

"8.11")
	### 8.11. Readline-8.1.2
	begin readline-8.1.2 tar.gz
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.1.2
	make SHLIB_LIBS="-lncursesw"
	make SHLIB_LIBS="-lncursesw" install
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1.2
	finish
;&

"8.12")
	### 8.12. M4-1.4.19
	begin m4-1.4.19 tar.xz
	./configure --prefix=/usr
	make
	make check
	make install
	finish
;&

"8.13")
	### 8.13. Bc-6.0.1
	begin bc-6.0.1 tar.xz
	CC=gcc ./configure --prefix=/usr -G -O3 -r
	make
	make test
	make install
	finish
;&

"8.14")
	### 8.14. Flex-2.6.4
	begin flex-2.6.4.tar.gz
	./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
	make
	make check
	make install
	ln -sv flex /usr/bin/lex
	finish
;&

"8.15")
	### 8.15. Tcl-8.6.12
	begin tcl8.6.12-src tar.gz
	tar -xf ../tcl8.6.12-html.tar.gz --strip-components=1
	SRCDIR=$(pwd)
	cd unix
	./configure --prefix=/usr           \
	            --mandir=/usr/share/man
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
	mkdir -v -p /usr/share/doc/tcl-8.6.12
	cp -v -r  ../html/* /usr/share/doc/tcl-8.6.12
	finish
;&

"8.16")
	### 8.16. Expect-5.45.4
	begin expect5.45.4 tar.gz
	./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
	make
	make test
	make install
	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
	finish
;&

"8.17")
	### 8.17. DejaGNU-1.6.3
	begin dejagnu-1.6.3 tar.gz
	mkdir -v build
	cd build
	../configure --prefix=/usr
	makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
	makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
	make install
	install -v -dm755  /usr/share/doc/dejagnu-1.6.3
	install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
	make check
	finish
;&

"8.18")
	### 8.18. Binutils-2.39
	begin binutils-2.39 tar.xz
	expect -c "spawn ls"
	spawn ls
	sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
	mkdir -v build
	cd build
	../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
	make tooldir=/usr
	make -k check
	make tooldir=/usr install
	rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
	finish
;&

"8.19")
	### 8.19. GMP-6.2.1
	begin gmp-6.2.1 tar.xz
	./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1
	make
	make html
	make check 2>&1 | tee gmp-check-log
	awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
	make install
	make install-html
	finish
;&

"8.20")
	### 8.20. MPFR-4.1.0
	begin mpfr-4.1.0 tar.xz
	./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
	make
	make html
	make check
	make install
	make install-html
	finish
;&

"8.21")
	### 8.21. MPC-1.2.1
	begin mpc-1.2.1 tar.gz
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1
	make
	make html
	make check
	make install
	make install-html
	finish
;&

"8.22")
	### 8.22. Attr-2.5.1
	begin attr-2.5.1 tar.gz
	./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.1
	make
	make check
	make install
	finish
;&

"8.23")
	### 8.23. Acl-2.3.1
	begin acl-2.3.1 tar.xz
	./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.1
	make
	make install
	finish
;&

"8.24")
	### 8.24 Libcap-2.65
	begin libcap-2.65 tar.xz
	sed -i '/install -m.*STA/d' libcap/Makefile
	make prefix=/usr lib=lib
	make test
	make prefix=/usr lib=lib install
	finish
;&

"8.25")
	### 8.25 Shadow-4.12.2
	begin shadow-4.12.2 tar.xz
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
	finish
;&

"8.26")
	### 8.26. GCC-12.2.0
	tar -xf gcc-12.2.0 tar.xz
	case $(uname -m) in
	  x86_64)
	    sed -e '/m64=/s/lib64/lib/' \
	        -i.orig gcc/config/i386/t-linux64
	  ;;
	esac
	[ -e build ] && rm -r build
	mkdir -v build
	cd build
	../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
	make
	ulimit -s 32768
	chown -Rv tester .
	su tester -c "PATH=$PATH make -k check" || true
	../contrib/test_summary
	make install
	chown -v -R root:root \
    	/usr/lib/gcc/$(gcc -dumpmachine)/12.2.0/include{,-fixed}
	ln -svr ../usr/bin/cpp /lib
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/12.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'
	### TODO grep
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	finish
;&

"8.27")
	### 8.27. Pkg-config-0.29.2
	begin pkg-config-0.29.2 tar.gz
	./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2
	make
	make check
	make install
	finish
;&

"8.28")
	### 8.28. Ncurses-6.3
	begin ncurses-6.3 tar.gz
	./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
	make
	make DESTDIR=$PWD/dest install
	install -vm755 dest/usr/lib/libncursesw.so.6.3 /usr/lib
	rm -v  dest/usr/lib/libncursesw.so.6.3
	cp -av dest/* /
	for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
	done
	rm -vf                     /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so      /usr/lib/libcurses.so
	mkdir -pv      /usr/share/doc/ncurses-6.3
	cp -v -R doc/* /usr/share/doc/ncurses-6.3
;&

"8.29")
	### 8.29. Sed-4.8
	begin sed-4.8 tar.xz
	./configure --prefix=/usr
	make
	make html
	chown -Rv tester .
	su tester -c "PATH=$PATH make check"
	make install
	install -d -m755           /usr/share/doc/sed-4.8
	install -m644 doc/sed.html /usr/share/doc/sed-4.8
	finish
;&

"8.30")
	### 8.30. Psmisc-23.5
	begin psmisc-23.5 tar.xz
	./configure --prefix=/usr
	make
	make install
	finish
;&

"8.31")
	### 8.31.Gettext-0.21
	begin gettext-0.21 tar.xz
	./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21
	make
	make check
	make install
	chmod -v 0755 /usr/lib/preloadable_libintl.so
	finish
;&

"8.32")
	### 8.32. Bison-3.8.2
	begin bison-3.8.2 tar.xz
	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
	make
	make check || make check
	make install
	finish
;&

"8.33")
	### 8.33. Grep-3.7
	begin grep-3.7 tar.xz
	./configure --prefix=/usr
	make
	make check
	make install
	finish
;&

"8.34")
	### 8.34. Bash-5.1.16
	begin bash-5.1.16 tar.gz
	./configure --prefix=/usr                      \
            --docdir=/usr/share/doc/bash-5.1.16 \
            --without-bash-malloc              \
            --with-installed-readline
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
