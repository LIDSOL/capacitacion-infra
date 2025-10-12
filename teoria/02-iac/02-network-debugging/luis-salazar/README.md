# Solution

My solution was very simple: I created a service that executes a bash script. This keeps my program running even after my playbook finishes. This bash script uses a command called ip monitor link,
whose main function is to react to network changes. For an internet connection, my target was the default interface, so with the ip monitor command I analyze every network change, and if the change happens to be on the default interface, I bring it up immediately. Monitoring only reacts to changes, so it uses very few resources.