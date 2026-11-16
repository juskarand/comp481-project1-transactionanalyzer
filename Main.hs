module Main where

import TransactionAnalyzer

main :: IO ()
main = do
  putStrLn "All transactions:"
  putStrLn (formatTransactions sampleTransactions)
  let bigFood = filterByMinAmount 10 (filterByCategory "Food" sampleTransactions)
  putStrLn "Food transactions of at least 10:"
  putStrLn (formatTransactions bigFood)
  putStrLn "Totals by category:"
  putStrLn (formatCategoryTotals (totalByCategory sampleTransactions))
