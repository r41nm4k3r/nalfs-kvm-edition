#!/bin/bash

set -e
set -v

### Chapter 5. Compiling a Cross-Toolchain
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

### Start
case "$KVM_LFS_CONTINUE" in
"5.2")
	### 5.2 Binutils-2.39 - Pass 1
	begin binutils-2.39 tar.xz
	mkdir -v build
	cd build
	../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror
	make
	make install
	finish
;&

"5.3")
	### 5.3. GCC-12.2.0 - Pass 1
	begin gcc-12.2.0 tar.xz
	tar -xf ../mpfr-4.1.0.tar.xz
	mv -v mpfr-4.1.0 mpfr
	tar -xf ../gmp-6.2.1.tar.xz
	mv -v gmp-6.2.1 gmp
	tar -xf ../mpc-1.2.1.tar.gz
	mv -v mpc-1.2.1 mpc
	case $(uname -m) in
  	x86_64)
    	sed -e '/m64=/s/lib64/lib/' \
        	-i.orig gcc/config/i386/t-linux64
	;;
	esac
	mkdir -v build
	cd build
	../configure                  \
    	--target=$LFS_TGT         \
    	--prefix=$LFS/tools       \
    	--with-glibc-version=2.36 \
    	--with-sysroot=$LFS       \
    	--with-newlib             \
    	--without-headers         \
    	--disable-nls             \
    	--disable-shared          \
    	--disable-multilib        \
    	--disable-decimal-float   \
    	--disable-threads         \
    	--disable-libatomic       \
    	--disable-libgomp         \
    	--disable-libquadmath     \
    	--disable-libssp          \
    	--disable-libvtv          \
    	--disable-libstdcxx       \
    	--enable-languages=c,c++
	make
	make install
	cd ..
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  	  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
	finish
;&

"5.4")
	### 5.4. Linux-5.19.2 API Headers
	begin linux-5.19.2 tar.xz
	make mrproper
	make headers
	find usr/include -type f ! -name '*.h' -delete
	cp -rv usr/include $LFS/usr
	finish
;&

"5.5")
	### 5.5. Glibc-2.36
	begin glibc-2.36 tar.xz
	case $(uname -m) in
    	i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    	;;
    	x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            	ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    	;;
	esac
	patch -Np1 -i ../glibc-2.36-fhs-1.patch
	mkdir -v build
	cd build
	echo "rootsbindir=/usr/sbin" > configparms
	../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib
	make
	make DESTDIR=$LFS install
	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
	echo 'int main(){}' | gcc -xc -
	readelf -l a.out | grep ld-linux
	rm -v a.out
	$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
	finish
;&

"5.6")
	### 5.6 Libstdc++ from GCC-11.2.0, Pass 1
	begin gcc-12.2.0 tar.xz
	mkdir -v build
	cd build
	../libstdc++-v3/configure           \
    	--host=$LFS_TGT                 \
    	--build=$(../config.guess)      \
    	--prefix=/usr                   \
    	--disable-multilib              \
    	--disable-nls                   \
    	--disable-libstdcxx-pch         \
    	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0
	make
	make DESTDIR=$LFS install
	rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
	finish
	echo "SUCCESS - 5"
;&
esac
