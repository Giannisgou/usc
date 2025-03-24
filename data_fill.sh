#!/usr/bin/env bash
#
# data_fill.sh
# ------------
# Σκοπός:
#   - Διαβάζει τα αρχεία training.txt, validation.txt, testing.txt από τον φάκελο files/filesets/
#   - Για κάθε utterance_id της μορφής "f1_003", "m3_010", κ.λπ. δημιουργεί:
#       * uttids
#       * utt2spk
#       * wav.scp
#       * text
#     στους φακέλους data/train, data/dev, data/test.
#   - Στο αρχείο text, για κάθε utterance_id εξάγεται το numeric κομμάτι (π.χ. "003") και γίνεται αναζήτηση
#     στο files/transcriptions.txt (γραμμές της μορφής "003<TAB>Transcription...") ώστε να αντιστοιχιστεί το κείμενο.
#
# Προϋποθέτει ότι το transcriptions.txt έχει τη μορφή:
#   001<TAB>This was easy for us.
#   002<TAB>Jane may earn more money by working hard.
#   003<TAB>She is thinner than I am.
#   ...

# -- Ρυθμίσεις διαδρομών --
FILESETS_DIR="files/filesets"          # Περιέχει τα training.txt, validation.txt, testing.txt
WAV_DIR="files/wav"                    # Περιέχει τα .wav αρχεία
DATA_DIR="data"                        # Θα δημιουργηθούν τα data/train, data/dev, data/test
TRANSCRIPTIONS="files/transcriptions.txt"  # Το αρχείο transcriptions.txt

# -- Χαρτογράφηση των αρχείων .txt στα αντίστοιχα σετ --
DATASETS=("train" "dev" "test")
FILELISTS=("training.txt" "validation.txt" "testing.txt")

# Δημιουργούμε τους φακέλους data/<set> αν δεν υπάρχουν
for set in "${DATASETS[@]}"; do
  mkdir -p "${DATA_DIR}/${set}"
done

# Για κάθε σετ (train, dev, test)...
for i in "${!DATASETS[@]}"; do
  setname="${DATASETS[$i]}"       # π.χ. "train", "dev", "test"
  filelist="${FILELISTS[$i]}"       # π.χ. "training.txt", "validation.txt", "testing.txt"

  echo "Επεξεργασία σετ: ${setname} (αρχείο: ${filelist})"

  # Ορισμός των αρχείων-δείκτες
  uttids_file="${DATA_DIR}/${setname}/uttids"
  utt2spk_file="${DATA_DIR}/${setname}/utt2spk"
  wavscp_file="${DATA_DIR}/${setname}/wav.scp"
  text_file="${DATA_DIR}/${setname}/text"

  # Εκκαθάριση προηγούμενων περιεχομένων
  > "${uttids_file}"
  > "${utt2spk_file}"
  > "${wavscp_file}"
  > "${text_file}"

  # Έλεγχος ύπαρξης του αρχείου με τα IDs
  file_list_path="${FILESETS_DIR}/${filelist}"
  if [ ! -f "${file_list_path}" ]; then
    echo "  [!] Το αρχείο ${file_list_path} δεν υπάρχει. Παραλείπεται το σετ: ${setname}"
    continue
  fi

  # Διαβάζουμε κάθε γραμμή (π.χ. "f1_003")
  while IFS= read -r utt_id; do
    # 1) uttids: Απλά γράφουμε το utterance_id
    echo "${utt_id}" >> "${uttids_file}"

    # 2) utt2spk: Ο speaker_id είναι το μέρος πριν το '_'
    speaker_id="$(echo "${utt_id}" | cut -d'_' -f1)"
    echo "${utt_id} ${speaker_id}" >> "${utt2spk_file}"

    # 3) wav.scp: Υποθέτουμε ότι το αρχείο ήχου είναι αποθηκευμένο ως files/wav/<utt_id>.wav
    wav_path="${WAV_DIR}/${utt_id}.wav"
    echo "${utt_id} ${wav_path}" >> "${wavscp_file}"

    # 4) text: Εξαγωγή του numeric κομματιού (μετά το '_') από το utt_id
    numeric_id="$(echo "${utt_id}" | cut -d'_' -f2)"
    # Αναζήτηση στο transcriptions.txt για γραμμή που ξεκινά με το numeric_id και tab ή άλλο whitespace
    text_line="$(grep -m 1 "^${numeric_id}[[:space:]]" "${TRANSCRIPTIONS}")"
    if [ -z "${text_line}" ]; then
      actual_text="NO_TRANSCRIPTION_FOUND"
    else
      # Χρήση του cut για να πάρουμε το κείμενο μετά το πρώτο πεδίο (ο διαχωρισμός γίνεται με tab)
      actual_text="$(echo "${text_line}" | cut -f2-)"
    fi
    echo "${utt_id} ${actual_text}" >> "${text_file}"
  done < "${file_list_path}"

  echo "  -> Ολοκληρώθηκε η δημιουργία των αρχείων για το σετ: ${setname}"
done

echo "Η διαδικασία γέμισματος των data/ φακέλων ολοκληρώθηκε!"
