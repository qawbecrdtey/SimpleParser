import «SimpleParser»

def main (args : List String) : IO Unit := do
  match args with
  | [] => pure ()
  | h :: t => do
    solve_ h
    main t
