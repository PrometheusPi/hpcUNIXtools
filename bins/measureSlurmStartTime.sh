#!/bin/bash

SUBMITFILE=submit.start    # temporary submit file
OUTPUTFILE=starttimes.log  # log file for start time data

NODES=32                   # number of tasks requested
GPUS=2                     # number of GPUs per node
TASKSPERNODE=$GPUS



[ -f ./$OUTPUTFILE ] || printf "INFO         SEK \t   STARTTIME\n" > $OUTPUTFILE 

# check for several wall times
for WALLTIME in 1 2 3 4 12 24 36 48
do
    # delete previous submit file
    rm $SUBMITFILE

    # write new submit file
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

    # start submit file and save jobid
    OUTPUT=$(sbatch $SUBMITFILE)
    JOBID=$(echo $OUTPUT | awk '{print $4}')

    # verbose output for user
    echo " ------- "
    echo $OUTPUT
    echo "please wait ..."
    sleep 120

    # extract start time
    TIME1=$(scontrol show job $JOBID | grep SubmitTime | awk '{print $1}' | sed -e 's/SubmitTime=//g')
    TIME2=$(scontrol show job $JOBID | grep StartTime | awk '{print $1}' | sed -e 's/StartTime=//g')

    # compute UNIX time of times (in seconds)
    TIME1SEK=$(date -d $TIME1 +%s)
    TIME2SEK=$(date -d $TIME2 +%s)

    # compute seconds till job starts (in seconds)
    TIME=$(expr $TIME2SEK - $TIME1SEK)

    # print data to file
    printf "walltime_in_h=%d , nodes=%d GPUs=%d -> %d \t %s\n" $WALLTIME $NODES $GPUS $TIME $TIME2 >> $OUTPUTFILE

    # cancel test job
    scancel $JOBID

done
