module Main where

import Control.Monad (unless)
import Data.List (elemIndices, isInfixOf)
import TransactionAnalyzer

check :: String -> Bool -> IO ()
check label passed = unless passed (error ("FAILED: " ++ label))

close :: Double -> Double -> Bool
close a b = abs (a - b) < 1e-9

main :: IO ()
main = do
  let lunch = Transaction "2024-03-01" "Food" 12.50 "Lunch at cafe"
      coffee = Transaction "2024-03-04" "Food" 7.80 "Coffee"
      extra = Transaction "2024-03-05" "Food" 10 "Threshold"
      refund = Transaction "2024-03-06" "Travel" (-20) "Refund"
  check "category filter and order" (filterByCategory "Food" sampleTransactions == [lunch, coffee])
  check "category matching is exact" (null (filterByCategory "food" sampleTransactions))
  check "missing category" (null (filterByCategory "Other" sampleTransactions))
  check "inclusive threshold" (filterByMinAmount 10 [coffee, extra, lunch] == [extra, lunch])
  check "composed query" (filterByMinAmount 10 (filterByCategory "Food" sampleTransactions) == [lunch])
  check "empty filters" (null (filterByCategory "Food" []) && null (filterByMinAmount 0 []))
  check "empty totals" (null (totalByCategory []))
  check "non-adjacent categories and refunds" $
    case totalByCategory (sampleTransactions ++ [extra, refund]) of
      [("Food", food), ("Travel", travel)] -> close food 30.3 && close travel 100
      _ -> False
  check "sample totals" $
    case totalByCategory sampleTransactions of
      [("Food", food), ("Travel", travel)] -> close food 20.3 && close travel 120
      _ -> False
  check "two decimal places" ("12.50" `isInfixOf` formatTransactions [lunch])
  check "empty table has header" ("Date" `isInfixOf` formatTransactions [])
  let long = Transaction "2024-03-07" "Long category name" 12345.6 "A longer note"
      tableLines = lines (formatTransactions [lunch, long])
      positions = map (elemIndices '|') (take 1 tableLines ++ drop 2 tableLines)
  check "aligned columns" (case positions of
    first : rest -> length rest == 2 && all (== first) rest
    [] -> False)
  check "totals formatting" ("20.30" `isInfixOf` formatCategoryTotals (totalByCategory sampleTransactions))
  putStrLn "All 13 checks passed."
