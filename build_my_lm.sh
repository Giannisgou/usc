#!/usr/bin/env bash
# 4.2.2
# build_my_lm.sh
# --------------
# Σκοπός:
#   Χρήση του εργαλείου IRSTLM (build-lm.sh) για τη δημιουργία unigram και bigram γλωσσικού μοντέλου
#   από το αρχείο κειμένου lm_train.text.
#
# Προϋποθέσεις:
#   - Το Kaldi και το IRSTLM είναι εγκατεστημένα, και έχει γίνει `source path.sh`.
#   - Υπάρχει το αρχείο data/local/dict/lm_train.text που περιέχει τις προτάσεις για το LM.
#   - Ο φάκελος data/local/lm_tmp υπάρχει ή θα δημιουργηθεί από αυτό το script.
source path.sh

set -e  # Τερματίζει το script αν υπάρξει κάποιο σφάλμα

LM_TMP_DIR="data/local/lm_tmp"
TRAIN_TEXT="data/local/dict/lm_train.text"

echo "Δημιουργία unigram γλωσσικού μοντέλου..."
build-lm.sh -i "${TRAIN_TEXT}" \
            -n 1 \
            -o "${LM_TMP_DIR}/unigram.ilm.gz"

echo "Δημιουργία bigram γλωσσικού μοντέλου..."
build-lm.sh -i "${TRAIN_TEXT}" \
            -n 2 \
            -o "${LM_TMP_DIR}/bigram.ilm.gz"

echo "Ολοκληρώθηκε η δημιουργία των unigram και bigram LM στο ${LM_TMP_DIR}"
