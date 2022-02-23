# PlayerSwap
This script uses the text files generated by a program like StreamLabels to track incoming bits/subs to see which "side" is in the lead allowing for some fun content creation.
It tracks who should be playing at a given point in time as well as how much $ is required to swap back to the other player.

![image](https://user-images.githubusercontent.com/53557479/155297542-26b26483-14b1-4482-bc44-2ea28bd1c819.png)

## For subs
The script tracks subpoints and does a simple `subpounts` * `2.5` to get a $ value. Technically this means Tier 3 subs account for more than they're supposed to but it's more accurate than T2 & T3 subs not counting any extra at all

## For bits
The script tracks the amount of bits given in the current session, then does a simple `bits` / `100` to get an accurate $ value

## What to do
- Download and install [StreamLabels](https://streamlabs.com/dashboard#/streamlabels)
- Download and install the [latest version of PlayerSwap](https://github.com/Tomshiii/PlayerSwap/releases)
- Set the destination folder for the text files within StreamLabels using the button shown here -> ![image](https://user-images.githubusercontent.com/53557479/155299364-b75c082a-1964-411f-bf47-33f664a6993c.png)
- Set same folder within the included `User_Value.ini` file
- Set name and colours for bot players within the included `User_Value.ini` file
- Keep both `PlayerSwap.exe` and `StreamLabels` open and enjoy!
 
*Note: Streamlabels only updates its text files periodically, this script reads those files every 2.5s, so although this script is constantly updating, StreamLabels is incredibly slow to update and you will notice a delay*

