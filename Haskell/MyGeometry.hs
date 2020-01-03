module MyGeometry (
    MyPoint (..),
    MySize (..),
    MyEnum (..)
 ) where

data MyPoint = MyPoint { xf :: Float, yf :: Float } deriving (Show)
data MySize = MySize { wf :: Float, hf :: Float} deriving (Show)
data MyEnum = L MyPoint | R MySize deriving (Show)