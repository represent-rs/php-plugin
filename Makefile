version = 5.4.11
uploadprogress-version = 1.0.3.1
curl-version = 7.28.1
libjpeg-version = 1.2.1
libpng-version = 1.5.14
mysql-version = 5.5.29
msmtp-verison = 1.4.30
httpd-version = 2.4.3

all: clean
	wget -q http://ch1.php.net/get/php-$(version).tar.gz/from/us2.php.net/mirror -O php-$(version).tar.gz
	wget -q http://pecl.php.net/get/uploadprogress-$(uploadprogress-version).tgz
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/curl-$(curl-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libjpeg-$(libjpeg-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/libpng-$(libpng-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/mysql-$(mysql-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/msmtp-$(msmtp-version).zip
	wget -q http://cloudbees-clickstack.s3.amazonaws.com/jenkins/lib/httpd-$(httpd-version).zip

	tar -xf php-$(version).tar.gz
	tar -xf uploadprogress-$(uploadprogress-version).tgz
	unzip -q curl-$(curl-version).zip -d pkg
	unzip -q libjpeg-$(libjpeg-version).zip -d pkg
	unzip -q libpng-$(libpng-version).zip -d pkg
	unzip -q mysql-$(mysql-version).zip -d pkg
	unzip -q msmtp-$(msmtp-version).zip -d pkg
	unzip -q httpd-$(httpd-version).zip -d httpd

	cd php-$(version); \
		./configure --prefix=$(CURDIR)/pkg --with-mysql --with-mysqli --enable-pdo \
		--with-pdo-mysql --with-gd --enable-mbstring --without-pear --disable-cgi \
		--with-png-dir=$(CURDIR)/pkg --with-jpeg-dir=$(CURDIR)/pkg \
		--with-curl=$(CURDIR)/pkg --with-apxs2=$(CURDIR)/httpd/bin/apxs; \
		make; \
		make install; \
		libtool --finish $(CURDIR)/php-$(version)/libs; \
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
		zip -rqy $(CURDIR)/php-$(version).zip .

clean: 
	rm -rf php* uploadprogress* curl* libjpeg* libpng* mysql* httpd* msmtp* pkg