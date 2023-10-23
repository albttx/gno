// PKGPATH: gno.land/r/demo/foo20-airdrop
package airdrop

import (
	"std"
	"testing"

	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/grc/grc20"
	ptests "gno.land/p/demo/tests"
	"gno.land/p/demo/testutils"
	rtests "gno.land/r/demo/tests"
)

var (
	user1 = testutils.TestAddress("user1.gno")
	addr1 = testutils.TestAddress("addr1")
	addr2 = testutils.TestAddress("addr2")
)

func main() {
	foo20 := grc20.NewGRC20("Foo", "FOO", 0)
	sfoo20 := foo20.LocalBanker()
	foo20.Mint(std.CurrentRealm().Addr(), 1_100_000)

	err := sfoo20.Transfer(addr2, 100_000)
	if err != nil {
		println("errror: failed to transfer", err)
		return
		// panic(ufmt.Sprintf("error: failed to transfer: %v", err))
	}
	balance, _ := foo20.BalanceOf(addr2)
	println(balance)
}

// Output:
// safe transfer 100000  from:  g19q0jnz4wtyu6jkwm3zsvl5ausf0e52sqnf3q7e to: g1v9jxgu3jta047h6lta047h6lta047h6la2uhll
// 100000
