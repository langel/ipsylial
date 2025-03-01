extends Node

var byte: int = 1

func lfsr_byte() -> int:
	var carry = byte & 1
	byte >>= 1
	if (carry): byte ^= 0xd4
	return byte;
	
func rng(pos, seed) -> int:
	const BIT_NOISE1: int = 0xB5297A4D
	const BIT_NOISE2: int = 0x68E31DA4
	const BIT_NOISE3: int = 0x1B56C4E9
	var mangled: int = pos
	mangled *= BIT_NOISE1
	mangled += seed
	mangled ^= (mangled >> 8)
	mangled += BIT_NOISE2
	mangled ^= (mangled << 8)
	mangled *= BIT_NOISE3
	mangled ^= (mangled >> 8)
	mangled &= 0xffffffff
	return mangled
