package main

import (
    "encoding/hex"
    "fmt"
    "os"

    "github.com/nknorg/nkn/common"
    "github.com/nknorg/nkn/crypto"
    "github.com/nknorg/nkn/core/contract"
)

/* Conventional style */
/* func main() {
    crypto.SetAlg("")
    for _, key := range os.Args[1:] {
        k, err := hex.DecodeString(key)
        if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }

        pk, err := crypto.DecodePoint(k)
        if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }

        redeemHash, err := contract.CreateRedeemHash(pk)
        if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }

        addr, err := redeemHash.ToAddress()
        if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
        } else {
            fmt.Println(addr)
        }
    }
} */

/* resist redundancy style */
func main() {
    var err error
    var k []byte
    var pk *crypto.PubKey
    var redeemHash common.Uint160
    var addr string

    var _ = contract.ByteToContractParameterType
    var _ = contract.CreateRedeemHash
    var _ = contract.CreateSignatureContract

    crypto.SetAlg("")
    for _, key := range os.Args[1:] {
        if k, err = hex.DecodeString(key); err == nil {
            if pk, err = crypto.DecodePoint(k); err == nil {
                if redeemHash, err = contract.CreateRedeemHash(pk); err == nil {
                    if addr, err = redeemHash.ToAddress(); err == nil {
                        fmt.Println(addr)
                        continue
                    }
                }
            }
        }
        os.Stderr.WriteString(err.Error() + "\n")
    }
}
