#!/bin/sh
# ARM64EC 用のコンパイラのラッパー。使い方: ec-wrapper.sh <llvm-mingw の bin> <clang|clang++> <出力先>
# arm64ec の clang が受け付けない x86 向けの選択肢 (-mwindows、-msse* など) を取り除き、
# C++ は新しい libc++ に合わせて -std=gnu++0x を -std=gnu++14 にする
bin="$1"; t="$2"; out="$3"
cat > "$out" <<EOT
#!/bin/sh
for a in "\$@"; do
    shift
    case "\$a" in
    -mwindows|-msse*|-mssse3|-mavx*|-mmmx|-mfpmath=*) ;;
    -std=gnu++0x|-std=gnu++11) set -- "\$@" -std=gnu++14 ;;
    *) set -- "\$@" "\$a" ;;
    esac
done
exec $bin/arm64ec-w64-mingw32-$t "\$@"
EOT
chmod +x "$out"
