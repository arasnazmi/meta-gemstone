#!/bin/sh

swupartconf_enabled()
{
    if [ "$bootparam_swupdate" != 1 ]; then
        return 1
    fi

    if [ -b "/dev/disk/by-label/ROOTFS_A" ]; then
        return 1
    fi

    printf "\n\n" >/dev/console
    msg "Configuring partitions for SWUpdate..."

    return 0
}

get_disk_of_partition()
{
    part_name="$(basename "$1")"
    sysfs_part_path="$(readlink -f "/sys/class/block/$part_name")"
    sysfs_disk_path="$(dirname "$sysfs_part_path")"

    if [ ! -d "$sysfs_disk_path" ]; then
        return 1
    fi

    printf "%s" "/dev/$(basename "$sysfs_disk_path")"
    return 0
}

swupartconf_run()
{
    if [ -z "$bootparam_bootpart" ]; then
        msg "'bootpart' is not passed as kernel parameter. Aborting partition configuration..."
        return 1
    fi

    boot_mntpoint="/boot"

    if ! disk_dev=$(get_disk_of_partition "$bootparam_bootpart"); then
        msg "Unable to get disk that partition belongs to"
        return 1
    fi

    parted_script='rm 2 mkpart primary btrfs 129MiB 4225MiB mkpart primary btrfs 4225MiB 8321MiB mkpart primary btrfs 8321MiB -1'

    tmp_mountdir="/tmp/rootfs"
    mkdir -p "$tmp_mountdir"

    parted --script "$disk_dev" -- "$parted_script" \
        && mkfs.btrfs -f -L "ROOTFS_B" "${disk_dev}p3" > /dev/null \
        && mkfs.btrfs -f -L "DATA" "${disk_dev}p4" > /dev/null \
        && btrfs rescue fix-device-size "${disk_dev}p2" \
        && mount -t btrfs "${disk_dev}p2" "$tmp_mountdir" \
        && btrfs filesystem resize max "$tmp_mountdir" > /dev/null \
        && btrfs filesystem label "$tmp_mountdir" ROOTFS_A > /dev/null \
        && umount "$tmp_mountdir" \
        || { msg "Partition configuration failed."; return 1; }

    echo '/boot/uboot.env 0x0     0x40000' > /etc/fw_env.config \
        && mkdir -p "$boot_mntpoint" \
        && mount ${disk_dev}p1 "$boot_mntpoint" \
        && fw_setenv slot A \
        || { msg "Unable to update U-Boot environment."; return 1; }

    sed -i 's/swupdate=1/swupdate=0/' "$boot_mntpoint/uEnv.txt"
    umount $boot_mntpoint

    sync
}
