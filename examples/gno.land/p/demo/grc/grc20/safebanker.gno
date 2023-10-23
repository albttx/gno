package grc20

import (
	"std"

	"gno.land/p/demo/grc/exts"
	"gno.land/p/demo/ufmt"
)

type LocalBanker interface {
	exts.TokenMetadata

	// Returns the amount of tokens in existence.
	TotalSupply() uint64

	// Returns the amount of tokens owned by `account`.
	BalanceOf(account std.Address) (uint64, error)

	// Moves `amount` tokens from the caller's account to `to`.
	//
	// Returns an error if the operation failed.
	Transfer(to std.Address, amount uint64) error
}

// safeBanker is complient with LocalBanker interface
// safeBanker is complient with IGRC20 interface
type safeBanker20 struct {
	banker *Banker20

	from std.Address
}

func (b *safeBanker20) GetName() string   { return b.banker.name }
func (b *safeBanker20) GetSymbol() string { return b.banker.symbol }
func (b *safeBanker20) GetDecimals() uint { return b.banker.decimals }

func (b *safeBanker20) TotalSupply() uint64 {
	return b.banker.TotalSupply()
}

func (b *safeBanker20) BalanceOf(account std.Address) (uint64, error) {
	return b.banker.BalanceOf(account)
}

func (b *safeBanker20) Transfer(to std.Address, amount uint64) error {
	from := b.from
	if b.from == nil {
		from = std.PrevRealm().Addr()
	}
	println("safe transfer", amount, " from: ", from, "to:", to)
	return b.banker.Transfer(from, to, amount)
}

func (b *safeBanker20) Allowance(owner, spender std.Address) (uint64, error) {
	return b.banker.Allowance(owner, spender)
}

func (b *safeBanker20) Approve(spender std.Address, amount uint64) error {
	from := b.from
	if b.from == nil {
		from = std.PrevRealm().Addr()
	}
	return b.banker.Approve(from, spender, amount)
}

func (b *safeBanker20) TransferFrom(from, to std.Address, amount uint64) error {
	spender := b.from
	if spender == nil {
		spender = std.PrevRealm().Addr()
	} else if spender != std.CurrentRealm().Addr() {
		panic(ufmt.Sprintf("unauthorized: banker spender is scoped to: %s", from))
	}
	if err := b.banker.spendAllowance(from, spender, amount); err != nil {
		return err
	}
	return b.banker.transfer(from, to, amount)
}
