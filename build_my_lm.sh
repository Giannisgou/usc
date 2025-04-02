#!/usr/bin/env bash
# 4.2.2
# build_my_lm.sh
# --------------
# Σκοπός:
#   Χρήση του εργαλείου IRSTLM (build-lm.sh) για τη δημιουργία unigram και bigram
#   γλωσσικού μοντέλου από τα αρχεία κειμένου lm_{set}.text για κάθε set (train, dev, test).
#
# Προϋποθέσεις:
#   - Το Kaldi και το IRSTLM είναι εγκατεστημένα, και έχει γίνει "source path.sh".
#   - Τα αρχεία κειμένου για το LM υπάρχουν:
#         data/local/dict/lm_train.text
#         data/local/dict/lm_dev.text
#         data/local/dict/lm_test.text
#   - Ο φάκελος data/local/lm_tmp υπάρχει ή θα δημιουργηθεί από αυτό το script.

source path.sh

set -e

LM_TMP_DIR="data/local/lm_tmp"
mkdir -p "${LM_TMP_DIR}"

for set in train dev test; do
  INPUT_FILE="data/local/dict/lm_${set}.text"
  if [ ! -f "${INPUT_FILE}" ]; then
    echo "Δεν βρέθηκε το ${INPUT_FILE}. Παραλείπω το set ${set}."
    continue
  fi
  
  echo "Δημιουργία unigram γλωσσικού μοντέλου για το set ${set}..."
  build-lm.sh -i "${INPUT_FILE}" -n 1 -o "${LM_TMP_DIR}/unigram_${set}.ilm.gz"
  
  echo "Δημιουργία bigram γλωσσικού μοντέλου για το set ${set}..."
  build-lm.sh -i "${INPUT_FILE}" -n 2 -o "${LM_TMP_DIR}/bigram_${set}.ilm.gz"
done

echo "Ολοκληρώθηκε η δημιουργία των LM μοντέλων (unigram και bigram) για τα sets train, dev και test στο ${LM_TMP_DIR}"
