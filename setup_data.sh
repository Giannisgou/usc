#!/bin/bash

# Δημιουργία βασικού φακέλου data και υποφακέλων για training, validation και testing
mkdir -p data/train data/dev data/test

# Λίστα με τα αρχεία-δείκτες που πρέπει να δημιουργηθούν
index_files=("uttids" "utt2spk" "wav.scp" "text")

# Δημιουργία των αρχείων-δείκτες σε κάθε υποφάκελο
for dir in data/train data/dev data/test; do
    for file in "${index_files[@]}"; do
        # Δημιουργία κενών αρχείων, αν δεν υπάρχουν ήδη
        touch "$dir/$file"
    done
done

echo "Η δομή φακέλων και τα αρχεία-δείκτες δημιουργήθηκαν επιτυχώς."

