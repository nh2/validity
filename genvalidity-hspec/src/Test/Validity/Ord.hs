{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

-- | Ord properties
--
-- You will need @TypeApplications@ to use these.
module Test.Validity.Ord
    ( ordSpecOnGen
    , ordSpecOnValid
    , ordSpecOnInvalid
    , ordSpec
    , ordSpecOnArbitrary
    ) where

import Data.Data

import Data.GenValidity

import Test.Hspec
import Test.QuickCheck

import Test.Validity.Functions
import Test.Validity.Relations
import Test.Validity.Utils

{-# ANN module "HLint: ignore Use <=" #-}

{-# ANN module "HLint: ignore Use >=" #-}

{-# ANN module "HLint: ignore Use <" #-}

{-# ANN module "HLint: ignore Use >" #-}

leTypeStr
    :: forall a.
       Typeable a
    => String
leTypeStr = binRelStr @a "<="

geTypeStr
    :: forall a.
       Typeable a
    => String
geTypeStr = binRelStr @a ">="

ltTypeStr
    :: forall a.
       Typeable a
    => String
ltTypeStr = binRelStr @a "<"

gtTypeStr
    :: forall a.
       Typeable a
    => String
gtTypeStr = binRelStr @a ">"

-- | Standard test spec for properties of Ord instances for valid values
--
-- Example usage:
--
-- > ordSpecOnValid @Double
ordSpecOnValid
    :: forall a.
       (Show a, Ord a, Typeable a, GenValid a)
    => Spec
ordSpecOnValid = ordSpecOnGen @a genUnchecked "unchecked"

-- | Standard test spec for properties of Ord instances for invalid values
--
-- Example usage:
--
-- > ordSpecOnInvalid @Double
ordSpecOnInvalid
    :: forall a.
       (Show a, Ord a, Typeable a, GenInvalid a)
    => Spec
ordSpecOnInvalid = ordSpecOnGen @a genInvalid "invalid"

-- | Standard test spec for properties of Ord instances for unchecked values
--
-- Example usage:
--
-- > ordSpec @Int
ordSpec
    :: forall a.
       (Show a, Ord a, Typeable a, GenUnchecked a)
    => Spec
ordSpec = ordSpecOnGen @a genUnchecked "unchecked"

-- | Standard test spec for properties of Ord instances for arbitrary values
--
-- Example usage:
--
-- > ordSpecOnArbitrary @Int
ordSpecOnArbitrary
    :: forall a.
       (Show a, Ord a, Typeable a, Arbitrary a)
    => Spec
ordSpecOnArbitrary = ordSpecOnGen @a arbitrary "unchecked"

-- | Standard test spec for properties of Ord instances for values generated by a given generator (and name for that generator).
--
-- Example usage:
--
-- > ordSpecOnGen ((* 2) <$> genValid @Int) "even"
ordSpecOnGen
    :: forall a.
       (Show a, Eq a, Ord a, Typeable a)
    => Gen a -> String -> Spec
ordSpecOnGen gen genname =
    parallel $ do
        let name = nameOf @a
            funlestr = leTypeStr @a
            fungestr = geTypeStr @a
            funltstr = ltTypeStr @a
            fungtstr = gtTypeStr @a
            cmple = (<=) @a
            cmpge = (>=) @a
            cmplt = (<) @a
            cmpgt = (>) @a
            gen2 = (,) <$> gen <*> gen
            gen3 = (,,) <$> gen <*> gen <*> gen
        describe ("Ord " ++ name) $ do
            describe funlestr $ do
                it
                    (unwords
                         [ "is reflexive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    reflexivityOnGen cmple gen
                it
                    (unwords
                         [ "is antisymmetric for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    antisymmetryOnGens cmple gen2
                it
                    (unwords
                         [ "is transitive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    transitivityOnGens cmple gen3
                it
                    (unwords
                         [ "is equivalent to (\\a b -> compare a b /= GT) for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    equivalentOnGens2 cmple (\a b -> compare a b /= GT) gen2
            describe fungestr $ do
                it
                    (unwords
                         [ "is reflexive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    reflexivityOnGen cmpge gen
                it
                    (unwords
                         [ "is antisymmetric for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    antisymmetryOnGens cmpge gen2
                it
                    (unwords
                         [ "is transitive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    transitivityOnGens cmpge gen3
                it
                    (unwords
                         [ "is equivalent to (\\a b -> compare a b /= LT) for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    equivalentOnGens2 cmpge (\a b -> compare a b /= LT) gen2
            describe funltstr $ do
                it
                    (unwords
                         [ "is antireflexive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    antireflexivityOnGen cmplt gen
                it
                    (unwords
                         [ "is transitive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    transitivityOnGens cmplt gen3
                it
                    (unwords
                         [ "is equivalent to (\\a b -> compare a b == LT) for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    equivalentOnGens2 cmplt (\a b -> compare a b == LT) gen2
            describe fungtstr $ do
                it
                    (unwords
                         [ "is antireflexive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    antireflexivityOnGen cmpgt gen
                it
                    (unwords
                         [ "is transitive for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    transitivityOnGens cmpgt gen3
                it
                    (unwords
                         [ "is equivalent to (\\a b -> compare a b == GT) for"
                         , "\"" ++ genname
                         , name ++ "\"" ++ "'s"
                         ]) $
                    equivalentOnGens2 cmpgt (\a b -> compare a b == GT) gen2
