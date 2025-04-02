#!/usr/bin/env python3
import subprocess
import sys

def run_command(command):
    """
    Εκτελεί την εντολή, προσθέτοντας "source path.sh &&" στην αρχή ώστε να φορτωθεί το περιβάλλον του Kaldi.
    Αν υπάρχει σφάλμα, τερματίζει το script.
    """
    # Συνδυάζουμε την εντολή σε μία συμβολοσειρά
    full_command = "source path.sh && " + " ".join(command)
    print("Running command: " + full_command)
    result = subprocess.run(full_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        print("Error executing command:")
        print(result.stderr)
        sys.exit(result.returncode)
    else:
        print(result.stdout)

def main():
    sets = ["train", "dev", "test"]
    
    for s in sets:
        print(f"Processing set: data/{s}")
        # Εκτέλεση του steps/make_mfcc.sh
        make_mfcc_cmd = [
            "steps/make_mfcc.sh", 
            "--nj", "10", 
            "--cmd", "run.pl", 
            "--config", "conf/mfcc.conf",
            f"data/{s}", 
            f"exp/make_mfcc/{s}", 
            "mfcc"
        ]
        run_command(make_mfcc_cmd)
        
        # Εκτέλεση του steps/compute_cmvn_stats.sh
        compute_cmvn_cmd = [
            "steps/compute_cmvn_stats.sh", 
            f"data/{s}", 
            f"exp/make_mfcc/{s}", 
            "mfcc"
        ]
        run_command(compute_cmvn_cmd)
        
        print(f"Finished processing set: data/{s}\n")
    
    print("MFCC extraction and CMVN computation completed for all sets.")

if __name__ == "__main__":
    main()
