#!/bin/sh
# ビルドのログからコンパイルとリンクのエラーを種類ごとに数える
log="$1"
echo "== 失敗した make の対象"
grep -E '^make.*\*\*\* .*(Error|エラー) [0-9]' "$log" | sed -E 's/^make\[[0-9]+\]: //' | sort | uniq -c | sort -rn | head -60
echo
echo "== エラーの種類 (場所と文面)"
grep -E ' error: |undefined (reference|symbol)' "$log" | grep -v 'too many errors' \
  | sed -E 's#^.*/(src|obj)/##; s/:[0-9]+:[0-9]+:/:/' | sort | uniq -c | sort -rn | head -150
