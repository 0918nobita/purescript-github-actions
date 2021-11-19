module GitHub.Actions.IO where

import Prelude

import Control.Promise (Promise)
import Control.Promise as Promise
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)

foreign import _mkdirP :: String -> Effect (Promise Unit)

mkdirP :: String -> Aff Unit
mkdirP path = (liftEffect $ _mkdirP path) >>= Promise.toAff
