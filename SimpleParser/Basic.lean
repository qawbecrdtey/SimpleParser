import Lean.Data.Parsec

open Lean Parsec

def lparen : Parsec Char := pchar '('
def rparen : Parsec Char := pchar ')'
def add_operator : Parsec Char := pchar '+'
def sub_operator : Parsec Char := pchar '-'
def mul_operator : Parsec Char := pchar '*'
def div_operator : Parsec Char := pchar '/'

def operator : Parsec Char := add_operator <|> sub_operator <|> mul_operator <|> div_operator

inductive Operator
| none
| add
| sub
| mul
| div

instance : Inhabited Operator :=
  ⟨Operator.none⟩

def charToOperator (c : Char) : Operator :=
  if c = '+' then Operator.add
  else if c = '-' then Operator.sub
  else if c = '*' then Operator.mul
  else if c = '/' then Operator.div
  else panic! "Wrong operator selected."

inductive ExpressionTree
| expression : Operator → ExpressionTree → ExpressionTree → ExpressionTree
| number : Nat → ExpressionTree

def number : Parsec ExpressionTree := do
  let nums_str ← manyChars digit
  pure (ExpressionTree.number nums_str.toNat!)

partial def expression : Parsec ExpressionTree := do
  let _ ← lparen
  ws
  let op ← operator
  ws
  let expr1 ← expression <|> number
  ws
  let expr2 ← expression <|> number
  ws
  let _ ← rparen
  pure (ExpressionTree.expression (charToOperator op) expr1 expr2)

def compute_inner (exprTree : ExpressionTree) : Option Nat :=
  match exprTree with
  | ExpressionTree.expression op expr₁ expr₂ => do
    let n₁ ← compute_inner expr₁
    let n₂ ← compute_inner expr₂
    match op with
    | Operator.add => some (n₁ + n₂)
    | Operator.sub => some (n₁ - n₂)
    | Operator.mul => some (n₁ * n₂)
    | Operator.div => if n₂ = 0 then none else some (n₁ / n₂)
    | _ => panic! "Wrong operator selected."
  | ExpressionTree.number n => some n

def compute (exprTree : ExpressionTree) : Nat :=
  match (compute_inner exprTree) with
  | some n => n
  | none => panic! s!"Wrong expression."

def solve_ (str : String) := do
  match Parsec.run (expression <|> number) str with
  | .ok res => IO.println s!"The result is {compute res}."
  | .error err => IO.println err
