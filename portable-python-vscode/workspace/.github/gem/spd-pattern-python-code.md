※作成例
# SPD for Python

## 1.コメント
・※から行末まではコメントであり、SPDの構造・処理としては解釈しない。
・コメントは生成コードの対応する位置に # コメントとして転記する。
・引用符("…")・鉤括弧(「…」)内の※はコメント開始とみなさない。
・※だけの行は構造解析上は存在しないものとして扱う(縦線の連結を切らない)。

```
税込み価格の計算(※による1行コメント)
│
├─変数priceにキーボードから整数の価格を入力する ※税抜き価格
│  ※ここからは税込み価格の計算と表示
└─priceに1.1を掛けて整数に丸め、"税込=〇〇"の形式で表示する
```

```python
price = int(input("価格> "))  # 税抜き価格

# ここからは税込み価格の計算と表示
print(f"税込={round(price * 1.1)}")
```

## 2.基本構造

### 2.1 順次構造

```
複合代入演算子の働き
│
├─変数var に10を代入する
├─var を１増やす : var += 1
└─var を表示する
```

```python
var = 10
var += 1
print(var)
```

### 2.2 分岐構造

#### 2.2.1 if文

```
平方根を計算する
│
├─変数x にキーボードから整数を入力する
├─◇─xは負
│        └─x *= -1
├─x の平方根を計算して、変数value に代入する
└─value を表示する
```

```python
x = int(input("整数> "))

# 負の値は符号を反転してから平方根を計算する
if x < 0:
    x *= -1

value = x ** 0.5
print(value)
```

#### 2.2.2 if-else文と書き方のTips

- 単純な書き方
```
サイコロゲーム
│
├─tkxlib　からdice関数をインポートする
├─サイコロを振って（dice()）出目を変数numberに代入する
│
└─◇─numberは6 である
         │    └─"当たり" と表示する
         └─else
               └─"はずれ" と表示する
```

```python
from tkxlib import dice

number = dice()

# 出目が6かどうかで当たり・はずれを決める
if number == 6:
    print("当たり")
else:
    print("はずれ")
```

- タイトルを付ける（段階的詳細化）
```
サイコロゲーム
│
├─tkxlibからdice関数をインポートする
├─サイコロを振って（dice()）出目を変数numberに代入する
│
└─結果の表示─◇─numberは6 である
                │    └─"当たり" と表示する
                └─else
                      └─"はずれ" と表示する
```

```python
from tkxlib import dice

number = dice()

# 結果の表示
if number == 6:
    print("当たり")
else:
    print("はずれ")
```

- 枝を折り曲げてコンパクトにする
```
サイコロゲーム
│
├─tkxlibからdice関数をインポートする
├─サイコロを振って（dice()）出目を変数numberに代入する
│
└─結果を表示する
      └─◇─numberは6である
          │    └─"当たり" と表示する
          └─else
                └─"はずれ" と表示する
```

```python
from tkxlib import dice

number = dice()

# 結果を表示する
if number == 6:
    print("当たり")
else:
    print("はずれ")
```

#### 2.2.3 if-elif文

- 複数の場合分け
```
サイコロゲーム
│
├─キーボードから英単語を入力してwordに入れる
└─◇─wordは"cat" である
    │    └─"ネコ" と表示する
    │
    ◇─wordは"dog" である
    │    └─"イヌ" と表示する
    │
    ◇─wordは"rabbit"である
    │    └─"ウサギ" と表示する
    │
    └─else
          └─"辞書にありません" と表示する
```

```python
word = input("英単語> ")

# 入力された英単語に対応する日本語を表示する
if word == "cat":
    print("ネコ")
elif word == "dog":
    print("イヌ")
elif word == "rabbit":
    print("ウサギ")
else:
    print("辞書にありません")
```

- 数値の範囲での場合分け
```
身長の階級（if-elif 文）
│
├─キーボードから身長（cm）を変数heightに入力する（入力プロンプトは "身長>"）
│
└─身長の階級を求める─◇─180cm 以上
                        │    └─"A"と表示する
                        ◇─170cm 以上
                        │    └─"B"と表示する
                        ◇─160cm 以上
                        │    └─"C"と表示する
                        └─else
                              └─"D"と表示する
```

```python
height = float(input("身長>"))

# 身長の階級を求める
if height >= 180:
    print("A")
elif height >= 170:
    print("B")
elif height >= 160:
    print("C")
else:
    print("D")
```

### 2.3 反復構造

#### 2.3.1 for文

- 反復して表示する
```
リストの要素を表示する
│
├─データの準備─整数のリストを作成して、変数numbers に代入する
│                    └─要素は(10, 20, 30)
│
└─表示処理─↻─for:number←numbers
              │
              └─numberをコンソールに表示する
```

```python
numbers = [10, 20, 30]

# リストの全要素を表示する
for number in numbers:
    print(number)
```

- 反復して計算する
```
リストの要素を集計する
│
├─データの準備─整数のリストを作成して、変数numbers に代入する
│                    └─要素は(10, 20, 30)
│
├─合計の計算┬─total = 0とする
│            └─↻─for:number←numbers
│                │
│                └─numberをtotal に加算する
│
├─平均の計算─平均を計算して変数ave に代入する
│                └─平均はtotalをnumbersの要素数で割り、小数点以下1桁までに丸める
│
└─結果の表示┬─合計を"合計＝〇〇"の書式でコンソールに表示する
              └─平均を"平均＝〇〇"の書式でコンソールに表示する
```

```python
numbers = [10, 20, 30]

# 合計の計算
total = 0
for number in numbers:
    total += number

# 平均の計算
ave = round(total / len(numbers), 1)

# 結果の表示
print(f"合計＝{total}")
print(f"平均＝{ave}")
```

- オブジェクトのリストを操作する
```
データクラス：Product
│
├─目的：製品を表すデータクラス
└─属性
      ├─製品コード：code: str
      ├─製品名：name: str
      ├─価格：price: int
      └─在庫：stock: bool

オブジェクトのリスト
│
├─データの準備─Productクラスのインスタンスを3 つ作って、リストproductsに代入する
│                      └─products ←[Product(MT890, ステンレスネジ ,280, False),
│                                      Product(MT810, タッピングネジ ,160, True ),
│                                      Product(MT900, スクリューネジ ,350, True )]
│
└─表示処理─↻─for:p←products
              │
              └─商品名（p.name）と価格（p.price ）をコロンとタブで区切って表示する
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Product:
    """製品を表すデータクラス。"""

    code: str
    name: str
    price: int
    stock: bool


products = [Product("MT890", "ステンレスネジ", 280, False),
            Product("MT810", "タッピングネジ", 160, True),
            Product("MT900", "スクリューネジ", 350, True)]

# 商品名と価格をコロンとタブで区切って表示する
for p in products:
    print(f"{p.name}:\t{p.price}")
```

#### 2.3.2 while文

- 無限ループのパターン
```
電卓プログラム
│
├─準備─total = 0とする
├─合計の計算─↻─while:True  ※無限ループ
│              │
│              ├─変数numberにキーボードから整数を入力する
│              ├─◇─numberは0である
│              │        └─breakでループを脱出する
│              ├─numberをコンソールに表示する
│              └─totalにnumberを加算する
│
└─結果の表示┬─終了時の区切りとして"------"を表示する
              └─"合計= 〇〇"の形式でtotal を表示する
```

```python
total = 0

# 合計の計算
while True:  # 無限ループ
    number = int(input("整数> "))
    if number == 0:
        break
    print(number)
    total += number

# 結果の表示
print("------")
print(f"合計= {total}")
```

- ウォルラス演算子の例
```
電卓プログラム（while 文、入力して条件判定のパターン）
│
├─変数の準備┬─total = 0とする
│            └─変数numberを用意する
│
├─合計の計算
│    └─↻─while:numberにキーボードから整数を入力し、それが0 でない間繰り返す
│        │
│        ├─numberをコンソールに表示する
│        └─totalにnumberを加算する
│
└─結果の表示┬─終了時の区切りとして"------"を表示する
              └─"合計= 〇〇"の形式でtotalを表示する
```

```python
total = 0

# 入力した整数が0でない間、合計に加算する
while (number := int(input("整数> "))) != 0:
    print(number)
    total += number

# 結果の表示
print("------")
print(f"合計= {total}")
```

### 2.4 リストの操作

#### 2.4.1 リスト内包表記

- 変換操作

```
値の変換
│
├─変換元のリストを用意する─numbers←[2, 7, 8, 5, 6]
│
├─偶数の要素だけを取り出し、2倍して新しいリストにする
│      │
│      └─リスト内包表記で新しいリストnew_numbers を作成する
│          ├─for: num←numbers
│          └─変換: num * 2
│
└─new_numbersを表示する
```

```python
numbers = [2, 7, 8, 5, 6]

new_numbers = [num * 2 for num in numbers]

print(new_numbers)
```

- 条件付きで変換する

```
条件を付けて変換する
│
├─変換元のリストを用意する─numbers←[2, 7, 8, 5, 6]
│
├─偶数の要素だけを取り出し、2倍して新しいリストにする
│      │
│      └─リスト内包表記で新しいリストnew_numbers を作成する
│          ├─for: num←numbers
│          ├─変換: num * 2
│          └─条件: num % 2 == 0
│
└─new_numbersを表示する
```

```python
numbers = [2, 7, 8, 5, 6]

# 偶数の要素だけを取り出し、2倍して新しいリストにする
new_numbers = [num * 2 for num in numbers if num % 2 == 0]

print(new_numbers)
```

- 抽出する（条件なし）

```
偶数だけのリストにする
│
├─変換元のリストを用意する─numbers ←[2, 7, 8, 5, 6]
│
├─偶数の要素だけを取り出し、2 倍して新しいリストにする
│      │
│      └─リスト内包表記で新しいリストnew_numbers を作成する
│          ├─for: num← numbers
│          └─条件: num % 2 == 0
│
└─new_numbersを表示する
```

```python
numbers = [2, 7, 8, 5, 6]

# 偶数の要素だけを取り出して新しいリストにする
new_numbers = [num for num in numbers if num % 2 == 0]

print(new_numbers)
```

- 2次元リストを扱うリスト内包表記

```
体重と身長のリストをBMIのリストに変換する
│
├─変数dataに[[65.5, 172.8],[50.8, 158.2],[75.7, 178.3]]を代入する
├─リスト内包表記で新しいリストbmiを作成する
│    ├─for: weight, height ← data  ※アンパック
│    └─変換: weight / (height / 100) ** 2
└─bmiを表示する
```

```python
data = [[65.5, 172.8], [50.8, 158.2], [75.7, 178.3]]

bmi = [weight / (height / 100) ** 2 for weight, height in data]  # アンパック

print(bmi)
```

#### 2.4.2 イテレータ関数

- インデックスを付けるenumerate関数

```
項番付きで表示する
│
├─リストを用意する─animals←["dog", "cat", "rabbit"]
│
└─要素をインデックス付きで表示する
                  │
                  └─↻─for: i, animal← enumerate(animals)
                      └─iとanimalを並べて表示する
```

```python
animals = ["dog", "cat", "rabbit"]

# 要素をインデックス付きで表示する
for i, animal in enumerate(animals):
    print(i, animal)
```

- 複数のリストを合併するzip関数

```
名前のリストと身長のリストを並べて表示する
│
├─名前のリストと身長のリストを用意する
│    ├─names←[ "田中", "佐藤", "山田"]
│    └─heights←[175.3, 163.5, 182.1]
│
└─名前と身長を並べて表示する─↻─ for: name, height← zip(names, heights)
                                     └─nameとheightを並べて表示する
```

```python
names = ["田中", "佐藤", "山田"]
heights = [175.3, 163.5, 182.1]

# 名前と身長を並べて表示する
for name, height in zip(names, heights):
    print(name, height)
```

### 2.5 辞書の操作

#### 2.5.1 辞書の操作

- 辞書のキーと値を表示する

```
辞書のすべてのキーと値を表示する
  │
  ├─変数score に成績を表す辞書を代入する
  │      └─score←{"id": 1201, "English": 90, "Math": 85, "Language": 92}
  │
  └─scoreのすべてのキーと値を表示する
        └─↻─for: key← score
            │
            └─キーと値をコロン（:）で区切って表示する
```

```python
score = {"id": 1201, "English": 90, "Math": 85, "Language": 92}

# scoreのすべてのキーと値をコロンで区切って表示する
for key in score:
    print(f"{key}:{score[key]}")
```

- 辞書のビュー（items()）

```
辞書のキーと値を表示する
│
├─変数score に成績を表す辞書を代入する
│      └─score←{"id": 1201, "English": 90, "Math": 85, "Language": 92}
│
└─scoreのすべてのキーと値を表示する
      └─↻─for: key, value ← score.items()
          │
          └─キーと値をコロン（:）で区切って表示する
```

```python
score = {"id": 1201, "English": 90, "Math": 85, "Language": 92}

# scoreのすべてのキーと値をコロンで区切って表示する
for key, value in score.items():
    print(f"{key}:{value}")
```

- 辞書のリストから要素を検索する

```
ユーザーのリストから特定のユーザーを検索する
│
├─ユーザーのリストを作成する:
│  └─users = [
│              {"id": 103, "name": "tanaka", "role": "admin"},
│              {"id": 105, "name": "sasaki", "role": "user"},
│              {"id": 100, "name": "maeda", "role": "user"}, ]
│
└─sasakiを検索して表示する:
      └─↻─for: user ← users
          │
          └─◇─userの名前（name）はsasakiである
                    ├─printでuserのid, name, roleを並べて表示する
                    └─breakでループを抜ける
```

```python
users = [
    {"id": 103, "name": "tanaka", "role": "admin"},
    {"id": 105, "name": "sasaki", "role": "user"},
    {"id": 100, "name": "maeda", "role": "user"},
]

# sasakiを検索して表示する
for user in users:
    if user["name"] == "sasaki":
        print(user["id"], user["name"], user["role"])
        break
```

- 辞書の並べ替え

```
辞書のリストのソート
│
├─ユーザー辞書のリストを作成する
│      └─users = [
│            {"id": 103, "name": "tanaka", "role": "admin"},
│            {"id": 105, "name": "sasaki", "role": "user"},
│            {"id": 100, "name": "maeda", "role": "user"}, ]
│
├─ユーザー辞書のリストusersを、"id"の降順にソートする
│
└─リストの全要素を表示する─↻─for: user←users
                              │
                              └─userをprintで表示する
```

```python
users = [
    {"id": 103, "name": "tanaka", "role": "admin"},
    {"id": 105, "name": "sasaki", "role": "user"},
    {"id": 100, "name": "maeda", "role": "user"},
]

users.sort(key=lambda user: user["id"], reverse=True)

# リストの全要素を表示する
for user in users:
    print(user)
```

#### 2.5.2 辞書内包表記

- 辞書を変換して別形式の辞書を作る

```
検索用の辞書を作成する
│
├─ユーザーのリストを作成する:
│      └─users←[
│              {"id": 103, "name": "tanaka", "role": "admin"},
│              {"id": 105, "name": "sasaki", "role": "user"},
│              {"id": 100, "name": "maeda", "role": "user"}, ]
│
├─検索用の辞書を作る
│      └─辞書内包表記で、users からuser_mapを作る
│            ├─for: user ← users
│            └─変換
│                  ├─キー: user["name"]
│                  └─値: {"id": user["id"], "role": user["role"]}
│
└─user_mapからsasakiを検索して表示する
    ├─user←user_map["sasaki"]
    └─printで"sasaki"とuser["id"]とuser["role"]を並べて表示する
```

```python
users = [
    {"id": 103, "name": "tanaka", "role": "admin"},
    {"id": 105, "name": "sasaki", "role": "user"},
    {"id": 100, "name": "maeda", "role": "user"},
]

# 名前をキーにした検索用の辞書を作る
user_map = {
    user["name"]: {"id": user["id"], "role": user["role"]}
    for user in users
}

user = user_map["sasaki"]
print("sasaki", user["id"], user["role"])
```

### 2,6 関数

#### 2.6.1 関数の定義

- 定義方法と使用例

```
関数: score
│
├─目的：3 科目のテストの合計と平均を計算する
├─引数
│    ├─math：数学のテストの点数
│    ├─science ：理科のテストの点数
│    └─english ：英語のテストの点数
│
├─戻り値：合計と平均のタプル
│
└─処理
    ├─合計を計算して変数total に代入する
    ├─平均を計算して小数点以下1 桁までに丸めて、変数average に代入する
    └─totalとaverageをタプルにして返す

関数の使用例
│
├─score(80, 70, 60) を実行して、戻り値を変数total とaverage に代入する
└─合計(total) と平均(average) を、"合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

```python
def score(math, science, english):
    """3科目のテストの合計と平均を計算します。"""
    total = math + science + english
    average = round(total / 3, 1)
    return total, average


total, average = score(80, 70, 60)
print(f"合計= {total}、平均= {average:.1f}")
```

#### 2.6.2 デフォルト引数

```
関数: calc_price
│
├─目的：税込みの価格を計算する
├─引数
│    ├─price:　商品の税抜き価格
│    └─tax_rate = 0.1: 税率    ※デフォルト引数
├─戻り値：税込みの価格
└─処理
    └─税込みの価格を計算し、整数にして返す
              └─return　int(price * (1 + tax_rate))

関数の使用例
│
├─"価格＝〇〇"の形式でcalc_price(1000)の戻り値を表示する
└─"価格＝〇〇"の形式でcalc_price(1000, 0.08)の戻り値を表示する
```

```python
def calc_price(price, tax_rate=0.1):
    """税込みの価格を計算します。"""
    return int(price * (1 + tax_rate))


print(f"価格＝{calc_price(1000)}")
print(f"価格＝{calc_price(1000, 0.08)}")
```

#### 2.6.3 main関数

- main関数の定義例

```
関数: main
  │
  ├─目的：3 科目の点数から合計と平均を求めて表示する
  ├─引数: なし
  ├─戻り値: なし
  │
  └─処理
        ├─数学・理科・英語の点数をキーボードから入力する
        ├─score() を呼び出して、戻り値を変数total とaverage に代入する
        └─合計(total) と平均(average) を、 "合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

```python
def main():
    """3科目の点数から合計と平均を求めて表示します。"""
    math = int(input("数学> "))
    science = int(input("理科> "))
    english = int(input("英語> "))
    total, average = score(math, science, english)
    print(f"合計= {total}、平均= {average:.1f}")


if __name__ == "__main__":
    main()
```

- main関数の簡略定義

```
※main　関数の省略形（main　は引数も戻り値もないので、目的・引数・戻り値の枝は省略してよい）
関数: main
  │
  └─処理
        ├─数学・理科・英語の点数をキーボードから入力する
        ├─score() を呼び出して、戻り値を変数total とaverage に代入する
        └─合計(total) と平均(average) を、 "合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

```python
def main():
    """3科目の点数から合計と平均を求めて表示します。"""
    math = int(input("数学> "))
    science = int(input("理科> "))
    english = int(input("英語> "))
    total, average = score(math, science, english)
    print(f"合計= {total}、平均= {average:.1f}")


if __name__ == "__main__":
    main()
```

### 2.7 ファイルとディレクトリの操作

- パスの結合

```
 2つのパスを結合する
│
├─ベースパスの作成──"c:/python" をパスオブジェクトにしてpathに入れる
├─ファイル名を得る──キーボードから入力したファイル名をfname に入れる
├─ベースパスとファイル名を結合してpathに入れる
└─pathを表示する
```

```python
from pathlib import Path

# ベースパスの作成
path = Path("c:/python")

# ファイル名を得る
fname = input("ファイル名> ")

path = path / fname
print(path.as_posix())
```

- パスオブジェクトから再帰的にすべてのファイル名を取り出す

```
指定したディレクトリから再帰的にすべてのファイル名を取り出して表示する
│
├─"c:/python/workspace" のパスをpathに入れる
└─↻─for:p←pathの中の全てのパス
    │
    └─◇─pはファイルである
                └─ファイル名を表示する
```

```python
from pathlib import Path

path = Path("c:/python/workspace")

# 再帰的にすべてのパスをたどり、ファイルの名前だけを表示する
for p in path.rglob("*"):
    if p.is_file():
        print(p.name)
```

### 2.8 例外処理とファイル入出力

#### 2.8.1 テキストファイルの入力

- 一括読み込み

```
テキストファイルの一括読み込み（例外処理）
│
├─入力ファイルのパスを用意する─path←fruit.txt のパス
│
└─ファイル入力処理─〇─try
                      │    ├─ファイルの全内容を一括読み出しして、変数dataに代入する
                      │    │      └─ data ← path.read_text(encoding="utf-8")
                      │    └─print でdataをコンソールに出力する
                      │
                      〇─except (OSError, UnicodeDecodeError) as e:
                            └─ "ファイル入力エラー" と表示する
```

```python
from pathlib import Path

path = Path("fruit.txt")

# ファイルの全内容を一括で読み出して表示する
try:
    data = path.read_text(encoding="utf-8")
    print(data)
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

- 行単位の読み込み

```
行単位のファイル読み込み（例外処理）
│
├─入力ファイルのパスを用意する─path←fruit.txt のパス
│
└─ファイル入力処理
      │
      └─〇─ try: with文で、pathを入力モードで開いてファイルオブジェクトをf にセットする
          │    └─↻─ for: line← f
          │            └─ 1行分のデータ（line）をコンソールに表示する
          │
          〇─ except (OSError, UnicodeDecodeError) as e:
                └─ "ファイル入力エラー" と表示する
```

```python
from pathlib import Path

path = Path("fruit.txt")

# ファイルを1行ずつ読み出して表示する
try:
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            print(line, end="")
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

#### 2.8.2 テキストファイルの出力

- 一括出力

```
テキストファイルの一括出力（例外処理）
│
├─出力するテキストとパスを準備する┬─出力するテキストを作る
│                                  │    └─ data ← "リンゴ\nバナナ\nさくらんぼ\n"
│                                  └─path←fruit.txt のパス
│
└─ファイルへ一括出力処理─〇─try
                            │    └─テキストを一括出力する
                            │            └─ path.write_text(data, encoding="utf-8")
                            │
                            〇─except (OSError, UnicodeEncodeError) as e:
                                  └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

data = "リンゴ\nバナナ\nさくらんぼ\n"
path = Path("fruit.txt")

# テキストを一括で出力する
try:
    path.write_text(data, encoding="utf-8")
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

- リストの一括出力

```
リストの一括出力（例外処理）
│
├─準備┬─出力するリストを用意する┬─出力するリストを作る
│      │                          │    └─data← ["apple","banana","cherry"]
│      │                          │
│      │                          └─リストの各要素に改行（\n）を付加した新しいリストを作る
│      │                                │
│      │                                └─リスト内包表記で新しいリストnew_dataを作成する
│      │                                        ├─for: item ← data
│      │                                        └─変換: item + "\n"
│      │
│      └─パスの作成─path←fruit.txt のパス
│
└─リストの一括出力処理─〇─try: with 文で、pathを出力モードで開いてファイルオブジェクトをf にセットする
                          │    │
                          │    └─リストの全要素を一括出力する─ f.writelines(new_data)
                          │
                          〇─except (OSError, UnicodeEncodeError) as e:
                                │
                                └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

data = ["apple", "banana", "cherry"]

# リストの各要素に改行を付加した新しいリストを作る
new_data = [item + "\n" for item in data]

path = Path("fruit.txt")

# リストの全要素を一括で出力する
try:
    with path.open("w", encoding="utf-8") as f:
        f.writelines(new_data)
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

- 行単位の出力

```
行単位のファイル出力（例外処理）
│
├─準備┬─出力ファイルのパスを用意する─path←”data.txt”のパス
│      └─出力する変数を用意する┬─text = "こんにちは"
│                                └─number = 123
│
└─行単位のファイル出力処理
      │
      └─〇─ try: with文で、pathを出力モードで開いてファイルオブジェクトをf にセットする
          │    │
          │    ├─f.write でtextを出力する
          │    └─f.write でnumberを文字列に変換したstr(number) を出力する
          │
          〇─ except (OSError, UnicodeEncodeError) as e:
                └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

path = Path("data.txt")
text = "こんにちは"
number = 123

# textとnumberを行単位で出力する
try:
    with path.open("w", encoding="utf-8") as f:
        f.write(text)
        f.write(str(number))
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

#### 2.8.3 例外を発生させる

```
関数：sqrt
  │
  ├─目的：平方根を計算する
  ├─引数
  │    └─x ：平方根を求める値
  ├─戻り値：x の平方根の値
  │
  └─処理
        └─◇─xは負である
            │    └─ValueError("負の平方根は計算できません")を発生させる
            │
            └─else
                  └─x ** 0.5　の値を返す

計算処理
  │
  ├─tkxlibからget_float 関数をインポートする
  ├─キーボードからnumberに小数を入力する
  └─〇─try:
      │  ├─sqrt関数でnumberの平方根を計算して答えをresultに代入する
      │  └─resultを小数点以下1桁に丸めて "平方根＝〇〇. 〇"の形式で表示する
      │
      〇─except ValueError as e:
          └─"エラー\n" とe を表示する
```

```python
from tkxlib import get_float


def sqrt(x):
    """平方根を計算します。"""
    if x < 0:
        raise ValueError("負の平方根は計算できません")
    else:
        return x ** 0.5


number = get_float("小数> ")

try:
    result = sqrt(number)
    print(f"平方根＝{round(result, 1)}")
except ValueError as error:
    print("エラー\n", error)
```

## 3. クラスとオブジェクト

### 3.1 クラスの定義

```
※移譲メソッドの自動生成を除く、クラスの構成要素をすべて含む例である
※クラス宣言部と属性は省略できない
※ただし、属性がない場合は属性：なしと定義する
※それ以外は必要な構成要素だけを書く

クラス: Member
│
├─目的：会員を表すクラス
├─属性
│    ├─番号：uid: int
│    ├─名前：name: str
│    └─年齢：_age: int   ※ _を付けているので仮想属性age を作成することを意味する
│
├─特殊メソッド  ※自動生成される
│    │
│    ├─コンストラクタ         ※__init__の引数はuid 、name、age となる。age は仮想属性
│    ├─表示メソッド          ※__str__ と__repr__を生成する
│    └─等値メソッド <- uid   ※__eq__と__hash__はuid で比較する
│
├─メソッド：age  ※セッターなので@age.setter が付く
│    │
│    ├─目的：age のセッター
│    ├─引数
│    │    └─年齢：age_value: int
│    │
│    ├─戻り値：なし
│    └─処理
│          ├─◇─age_value は負である
│          │          └─ValueError("年齢は0 以上" ）を発生する
│          │
│          └─_ageにage_value を代入する
│
├─メソッド: membership_fee
│    │
│    ├─目的: 会費額を返す
│    ├─引数: なし
│    ├─戻り値: 会費 -> int
│    │
│    └─処理
│        └─ FEEを返す
│
├─クラス変数
│      └─会費: FEE: int = 5000
│
├─クラスメソッド: from_csv
│      │※メソッド宣言に@classmethodデコレーターが付く
│      │※属性にアクセスでき、第１引数はclsである
│      │※この例は、代替コンストラクタの作成例
│      │
│      ├─目的: CSV 文字列からインスタンスを作って返す
│      ├─引数
│      │    └─CSV 文字列: csv: str
│      │
│      ├─戻り値: Memberインスタンス -> Member
│      │
│      └─処理
│          ├─csv をコンマで区切ってリストdtを作る
│          ├─dtから番号（w_uid ）、氏名（w_name）、年齢（w_age ）を取り出す
│          │      │
│          │      └─〇─try
│          │          │  ├─要素を変数に取り出す─w_uid, w_name, w_age ← dt
│          │          │  ├─w_uid を整数化してw_uid に再代入する
│          │          │  └─w_age を整数化してw_age に再代入する
│          │          │
│          │          〇─except Exception as e:
│          │              └─ValueError("csv が不正")を発生させる
│          │
│          │    ※インスタンス生成には cls(...) を使う
│          └─w_uid 、w_name、w_age からインスタンスを作って返す
│
└─スタティックメソッド: is_adult
      │※メソッド宣言に@staticmethodデコレーターが付く
      │※クラスと概念的に強く結びついているが、インスタンスの状態は不要な場合に作る
      │※属性にアクセスできず、引数にclsをとらない
      │※Member.is_adult(20) のようにクラス名を付けて呼び出す
      │
      ├─目的: 年齢が18歳以上（成人）かどうかを判定する
      ├─引数
      │    └─年齢: age: int
      │
      ├─戻り値: 成人かどうか -> bool
      │
      └─処理
          └─ ageが18以上かどうか（age >= 18）を判定して返す
```

```python
class Member:
    """会員を表すクラス。"""

    # 会費
    FEE = 5000

    # __init__の引数はuid、name、ageとなる。ageは仮想属性
    def __init__(self, uid: int, name: str, age: int) -> None:
        self.uid = uid
        self.name = name
        self._age = age

    # __str__と__repr__を生成する
    def __str__(self) -> str:
        return f"Member({self.uid}, {self.name}, {self._age})"

    def __repr__(self) -> str:
        return (f"Member(uid={self.uid!r}, name={self.name!r}, "
                f"age={self._age!r})")

    # __eq__と__hash__はuidで比較する
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Member):
            return NotImplemented
        return self.uid == other.uid

    def __hash__(self) -> int:
        return hash(self.uid)

    # _を付けているので仮想属性ageを作成することを意味する
    @property
    def age(self) -> int:
        """年齢を返します。"""
        return self._age

    # セッターなので@age.setterが付く
    @age.setter
    def age(self, age_value: int) -> None:
        """ageのセッター。"""
        if age_value < 0:
            raise ValueError("年齢は0以上")
        self._age = age_value

    def membership_fee(self) -> int:
        """会費額を返します。"""
        return Member.FEE

    # メソッド宣言に@classmethodデコレーターが付く
    # 属性にアクセスでき、第1引数はclsである
    # この例は、代替コンストラクタの作成例
    @classmethod
    def from_csv(cls, csv: str) -> "Member":
        """CSV文字列からインスタンスを作って返します。"""
        dt = csv.split(",")
        try:
            w_uid, w_name, w_age = dt
            w_uid = int(w_uid)
            w_age = int(w_age)
        except Exception as error:
            raise ValueError("csvが不正")
        # インスタンス生成には cls(...) を使う
        return cls(w_uid, w_name, w_age)

    # メソッド宣言に@staticmethodデコレーターが付く
    # クラスと概念的に強く結びついているが、インスタンスの状態は不要な場合に作る
    # 属性にアクセスできず、引数にclsをとらない
    # Member.is_adult(20) のようにクラス名を付けて呼び出す
    @staticmethod
    def is_adult(age: int) -> bool:
        """年齢が18歳以上（成人）かどうかを判定します。"""
        return age >= 18
```

### 3.2 継承

#### 3.2.1 Memberクラスを継承するGeneralMemberクラス

```
クラス: GeneralMember(Member)
│
├─目的：一般会員のクラス
├─属性
│    └─レッスンメニュー: lesson_menu: list[str]
│
└─特殊メソッド
      │
      └─コンストラクタ
```

```python
class GeneralMember(Member):
    """一般会員のクラス。"""

    def __init__(self, uid: int, name: str, age: int,
                 lesson_menu: list[str]) -> None:
        super().__init__(uid, name, age)
        self.lesson_menu = lesson_menu
```

#### 3.2.2 コンストラクタのないサブラス

```
クラス: SeniorMember(Member)
│
├─目的：メソッドだけのクラス
├─属性：なし
├─特殊メソッド：なし
│
└─メソッド: membership_fee   ※オーバーライドメソッド
    │
    ├─目的: 会費額を返す
    ├─引数: なし
    ├─戻り値: 会費 -> int
    └─処理
          └─ FEE * 0.6　を整数に丸めた額を返す
```

```python
class SeniorMember(Member):
    """メソッドだけのクラス。"""

    # オーバーライドメソッド
    def membership_fee(self) -> int:
        """会費額を返します。"""
        return round(Member.FEE * 0.6)
```

#### 3.2.3 ミックスイン

```
クラス: JsonMixin
│
├─属性：なし
├─特殊メソッド：なし
│
└─メソッド: to_json
    │
    ├─目的: 属性をJSON形式の文字列にして返す
    ├─引数: なし
    ├─戻り値: クラス属性のJSON形式の文字列 -> str
    └─処理
          └─ return json.dumps(self.__dict__, ensure_ascii=False)

※継承を利用してJsonMixinのto_jsonメソッドを取り込む
クラス: GeneralMember(JsonMixin, Member)
│
├─目的：一般会員のクラス
├─属性
│    └─レッスンメニュー: lesson_menu: list[str]
│
└─特殊メソッド
      │
      └─コンストラクタ
```

```python
import json


class JsonMixin:
    """属性のJSON変換機能を提供するミックスイン。"""

    def to_json(self) -> str:
        """属性をJSON形式の文字列にして返します。"""
        return json.dumps(self.__dict__, ensure_ascii=False)


class GeneralMember(JsonMixin, Member):
    """一般会員のクラス。"""

    def __init__(self, uid: int, name: str, age: int,
                 lesson_menu: list[str]) -> None:
        super().__init__(uid, name, age)
        self.lesson_menu = lesson_menu
```

#### 3.2.4 データクラス

- データクラスの定義

```
データクラス: Person
│
├─目的：個人を表すクラス
└─属性
      ├─氏名: name: str
      └─年齢: age: int
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Person:
    """個人を表すクラス。"""

    name: str
    age: int
```

- 属性値の検査（バリデーション）

```
データクラス: Person
│
├─目的：個人を表すクラス
├─属性
│    ├─氏名: name: str
│    └─年齢: age: int
│
└─メソッド: __post_init__
    │
    ├─目的: age のバリデーション
    ├─引数: なし
    ├─戻り値: なし
    └─処理
          └─◇─ ageは負
                      └─ ValueError( "年齢は負にできません")　を発生させる
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Person:
    """個人を表すクラス。"""

    name: str
    age: int

    def __post_init__(self) -> None:
        """ageのバリデーション。"""
        if self.age < 0:
            raise ValueError("年齢は負にできません")
```
