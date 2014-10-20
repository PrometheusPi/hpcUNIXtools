#! /usr/bin/env python

import os
import re
import argparse
import numpy as np
import datetime as dt
import matplotlib.pyplot as plt
from matplotlib.dates import date2num, DateFormatter


parser = argparse.ArgumentParser(
           description="Shows start time for slurm jobs over time.",
           epilog="For further questions please contact Richard Pausch.")


parser.add_argument('-l', '--log',
                    dest="path2log",
                    metavar="Path to log file directory", 
                    action='store',
                    help="directory to look for log files",
                    default="~/log/")

args = parser.parse_args()
logDirectory = args.path2log


fontsize=14
plt.figure("starttime")
ax = plt.subplot(111)
ax.set_xlabel("time", fontsize=fontsize)
ax.set_ylabel("time till estimated start [days]", fontsize=fontsize)
# dummy for axis scaling
maxDurration = 0.0


# go through each file
for logfile in os.listdir(logDirectory):
    if (logfile.startswith("starttime_") and logfile.endswith(".log")):
        # extract job id from filename
        name = (re.search("starttime_(.+?).log", logfile)).group(1)
        # get data
        data = np.loadtxt(logfile, usecols=(1,3))
        # convert  unix time to  dates
        time_humanReadable = [dt.datetime.fromtimestamp(ts) for ts in data[:,0]]
        # convert to fractional date in days starting from year 1
        time_matplotlib = date2num(time_humanReadable)
        # get time till estimated start in days
        durration = (data[:,1]-data[:,0]) / (60.**2*24.) # [hours]
        # compute maximum durration
        maxDurration = np.max((maxDurration, np.amax(durration)))
        # plot change in start time estimate
        plt.plot(time_matplotlib, durration, label=name)


# set plot options
ax.set_yticks(np.arange(0, 14, 0.5))
plt.xticks( rotation=90 )
xfmt = DateFormatter('%d.%m.%Y %H:%M')
ax.xaxis.set_major_formatter(xfmt)
plt.ylim(0, 1.1*maxDurration)
plt.legend(loc=0, fontsize=fontsize)

plt.tight_layout()
plt.show()
