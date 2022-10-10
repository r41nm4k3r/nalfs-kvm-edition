#!/bin/bash

set -e
set -v

source $HOME/.bashrc
env
echo $LFS
cd $LFS/sources

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
"6.2")
	### Chapter 6. Cross Compiling Temporary Tools
	### 6.2. M4-1.4.19
	begin m4-1.4.19 tar.xz
	./configure --prefix=/usr \
				--host=$LFS_TGT \
				--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	finish
;&

"6.3")
	### 6.3 Ncurses-6.3
	begin ncurses-6.3 tar.gz
	sed -i s/mawk// configure
	mkdir build
	pushd build
	../configure
	make -C include
	make -C progs tic
	popd
	./configure --prefix=/usr                \
            	--host=$LFS_TGT              \
            	--build=$(./config.guess)    \
            	--mandir=/usr/share/man      \
            	--with-manpage-format=normal \
            	--with-shared                \
            	--without-normal             \
            	--with-cxx-shared            \
            	--without-debug              \
            	--without-ada                \
            	--disable-stripping          \
            	--enable-widec
	make
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
	finish

"6.4")
	### 6.4 Bash-5.1.16
	begin bash-5.1.16 tar.gz
	./configure --prefix=/usr \
				--build=$(support/config.guess) \
				--host=$LFS_TGT \
				--without-bash-malloc
	make
	make DESTDIR=$LFS install
	ln -sv bash $LFS/bin/sh
	finish
;&

"6.5")
	### 6.5. Coreutils-9.0
	begin coreutils-9.1 tar.xz
	./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
	finish
;&

"6.6")
	### 6.6. Diffutils-3.8
	begin diffutils-3.8 tar.xz
	cd diffutils-3.8
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	finish
;&

"6.7")
	### 6.7. File-5.42
	begin file-5.42 tar.gz
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
	rm -v $LFS/usr/lib/libmagic.la
	finish
;&

"6.8")
	### 6.8. Findutils-4.9.0
	begin findutils-4.9.0 tar.xz
	./configure --prefix=/usr                   \
            	--localstatedir=/var/lib/locate \
            	--host=$LFS_TGT                 \
            	--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	finish
;&
"6.9")
	### 6.9 Gawk-5.1.1
	begin gawk-5.1.1 tar.xz
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	finish
;&

"6.10")
	### 6.10. Grep-3.7
	begin grep-3.7 tar.xz
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	finish
;&

"6.11")
	### 6.11. Gzip-1.12
	begin gzip-1.12 tar.xz
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	finish
;&

"6.12")
	### 6.12. Make-4.3
	begin make-4.3 tar.gz
	./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	finish
;&

"6.13")
	### 6.13. Patch-2.7.6
	begin patch-2.7.6 tar.xz
	./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	finish
;&

"6.14")
	### 6.14. Sed-4.8
	tar -xf sed-4.8.tar.xz
	cd sed-4.8
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	cd ..
	rm -rf sed-4.8
;&

"6.15")
	### 6.15. Tar-1.34
	tar -xf tar-1.34.tar.xz
	cd tar-1.34
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
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
	cd ..
	rm -rf xz-5.2.5
;&

"6.17")
	### 6.17. Binutils-2.38 - Pass 2
	tar -xf binutils-2.38.tar.xz
	cd binutils-2.38
	sed '6009s/$add_dir//' -i ltmain.sh
	mkdir -v build
	cd build
	../configure                   \
    	--prefix=/usr              \
    	--build=$(../config.guess) \
    	--host=$LFS_TGT            \
    	--disable-nls              \
    	--enable-shared            \
    	--disable-werror           \
    	--enable-64-bit-bfd
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
	cd ../..
	rm -rf gcc-11.2.0
	echo "SUCCESS - 6"
;&
esac

