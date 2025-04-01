#!/usr/bin/env bash
# sort_files.sh
# Σκοπός: Ταξινομεί τα αρχεία wav.scp, text και utt2spk στους φακέλους data/train, data/dev και data/test
source ./path.sh

for set in train dev test; do
  echo "Ταξινόμηση αρχείων στο data/${set}..."
  for file in wav.scp text utt2spk; do
    sort data/${set}/${file} -o data/${set}/${file}
  done
done

echo "Η ταξινόμηση ολοκληρώθηκε!"
