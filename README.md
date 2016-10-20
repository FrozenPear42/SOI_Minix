# MINIX
MINIX operating system sources extracted from system image.

# MINIX emulation with QEmu with "shared directory" on host sytem

1. Create shared disk image on your host sytem with:
```shell
dd if=/dev/zero of=shared.img bs=512 count=!!!!!!!
```
2. Run your quemu with
```shell
qemu-system-x86_64 -hdb shared.img minix203.img
```
3. In MINIX run
```shell
mkfs /dev/c0d1
```

Now you can mount your shared disk in MINIX with
```shell
mount /dev/d0c1 /mnt
```
and your disk will be avaliable at /mnt
