#!/bin/bash

# (C) 2015-2017 Francesco Bonanno <mibofra@frozenbox.org>

# Write or create armhf images.

# You need superuser privileges.

BUILD_NUMBER=1
BASEIMG=parrotsec-standard-3.5-armhf-rpi
IMAGEPREFIX=$(BASEIMG)-$(BUILD_NUMBER)
LOGFILE=$(IMAGEPREFIX).image-build-log.txt
IMAGENAME=$(IMAGEPREFIX).img
MD5SUMIMG=$(IMAGENAME).md5sum.txt
SHA1SUMIMG=$(IMAGENAME).sha1sum.txt
TARGZFILE=$(IMAGEPREFIX).tar.gz
TARXZFILE=$(IMAGENAME).tar.xz
MD5SUMTARXZFILE=$(TARXZFILE).md5sum.txt
SHA1SUMTARXZFILE=$(TARXZFILE).sha1sum.txt
BLOCKDEVICE=$1

all:
	set -e; sudo ./build_parrotsec_image.sh 2>&1 | tee $(LOGFILE)
	if [ -f parrotsec-rpi/parrot-armhf-image.img ]; then \
		sudo mv parrotsec-rpi/parrot-armhf-image.img $(IMAGENAME); \
		sudo mv parrotsec-rpi/parrot-armhf-image.img.md5sum.txt $(MD5SUMIMG); \
		sudo mv parrotsec-rpi/parrot-armhf-image.img.sha1sum.txt $(SHA1SUMIMG); \
		sleep 1; \
		XZ_OPT=-9 tar cfJ $(TARXZFILE) $(IMAGENAME) $(MD5SUMIMG) $(SHA1SUMIMG); \
		sudo rm -rf $(IMAGENAME) $(MD5SUMIMG) $(SHA1SUMIMG); \
		md5sum $(TARXZFILE) > $(MD5SUMTARXZFILE); \
		sha1sum $(TARXZFILE) > $(SHA1SUMTARXZFILE); \
	fi

clean:
	rm -f $(IMAGENAME)*
	rm -f $(LOGFILE)
	sudo umount -l parrotsec-rpi/*; true
	sudo dmsetup remove_all
	sudo rm -rf parrotsec-rpi rpi-firmware
	sudo rm -rf rpi-firmware; true

write-image:
	sudo ./build_parrotsec_image.sh $(BLOCKDEVICE)
