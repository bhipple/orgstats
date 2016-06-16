{-# LANGUAGE OverloadedStrings #-}
module Main where
import Orgstats

import GitHub
import Prelude hiding (FilePath)
import Turtle
import Data.Text hiding (empty)

import Data.Maybe (fromMaybe)
import Data.String (fromString)
import System.Environment (getEnv, lookupEnv)

import qualified Data.Vector as V

data Settings = Settings { sOrg :: Text,
                           sOutputDir :: Maybe FilePath }

parser :: Parser Settings
parser = Settings <$> optText "org" 'o' "Github organization name"
                  <*> optional
                        (optPath "outdir" 'O' "Directory to output generated HTML files; defaults to [org]-stats")

main :: IO ()
main = do
    (Settings org outdir) <- options
        "Utility for generating gitstats on every repo in an organization" parser
    token <- getEnv "GITHUB_TOKEN"
    endpoint <- fromMaybe "https://api.github.com" <$> lookupEnv "GITHUB_API_ENDPOINT"
    let auth = GitHub.EnterpriseOAuth endpoint (fromString token)
    let outputDir = fromMaybe (fromText $ org <> "-stats") outdir
    processOrg auth org outputDir
