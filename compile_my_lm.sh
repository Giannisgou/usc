#!/usr/bin/env bash
# compile_my_lm.sh
# 4.2.3
# ----------------
# Σκοπός:
#   Χρήση του compile-lm (IRSTLM) για να μετατρέψουμε τα .ilm.gz μοντέλα για κάθε set
#   (train, dev, test) σε αρχεία ARPA (gzip), αφαιρώντας τυχόν <unk> γραμμές.
#
# Για παράδειγμα, για το set "train":
#   Input:  data/local/lm_tmp/unigram_train.ilm.gz, data/local/lm_tmp/bigram_train.ilm.gz
#   Output: data/local/nist_lm/lm_phone_train_ug.arpa.gz, data/local/nist_lm/lm_phone_train_bg.arpa.gz
#
# Προϋποθέσεις:
#   - Έχεις κάνει source path.sh ώστε να φορτωθούν οι απαραίτητες μεταβλητές και εργαλεία.
#   - Τα μοντέλα (.ilm.gz) υπάρχουν στον φάκελο data/local/lm_tmp.
#   - Ο φάκελος data/local/nist_lm υπάρχει ή θα δημιουργηθεί από αυτό το script.

source path.sh
set -e

# Ορισμός φακέλων
LM_TMP_DIR="data/local/lm_tmp"
NIST_LM_DIR="data/local/nist_lm"
mkdir -p "${NIST_LM_DIR}"

# Λίστα των sets για τα οποία θέλουμε να χτίσουμε τα LM μοντέλα.
for set in train dev test; do
  # Ορισμός αρχείων εισόδου και εξόδου για το κάθε set
  UG_ILM="${LM_TMP_DIR}/unigram_${set}.ilm.gz"
  BG_ILM="${LM_TMP_DIR}/bigram_${set}.ilm.gz"
  UG_OUT="${NIST_LM_DIR}/lm_phone_${set}_ug.arpa.gz"
  BG_OUT="${NIST_LM_DIR}/lm_phone_${set}_bg.arpa.gz"
  
  if [ ! -f "${UG_ILM}" ]; then
    echo "[!] Δεν βρέθηκε το αρχείο ${UG_ILM} για το set ${set}."
    continue
  fi
  if [ ! -f "${BG_ILM}" ]; then
    echo "[!] Δεν βρέθηκε το αρχείο ${BG_ILM} για το set ${set}."
    continue
  fi
  
  echo "Compiling unigram LM για το set ${set}..."
  compile-lm "${UG_ILM}" -t=yes /dev/stdout | grep -v unk | gzip -c > "${UG_OUT}"
  echo "Το unigram μοντέλο για το set ${set} αποθηκεύτηκε ως: ${UG_OUT}"
  
  echo "Compiling bigram LM για το set ${set}..."
  compile-lm "${BG_ILM}" -t=yes /dev/stdout | grep -v unk | gzip -c > "${BG_OUT}"
  echo "Το bigram μοντέλο για το set ${set} αποθηκεύτηκε ως: ${BG_OUT}"
done

echo "Η διαδικασία compile-lm ολοκληρώθηκε. Τα μοντέλα βρίσκονται στον φάκελο ${NIST_LM_DIR}"
