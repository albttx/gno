package lol

import (
	"std"
	"testing"
)

func TestRealmLol(t *testing.T) {
	println("HELLO IN REALM")
	// std.PrintFrames()
	println("1. PrevRealm: ", std.PrevRealm())
	// println("1. CurrentRealm: ", std.CurrentRealmPath())
	std.TestSetPrevRealm("gno.land/r/lol")
	// std.PrintFrames()
	println("2. PrevRealm: ", std.PrevRealm())
	// println("2. CurrentRealm: ", std.CurrentRealmPath())
}
