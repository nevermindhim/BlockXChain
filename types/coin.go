package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
)

const (
	// AttoBlockX defines the default coin denomination used in BlockX in:
	//
	// - Staking parameters: denomination used as stake in the dPoS chain
	// - Mint parameters: denomination minted due to fee distribution rewards
	// - Governance parameters: denomination used for spam prevention in proposal deposits
	// - Crisis parameters: constant fee denomination used for spam prevention to check broken invariant
	// - EVM parameters: denomination used for running EVM state transitions in BlockX.
	AttoBlockX string = "abcx"

	// BaseDenomUnit defines the base denomination unit for BlockXs.
	// 1 bcx = 1x10^{BaseDenomUnit} abcx
	BaseDenomUnit = 18
)

// NewBlockXCoin is a utility function that returns an "abcx" coin with the given sdk.Int amount.
// The function will panic if the provided amount is negative.
func NewBlockXCoin(amount sdk.Int) sdk.Coin {
	return sdk.NewCoin(AttoBlockX, amount)
}

// NewBlockXDecCoin is a utility function that returns an "abcx" decimal coin with the given sdk.Int amount.
// The function will panic if the provided amount is negative.
func NewBlockXDecCoin(amount sdk.Int) sdk.DecCoin {
	return sdk.NewDecCoin(AttoBlockX, amount)
}

// NewBlockXCoinInt64 is a utility function that returns an "abcx" coin with the given int64 amount.
// The function will panic if the provided amount is negative.
func NewBlockXCoinInt64(amount int64) sdk.Coin {
	return sdk.NewInt64Coin(AttoBlockX, amount)
}
