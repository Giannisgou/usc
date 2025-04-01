#!/usr/bin/env bash
set -e

# build_grammar.sh
# ----------------
# Σκοπός:
#   Δημιουργεί τα FST της γραμματικής (grammar FST) για το unigram και το bigram
#   γλωσσικό μοντέλο και τα αποθηκεύει μέσα στον φάκελο data/lang.
#
# Τα παραχθέντα FST θα ονομάζονται:
#   data/lang/G_ug.fst   (για το unigram LM)
#   data/lang/G_bg.fst   (για το bigram LM)
#
# Προϋποθέσεις:
#   - Τα ARPA μοντέλα υπάρχουν στα αρχεία:
#         data/local/nist_lm/lm_phone_ug.arpa.gz
#         data/local/nist_lm/lm_phone_bg.arpa.gz
#   - Το αρχείο data/lang/words.txt υπάρχει και περιέχει το symbol table.
#   - Έχεις κάνει source το path.sh ώστε να είναι διαθέσιμα τα εργαλεία του Kaldi (π.χ. arpa2fst).

source path.sh

LANG_DIR="data/lang"
NIST_LM_DIR="data/local/nist_lm"

UNIGRAM_ARPA="${NIST_LM_DIR}/lm_phone_ug.arpa.gz"
BIGRAM_ARPA="${NIST_LM_DIR}/lm_phone_bg.arpa.gz"

G_UG="${LANG_DIR}/G_ug.fst"
G_BG="${LANG_DIR}/G_bg.fst"

# Έλεγχος ύπαρξης του symbol table
if [ ! -f "${LANG_DIR}/words.txt" ]; then
  echo "[!] Δεν βρέθηκε το ${LANG_DIR}/words.txt. Βεβαιώσου ότι το language directory έχει προετοιμαστεί σωστά."
  exit 1
fi

echo "Δημιουργία Unigram grammar FST..."
gunzip -c "${UNIGRAM_ARPA}" | arpa2fst --disambig-symbol=#0 --read-symbol-table="${LANG_DIR}/words.txt" - "${G_UG}"
echo "Το Unigram FST αποθηκεύτηκε ως: ${G_UG}"
fstisstochastic "${G_UG}" || echo "Προσοχή: Το Unigram FST μπορεί να μην είναι πλήρως stochastic."

echo "Δημιουργία Bigram grammar FST..."
gunzip -c "${BIGRAM_ARPA}" | arpa2fst --disambig-symbol=#0 --read-symbol-table="${LANG_DIR}/words.txt" - "${G_BG}"
echo "Το Bigram FST αποθηκεύτηκε ως: ${G_BG}"
fstisstochastic "${G_BG}" || echo "Προσοχή: Το Bigram FST μπορεί να μην είναι πλήρως stochastic."

echo "Η δημιουργία των grammar FST ολοκληρώθηκε και βρίσκονται μέσα στον φάκελο ${LANG_DIR}"
