#!/bin/bash
set -e

source path.sh

# Αντιγραφή του score.sh 
echo "Αντιγραφή score.sh από ../wsj/s5/local/score.sh στο ./local/score.sh..."
mkdir -p local
cp ../wsj/s5/local/score.sh local/score.sh

# 2) Δημιουργία γράφου για το Unigram LM
echo "=== Δημιουργία Unigram γράφου ==="
# - Αντιγράφουμε το G_ug.fst σε G.fst
cp data/lang_test/G_ug.fst data/lang_test/G.fst
utils/mkgraph.sh --mono data/lang_test exp/mono exp/mono/graph_ug || exit 1

# 3) Αποκωδικοποίηση με τον Unigram γράφο
echo "=== Decoding (Unigram) για dev set ==="
steps/decode.sh exp/mono/graph_ug data/dev exp/mono/decode_dev_ug || exit 1

echo "=== Decoding (Unigram) για test set ==="
steps/decode.sh exp/mono/graph_ug data/test exp/mono/decode_test_ug || exit 1

# 2) Δημιουργία γράφου για το Bigram LM
echo "=== Δημιουργία Bigram γράφου ==="
cp data/lang_test/G_bg.fst data/lang_test/G.fst
utils/mkgraph.sh --mono data/lang_test exp/mono exp/mono/graph_bg || exit 1

# 3) Αποκωδικοποίηση με τον Bigram γράφο
echo "=== Decoding (Bigram) για dev set ==="
steps/decode.sh exp/mono/graph_bg data/dev exp/mono/decode_dev_bg || exit 1

echo "=== Decoding (Bigram) για test set ==="
steps/decode.sh exp/mono/graph_bg data/test exp/mono/decode_test_bg || exit 1

# 4) Υπολογισμός PER
echo "=== Αποτελέσματα Unigram ==="
echo "Dev set:"
./local/score.sh data/dev data/lang_test exp/mono/decode_dev_ug
echo "Test set:"
./local/score.sh data/test data/lang_test exp/mono/decode_test_ug

echo ""
echo "=== Αποτελέσματα Bigram ==="
echo "Dev set:"
./local/score.sh data/dev data/lang_test exp/mono/decode_dev_bg
echo "Test set:"
./local/score.sh data/test data/lang_test exp/mono/decode_test_bg

echo ""
echo "Ολοκληρώθηκε η δημιουργία γράφων, αποκωδικοποίηση και scoring για Unigram/Bigram."
