Wine Gecko 2.47.4 の配布物 (aarch64、arm64ec、x86、x86_64)。

## ファイル

- `wine-gecko-2.47.4-aarch64`: ARM64 Windows (aarch64-w64-mingw32) 向け。Wine の aarch64 のプロセスの mshtml が読む。
  LLVM 15 系の llvm-mingw (20220906) で作成。
  gecko-2.47.4-1 の物と同じ手順だが、arm64ec 用の変更を足したパッチ (下記) から作り直している
  (arm64ec 用の変更は `__arm64ec__` の判定が主で、aarch64 版の動作には影響しない見込み)。
- `wine-gecko-2.47.4-arm64ec`: ARM64EC 向け。x64 のアプリ (ARM64EC のプロセス) の mshtml から、エミュレーションなしで使える。
  LLVM 23 系の llvm-mingw (20260908) の `arm64ec-w64-mingw32` で作成。
  ARM64EC の mshtml は `wine-gecko-2.47.4-x86_64` を探すので、使う時はこの名前に変えて置く
  (DLL は x64 のヘッダーに CHPE メタデータが付いた ARM64EC の形式で、x64 の Windows では動かない)。
- `wine-gecko-2.47.4-x86`、`wine-gecko-2.47.4-x86_64`: https://dl.winehq.org/wine/wine-gecko/2.47.4/ の公式の物の写し (変更なし)。
- `*.zip`: 各 tar.xz を展開して `zip -r -9 -X` でまとめ直したもの (中身は同じ、先頭は `wine-gecko-2.47.4-<arch>/`)。

## ソースとライセンス

- 元のソース: https://gitlab.winehq.org/wine/wine-gecko のタグ `wine-gecko-2.47.4` に、このリポジトリの
  `patches/0001-aarch64-arm64ec-mingw.patch` を当てたもの (コミット @COMMIT@、ビルドは @RUN_URL@)。
- ライセンス: Mozilla Public License 2.0 (https://www.mozilla.org/MPL/2.0/)。

## aarch64 版と arm64ec 版で無効にしたもの・仮の実装

- JIT なし (インタプリタのみ、`JS_CODEGEN_NONE`)。asm.js と wasm は使えない。JIT のコードの SEH の unwind の登録もしない。
- DLL のフック (`nsWindowsDllInterceptor.h`) は常に失敗扱い (mozglue の DLL のブロックリスト、プラグインのフック、AvailableMemoryTracker などが働かない)。
- アクセシビリティ (`--disable-accessibility`)、js-ctypes、SPS プロファイラー、webspeech、ffmpeg、fmp4、EME、DirectShow、raw は無効。
  そのため x86/x86_64 版にある AccessibleMarshal.dll、gmp-clearkey/、mozavcodec.dll、mozavutil.dll は入っていない。
- XPCOM の xptcall は Linux の aarch64 版 (AAPCS64) を COFF 向けに直したもの。
- arm64ec 版だけの注意:
  - `_NS_InvokeByIndex` (xptcall) は、呼ぶ先の関数を thunk の確認なしで直接呼ぶ。呼ばれる XPCOM のメソッドが x64 のコードだと落ちる
    (x64 の DLL が XPCOM のインターフェースを実装して Gecko に渡した場合など)。Gecko の中と ARM64EC の Wine の mshtml の間では問題ない。
  - xptcall のアセンブリのスタブには入口の thunk が無い。x64 のコードが Gecko の XPCOM のオブジェクトを vtable で直接呼ぶと落ちる。
  - x86 の SSE やアセンブリを使う所 (libyuv、libvpx、qcms、vorbis、NSS の一部など) は使わず、C の版を使う。
