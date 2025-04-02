#!/usr/bin/env bash
# 4.2.3
# compile_my_lm.sh
# ----------------
# Σκοπός:
#   Χρήση του compile-lm (IRSTLM) για να μετατρέψουμε τα .ilm.gz (unigram, bigram)
#   σε αρχεία ARPA (gzip), αφαιρώντας τυχόν <unk> γραμμές.
#
# Προϋποθέσεις:
#   - Το Kaldi και το IRSTLM είναι εγκατεστημένα, και έχει γίνει `source path.sh`.
#   - Υπάρχουν τα αρχεία data/local/lm_tmp/unigram.ilm.gz και bigram.ilm.gz
#   - Θέλουμε να παράγουμε, αντίστοιχα, τα unigram_lm_phone_ug.arpa.gz και bigram_lm_phone_bg.arpa.gz
source path.sh
#!/usr/bin/env bash
set -e

# Ορισμός φακέλων
LM_TMP_DIR="data/local/lm_tmp"
NIST_LM_DIR="data/local/nist_lm"


# Ορισμός αρχείων εισόδου (το compiled ILM μοντέλο)
UNIGRAM_ILM="${LM_TMP_DIR}/unigram.ilm.gz"
BIGRAM_ILM="${LM_TMP_DIR}/bigram.ilm.gz"

# Ορισμός αρχείων εξόδου
UNIGRAM_OUT="${NIST_LM_DIR}/lm_phone_ug.arpa.gz"
BIGRAM_OUT="${NIST_LM_DIR}/lm_phone_bg.arpa.gz"

# Έλεγχος ύπαρξης αρχείων εισόδου
if [ ! -f "${UNIGRAM_ILM}" ]; then
  echo "[!] Δεν βρέθηκε το αρχείο ${UNIGRAM_ILM}"
  exit 1
fi

if [ ! -f "${BIGRAM_ILM}" ]; then
  echo "[!] Δεν βρέθηκε το αρχείο ${BIGRAM_ILM}"
  exit 1
fi

echo "Compiling unigram LM..."
compile-lm "${UNIGRAM_ILM}" -t=yes /dev/stdout | grep -v unk | gzip -c > "${UNIGRAM_OUT}"
echo "Το unigram μοντέλο αποθηκεύτηκε ως: ${UNIGRAM_OUT}"

echo "Compiling bigram LM..."
compile-lm "${BIGRAM_ILM}" -t=yes /dev/stdout | grep -v unk | gzip -c > "${BIGRAM_OUT}"
echo "Το bigram μοντέλο αποθηκεύτηκε ως: ${BIGRAM_OUT}"

echo "Η διαδικασία compile-lm ολοκληρώθηκε. Τα μοντέλα βρίσκονται στον φάκελο ${NIST_LM_DIR}"
