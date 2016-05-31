{-# LANGUAGE OverloadedStrings #-}
module Main where
import GitHub
import GitHub.Auth
import GitHub.Endpoints.Repos
import Turtle
import Data.Text hiding (empty)

import Data.Maybe (fromMaybe, fromJust)
import Data.String (fromString)
import System.Environment (getEnv, lookupEnv)

import qualified Data.Vector as V

org = "scrp"
outdir = "/Users/bhipple/public_html/"

main :: IO ()
main = do
    token <- getEnv "GITHUB_TOKEN"
    endpoint <- fromMaybe "https://api.github.com" <$> lookupEnv "GITHUB_API_ENDPOINT"
    let auth = GitHub.EnterpriseOAuth endpoint (fromString token)
    resp <- organizationRepos' (Just auth) (mkOrganizationName org) RepoPublicityAll
    case resp of
        (Left error) -> print error
        (Right repos) -> do
            -- Only take repos that have been initialized
            let r' = V.filter ((>0) . fromJust . repoSize) repos
            mktree ".work"
            V.mapM_ download r'
            V.mapM_ (generateStats outdir) r'

    putStrLn "Done"

download :: Repo -> IO ()
download r = do
    let dirName = ".work/" <> toName r
    print $ "Processing " <> dirName
    res <- testdir (fromText dirName)
    if res
        then shells ("cd " <> dirName <> " && git pull") empty
        else shells ("cd .work && git clone " <> repoHtmlUrl r) empty

toName :: Repo -> Text
toName = untagName . repoName

generateStats :: Text -> Repo -> IO ()
generateStats fp r = let rn = toName r
                         outpath = fp <> "/" <> org <> "/" <> rn
                     in shells ("gitstats .work/" <> rn <> " " <> outpath) empty
