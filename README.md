# MINIX
MINIX operating system sources extracted from system image.

## MINIX emulation with QEmu with "shared directory" on host sytem
1. Create mounting point in your host system
```shell
sudo mkdir /mnt/minix
```
2. Create shared disk image on your host sytem with:
```shell
dd if=/dev/zero of=shared.img bs=512 count=31680
```
3. Run your Qemu with
```shell
qemu-system-x86_64 -hdb shared.img minix203.img
```
4. In MINIX run
```shell
mkfs /dev/c0d1
```

Now you can mount your shared disk in MINIX with
```shell
mount /dev/d0c1 /mnt
```
and your disk will be avaliable at /mnt
After operations on your /mnt remember to unmount it with
```shell
sync
umount /dev/d0c1
```


To access that disk in your host system just mount it with
```shell
sudo mount shared.img /mnt/minix
```
and your disc will be avaliable at /mnt/minix
Dont forget to unmount it when you are done
```shell
sync
sudo umount /mnt/minix
```

## Compiling new  minix203.img file in your host system
TO BE ADDDED
