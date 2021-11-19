module GitHub.Actions.Core where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, throwError)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, toUpper, trim)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (appendTextFile)
import Node.Path (FilePath)
import Node.Process (lookupEnv)

type ErrMsg = String

addPath :: forall m. MonadEffect m => MonadThrow ErrMsg m => FilePath -> m Unit
addPath path = do
  filePathOpt <- liftEffect $ lookupEnv "GITHUB_PATH"

  case filePathOpt of
    Just filePath ->
      liftEffect $ appendTextFile UTF8 filePath path
    Nothing -> throwError "The GITHUB_PATH environment variable not set"

getInput :: forall m. MonadEffect m => MonadThrow ErrMsg m => String -> m String
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

group :: forall m a. MonadEffect m => String -> m a -> m a
group name fn = do
  log $ "::group::" <> name
  res <- fn
  log "::endgroup::"
  pure res
