#!/bin/bash

help="usage: ./script <disk_storage> <vm_ram> <cpu_cores> <iso_img.iso>"
main(){

( [ $(id -u) == 0 ] && ( run $1 $2 $3 $4 )) || echo "+ must run as super user !"

}


run(){
	( [ ! -f ./disk.qcow2 ] && qemu-img create -f qcow2 disk.qcow2 $1 );

	qemu-system-x86_64 -enable-kvm -m $2 -smp $3 -cpu host \
  		-drive file=./disk.qcow2,format=qcow2 \
  		-cdrom $4 -boot d
}
[ "$1" == "-h" ] && echo $help && exit ||
( [ -n "$1" ] && [ -n "$2" ] &&  [ -n "$3" ] && [ -n "$4" ] && main $1 $2 $3 $4 ) || echo $help 


