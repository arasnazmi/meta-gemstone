#!/bin/sh

disklinks_enabled()
{
    return 0
}

disklinks_run()
{
    mkdir -p /dev/disk/by-uuid /dev/disk/by-label /dev/disk/by-partuuid

    for n in /sys/class/block/*; do
        dev="$(basename "$n")"
        [ -e "/dev/$dev" ] || continue

        disk_entry=$(blkid "/dev/$dev" 2>/dev/null)
        disk_entry="${disk_entry#*: }"

        if eval "$disk_entry"; then
            [ -n "${UUID:-}" ] && ln -snf "/dev/$dev" "/dev/disk/by-uuid/$UUID"

            if [ -n "${LABEL:-}" ]; then
                safe="$(printf '%s' "$LABEL" | tr ' /' '__')"
                ln -snf "/dev/$dev" "/dev/disk/by-label/$safe"
            fi
        fi
    done
}
