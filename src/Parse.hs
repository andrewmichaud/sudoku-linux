module Parse where

import Move
import SudokuBoard

-- Parse a move
-- Also styled after a friend's code.
parseMove :: String -> Maybe Move

-- Set value at row and column to value.
parseMove ('s':r:c:v)
    | loc == Nothing = Nothing
    | val == Nothing = Nothing
    | otherwise      = Just $ Set [r] [c] v
    where
        loc = parseLocation [r] [c]
        val = parseSquare v

-- Check if board is valid.
parseMove "c" = Just Check

-- Quit.
parseMove "q" = Just Quit

-- Reset board.
parseMove "r" = Just Reset

-- Erase value in board.
parseMove ('e':r:c)
    | loc == Nothing = Nothing
    | otherwise      = Just $ Erase [r] c
    where
        loc = parseLocation [r] c

-- No other moves are valid.
parseMove _ = Nothing

-- Turn an Int into a square (or nothing).
-- 0 is turned into Empty.
parseSquare :: String -> Maybe Square
parseSquare intString = toSquare intString

-- Turn two ints into a Location
parseLocation :: String -> String -> Maybe Location
parseLocation rowString colString = toLocation rowString colString

