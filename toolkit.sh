#!/bin/bash

QEMU_CMD='qemu-system-x86_64'																														
MINIX_MOUNT_CMD='mount -t minix -o rw,loop,offset=1483776'								

EXPORT_DIR_NAME="minix_diff"

MINIX_IMG='minix203.img'
MINIX_ORG_IMG='minix203.img.org'

MINIX_URL='http://www.ia.pw.edu.pl/~tkruk/edu/soi.b/lab/minix/minix203.img'

MOUNT_DIR='minix_mnt'
MINIX_USR_DIR='source'

if test $UID -ne 0
then
	echo 'Permission denied. Run with superuser permissions.'
	exit 1
fi

if ! test -f $MINIX_ORG_IMG
then
	echo "Downloading clean image"
	while ! wget -O $MINIX_ORG_IMG $MINIX_URL
	do
		echo "Error downloading image, press enter to continue..."
		read
	done
	chmod 0666 $MINIX_ORG_IMG
fi

if ! test -f $MINIX_IMG
then
	cp $MINIX_ORG_IMG $MINIX_IMG
	chmod 0666 $MINIX_IMG
fi

if ! test -d source
then
	echo 'No source directory found - creating new one'
	TMP_DIR=`mktemp -d`
	mkdir source
	$MINIX_MOUNT_CMD $MINIX_ORG_IMG $TMP_DIR
	cp -R $TMP_DIR/src source/src
	cp -R $TMP_DIR/include source/include
	mkdir source/dev
	umount $TMP_DIR
	rm -rf $TMP_DIR
	chmod -R 0777 source
	echo 'Done. Press enter to continue...'
	read
fi

mkdir -p $MOUNT_DIR
chmod -R 0777 $MOUNT_DIR
mkdir -p $EXPORT_DIR_NAME
chmod -R 0777 $EXPORT_DIR_NAME



run_minix()
{
	$QEMU_CMD $MINIX_IMG
}

mount_image()
{
	if ! mount | grep "$PWD/$MINIX_IMG" > /dev/null
	then
		$MINIX_MOUNT_CMD $MINIX_IMG $MOUNT_DIR
	fi
}

umount_image()
{
	if mount | grep "$PWD/$MINIX_IMG" > /dev/null
	then
		while ! umount "$PWD/$MINIX_IMG"
		do
			echo "MInix is busy. Press any ket to retry."
			read
		done
	fi
}

sync_files()
{
	rm -rf $MOUNT_DIR/src
	rm -rf $MOUNT_DIR/include
	rm -rf $MOUNT_DIR/local/dev
	cp -R  $MINIX_USR_DIR/src $MOUNT_DIR/src
	cp -R  $MINIX_USR_DIR/include $MOUNT_DIR/include
	cp -R  $MINIX_USR_DIR/dev $MOUNT_DIR/local/dev
	chown -R root $MOUNT_DIR/src
	chown -R root $MOUNT_DIR/include
	chown -R root $MOUNT_DIR/local/dev
}

load_new_image()
{
	rm minix203.img
	cp minix203.img.org minix203.img
}

echo

clear

while true
do
	echo 	"== 1) Run MINIX"
	echo 	"== 2) Mount filesytem"
	echo 	"== 3) Unmount filesystem"
	echo 	"== 4) Sync files"
	echo 	"== 5) Sync files and run"
	echo    "== 6) Load new image"
	echo    "== 7) Export changed files"
	echo 	"== q) Exit"
	echo -n	"== Choice: "; read CHOICE

	clear

	case $CHOICE in
		"1")
			run_minix
			;;
		"2")
			mount_image
			;;
		"3")
			umount_image
			;;
		"4")
			mount_image
			sync_files
			umount_image
			;;
		"5")
			mount_image
			sync_files
			umount_image
			run_minix
			;;
		"6")
			load_new_image
			;;
		"7")
			TMP_DIR=`mktemp -d`
			$MINIX_MOUNT_CMD $MINIX_ORG_IMG $TMP_DIR
			$MINIX_MOUNT_CMD $MINIX_IMG $MOUNT_DIR
			EXCLUDES='^adm/\|.o$\|.map$'
			FILES_DIFF=`(LANG= diff -rqN $MOUNT_DIR/ $TMP_DIR/ | grep "^Only in $MOUNT_DIR" | awk '{print substr($3, 0, length($3))"/"$4}' ; LANG= diff -rqN $MOUNT_DIR/ $TMP_DIR/ | grep "^Files" | awk '{print $2}') | sed 's,^[^/]*/,,' | grep -v $EXCLUDES`
			cd $MOUNT_DIR
			FILES_DIFF=`echo ${FILES_DIFF[@]} | xargs file | grep -iv 'executable' | grep -iv 'dBase*' | awk '{print substr($1, 0, length($1))}'`
			cd ..
			echo 'Changed files: '
			echo $FILES_DIFF | tr ' ' '\n'
			echo 'Press enter to continue...'
			read

			rm -rf $EXPORT_DIR_NAME
			mkdir -p $EXPORT_DIR_NAME
			
			if test ${#FILES_DIFF[@]} -ne 0
			then
				cd $MOUNT_DIR
				echo ${FILES_DIFF[@]} | xargs cp --parents --target-directory=../$EXPORT_DIR_NAME
				echo "Files exported to: $EXPORT_DIR_NAME"
				echo 'Press enter to continue...'
				read
			fi
			umount $TMP_DIR
			rm -rf  $TMP_DIR
			umount ../$MOUNT_DIR
			;;
		"q")
			echo "-> Sleeeeeeeeeep"
			break
			;;
	esac
	clear
done
clear