#!/usr/bin/env bash
#
# text_to_phonemes.sh
#
# Σκοπός:
#   Για κάθε αρχείο text που δημιουργήσατε (στο data/train, data/dev, data/test),
#   να μετατρέπει το transcription σε αλληλουχία φωνημάτων χρησιμοποιώντας το λεξικό στο files/lexicon.txt,
#   αντικαθιστώντας το αρχικό αρχείο text.
#
# Απαιτήσεις:
#   - Το files/lexicon.txt πρέπει να έχει τη μορφή (χωρισμένο με whitespace ή tab):
#         word    PHONEME1 PHONEME2 ...
#     π.χ.:
#         this    dh ih s
#         was     w ao z
#         easy    iy z iy
#
#   - Τα αρχεία text έχουν τη μορφή:
#         utterance_id   Transcription
#
# Η μετατροπή περιλαμβάνει:
#   • Μετατροπή σε lower case.
#   • Αφαίρεση ειδικών χαρακτήρων (επιτρέπονται μόνο οι χαρακτήρες a-z, το space και το single quote).
#   • Αντικατάσταση κάθε λέξης με την αντίστοιχη φωνηματική ακολουθία από το λεξικό.
#   • Προσθήκη "sil" στην αρχή και στο τέλος.
#

LEXICON="files/lexicon.txt"
DATA_DIR="data"
SETS=("train" "dev" "test")

for set in "${SETS[@]}"; do
  TEXT_FILE="${DATA_DIR}/${set}/text"
  TMP_FILE="${TEXT_FILE}.tmp"
  
  awk -v lexicon="${LEXICON}" '
    BEGIN {
      # Διαβάζουμε το λεξικό και αποθηκεύουμε κάθε λέξη (σε lower case) μαζί με την φωνηματική ακολουθία της.
      while ((getline < lexicon) > 0) {
         word = tolower($1);
         $1 = "";
         gsub(/^[ \t]+/, "", $0);  # Αφαίρεση αρχικών κενών.
         mapping[word] = $0;
      }
      close(lexicon);
    }
    {
      utt_id = $1;
      # Συνένωση των υπολοίπων πεδίων για τη μεταγραφή.
      transcription = "";
      for (i = 2; i <= NF; i++) {
          transcription = transcription $i " ";
      }
      transcription = tolower(transcription);
      # Αφαίρεση ειδικών χαρακτήρων (επιτρέπονται μόνο a-z, το space και το single quote).
      gsub(/[^a-z'\'' ]/, "", transcription);
      
      # Διαχωρισμός της μεταγραφής σε λέξεις.
      n = split(transcription, words, /[ \t]+/);
      
      # Ξεκινάμε με το "sil" στην αρχή.
      phonemes = "sil";
      for (i = 1; i <= n; i++) {
         if (words[i] != "") {
            if (words[i] in mapping) {
               phonemes = phonemes " " mapping[words[i]];
            } else {
               phonemes = phonemes " <unk>";
            }
         }
      }
      # Προσθέτουμε "sil" στο τέλος.
      phonemes = phonemes " sil";
      
      print utt_id, phonemes;
    }
  ' "${TEXT_FILE}" > "${TMP_FILE}"
  
  # Μετακίνηση του προσωρινού αρχείου για αντικατάσταση του αρχικού
  mv "${TMP_FILE}" "${TEXT_FILE}"
  
  echo "Ενημερώθηκε το αρχείο ${TEXT_FILE}"
done

echo "Η μετατροπή των transcriptions σε φωνηματικές ακολουθίες ολοκληρώθηκε!"
