all: clean
	wget -q http://ch1.php.net/get/php-$(php).tar.gz/from/us2.php.net/mirror -O php-$(php).tar.gz
	wget -q http://pecl.php.net/get/uploadprogress-$(uploadprogress).tgz
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/curl-$(curl).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libjpeg-$(libjpeg).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libpng-$(libpng).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/httpd-$(httpd).zip

	tar -xf php-$(php).tar.gz
	tar -xf uploadprogress-$(uploadprogress).tgz
	unzip -q curl-$(curl).zip -d pkg
	unzip -q libjpeg-$(libjpeg).zip -d pkg
	unzip -q libpng-$(libpng).zip -d pkg
	unzip -q httpd-$(httpd).zip -d httpd

	cd php-$(php); \
		./configure --prefix=$(CURDIR)/pkg --with-mysql --with-mysqli --enable-pdo \
		--with-pdo-mysql --with-gd --enable-mbstring --without-pear --disable-cgi \
		--with-png-dir=$(CURDIR)/pkg --with-jpeg-dir=$(CURDIR)/pkg \
		--with-curl=$(CURDIR)/pkg --with-apxs2=$(CURDIR)/httpd/bin/apxs; \
		make; \
		make install; \
		libtool --finish $(CURDIR)/php-$(php)/libs; \
		cp -a libs/* $(CURDIR)/pkg/lib/

	cd uploadprogress-$(uploadprogress); \
		$(CURDIR)/pkg/bin/phpize; \
		./configure --with-php-config=$(CURDIR)/pkg/bin/php-config; \
		make; \
		mkdir -p $(CURDIR)/pkg/modules; \
		cp -a modules/* $(CURDIR)/pkg/modules/

	cd pkg; \
		rm bin/phar; \
		mv bin/phar.phar bin/phar; \
		rm -r php; \
		zip -rqy $(CURDIR)/php-$(php).zip.

clean: 
	rm -rf php* uploadprogress* curl* libjpeg* libpng* httpd* pkg