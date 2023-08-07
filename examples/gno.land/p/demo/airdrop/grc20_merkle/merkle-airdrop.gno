package grc20_merkle

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"std"

	"gno.land/p/demo/avl"
	"gno.land/p/demo/ufmt"
	"gno.land/p/demo/grc/grc20"
	"gno.land/p/demo/merkle"
)

var (
	ErrAlreadyClaimed = errors.New("already claimed")
	ErrInvalidProof   = errors.New("invalid merkle proof")
)

type AirdropData struct {
	Address std.Address
	Amount uint64
}

func (d AirdropData) Bytes() []byte {
	// TODO: use binary.Write
	// var buf bytes.Buffer
	// binary.Write(&buf, binary.BigEndian, d)
	// return buf.Bytes()
	// OR: use json.Marshal for frontend compatibilities

	s := ufmt.Sprintf("%v", d)
	return []byte(s)
}

type MerkleAirdrop struct {
	root string

	token   grc20.IGRC20
	claimed *avl.Tree
}

func NewMerkleAirdrop(merkleroot string, token grc20.IGRC20) *MerkleAirdrop {
	return &MerkleAirdrop{
		root: merkleroot,

		token:   token,
		claimed: avl.NewTree(),
	}
}

func (ma *MerkleAirdrop) Root() string {
	return ma.root
}

func (ma *MerkleAirdrop) Claim(data AirdropData, proofs []merkle.Node) error {
	shasum := sha256.Sum256(data.Bytes())
	hash := hex.EncodeToString(shasum[:])

	if ma.claimed.Has(hash) {
		return ErrAlreadyClaimed
	}

	if !merkle.Verify(ma.root, data, proofs) {
		return ErrInvalidProof
	}

	err := ma.token.Transfer(data.Address, data.Amount)
	if err != nil {
		return err
	}

	ma.claimed.Set(hash, data.Amount)
	return nil
}

func (ma MerkleAirdrop) TotalClaimed() uint64 {
	var claimed uint64 = 0

	ma.claimed.Iterate("", "", func(k string, v interface{}) bool {
		claimed += v.(uint64)
		return false
	})

	return claimed
}
