#!/usr/bin/env bash
# 4.2.6
# create_spk2utt.sh
# Σκοπός: Δημιουργεί τα spk2utt αρχεία από τα utt2spk στα data/train, data/dev και data/test

for set in train dev test; do
  echo "Δημιουργία spk2utt για το set: ${set}"
  utils/utt2spk_to_spk2utt.pl data/${set}/utt2spk > data/${set}/spk2utt
done

echo "Η δημιουργία των spk2utt ολοκληρώθηκε!"
