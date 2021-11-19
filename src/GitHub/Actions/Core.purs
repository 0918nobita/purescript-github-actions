module GitHub.Actions.Core where

import Prelude

import Control.Monad.Except (ExceptT, throwError)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, toUpper, trim)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (appendTextFile)
import Node.Process (lookupEnv)

type ErrMsg = String

addPath :: String -> ExceptT ErrMsg Aff Unit
addPath path = do
  filePathOpt <- liftEffect $ lookupEnv "GITHUB_PATH"

  case filePathOpt of
    Just filePath ->
      liftEffect $ appendTextFile UTF8 filePath path
    Nothing -> throwError "The GITHUB_PATH environment variable not set"

getInput :: String -> ExceptT ErrMsg Aff String
getInput name = do
  valOpt <-
    liftEffect
      $ map (map trim)
      $ lookupEnv
      $ "INPUT_" <> toUpper (replaceAll (Pattern " ") (Replacement "_") name)

  case valOpt of
    Just val ->
      pure val
    Nothing ->
      throwError $ "Failed to get `" <> name <> "` input"

group :: forall a. String -> Aff a -> Aff a
group name fn = do
  log $ "::group::" <> name
  res <- fn
  log "::endgroup::"
  pure res
