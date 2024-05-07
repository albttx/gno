package airdrop

type Airdrop interface {
	Claim(amount uint64, proof []string)
	TotalClaimed() uint64
}
