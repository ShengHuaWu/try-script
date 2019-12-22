#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}

-- https://hackage.haskell.org/package/turtle-1.5.15/docs/Turtle-Tutorial.html

import Turtle

myFunc :: Integer -> Integer
myFunc i = i + 1

main = do
  dir <- pwd
  print dir
