// Copyright (c) 2020 Tailscale Inc & AUTHORS All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Package distro reports which distro we're running on.
package distro

import (
	"os"
	"runtime"
	"sync/atomic"
)

type Distro string

const (
	Debian   = Distro("debian")
	Arch     = Distro("arch")
	Synology = Distro("synology")
	OpenWrt  = Distro("openwrt")
	NixOS    = Distro("nixos")
	QNAP     = Distro("qnap")
	Pfsense  = Distro("pfsense")
	OPNsense = Distro("opnsense")
	TrueNAS  = Distro("truenas")
	Gokrazy  = Distro("gokrazy")
)

var distroAtomic atomic.Value // of Distro

// Get returns the current distro, or the empty string if unknown.
func Get() Distro {
	d, ok := distroAtomic.Load().(Distro)
	if ok {
		return d
	}
	switch runtime.GOOS {
	case "linux":
		d = linuxDistro()
	case "freebsd":
		d = freebsdDistro()
	}
	distroAtomic.Store(d) // even if empty
	return d
}

func have(file string) bool {
	_, err := os.Stat(file)
	return err == nil
}

func haveDir(file string) bool {
	fi, err := os.Stat(file)
	return err == nil && fi.IsDir()
}

func linuxDistro() Distro {
	switch {
	case haveDir("/usr/syno"):
		return Synology
	case have("/usr/local/bin/freenas-debug"):
		// TrueNAS Scale runs on debian
		return TrueNAS
	case have("/etc/debian_version"):
		return Debian
	case have("/etc/arch-release"):
		return Arch
	case have("/etc/openwrt_version"):
		return OpenWrt
	case have("/run/current-system/sw/bin/nixos-version"):
		return NixOS
	case have("/etc/config/uLinux.conf"):
		return QNAP
	case haveDir("/gokrazy"):
		return Gokrazy
	}
	return ""
}

func freebsdDistro() Distro {
	switch {
	case have("/etc/pfSense-rc"):
		return Pfsense
	case have("/usr/local/sbin/opnsense-shell"):
		return OPNsense
	case have("/usr/local/bin/freenas-debug"):
		// TrueNAS Core runs on FreeBSD
		return TrueNAS
	}
	return ""
}
