package rpc

import (
	"github.com/ethereum/go-ethereum/rpc"

	"github.com/cosmos/cosmos-sdk/client/context"

	"github.com/defi-ventures/ethermint/crypto/ethsecp256k1"
	"github.com/defi-ventures/ethermint/rpc/backend"
	"github.com/defi-ventures/ethermint/rpc/namespaces/eth"
	"github.com/defi-ventures/ethermint/rpc/namespaces/eth/filters"
	"github.com/defi-ventures/ethermint/rpc/namespaces/net"
	"github.com/defi-ventures/ethermint/rpc/namespaces/personal"
	"github.com/defi-ventures/ethermint/rpc/namespaces/web3"
	rpctypes "github.com/defi-ventures/ethermint/rpc/types"
)

// RPC namespaces and API version
const (
	Web3Namespace     = "web3"
	EthNamespace      = "eth"
	PersonalNamespace = "personal"
	NetNamespace      = "net"
	flagRPCAPI        = "rpc-api"

	apiVersion = "1.0"
)

// GetAPIs returns the list of all APIs from the Ethereum namespaces
func GetAPIs(clientCtx context.CLIContext, selectedApis []string, keys ...ethsecp256k1.PrivKey) []rpc.API {
	nonceLock := new(rpctypes.AddrLocker)
	backend := backend.New(clientCtx)
	ethAPI := eth.NewAPI(clientCtx, backend, nonceLock, keys...)

	var apis []rpc.API

	apis = append(apis,
		rpc.API{
			Namespace: EthNamespace,
			Version:   apiVersion,
			Service:   ethAPI,
			Public:    true,
		},
	)
	apis = append(apis,
		rpc.API{
			Namespace: EthNamespace,
			Version:   apiVersion,
			Service:   filters.NewAPI(clientCtx, backend),
			Public:    true,
		},
	)

	for _, api := range selectedApis {
		switch api {
		case Web3Namespace:
			apis = append(apis,
				rpc.API{
					Namespace: Web3Namespace,
					Version:   apiVersion,
					Service:   web3.NewAPI(),
					Public:    true,
				},
			)
		case PersonalNamespace:
			apis = append(apis,
				rpc.API{
					Namespace: PersonalNamespace,
					Version:   apiVersion,
					Service:   personal.NewAPI(ethAPI),
					Public:    false,
				},
			)
		case NetNamespace:
			apis = append(apis,
				rpc.API{
					Namespace: NetNamespace,
					Version:   apiVersion,
					Service:   net.NewAPI(clientCtx),
					Public:    true,
				},
			)
		}
	}

	return apis
}
