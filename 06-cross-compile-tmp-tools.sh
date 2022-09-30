#!/bin/bash

set -e
set -v

source $HOME/.bashrc
env
echo $LFS
cd $LFS
cd $LFS/sources

case "$KVM_LFS_CONTINUE" in
"6.2")
	### Chapter 6. Cross Compiling Temporary Tools
	### 6.2. M4-1.4.19
	tar -xf m4-1.4.19.tar.xz
	cd m4-1.4.19
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf m4-1.4.19
;&

"6.3")
	### 6.3 Ncurses-6.3
	tar -xf ncurses-6.3.tar.gz
	cd ncurses-6.3
	sed -i s/mawk// configure
	mkdir build
	pushd build
	../configure
	make -C include
	make -C progs tic
	popd
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) \
		--mandir=/usr/share/man --with-manpage-format=normal --with-shared \
		--without-debug --without-ada --without-normal --enable-widec
	make
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
	mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
	ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) \
		$LFS/usr/lib/libncursesw.so
	cd ..
	rm -rf ncurses-6.3
;&

"6.4")
	### 6.4 Bash-5.1.16
	tar -xf bash-5.1.16.tar.gz
	cd bash-5.1.16
	./configure --prefix=/usr --build=$(support/config.guess) --host=$LFS_TGT \
		--without-bash-malloc
	make
	make DESTDIR=$LFS install
	mv $LFS/usr/bin/bash $LFS/bin/bash
	ln -sv bash $LFS/bin/sh
	cd ..
	rm -rf bash-5.1.16
;&

"6.5")
	### 6.5. Coreutils-9.0
	tar -xf coreutils-9.0.tar.xz
	cd coreutils-9.0
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) \
		--enable-install-program=hostname \
		--enable-no-install-program=kill,uptime
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
	mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} $LFS/bin
	mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname} $LFS/bin
	mv -v $LFS/usr/bin/{head,nice,sleep,touch} $LFS/bin
	mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
	cd ..
	rm -rf coreutils-9.0
;&

"6.6")
	### 6.6. Diffutils-3.8
	tar -xf diffutils-3.8.tar.xz
	cd diffutils-3.8
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf diffutils-3.8
;&

"6.7")
	### 6.7. File-5.41
	tar -xf file-5.41.tar.gz
	cd file-5.41
	mkdir build
	pushd build
  	  ../configure --disable-bzlib      \
      		       --disable-libseccomp \
                   --disable-xzlib      \
                   --disable-zlib
      make
    popd
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
	make FILE_COMPILE=$(pwd)/build/src/file
	make DESTDIR=$LFS install
	cd ..
	rm -rf file-5.41
;&

"6.8")
	### 6.8. Findutils-4.9.0
	tar -xf findutils-4.9.0.tar.xz
	cd findutils-4.9.0
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/find $LFS/bin
	sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
	cd ..
	rm -rf findutils-4.9.0
;&

"6.9")
	### 6.9 Gawk-5.1.1
	tar -xf gawk-5.1.1.tar.xz
	cd gawk-5.1.1
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf gawk-5.1.1
;&

"6.10")
	### 6.10. Grep-3.7
	tar -xf grep-3.7.tar.xz
	cd grep-3.7
	./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf grep-3.7
;&

"6.11")
	### 6.11. Gzip-1.11
	tar -xf gzip-1.11.tar.xz
	cd gzip-1.11
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/gzip $LFS/bin
	cd ..
	rm -rf gzip-1.11
;&

"6.12")
	### 6.12. Make-4.3
	tar -xf make-4.3.tar.gz
	cd make-4.3
	./configure --prefix=/usr --without-guile --host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf make-4.3
;&

"6.13")
	### 6.13. Patch-2.7.6
	tar -xf patch-2.7.6.tar.xz
	cd patch-2.7.6
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf patch-2.7.6
;&

"6.14")
	### 6.14. Sed-4.8
	tar -xf sed-4.8.tar.xz
	cd sed-4.8
	./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf sed-4.8
;&

"6.15")
	### 6.15. Tar-1.34
	tar -xf tar-1.34.tar.xz
	cd tar-1.34
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) \
		--bindir=/bin
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf tar-1.34
;&

"6.16")
	### 6.16. Xz-5.2.5
	tar -xf xz-5.2.5.tar.xz
	cd xz-5.2.5
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) \
		--disable-static --docdir=/usr/share/doc/xz-5.2.5
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} $LFS/bin
	mv -v $LFS/usr/lib/liblzma.so.* $LFS/lib
	ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
	cd ..
	rm -rf xz-5.2.5
;&

"6.17")
	### 6.17. Binutils-2.38 - Pass 2
	tar -xf binutils-2.38.tar.xz
	cd binutils-2.38
	mkdir -v build
	cd build
	../configure --prefix=/usr --build=$(../config.guess) --host=$LFS_TGT \
		--disable-nls --enable-shared --disable-werror --enable-64-bit-bfd
	make
	make DESTDIR=$LFS install
	cd ../..
	rm -rf binutils-2.38
;&

"6.18")
	### 6.18. GCC-11.2.0 - Pass 2
	rm -rf gcc-11.2.0
	tar -xf gcc-11.2.0.tar.xz
	cd gcc-11.2.0
	tar -xf ../mpfr-4.1.0.tar.xz
	mv -v mpfr-4.1.0 mpfr
	tar -xf ../gmp-6.2.1.tar.xz
	mv -v gmp-6.2.1 gmp
	tar -xf ../mpc-1.2.1.tar.gz
	mv -v mpc-1.2.1 mpc
	case $(uname -m) in
	  		x86_64)
    				sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  	  				;;
	esac
	mkdir -v build
	cd build
	mkdir -pv $LFS_TGT/libgcc
	ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
	../configure                                       \
    	--build=$(../config.guess)                     \
    	--host=$LFS_TGT                                \
    	--prefix=/usr                                  \
    	CC_FOR_TARGET=$LFS_TGT-gcc                     \
    	--with-build-sysroot=$LFS                      \
    	--enable-initfini-array                        \
    	--disable-nls                                  \
    	--disable-multilib                             \
    	--disable-decimal-float                        \
    	--disable-libatomic                            \
    	--disable-libgomp                              \
    	--disable-libquadmath                          \
    	--disable-libssp                               \
    	--disable-libvtv                               \
    	--disable-libstdcxx                            \
    	--enable-languages=c,c++
	make
	make DESTDIR=$LFS install
	ln -sv gcc $LFS/usr/bin/cc
#	ln -sv ../lib64/libgcc_s.so $LFS/usr/lib/libgcc_s.so
#	ln -sv ../lib64/libgcc_s.so.1 $LFS/usr/lib/libgcc_s.so.1
	cd ../..
	rm -rf gcc-11.2.0
	echo "SUCCESS - 6"
;&
esac
