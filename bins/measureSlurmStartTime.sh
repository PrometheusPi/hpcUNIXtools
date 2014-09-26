#!/bin/bash

SUBMITFILE=submit.start
OUTPUTFILE=starttimes.log

NODES=32
GPUS=2
TASKSPERNODE=$GPUS



[ -f ./$OUTPUTFILE ] || printf "INFO         SEK \t   STARTTIME\n" > $OUTPUTFILE 

for WALLTIME in 1 2 3 4 12 24 36 48
do


    rm $SUBMITFILE

    printf "#!/bin/bash \n" >> $SUBMITFILE
    printf " \n" >> $SUBMITFILE
    printf "#SBATCH --job-name=slurmTest \n" >> $SUBMITFILE
    printf "#SBATCH --nodes=%d \n" $NODES >> $SUBMITFILE
    printf "#SBATCH --ntasks-per-node=%d \n" $TASKSPERNODE >> $SUBMITFILE
    printf "#SBATCH --cpus-per-task=8 \n" >> $SUBMITFILE
    printf "#SBATCH --time=%d:00:00 \n" $WALLTIME >> $SUBMITFILE
    printf "#SBATCH --gres=gpu:%d \n" $GPUS >> $SUBMITFILE
    printf " \n">> $SUBMITFILE
    printf "sleep 1800 \n" >> $SUBMITFILE
    printf "hostname \n" >> $SUBMITFILE
    printf " ">> $SUBMITFILE


    OUTPUT=$(sbatch $SUBMITFILE)
    JOBID=$(echo $OUTPUT | awk '{print $4}')

    echo " ------- "
    echo $OUTPUT
    echo "please wait ..."
    sleep 120

    TIME1=$(scontrol show job $JOBID | grep SubmitTime | awk '{print $1}' | sed -e 's/SubmitTime=//g')
    TIME2=$(scontrol show job $JOBID | grep StartTime | awk '{print $1}' | sed -e 's/StartTime=//g')

    TIME1SEK=$(date -d $TIME1 +%s)
    TIME2SEK=$(date -d $TIME2 +%s)

    TIME=$(expr $TIME2SEK - $TIME1SEK)
    printf "walltime_in_h=%d , nodes=%d GPUs=%d -> %d \t %s\n" $WALLTIME $NODES $GPUS $TIME $TIME2 >> $OUTPUTFILE

    scancel $JOBID

done
