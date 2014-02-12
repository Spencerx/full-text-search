{-# LANGUAGE BangPatterns, GeneralizedNewtypeDeriving #-}
module Data.SearchEngine.DocTermIds (
    DocTermIds,
    TermId,
    fieldLength,
    fieldTermCount,
    fieldElems,
    create,
    vecIndexIx,
    vecCreateIx,
  ) where

import Data.SearchEngine.TermBag (TermBag, TermId)
import qualified Data.SearchEngine.TermBag as TermBag

import Data.Vector (Vector, (!))
import qualified Data.Vector as Vec
import Data.Ix (Ix)
import qualified Data.Ix as Ix


-- | The 'TermId's for the 'Term's that occur in a document. Documents may have
-- multiple fields and the 'DocTerms' type holds them separately for each field.
--
newtype DocTermIds field = DocTermIds (Vector TermBag)
  deriving (Show)

getField :: (Ix field, Bounded field) => DocTermIds field -> field -> TermBag
getField (DocTermIds fieldVec) = vecIndexIx fieldVec

create :: (Ix field, Bounded field) =>
          (field -> [TermId]) -> DocTermIds field
create docTermIds =
    DocTermIds (vecCreateIx (TermBag.fromList . docTermIds))

-- | The number of terms in a field within the document.
fieldLength :: (Ix field, Bounded field) => DocTermIds field -> field -> Int
fieldLength docterms field =
    TermBag.size (getField docterms field)

-- | The frequency of a particular term in a field within the document.
fieldTermCount :: (Ix field, Bounded field) => DocTermIds field -> field -> TermId -> Int
fieldTermCount docterms field termid =
    TermBag.termCount (getField docterms field) termid

fieldElems :: (Ix field, Bounded field) => DocTermIds field -> field -> [TermId]
fieldElems docterms field =
    TermBag.elems (getField docterms field)

---------------------------------
-- Vector indexed by Ix Bounded
--

vecIndexIx  :: (Ix ix, Bounded ix) => Vector a -> ix -> a
vecIndexIx vec ix = vec ! Ix.index (minBound, maxBound) ix

vecCreateIx :: (Ix ix, Bounded ix) => (ix -> a) -> Vector a
vecCreateIx f = Vec.fromListN (Ix.rangeSize bounds)
                  [ y | ix <- Ix.range bounds, let !y = f ix ]
  where
    bounds = (minBound, maxBound)

