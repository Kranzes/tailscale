// Copyright (c) 2021 Tailscale Inc & AUTHORS All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

//go:build linux || (darwin && !ios)
// +build linux darwin,!ios

package netstack

import "tailscale.com/ssh/tailssh"

func init() {
	handleSSH = tailssh.Handle
}
