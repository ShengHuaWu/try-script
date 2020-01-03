module MyGeometry.TryOut (
    tryType
) where

import MyGeometry.Data

tryType :: IO ()
tryType = do
  let p = MyPoint { xf = 100.0, yf = 10.5 } -- From module `MyGeometry.Data`
  let s = MySize { wf = 50.5, hf = 100.0 } -- From module `MyGeometry.Data`
  print(p)
  print(s)

  let m = L p -- From module `MyGeometry.Data`
  print(m)