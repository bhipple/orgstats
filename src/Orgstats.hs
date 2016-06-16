{-# LANGUAGE OverloadedStrings #-}
module Orgstats (
    processOrg
  , getRepos
  , download
  , generateStats
  , toName
  )
where

import GitHub
import GitHub.Endpoints.Repos (organizationRepos')
import Prelude hiding (FilePath)
import Turtle
import Data.Text hiding (empty)
import Data.Maybe (fromJust)
import qualified Data.Vector as V

processOrg :: Auth -> Text -> FilePath -> IO ()
processOrg auth org outdir = do
    repos <- getRepos auth org
    mktree ".work"
    V.mapM_ download repos
    V.mapM_ (generateStats org outdir) repos

getRepos :: Auth -> Text -> IO (V.Vector Repo)
getRepos auth org = do
    resp <- organizationRepos' (Just auth) (mkOrganizationName org) RepoPublicityAll
    case resp of
        (Left error) -> do
            print error
            return mempty
        (Right repos) ->
            -- Only take repos that have been initialized
            return $ V.filter ((>0) . fromJust . repoSize) repos

toName :: Repo -> Text
toName = untagName . repoName

download :: Repo -> IO ()
download r = do
    let dirName = ".work/" <> toName r
    print $ "Processing " <> dirName
    res <- testdir (fromText dirName)
    if res
        then shells ("cd " <> dirName <> " && git pull") empty
        else shells ("cd .work && git clone " <> repoHtmlUrl r) empty

generateStats :: Text -> FilePath -> Repo -> IO ()
generateStats org outdir r = let rn = toName r
                                 outpath = format fp outdir <> "/" <> org <> "/" <> rn
                             in shells ("gitstats .work/" <> rn <> " " <> outpath) empty
