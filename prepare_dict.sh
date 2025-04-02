#!/usr/bin/env bash
# 4.2.1
# prepare_dict.sh
# ---------------
# Σκοπός:
#   1. Δημιουργία των βασικών αρχείων για το λεξικό στο data/local/dict/:
#         silence_phones.txt, optional_silence.txt, nonsilence_phones.txt, lexicon.txt.
#   2. Συγκέντρωση του κειμένου από τα data/train/text, data/dev/text και data/test/text
#      σε αρχεία lm_train.text, lm_dev.text, lm_test.text, προσθέτοντας στην αρχή κάθε πρότασης
#      το <s> και στο τέλος το </s>.
#   3. Δημιουργία του αρχείου extra_questions.txt.
#
# Προϋποθέσεις:
#   - Το αρχείο files/lexicon.txt περιέχει γραμμές της μορφής:
#         EXPLAINABLE    ih k s p l ey n ah b ah l
#   - Τα αρχεία data/train/text, data/dev/text και data/test/text έχουν τη μορφή:
#         utt_id word1 word2 word3 ...
#   - Το φώνημα σιωπής είναι "sil".
#   - Στο nonsilence_phones.txt θα εξαχθούν όλα τα φωνήματα (ξεχωριστά, χωρίς διπλότυπα)
#   - Στο lexicon.txt που δημιουργείται θα έχει κάθε γραμμή τη μορφή:
#         φωνήμα <space> φωνήμα   (π.χ.  aa aa)
#
source path.sh
set -e  # Τερματίζει το script σε περίπτωση σφάλματος

#####################################
# 1. Δημιουργία φακέλου data/local/dict
#####################################
echo "Δημιουργία φακέλου data/local/dict..."
mkdir -p data/local/dict

#####################################
# 2. silence_phones.txt και optional_silence.txt
#####################################
echo "Δημιουργία silence_phones.txt και optional_silence.txt..."
echo "sil" > data/local/dict/silence_phones.txt
echo "sil" > data/local/dict/optional_silence.txt

#####################################
# 3. nonsilence_phones.txt
#####################################
echo "Δημιουργία nonsilence_phones.txt..."
LEXICON_SRC="files/lexicon.txt"
if [ ! -f "${LEXICON_SRC}" ]; then
  echo "[!] Δεν βρέθηκε το ${LEXICON_SRC}. Τερματισμός."
  exit 1
fi
awk '{for(i=2; i<=NF; i++) print $i}' "${LEXICON_SRC}" | grep -v "^sil$" | sort -u > data/local/dict/nonsilence_phones.txt

#####################################
# 4. lexicon.txt (δύο στήλες: φωνήμα <space> το ίδιο φωνήμα)
#####################################
echo "Δημιουργία lexicon.txt με δύο στήλες (φωνήμα <κενό> το ίδιο φωνήμα)..."
awk '{print $1, $1}' data/local/dict/nonsilence_phones.txt > data/local/dict/lexicon.txt

#####################################
# 5. Δημιουργία lm_train.text, lm_dev.text, lm_test.text με προσθήκη <s> και </s>
#####################################
echo "Δημιουργία lm_train.text από data/train/text..."
TRAIN_TEXT="data/train/text"
LM_TRAIN="data/local/dict/lm_train.text"
if [ -f "${TRAIN_TEXT}" ]; then
  awk '{if(NF>1) {print $1, "<s>", substr($0, index($0,$2)), "</s>"} else {print $0}}' "${TRAIN_TEXT}" > "${LM_TRAIN}"
else
  echo "[!] Δεν βρέθηκε το ${TRAIN_TEXT}. Δημιουργούμε κενό lm_train.text."
  touch "${LM_TRAIN}"
fi

echo "Δημιουργία lm_dev.text από data/dev/text..."
DEV_TEXT="data/dev/text"
LM_DEV="data/local/dict/lm_dev.text"
if [ -f "${DEV_TEXT}" ]; then
  awk '{if(NF>1) {print $1, "<s>", substr($0, index($0,$2)), "</s>"} else {print $0}}' "${DEV_TEXT}" > "${LM_DEV}"
else
  echo "[!] Δεν βρέθηκε το ${DEV_TEXT}. Δημιουργούμε κενό lm_dev.text."
  touch "${LM_DEV}"
fi

echo "Δημιουργία lm_test.text από data/test/text..."
TEST_TEXT="data/test/text"
LM_TEST="data/local/dict/lm_test.text"
if [ -f "${TEST_TEXT}" ]; then
  awk '{if(NF>1) {print $1, "<s>", substr($0, index($0,$2)), "</s>"} else {print $0}}' "${TEST_TEXT}" > "${LM_TEST}"
else
  echo "[!] Δεν βρέθηκε το ${TEST_TEXT}. Δημιουργούμε κενό lm_test.text."
  touch "${LM_TEST}"
fi

#####################################
# 6. extra_questions.txt
#####################################
echo "Δημιουργία extra_questions.txt..."
cat <<EOF > data/local/dict/extra_questions.txt
EOF

echo "Ολοκληρώθηκε η προετοιμασία του λεξικού (data/local/dict)!"
