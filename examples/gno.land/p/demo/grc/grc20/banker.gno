package grc20

import (
	"std"

	"gno.land/p/demo/avl"
)

type Banker20 struct {
	name        string
	symbol      string
	decimals    uint
	totalSupply uint64
	balances    avl.Tree // std.Address(owner) -> uint64
	allowances  avl.Tree // string(owner+":"+spender) -> uint64
}

func NewGRC20(name, symbol string, decimals uint) *Banker20 {
	// FIXME: check for limits

	return &Banker20{
		name:     name,
		symbol:   symbol,
		decimals: decimals,

		balances:   avl.Tree{},
		allowances: avl.Tree{},
	}
}

func (t *Banker20) LocalBanker() LocalBanker {
	from := std.CurrentRealm()
	return &safeBanker20{
		banker: t,
		from:   from.Addr(),
	}
}

func (t *Banker20) GRC20() IGRC20 {
	return &safeBanker20{
		banker: t,
	}
}

func (t *Banker20) GetName() string     { return t.name }
func (t *Banker20) GetSymbol() string   { return t.symbol }
func (t *Banker20) GetDecimals() uint   { return t.decimals }
func (t *Banker20) TotalSupply() uint64 { return t.totalSupply }

func (t *Banker20) Treasury() uint64 {
	// TODO: Return std.CurrentRealm Balance
	return 0
}

func (t *Banker20) BalanceOf(owner std.Address) (uint64, error) {
	return t.balanceOf(owner)
}

func (t *Banker20) Transfer(owner, to std.Address, amount uint64) error {
	return t.transfer(owner, to, amount)
}

func (t *Banker20) Allowance(owner, spender std.Address) (uint64, error) {
	return t.allowance(owner, spender)
}

func (t *Banker20) Approve(owner, spender std.Address, amount uint64) error {
	return t.approve(owner, spender, amount)
}

func (t *Banker20) TransferFrom(spender, from, to std.Address, amount uint64) error {
	if err := t.spendAllowance(from, spender, amount); err != nil {
		return err
	}
	return t.transfer(from, to, amount)
}

func (t *Banker20) Mint(to std.Address, amount uint64) error {
	return t.mint(to, amount)
}

func (t *Banker20) Burn(from std.Address, amount uint64) error {
	return t.burn(from, amount)
}

// Private helpers
// =============================================================

func (t *Banker20) mint(address std.Address, amount uint64) error {
	if err := checkIsValidAddress(address); err != nil {
		return err
	}

	// TODO: check for overflow

	t.totalSupply += amount
	currentBalance, err := t.balanceOf(address)
	if err != nil {
		return err
	}
	newBalance := currentBalance + amount

	t.balances.Set(string(address), newBalance)

	event := TransferEvent{zeroAddress, address, amount}
	emit(&event)

	return nil
}

func (t *Banker20) burn(address std.Address, amount uint64) error {
	if err := checkIsValidAddress(address); err != nil {
		return err
	}
	// TODO: check for overflow

	currentBalance, err := t.balanceOf(address)
	if err != nil {
		return err
	}
	if currentBalance < amount {
		return ErrInsufficientBalance
	}

	t.totalSupply -= amount
	newBalance := currentBalance - amount

	t.balances.Set(string(address), newBalance)

	event := TransferEvent{address, zeroAddress, amount}
	emit(&event)

	return nil
}

func (t *Banker20) balanceOf(address std.Address) (uint64, error) {
	if err := checkIsValidAddress(address); err != nil {
		return 0, err
	}

	balance, found := t.balances.Get(address.String())
	if !found {
		return 0, nil
	}
	return balance.(uint64), nil
}

func (t *Banker20) spendAllowance(owner, spender std.Address, amount uint64) error {
	if err := checkIsValidAddress(owner); err != nil {
		return err
	}
	if err := checkIsValidAddress(spender); err != nil {
		return err
	}

	currentAllowance, err := t.allowance(owner, spender)
	if err != nil {
		return err
	}
	if currentAllowance < amount {
		return ErrInsufficientAllowance
	}

	key := allowanceKey2(owner, spender)
	if currentAllowance > amount {
		t.allowances.Set(key, currentAllowance-amount)
	} else {
		t.allowances.Remove(key)
	}

	return nil
}

func (t *Banker20) transfer(from, to std.Address, amount uint64) error {
	if err := checkIsValidAddress(from); err != nil {
		return err
	}
	if err := checkIsValidAddress(to); err != nil {
		return err
	}

	if from == to {
		return ErrCannotTransferToSelf
	}

	toBalance, err := t.balanceOf(to)
	if err != nil {
		return err
	}
	fromBalance, err := t.balanceOf(from)
	if err != nil {
		return err
	}

	// debug.
	// println("from", from, "to", to, "amount", amount, "fromBalance", fromBalance, "toBalance", toBalance)

	if fromBalance < amount {
		return ErrInsufficientBalance
	}

	newToBalance := toBalance + amount
	newFromBalance := fromBalance - amount

	t.balances.Set(string(to), newToBalance)
	t.balances.Set(string(from), newFromBalance)

	event := TransferEvent{from, to, amount}
	emit(&event)

	return nil
}

func (t *Banker20) allowance(owner, spender std.Address) (uint64, error) {
	if err := checkIsValidAddress(owner); err != nil {
		return 0, err
	}
	if err := checkIsValidAddress(spender); err != nil {
		return 0, err
	}

	allowance, found := t.allowances.Get(allowanceKey2(owner, spender))
	if !found {
		return 0, nil
	}

	return allowance.(uint64), nil
}

func (t *Banker20) approve(owner, spender std.Address, amount uint64) error {
	if err := checkIsValidAddress(owner); err != nil {
		return err
	}
	if err := checkIsValidAddress(spender); err != nil {
		return err
	}

	t.allowances.Set(allowanceKey2(owner, spender), amount)

	event := ApprovalEvent{owner, spender, amount}
	emit(&event)

	return nil
}

func allowanceKey2(owner, spender std.Address) string {
	return owner.String() + ":" + spender.String()
}
