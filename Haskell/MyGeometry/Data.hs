-- It is important to align the module name with the folder structure, for example,
-- MyGeometry
--      ├── Data.hs (modeul MyGeometry.Data)
--      └── TryOut.hs (module MyGeometry.TryOut)

module MyGeometry.Data (
    MyPoint (..),
    MySize (..),
    MyEnum (..)
 ) where

data MyPoint = MyPoint { xf :: Float, yf :: Float } deriving (Show)
data MySize = MySize { wf :: Float, hf :: Float} deriving (Show)
data MyEnum = L MyPoint | R MySize deriving (Show)