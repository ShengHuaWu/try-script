#!/usr/bin/env stack
-- stack --resolver lts-10.2 script

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
  view (select [1..10]) -- loop
  view (mfilter even (select [1..10])) -- show even numbers

inner :: Shell a
inner = do
  x <- select [1, 2]
  y <- select [3, 4]
  liftIO(print (x, y))
  empty -- An Shell stream that produces 0 elements will short-circuit and prevent subsequent commands from being run.

outer :: Shell ()
outer = do
  sh inner -- If you want to run a Shell stream just for its side effects, wrap the Shell with sh.
  liftIO(echo "Show outer")

myProc :: MonadIO io => Text -> [Text] -> io ()
myProc cmd args = do
  x <- proc cmd args empty
  case x of 
    ExitSuccess   -> return ()
    ExitFailure n -> die (cmd <> " failed with exit code: " <> repr n)

tryFile :: IO ()
tryFile = do
  myProc "ls" ["-al"]
  myProc "mkdir" ["test"]
  myProc "ls" ["-al"]
  myProc "touch" ["test/test.txt"]
  myProc "ls" ["-al", "test"]
  myProc "rm" ["test/test.txt"]
  myProc "ls" ["-al", "test"]
  myProc "rmdir" ["test"]
  myProc "ls" ["-al"]

data MyPoint = MyPoint { xf :: Float, yf :: Float } deriving (Show)
data MySize = MySize { wf :: Float, hf :: Float} deriving (Show)
data MyEnum = L MyPoint | R MySize deriving (Show)

tryType :: IO ()
tryType = do
  let p = MyPoint { xf = 100.0, yf = 10.5 }
  let s = MySize { wf = 50.5, hf = 100.0 }
  print(show p <> show s)

  let m = L p
  print(m)

main = do
  -- time <- datePwd
  -- print time
  -- print( "123" <> "789" ) -- `<>` is string concatenation
  -- tryProc
  -- tryView
  -- sh outer
  -- tryFile
  tryType
