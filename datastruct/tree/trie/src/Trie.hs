{-
    Trie.hs, Alphabetic Trie.
    Copyright (C) 2010, Liu Xinyu (liuxinyu95@gmail.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-}

-- Refer to http://en.wikipedia.org/wiki/Trie
module Trie where

import Data.List (sort, sortBy)
import Data.Function (on)
import qualified Data.Map as Map


-- Assoc list based Trie
data Trie k v = Trie { value :: Maybe v
                     , subTrees :: [(k, Trie k v)]} deriving (Show)

empty = Trie Nothing []

insert :: Eq k => Trie k v -> [k] -> v -> Trie k v
insert (Trie _ ts) [] x = Trie (Just x) ts
insert (Trie v ts) (k:ks) x = Trie v (ins ts) where
    ins [] = [(k, insert empty ks x)]
    ins ((c, t) : ts) = if c == k then (k, insert t ks x) : ts
                        else (c, t) : (ins ts)

lookup :: Eq k => [k] -> Trie k v -> Maybe v
lookup [] t = value t
lookup (k:ks) t = case Prelude.lookup k (subTrees t) of
                  Nothing -> Nothing
                  Just t' -> Trie.lookup ks t'

fromList :: Eq k => [([k], v)] -> Trie k v
fromList xs = foldl ins empty xs where
  ins t (k, v) = insert t k v

fromString :: (Enum v, Num v) => String -> Trie Char v
fromString = fromList . (flip zip [1..]) . words

-- Pre-order traverse to populate keys in lexicographical order
keys :: Ord k => Trie k v -> [[k]]
keys t = map reverse $ keys' t [] where
  keys' t prefix = case (value t) of
    Nothing -> ks
    (Just _ ) -> prefix : ks
    where
      ks = concatMap (\(k, t') -> keys' t' (k : prefix)) ts
      ts = sortBy (compare `on` fst) (subTrees t)

-- example
example = insert (fromString "a place where animals are for public to see") "zoo" 0

-- test data
assocs = [[("a", 1), ("an", 2), ("another", 7), ("boy", 3), ("bool", 4), ("zoo", 3)],
          [("zoo", 3), ("bool", 4), ("boy", 3), ("another", 7), ("an", 2), ("a", 1)]]

verify = all (\as ->
                 let t = fromList as in
                   all (\(k, v) -> maybe False (==v) (Trie.lookup k t)) as) assocs

verifyKeys = all (\as ->
                   keys (fromList as) == (sort $ fst $ unzip as)) assocs
