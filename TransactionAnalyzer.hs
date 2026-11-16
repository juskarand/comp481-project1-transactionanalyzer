module TransactionAnalyzer
  ( Transaction (..)
  , sampleTransactions
  , filterByCategory
  , filterByMinAmount
  , totalByCategory
  , formatTransactions
  , formatCategoryTotals
  ) where

import Data.List (groupBy, intercalate, sortOn)
import Data.Maybe (mapMaybe)
import Text.Printf (printf)

data Transaction = Transaction
  { tDate :: String
  , tCategory :: String
  , tAmount :: Double
  , tNote :: String
  } deriving (Show, Eq)

sampleTransactions :: [Transaction]
sampleTransactions =
  [ Transaction "2024-03-01" "Food" 12.50 "Lunch at cafe"
  , Transaction "2024-03-02" "Travel" 120.00 "Taxi and train"
  , Transaction "2024-03-04" "Food" 7.80 "Coffee"
  ]

-- Category names are case-sensitive.
filterByCategory :: String -> [Transaction] -> [Transaction]
filterByCategory category = filter (\t -> tCategory t == category)

-- Include amounts equal to the minimum too.
filterByMinAmount :: Double -> [Transaction] -> [Transaction]
filterByMinAmount minimumAmount = filter (\t -> tAmount t >= minimumAmount)

-- Sort first so matching categories stay together.
totalByCategory :: [Transaction] -> [(String, Double)]
totalByCategory txs = mapMaybe summarize groups
  where
    groups = groupBy sameCategory (sortOn tCategory txs)
    sameCategory a b = tCategory a == tCategory b
    summarize [] = Nothing
    summarize group@(first : _) =
      let category = tCategory first
          total = foldr (\t acc -> tAmount t + acc) 0 group
      in Just (category, total)

formatTransactions :: [Transaction] -> String
formatTransactions txs = formatTable ["Date", "Category", "Amount", "Note"] rows
  where
    rows = [[tDate t, tCategory t, money (tAmount t), tNote t] | t <- txs]

formatCategoryTotals :: [(String, Double)] -> String
formatCategoryTotals totals = formatTable ["Category", "Amount"] rows
  where
    rows = [[category, money amount] | (category, amount) <- totals]

money :: Double -> String
money = printf "%.2f"

-- Allow enough room for the longest value in each column.
formatTable :: [String] -> [[String]] -> String
formatTable headers rows = unlines (render headers : divider : map render rows)
  where
    widths = [maximum (map (length . (!! i)) (headers : rows))
             | i <- [0 .. length headers - 1]]
    render cells = intercalate " | " (zipWith3 pad headers widths cells)
    pad heading width value
      | heading == "Amount" = replicate (width - length value) ' ' ++ value
      | otherwise = value ++ replicate (width - length value) ' '
    divider = intercalate "-+-" [replicate width '-' | width <- widths]
