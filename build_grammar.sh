#!/usr/bin/env bash
set -e

# build_grammar.sh
# ----------------
# Σκοπός:
#   Δημιουργεί τα FST της γραμματικής (grammar FST) για κάθε dataset (train, dev, test)
#   με βάση τα ARPA μοντέλα που έχουν παραχθεί για το unigram και το bigram LM.
#
# Για κάθε set, το script:
#   1. Αντιγράφει το βασικό language directory (data/lang) σε ένα νέο directory
#      (π.χ. data/lang_train, data/lang_dev, data/lang_test).
#   2. Χρησιμοποιεί τα αντίστοιχα ARPA μοντέλα (π.χ. lm_phone_train_ug.arpa.gz, lm_phone_train_bg.arpa.gz)
#      για να δημιουργήσει τα FST:
#         - G_ug.fst (για το unigram LM)
#         - G_bg.fst (για το bigram LM)
#   3. Ελέγχει το FST με fstisstochastic.
#
# Προϋποθέσεις:
#   - Τα ARPA μοντέλα υπάρχουν στον φάκελο data/local/nist_lm με τα ονόματα:
#         lm_phone_train_ug.arpa.gz, lm_phone_train_bg.arpa.gz,
#         lm_phone_dev_ug.arpa.gz,   lm_phone_dev_bg.arpa.gz,
#         lm_phone_test_ug.arpa.gz,  lm_phone_test_bg.arpa.gz.
#   - Το βασικό language directory (data/lang) υπάρχει και περιέχει το words.txt.

source path.sh

BASE_LANG="data/lang"
NIST_LM_DIR="data/local/nist_lm"

# Λίστα των datasets
for set in train dev test; do
  LANG_OUT="data/lang_${set}"
  echo "Δημιουργία language directory για το set ${set} -> ${LANG_OUT}"
  
  # Αν υπάρχει ήδη το directory, το διαγράφουμε για καθαρό αποτέλεσμα
  rm -rf "${LANG_OUT}"
  cp -r "${BASE_LANG}" "${LANG_OUT}"
  
  for lm_type in ug bg; do
    if [ "$lm_type" == "ug" ]; then
      ARPA_MODEL="${NIST_LM_DIR}/lm_phone_${set}_ug.arpa.gz"
      G_FST="${LANG_OUT}/G_ug.fst"
    else
      ARPA_MODEL="${NIST_LM_DIR}/lm_phone_${set}_bg.arpa.gz"
      G_FST="${LANG_OUT}/G_bg.fst"
    fi
    
    if [ ! -f "${ARPA_MODEL}" ]; then
      echo "[!] Δεν βρέθηκε το ARPA μοντέλο ${ARPA_MODEL} για το set ${set}. Παράλειψη."
      continue
    fi
    
    echo "Μετατροπή του ARPA μοντέλου ${ARPA_MODEL} σε FST για το set ${set}..."
    gunzip -c "${ARPA_MODEL}" | \
      arpa2fst --disambig-symbol=#0 --read-symbol-table="${LANG_OUT}/words.txt" - "${G_FST}"
    echo "Το FST αποθηκεύτηκε ως: ${G_FST}"
    fstisstochastic "${G_FST}" || echo "Προσοχή: Το FST ${G_FST} μπορεί να μην είναι πλήρως stochastic."
  done
done

echo "Η δημιουργία των grammar FST για τα sets train, dev και test ολοκληρώθηκε!"
