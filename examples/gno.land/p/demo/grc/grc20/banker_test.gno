package grc20

import (
	"std"
	"testing"

	"gno.land/p/demo/testutils"
	ptests "gno.land/r/demo/tests"
	rtests "gno.land/r/demo/tests"
)

// Write test cases
// 1. user -> banker
// 2. user -> realm -> banker
// 3. user -> realm -> realm -> banker
// 4. user -> realm -> pkg -> banker

var (
	user1 = testutils.TestAddress("user1.gno")
	addr1 = testutils.TestAddress("addr1")
	addr2 = testutils.TestAddress("addr2")
)

// func TestBanker(t *testing.T) {
// 	foo20 := NewGRC20("Foo", "FOO", 0)
// 	sfoo20 := foo20.GRC20()

// 	// std.TestSetOrigCaller(addr1)
// 	// std.TestPushFrameRealm(string(addr1))
// 	// defer std.TestSetOrigCaller(user1)

// 	foo20.Mint(addr1, 1_100_000)

// 	err := sfoo20.Transfer(addr2, 100_000)
// 	if err != nil {
// 		println("ERROR:", err)
// 		t.Fail()
// 	}
// 	println(foo20.MustBalanceOf(addr2))
// }

// func TestBankerRealm(t *testing.T) {
// 	foo20 := NewGRC20("Foo", "FOO", 0)
// 	foo20.Mint(addr1, 1_100_000)

// 	sfoo20 := foo20.SafeGRC20()
// 	err := rtests.BankerTransfer(sfoo20, addr2, 100_000)
// 	if err != nil {
// 		println("ERROR: ", err)
// 		t.Fail()
// 	}
// 	println(foo20.MustBalanceOf(addr2))
// }

// func TestBankerRealmUnsafe(t *testing.T) {
// 	foo20 := NewGRC20("Foo", "FOO", 0)
// 	foo20.Mint(addr1, 1_100_000)
// 	// std.TestPushRealmFrame("gno.land/r/demo/lol")
// 	sfoo20 := foo20.UnsafeGRC20()
// 	err := rtests.BankerTransfer(sfoo20, addr2, 100_000)
// 	if err != nil {
// 		println("ERROR: ", err)
// 		t.Fail()
// 	}
// 	println(foo20.MustBalanceOf(addr2))
// }

// func TestBankerPkg(t *testing.T) {
// 	foo20 := NewGRC20("Foo", "FOO", 0)
// 	foo20.Mint(addr1, 1_100_000)

// 	sfoo20 := foo20.SafeGRC20()
// 	err := ptests.BankerTransfer(sfoo20, addr2, 100_000)
// 	if err != nil {
// 		println("ERROR: ", err)
// 		t.Fail()
// 	}
// 	println(foo20.MustBalanceOf(addr2))
// }
