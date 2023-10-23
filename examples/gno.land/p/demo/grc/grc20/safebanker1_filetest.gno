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

	user1 = std.DerivePkgAddr("user1.gno")
	addr1 = testutils.TestAddress("addr1")
	addr2 = testutils.TestAddress("addr2")
)

func main() {
	foo20 := grc20.NewGRC20("Foo", "FOO", 0)
	sfoo20 := foo20.GRC20()
	foo20.Mint(user1, 1_100_000)

	err := sfoo20.Transfer(addr2, 100_000)
	if err != nil {
		println("error: failed to transfer", err)
		return
	}

	balance, _ := foo20.BalanceOf(addr2)
	println(balance)
}

// Output:
// safe transfer 100000  from:  g1wymu47drhr0kuq2098m792lytgtj2nyx77yrsm to: g1v9jxgu3jta047h6lta047h6lta047h6la2uhll
// 100000
