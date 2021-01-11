#!/bin/sh
#
# Copyright (C) 2020 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

. /lib/functions.sh
. /usr/share/libubox/jshn.sh
. /lib/functions/leds.sh
. /lib/functions/network.sh

log() {
	local facility=$1; shift
	# in development, we want to show 'debug' level logs
	# when this release is out of beta, the comment in the line below
	# should be removed
	[ "$facility" = "debug" ] && return
	logger -t "led-mwan3-iface[$$]" -p $facility "$*"
}

check_iface() {
	local cfg="$1"
	local trigger_iface="$2"

	local trigger iface sysfs
	local up enabled running status
	local device

	config_get trigger "$cfg" trigger
	config_get iface "$cfg" iface
	config_get sysfs "$cfg" sysfs

	[ "$trigger" = "mwan3-iface" ] \
		&& [ -n "$sysfs" ] \
		&& [ -n "$iface" ] \
		|| return

	[ "$trigger_iface" = "$iface" ] || return

	json_init
	json_add_string section interfaces
	json_add_string interface "$iface"

	json_load "$(ubus call mwan3 status "$(json_dump)")"
	json_select interfaces
	json_select "$iface"

	json_get_var enabled 'enabled'
	[ "$enabled" = "1" ] || {
		log debug "Interface is not enabled ($iface)"
		led_off "$sysfs"
		return
	}

	json_get_var up 'up'
	[ "$up" = "1" ] || {
		log debug "Interface is not up ($iface)"
		led_off "$sysfs"
		return
	}

	json_get_var running 'running'
	[ "$up" = "1" ] || {
		log debug "Interface tracker is not running ($iface)"
		led_off "$sysfs"
		return
	}

	json_get_var status 'status'
	json_cleanup

	network_get_device device "$iface"
	[ -n "$device" ] || {
		log debug "Unable to find l3_device"
		led_off "$sysfs"
		return
	}

	case "$status" in
		online)
			log debug "Set online trigger \"netdev\" for $iface"
			led_set_attr "${sysfs}" "trigger" "netdev"
			led_set_attr "${sysfs}" "device_name" "${device}"
			led_set_attr "${sysfs}" "rx" "1"
			led_set_attr "${sysfs}" "tx" "1"
			led_set_attr "${sysfs}" "link" "1"
			;;
		offline)
			log debug "Set offline trigger \"none\" for $iface"
			led_off "$sysfs"
			;;
		*)
			log debug "Set unknown trigger \"timer\" for $iface"
			led_timer "$sysfs" "500" "500"
			;;
	esac
}

main() {
	local iface="$1"

	config_load system
	config_foreach check_iface led "$iface"
}
