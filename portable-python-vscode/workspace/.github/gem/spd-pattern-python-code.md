# SPD → Python 変換パターン集（Gem知識ファイル）

（v2.0.0 — 更新履歴は第4章を参照）

本ファイルは、SPDからPythonコードを生成するための知識ファイルである。
カスタム指示（`カスタム指示.md`）のルールと合わせて使い、生成方法に迷った場合はここの対応例に従う。

- **第1章「変換パターン早見表」**は、SPDの形と生成するPythonの対応を抽象化したものである。まずここで形を判定する。
- **第2章「作成例」**は、具体的なプログラムでの変換例である。第1章で判断がつかない場合に参照する。
- **第3章「未記入SPDの適用例」**は、カスタム指示の第0章（未記入部分は生成しない）を適用した出力例である。

本ファイルは変換の**参照表**であり、設計の入力ではない。ここに載っている処理を、与えられたSPDに無いのに補ってはならない。

---

## 1. 変換パターン早見表

### 1.1 コメント（`※`）

- `※` から行末まではコメントであり、SPDの構造・処理としては解釈しない。
- コメントは生成コードの対応する位置に `#` コメントとして転記する。
- 引用符（`"…"`）・鉤括弧（`「…」`）内の `※` はコメント開始とみなさない。
- `※` だけの行は構造解析上は存在しないものとして扱う（縦線の連結を切らない）。
- カスタム指示0.1節の `【課題】`・`【仕様】`・`【例】`・`【ヒント】` は、この転記規則の**対象外**とする（コードに書き写さない）。

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

### 1.2 分岐（`◇`）

`◇` を `if` にするか `elif` にするかは、**`◇` の左にある最初の非空白文字**で判定する。

| `◇` の左の最初の非空白文字 | 生成 |
|---|---|
| `│`、または行頭（左に何もない） | `elif` |
| それ以外（`─` など） | 独立した `if` |

桁位置（字下げ）の一致は判定材料にしない。

#### 1.2.1 パターンA：if / else

```text
├─ ◇─ 条件
│   │    └─ 真の場合の処理
│   └─ else
│          └─ 偽の場合の処理
```

```python
if 条件:
    真の場合の処理
else:
    偽の場合の処理
```

#### 1.2.2 パターンB：単独のif

```text
├─ ◇─ 条件
│        └─ 処理
```

```python
if 条件:
    処理
```

#### 1.2.3 パターンB-2：独立したifが連続する場合

どちらも `◇` の左が `─` なので、`elif` にせず独立した `if` を2つ生成する。

```text
├─ 判定1─ ◇─ 条件1
│              └─ 処理1
├─ 判定2─ ◇─ 条件2
│              └─ 処理2
```

```python
# 判定1
if 条件1:
    処理1

# 判定2
if 条件2:
    処理2
```

#### 1.2.4 パターンC：if / elif / else

2つ目以降の `◇` は左が `│` なので `elif` になる。

```text
└─ 結果を表示する─ ◇─ 条件1
                      │    └─ 処理1
                      ◇─ 条件2
                      │    └─ 処理2
                      └─ else
                            └─ デフォルト処理
```

```python
# 結果を表示する
if 条件1:
    処理1
elif 条件2:
    処理2
else:
    デフォルト処理
```

#### 1.2.5 パターンD：match

SPDに `match` と明示されている場合だけ、Pythonの `match` 文を使う。

```text
└─ ◇─ match: codeの値で判定
           ├─ case 100なら「正常終了」と表示する
           ├─ case 200か201なら「ページが存在しない」と表示する
           └─ default それ以外は「内部エラー」と表示する
```

```python
match code:
    case 100:
        print("正常終了")
    case 200 | 201:
        print("ページが存在しない")
    case _:
        print("内部エラー")
```

### 1.3 繰り返し（`↻`）

#### 1.3.1 パターンA：for

```text
└─ ↻─ for: number ← numbers
          └─ numberをコンソールに表示する
```

```python
for number in numbers:
    print(number)
```

#### 1.3.2 パターンB：while

```text
└─ ↻─ while: numberが0でない間繰り返す
          └─ 処理
```

```python
while number != 0:
    処理
```

#### 1.3.3 パターンC：無限ループ + break

```text
├─ 合計の計算─ ↻─ while: True
│                     ├─ 変数numberにキーボードから整数を入力する
│                     ├─ ◇─ numberは0である
│                     │          └─ breakでループを脱出する
│                     └─ totalにnumberを加算する
```

```python
# 合計の計算
while True:
    number = int(input("整数> "))
    if number == 0:
        break
    total += number
```

### 1.4 例外処理（`〇`）

#### 1.4.1 パターンA：try / except

```text
└─ 〇─try:
     │   └─ 通常処理
     〇─except (OSError, UnicodeDecodeError) as e:
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    通常処理
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

SPDの `as e` は、生成コードでは `as error` とする。

#### 1.4.2 パターンB：with文を含むtry

```text
└─ 〇─try: with文で、pathの入力用ファイルオブジェクトをfile_objにセットする
     │   └─ ↻─ for: line ← file_obj
     │             └─ lineをコンソールに表示する
     〇─except (OSError, UnicodeDecodeError) as e:
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    with path.open("r", encoding="utf-8") as file_obj:
        for line in file_obj:
            print(line, end="")
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

### 1.5 内包表記

#### 1.5.1 共通ルール

SPDに「リスト内包表記で」「辞書内包表記で」「セット内包表記で」と明記されている場合のみ生成する。
明記のない繰り返し（`↻`）は、通常の `for` 文にする。

枝は次の3つ。種類が違っても骨格は同じで、変わるのは `変換` 枝の形だけである。

| 枝 | 意味 | Pythonでの位置 | 省略 |
|---|---|---|---|
| `for: 変数 ← イテラブル` | ループ部 | `for 変数 in イテラブル` | 不可 |
| `変換` | 各要素から作る値 | 先頭の式 | 可（省略時はループ変数そのもの） |
| `条件: 式` | 要素を残す条件 | 末尾の `if 式` | 可（省略時は `if` なし） |

| 種類 | `変換` 枝の形 | 生成するPython |
|---|---|---|
| リスト内包表記 | `変換: 式` | `[変換 for ループ部 if 条件]` |
| 辞書内包表記 | `変換` ＋ 子枝 `キー: 式` / `値: 式` | `{キー: 値 for ループ部 if 条件}` |
| セット内包表記 | `変換: 式` | `{変換 for ループ部 if 条件}` |

- 辞書内包表記では、キーと値の両方が必要なため `変換` を省略できない。
- `変換` は、値を直接書く場合はコロンを付け、`キー:`・`値:` の子枝を持つ場合はコロンを付けない。どちらも受理する。
- 代入先の変数名は、タイトル行の「〜を作成する」「〜を作る」の直前にある識別子を使う。
- `for:` 枝には `↻` を付けない（内包表記は式であり、制御構造の枝ではないため）。
- 枝の記述順は問わない。生成コードは常に上表の展開形の順に組み立てる。
- `for:` 枝は1つだけとする。多重ループが必要な場合は明示的な `for` 文にする。
- ループ変数は `for: i, animal ← enumerate(animals)` のようにタプルで受け取ってもよい。
- SPDの式は字面をそのまま転記せず、空白の位置などをPEP 8に正規化する。
- 1行が79文字を超える場合は、開き括弧（`[` または `{`）の直後で改行し、`for` 以降を独立した行にする。

#### 1.5.2 パターンA：リスト内包表記（変換＋条件）

```text
├─ リスト内包表記で新しいリストnew_numbersを作成する
│      ├─ for: num ← numbers
│      ├─ 変換: num * 2
│      └─ 条件: num % 2 == 0
```

```python
new_numbers = [num * 2 for num in numbers if num % 2 == 0]
```

#### 1.5.3 パターンB：`条件:` の省略（フィルタなし）

```text
└─ リスト内包表記で新しいリストnew_dataを作成する
        ├─ for: item ← data
        └─ 変換: item + "\n"
```

```python
new_data = [item + "\n" for item in data]
```

#### 1.5.4 パターンC：`変換:` の省略（絞り込みのみ）

```text
└─ リスト内包表記で新しいリストevensを作成する
        ├─ for: num ← numbers
        └─ 条件: num % 2 == 0
```

```python
evens = [num for num in numbers if num % 2 == 0]
```

#### 1.5.5 パターンD：辞書内包表記

```text
├─ 辞書内包表記で、usersからuser_mapを作る
│      ├─ for: user ← users
│      └─ 変換
│            ├─ キー: user["name"]
│            └─ 値: {"id": user["id"], "role": user["role"]}
```

```python
user_map = {
    user["name"]: {"id": user["id"], "role": user["role"]}
    for user in users
}
```

1行にすると79文字を超えるため、`{` の直後で改行し、`for` 以降を独立した行にしている。

#### 1.5.6 `条件:` 枝と条件式（三項）の区別

- `条件:` **枝**は要素を絞り込むフィルタであり、末尾の `if`（`else` なし）になる。要素数が減る。
- `変換:` の**式の中**の条件式（三項）は、先頭の式の中の `A if 条件 else B` になる。要素数は減らない。

```text
└─ リスト内包表記で新しいリストlabelsを作成する
        ├─ for: num ← numbers
        └─ 変換: "偶数" if num % 2 == 0 else "奇数"
```

```python
labels = ["偶数" if num % 2 == 0 else "奇数" for num in numbers]
```

### 1.6 関数定義（`関数:`）

| SPDの枝 | 生成するPython |
|---|---|
| `関数: 名前` | `def 名前(...):` |
| `目的：…` | docstring（「〜します。」の形に整える） |
| `引数` の子枝 | 引数。`説明: 名前` と `名前: 説明` のどちらでもよい |
| `引数: なし` | 引数なし |
| `名前: 型` | 型ヒント（SPDに型指定がある場合のみ） |
| `戻り値: 説明 -> 型` | 戻り値の型ヒント |
| `戻り値: なし` | `return` を書かない |
| `処理` の子枝 | 関数本体 |
| `tax_rate = 0.1: 税率` | デフォルト引数 `tax_rate=0.1` |

```text
関数: calc_price
│
├─目的：税込みの価格を計算する
├─引数
│    ├─price: 商品の税抜き価格
│    └─tax_rate = 0.1: 税率
├─戻り値：税込みの価格
└─処理
    └─税込みの価格を計算し、整数にして返す
```

```python
def calc_price(price, tax_rate=0.1):
    """税込みの価格を計算します。"""
    return int(price * (1 + tax_rate))
```

`関数: main` のSPDがある場合だけ `main()` と実行エントリ（`if __name__ == "__main__":`）を生成する。
`main` に限り `目的`・`引数`・`戻り値` の枝を省略してよく、省略時のdocstringは処理内容から作る。

### 1.7 クラス定義（`クラス:`・`データクラス:`）

| SPDの枝 | 生成するPython |
|---|---|
| `クラス: 名前` | `class 名前:` |
| `クラス: 名前(親)` | `class 名前(親):` |
| `データクラス: 名前` | `@dataclass(frozen=True)` ＋ `class 名前:` |
| `目的：…` | クラスのdocstring |
| `属性` の子枝 `説明: 名前: 型` | `__init__` の引数と `self.名前` |
| `_` 付きの属性（`_age`） | 仮想属性。`@property` と `@age.setter` を生成 |
| `属性：なし` | 属性なし（`__init__` を作らない） |
| `クラス変数` の子枝 `名前: 型 = 値` | クラス直下の定数 |
| `特殊メソッド`→`コンストラクタ` | `__init__` |
| `特殊メソッド`→`表示メソッド` | `__str__` と `__repr__` |
| `特殊メソッド`→`等値メソッド <- 属性` | その属性で比較する `__eq__` と `__hash__` |
| `メソッド: 名前` | インスタンスメソッド（第1引数 `self`） |
| `クラスメソッド: 名前` | `@classmethod`（第1引数 `cls`。インスタンス生成は `cls(...)`） |
| `スタティックメソッド: 名前` | `@staticmethod`（`self`・`cls` を取らない） |

- クラス定義の**すべてのメソッド**（コンストラクタ・特殊メソッドを含む）の引数・戻り値に型ヒントを付ける。
- `@dataclass` の属性にも型ヒントを付ける。
- 自分のクラスを戻り値の型にする場合は前方参照（`-> "Member"`）にする。
- クラス変数はメソッドの中から `クラス名.変数名` で参照する。

具体的な生成例は2.9節（クラスの定義）・2.10節（継承）・2.11節（データクラス）を参照する。

---
## 2. 作成例

第1章で形が判定できない場合に参照する、具体的なプログラムでの変換例である。
SPDの枝の描き方（枝を折り曲げる・タイトルを付ける・展開する）が違っても、同じ構造なら生成コードは同じになる。

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

### 2.2 分岐

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

#### 2.2.2 if-else文

タイトル（`結果の表示`）は、生成コードの対応する位置に `#` コメントとして転記する。

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

#### 2.2.3 if-elif文

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

### 2.3 繰り返し

#### 2.3.1 for文（集計）

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

#### 2.3.2 for文（オブジェクトのリスト）

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

#### 2.3.3 while文（無限ループ）

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

#### 2.3.4 while文（ウォルラス演算子）

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

#### 2.4.1 2次元リストを扱うリスト内包表記

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

#### 2.4.2 インデックスを付けるenumerate関数

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

#### 2.4.3 複数のリストを合併するzip関数

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

#### 2.5.1 辞書のキーと値を表示する

`for: key ← score` はキーだけを取り出し、`for: key, value ← score.items()` はキーと値の両方を取り出す。

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

#### 2.5.2 辞書のリストから要素を検索する

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

#### 2.5.3 辞書の並べ替え

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

### 2.6 関数

#### 2.6.1 関数の定義と使用例

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

#### 2.6.2 main関数

`関数: main` があるときだけ `main()` と実行エントリを生成する。

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

`main` は引数も戻り値もないので、`目的`・`引数`・`戻り値` の枝を省略してよい。
省略形でも生成するコードは上と同じで、docstringは `処理` の内容から作る。

```
※main　関数の省略形
関数: main
  │
  └─処理
        ├─数学・理科・英語の点数をキーボードから入力する
        ├─score() を呼び出して、戻り値を変数total とaverage に代入する
        └─合計(total) と平均(average) を、 "合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

### 2.7 ファイルとディレクトリの操作

#### 2.7.1 パスの結合

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

#### 2.7.2 再帰的にすべてのファイル名を取り出す

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

#### 2.8.1 テキストファイルの一括読み込み

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

#### 2.8.2 テキストファイルの行単位の読み込み

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

#### 2.8.3 テキストファイルの一括出力

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

#### 2.8.4 リストの一括出力

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

#### 2.8.5 行単位の出力

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

#### 2.8.6 例外を発生させる

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

### 2.9 クラスの定義

移譲メソッドの自動生成を除く、クラスの構成要素をすべて含む例である。
クラス宣言部と属性は省略できない。属性がない場合は `属性：なし` と書く。それ以外は必要な構成要素だけを書く。

```
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

### 2.10 継承

#### 2.10.1 Memberクラスを継承するGeneralMemberクラス

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

#### 2.10.2 コンストラクタのないサブクラス

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

#### 2.10.3 ミックスイン

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

### 2.11 データクラス

#### 2.11.1 データクラスの定義

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

#### 2.11.2 属性値の検査（バリデーション）

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

### 2.12 別ファイルのクラスを使う

クラス定義と、それを使うプログラムが同じフォルダの別ファイルに分かれている場合、
使う側のSPDに「〜をインポートする」と書かれていなくても `import` 文を補う。

```
会員情報を表示する
│
├─ Memberのインスタンスを作成して変数memberに代入する
│        └─ 引数は("A001", "山田太郎")
└─ memberを"会員＝〇〇"の書式でコンソールに表示する
```

```python
from member import Member


member = Member("A001", "山田太郎")

print(f"会員＝{member}")
```

`Member` はこのファイルで定義していないので `from member import Member` を補う。
モジュール名 `member` は、クラスを定義したファイル `member.py` の拡張子を除いたファイル名である。
ファイル名が確認できない場合は、推測で書かずにユーザーへ確認する。
SPDに根拠がない限り、クラスを別ファイルへ切り出す判断は生成側で行わない。

---
## 3. 未記入SPDの適用例

カスタム指示の第0章（SPDの未記入部分は生成しない）を適用した出力例である。
各例は、**`未記入判定:` の1行 → ファイル全体 → 生成後の報告**の順に出力する。
ファイル先頭のSPDブロックは、未記入の部分も含めて**原文のまま**残す。

### 3.1 関数が未記入（`★` マーカー）

入力のSPD。`calc_score` の `処理` にマーカーがある。

```
関数: main
  │
  └─処理
        ├─手札のリストhandに[1, 5, 9]を代入する
        ├─calc_score(hand) を呼び出して、戻り値を変数scoreに代入する
        └─"得点= 〇〇" の形式でscoreを表示する

関数: calc_score
│
├─目的：手札の合計点を計算する
├─引数
│    └─手札のリスト: hand: list[int]
├─戻り値：合計点 -> int
└─処理
      └─★ここにSPDを書く★
```

出力する1行。

```text
未記入判定: main=記入済み calc_score=未記入
```

生成するファイル。`calc_score` はコメント1行だけにし、SPDに現れた順序の位置に置く。

```python
"""
関数: main
  │
  └─処理
        ├─手札のリストhandに[1, 5, 9]を代入する
        ├─calc_score(hand) を呼び出して、戻り値を変数scoreに代入する
        └─"得点= 〇〇" の形式でscoreを表示する

関数: calc_score
│
├─目的：手札の合計点を計算する
├─引数
│    └─手札のリスト: hand: list[int]
├─戻り値：合計点 -> int
└─処理
      └─★ここにSPDを書く★
"""


def main():
    """手札の合計点を求めて表示します。"""
    hand = [1, 5, 9]
    score = calc_score(hand)
    print(f"得点= {score}")


# calc_score関数：SPDが未記入のため生成していません


if __name__ == "__main__":
    main()
```

コードブロックの外に置く報告。

```text
── 生成後の報告 ──

【SPDが未記入のため生成しなかった関数】

- calc_score

SPDを書いてから、もう一度渡してください。
```

### 3.2 クラスの骨格が未記入（`クラス変数` の見落とし）

`属性` と `特殊メソッド` は記入済みだが、`クラス変数` にマーカーがある。
この場合は**クラス全体を未完成**とし、`class` 文を出さない。
クラス変数が生成されないまま `return FEE` だけを生成すると、実行できないコードになるためである。

```
クラス: Member
│
├─目的：会員を表すクラス
├─属性
│    ├─番号：uid: int
│    └─名前：name: str
│
├─特殊メソッド
│    └─コンストラクタ
│
├─クラス変数
│      └─★ここに書く★
│
└─メソッド: membership_fee
    │
    ├─目的: 会費額を返す
    ├─引数: なし
    ├─戻り値: 会費 -> int
    └─処理
        └─ FEEを返す
```

```text
未記入判定: Member=未記入
```

```python
# Memberクラス：SPDが未記入のため生成していません
```

```text
── 生成後の報告 ──

【SPDが未記入のため生成しなかったSPD】

- Member

SPDを書いてから、もう一度渡してください。
```

### 3.3 メソッドだけが未記入（部分生成）

骨格（`属性`・`特殊メソッド`・`クラス変数`）が記入済みなら、`class` 文・属性・特殊メソッドは通常どおり生成し、
未記入の**メソッドだけ**をコメント1行に置き換える。コメントはクラス本体の中に、他のメソッドと同じ字下げで置く。

```
クラス: Member
│
├─目的：会員を表すクラス
├─属性
│    ├─番号：uid: int
│    └─名前：name: str
│
├─特殊メソッド
│    └─コンストラクタ
│
├─メソッド: membership_fee
│    │
│    ├─目的: 会費額を返す
│    ├─引数: なし
│    ├─戻り値: 会費 -> int
│    └─処理
│        └─ 5000を返す
│
└─メソッド: calc_age
      │
      ├─目的: 年齢を計算する
      ├─引数: なし
      ├─戻り値: 年齢 -> int
      └─処理
            └─★ここに書く★
```

```text
未記入判定: Member=記入済み Member.membership_fee=記入済み Member.calc_age=未記入
```

```python
class Member:
    """会員を表すクラス。"""

    def __init__(self, uid: int, name: str) -> None:
        self.uid = uid
        self.name = name

    def membership_fee(self) -> int:
        """会費額を返します。"""
        return 5000

    # calc_ageメソッド：SPDが未記入のため生成していません
```

```text
── 生成後の報告 ──

【SPDが未記入のため生成しなかった関数】

- Member.calc_age

SPDを書いてから、もう一度渡してください。
```

### 3.4 クラス本体が空になる場合（`pass` を置く）

そのクラスで生成される文が1つも無くなる場合は、コメント行のあとに `pass` を1行だけ置く。
本体が空のクラスはPythonの構文として書けないためである。

```
クラス: Member
│
├─目的：会員を表すクラス
├─属性：なし
├─特殊メソッド：なし
│
├─メソッド: calc_age
│    │
│    ├─目的: 年齢を計算する
│    ├─引数: なし
│    ├─戻り値: 年齢 -> int
│    └─処理
│          └─★ここに書く★
│
└─メソッド: judge_rank
      │
      ├─目的: 会員ランクを判定する
      ├─引数: なし
      ├─戻り値: ランク -> str
      └─処理
            └─★ここに書く★
```

```text
未記入判定: Member=記入済み Member.calc_age=未記入 Member.judge_rank=未記入
```

`属性：なし`・`特殊メソッド：なし` は**記入済み**として扱うので、骨格は未完成ではない。

```python
class Member:
    # calc_ageメソッド：SPDが未記入のため生成していません
    # judge_rankメソッド：SPDが未記入のため生成していません
    pass
```

```text
── 生成後の報告 ──

【SPDが未記入のため生成しなかった関数】

- Member.calc_age
- Member.judge_rank

SPDを書いてから、もう一度渡してください。
```

### 3.5 すべての単位が未記入

ファイル先頭のSPDブロックは原文のまま出力し、その下にはコメント行だけを置く。

```
関数: calc_score
│
├─目的：手札の合計点を計算する
└─処理
      └─★ここにSPDを書く★
```

```text
未記入判定: calc_score=未記入
```

```python
"""
関数: calc_score
│
├─目的：手札の合計点を計算する
└─処理
      └─★ここにSPDを書く★
"""


# calc_score関数：SPDが未記入のため生成していません
```

```text
── 生成後の報告 ──

【SPDが未記入のため生成しなかった関数】

- calc_score

SPDを書いてから、もう一度渡してください。
```

### 3.6 判定を誤りやすい書き方

| SPDの書き方 | 判定 | 理由 |
|---|---|---|
| `属性：なし` | 記入済み | `なし` は記入済みとして扱う |
| `引数: なし`・`戻り値: なし` | 記入済み | 同上 |
| `属性` の枝がそもそも無い | 記入済み | 枝が無いことは未完成ではない |
| `属性` の枝があり、直下に何も無い | 未記入 | 枝があるのに中身が無い |
| `└─年齢：_age: int　（_ を付けているので…）` | 記入済み | 行末の全角括弧は注記なので判定材料にしない |
| `├─サイコロを振って（dice()）出目を…` | 記入済み | 行の途中の括弧はSPD本体 |
| `クラス: SeniorMember(Member)` | 記入済み | 半角括弧はSPD本体 |
| 分岐の1枝だけが `★` | その関数・メソッド全体が未記入 | 書いてある枝だけをコード化してはならない |

---

## 4. 更新履歴

| バージョン | 日付 | 変更内容 |
|---|---|---|
| v1.x | 〜2026-09-07 | SPD作成例集（`SPD-example-v3.md` の後継）として、言語機能別の章立て（コメント／基本構造／クラスとオブジェクト）でSPDと生成コードの対を収録 |
| v2.0.0 | 2026-09-22 | Gem知識ファイルとして再編。第1章「変換パターン早見表」を新設し、SPD記号（`◇`・`↻`・`〇`）から引ける抽象パターンを収録（旧 `gem-SPD-patterns.md` から移植。`match`、`◇` のif/elif判定、独立したifの連続、`条件:` 枝と条件式（三項）の区別、関数定義・クラス定義の対応表を補充）。既存の作成例を第2章に整理し、SPDの描き方だけが異なり生成コードが同じ例と、学習者向けの説明を削除。第3章「未記入SPDの適用例」を新設（カスタム指示の第0章に対応）。冒頭に知識ファイルとしての位置づけを明記し、章番号の誤記（`2,6`）を修正 |
