#MINIX toolkit - git and memory friendly

Simple bash script which allows you to work etter and faster on your next MINIX project!

##Functions
- Creating new project
- Running image
- Mounting `/usr` filesystem
- Upload files to MINIX image
- Reload clean MINIX image
- Extract changed files into directory
- Source is on your computer, than uploaded to MINIX, no worries about MINIX segmentation errors, no more 50MB backup files
- All the source is kept in `./source` directory - you can init git repo there and keep track of your changes

##How to
Download (clone) this repo into a directory on your system. Than run `sudo ./toolkit.sh`. Root permissions are required for mounting images.
Script will download MINIX image, create all the required directories. 

Now, edit your code in `./source`. Files created in `source/dev` are coppied into `/usr/local/dev/`.

