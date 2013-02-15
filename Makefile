all: clean
	wget -q http://ch1.php.net/get/php-$(version).tar.gz/from/us2.php.net/mirror -O php-$(php-version).tar.gz
	wget -q http://pecl.php.net/get/uploadprogress-$(uploadprogress-version).tgz
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/curl-$(curl-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libjpeg-$(libjpeg-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libpng-$(libpng-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/httpd-$(httpd-version).zip

	tar -xf php-$(version).tar.gz
	tar -xf uploadprogress-$(uploadprogress-version).tgz
	unzip -q curl-$(curl-version).zip -d pkg
	unzip -q libjpeg-$(libjpeg-version).zip -d pkg
	unzip -q libpng-$(libpng-version).zip -d pkg
	unzip -q httpd-$(httpd-version).zip -d httpd

	cd php-$(version); \
		./configure --prefix=$(CURDIR)/pkg --with-mysql --with-mysqli --enable-pdo \
		--with-pdo-mysql --with-gd --enable-mbstring --without-pear --disable-cgi \
		--with-png-dir=$(CURDIR)/pkg --with-jpeg-dir=$(CURDIR)/pkg \
		--with-curl=$(CURDIR)/pkg --with-apxs2=$(CURDIR)/httpd/bin/apxs; \
		make; \
		make install; \
		libtool --finish $(CURDIR)/php-$(php-version)/libs; \
		cp -a libs/* $(CURDIR)/pkg/lib/

	cd uploadprogress-$(uploadprogress-version); \
		$(CURDIR)/pkg/bin/phpize; \
		./configure --with-php-config=$(CURDIR)/pkg/bin/php-config; \
		make; \
		mkdir -p $(CURDIR)/pkg/modules; \
		cp -a modules/* $(CURDIR)/pkg/modules/

	cd pkg; \
		rm bin/phar; \
		mv bin/phar.phar bin/phar; \
		rm -r php; \
		zip -rqy $(CURDIR)/php-$(php-version).zip.

clean: 
	rm -rf php* uploadprogress* curl* libjpeg* libpng* httpd* pkg