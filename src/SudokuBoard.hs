-- Andrew Michaud
-- 02/05/15
-- Data and other definitions needed for Sudoku.

module SudokuBoard
( SudokuBoard
, Square
, SqVal
, toVal
, emptyBoard
, testRow
, setBoardValue
, checkBoard
, prettyPrint
) where

import Data.Maybe
import qualified Data.List

data SqVal = V1 | V2 | V3 | V4 | V5 | V6 | V7 | V8 | V9 deriving (Eq, Ord, Enum, Show)

toVal :: Int -> Maybe SqVal
toVal 1 = Just V1
toVal 2 = Just V2
toVal 3 = Just V3
toVal 4 = Just V4
toVal 5 = Just V5
toVal 6 = Just V6
toVal 7 = Just V7
toVal 8 = Just V8
toVal 9 = Just V9
toVal _ = Nothing

-- Type for Sudoku square value.
data Square = Empty | Val SqVal deriving (Eq)

-- Test constructor.
testRow :: [Int] -> [Square]
testRow nums = answer
    where
        vals       = map (toVal) nums
        answer = map (filterFunc) vals

filterFunc :: Maybe SqVal -> Square
filterFunc val = if isJust val then Val (fromJust val) else Empty

-- Show either the number, or "N" for nothing.
instance Show Square where
    show (Val value) = show value
    show (Empty)    = "N"

-- Type for Sudoku board.
data SudokuBoard = SudokuBoard [[Square]] deriving (Show)

-- Check if a pair of Squares are equal.
checkPair :: Square -> Square -> Bool
checkPair (Val squareA) (Val squareB) = (squareA == squareB)
checkPair _ _ = False

-- Check a list of Squares and returns a list of pairs that are equal.
checkList :: [Square] -> [(Square, Square)]
checkList (x:xs)
    | tail xs == [] = if checkPair x (head xs) then [(x, (head xs))] else []
    | otherwise     = answer
    where
        headPairs   = [(x, y) | y <- xs, checkPair x y]
        answer      = headPairs ++ checkList xs
        
-- Retrieves a specified column from a 2D list.
getColumn :: [[a]] -> Int -> [a]
getColumn list index = [row !! index| row <- list]

-- Checks if a SudokuBoard is currently valid or not.
-- Checks all rows, columns, and subgrids with checkList and returns a 
-- list of matching pairs.
checkBoard :: SudokuBoard -> [(Square, Square)]
checkBoard (SudokuBoard board) = allPairs
    where
        rowPairs = concat $ map checkList board
        columns  = [getColumn board index | index <- [0..9]]
        colPairs = concat $ map checkList board
        allPairs = colPairs ++ rowPairs


-- Given an array and a spacer, uses the spacer to separate
-- the first three from the middle three rows and the middle
-- three from the last three rows.
sudokuSpacer :: a -> [a] -> [a]
sudokuSpacer spacer array = result
    where 
        first3 = take 3 array
        mid3   = take 3 (drop 3 array)
        last3  = drop 6 array
        result = first3 ++ [spacer] ++ mid3 ++ [spacer] ++ last3

-- Show for SudokuBoard, prints it nicely.
prettyPrint :: SudokuBoard -> String
prettyPrint (SudokuBoard board) = niceBoard
    where
        -- Horizontal spacer line.
        horSepLine    = unwords (replicate 17 " ")
        
        -- Convert all SquareValues to strings.
        stringBoard   = map (map show) board
        
        -- Insert vertical spaces and then join lines into strings.
        vSpacedBoard  = map (sudokuSpacer " ") stringBoard
        unwordedBoard = map unwords vSpacedBoard
       
        -- Separate rows with horizontal space lines.
        separated     = sudokuSpacer horSepLine unwordedBoard
        
        -- Join array into newline-separated string.
        niceBoard     = unlines separated
 
-- Creates empty Sudoku board.
emptyBoard :: SudokuBoard
emptyBoard = SudokuBoard [replicate 9 x | x <- (replicate 9 (Empty))]

-- Get the value in a particular square of a Sudoku board.
getBoardValue :: SudokuBoard -> Int -> Int -> Maybe Square
getBoardValue (SudokuBoard board) rowIndex colIndex
    
-- Check if out of bounds.
    | rowIndex > 8 || rowIndex < 0 = Nothing
    | colIndex > 8 || colIndex < 0 = Nothing
    
    -- Otherwise return value.
    | otherwise                    = Just value
    where
        row   = board !! rowIndex
        value = row !! colIndex

-- Returns a SudokuBoard with the value at the two indices erased.
eraseBoardValue :: SudokuBoard -> Int -> Int -> Maybe SudokuBoard
eraseBoardValue (SudokuBoard board) rowIndex colIndex
    -- Check if out of bounds.
    | rowIndex > 8 || rowIndex < 0 = Nothing
    | colIndex > 8 || colIndex < 0 = Nothing
    
    -- Return new board if everything seems all right.
    | otherwise                    = Just $ SudokuBoard newBoard
    where
        oldRow    = board !! rowIndex
        -- Create new row.
        newRow    = take colIndex oldRow ++ [Empty] ++ drop (colIndex + 1) oldRow

	-- Create new board.
        newBoard  = take rowIndex board ++ [newRow] ++ drop (colIndex + 1) board

-- Take squares? Return errors?

-- Returns a SudokuBoard with the value at the two indices modified.
setBoardValue :: SudokuBoard -> Int -> Int -> Square -> Maybe SudokuBoard
setBoardValue (SudokuBoard board) rowIndex colIndex newSquare
    
    -- Check if out of bounds.
    | rowIndex > 8 || rowIndex < 0 = Nothing
    | colIndex > 8 || colIndex < 0 = Nothing
    
    -- Return new board if everything seems all right.
    | otherwise                    = Just $ SudokuBoard newBoard
    where
        oldRow    = board !! rowIndex
        -- Create new row.
        newRow    = take colIndex oldRow ++ [newSquare] ++ drop (colIndex + 1) oldRow

	-- Create new board.
        newBoard  = take rowIndex board ++ [newRow] ++ drop (colIndex + 1) board
        