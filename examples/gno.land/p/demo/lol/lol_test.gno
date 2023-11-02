package lol

import (
	"gno.land/p/demo/ufmt"
	"std"
	"testing"
)

func TestPackageLol(t *testing.T) {
	println("1. PrevRealm: ", std.PrevRealm())
	println("1. CurrentRealm: ", std.CurrentRealm())
	std.TestSetPrevRealm("gno.land/r/lol")
	println("2. PrevRealm: ", std.PrevRealm())
	println("2. CurrentRealm: ", std.CurrentRealm())
}
