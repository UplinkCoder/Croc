/*******************************************************************************

        copyright:      Copyright (c) 2006 Tango. All rights reserved

        license:        BSD style: $(LICENSE)

        version:        Initial release: November 2006

        author:         Walter Bright, Keinfarbton

*******************************************************************************/

module UniChar;

/******************************************************************************

        Returns !=0 if c is a digit.

******************************************************************************/

bool isUniDigit (dchar c)
{
        return (c >= '0' && c <= '9');
}

/******************************************************************************

        Returns !=0 if c is a Unicode lower case character.

******************************************************************************/

bool isUniLower (dchar c)
{
    if (c <= 0x7F)
        return (c >= 'a' && c <= 'z');

    return isUniAlpha(c) && c == toUniLower(c);
}

/******************************************************************************

        Returns !=0 if c is a Unicode upper case character.

******************************************************************************/

bool isUniUpper (dchar c)
{
    if (c <= 0x7F)
        return (c >= 'A' && c <= 'Z');

    return isUniAlpha(c) && c == toUniUpper(c);
}

/******************************************************************************

        If c is a Unicode upper case character, return the lower case
        equivalent, otherwise return c.

******************************************************************************/

dchar toUniLower (dchar c)
{
    if (c >= 'A' && c <= 'Z')
    {
        c += 32;
    }
    if (c >= 0x00C0)
    {
        if ((c >= 0x00C0 && c <= 0x00D6) || (c >= 0x00D8 && c<=0x00DE))
        {
            c += 32;
        }
        else if ((c >= 0x0100 && c < 0x0138) || (c > 0x0149 && c < 0x0178))
        {
            if (c == 0x0130)
                c = 0x0069;
            else if ((c & 1) == 0)
                c += 1;
        }
        else if (c == 0x0178)
        {
            c = 0x00FF;
        }
        else if ((c >= 0x0139 && c < 0x0149) || (c > 0x0178 && c < 0x017F))
        {
            if (c & 1)
                c += 1;
        }
        else if (c >= 0x0200 && c <= 0x0217)
        {
            if ((c & 1) == 0)
                c += 1;
        }
        else if ((c >= 0x0401 && c <= 0x040C) || (c>= 0x040E && c <= 0x040F))
        {
            c += 80;
        }
        else if (c >= 0x0410  && c <= 0x042F)
        {
            c += 32;
        }
        else if (c >= 0x0460 && c <= 0x047F)
        {
            if ((c & 1) == 0)
                c += 1;
        }
        else if (c >= 0x0531 && c <= 0x0556)
        {
            c += 48;
        }
        else if (c >= 0x10A0 && c <= 0x10C5)
        {
            c += 48;
        }
        else if (c >= 0xFF21 && c <= 0xFF3A)
        {
            c += 32;
        }
    }
    return c;
}

/******************************************************************************

        If c is a Unicode lower case character, return the upper case
        equivalent, otherwise return c.

******************************************************************************/

dchar toUniUpper (dchar c)
{
    if (c >= 'a' && c <= 'z')
    {
        c -= 32;
    }
    if (c >= 0x00E0)
    {
        if ((c >= 0x00E0 && c <= 0x00F6) || (c >= 0x00F8 && c <= 0x00FE))
        {
            c -= 32;
        }
        else if (c == 0x00FF)
        {
            c = 0x0178;
        }
        else if ((c >= 0x0100 && c < 0x0138) || (c > 0x0149 && c < 0x0178))
        {
            if (c == 0x0131)
                c = 0x0049;
            else if (c & 1)
                c -= 1;
        }
        else if ((c >= 0x0139 && c < 0x0149) || (c > 0x0178 && c < 0x017F))
        {
            if ((c & 1) == 0)
                c = c-1;
        }
        else if (c == 0x017F)
        {
            c = 0x0053;
        }
        else if (c >= 0x0200 && c <= 0x0217)
        {
            if (c & 1)
                c = c-1;
        }
        else if (c >= 0x0430 && c<= 0x044F)
        {
            c -= 32;
        }
        else if ((c >= 0x0451 && c <= 0x045C) || (c >=0x045E && c<= 0x045F))
        {
            c -= 80;
        }
        else if (c >= 0x0460 && c <= 0x047F)
        {
            if (c & 1)
                c -= 1;
        }
        else if (c >= 0x0561 && c < 0x0587)
        {
            c -= 48;
        }
        else if (c >= 0xFF41 && c <= 0xFF5A)
        {
            c -= 32;
        }
    }
    return c;
}


/******************************************************************************

        Return !=0 if u is a Unicode alpha character.

******************************************************************************/

bool isUniAlpha (dchar u)
{
    static ushort table[][2] =
    [
        [ 'A', 'Z' ],
        [ 'a', 'z' ],
        [ 0x00AA, 0x00AA ],
        [ 0x00B5, 0x00B5 ],
        [ 0x00B7, 0x00B7 ],
        [ 0x00BA, 0x00BA ],
        [ 0x00C0, 0x00D6 ],
        [ 0x00D8, 0x00F6 ],
        [ 0x00F8, 0x01F5 ],
        [ 0x01FA, 0x0217 ],
        [ 0x0250, 0x02A8 ],
        [ 0x02B0, 0x02B8 ],
        [ 0x02BB, 0x02BB ],
        [ 0x02BD, 0x02C1 ],
        [ 0x02D0, 0x02D1 ],
        [ 0x02E0, 0x02E4 ],
        [ 0x037A, 0x037A ],
        [ 0x0386, 0x0386 ],
        [ 0x0388, 0x038A ],
        [ 0x038C, 0x038C ],
        [ 0x038E, 0x03A1 ],
        [ 0x03A3, 0x03CE ],
        [ 0x03D0, 0x03D6 ],
        [ 0x03DA, 0x03DA ],
        [ 0x03DC, 0x03DC ],
        [ 0x03DE, 0x03DE ],
        [ 0x03E0, 0x03E0 ],
        [ 0x03E2, 0x03F3 ],
        [ 0x0401, 0x040C ],
        [ 0x040E, 0x044F ],
        [ 0x0451, 0x045C ],
        [ 0x045E, 0x0481 ],
        [ 0x0490, 0x04C4 ],
        [ 0x04C7, 0x04C8 ],
        [ 0x04CB, 0x04CC ],
        [ 0x04D0, 0x04EB ],
        [ 0x04EE, 0x04F5 ],
        [ 0x04F8, 0x04F9 ],
        [ 0x0531, 0x0556 ],
        [ 0x0559, 0x0559 ],
        [ 0x0561, 0x0587 ],
        [ 0x05B0, 0x05B9 ],
        [ 0x05BB, 0x05BD ],
        [ 0x05BF, 0x05BF ],
        [ 0x05C1, 0x05C2 ],
        [ 0x05D0, 0x05EA ],
        [ 0x05F0, 0x05F2 ],
        [ 0x0621, 0x063A ],
        [ 0x0640, 0x0652 ],
        [ 0x0660, 0x0669 ],
        [ 0x0670, 0x06B7 ],
        [ 0x06BA, 0x06BE ],
        [ 0x06C0, 0x06CE ],
        [ 0x06D0, 0x06DC ],
        [ 0x06E5, 0x06E8 ],
        [ 0x06EA, 0x06ED ],
        [ 0x06F0, 0x06F9 ],
        [ 0x0901, 0x0903 ],
        [ 0x0905, 0x0939 ],
        [ 0x093D, 0x093D ],
        [ 0x093E, 0x094D ],
        [ 0x0950, 0x0952 ],
        [ 0x0958, 0x0963 ],
        [ 0x0966, 0x096F ],
        [ 0x0981, 0x0983 ],
        [ 0x0985, 0x098C ],
        [ 0x098F, 0x0990 ],
        [ 0x0993, 0x09A8 ],
        [ 0x09AA, 0x09B0 ],
        [ 0x09B2, 0x09B2 ],
        [ 0x09B6, 0x09B9 ],
        [ 0x09BE, 0x09C4 ],
        [ 0x09C7, 0x09C8 ],
        [ 0x09CB, 0x09CD ],
        [ 0x09DC, 0x09DD ],
        [ 0x09DF, 0x09E3 ],
        [ 0x09E6, 0x09EF ],
        [ 0x09F0, 0x09F1 ],
        [ 0x0A02, 0x0A02 ],
        [ 0x0A05, 0x0A0A ],
        [ 0x0A0F, 0x0A10 ],
        [ 0x0A13, 0x0A28 ],
        [ 0x0A2A, 0x0A30 ],
        [ 0x0A32, 0x0A33 ],
        [ 0x0A35, 0x0A36 ],
        [ 0x0A38, 0x0A39 ],
        [ 0x0A3E, 0x0A42 ],
        [ 0x0A47, 0x0A48 ],
        [ 0x0A4B, 0x0A4D ],
        [ 0x0A59, 0x0A5C ],
        [ 0x0A5E, 0x0A5E ],
        [ 0x0A66, 0x0A6F ],
        [ 0x0A74, 0x0A74 ],
        [ 0x0A81, 0x0A83 ],
        [ 0x0A85, 0x0A8B ],
        [ 0x0A8D, 0x0A8D ],
        [ 0x0A8F, 0x0A91 ],
        [ 0x0A93, 0x0AA8 ],
        [ 0x0AAA, 0x0AB0 ],
        [ 0x0AB2, 0x0AB3 ],
        [ 0x0AB5, 0x0AB9 ],
        [ 0x0ABD, 0x0AC5 ],
        [ 0x0AC7, 0x0AC9 ],
        [ 0x0ACB, 0x0ACD ],
        [ 0x0AD0, 0x0AD0 ],
        [ 0x0AE0, 0x0AE0 ],
        [ 0x0AE6, 0x0AEF ],
        [ 0x0B01, 0x0B03 ],
        [ 0x0B05, 0x0B0C ],
        [ 0x0B0F, 0x0B10 ],
        [ 0x0B13, 0x0B28 ],
        [ 0x0B2A, 0x0B30 ],
        [ 0x0B32, 0x0B33 ],
        [ 0x0B36, 0x0B39 ],
        [ 0x0B3D, 0x0B3D ],
        [ 0x0B3E, 0x0B43 ],
        [ 0x0B47, 0x0B48 ],
        [ 0x0B4B, 0x0B4D ],
        [ 0x0B5C, 0x0B5D ],
        [ 0x0B5F, 0x0B61 ],
        [ 0x0B66, 0x0B6F ],
        [ 0x0B82, 0x0B83 ],
        [ 0x0B85, 0x0B8A ],
        [ 0x0B8E, 0x0B90 ],
        [ 0x0B92, 0x0B95 ],
        [ 0x0B99, 0x0B9A ],
        [ 0x0B9C, 0x0B9C ],
        [ 0x0B9E, 0x0B9F ],
        [ 0x0BA3, 0x0BA4 ],
        [ 0x0BA8, 0x0BAA ],
        [ 0x0BAE, 0x0BB5 ],
        [ 0x0BB7, 0x0BB9 ],
        [ 0x0BBE, 0x0BC2 ],
        [ 0x0BC6, 0x0BC8 ],
        [ 0x0BCA, 0x0BCD ],
        [ 0x0BE7, 0x0BEF ],
        [ 0x0C01, 0x0C03 ],
        [ 0x0C05, 0x0C0C ],
        [ 0x0C0E, 0x0C10 ],
        [ 0x0C12, 0x0C28 ],
        [ 0x0C2A, 0x0C33 ],
        [ 0x0C35, 0x0C39 ],
        [ 0x0C3E, 0x0C44 ],
        [ 0x0C46, 0x0C48 ],
        [ 0x0C4A, 0x0C4D ],
        [ 0x0C60, 0x0C61 ],
        [ 0x0C66, 0x0C6F ],
        [ 0x0C82, 0x0C83 ],
        [ 0x0C85, 0x0C8C ],
        [ 0x0C8E, 0x0C90 ],
        [ 0x0C92, 0x0CA8 ],
        [ 0x0CAA, 0x0CB3 ],
        [ 0x0CB5, 0x0CB9 ],
        [ 0x0CBE, 0x0CC4 ],
        [ 0x0CC6, 0x0CC8 ],
        [ 0x0CCA, 0x0CCD ],
        [ 0x0CDE, 0x0CDE ],
        [ 0x0CE0, 0x0CE1 ],
        [ 0x0CE6, 0x0CEF ],
        [ 0x0D02, 0x0D03 ],
        [ 0x0D05, 0x0D0C ],
        [ 0x0D0E, 0x0D10 ],
        [ 0x0D12, 0x0D28 ],
        [ 0x0D2A, 0x0D39 ],
        [ 0x0D3E, 0x0D43 ],
        [ 0x0D46, 0x0D48 ],
        [ 0x0D4A, 0x0D4D ],
        [ 0x0D60, 0x0D61 ],
        [ 0x0D66, 0x0D6F ],
        [ 0x0E01, 0x0E3A ],

        [ 0x0E40, 0x0E5B ],
//      [ 0x0E50, 0x0E59 ],     // Digits? Why does this overlap previous?

        [ 0x0E81, 0x0E82 ],
        [ 0x0E84, 0x0E84 ],
        [ 0x0E87, 0x0E88 ],
        [ 0x0E8A, 0x0E8A ],
        [ 0x0E8D, 0x0E8D ],
        [ 0x0E94, 0x0E97 ],
        [ 0x0E99, 0x0E9F ],
        [ 0x0EA1, 0x0EA3 ],
        [ 0x0EA5, 0x0EA5 ],
        [ 0x0EA7, 0x0EA7 ],
        [ 0x0EAA, 0x0EAB ],
        [ 0x0EAD, 0x0EAE ],
        [ 0x0EB0, 0x0EB9 ],
        [ 0x0EBB, 0x0EBD ],
        [ 0x0EC0, 0x0EC4 ],
        [ 0x0EC6, 0x0EC6 ],
        [ 0x0EC8, 0x0ECD ],
        [ 0x0ED0, 0x0ED9 ],
        [ 0x0EDC, 0x0EDD ],
        [ 0x0F00, 0x0F00 ],
        [ 0x0F18, 0x0F19 ],
        [ 0x0F20, 0x0F33 ],
        [ 0x0F35, 0x0F35 ],
        [ 0x0F37, 0x0F37 ],
        [ 0x0F39, 0x0F39 ],
        [ 0x0F3E, 0x0F47 ],
        [ 0x0F49, 0x0F69 ],
        [ 0x0F71, 0x0F84 ],
        [ 0x0F86, 0x0F8B ],
        [ 0x0F90, 0x0F95 ],
        [ 0x0F97, 0x0F97 ],
        [ 0x0F99, 0x0FAD ],
        [ 0x0FB1, 0x0FB7 ],
        [ 0x0FB9, 0x0FB9 ],
        [ 0x10A0, 0x10C5 ],
        [ 0x10D0, 0x10F6 ],
        [ 0x1E00, 0x1E9B ],
        [ 0x1EA0, 0x1EF9 ],
        [ 0x1F00, 0x1F15 ],
        [ 0x1F18, 0x1F1D ],
        [ 0x1F20, 0x1F45 ],
        [ 0x1F48, 0x1F4D ],
        [ 0x1F50, 0x1F57 ],
        [ 0x1F59, 0x1F59 ],
        [ 0x1F5B, 0x1F5B ],
        [ 0x1F5D, 0x1F5D ],
        [ 0x1F5F, 0x1F7D ],
        [ 0x1F80, 0x1FB4 ],
        [ 0x1FB6, 0x1FBC ],
        [ 0x1FBE, 0x1FBE ],
        [ 0x1FC2, 0x1FC4 ],
        [ 0x1FC6, 0x1FCC ],
        [ 0x1FD0, 0x1FD3 ],
        [ 0x1FD6, 0x1FDB ],
        [ 0x1FE0, 0x1FEC ],
        [ 0x1FF2, 0x1FF4 ],
        [ 0x1FF6, 0x1FFC ],
        [ 0x203F, 0x2040 ],
        [ 0x207F, 0x207F ],
        [ 0x2102, 0x2102 ],
        [ 0x2107, 0x2107 ],
        [ 0x210A, 0x2113 ],
        [ 0x2115, 0x2115 ],
        [ 0x2118, 0x211D ],
        [ 0x2124, 0x2124 ],
        [ 0x2126, 0x2126 ],
        [ 0x2128, 0x2128 ],
        [ 0x212A, 0x2131 ],
        [ 0x2133, 0x2138 ],
        [ 0x2160, 0x2182 ],
        [ 0x3005, 0x3007 ],
        [ 0x3021, 0x3029 ],
        [ 0x3041, 0x3093 ],
        [ 0x309B, 0x309C ],
        [ 0x30A1, 0x30F6 ],
        [ 0x30FB, 0x30FC ],
        [ 0x3105, 0x312C ],
        [ 0x4E00, 0x9FA5 ],
        [ 0xAC00, 0xD7A3 ],
        [ 0xFF21, 0xFF3A ],
        [ 0xFF41, 0xFF5A ],
    ];

    if (u > 0xD7A3 && u < 0xFF21)
        goto Lisnot;

    // Binary search
    uint mid;
    uint low;
    uint high;

    low = 0;
    high = table.length - 1;
    while (cast(int)low <= cast(int)high)
    {
        mid = (low + high) >> 1;
        if (u < table[mid][0])
            high = mid - 1;
        else if (u > table[mid][1])
            low = mid + 1;
        else
            goto Lis;
    }

Lisnot:
    debug
    {
        for (int i = 0; i < table.length; i++)
        {
            assert(u < table[i][0] || u > table[i][1]);
        }
    }
    return false;

Lis:
    debug
    {
        for (int i = 0; i < table.length; i++)
        {
            if (u >= table[i][0] && u <= table[i][1])
                return 1;
        }
        assert(0);              // should have been in table
    }
    return true;
}

unittest
{
    for (uint i = 0; i < 0x80; i++)
    {
        if (i >= 'A' && i <= 'Z')
            assert(isUniAlpha(i));
        else if (i >= 'a' && i <= 'z')
            assert(isUniAlpha(i));
        else
            assert(!isUniAlpha(i));
    }
}


