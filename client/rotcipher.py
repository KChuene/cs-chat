import sys

def rot47(text: str) -> str:
    result = []
    for char in text:
        dec = ord(char)
        if dec < 33 or dec > 126:
            result.append(char)
            continue

        rotdec = dec
        if dec + 47 <= 126:
            rotdec = dec + 47
        else:
            rotdec = 32 + ((dec + 47) - 126)

        result.append( chr(rotdec) )

    return ''.join(result)

def reverse(text: str) -> str:
    return text[::-1]

def obfuscate(text: str) -> str:
    _rot47 = rot47(text)
    return reverse(_rot47)

def deobfuscate(text: str) -> str:
    rev = reverse(text)
    return rot47(rev)

def bye(code: int, msg: str):
    if __name__!="__main__":
        sys.exit(-1)
    
    print(msg)
    print("\nusage:")
    print("\tprogram.py -e <text_to_obfuscate>")
    print("\tprogram.py -d <text_to_deobfuscate>")
    sys.exit(code)

if __name__=="__main__":
    if not len(sys.argv) >= 3:
        bye(-1, "Not enough arguments.")

    mode = sys.argv[1]
    if mode == "-e":
        print( obfuscate(sys.argv[2]) )
    elif mode == "-d":
        print( deobfuscate(sys.argv[2]) )
    else:
        bye(-1, "Only modes -e and -d are valid.")

    

