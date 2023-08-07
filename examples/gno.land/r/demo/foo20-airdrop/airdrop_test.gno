package foo20airdrop

import (
	"std"
	"testing"

	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/airdrop/grc20_merkle"
	"gno.land/p/demo/merkle"
	"gno.land/r/demo/foo20"
	"gno.land/r/demo/users"
)

var leaves []merkle.Hashable = []grc20_merkle.AirdropData{
	{
		Address: "g1auhc2cymv7gn9qmls0ttdr3wqrljgz0dhq90e",
		Amount:  1_000_000,
	},
	{
		Address: "g1zyvskpxg5lv4qpygtuvp93zprrrjpk2exa9rfx",
		Amount:  1_000_000,
	},
	{
		Address: "g14szvkruznx49sxe4m9dmg3m8606sm6yp4a0wv8",
		Amount:  1_000_000,
	},
}

// func TestRegisterMerkle(t *testing.T) {
// 	tree := merkle.NewTree(leaves)
// 	root := tree.Root()

// 	RegisterMerkleRoot(root)
// 	reset()
// }

// user1.gno -> r/foo20-airdrop -> p/airdrop/grc_merkle -> r/foo20
func TestClaimAirdrop(t *testing.T) {
	println("Prev", std.PrevRealm().PkgPath())
	println("Current", std.CurrentRealm().PkgPath())
	println("------------------------------------")
	println("------------------------------------")
	contractAddr := std.DerivePkgAddr("gno.land/r/demo/foo20-airdrop")
	// contractAddr := std.DerivePkgAddr("user1.gno")
	std.TestSetOrigCaller(contractAddr)

	// instantiate foo20 airdrop contract
	tree := merkle.NewTree(leaves)
	RegisterMerkleRoot(tree.Root())
	defer reset()

	sumClaimed := uint64(0)
	for _, leaf := range leaves {
		data := leaf.(grc20_merkle.AirdropData)
		user := data.Address
		sumClaimed += data.Amount

		proofs, err := tree.Proof(leaf)
		if err != nil {
			t.Fatalf("failed to generate proof, %v", err)
			return
		}

		// claim airdrop
		Claim(leaf.(grc20_merkle.AirdropData), proofs)
	}

	ttClaimed := TotalClaimed()
	if ttClaimed != sumClaimed {
		t.Fatalf("expected: %d", sumClaimed)
	}
}
