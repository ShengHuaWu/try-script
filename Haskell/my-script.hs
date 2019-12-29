#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}

-- https://hackage.haskell.org/package/turtle-1.5.15/docs/Turtle-Tutorial.html

import Turtle

myFunc :: Integer -> Integer
myFunc i = i + 1

-- The <- symbol is overloaded and its meaning is context-dependent; in this context it just means "store the current result"
-- The = symbol is not overloaded and always means that the two sides of the equality are interchangeable
datePwd :: IO UTCTime
datePwd = do
  dir <- pwd
  datefile dir -- do notation implicitly returns the value of the last command within a subroutine

tryProc :: IO ()
tryProc = do
  proc "mkdir" ["test"] empty
  proc "ls" ["-la"] empty
  -- Have to do pattern matching on `x`, 
  -- becasue the last command will be return automatically
  x <- proc "rmdir" ["test"] empty
  case x of 
    ExitSuccess   -> return ()
    ExitFailure n -> die ("ls failed with exit code: " <> repr n)

tryView :: IO ()
tryView = do
  -- The <|> symbol is Shell stream concatenation
  view (return 1 <|> return 2)
  view (ls "/Users/shenghuawu/Downloads" <|>  ls "/Users/shenghuawu/Development")

main = do
  -- time <- datePwd
  -- print time
  -- print( "123" <> "789" ) -- `<>` is string concatenation
  -- tryProc
  tryView
