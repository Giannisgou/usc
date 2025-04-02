#!/bin/bash
source ./path.sh
cd "data/local/lm_tmp"

echo "# Calculating perplexity for the unigram model of the dev set #"
compile-lm unigram_dev.ilm.gz --eval=../dict/lm_dev.text --dub=10000000

echo "# Calculating perplexity for the bigram model of the dev set #"
compile-lm bigram_dev.ilm.gz --eval=../dict/lm_dev.text --dub=10000000

echo "# Calculating perplexity for the unigram model of the test set #"
compile-lm unigram_test.ilm.gz --eval=../dict/lm_test.text --dub=10000000

echo "# Calculating perplexity for the bigram model of the test set #"
compile-lm bigram_test.ilm.gz --eval=../dict/lm_test.text --dub=10000000

cd ../../..
