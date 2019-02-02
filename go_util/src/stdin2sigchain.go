package main

import (
    "bufio"
    "encoding/hex"
    "encoding/json"
    "fmt"
    "io"
    "os"

    "github.com/nknorg/nkn/por"
)

type HexBytes []byte

// Repalce []byte with HexBytes in order to orveride encoding/json serialize
type SigChainElem struct {
    Addr       HexBytes    `protobuf:"bytes,1,opt,name=Addr,proto3" json:"Addr,omitempty"`
    NextPubkey HexBytes    `protobuf:"bytes,2,opt,name=NextPubkey,proto3" json:"NextPubkey,omitempty"`
    Mining     bool        `protobuf:"varint,3,opt,name=Mining,proto3" json:"Mining,omitempty"`
    SigAlgo    por.SigAlgo `protobuf:"varint,4,opt,name=SigAlgo,proto3,enum=por.SigAlgo" json:"SigAlgo,omitempty"`
    Signature  HexBytes    `protobuf:"bytes,5,opt,name=Signature,proto3" json:"Signature,omitempty"`
}

type SigChain struct {
    Nonce      uint32          `protobuf:"varint,1,opt,name=Nonce,proto3" json:"Nonce,omitempty"`
    DataSize   uint32          `protobuf:"varint,2,opt,name=DataSize,proto3" json:"DataSize,omitempty"`
    DataHash   HexBytes        `protobuf:"bytes,3,opt,name=DataHash,proto3" json:"DataHash,omitempty"`
    BlockHash  HexBytes        `protobuf:"bytes,4,opt,name=BlockHash,proto3" json:"BlockHash,omitempty"`
    SrcPubkey  HexBytes        `protobuf:"bytes,5,opt,name=SrcPubkey,proto3" json:"SrcPubkey,omitempty"`
    DestPubkey HexBytes        `protobuf:"bytes,6,opt,name=DestPubkey,proto3" json:"DestPubkey,omitempty"`
    Elems      []*SigChainElem `protobuf:"bytes,7,rep,name=Elems" json:"Elems,omitempty"`
}

// Customize []byte serialize to hexString instead of base64 string
func (b HexBytes) MarshalJSON() ([]byte, error) {
    ret := []byte("\"" + hex.EncodeToString(b) + "\"")
    return ret, nil
}

func main() {
    rd := bufio.NewReader(os.Stdin)

NEXTLINE:
    for {
        l, err := rd.ReadString('\n')
        switch err {
        case nil: // Do nothing
        case io.EOF:
            break NEXTLINE
        default:
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }

        buf, err := hex.DecodeString(l[:len(l)-1]) // omit latest byte '\n'
        /* if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        } */	// try to PB Unmarshal even err

        sig := &por.SigChain{}
        if err := sig.Unmarshal(buf); err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }

        out := &SigChain{sig.Nonce, sig.DataSize, sig.DataHash, sig.BlockHash, sig.SrcPubkey, sig.DestPubkey, []*SigChainElem{}}
        for _, e := range sig.Elems {
            out.Elems = append(out.Elems, &SigChainElem{e.Addr, e.NextPubkey, e.Mining, e.SigAlgo, e.Signature})
        }

        js, err := json.Marshal(out)
        if err != nil {
            fmt.Fprintf(os.Stderr, "%v\n", err)
            continue
        }
        fmt.Printf("%s\n", js)
    }
}
