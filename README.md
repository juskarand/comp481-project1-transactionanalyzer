# Functional Transaction Analyzer (Haskell)

A small Haskell program that stores spending transactions, filters them, totals them by category, and prints the results as aligned text tables. Built for **COMP 481 – Mini-Project 1** at the University of the Fraser Valley.

## What it does

- Stores each transaction as a record with a date, category, amount and note
- Filters transactions by category (exact, case-sensitive match)
- Filters transactions by a minimum amount (inclusive, so `10.00` counts as "at least 10")
- Combines filters by passing the output of one into the next
- Totals spending per category
- Prints results as tables, with columns sized to the longest value and amounts shown to two decimal places

## Project structure

| File | Purpose |
| --- | --- |
| `TransactionAnalyzer.hs` | The `Transaction` type, sample data, and all pure functions (filters, totals, table formatting). Its export list keeps the helpers `money` and `formatTable` private |
| `Main.hs` | Entry point. Prints all transactions, runs the Food ≥ 10 query, and prints the category totals |
| `Tests.hs` | 13 checks covering the filters, totals, empty input, refunds and table alignment |
| `COMP481-Mini-Project-1-Report.pdf` | Project report |

## Requirements

- [GHC](https://www.haskell.org/ghcup/) (any recent version)
- No extra packages. The code only uses modules that ship with GHC (`Data.List`, `Data.Maybe`, `Text.Printf`, `Control.Monad`)

## How to run

From the project folder:

```bash
runghc Main.hs     # run the analyzer
runghc Tests.hs    # run the tests
```

To compile instead of interpreting:

```bash
ghc Main.hs -outputdir build/main -o analyzer
./analyzer
```

> `Main.hs` and `Tests.hs` both define `module Main`, so give each its own `-outputdir` if you compile both.

## Example output

```text
All transactions:
Date       | Category | Amount | Note
-----------+----------+--------+---------------
2024-03-01 | Food     |  12.50 | Lunch at cafe
2024-03-02 | Travel   | 120.00 | Taxi and train
2024-03-04 | Food     |   7.80 | Coffee

Food transactions of at least 10:
Date       | Category | Amount | Note
-----------+----------+--------+--------------
2024-03-01 | Food     |  12.50 | Lunch at cafe

Totals by category:
Category | Amount
---------+-------
Food     |  20.30
Travel   | 120.00
```

Running the tests prints:

```text
All 13 checks passed.
```

## Trying your own queries

Load the module in GHCi and call the functions directly:

```bash
ghci TransactionAnalyzer.hs
```

```haskell
ghci> filterByCategory "Travel" sampleTransactions
ghci> totalByCategory (filterByMinAmount 10 sampleTransactions)
ghci> putStr (formatTransactions (filterByCategory "Food" sampleTransactions))
ghci> putStr (formatCategoryTotals (totalByCategory sampleTransactions))
```

To use your own data, edit `sampleTransactions` in `TransactionAnalyzer.hs`:

```haskell
Transaction "2024-03-05" "Rent" 950.00 "March rent"
```

Some tests compare against the original three sample records, so `Tests.hs` will fail if you change them.

## How it works

- **Filtering**: `filter` with a lambda that checks one field of the record.
- **Totals by category**: `sortOn tCategory` puts matching categories next to each other, then `groupBy` collects them and `foldr` adds up each group's amounts. The sort comes first because `groupBy` only merges neighbouring elements.
- **Module interface**: `TransactionAnalyzer` has an export list, so `Main.hs` and `Tests.hs` can only use the type, the sample data, the two filters, `totalByCategory` and the two formatting functions. The helpers `money` and `formatTable` stay internal.
- **Formatting**: `formatTable` works out each column's width from its longest value, pads the cells (amounts right-aligned), and joins the rows with `intercalate`. `printf "%.2f"` formats the amounts.

## Haskell concepts used

- Record types (`data Transaction = Transaction { ... } deriving (Show, Eq)`)
- Modules with an export list
- Higher-order functions: `filter`, `map`, `foldr`, `sortOn`, `groupBy`, `zipWith3`
- Lambdas and partial application
- Pattern matching, including the empty-list case in `summarize`
- `Maybe` with `mapMaybe`
- `where` and `let` bindings
- List comprehensions and guards

## Team

Built by Arundeep Singh (team leader), Juskaran Dhanjal, Pushpdeep Sandhu and Inder Nijjar.
