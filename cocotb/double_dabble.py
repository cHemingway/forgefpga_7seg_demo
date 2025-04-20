""" Python implementation of the double-dabble algorithm """

def u8_to_bcd(val: int) -> int:
    ''' Converts an unsigned 8 bit `val` (0-99) to bcd '''

    scratch = val
    SHIFTS = 8

    for _ in range(SHIFTS):
        # If the tens digit is greater than 4, add 3
        if (scratch & 0xF000) > 0x4000:
            scratch = (scratch + 0x3000) << 1
        # If the ones digit is greater than 4, add 3
        elif (scratch & 0x0F00) > 0x0400:
            scratch = (scratch + 0x0300) << 1
        else:
            # If both digits are less than 5, just shift left
            scratch <<= 1

    # Mask the result to get the BCD value
    bcd = (scratch & 0xFF00) >> 8
    return bcd


if __name__ == "__main__":
    # Test the function
    for i in [24, 99]:
        bcd = u8_to_bcd(i)
        print(f"{i} -> 0x{bcd:02x}")
    