{-# LANGUAGE OverloadedStrings #-}
module Main where
import Orgstats

import GitHub
import Turtle
import Data.Text hiding (empty)

import Data.Maybe (fromMaybe)
import Data.String (fromString)
import System.Environment (getEnv, lookupEnv)

import qualified Data.Vector as V

org = "mmit"
outdir = "/Users/bhipple/public_html/"

main :: IO ()
main = do
    token <- getEnv "GITHUB_TOKEN"
    endpoint <- fromMaybe "https://api.github.com" <$> lookupEnv "GITHUB_API_ENDPOINT"
    let auth = GitHub.EnterpriseOAuth endpoint (fromString token)
    processOrg auth org outdir
