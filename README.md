# cURL for Android

Compile curl, openssl, zlib with Android NDK.

Support system:
+ Mac OS X
+ Linux 64-bit

## Before build

Download android ndk-r14b from [here](https://developer.android.com/ndk/downloads/),
and set NDK_ROOT in your system environment variable.

For example:

```
export NDK_ROOT=your_ndk_path
```

Install dependent:

```
autoconf >= 2.57
automake >= 1.7
libtool  >= 1.4.2
GNU m4
nroff
perl
```

## version

* curl: curl-7.67.0
* openssl: openssl-1.1.1d

```
chmod 755 build_for_android.sh
./build_for_android.sh
```

## Binary and Library

```
# cURL
jni/build/curl/*/curl
jni/libs/*/libcurl.a
jni/libs/*/libcurl.so

# OpenSSL
jni/build/openssl/*/bin/openssl
jni/build/openssl/*/lib/libssl.a
jni/build/openssl/*/lib/libcrypto.a

