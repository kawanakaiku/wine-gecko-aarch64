#!/bin/sh
# llvm-mingw に aarch64 版の無い取り込みライブラリを、x86_64 版の公開名から作る
# 使い方: mkimplibs.sh <llvm-mingw の最上位> <出力先> [arm64|arm64ec]
set -e
top="$1"; out="$2"; m="${3:-arm64}"
mkdir -p "$out"
for l in wintrust rasdlg rasapi32 esent; do
    [ -f "$top/aarch64-w64-mingw32/lib/lib$l.a" ] && continue
    {
        echo "LIBRARY $l.dll"
        echo "EXPORTS"
        "$top/bin/llvm-nm" "$top/x86_64-w64-mingw32/lib/lib$l.a" 2>/dev/null \
            | sed -n 's/^.* T __imp_\(.*\)$/\1/p' | sort -u
    } > "$out/$l.def"
    "$top/bin/llvm-dlltool" -m "$m" -d "$out/$l.def" -l "$out/lib$l.a"
    echo "lib$l.a ($m): $(grep -c . "$out/$l.def") 行"
done
