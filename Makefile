php-version = 5.4.10
uploadprogress-version = 1.0.3.1
curl-version = 7.28.1
libjpeg-version = 1.2.1
libpng-version = 1.5.13
mysql-c-version = 6.0.2


all: clean
	wget -q http://ch1.php.net/get/php-5.4.10.tar.gz/from/us2.php.net/mirror -O php-$(php-version).tar.gz
	wget -q http://pecl.php.net/get/uploadprogress-$(uploadprogress-version).tgz
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/curl-$(curl-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libjpeg-$(libjpeg-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libpng-$(libpng-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/mysql-c-$(mysql-c-version).zip

	tar -xf php-$(php-version).tar.gz
	tar -xf uploadprogress-$(uploadprogress-version).tgz
	unzip -q curl-$(curl-version).zip -d pkg
	unzip -q libjpeg-$(libjpeg-version).zip -d pkg
	unzip -q libpng-$(libpng-version).zip -d pkg
	unzip -q mysql-c-$(mysql-c-version).zip -d pkg

	cd php-$(php-version); \
		./configure --prefix=$(CURDIR)/pkg --with-mysql --with-mysqli --enable-pdo \
		--with-pdo-sqlite --with-pdo-mysql --with-gd --enable-mbstring --enable-cgi \
		--enable-fpm --with-png-dir=$(CURDIR)/pkg --with-jpeg-dir=$(CURDIR)/pkg \
		--with-curl=$(CURDIR)/pkg; \
		make; \
		make install; \
		libtool --finish $(CURDIR)/php-$(php-version)/libs; \
		cp libs/* $(CURDIR)/pkg/lib/
  
	export PATH=$(CURDIR)/build/php:$PATH
	export LD_LIBRARY_PATH=$(CURDIR)/build/php

	cd uploadprogress-$(uploadprogress-version); \
		phpize; \
		./configure; \
		make; \
		cp -a modules/* $(CURDIR)/pkg/modules/

	cd pkg; \
		zip -r $(CURDIR)/php-$(php-version).zip .

clean: 
	rm -rf php* uploadprogress* curl* libjpeg* libpng* mysql* pkg