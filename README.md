# simple_hex_patch
Simple binary hex patcher written on ZIG lang (www.ziglang.org)

- this code not perfect, I'm not responsible for any problems with it.
- it works for linux(zig build -Drelease-small) and windows(-Drelease-small=true -Dtarget=x86_64-windows-gnu) targets
- compiled linux version not using any dynamic libraries, fully autonomus executable!
- because it is simple, to patch file, it fully loaded in mem buffer
- search sequence xored for fun and profit (to avoid patching for patcher :smile: )

# usage
- you need to install zig language  
- optionally you can install very handy bbe utility (https://sourceforge.net/projects/bbe-/). It is a sed-like editor for binary files.
- then clone this repository: 
> git clone https://github.com/lexaone/simple_hex_patch
> cd simple_hex_patch

- first, prepare the patch - you need to create search sequence, replace sequence, and choose any xor byte:
example: search sequence "\xA1\xB1\xC1\xD1\xE1\xF1"
        replace sequence "\xA2\xB2\xC2\xD2\xE2\xF2"
        I choose 'A' as xor byte
- xored by 'A' search sequence: "x39\x00\x70\xf0\x80\x90\xa0\xb0" 
- now you can edit src/main.zig and replace search_string_xored, replace_string,xor_val constants with new ones;
- then compile your app: 
> zig build -Drelease-small
- optionally, you can strip the executable (I like small files!): 
> strip ./zig-out/bin/simple_hex_patch
- congratulations! you simple and standalone patch prepared!
```
# now test it:
echo -n "\x00\xFF\0x00\xFF\xA1\xB1\xC1\xD1\xE1\xF1\xFF\x00\xFF\0x00\xFF\0xAA" >file_to_patch
cat file_to_patch|bbe -e 'p H'
x00 xff x00 xff xa1 xb1 xc1 xd1 xe1 xf1 xff x00 xff x00 xff xaa
#we want to replace \xA1\xB1\xC1\xD1\xE1\xF1 to \xA2\xB2\xC2\xD2\xE2\xF2, 
#so search sequence is \xA1\xB1\xC1\xD1\xE1\xF1 , replace seqence is 
#\xA2\xB2\xC2\xD2\xE2\xF2 and we choose xor value as 'A' (just as example)

echo -n "\xA1\xB1\xC1\xD1\xE1\xF1"|bbe -e '^ A;p H'
xe0 xf0 x80 x90 xa0 xb0
#xored by 'A' sequence is "\xe0\xf0\x80\x90\xa0\xb0"
#edit file src/main.zig
#compile it
./zig-out/bin/simple_hex_patch file_to_patch patched_file
---===@@@ Simple binary patcher (c)2022 by lexa @@@===---

## Sequence found in file file_to_patch,offset:4
## Patching...
## Writing back...
## Done...
cat patched_file|bbe -e 'p H'         
x00 xff x00 xff xa2 xb2 xc2 xd2 xe2 xf2 xff x00 xff x00 xff xaa
```
