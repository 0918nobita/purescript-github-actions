module GitHub.Actions.ToolCache where

import Prelude

import Control.Monad.Maybe.Trans (MaybeT(..))
import Data.Maybe (Maybe, fromMaybe)
import Effect (Effect)
import Node.Path (FilePath, concat)
import Node.Process (lookupEnv)

cacheDir :: MaybeT Effect FilePath
cacheDir = MaybeT $ lookupEnv "RUNNER_TOOL_CACHE"

newtype ToolPath = ToolPath FilePath

newtype MarkerPath = MarkerPath FilePath

computeToolPath :: { tool :: String, version :: String, arch :: Maybe String } -> MaybeT Effect ToolPath
computeToolPath { tool, version, arch } = do
  base <- cacheDir
  pure $ ToolPath $ concat [base, tool, version, fromMaybe "" arch]

markerPath :: ToolPath -> MarkerPath
markerPath (ToolPath path) = MarkerPath $ path <> ".complete"
